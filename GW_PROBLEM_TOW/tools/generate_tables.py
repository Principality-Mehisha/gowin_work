"""Generate function/parameter ROMs only. Never generate note PCM for the FPGA."""
from pathlib import Path
import math

ROOT = Path(__file__).resolve().parents[1]
ROM = ROOT / "src" / "rom"
ROM.mkdir(exist_ok=True)
sine = [round(30000 * math.sin(2 * math.pi * i / 256)) for i in range(256)]
words = [round(27.5 * 2 ** (i / 12) * 2 ** 32 / 48000) for i in range(88)]
# Hand-voiced parameter anchors, not PCM or extracted recording envelopes.
# Interpolate per semitone to avoid loudness/timbre jumps at octave boundaries.
anchors = [
    (0, [150, 250, 215, 155, 105, 70, 45, 34], 1126),
    (12, [260, 260, 195, 125, 80, 48, 32, 24], 774),
    (24, [340, 245, 175, 105, 65, 42, 28, 24], 480),
    (36, [420, 220, 140, 90, 60, 42, 30, 22], 288),
    (48, [420, 220, 140, 90, 60, 42, 30, 22], 256),
    (87, [420, 220, 140, 90, 60, 42, 30, 22], 256),
]
profiles = []
for note in range(88):
    for (lo, w0, g0), (hi, w1, g1) in zip(anchors, anchors[1:]):
        if lo <= note <= hi:
            t = (note - lo) / (hi - lo)
            weights = [round(a + (b - a) * t) for a, b in zip(w0, w1)]
            weights[0] += 1024 - sum(weights)
            # Equal dB steps keep adjacent-key compensation smooth.
            gain = round(g0 * (g1 / g0) ** t)
            # Q0.8 decay-rate scale: 1/4 at A0, 1 at A3 and above.
            decay_scale = round(64 + min(note, 36) * 192 / 36)
            # Bass stiffness only. Fundamental remains the standard DDS word.
            # delta_h = (h^3-h) * stiffness_step, B approximately 1/32768.
            stiffness_step = round(words[note] * max(0, 36 - note) / (36 * 65536))
            packed = stiffness_step
            packed = (packed << 9) | decay_scale
            packed = (packed << 11) | gain
            for weight in reversed(weights):
                packed = (packed << 11) | weight
            profiles.append(packed)
            break
(ROM / "sine256.hex").write_text(
    "".join(f"{value & 65535:04x}\n" for value in sine), encoding="ascii")
(ROM / "frequency88.hex").write_text(
    "".join(f"{value:08x}\n" for value in words), encoding="ascii")
(ROM / "voicing88.hex").write_text(
    "".join(f"{value:035x}\n" for value in profiles), encoding="ascii")
print(f"Function table: {len(sine)} points; pitch parameters: {len(words)}")
print(f"Voicing parameters: {len(profiles)} x 140 bits (weights/gain/decay/stiffness)")
print(f"A4 DDS word: {words[48]}; Fs=48000")
