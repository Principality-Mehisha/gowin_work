"""Check synthesis tables and the explicitly SD event ringtone."""
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
marimba_table = (root / "src/rom/marimba48.hex").read_text().splitlines()
attack_table = (root / "src/rom/marimba_attack48.hex").read_text().splitlines()
assert len(marimba_table) == 48 and all(len(row) == 64 for row in marimba_table)
assert len(attack_table) == 48 and all(len(row) == 8 for row in attack_table)
for row in marimba_table:
    packed = int(row, 16)
    assert all(
        ((packed >> (mode * 64 + 32)) & 0xFFFFFFFF) < 0x80000000
        for mode in range(4)
    ), "Marimba mode exceeds Nyquist"
readmem_sources = []
for source in sources:
    if "$readmem" in source.read_text():
        readmem_sources.append(source.name)
assert set(readmem_sources) == {"piano_synth.v", "marimba_synth.v"}
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
assert "parameter integer DEFAULT_MARIMBA = 1" in top
player = (root / "src/piano_score_player.v").read_text()
assert "sd_spi_reader" in player
assert ".clk(sys_clk)" in player and ".sys_clk(sys_clk)" in player
assert "module dynamics_fixed" in (root / "src/dynamics_fixed.v").read_text()
assert "assign dynamics = 8'd192" in (root / "src/dynamics_fixed.v").read_text()
assert "parameter integer SD_SCORE_ENABLE = 0" in player
assert "wire reset_async_n = reset_request_n && KEY2" in player
assert "wire manual_mode = !ringtone_active" in player
assert "dynamics_fixed.v" in {
    source.name for source in sources
}
text = (root / "src/piano_synth.v").read_text()
assert text.count("$readmemh") == 3
assert "sine_rom [0:255]" in text
assert "sine256.hex" in text and "frequency88.hex" in text
assert not any(p.suffix.lower() in (".wav", ".mp3", ".pcm") for p in sources)
assert "voicing88.hex" in text
marimba = (root / "src/marimba_synth.v").read_text()
assert marimba.count("$readmemh") == 3
assert "marimba48.hex" in marimba and "marimba_attack48.hex" in marimba
assert "sine256.hex" in marimba
assert (root / "src/marimba_body_filter.v").exists()
ringtone = (root / "src/ringtone_pcm_player.v").read_text()
assert "ringtone_config.vh" in ringtone
assert "ringtone_pcm_player" not in player
assert all(name in player for name in ("ANDROID BIN", "RINGTONEBIN", "PIANO   BIN"))
assert ".marimba_format(selected_track!=3)" in player
assert "uart_score_control" in player and ".uart_rx(uart_rx)" in top
assert {"uart_rx.v", "uart_tx.v", "tjc_status_tx.v", "uart_score_control.v"}.issubset(
    {source.name for source in sources})
assert "uart_note_audition.v" in {source.name for source in sources}
assert "uart_note_audition" in player
assert (root / "sd_card/ANDROID.BIN").read_bytes()[:4] == b"M42S"
assert "ringtone_button" in player
for bank in range(5):
    data = (root / f"src/rom/ringtone_bank{bank}.hex").read_text().splitlines()
    assert len(data) == 32768 and all(len(row) == 2 for row in data)
assert len((root / "src/rom/ima_steps.hex").read_text().splitlines()) == 89
print("PASS structural checks: default marimba, SD event ringtone, 50 MHz, DDS tables")
for source in sources:
    print(hashlib.sha256(source.read_bytes()).hexdigest(), source.relative_to(root))
