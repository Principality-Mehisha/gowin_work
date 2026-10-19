"""Generate function/parameter ROMs only. Never generate note PCM for the FPGA."""
from pathlib import Path
import math

ROOT = Path(__file__).resolve().parents[1]
ROM = ROOT / "src" / "rom"
ROM.mkdir(exist_ok=True)
sine = [round(30000 * math.sin(2 * math.pi * i / 256)) for i in range(256)]
words = [round(27.5 * 2 ** (i / 12) * 2 ** 32 / 48000) for i in range(88)]
(ROM / "sine256.hex").write_text(
    "".join(f"{value & 65535:04x}\n" for value in sine), encoding="ascii")
(ROM / "frequency88.hex").write_text(
    "".join(f"{value:08x}\n" for value in words), encoding="ascii")
print(f"Function table: {len(sine)} points; pitch parameters: {len(words)}")
print(f"A4 DDS word: {words[48]}; Fs=48000")
