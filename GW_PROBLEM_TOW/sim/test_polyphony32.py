"""Offline 8/32-slot score compatibility and boundary tests."""
from pathlib import Path
import struct
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))

from bluetooth_upload import load_score, validate_score
from make_piano_score import compile_notes, pack_score
from score_bin import read_p88s
from make_selected_piano import verify_bundle
from prepare_bluetooth_files import prepare


def chord(slots=32, count=32, instrument="piano"):
    first = 0 if instrument == "piano" else 36
    events = [(0, slot, first + slot, 100, 0) for slot in range(count)]
    events += [(100, slot, first + slot, 0, 0) for slot in range(count)]
    events += [(1600, 255, 255, 0, 0)]
    magic = b"P88S" if instrument == "piano" else b"M42S"
    return struct.pack("<4sBBBBII", magic, 1, 8, slots, 0, 1000, len(events)) + b"".join(
        struct.pack("<IBBBB", *event) for event in events)


class PolyphonyTests(unittest.TestCase):
    def test_generator_accepts_32_reuses_all_slots_and_rejects_33(self):
        notes = [dict(start=start, end=start + 0.1, pitch=21 + n, gain=0.8)
                 for start in (0, 0.1) for n in range(32)]
        events, peak = compile_notes(notes, 0.2)
        self.assertEqual(peak, 32)
        self.assertEqual({e[1] for e in events if e[3]}, set(range(32)))
        data = pack_score(events)
        self.assertEqual(data[6], 32)
        validate_score(data, "piano")
        notes.append(dict(start=0, end=0.1, pitch=87, gain=0.8))
        with self.assertRaisesRegex(ValueError, "32 simultaneous"):
            compile_notes(notes, 0.2)

    def test_legacy_and_32_slot_round_trip_and_padding(self):
        with tempfile.TemporaryDirectory() as temporary:
            path = Path(temporary) / "PN001.BIN"
            for slots in (8, 32):
                data = chord(slots, slots)
                path.write_bytes(data)
                _, decoded = read_p88s(path)
                self.assertEqual(decoded["voices"], slots)
                self.assertEqual(decoded["peak_polyphony"], slots)
                self.assertEqual(decoded["note_count"], slots)
                path.write_bytes(data.ljust(102400, b"\0"))
                self.assertEqual(load_score(path, "piano"), data)

    def test_both_instruments_support_legacy_and_32_slots(self):
        for instrument in ("piano", "marimba"):
            for slots in (8, 32):
                data = chord(slots, slots, instrument)
                validate_score(data, instrument)
                files, report = prepare(data, instrument, 1)
                name = "PN001_DATA_END.bin" if instrument == "piano" else "MB001_DATA_END.bin"
                self.assertEqual(files[name][:-10], data)
                self.assertEqual(report["score_slots"], slots)

    def test_invalid_slot_counts_and_slot_boundary_are_rejected(self):
        for instrument in ("piano", "marimba"):
            for slots in (0, 7, 9, 16, 31, 33, 255):
                with self.subTest(instrument=instrument, slots=slots):
                    with self.assertRaises(ValueError):
                        validate_score(chord(slots, 1, instrument), instrument)
            for slots in (8, 32):
                with self.assertRaises(ValueError):
                    validate_score(chord(slots, slots + 1, instrument), instrument)

    def test_analysis_rejects_out_of_range_slot_and_overlapping_slot_reuse(self):
        with tempfile.TemporaryDirectory() as temporary:
            path = Path(temporary) / "score.bin"
            path.write_bytes(chord(8, 9))
            with self.assertRaises(ValueError):
                read_p88s(path)
            data = bytearray(chord())
            data[16 + 8 + 4] = 0
            path.write_bytes(data)
            with self.assertRaisesRegex(ValueError, "retriggered without note-off"):
                read_p88s(path)

    def test_32_note_selected_bundle_validation(self):
        with tempfile.TemporaryDirectory() as temporary:
            directory = Path(temporary)
            data = chord()
            (directory / "PN001.BIN").write_bytes(data)
            files, _ = prepare(data, "piano", 1)
            bundle = directory / "bluetooth/PN001"
            bundle.mkdir(parents=True)
            for name, content in files.items():
                (bundle / name).write_bytes(content)
            verify_bundle(directory, dict(number=1), dict(
                file="PN001.BIN", note_count=32, peak_polyphony=32))


if __name__ == "__main__":
    unittest.main()
