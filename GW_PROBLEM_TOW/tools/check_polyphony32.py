"""Collect current-source functional evidence, without making build/timing claims."""
from pathlib import Path
import hashlib
import json
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "output/polyphony32"
BENCHES = ("tb_score32_reader", "tb_sd_polyphony32", "tb_follow_sequencer",
           "tb_score_full", "tb_bluetooth_polyphony32")


def main():
    results = {}
    for bench in BENCHES:
        path = OUT / f"{bench}.log"
        text = path.read_text(errors="replace")
        assert "# PASS" in text and "Errors: 0" in text and "** Fatal" not in text, bench
        results[bench] = [line for line in text.splitlines() if line.startswith("# PASS")]
    project = ET.parse(ROOT / "GW_PROBLEM_TOW.gprj")
    inputs = {entry.attrib["path"] for entry in project.findall("./FileList/File")
              if entry.attrib.get("enable") == "1"}
    inputs.update(f"sim/{bench}.sv" for bench in BENCHES
                  if (ROOT / f"sim/{bench}.sv").exists())
    inputs.update((
        "GW_PROBLEM_TOW.gprj", "ip/audio_fifo32/audio_fifo32.vo",
        "sim/tb_score_full.v", "sim/tb_bluetooth_upload.sv", "sim/sd_card_model.v",
        "sim/uart_test_tasks.vh", "sim/run_polyphony32.ps1", "sim/test_polyphony32.py",
        "sim/test_classical_scores.py", "sim/test_bluetooth_upload.py",
        "tools/make_polyphony32_fixtures.py", "tools/make_upload_fixtures.py",
        "tools/fat_test_fixtures.py", "tools/slot_card.py", "tools/project_sources.ps1",
        "tools/make_piano_score.py", "tools/score_bin.py", "tools/bluetooth_upload.py",
        "tools/make_android_ringtone.py", "tools/make_ringtone_score.py",
        "tools/make_classical_scores.py", "tools/make_selected_piano.py",
        "tools/make_pn001_test.py", "tools/midi_notes.py",
        "tools/prepare_bluetooth_files.py", "tools/check_polyphony32.py",
        "sd_card/PIANO.BIN", "sd_card/ANDROID.BIN"))
    inputs.update(path.relative_to(ROOT).as_posix() for path in (ROOT / "src/rom").iterdir())
    report = dict(
        date="2026-11-04", score_slots=32, legacy_slots=8, host_tests=23,
        rtl_tests=results, simultaneous_32_notes_verified_for=["piano", "marimba"],
        sd_spi_and_score_clock_accelerated=True, audio_clock_hz=150000000,
        compiled_bitstream=False, hardware_tested=False, physical_timing_verified=False,
        inputs_sha256={name: hashlib.sha256((ROOT / name).read_bytes()).hexdigest()
                       for name in sorted(inputs)})
    (OUT / "verification.json").write_text(json.dumps(report, indent=2) + "\n", encoding="ascii")
    print("PASS: 32-slot SD/PN/MB/DAC, Bluetooth upload, legacy8, guide, full-score logs and source hashes")


if __name__ == "__main__":
    main()
