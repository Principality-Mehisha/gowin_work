"""Collect piano88 simulation evidence and validate the screen/host command."""
from pathlib import Path
import hashlib
import json
import re
import subprocess
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "output/piano88"
BENCHES = ("tb_piano88_core", "tb_piano88_core_fixed", "tb_piano88_uart",
           "tb_note_audition", "tb_uart_protocol", "tb_uart_notes")


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    tests = {}
    for name in BENCHES:
        path = OUT / (name + ".log")
        text = path.read_text(errors="replace")
        assert "# PASS" in text and "Errors: 0" in text, name
        assert "** Fatal" not in text and "** Error" not in text, name
        tests[name] = {
            "log": path.relative_to(ROOT).as_posix(), "sha256": digest(path),
            "results": [line for line in text.splitlines() if line.startswith("# PASS")],
        }
    for name in ("tb_piano88_core", "tb_piano88_core_fixed"):
        cycles = int(re.search(r"max (\d+)/3072 cycles", " ".join(tests[name]["results"]))[1])
        assert cycles < 3072
        tests[name]["max_frame_cycles"] = cycles
    frame = bytes.fromhex("A5 5A 01 00 46 00 00 00 47 0D")
    assert sum(frame[2:8]) & 255 == frame[8]
    script = ROOT / "screen/tjc_uart/piano88_release.txt"
    assert bytes.fromhex(script.read_text().removeprefix("printh").strip()) == frame
    host_frame = subprocess.check_output(
        ["powershell", "-NoProfile", "-File", str(ROOT / "tools/send_uart_command.ps1"),
         "-Command", "Piano88"], text=True)
    assert bytes.fromhex(host_frame.strip()) == frame
    project = ET.parse(ROOT / "GW_PROBLEM_TOW.gprj")
    paths = [ROOT / f.attrib["path"] for f in project.findall("./FileList/File")
             if f.attrib.get("enable") == "1"]
    paths += list((ROOT / "src/rom").glob("*.hex"))
    paths += [ROOT / name for name in (
        "sim/tb_piano88_core.sv", "sim/tb_piano88_uart.sv", "sim/tb_note_audition.sv",
        "sim/tb_uart_protocol.sv", "sim/tb_uart_notes.sv", "sim/audio_gate_cdc_monitor.sv",
        "sim/run_piano88.ps1", "tools/send_uart_command.ps1", "tools/check_piano88.py",
        "screen/tjc_uart/piano88_release.txt")]
    result = {
        "tests": tests, "simulation_runs": len(tests), "frame": frame.hex(" ").upper(),
        "inputs": {p.relative_to(ROOT).as_posix(): digest(p) for p in sorted(set(paths))},
        "full_synthesis_pnr_run": False, "bitstream_updated": False, "hardware_tested": False,
    }
    (OUT / "verification.json").write_text(json.dumps(result, indent=2) + "\n", encoding="ascii")
    print("PASS: six piano88 simulation runs, frame budget, screen/host command and source fingerprints")


if __name__ == "__main__":
    main()
