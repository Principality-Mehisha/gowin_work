"""Validate a score, then upload it through an HC-05 serial port.

Without --port this is an offline validation only. A physical port is never
opened implicitly. Install pyserial only on the computer doing the transfer.
"""
from __future__ import annotations

import argparse
import binascii
from dataclasses import dataclass
from pathlib import Path
import struct
import time
import zlib

MAX_FILE_BYTES = 100 * 1024
STATUS = {
    0: "OK", 1: "packet CRC", 2: "invalid arguments", 3: "unexpected sequence",
    4: "no upload session", 5: "busy", 6: "file CRC", 7: "invalid score",
    8: "storage/layout error", 9: "cancelled", 10: "session timeout",
    11: "receive FIFO overflow", 12: "UART framing error",
}


def validate_score(data: bytes, instrument: str) -> None:
    if not 24 <= len(data) <= MAX_FILE_BYTES:
        raise ValueError(f"File must be 24..{MAX_FILE_BYTES} bytes")
    magic, version, record_bytes, slots, reserved, rate, count = struct.unpack_from("<4sBBBBII", data)
    expected = b"P88S" if instrument == "piano" else b"M42S"
    if ((magic, version, record_bytes, reserved, rate) != (expected, 1, 8, 0, 1000)
            or slots not in (8, 32)):
        raise ValueError(f"Expected a {expected.decode()} v1 score with 8 or 32 slots")
    if not 1 <= count <= 20000 or len(data) != 16 + count * 8:
        raise ValueError("Header event count does not match the actual file length")
    previous = 0
    for index, (timestamp, slot, note, velocity, padding) in enumerate(struct.iter_unpack("<IBBBB", data[16:])):
        if timestamp < previous or padding:
            raise ValueError(f"Invalid event {index}")
        previous = timestamp
        if index == count - 1:
            if (slot, note, velocity) != (255, 255, 0):
                raise ValueError("Missing final end record")
        elif slot >= slots or velocity >= 128 or not (
            0 <= note <= 87 if instrument == "piano" else 36 <= note <= 83
        ):
            raise ValueError(f"Invalid note event {index}")


def load_score(path: Path, instrument: str) -> bytes:
    data = path.read_bytes()
    # Windows sees a fixed 100 KiB file; its P88S/M42S header still carries
    # the actual event count. Accept zero padding exported from a slot.
    if len(data) == MAX_FILE_BYTES and len(data) >= 16:
        actual = 16 + struct.unpack_from("<I", data, 12)[0] * 8
        if 24 <= actual <= len(data) and not any(data[actual:]):
            data = data[:actual]
    validate_score(data, instrument)
    return data


def packet(operation: int, sequence: int, payload: bytes = b"") -> bytes:
    if operation not in (1, 3, 4) or sequence != 0 or len(payload) > 10:
        raise ValueError("Packet sequence or length out of range")
    body = struct.pack("<2sBBHH", b"\xa5\x5a", 2, operation, sequence, len(payload)) + payload
    return body + struct.pack("<H", binascii.crc_hqx(body, 0))


@dataclass(frozen=True)
class Reply:
    operation: int
    sequence: int
    status: int
    detail: int
    reserved: int


def decode_reply(frame: bytes) -> Reply:
    if len(frame) != 12 or frame[:3] != b"\x5a\xa5\x02":
        raise ValueError("Bad reply header")
    if binascii.crc_hqx(frame[:10], 0) != struct.unpack_from("<H", frame, 10)[0]:
        raise ValueError("Bad reply CRC")
    return Reply(*struct.unpack_from("<BHBBH", frame, 3))


def read_reply(port, deadline: float) -> Reply:
    buffer = bytearray()
    while time.monotonic() < deadline:
        byte = port.read(1)
        if not byte:
            continue
        buffer.extend(byte)
        while len(buffer) >= 2 and buffer[:2] != b"\x5a\xa5":
            del buffer[0]
        if len(buffer) >= 12:
            try:
                return decode_reply(bytes(buffer[:12]))
            except ValueError:
                del buffer[0]
    raise TimeoutError("No valid FPGA response")


def exchange(port, operation: int, sequence: int, payload: bytes = b"", *,
             timeout: float = 60, retries: int = 3) -> Reply:
    request = packet(operation, sequence, payload)
    for attempt in range(retries):
        port.write(request)
        port.flush()
        deadline = time.monotonic() + timeout
        try:
            while True:
                reply = read_reply(port, deadline)
                if reply.operation == 4 and reply.status:
                    raise RuntimeError(f"FPGA aborted: {STATUS.get(reply.status, 'error')}; detail=0x{reply.detail:02X}")
                if (reply.operation, reply.sequence) != (operation, sequence):
                    continue
                if reply.status == 1:
                    break
                if reply.status:
                    raise RuntimeError(f"{STATUS.get(reply.status, 'unknown error')}; detail=0x{reply.detail:02X}")
                return reply
        except TimeoutError:
            if attempt == retries - 1:
                raise
    raise RuntimeError("Packet CRC rejected repeatedly")


def upload(port, data: bytes, instrument: str, number: int) -> None:
    validate_score(data, instrument)
    kind = 1 if instrument == "piano" else 2
    header = struct.pack("<BBII", kind, number, len(data), zlib.crc32(data))
    print("Preparing and clearing 100 KiB slot...")
    exchange(port, 1, 0, header, timeout=300)
    print("READY. Sending raw file bytes; no DATA packets or per-block acknowledgements.")
    try:
        count = port.write(data)
        if count != len(data):
            raise OSError(f"Short serial write: {count}/{len(data)}")
        port.flush()
        exchange(port, 3, 0, timeout=120)
    except BaseException:
        # A control frame cannot interrupt a raw binary body. Sending CANCEL
        # here could be consumed as file bytes. Let the idle timeout invalidate it.
        print("Transfer failed. The old slot is invalid; wait for FPGA timeout before playback or retry.")
        raise
    print("\nUpload committed.")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("file", type=Path)
    parser.add_argument("--instrument", choices=("piano", "marimba"), required=True)
    parser.add_argument("--number", type=int, required=True, choices=range(1, 101), metavar="1..100")
    parser.add_argument("--port", help="HC-05/SPP or USB-TTL COM port; omission means offline check only")
    args = parser.parse_args()
    data = load_score(args.file, args.instrument)
    name = f"{'PN' if args.instrument == 'piano' else 'MB'}{args.number:03}.BIN"
    print(f"{name}: {len(data)} raw bytes, CRC32={zlib.crc32(data):08X}, protocol v2")
    if not args.port:
        print("Offline validation passed. No port opened and no SD card modified.")
        return
    try:
        import serial
    except ImportError as exc:
        raise SystemExit("Install the upload dependency: python -m pip install pyserial") from exc
    with serial.Serial(args.port, 115200, timeout=0.1, write_timeout=30,
                       rtscts=False, dsrdtr=False) as port:
        port.reset_input_buffer()
        upload(port, data, args.instrument, args.number)


if __name__ == "__main__":
    main()
