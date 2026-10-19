"""Measure RTL-generated audio using only the Python standard library."""
from array import array
from pathlib import Path
import json
import math
import wave

ROOT = Path(__file__).resolve().parents[1]
rows = [
    [int(value) for value in line.split()]
    for line in (ROOT / "sim/demo_pcm.txt").read_text().splitlines()
]
audio = [row[1] for row in rows]
fs = 48000


def spectral_level(segment, frequency):
    count = len(segment)
    window_sum = 0.0
    real = 0.0
    imag = 0.0
    for index, sample in enumerate(segment):
        window = 0.5 - 0.5 * math.cos(2 * math.pi * index / (count - 1))
        angle = 2 * math.pi * frequency * index / fs
        value = sample * window
        real += value * math.cos(angle)
        imag -= value * math.sin(angle)
        window_sum += window
    return 2 * math.hypot(real, imag) / window_sum


a4 = audio[2000:22000]
a4_amplitudes = [spectral_level(a4, 440 * harmonic) for harmonic in range(1, 9)]
assert a4_amplitudes[0] > 50
assert min(a4_amplitudes[1:]) > 2, f"Missing A4 partial: {a4_amplitudes}"

chord = audio[44000:64000]
chord_frequencies = [440, 440 * 2 ** (4 / 12), 440 * 2 ** (7 / 12)]
chord_levels = [spectral_level(chord, frequency) for frequency in chord_frequencies]
assert min(chord_levels) > 50, f"Missing chord tone: {chord_levels}"

c8 = audio[86000:94000]
c8_frequency = 27.5 * 2 ** (87 / 12)
c8_amplitude = spectral_level(c8, c8_frequency)
alias_levels = [
    20 * math.log10(max(spectral_level(c8, abs(fs - harmonic * c8_frequency)), 1e-9)
                    / max(c8_amplitude, 1e-9))
    for harmonic in (6, 7, 8)
]
assert max(alias_levels) < -42, f"Aliased high harmonics: {alias_levels}"

early = audio[2400:7200]
late = audio[12000:16800]
early_ratio = spectral_level(early, 3520) / spectral_level(early, 440)
late_ratio = spectral_level(late, 3520) / spectral_level(late, 440)
assert late_ratio < early_ratio, "8th partial did not decay during the note"

peak_pcm = max(abs(value) for value in audio)
assert peak_pcm <= 30001
assert max(row[3] for row in rows) == 88
assert all(value == 0 for value in audio[-5:])
limiter_frames = sum(bool(row[4]) for row in rows)
assert limiter_frames > 0, "Limiter was not exercised"

stereo = array("h")
for sample in audio:
    stereo.extend((sample, sample))
with wave.open(str(ROOT / "sim/realtime_synth_demo.wav"), "wb") as output:
    output.setnchannels(2)
    output.setsampwidth(2)
    output.setframerate(fs)
    output.writeframes(stereo.tobytes())

report = {
    "sample_rate": fs,
    "frames": len(audio),
    "peak_pcm": peak_pcm,
    "max_active_voices": max(row[3] for row in rows),
    "limiter_frames": limiter_frames,
    "a4_harmonic_amplitudes": [round(value, 2) for value in a4_amplitudes],
    "a4_8th_partial_ratio_early": round(early_ratio, 4),
    "a4_8th_partial_ratio_late": round(late_ratio, 4),
    "chord_tone_amplitudes": [round(value, 2) for value in chord_levels],
    "c8_folded_harmonics_db": [round(value, 2) for value in alias_levels],
    "source": "ModelSim RTL output; not prerecorded RTL inputs",
}
(ROOT / "sim/audio_report.json").write_text(json.dumps(report, indent=2), encoding="ascii")
print(json.dumps(report, indent=2))
