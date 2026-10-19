"""Validate RTL-generated audio; the WAV is never an input to the FPGA."""
from pathlib import Path
import json
import math
import wave
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
data = np.loadtxt(ROOT / "sim/demo_pcm.txt", dtype=np.int64)
audio = data[:, 1]
fs = 48000
weights = [420, 220, 140, 90, 60, 42, 30, 22]
table = [round(30000 * math.sin(2 * math.pi * i / 256)) for i in range(256)]
phase = 0
level = 0
state = 1
model = []
for frame in range(24000):
    if state == 1:
        level = min(0xffffff, level + 69906)
        if level == 0xffffff:
            state = 2
    elif state == 2:
        level = max(3145728, level - 711)
        if level == 3145728:
            state = 3
    total = 0
    for harmonic, weight in enumerate(weights, 1):
        p = phase * harmonic & 0xffffffff
        address = p >> 24
        frac = p >> 16 & 255
        s = table[address] + ((table[(address + 1) & 255] - table[address]) * frac >> 8)
        brightness = 256 if harmonic == 1 else 128 + (level >> 17)
        total += s * (weight * brightness >> 8)
    voice = ((((total >> 10) * (level >> 8)) >> 16) * 192) >> 8
    model.append((voice + 2) >> 2 if voice >= 0 else -((-voice + 2) >> 2))
    phase = phase + 39370534 & 0xffffffff
reference_error = int(np.max(np.abs(audio[:24000] - model)))
assert reference_error == 0, f"RTL/reference mismatch: {reference_error}"

def spectral_level(segment, frequency):
    x = np.asarray(segment, dtype=float)
    w = np.hanning(len(x))
    t = np.arange(len(x)) / fs
    return 2 * abs(np.sum(x * w * np.exp(-2j * np.pi * frequency * t))) / np.sum(w)

a4 = audio[2000:22000]
a4_amplitude = spectral_level(a4, 440)
assert a4_amplitude > 50
for h in range(2, 9):
    assert spectral_level(a4, 440 * h) > 2, f"Missing harmonic {h}"
chord = audio[44000:64000]
chord_frequencies = [440, 440 * 2 ** (4 / 12), 440 * 2 ** (7 / 12)]
chord_levels = [spectral_level(chord, f) for f in chord_frequencies]
assert min(chord_levels) > 50, f"Missing chord tone: {chord_levels}"
c8 = audio[86000:94000]
c8_frequency = 27.5 * 2 ** (87 / 12)
c8_amplitude = spectral_level(c8, c8_frequency)
alias_levels = [
    20 * math.log10(max(spectral_level(c8, abs(fs - h * c8_frequency)), 1e-9)
                    / max(c8_amplitude, 1e-9))
    for h in (6, 7, 8)
]
assert max(alias_levels) < -42, f"Aliased high harmonics: {alias_levels}"
assert np.max(np.abs(audio)) <= 30001
assert np.max(data[:, 3]) == 88
assert np.all(audio[-5:] == 0)
assert np.count_nonzero(data[:, 4]) > 0, "Limiter was not exercised"
stereo = np.column_stack((audio, audio)).astype("<i2")
with wave.open(str(ROOT / "sim/realtime_synth_demo.wav"), "wb") as out:
    out.setnchannels(2)
    out.setsampwidth(2)
    out.setframerate(fs)
    out.writeframes(stereo.tobytes())
report = {
    "sample_rate": fs, "frames": len(audio),
    "peak_pcm": int(np.max(np.abs(audio))),
    "max_active_voices": int(np.max(data[:, 3])),
    "limiter_frames": int(np.count_nonzero(data[:, 4])),
    "a4_bit_exact_reference_error": reference_error,
    "a4_harmonic_amplitudes": [round(spectral_level(a4, 440*h), 2) for h in range(1, 9)],
    "chord_tone_amplitudes": [round(v, 2) for v in chord_levels],
    "c8_folded_harmonics_db": [round(v, 2) for v in alias_levels],
    "source": "ModelSim RTL output; not FPGA input data",
}
(ROOT / "sim/audio_report.json").write_text(json.dumps(report, indent=2), encoding="ascii")
print(json.dumps(report, indent=2))
