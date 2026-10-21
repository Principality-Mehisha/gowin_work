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
assert len(sources) == len(set(sources)), "Duplicate RTL entries in Gowin project"
top = (root / "src/GW_PROBLEM_TOW.v").read_text()
assert not re.search(r"\b(always|initial|assign|function|task)\b", top)
assert len((root / "src/rom/sine256.hex").read_text().splitlines()) == 256
assert len((root / "src/rom/frequency88.hex").read_text().splitlines()) == 88
assert len((root / "src/rom/voicing88.hex").read_text().splitlines()) == 88
readmem_sources = []
for source in sources:
    if "$readmem" in source.read_text():
        readmem_sources.append(source.name)
assert readmem_sources == ["piano_synth.v"]
for removed in (
    "piano_bank.hex", "piano_pcm_voice.v", "piano_polyphony.v",
    "piano_sample_map.v", "pt8211_tx.v",
):
    assert not (root / "src" / removed).exists(), removed
score = (root / "sd_card/PIANO.BIN").read_bytes()
assert score[:4] == b"P88S"
assert len(score) == 16 + 8 * int.from_bytes(score[12:16], "little")
assert "piano_score_player" in top
assert "parameter integer SD_SCORE_ENABLE = 0" in top
assert ".SD_SCORE_ENABLE(SD_SCORE_ENABLE)" in top
player = (root / "src/piano_score_player.v").read_text()
assert "sd_spi_reader" in player
assert ".clk(sys_clk)" in player and ".sys_clk(sys_clk)" in player
assert "module dynamics_fixed" in (root / "src/dynamics_fixed.v").read_text()
assert "assign dynamics = 8'd192" in (root / "src/dynamics_fixed.v").read_text()
assert "parameter integer SD_SCORE_ENABLE = 0" in player
assert "wire reset_async_n = reset_request_n && KEY2" in player
assert "wire manual_mode = !SD_SCORE_ENABLE" in player
assert "dynamics_fixed.v" in {
    source.name for source in sources
}
text = (root / "src/piano_synth.v").read_text()
assert text.count("$readmemh") == 3
assert "sine_rom [0:255]" in text
assert "sine256.hex" in text and "frequency88.hex" in text
assert not any(p.suffix.lower() in (".wav", ".mp3", ".pcm") for p in sources)
assert "voicing88.hex" in text
print("PASS structural checks: top, 50 MHz clock, dynamics hook, DDS tables")
for source in sources:
    print(hashlib.sha256(source.read_bytes()).hexdigest(), source.relative_to(root))
