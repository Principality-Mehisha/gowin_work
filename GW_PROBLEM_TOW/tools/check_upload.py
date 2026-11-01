"""Collect upload regression evidence, optionally require a matching full build."""
from pathlib import Path
from datetime import datetime, timezone, timedelta
import argparse
import hashlib
import json
import subprocess
import sys
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
BENCHES = (
    "tb_score_file_name", "tb_bluetooth_upload", "tb_bluetooth_overflow",
    "tb_bluetooth_reset", "tb_fixed_slot_reader", "tb_uart_protocol",
    "tb_board_controls", "tb_uart_player", "tb_uart_notes", "tb_score_player", "tb_score_full",
)


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--require-build", action="store_true")
    args = parser.parse_args()
    sources = [ROOT / item.attrib["path"] for item in
               ET.parse(ROOT / "GW_PROBLEM_TOW.gprj").findall("./FileList/File")
               if item.attrib.get("enable") == "1"]
    logs = {}
    for bench in BENCHES:
        path = ROOT / "output/numbered_only" / f"{bench}.log"
        text = path.read_text(errors="replace")
        assert "# PASS" in text and "# Errors: 0," in text, f"Missing PASS: {bench}"
        assert "** Fatal:" not in text, f"Fatal failure: {bench}"
        logs[bench] = sha(path)
    host = subprocess.run([sys.executable, "-B", str(ROOT / "sim/test_bluetooth_upload.py")],
                          cwd=ROOT, text=True, capture_output=True, check=True)
    host_log = ROOT / "output/numbered_only/host_tests.log"
    host_log.write_text(host.stdout + host.stderr, encoding="ascii")
    manifest_path = ROOT / "output/build_manifest.json"
    matching = False
    if manifest_path.exists():
        manifest = json.loads(manifest_path.read_text())
        matching = all((ROOT / name).is_file() and sha(ROOT / name) == digest
                       for name, digest in manifest["inputs"].items())
        matching &= sha(ROOT / manifest["bitstream"]) == manifest["bitstream_sha256"]
        matching &= (ROOT / "output/GW_PROBLEM_TOW.fs").exists()
        if matching:
            matching &= sha(ROOT / "output/GW_PROBLEM_TOW.fs") == manifest["bitstream_sha256"]
    if args.require_build:
        assert matching, "Build manifest/bitstream does not match current inputs"
        subprocess.run([sys.executable, "-B", str(ROOT / "tools/check_fixed_resources.py")],
                       cwd=ROOT, check=True)
    result = {
        "created_at": datetime.now(timezone(timedelta(hours=8))).isoformat(),
        "benches": logs,
        "host_tests_log_sha256": sha(host_log),
        "host_inputs": {name: sha(ROOT / name) for name in
                        ("tools/bluetooth_upload.py", "tools/slot_card.py", "sim/test_bluetooth_upload.py",
                         "tools/make_upload_fixtures.py", "sim/sd_card_model.v", "sim/tb_bluetooth_upload.sv",
                         "sim/tb_fixed_slot_reader.sv", "sim/run_upload.ps1",
                         "sim/tb_score_file_name.sv", "sim/tb_uart_protocol.sv",
                         "sim/tb_board_controls.sv", "sim/tb_uart_player.sv", "sim/tb_uart_notes.sv",
                         "sim/tb_score_player.v", "sim/tb_score_full.v", "sim/tb_video_player.sv",
                         "tools/check_upload.py", "tools/check_fixed_resources.py",
                         "tools/check_analysis_build.py")},
        "rtl_and_constraints": {path.relative_to(ROOT).as_posix(): sha(path) for path in sources},
        "build_matches_sources": bool(matching),
        "hardware_tested": False,
    }
    if matching:
        result["bitstream_sha256"] = manifest["bitstream_sha256"]
        result["timing"] = manifest["timing"]
        resource_path = ROOT / "output/numbered_only/resources.json"
        if resource_path.exists():
            result["resources"] = json.loads(resource_path.read_text())
        display_path = ROOT / "output/piano_analysis/verification.json"
        if display_path.exists():
            display = json.loads(display_path.read_text())
            if display.get("bitstream_sha256") == manifest["bitstream_sha256"]:
                result["display_verification"] = {
                    "path": display_path.relative_to(ROOT).as_posix(),
                    "sha256": sha(display_path),
                    "testbenches": display["distinct_testbenches"],
                }
    out = ROOT / "output/numbered_only/verification.json"
    out.write_text(json.dumps(result, indent=2) + "\n", encoding="ascii")
    print(f"PASS: {len(logs)} RTL regressions; matching build={bool(matching)}; no physical hardware test")


if __name__ == "__main__":
    main()
