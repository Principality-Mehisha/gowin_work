"""Sparse simulation card with cross-group collisions; never access real SD."""
import struct
from pathlib import Path
from fat_test_fixtures import save_hex
from make_upload_fixtures import build, seed, score
from slot_card import metadata

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "output/key_guide"


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    layout, sectors = build()
    events = [
        (0, 0, 6, 100), (0, 1, 22, 110), (0, 2, 25, 100),
        (20, 0, 6, 0), (20, 1, 22, 0), (20, 2, 25, 0),
        (40, 1, 22, 110), (60, 1, 22, 0),
        (80, 1, 22, 110), (100, 1, 22, 0),
        (120, 0, 0, 100), (120, 3, 54, 110),
        (140, 0, 0, 0), (140, 3, 54, 0),
        (160, 4, 87, 100), (180, 4, 87, 0),
        (200, 0, 0, 100), (200, 1, 15, 100),
        (220, 0, 0, 0), (220, 1, 15, 0), (240, 255, 255, 0),
    ]
    data = struct.pack("<4sBBBBII", b"P88S", 1, 8, 8, 0, 1000, len(events))
    data += b"".join(struct.pack("<IBBBB", *event, 0) for event in events)
    seed(sectors, layout, 0, data)
    seed(sectors, layout, 100, b"M42S" + score(60)[4:])
    bad = b"BAD!" + score(39)[4:]
    sectors[layout.lba(1)] = bad.ljust(512, b"\0")
    sectors[9] = metadata(1, bad)
    save_hex(OUT / "card.hex", {lba: bytearray(block) for lba, block in sectors.items()})
    print("PASS: sparse follow-guide fixture, highest-group chords, repeated key7, "
          "C8, EOF, marimba and format error")


if __name__ == "__main__":
    main()
