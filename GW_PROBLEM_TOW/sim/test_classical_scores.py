"""Exercise MIDI-to-P88S compatibility without downloading or opening ports."""
from pathlib import Path
import struct
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))

from make_classical_scores import CATALOG, convert_song, generate
from midi_notes import mido, read_notes
from score_bin import read_p88s
from bluetooth_upload import load_score


def write_midi(path, intervals, tempos=()):
    midi = mido.MidiFile(ticks_per_beat=480)
    track = mido.MidiTrack()
    midi.tracks.append(track)
    events = [(0, -2, mido.Message("program_change", program=0))]
    for tick, tempo in tempos:
        events.append((tick, -1, mido.MetaMessage("set_tempo", tempo=tempo)))
    for start, end, pitch, velocity, channel in intervals:
        events += [(start, 1, mido.Message("note_on", note=pitch, velocity=velocity, channel=channel)),
                   (end, 0, mido.Message("note_off", note=pitch, velocity=0, channel=channel))]
    previous = 0
    for tick, _, message in sorted(events, key=lambda event: (event[0], event[1])):
        message.time = tick - previous
        track.append(message)
        previous = tick
    path.parent.mkdir(parents=True, exist_ok=True)
    midi.save(path)


class PianoLibraryTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="gw_classics_test_", dir=ROOT / "sim")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)

    def test_tempo_velocity_range_and_terminal_event(self):
        source = self.root / "tempo.mid"
        write_midi(source, [(0, 960, 60, 100, 0)], [(480, 1000000)])
        report = convert_song(CATALOG[0], source, self.root / "out")
        _, score = read_p88s(self.root / "out/PN001.BIN")
        self.assertEqual(score["notes"][0]["note"], 39)
        self.assertEqual(score["notes"][0]["start_ms"], 0)
        self.assertEqual(score["notes"][0]["end_ms"], 1500)
        self.assertGreater(score["notes"][0]["velocity"], 0)
        self.assertLessEqual(score["notes"][0]["velocity"], 127)
        self.assertEqual(report["duration_ms"], 3000)
        load_score(self.root / "out/PN001.BIN", "piano")

    def test_same_pitch_retrigger_does_not_leave_stale_note_off(self):
        source = self.root / "unisons.mid"
        write_midi(source, [(0, 960, 60, 80, 0), (0, 480, 60, 110, 1),
                            (240, 720, 60, 100, 2)])
        report = convert_song(CATALOG[0], source, self.root / "out")
        _, score = read_p88s(self.root / "out/PN001.BIN")
        self.assertEqual(report["source_note_count"], 3)
        self.assertEqual(report["note_count"], 2)
        self.assertEqual(report["merged_unisons"], 1)
        self.assertEqual(report["shortened_same_pitch_retriggers"], 1)
        self.assertEqual([(n["start_ms"], n["end_ms"]) for n in score["notes"]],
                         [(0, 250), (250, 750)])

    def test_nine_notes_are_rejected_without_publishing_a_partial_library(self):
        source_dir = self.root / "source"
        for song in CATALOG:
            count = 9 if song["number"] == 2 else 1
            write_midi(source_dir / song["midi"], [(0, 480, 48 + i, 100, 0) for i in range(count)])
        with self.assertRaisesRegex(ValueError, "eight simultaneous"):
            generate(source_dir, self.root / "out")
        self.assertFalse((self.root / "out").exists())

    def test_oversized_score_is_rejected(self):
        source = self.root / "large.mid"
        write_midi(source, [(i * 96, i * 96 + 48, 60, 100, 0) for i in range(6400)])
        with self.assertRaisesRegex(ValueError, "102400"):
            convert_song(CATALOG[0], source, self.root / "out")
        self.assertFalse((self.root / "out").exists())

    def test_all_three_filenames_and_upload_validation(self):
        source_dir = self.root / "source"
        for song in CATALOG:
            write_midi(source_dir / song["midi"], [(0, 480, 60 + song["number"], 100, 0)])
        reports = generate(source_dir, self.root / "out")
        self.assertEqual([r["file"] for r in reports], ["PN001.BIN", "PN002.BIN", "PN003.BIN"])
        for report in reports:
            data = load_score(self.root / "out" / report["file"], "piano")
            self.assertEqual(struct.unpack_from("<4sBBBBII", data)[:6], (b"P88S", 1, 8, 8, 0, 1000))
            self.assertEqual(report["bytes"], len(data))
        with self.assertRaises(FileExistsError):
            generate(source_dir, self.root / "out")

    def test_existing_multi_minute_reader_guard_stays_enabled(self):
        source = self.root / "short.mid"
        write_midi(source, [(0, 480, 60, 100, 0)])
        with self.assertRaisesRegex(ValueError, "1000 notes"):
            read_notes(source)


if __name__ == "__main__":
    unittest.main()
