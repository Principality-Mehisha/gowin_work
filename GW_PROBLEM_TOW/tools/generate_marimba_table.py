"""Generate fixed modal parameters for the 24-note synthetic marimba."""
from pathlib import Path
import math

ROOT = Path(__file__).resolve().parents[1]
ROM = ROOT / "src" / "rom"
ROM.mkdir(exist_ok=True)

SAMPLE_RATE = 50_000_000 / 3072
NOTE_FIRST = 24
NOTE_COUNT = 24
MODE_RATIOS = (1.0, 3.99, 10.65, None)
MODE_GAINS = (0.68, 0.17, 0.12, 0.08)
MODE_DECAYS = (0.9996, 0.9994, 0.9994, 0.9990)
FIXED_MODE_HZ = 2443.0

rows = []
highest_mode = 0.0
for offset in range(NOTE_COUNT):
    note_index = NOTE_FIRST + offset
    midi_note = 21 + note_index
    fundamental = 440.0 * 2 ** ((midi_note - 69) / 12)
    frequencies = [
        fundamental * ratio if ratio is not None else FIXED_MODE_HZ
        for ratio in MODE_RATIOS
    ]
    highest_mode = max(highest_mode, *frequencies)
    if max(frequencies) >= SAMPLE_RATE / 2:
        raise ValueError(f"Note index {note_index} has a mode above Nyquist")

    packed_modes = []
    for frequency, gain, decay in zip(frequencies, MODE_GAINS, MODE_DECAYS):
        phase_step = round(frequency * 2**32 / SAMPLE_RATE)
        gain_q15 = round(gain * 32768)
        decay_q15 = min(32767, round(decay * 32768))
        packed_modes.append((phase_step << 32) | (gain_q15 << 16) | decay_q15)

    row = 0
    for mode in reversed(packed_modes):
        row = (row << 64) | mode
    rows.append(f"{row:064x}\n")

(ROM / "marimba24.hex").write_text("".join(rows), encoding="ascii")
print(
    f"Generated {NOTE_COUNT} x 4 modal table at {SAMPLE_RATE:.6f} Hz; "
    f"highest mode {highest_mode:.2f} Hz"
)
