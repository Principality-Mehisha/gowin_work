"""Independent integer audio model used for marimba calibration and RTL checks."""
from __future__ import annotations

import numpy as np

OUT_FS = 50_000_000 / 3072


def decode_modes(row: int) -> list[tuple[int, int, int]]:
    return [((row >> (i * 64 + 32)) & 0xffffffff,
             (row >> (i * 64 + 16)) & 65535,
             (row >> (i * 64)) & 65535) for i in range(4)]


def render_note(modes, attack, sine, note_index, frames=16276, dynamics=192):
    phase = [0] * 4
    level = [mode[1] for mode in modes]
    noise_level, noise_step = attack >> 16, attack & 65535
    lfsr = (0x1ace + note_index) & 65535
    bright = (dynamics >> 4) ** 2
    r1_y1 = r1_y2 = r2_y1 = r2_y2 = 0
    pcm = np.empty(frames, dtype=np.int32)
    peak = 0
    for frame in range(frames):
        mixed = 0
        for i, (step, _, decay) in enumerate(modes):
            if level[i] == 0:
                continue
            address = phase[i] >> 24
            fraction = (phase[i] >> 16) & 255
            value = sine[address] + (
                (sine[(address + 1) & 255] - sine[address]) * fraction >> 8)
            amplitude = value * (level[i] & 32767) >> 15
            mixed += amplitude * (dynamics if i == 0 else bright) >> 8
            level[i] = level[i] * (decay & 32767) >> 15
            phase[i] = (phase[i] + step) & 0xffffffff
        if noise_level:
            mixed += (((lfsr & 255) - 128) *
                      (noise_level & 32767) >> 7) * bright >> 8
            noise_level = max(0, noise_level - noise_step)
            feedback = ((lfsr >> 15) ^ (lfsr >> 13) ^
                        (lfsr >> 12) ^ (lfsr >> 10)) & 1
            lfsr = ((lfsr << 1) | feedback) & 65535
            if lfsr == 0:
                lfsr = 0x1ace
        r1 = (mixed >> 4) + (r1_y1 * 30138 >> 14) - (r1_y2 * 14171 >> 14)
        r2 = (mixed >> 5) + (r2_y1 * 27708 >> 14) - (r2_y2 * 12688 >> 14)
        r1_y2, r1_y1 = r1_y1, r1
        r2_y2, r2_y1 = r2_y1, r2
        body = mixed + (r1 >> 2) + (r2 >> 3)
        sample = (body + (1 if body < 0 else 2)) >> 2
        peak = max(abs(sample), max(0, peak - max(1, peak >> 12)))
        gain = (30000 << 20) // peak if peak > 30000 else 1 << 20
        product = sample * gain
        pcm[frame] = (product + (524287 if product < 0 else 524288)) >> 20
    return pcm
