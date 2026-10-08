"""Generate the Croatian Rhapsody PCM image.

The default path renders the checked-in score with a deterministic acoustic
piano model.  The rendered audio is stored as 8-bit mu-law bytes in the
external .hex file; the FPGA only performs ROM reads, mu-law expansion, and
PT8211 serialization.  An optional recording path is kept for diagnostics,
but it requires PyAV and is not needed for the normal build.
"""
from __future__ import annotations

import argparse
import json
import math
import wave
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
FS = 50_000_000 / 3072
MAX_SAMPLES = 262144


def decode_audio(path: Path) -> np.ndarray:
    import sys

    sys.path.insert(0, str(ROOT / "tools" / "pydeps"))
    import av

    with av.open(str(path)) as container:
        resampler = av.AudioResampler(format="fltp", layout="mono", rate=round(FS))
        chunks = []
        for frame in container.decode(audio=0):
            chunks.extend(f.to_ndarray().reshape(-1) for f in resampler.resample(frame))
        chunks.extend(f.to_ndarray().reshape(-1) for f in resampler.resample(None))
    return np.concatenate(chunks).astype(np.float64)


def ulaw_encode(value: int) -> int:
    sign = 0x80 if value < 0 else 0
    magnitude = min(abs(value), 32635) + 132
    exponent = max(0, magnitude.bit_length() - 8)
    mantissa = (magnitude >> (exponent + 3)) & 15
    return (~(sign | (exponent << 4) | mantissa)) & 255


def ulaw_decode(code: int) -> int:
    value = (~code) & 255
    magnitude = (((value & 15) << 3) + 132) << ((value >> 4) & 7)
    magnitude -= 132
    return -magnitude if value & 128 else magnitude


def render_score() -> np.ndarray:
    score = json.loads((ROOT / "assets" / "score.json").read_text(encoding="utf8"))
    duration = score["duration_seconds"]
    total = math.ceil(duration * FS)
    mix = np.zeros(total, dtype=np.float64)
    rng = np.random.default_rng(20261009)
    # A compact piano model: slightly inharmonic partials, a fast hammer
    # transient, and a long natural decay.  This is rendered offline, so the
    # FPGA never needs a multiplier or a waveform oscillator.
    partials = np.array([1.00, 0.54, 0.27, 0.15, 0.09, 0.055, 0.032, 0.018])
    partials /= partials.sum()
    for event in score["events"]:
        start = round(event["start_seconds"] * FS)
        gate = round(event["duration_seconds"] * FS)
        release_frames = round(0.15 * FS)
        length = min(gate + release_frames, total - start)
        if length > 0:
            t = np.arange(length, dtype=np.float64) / FS
            frequency = 440.0 * 2.0 ** ((event["midi"] - 69) / 12.0)
            # Higher notes decay faster; long bass notes retain their body.
            decay = 1.15 + 0.012 * max(0, event["midi"] - 48)
            envelope = (1.0 - np.exp(-t / 0.0028)) * np.exp(-t / decay)
            if gate < length:
                envelope[gate:] *= np.linspace(1.0, 0.0, length - gate)
            voice = np.zeros(length, dtype=np.float64)
            for index, amplitude in enumerate(partials, start=1):
                inharmonic = 1.0 + 0.00065 * index * index
                voice += amplitude * np.sin(
                    2.0 * np.pi * frequency * index * inharmonic * t
                    + 0.015 * np.sin(2.0 * np.pi * 3.0 * t)
                )
            # Hammer noise is intentionally short and quiet.
            noise_len = min(length, round(0.018 * FS))
            if noise_len:
                noise_t = np.arange(noise_len, dtype=np.float64) / FS
                hammer = rng.standard_normal(noise_len) * np.exp(-noise_t / 0.004)
                voice[:noise_len] += 0.025 * hammer
            mix[start:start + length] += event["gain"] * voice * envelope
    return mix


def save_preview(path: Path, pcm: np.ndarray) -> None:
    with wave.open(str(path), "wb") as output:
        output.setnchannels(1)
        output.setsampwidth(2)
        output.setframerate(round(FS))
        output.writeframes(pcm.astype("<i2").tobytes())


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--audio", type=Path, help="Optional source recording.")
    parser.add_argument("--seconds", type=float, help="Limit external recording.")
    args = parser.parse_args()
    samples = decode_audio(args.audio) if args.audio else render_score()
    if args.seconds:
        samples = samples[:round(args.seconds * FS)]
    if not 1 <= len(samples) <= MAX_SAMPLES:
        raise ValueError(f"{len(samples)} samples exceed ROM capacity {MAX_SAMPLES}")
    samples = samples - samples.mean()
    fade = min(round(FS * 0.01), len(samples) // 2)
    samples[:fade] *= np.linspace(0, 1, fade)
    samples[-fade:] *= np.linspace(1, 0, fade)
    peak = max(float(np.max(np.abs(samples))), 1e-12)
    pcm = np.rint(samples / peak * 0.60 * 32767).astype(np.int16)
    codes = [ulaw_encode(int(value)) for value in pcm]
    depth = 1 << (len(codes) - 1).bit_length()
    hex_path = ROOT / "src" / "croatian_rhapsody.hex"
    hex_path.write_text(
        "\n".join(f"{value:02X}" for value in codes + [0xFF] * (depth - len(codes))) + "\n",
        encoding="ascii",
    )
    (ROOT / "src" / "rom_params.vh").write_text(
        "`define PCM_ADDR_BITS %d\n`define PCM_ROM_DEPTH %d\n`define PCM_SAMPLE_COUNT %d\n"
        % (int(math.log2(depth)), depth, len(codes)),
        encoding="ascii",
    )
    out = ROOT / "output"
    out.mkdir(exist_ok=True)
    decoded = np.array([ulaw_decode(value) for value in codes], dtype=np.int16)
    save_preview(out / "piano_preview.wav", decoded)
    report = {
        "sample_rate_hz": FS,
        "samples": len(codes),
        "seconds": len(codes) / FS,
        "rom_depth_bytes": depth,
        "source": str(args.audio) if args.audio else "assets/score.json",
        "voice": "imported audio" if args.audio else "offline additive acoustic piano model",
        "pcm_peak": int(np.max(np.abs(decoded.astype(np.int32)))),
        "clipped_samples": int(np.count_nonzero(np.abs(decoded.astype(np.int32)) >= 32767)),
        "dc_mean": float(decoded.mean()),
    }
    (out / "audio_report.json").write_text(json.dumps(report, indent=2), encoding="ascii")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
