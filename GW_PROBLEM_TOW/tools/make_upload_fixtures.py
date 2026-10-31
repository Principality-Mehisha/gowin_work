"""Prepared FAT32 fixed-slot fixtures; no physical disk access."""
from pathlib import Path
import struct
from fat_test_fixtures import save_hex
from slot_card import image_sectors, layout_for_size, metadata

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "output/fixed_slots"


def score(note=39):
    return struct.pack("<4sBBBBII", b"P88S", 1, 8, 8, 0, 1000, 2) + \
        struct.pack("<IBBBB", 0, 0, note, 100, 0) + struct.pack("<IBBBB", 100, 255, 255, 0, 0)


def build():
    layout = layout_for_size(3072 * 1024 * 1024)
    sectors = image_sectors(layout)
    for index, note in ((0, 35), (1, 39)):
        data = score(note)
        sectors[layout.lba(index)] = data.ljust(512, b"\0")
        sectors[8 + index] = metadata(index, data)
    sectors[layout.lba(0) + 199] = bytes([0xCC]) * 512
    return layout, sectors


if __name__ == "__main__":
    OUT.mkdir(parents=True, exist_ok=True)
    layout, sectors = build()
    save_hex(OUT / "card.hex", {lba: bytearray(block) for lba, block in sectors.items()})
    constants = "\n".join(f"localparam integer {name}={value};" for name, value in (
        ("FIX_DATA_BASE", layout.data_base), ("FIX_SLOT_BASE", layout.slot_base),
        ("FIX_FAT_SECTORS", layout.fat_sectors)))
    (OUT / "layout.vh").write_text(constants + "\n", encoding="ascii")
    print("PASS: fixed FAT32 layout, 200 named files, private metadata, old tail and legacy scores")
