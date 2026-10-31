"""Generate the 200 TJC touch-release command lines; never access a serial port."""
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]


def frame(kind: int, number: int) -> str:
    fields = [0xA5, 0x5A, 1, 0, 0x12, kind, number, 0]
    fields += [sum(fields[2:]) & 255, 0x0D]
    return "printh " + " ".join(f"{value:02X}" for value in fields)


if __name__ == "__main__":
    lines = ["// One command per button touch-release event; disable component-ID sending."]
    for kind, prefix in ((1, "PN"), (2, "MB")):
        for number in range(1, 101):
            lines += [f"// {prefix}{number:03}.BIN", frame(kind, number)]
    target = ROOT / "screen/tjc_uart/numbered_buttons.txt"
    content = "\n".join(lines) + "\n"
    if "--check" in sys.argv:
        assert target.read_text(encoding="ascii") == content, "Stale numbered button scripts"
    else:
        target.write_text(content, encoding="ascii")
    print(f"PASS: 200 numbered song buttons in {target.relative_to(ROOT)}")
