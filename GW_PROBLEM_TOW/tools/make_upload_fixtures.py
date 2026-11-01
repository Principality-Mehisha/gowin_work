"""Prepared FAT32 fixed-slot fixtures; no physical disk access."""
from pathlib import Path
import struct
from fat_test_fixtures import save_hex
from slot_card import image_sectors, layout_for_size, metadata
from bluetooth_upload import validate_score

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


def seed(sectors, layout, index, data):
    validate_score(data, "piano" if index < 100 else "marimba")
    for offset in range(0, len(data), 512):
        sectors[layout.lba(index) + offset // 512] = data[offset:offset + 512].ljust(512, b"\0")
    sectors[8 + index] = metadata(index, data)


if __name__ == "__main__":
    OUT.mkdir(parents=True, exist_ok=True)
    layout, sectors = build()
    save_hex(OUT / "card.hex", {lba: bytearray(block) for lba, block in sectors.items()})
    constants = "\n".join(f"localparam integer {name}={value};" for name, value in (
        ("FIX_DATA_BASE", layout.data_base), ("FIX_SLOT_BASE", layout.slot_base),
        ("FIX_FAT_SECTORS", layout.fat_sectors)))
    (OUT / "layout.vh").write_text(constants + "\n", encoding="ascii")
    player = dict(sectors)
    events = [(0, 0, 39, 127, 0), (0, 1, 43, 100, 0), (0, 2, 46, 80, 0),
              (35, 0, 39, 0, 0), (35, 1, 43, 0, 0), (35, 2, 46, 0, 0),
              (50, 0, 39, 110, 0), (80, 0, 39, 0, 0), (100, 255, 255, 0, 0)]
    chord = struct.pack("<4sBBBBII", b"P88S", 1, 8, 8, 0, 1000, len(events)) + b"".join(
        struct.pack("<IBBBB", *event) for event in events)
    seed(player, layout, 0, chord)
    for index, note in ((100, 60), (199, 67)):
        seed(player, layout, index, b"M42S" + score(note)[4:])
    save_hex(OUT / "player.hex", {lba: bytearray(block) for lba, block in player.items()})
    for name in ("bad_crc", "bad_format", "empty"):
        bad = dict(player)
        if name == "empty":
            bad[8] = bytes(512)
        else:
            data = b"X" + chord[1:]
            bad[layout.lba(0)] = data.ljust(512, b"\0")
            if name == "bad_format":
                bad[8] = metadata(0, data)
        save_hex(OUT / f"{name}.hex", {lba: bytearray(block) for lba, block in bad.items()})
    full = (ROOT / "sd_card/PIANO.BIN").read_bytes()
    seed(player, layout, 1, full)
    save_hex(OUT / "full.hex", {lba: bytearray(block) for lba, block in player.items()})
    (OUT / "full_events.hex").write_text(
        "".join(f"{int.from_bytes(full[i:i+8], 'little'):016x}\n" for i in range(16, len(full), 8)),
        encoding="ascii")
    (OUT / "full_params.vh").write_text(
        f"`define SCORE_EVENTS {(len(full)-16)//8}\n`define SCORE_BYTES {len(full)}\n", encoding="ascii")
    print("PASS: 200-slot-only FAT32 fixtures, piano/marimba, faults and full score in PN002")
