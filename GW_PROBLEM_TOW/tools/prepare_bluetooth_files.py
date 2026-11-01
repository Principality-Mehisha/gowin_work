"""Prepare two RAW transfer files for an existing score; no device access."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import struct
import zlib

from bluetooth_upload import load_score, packet, validate_score

ROOT = Path(__file__).resolve().parents[1]


def prepare(score: bytes, instrument: str, number: int, data_name: str | None = None):
    if instrument not in ("piano", "marimba") or not 1 <= number <= 100:
        raise ValueError("Expected piano/marimba and number 1..100")
    validate_score(score, instrument)
    target = f"{'PN' if instrument == 'piano' else 'MB'}{number:03}.BIN"
    data_name = data_name or f"{target[:-4]}_DATA_END.bin"
    if Path(data_name).name != data_name or not data_name.lower().endswith(".bin") or data_name.lower() == "begin.bin":
        raise ValueError("Merged name must be a .bin basename different from BEGIN.bin")
    checksum = zlib.crc32(score)
    begin = packet(1, 0, struct.pack("<BBII", 1 if instrument == "piano" else 2, number, len(score), checksum))
    merged = score + packet(3, 0)
    files = {"BEGIN.bin": begin, data_name: merged}
    report = {
        "target": target,
        "instrument": instrument,
        "number": number,
        "score_bytes": len(score),
        "score_crc32": f"{checksum:08X}",
        "score_sha256": hashlib.sha256(score).hexdigest(),
        "begin_hex": begin.hex(" ").upper(),
        "files": {
            name: {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}
            for name, data in files.items()
        },
        "physical_device_accessed": False,
    }
    notes = (
        f"TARGET: {target}. The target is encoded in BEGIN, NOT inferred from the transport filename.\n"
        "Use these two files as a matched pair; do not reuse BEGIN from a different score.\n"
        f"1. Send BEGIN.bin as RAW; wait for READY.\n"
        f"2. Within 30 seconds of READY, send {data_name} as RAW; wait for final success.\n"
        f"Merged content: {len(score)} original score bytes + 10 END control bytes.\n"
        "Do not send another score header, score file or END frame in this session.\n"
        "READY HEX: 5A A5 02 01 00 00 00 00 00 00 08 2A\n"
        "SUCCESS HEX: 5A A5 02 03 00 00 00 00 00 00 EB 4A\n"
        "The merged file is a transport envelope, not a standalone score.\n"
        "No COM port, physical card or disk image was opened by this tool.\n"
    )
    files["README.txt"] = notes.encode("ascii")
    return files, report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("file", type=Path)
    parser.add_argument("--instrument", choices=("piano", "marimba"), required=True)
    parser.add_argument("--number", type=int, choices=range(1, 101), required=True, metavar="1..100")
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--data-name", help="Optional transport filename; does not change the SD target")
    args = parser.parse_args()
    score = load_score(args.file, args.instrument)
    files, report = prepare(score, args.instrument, args.number, args.data_name)
    report["source"] = str(args.file.resolve())
    files["manifest.json"] = (json.dumps(report, indent=2) + "\n").encode("ascii")
    if any((args.output / name).exists() for name in files):
        raise FileExistsError("Output already exists; choose a new --output directory")
    args.output.mkdir(parents=True, exist_ok=True)
    for name, data in files.items():
        with (args.output / name).open("xb") as file:
            file.write(data)
    print(json.dumps(report, indent=2))
    print("PASS: transfer files prepared offline; original score unchanged")


if __name__ == "__main__":
    main()
