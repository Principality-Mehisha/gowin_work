"""Generate a small piano score, its exact split, and Bluetooth v2 controls.

Offline only: never opens a COM port, SD card, or disk image.
"""
from __future__ import annotations

import argparse
import binascii
import hashlib
import json
from pathlib import Path
import struct
import zlib

from bluetooth_upload import packet, validate_score
from make_piano_score import compile_notes, pack_score

ROOT = Path(__file__).resolve().parents[1]
HEADER_NAME = "\u6587\u4ef6\u5934.bin"
MERGED_NAME = "PN001_DATA_END.bin"


def write_new_files(output: Path, files: dict[str, bytes]) -> None:
    if any((output / name).exists() for name in files):
        raise FileExistsError("Test output already exists; choose a different --output directory")
    output.mkdir(parents=True, exist_ok=True)
    for name, data in files.items():
        with (output / name).open("xb") as file:
            file.write(data)


def two_send_instructions(score_size: int) -> bytes:
    return (
        "Two-send upload with FPGA firmware supporting the score header's slot count:\n"
        "New 32-slot scores require the updated FPGA firmware; old 8-slot firmware rejects them.\n"
        "1. Send BEGIN.bin as RAW; wait for a successful READY response.\n"
        f"2. Within 30 seconds, send {MERGED_NAME} as RAW; wait for final success.\n"
        f"{MERGED_NAME} = complete PN001.BIN ({score_size} bytes) + END.bin (10 bytes).\n"
        f"The BEGIN length remains {score_size}, NOT {score_size + 10}; its CRC32 covers the score only.\n"
        "Do NOT prepend BEGIN.bin: FPGA ignores incoming body data while preparing the SD slot.\n"
        "Do NOT send another PN001.BIN, DATA.bin, score header or END.bin in this upload.\n"
        "The combined file is a transport envelope, not a standalone P88S score file.\n"
        "READY HEX: 5A A5 02 01 00 00 00 00 00 00 08 2A\n"
        "SUCCESS HEX: 5A A5 02 03 00 00 00 00 00 00 EB 4A\n"
        "No serial port, SD card or disk image is accessed by this generator.\n"
    ).encode("ascii")


def merge_existing(output: Path) -> dict:
    score = (output / "PN001.BIN").read_bytes()
    begin = (output / "BEGIN.bin").read_bytes()
    end = (output / "END.bin").read_bytes()
    validate_score(score, "piano")
    expected = packet(1, 0, struct.pack("<BBII", 1, 1, len(score), zlib.crc32(score)))
    if begin != expected or end != packet(3, 0):
        raise ValueError("Existing BEGIN/END does not match PN001 or protocol v2; nothing was changed")
    merged = score + end
    report = {
        "score_bytes": len(score),
        "end_bytes": len(end),
        "score_crc32": f"{zlib.crc32(score):08X}",
        "files": {MERGED_NAME: {"bytes": len(merged), "sha256": hashlib.sha256(merged).hexdigest()}},
        "original_files_unchanged": True,
        "physical_device_accessed": False,
    }
    write_new_files(output, {
        MERGED_NAME: merged,
        "TWO_SEND_README.txt": two_send_instructions(len(score)),
        "merged_manifest.json": (json.dumps(report, indent=2) + "\n").encode("ascii"),
    })
    return report


def generate(output: Path) -> dict:
    pitches = (60, 62, 64, 65, 67, 69, 71, 72)
    notes = [
        {"start": index * 0.5, "end": index * 0.5 + 0.4,
         "pitch": pitch, "gain": 0.8}
        for index, pitch in enumerate(pitches)
    ]
    events, peak = compile_notes(notes, 4.0)
    score = pack_score(events)
    validate_score(score, "piano")
    checksum = zlib.crc32(score)
    begin = packet(1, 0, struct.pack("<BBII", 1, 1, len(score), checksum))
    end = packet(3, 0)
    files = {
        "PN001.BIN": score,
        HEADER_NAME: score[:16],
        "DATA.bin": score[16:],
        "BEGIN.bin": begin,
        "END.bin": end,
        MERGED_NAME: score + end,
    }
    assert files[HEADER_NAME] + files["DATA.bin"] == score
    assert len(score) == 16 + len(events) * 8 == 152
    for frame in (begin, end):
        assert binascii.crc_hqx(frame[:-2], 0) == struct.unpack("<H", frame[-2:])[0]
    assert struct.unpack_from("<BBII", begin, 8) == (1, 1, len(score), checksum)
    report = {
        "target": "PN001.BIN",
        "format": "P88S v1",
        "melody": "C4 D4 E4 F4 G4 A4 B4 C5",
        "duration_ms": events[-1][0],
        "events": len(events),
        "peak_polyphony": peak,
        "score_crc32": f"{checksum:08X}",
        "score_header_hex": score[:16].hex(" ").upper(),
        "begin_hex": begin.hex(" ").upper(),
        "end_hex": end.hex(" ").upper(),
        "files": {
            name: {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}
            for name, data in files.items()
        },
        "physical_device_accessed": False,
    }
    instructions = two_send_instructions(len(score)).decode("ascii") + "\n" + (
        "PN001: ascending piano C-major scale, C4 through C5.\n"
        f"PN001.BIN = {HEADER_NAME} (16-byte P88S header) + DATA.bin (136 event bytes).\n"
        "BEGIN.bin is a separate Bluetooth v2 control frame, NOT the P88S header.\n"
        "\n"
        "Whole-file upload:\n"
        "BEGIN.bin -> wait for successful READY -> PN001.BIN -> END.bin -> wait for success.\n"
        "\n"
        "Split-file upload (equivalent):\n"
        f"BEGIN.bin -> wait for successful READY -> {HEADER_NAME} -> DATA.bin -> END.bin -> wait for success.\n"
        "No per-DATA ACK. Use binary/raw file sending; do not append or convert bytes.\n"
        "Do not send PN001.BIN in addition to its two parts in the same upload.\n"
        "Do not send DATA.bin alone as the complete score. Idle timeout is 30 seconds.\n"
        "Use 115200/8N1 and a card already prepared for the fixed-slot layout.\n"
        "After final success, select piano 1 on the screen; upload does not start playback.\n"
        "Screen command (HEX): A5 5A 01 00 12 01 01 00 15 0D.\n"
        "No physical device was accessed while generating these files.\n"
    )
    files["README.txt"] = instructions.encode("utf-8")
    files["manifest.json"] = (json.dumps(report, ensure_ascii=False, indent=2) + "\n").encode("utf-8")
    write_new_files(output, files)
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=ROOT / "output/bluetooth_test")
    parser.add_argument("--merge-existing", action="store_true",
                        help="Keep existing BEGIN/score/END; create only the combined upload and its notes")
    args = parser.parse_args()
    report = merge_existing(args.output) if args.merge_existing else generate(args.output)
    for name, item in report["files"].items():
        print(f"{name}: {item['bytes']} bytes")
    print(f"Score CRC32: {report['score_crc32']}")
    print(f"PASS: score and protocol controls validated; output={args.output.resolve()}")


if __name__ == "__main__":
    main()
