"""Generate 3x-rate modal phase increments; preserve the original measured ROM."""
from pathlib import Path
import argparse
import hashlib
import json
import math

ROOT = Path(__file__).resolve().parents[1]
RATIO = 3
FS = 150_000_000 / 3072


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    old = ROOT / "src/rom/marimba48.hex"
    target = ROOT / "src/rom/marimba48_48828.hex"
    lines = []
    for line in old.read_text().split():
        word = int(line, 16)
        for mode in range(4):
            shift = mode * 64 + 32
            step = (word >> shift) & 0xffffffff
            word = (word & ~(0xffffffff << shift)) | (((step + 1) // RATIO) << shift)
        lines.append(f"{word:064x}\n")
    text = "".join(lines)
    if args.check:
        assert target.read_text() == text, "Native-rate marimba ROM is stale"
    else:
        target.write_text(text, encoding="ascii")
    filters = []
    for a1, a2, feed in ((30138, 14171, 1024), (27708, 12688, 512)):
        q = 16384
        radius = math.sqrt(a2 / q)
        angle = math.acos(a1 / (2 * q * radius))
        new_a1 = round(2 * radius ** (1 / RATIO) * math.cos(angle / RATIO) * q)
        new_a2 = round(radius ** (2 / RATIO) * q)
        new_feed = round(feed * (q-new_a1+new_a2) / (q-a1+a2))
        filters.append(dict(a1=new_a1, a2=new_a2, feed=new_feed))
    assert filters == [dict(a1=31946, a2=15610, feed=118),
                       dict(a1=31264, a2=15046, feed=62)]
    out = ROOT / "output/audio150"
    out.mkdir(parents=True, exist_ok=True)
    info = dict(clock_hz=150_000_000, frame_cycles=3072, sample_rate_hz=FS,
                piano_pitch_ratio=round(48000 / FS * 65536),
                envelope_control_rate_hz=FS/RATIO, filters=filters,
                delay_samples=round(FS*.3), delay_ram_words=16384,
                source_sha256=hashlib.sha256(old.read_bytes()).hexdigest(),
                target_sha256=hashlib.sha256(target.read_bytes()).hexdigest())
    (out / "parameters.json").write_text(json.dumps(info, indent=2)+"\n", encoding="ascii")
    print("PASS: native 48828.125 Hz phase ROM, 16.276 kHz envelope control, "
          "retuned body poles/feed gains; original ROM unchanged")


if __name__ == "__main__":
    main()
