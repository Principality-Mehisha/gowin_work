"""Analyze the latest RTL-generated single-note realism render."""
from array import array
from pathlib import Path
import json
import math
import wave

ROOT = Path(__file__).resolve().parents[1]
rows = [
    tuple(int(value) for value in line.split())
    for line in (ROOT / "sim/tone_realism_pcm.txt").read_text().splitlines()
]
audio = [row[1] for row in rows]
fs = 48000


def amplitude(start, end, frequency):
    segment = audio[start:end]
    count = len(segment)
    real = imag = window_sum = 0.0
    for index, sample in enumerate(segment):
        window = 0.5 - 0.5 * math.cos(2 * math.pi * index / (count - 1))
        angle = 2 * math.pi * frequency * index / fs
        value = sample * window
        real += value * math.cos(angle)
        imag -= value * math.sin(angle)
        window_sum += window
    return 2 * math.hypot(real, imag) / window_sum


partials_early = [amplitude(2400, 12000, 440 * h) for h in range(1, 9)]
partials_late = [amplitude(12000, 21600, 440 * h) for h in range(1, 9)]
ratio_early = partials_early[7] / partials_early[0]
ratio_late = partials_late[7] / partials_late[0]
assert len(audio) == 42000
assert ratio_late < ratio_early, "Upper partials did not darken"
assert max(abs(sample) for sample in audio) <= 30001
assert all(sample == 0 for sample in audio[-5:])

stereo = array("h")
for sample in audio:
    stereo.extend((sample, sample))
with wave.open(str(ROOT / "sim/tone_realism.wav"), "wb") as output:
    output.setnchannels(2)
    output.setsampwidth(2)
    output.setframerate(fs)
    output.writeframes(stereo.tobytes())

report = {
    "sample_rate": fs,
    "frames": len(audio),
    "peak_pcm": max(abs(sample) for sample in audio),
    "a4_partial_amplitudes_early": [round(value, 2) for value in partials_early],
    "a4_partial_amplitudes_late": [round(value, 2) for value in partials_late],
    "a4_8th_to_fundamental_ratio_early": round(ratio_early, 5),
    "a4_8th_to_fundamental_ratio_late": round(ratio_late, 5),
    "source": "ModelSim RTL output; not prerecorded RTL inputs",
}
(ROOT / "sim/tone_realism_report.json").write_text(
    json.dumps(report, indent=2), encoding="ascii")
print(json.dumps(report, indent=2))
