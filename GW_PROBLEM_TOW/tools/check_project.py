"""Small structural checks for the real-time synthesis data boundary."""
from pathlib import Path
import hashlib
import re
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parents[1]
project = ET.parse(root / "GW_PROBLEM_TOW.gprj")
sources = [
    root / f.attrib["path"] for f in project.findall("./FileList/File")
    if f.attrib["type"] == "file.verilog"
]
for source in sources:
    assert source.exists(), source
top = (root / "src/GW_PROBLEM_TOW.v").read_text()
assert not re.search(r"\b(always|initial|assign|function|task)\b", top)
assert len((root / "src/rom/sine256.hex").read_text().splitlines()) == 256
assert len((root / "src/rom/frequency88.hex").read_text().splitlines()) == 88
assert len((root / "src/rom/voicing88.hex").read_text().splitlines()) == 88
readmem_sources = []
for source in sources:
    if "$readmem" in source.read_text():
        readmem_sources.append(source.name)
assert sorted(readmem_sources) == [
    "piano_pcm_voice.v", "piano_polyphony.v", "piano_synth.v", "pll_init.v"
]
assert (root / "src/piano_bank.hex").stat().st_size == 1_048_576
score = (root / "sd_card/PIANO.BIN").read_bytes()
assert score[:4] == b"P88S"
assert len(score) == 16 + 8 * int.from_bytes(score[12:16], "little")
assert "piano_score_player" in top
assert "sd_spi_reader" in (root / "src/piano_score_player.v").read_text()
text = (root / "src/piano_synth.v").read_text()
assert text.count("$readmemh") == 3
assert "sine_rom [0:255]" in text
assert "sine256.hex" in text and "frequency88.hex" in text
assert not any(p.suffix.lower() in (".wav", ".mp3", ".pcm") for p in sources)
assert "voicing88.hex" in text
print("PASS structural checks: structural top, one sine table, pitch/voicing parameters")
for source in sources:
    print(hashlib.sha256(source.read_bytes()).hexdigest(), source.relative_to(root))
