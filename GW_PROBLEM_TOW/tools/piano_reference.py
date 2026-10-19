"""Independent fixed-point note model for verification, never an FPGA input."""
from pathlib import Path
import math
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
FS = 48000
BASE_WEIGHTS = [420, 220, 140, 90, 60, 42, 30, 22]
SINE = np.array(
    [round(30000 * math.sin(2 * math.pi * i / 256)) for i in range(256)],
    dtype=np.int64,
)


def parameters(note, enhanced=True):
    word = round(27.5 * 2 ** (note / 12) * 2**32 / FS)
    if not enhanced:
        return word, BASE_WEIGHTS, 256, 256, 0
    packed = int((ROOT / "src/rom/voicing88.hex").read_text().splitlines()[note], 16)
    weights = [(packed >> (11 * i)) & 2047 for i in range(8)]
    gain = (packed >> 88) & 2047
    decay_scale = (packed >> 99) & 511
    stiffness = packed >> 108
    return word, weights, gain, decay_scale, stiffness


def render_note(note, hold_frames, release_frames=18000, enhanced=True,
                hammer_transient=True):
    """Gate at frame 0; note-off at hold_frames, exactly as in the RTL bench."""
    count = hold_frames + release_frames
    word, weights, gain, decay_scale, stiffness = parameters(note, enhanced)
    level = 0
    state = 0
    release_step = 0
    tone = 65535
    levels = np.zeros(count, dtype=np.int64)
    tones = np.zeros(count, dtype=np.int64)
    strikes = np.zeros(count, dtype=np.int64)
    strike = 65535 if hammer_transient else 0
    decay_step = max(1, 711 * decay_scale >> 8)
    for frame in range(count):
        if frame == 0:
            level, state = 69906, 1
        elif frame == hold_frames:
            state = 4
            release_step = max(1, (level + 16383) >> 14)
        elif state == 1:
            level = min(0xFFFFFF, level + 69906)
            if level == 0xFFFFFF:
                state = 2
        elif state == 2:
            level = max(3145728, level - decay_step)
            if level == 3145728:
                state = 3
        elif state == 4:
            level = max(0, level - release_step)
            if level == 0:
                state = 0
        levels[frame] = level
        tones[frame] = tone
        strikes[frame] = strike
        tone = max(0, tone - max(1, tone >> 12))
        strike = max(0, strike - 128)

    total = np.zeros(count, dtype=np.int64)
    frames = np.arange(count, dtype=np.int64)
    for harmonic, coefficient in enumerate(weights, 1):
        step = harmonic * word + (harmonic**3 - harmonic) * stiffness
        phase = (frames * step) & 0xFFFFFFFF
        address = phase >> 24
        fraction = (phase >> 16) & 255
        samples = SINE[address] + (
            (SINE[(address + 1) & 255] - SINE[address]) * fraction >> 8
        )
        if harmonic == 1:
            brightness = 256
        elif enhanced and note < 36:
            brightness = (
                192 + (tones >> 10)
                if harmonic <= 3
                else 64 + (tones >> 9) + (tones >> 10)
            )
        else:
            brightness = 128 + (levels >> 17)
        if hammer_transient and harmonic >= 4:
            brightness = brightness + (strikes >> 9)
        if step >= 0x80000000:
            alias_gain = 0
        elif step <= 0x70000000:
            alias_gain = 256
        else:
            alias_gain = (0x80000000 - step) >> 20
        weight = ((coefficient * brightness >> 8) * alias_gain) >> 8
        total += samples * weight
    enveloped = ((total >> 10) * (levels >> 8)) >> 16
    voice = (enveloped * 192 * gain) >> 16
    pcm = np.where(voice >= 0, (voice + 2) >> 2, -((-voice + 2) >> 2))
    assert np.max(np.abs(pcm)) <= 30000, "Single note unexpectedly needs limiting"
    return pcm, levels


def spectral_level(segment, frequency):
    x = np.asarray(segment, dtype=float)
    window = np.hanning(len(x))
    time = np.arange(len(x)) / FS
    return 2 * abs(np.sum(x * window * np.exp(-2j * np.pi * frequency * time))) / np.sum(window)
