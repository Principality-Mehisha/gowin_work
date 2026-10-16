"""Convert a PCM16 WAV to the SD player's fixed, documented audio format."""
from __future__ import annotations

import argparse
import hashlib
import json
import wave
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
RATE = 16276


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", type=Path,
                        default=ROOT / "output/croatian_rhapsody_full.wav")
    parser.add_argument("--output", type=Path, default=ROOT / "sd_card/music/MUSIC.WAV")
    args = parser.parse_args()
    with wave.open(str(args.input), "rb") as source:
        if source.getsampwidth() != 2 or source.getcomptype() != "NONE":
            raise ValueError("Input must be an uncompressed PCM16 WAV")
        source_rate = source.getframerate()
        audio = np.frombuffer(source.readframes(source.getnframes()), "<i2")
        audio = audio.astype(np.float64).reshape(-1, source.getnchannels()).mean(axis=1)
    if not len(audio):
        raise ValueError("Input contains no audio")
    if source_rate != RATE:
        # Bandlimit before downsampling; WAV decode and channel conversion are offline.
        if source_rate > RATE:
            frequency = np.fft.rfftfreq(len(audio), 1 / source_rate)
            taper = np.clip((RATE * 0.49 - frequency) / (RATE * 0.04), 0, 1)
            audio = np.fft.irfft(np.fft.rfft(audio) * taper, n=len(audio))
        positions = np.arange(round(len(audio) * RATE / source_rate)) * source_rate / RATE
        audio = np.interp(positions, np.arange(len(audio)), audio)
    fade = min(round(0.005 * RATE), len(audio) // 2)
    if fade:
        audio[:fade] *= np.linspace(0, 1, fade)
        audio[-fade:] *= np.linspace(1, 0, fade)
    peak = np.max(np.abs(audio))
    if peak > 30000:
        audio *= 30000 / peak
    pcm = np.rint(audio).astype("<i2")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(args.output), "wb") as target:
        target.setnchannels(1)
        target.setsampwidth(2)
        target.setframerate(RATE)
        target.writeframes(pcm.tobytes())
    report = {
        "source": str(args.input.resolve()),
        "file": str(args.output.resolve()),
        "format": "RIFF/WAVE PCM16 little endian mono",
        "sample_rate_hz": RATE,
        "frames": len(pcm),
        "duration_seconds": len(pcm) / RATE,
        "bytes": args.output.stat().st_size,
        "peak": int(np.abs(pcm.astype(np.int32)).max()),
        "sha256": hashlib.sha256(args.output.read_bytes()).hexdigest(),
    }
    args.output.with_suffix(".json").write_text(json.dumps(report, indent=2), encoding="utf8")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
