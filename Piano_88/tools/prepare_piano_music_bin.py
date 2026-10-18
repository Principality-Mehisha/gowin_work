"""Convert the complete rendered piano WAV into headerless FPGA PCM and fixtures."""
import hashlib
import json
import struct
import wave
from pathlib import Path

from generate_sd_music_fixtures import build, save_hex, save_full_fat32

ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT / "sd_card/piano_music"
TEST = ROOT / "output/piano_music_test"


def main():
    DEST.mkdir(parents=True, exist_ok=True)
    TEST.mkdir(parents=True, exist_ok=True)
    source = ROOT / "sd_card/music/MUSIC.WAV"
    with wave.open(str(source)) as wav:
        assert (wav.getnchannels(), wav.getsampwidth(), wav.getframerate()) == (1, 2, 16276)
        frames = wav.getnframes()
        pcm = wav.readframes(frames)
    assert len(pcm) == frames * 2
    target = DEST / "PIANO.BIN"
    target.write_bytes(pcm)
    report = {
        "title": "Croatian Rhapsody - Aemisiya piano MIDI arrangement",
        "source_page": "https://musicalnexus.net/games/ms2/songs/maksim-mrvica-croatian-rhapsody-r1430",
        "format": "headerless signed PCM16 little-endian mono",
        "sample_rate_hz": 16276, "hardware_sample_rate_hz": 50_000_000 / 3072,
        "frames": frames, "bytes": len(pcm), "duration_seconds": frames / 16276,
        "sha256": hashlib.sha256(pcm).hexdigest(),
    }
    (DEST / "PIANO.json").write_text(json.dumps(report, indent=2) + "\n", encoding="ascii")
    # Include signed extremes, sector boundaries and a final partial sector.
    samples = [-32768, 32767, -1, 1] + [((i * 97) % 20000) - 10000 for i in range(1021)]
    short = struct.pack(f"<{len(samples)}h", *samples)
    for fat32 in (False, True):
        save_hex(TEST / ("fat32.hex" if fat32 else "fat16.hex"),
                 build(fat32, short, filename=b"PIANO   BIN"))
    for name, options in (("missing", {"missing": True}), ("broken", {"broken": True})):
        save_hex(TEST / f"{name}.hex", build(False, short, filename=b"PIANO   BIN", **options))
    (TEST / "expected.hex").write_text(
        "\n".join(f"{s & 65535:04X}" for s in samples) + "\n", encoding="ascii")
    save_full_fat32(pcm, output=TEST / "full_fat32.img", filename=b"PIANO   BIN")
    # Four test FIFOs of audio at the proven hardware SPI divider.
    slow = struct.pack("<4097h", *[1 + i % 30000 for i in range(4097)])
    save_full_fat32(slow, output=TEST / "throughput.img", filename=b"PIANO   BIN")
    image = (TEST / "throughput.img").read_bytes()
    sectors = {i // 512: bytearray(image[i:i + 512])
               for i in range(0, len(image), 512) if any(image[i:i + 512])}
    save_hex(TEST / "throughput.hex", sectors)
    (TEST / "params.vh").write_text(
        f"`define PIANO_BYTES {len(pcm)}\n`define PIANO_FRAMES {frames}\n", encoding="ascii")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
