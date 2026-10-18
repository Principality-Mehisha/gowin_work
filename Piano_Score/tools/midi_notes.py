"""Read timed piano notes, channel expression, and sustain from a MIDI file."""
from __future__ import annotations

import collections
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "vendor"))
import mido


def read_notes(path: Path) -> tuple[list[dict], float]:
    midi = mido.MidiFile(path)
    active = collections.defaultdict(collections.deque)
    released = collections.defaultdict(list)
    pedal = collections.defaultdict(bool)
    volume = collections.defaultdict(lambda: 100)
    expression = collections.defaultdict(lambda: 127)
    notes = []
    time = 0.0

    def finish(note: dict, end: float) -> None:
        note["end"] = max(end, note["start"] + 0.025)
        notes.append(note)

    for message in midi:
        time += message.time
        channel = getattr(message, "channel", 0)
        if message.type == "program_change" and message.program > 7:
            raise ValueError("The source includes a non-piano instrument")
        if message.type == "note_on" and message.velocity > 0:
            if channel == 9:
                raise ValueError("Unexpected percussion channel")
            active[channel, message.note].append({
                "pitch": message.note, "start": time,
                "gain": (message.velocity / 127) ** 1.25
                        * volume[channel] / 127 * expression[channel] / 127,
            })
        elif message.type == "note_off" or (
            message.type == "note_on" and message.velocity == 0
        ):
            queue = active[channel, message.note]
            if queue:
                note = queue.popleft()
                if pedal[channel]:
                    released[channel].append(note)
                else:
                    finish(note, time)
        elif message.type == "control_change":
            if message.control in (7, 11):
                (volume if message.control == 7 else expression)[channel] = message.value
            elif message.control == 64:
                pedal[channel] = message.value >= 64
                if not pedal[channel]:
                    for note in released.pop(channel, []):
                        finish(note, time)
            elif message.control in (120, 123):
                for key in list(active):
                    if key[0] == channel:
                        for note in active.pop(key):
                            finish(note, time)
                for note in released.pop(channel, []):
                    finish(note, time)
    for queue in active.values():
        for note in queue:
            finish(note, time)
    for queue in released.values():
        for note in queue:
            finish(note, time)
    if len(notes) < 1000 or time < 150:
        raise ValueError("Expected a complete multi-minute piano arrangement")
    return sorted(notes, key=lambda note: note["start"]), time
