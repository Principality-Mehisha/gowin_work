"""Collect pressure regression evidence without running synthesis or PnR."""
from datetime import datetime, timezone, timedelta
import hashlib
import json
from pathlib import Path
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "output/pressure_keyboard"
BENCHES = ("tb_pressure_curve", "tb_pressure_events", "tb_pressure", "tb_pitch_groups", "tb_hold_progress",
           "tb_pressure_integration", "tb_play_admission", "tb_instrument_bank", "tb_synth_live")


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    tests = {}
    for bench in BENCHES:
        path = OUT / (bench + ".log")
        text = path.read_text(errors="replace")
        assert "# PASS" in text and "# Errors: 0," in text and "** Fatal" not in text, bench
        tests[bench] = {"sha256": sha(path),
                        "results": [line for line in text.splitlines() if line.startswith("# PASS")]}
    paths = [ROOT / "GW_PROBLEM_TOW.gprj"] + [
        ROOT / item.attrib["path"] for item in
        ET.parse(ROOT / "GW_PROBLEM_TOW.gprj").findall("./FileList/File")
        if item.attrib.get("enable") == "1"]
    paths += sorted((ROOT / "src/rom").glob("*.hex"))
    baseline = OUT / "before/audio_rom_hashes.json"
    roms_unchanged = None
    if baseline.exists():
        original = json.loads(baseline.read_text(encoding="utf-8-sig"))
        assert len(original) == 5
        roms_unchanged = all(sha(ROOT / "src/rom" / Path(row["Path"]).name).upper() == row["Hash"]
                             for row in original)
        assert roms_unchanged, "Audio ROM changed"
    manifest_path = ROOT / "output/build_manifest.json"
    matching = False
    if manifest_path.exists():
        manifest = json.loads(manifest_path.read_text())
        matching = all((ROOT / name).is_file() and sha(ROOT / name) == digest
                       for name, digest in manifest["inputs"].items())
        matching &= sha(ROOT / manifest["bitstream"]) == manifest["bitstream_sha256"]
    result = {
        "created_at": datetime.now(timezone(timedelta(hours=8))).isoformat(),
        "tests": tests, "audio_roms_unchanged": roms_unchanged,
        "inputs": {p.relative_to(ROOT).as_posix(): sha(p) for p in paths},
        "test_inputs": {p.relative_to(ROOT).as_posix(): sha(p) for p in
                        [ROOT / "sim" / (name + ".sv") for name in BENCHES[:-1]] +
                        [ROOT / "sim/tb_synth.sv", ROOT / "sim/pressure_synth_adapter.sv",
                         ROOT / "sim/run_pressure.ps1", ROOT / "tools/check_pressure.py",
                         ROOT / "tools/project_sources.ps1"]},
        "build_matches_current_sources": bool(matching),
        "physical_timing_checked": False, "hardware_tested": False,
        "final_compilation_owner": "user",
    }
    (OUT / "verification.json").write_text(json.dumps(result, indent=2) + "\n", encoding="ascii")
    print(f"PASS: {len(tests)} pressure/compatibility regressions; audio-ROM baseline match={roms_unchanged}; "
          f"matching build={bool(matching)}; synthesis/PnR not run by this checker")


if __name__ == "__main__":
    main()
