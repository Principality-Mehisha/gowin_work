"""Check byte-level P88S decoding and generated timing against the actual score."""
import hashlib
import json
import struct
import sys
import unittest
from unittest.mock import patch
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))
from score_bin import read_p88s


def pack(records):
    return struct.pack('<4sBBBBII', b'P88S', 1, 8, 8, 0, 1000, len(records)) + b''.join(
        struct.pack('<IBBBB', *r) for r in records)


class ScoreBinTests(unittest.TestCase):
    def read(self, payload):
        with patch.object(Path, 'read_bytes', return_value=payload):
            return read_p88s(Path('fixture.bin'))

    def test_chord_limits_and_60hz_rounding(self):
        records = [(0, 0, 0, 127, 0), (0, 1, 87, 80, 0),
                   (125, 0, 0, 0, 0), (250, 1, 87, 0, 0), (300, 255, 255, 0, 0)]
        events, info = self.read(pack(records))
        self.assertEqual(events, [(0, 8, 0), (0, 15, 87)])
        self.assertEqual(info['peak_polyphony'], 2)
        self.assertEqual(info['notes'][1]['velocity'], 80)

    def test_malformed_inputs(self):
        valid = [(0, 0, 39, 90, 0), (200, 0, 39, 0, 0), (300, 255, 255, 0, 0)]
        bad = [b'PCM', b'WAVE' + pack(valid)[4:], pack(valid)[:-1],
               pack([valid[0], (200, 0, 40, 0, 0), valid[-1]]),
               pack([(0, 8, 39, 90, 0), valid[1], valid[-1]]),
               pack([(0, 0, 88, 90, 0), valid[1], valid[-1]]),
               pack([(0, 0, 39, 128, 0), valid[1], valid[-1]]),
               pack([valid[0], (200, 0, 39, 0, 1), valid[-1]]),
               pack([valid[0], valid[1], (100, 255, 255, 0, 0)]),
               pack([valid[0], (300, 255, 255, 0, 0)]),
               pack([valid[0], valid[1], (300, 0, 39, 0, 0)])]
        for payload in bad:
            with self.subTest(payload=payload[:24]):
                with self.assertRaises(ValueError):
                    self.read(payload)

    def test_actual_bin_independent_interval_audit(self):
        path = ROOT.parent / 'GW_PROBLEM_TOW/sd_card/PIANO.BIN'
        data = path.read_bytes()
        events, info = read_p88s(path)
        report = json.loads((ROOT / 'score_report.json').read_text())
        self.assertEqual(report['sha256'], hashlib.sha256(data).hexdigest())
        self.assertEqual(info['note_count'], 1860)
        self.assertEqual(info['duration_ms'], 202706)
        # Reconstruct each voice's intervals independently from the raw bytes.
        starts, raw = {}, []
        for time, voice, pitch, velocity, padding in struct.iter_unpack('<IBBBB', data[16:]):
            if voice == 255:
                continue
            if velocity:
                starts[voice] = (time, pitch, velocity)
            else:
                begin, expected_pitch, dynamics = starts.pop(voice)
                self.assertEqual(pitch, expected_pitch)
                raw.append((begin, time, pitch, dynamics, voice))
        exported = [(n['start_ms'], n['end_ms'], n['note'], n['velocity'], n['voice'])
                    for n in report['notes']]
        self.assertEqual(sorted(raw), sorted(exported))
        generated = json.loads((ROOT / 'sim/waterfall_reference.json').read_text())
        # Separate float/rational conversion check; do not reuse frame_at_ms.
        expected = sorted((int(a * 0.06 + 0.5),
                           max(1, int(b * 0.06 + 0.5) - int(a * 0.06 + 0.5)), n)
                          for a, b, n, _, _ in raw)
        self.assertEqual(expected, events)
        self.assertEqual(expected, [tuple(e) for e in generated['events']])
        self.assertLessEqual(info['max_quantization_error_ms'], 1000/60)


if __name__ == '__main__':
    unittest.main()
