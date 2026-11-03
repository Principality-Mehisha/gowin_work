"""Sparse 32-slot and legacy 8-slot simulation cards; no physical disk access."""
from pathlib import Path
import struct

from fat_test_fixtures import save_hex
from make_piano_score import compile_notes, pack_score
from make_upload_fixtures import seed
from slot_card import image_sectors, layout_for_size

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "output/polyphony32"


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    layout = layout_for_size(3072 * 1024 * 1024)
    sectors = image_sectors(layout)
    for slots, index in ((32, 0), (8, 1)):
        # Include both ends of each instrument's range, with a repeated chord.
        piano = list(range(slots // 2)) + list(range(88 - slots // 2, 88))
        marimba = list(range(36, 36 + slots // 2)) + list(range(84 - slots // 2, 84))
        notes = [dict(start=start, end=start + .02, pitch=note + 21, gain=.7)
                 for start in (0, .04) for note in piano]
        events, peak = compile_notes(notes, .08)
        assert peak == slots
        events[-1] = (100, 255, 255, 0, 0)
        data = bytearray(pack_score(events))
        data[6] = slots
        seed(sectors, layout, index, bytes(data))
        (OUT / f"piano{slots}.bin").write_bytes(data)
        mapped = [tuple([event[0], event[1], marimba[piano.index(event[2])],
                         event[3], event[4]]) if event[1] != 255 else event for event in events]
        data = struct.pack("<4sBBBBII", b"M42S", 1, 8, slots, 0, 1000, len(mapped))
        data += b"".join(struct.pack("<IBBBB", *event) for event in mapped)
        seed(sectors, layout, index + 100, data)
        (OUT / f"marimba{slots}.bin").write_bytes(data)
    save_hex(OUT / "card.hex", {lba: bytearray(block) for lba, block in sectors.items()})
    print("PASS: PN001/MB001 32-note repeated chords, PN002/MB002 legacy 8-note chords")


if __name__ == "__main__":
    main()
