"""Generate 45 hand-voiced harmonic profiles; no recordings or sample PCM."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
# MIDI anchors: low/chalumeau, throat/transition, clarion, altissimo.
# Q1.15 weights, fundamental first. Odd partials dominate the low register;
# even partials and the fundamental become stronger in the upper registers.
ANCHORS = [
    (50, [19000, 800, 8500, 600, 2200, 300, 1100, 268]),
    (67, [20500, 1400, 6800, 900, 1800, 500, 600, 268]),
    (79, [22000, 2000, 5000, 1400, 1100, 600, 400, 268]),
    (94, [24500, 2400, 3000, 1200, 800, 400, 300, 168]),
]


def profiles():
    for note in range(50, 95):
        for (lo, left), (hi, right) in zip(ANCHORS, ANCHORS[1:]):
            if lo <= note <= hi:
                t = (note - lo) / (hi - lo)
                values = [round(a + (b-a)*t) for a, b in zip(left, right)]
                values[0] += 32768 - sum(values)
                yield sum(value << (16*i) for i, value in enumerate(values))
                break


if __name__ == '__main__':
    path = ROOT/'src/rom/clarinet45.hex'
    path.write_text(''.join(f'{row:032x}\n' for row in profiles()), encoding='ascii')
    print('Generated 45 clarinet harmonic parameter rows (D3..Bb6)')
