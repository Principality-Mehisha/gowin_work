"""Render the complete downloaded piano MIDI with the project's recorded piano samples."""
from __future__ import annotations

import argparse
import collections
import hashlib
import json
import sys
import wave
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(Path(__file__).resolve().parent / "vendor"))
import mido

RATE = 16276
SOURCE_URL = "https://musicalnexus.net/games/ms2/songs/maksim-mrvica-croatian-rhapsody-r1430"
DOWNLOAD_URL = "https://musicalnexus.net/songs/1430/download/midi"


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


def load_zones() -> dict[int, np.ndarray]:
    zones = {}
    for path in sorted((ROOT / "assets/piano").glob("*.wav")):
        name = path.stem
        pitch = 12 * (int(name[-1]) + 1) + (6 if name.startswith("Fs") else 0)
        with wave.open(str(path)) as source:
            audio = np.frombuffer(source.readframes(source.getnframes()), "<i2")
            audio = audio.reshape(-1, source.getnchannels()).mean(axis=1) / 32768
            source_rate = source.getframerate()
        audio -= audio.mean()
        audible = np.flatnonzero(np.abs(audio) > np.max(np.abs(audio)) * 0.005)
        onset = max(0, int(audible[0]) - round(source_rate * 0.002))
        audio = audio[onset:]
        zones[pitch] = (audio, source_rate)
    result = {}
    for pitch in range(21, 109):
        root = min(zones, key=lambda value: abs(pitch - value))
        audio, source_rate = zones[root]
        step = source_rate / RATE * 2 ** ((pitch - root) / 12)
        spectrum = np.fft.rfft(audio)
        frequencies = np.fft.rfftfreq(len(audio), 1 / source_rate)
        cutoff = RATE * 0.47 / 2 ** ((pitch - root) / 12)
        spectrum *= np.clip((cutoff - frequencies) / (cutoff * 0.08), 0, 1)
        filtered = np.fft.irfft(spectrum, n=len(audio))
        positions = np.arange(int((len(audio) - 1) / step)) * step
        samples = np.interp(positions, np.arange(len(audio)), filtered)
        samples /= max(float(np.max(np.abs(samples))), 1e-9)
        samples[:48] *= np.linspace(0, 1, min(48, len(samples)))
        result[pitch] = samples
    return result


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--midi", type=Path, default=ROOT /
                        "sd_card/music/source/croatian_rhapsody_aemisiya.mid")
    parser.add_argument("--output", type=Path, default=ROOT / "output/croatian_rhapsody_full.wav")
    args = parser.parse_args()
    notes, midi_seconds = read_notes(args.midi)
    zones = load_zones()
    total_seconds = max(midi_seconds, max(note["end"] for note in notes)) + 2.0
    mix = np.zeros(round(total_seconds * RATE), dtype=np.float64)
    release = round(0.32 * RATE)
    for note in notes:
        if note["pitch"] not in zones:
            raise ValueError("Note outside the available 88-key piano")
        sample = zones[note["pitch"]]
        start = round(note["start"] * RATE)
        gate = round((note["end"] - note["start"]) * RATE)
        length = min(len(sample), gate + release, len(mix) - start)
        voice = sample[:length].copy()
        if gate < length:
            voice[gate:] *= np.linspace(1, 0, length - gate) ** 2
        else:
            width = min(256, length)
            voice[-width:] *= np.linspace(1, 0, width) ** 2
        mix[start:start + length] += note["gain"] * voice
    # Quiet, finite room reflections preserve a natural decay without loops.
    dry = mix.copy()
    for delay, gain in ((0.061, .07), (.103, .055), (.173, .04),
                        (.277, .03), (.419, .02), (.613, .012)):
        offset = round(delay * RATE)
        mix[offset:] += dry[:-offset] * gain
    mix -= mix.mean()
    fade = round(.015 * RATE)
    mix[:fade] *= np.linspace(0, 1, fade)
    mix[-fade:] *= np.linspace(1, 0, fade)
    mix *= 27000 / max(float(np.max(np.abs(mix))), 1e-9)
    pcm = np.rint(mix).astype("<i2")
    args.output.parent.mkdir(exist_ok=True, parents=True)
    with wave.open(str(args.output), "wb") as output:
        output.setnchannels(1)
        output.setsampwidth(2)
        output.setframerate(RATE)
        output.writeframes(pcm.tobytes())
    report = {
        "title": "Croatian Rhapsody - complete piano MIDI arrangement",
        "arranger": "Aemisiya", "source_page": SOURCE_URL, "midi_download": DOWNLOAD_URL,
        "midi_sha256": hashlib.sha256(args.midi.read_bytes()).hexdigest(),
        "render": "Recorded VSCO2/tonejs piano samples, offline pitch conversion and mixing",
        "notes": len(notes), "midi_seconds": midi_seconds,
        "duration_seconds": len(pcm) / RATE, "sample_rate": RATE, "frames": len(pcm),
        "peak": int(np.abs(pcm.astype(np.int32)).max()),
        "clipped_samples": int(np.count_nonzero(np.abs(pcm.astype(np.int32)) >= 32767)),
        "sha256": hashlib.sha256(args.output.read_bytes()).hexdigest(),
    }
    args.output.with_suffix(".json").write_text(json.dumps(report, indent=2), encoding="ascii")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
