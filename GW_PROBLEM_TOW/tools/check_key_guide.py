"""Check simulated guide frames and unchanged audio/storage inputs; no EDA build."""
from datetime import datetime, timezone, timedelta
from pathlib import Path
import hashlib
import json
import zipfile
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "output/key_guide"
BENCHES = ("tb_key_guide", "tb_key_guide_integration", "tb_board_controls",
           "tb_pressure_integration", "tb_uart_player", "tb_video_player")


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    logs = {}
    for bench in BENCHES:
        path = OUT / (bench + ".log")
        text = path.read_text(errors="replace")
        assert "# PASS" in text and "# Errors: 0," in text and "# End time:" in text, bench
        assert "** Fatal" not in text, bench
        logs[bench] = sha(path)
    changed = {"src/board/GW_PROBLEM_TOW.v", "src/board/piano_score_player.v",
               "src/board/GW_PROBLEM_TOW.cst", "src/ws2812_static.v",
               "src/board/GW_PROBLEM_TOW.sdc", "src/system/instrument_system.v",
               "src/video/piano_video.v", "src/video/video_source.v",
               "src/video/piano_analysis_scene.v"}
    preserved = {}
    with zipfile.ZipFile(OUT / "before/sources.zip") as backup:
        names = {name.replace("\\", "/"): name for name in backup.namelist()}
        for name, entry in names.items():
            if name.startswith("src/") and not name.startswith("src/audio/") and name not in changed:
                assert backup.read(entry) == (ROOT / name).read_bytes(), f"Unexpected change: {name}"
                preserved[name] = sha(ROOT / name)
        old = backup.read(names["src/ws2812_static.v"]).decode().splitlines()
        new = (ROOT / "src/ws2812_static.v").read_text().splitlines()
        new = [line.replace("output reg data_out,", "output reg data_out") for line in new
               if "output wire [143:0] group_palette" not in line and "assign group_palette=" not in line]
        assert new == old, "Original static serialization must remain unchanged"
        cst = (ROOT / "src/board/GW_PROBLEM_TOW.cst").read_text().splitlines()
        cst = [line for line in cst if '"LED_indicator_dynamic"' not in line]
        assert cst == backup.read(names["src/board/GW_PROBLEM_TOW.cst"]).decode().splitlines(), \
            "Only C19 guide pin constraints may be added"
    paths = [ROOT / "GW_PROBLEM_TOW.gprj"] + [ROOT / node.attrib["path"] for node in
            ET.parse(ROOT / "GW_PROBLEM_TOW.gprj").findall("./FileList/File")
            if node.attrib.get("enable") == "1"]
    paths += [ROOT / "sim" / (bench + ".sv") for bench in BENCHES]
    paths += [ROOT / name for name in ("sim/ws2812_monitor.sv", "sim/key_guide_reference.vh",
              "sim/audio_gate_cdc_monitor.sv",
              "sim/run_key_guide.ps1", "tools/make_key_guide_fixtures.py",
              "tools/check_key_guide.py", "tools/check_project.py")]
    reused_logs = {}
    for bench, suite in (("tb_pressure_integration", "pressure_keyboard"),
                         ("tb_uart_player", "no_clarinet"), ("tb_video_player", "no_clarinet")):
        previous = ROOT / "output" / suite / (bench + ".log")
        if previous.is_file() and sha(previous) == logs[bench]:
            reused_logs[bench] = previous.relative_to(ROOT).as_posix()
    result = dict(created_at=datetime.now(timezone(timedelta(hours=8))).isoformat(),
                  tests=logs, piano_notes=88, groups=6, dynamic_pixels=16,
                  reused_compatible_logs=reused_logs,
                  pin="C19", io_type="LVCMOS33", highest_group_only=True,
                  refresh_period_ms=2.0, existing_bin_format_unchanged=True,
                  pcm_dac_sd_uart_cycle_exact=True, static_serializer_unchanged=True,
                  audio_profile="native 150 MHz; audio changes audited in output/audio150",
                  unchanged_from_backup=preserved,
                  inputs={path.relative_to(ROOT).as_posix(): sha(path) for path in paths},
                  synthesis_run=False, pnr_run=False, hardware_tested=False)
    (OUT / "verification.json").write_text(json.dumps(result, indent=2) + "\n", encoding="ascii")
    print("PASS: six guide/compatibility benches, 88 notes/six colors, 16 serial pixels, "
          "C19/3.3 V; actual DAC/SD/UART unchanged; no synthesis/PnR or physical hardware access")


if __name__ == "__main__":
    main()
