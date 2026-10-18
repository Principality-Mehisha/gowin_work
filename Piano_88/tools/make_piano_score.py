"""Compile the downloaded piano MIDI into timestamped P88S note events."""
from __future__ import annotations

import argparse
import hashlib
import heapq
import json
import struct
from pathlib import Path

from render_full_piano import read_notes
from generate_sd_music_fixtures import build, save_hex, save_full_fat32

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "sd_card/score"
TEST = ROOT / "output/score_test"
VOICES = 8


def pack_score(events):
    header = struct.pack("<4sBBBBII", b"P88S", 1, 8, VOICES, 0, 1000, len(events))
    return header + b"".join(struct.pack("<IBBBB", *event) for event in events)


def compile_notes(notes, duration):
    actions = []
    for identity, note in enumerate(notes):
        start = round(note["start"] * 1000)
        end = max(start + 1, round(note["end"] * 1000))
        actions.extend([(start, 1, identity), (end, 0, identity)])
    free = list(range(VOICES))
    heapq.heapify(free)
    active = {}
    released = []
    events = []
    peak = 0
    for timestamp, on, identity in sorted(actions):
        while released and released[0][0] <= timestamp:
            _, slot = heapq.heappop(released)
            heapq.heappush(free, slot)
        note = notes[identity]
        index = note["pitch"] - 21
        if not 0 <= index < 88:
            raise ValueError("Score contains a note outside A0..C8")
        if on:
            if not free:
                # Reuse a released voice before considering any active voice.
                if not released:
                    raise ValueError("Arrangement exceeds eight simultaneous notes")
                _, slot = heapq.heappop(released)
            else:
                slot = heapq.heappop(free)
            active[identity] = slot
            velocity = max(1, min(127, round(note["gain"] * 127)))
            peak = max(peak, len(active))
        else:
            slot = active.pop(identity)
            velocity = 0
            heapq.heappush(released, (timestamp + 10, slot))
        events.append((timestamp, slot, index, velocity, 0))
    end = max(round(duration * 1000), events[-1][0]) + 1500
    events.append((end, 255, 255, 0, 0))
    return events, peak


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--midi", type=Path, default=ROOT /
                        "sd_card/music/source/croatian_rhapsody_aemisiya.mid")
    args = parser.parse_args()
    notes, duration = read_notes(args.midi)
    events, peak = compile_notes(notes, duration)
    data = pack_score(events)
    OUT.mkdir(parents=True, exist_ok=True)
    TEST.mkdir(parents=True, exist_ok=True)
    (OUT / "PIANO.BIN").write_bytes(data)
    report = {
        "title": "Croatian Rhapsody - Aemisiya piano MIDI arrangement",
        "format": "P88S v1, timestamped note on/off and velocity; no audio samples",
        "source_page": "https://musicalnexus.net/games/ms2/songs/maksim-mrvica-croatian-rhapsody-r1430",
        "midi_sha256": hashlib.sha256(args.midi.read_bytes()).hexdigest(),
        "notes": len(notes), "events": len(events), "voices": VOICES,
        "peak_polyphony": peak, "duration_ms": events[-1][0],
        "bytes": len(data), "sha256": hashlib.sha256(data).hexdigest(),
    }
    (OUT / "PIANO.json").write_text(json.dumps(report, indent=2) + "\n", encoding="ascii")
    (TEST / "events.hex").write_text(
        "\n".join(struct.pack("<IBBBB", *event)[::-1].hex() for event in events) + "\n",
        encoding="ascii")
    save_full_fat32(data, output=TEST / "full.img", filename=b"PIANO   BIN")
    # Coincident chord, repeated pitch, signed end marker, and a partial sector.
    short_events = [
        (0, 0, 39, 127, 0), (0, 1, 43, 100, 0), (0, 2, 46, 80, 0),
        (35, 0, 39, 0, 0), (35, 1, 43, 0, 0), (35, 2, 46, 0, 0),
        (50, 0, 39, 110, 0), (80, 0, 39, 0, 0), (100, 255, 255, 0, 0),
    ]
    short = pack_score(short_events)
    (TEST / "short.bin").write_bytes(short)
    for fat32 in (False, True):
        save_hex(TEST / ("fat32.hex" if fat32 else "fat16.hex"),
                 build(fat32, short, filename=b"PIANO   BIN"))
    save_hex(TEST / "missing.hex", build(False, short, filename=b"PIANO   BIN", missing=True))
    bad = b"RIFF" + short[4:]
    save_hex(TEST / "wrong_format.hex", build(False, bad, filename=b"PIANO   BIN"))
    (TEST / "params.vh").write_text(
        f"`define SCORE_EVENTS {len(events)}\n`define SCORE_BYTES {len(data)}\n",
        encoding="ascii")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
