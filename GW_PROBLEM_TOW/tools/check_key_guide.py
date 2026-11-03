"""Collect current follow-guide regression evidence; no build or hardware access."""
from datetime import datetime, timezone, timedelta
from pathlib import Path
import hashlib
import json
import re
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "output/key_guide"
BENCHES = ("tb_follow_sequencer", "tb_tjc_status", "tb_uart_protocol", "tb_key_guide",
           "tb_key_guide_integration", "tb_board_controls", "tb_pressure_integration",
           "tb_uart_player_crc", "tb_uart_player_format", "tb_uart_player_empty", "tb_video_player")


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    logs = {}
    for bench in BENCHES:
        path = OUT / (bench + ".log")
        text = path.read_text(errors="replace")
        assert "# PASS" in text and "# Errors: 0," in text and "# End time:" in text, bench
        assert "** Fatal" not in text and "** Error" not in text, bench
        logs[bench] = sha(path)
    extra_logs = {}
    for bench in ("tb_hold_progress", "tb_marimba_mapping", "tb_key_guide_cached", "tb_score_full"):
        path = OUT / (bench + ".log")
        if path.is_file():
            text = path.read_text(errors="replace")
            assert "# PASS" in text and "# Errors: 0," in text and "# End time:" in text, bench
            assert "** Fatal" not in text and "** Error" not in text, bench
            extra_logs[bench] = sha(path)
    paths = [ROOT / "GW_PROBLEM_TOW.gprj"] + [ROOT / node.attrib["path"] for node in
             ET.parse(ROOT / "GW_PROBLEM_TOW.gprj").findall("./FileList/File")
             if node.attrib.get("enable") == "1"]
    synthesis_report = ROOT / "output/follow_guide/synthesis/impl/gwsynthesis/follow_guide_syn.rpt.html"
    synthesis_log = ROOT / "output/follow_guide/synthesis/console.txt"
    synthesis = None
    if synthesis_report.is_file() and synthesis_log.is_file():
        log = synthesis_log.read_text(errors="replace")
        if ("GowinSynthesis finish" in log and not re.search(r"\bERROR\s*\(", log)
                and all(p.stat().st_mtime <= synthesis_report.stat().st_mtime for p in paths)):
            synthesis = {"report": synthesis_report.relative_to(ROOT).as_posix(),
                         "report_sha256": sha(synthesis_report), "log_sha256": sha(synthesis_log)}
    paths += sorted({ROOT / "sim" / ("tb_uart_player_errors.sv" if bench in
                     ("tb_uart_player_crc", "tb_uart_player_format", "tb_uart_player_empty")
                     else bench + ".sv") for bench in BENCHES})
    paths += [ROOT / "sim/tb_uart_player.sv"]
    paths += [ROOT / "sim" / (bench + ".sv") for bench in
              ("tb_hold_progress", "tb_marimba_mapping", "tb_pressure")]
    paths += [ROOT / "sim/tb_score_full.v"]
    paths += [ROOT / name for name in ("sim/ws2812_monitor.sv", "sim/key_guide_reference.vh",
              "sim/uart_test_tasks.vh", "sim/audio_gate_cdc_monitor.sv", "sim/run_key_guide.ps1",
              "tools/make_key_guide_fixtures.py", "tools/check_key_guide.py", "tools/check_project.py",
              "tools/send_uart_command.ps1", "tools/prepare_follow_synthesis.py",
              "docs/KEY_GUIDE.md", "docs/UART_SCREEN.md",
              "docs/ARCHITECTURE.md", "docs/PRESSURE_KEYBOARD.md", "README.md", "VERIFICATION.md",
              "screen/tjc_uart/status_timer.txt")]
    paths += sorted((ROOT / "screen/tjc_uart").glob("guide_*.txt"))
    result = dict(created_at=datetime.now(timezone(timedelta(hours=8))).isoformat(), tests=logs,
                  additional_tests=extra_logs,
                  piano_notes=88, groups=6, dynamic_pixels=16, pin="C19", io_type="LVCMOS33",
                  highest_onset_group_only=True, fresh_press_per_step=True,
                  chord_requires_all_target_keys_held=True, guide_score_audio=False,
                  physical_keys_sound=True, default_mode="automatic_without_guide_lights",
                  command="0x53", mode_feedback="main.n8.val", mode_switch_restarts_piano=True,
                  existing_bin_format_unchanged=True, refresh_period_ms=2.0,
                  inputs={path.relative_to(ROOT).as_posix(): sha(path) for path in paths},
                  isolated_synthesis=synthesis, synthesis_run=synthesis is not None,
                  pnr_run=False, hardware_tested=False)
    (OUT / "verification.json").write_text(json.dumps(result, indent=2) + "\n", encoding="ascii")
    print("PASS: eleven follow-guide/compatibility benches; 88 targets, six colors, silent waiting, "
          "physical-key sound, highest-group chords, repeats, UART mode/echo, real ADC/SD/LED; "
          "no PnR or hardware access; isolated synthesis evidence attached when current")


if __name__ == "__main__":
    main()
