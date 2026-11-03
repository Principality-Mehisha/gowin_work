"""Audit native-audio simulation evidence and preserved sources; never build EDA."""
from datetime import datetime, timezone, timedelta
from pathlib import Path
import hashlib
import json
import re
import zipfile
import xml.etree.ElementTree as ET

from check_analysis import reference
from make_analysis_fixtures import packed_frame

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "output/audio150"
BENCHES = ("tb_audio150_ip", "tb_audio150_core", "tb_audio150_bridge",
           "tb_audio150_effects", "tb_audio150_system", "tb_analysis_render")
CHANGED = {
    "src/audio/audio_effects.v", "src/audio/instrument_voice_bank.v",
    "src/audio/marimba_body_filter.v", "src/audio/marimba_synth.v",
    "src/audio/output_limiter.v", "src/audio/piano_synth.v",
    "src/audio/pt8211_score_tx.v", "src/board/GW_PROBLEM_TOW.sdc",
    "src/board/piano_score_player.v", "src/system/instrument_system.v",
    "src/video/piano_analysis_scene.v", "src/video/piano_video.v",
    "src/video/video_source.v",
}
NEW_SOURCES = {
    "src/audio/audio_clock150.v", "src/audio/audio_cdc_fifo.v",
    "src/audio/audio_domain_bridge.v", "src/rom/marimba48_48828.hex",
}
IP_INPUTS = (
    "ip/audio_fifo32/audio_fifo32.ipc", "ip/audio_fifo32/audio_fifo32.vo",
    "ip/audio_pll150/audio_pll150.ipc", "ip/audio_pll150/audio_pll150.mod",
)


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def statements(text):
    return [line.strip() for line in text.splitlines()
            if line.strip() and not line.lstrip().startswith("//")]


def main():
    logs = {}
    texts = {}
    for bench in BENCHES:
        path = OUT / (bench + ".log")
        text = path.read_text(errors="replace")
        assert "# PASS" in text and "# Errors: 0," in text and "# End time:" in text, bench
        assert "** Fatal" not in text, bench
        logs[bench] = sha(path)
        texts[bench] = text
    cycles = int(re.search(r"max (\d+) clocks", texts["tb_audio150_core"])[1])
    assert cycles < 3072
    frames, packets = map(int, re.search(
        r"(\d+) stereo frames, (\d+) exact return packets",
        texts["tb_audio150_system"]).groups())
    assert frames > 9000 and packets > frames
    assert "244491 samples" in texts["tb_audio150_effects"]

    preserved = {}
    with zipfile.ZipFile(OUT / "before/sources.zip") as backup:
        names = {name.replace("\\", "/"): name for name in backup.namelist()}
        old_sources = {name for name in names if name.startswith("src/")}
        for name in sorted(old_sources - CHANGED):
            assert backup.read(names[name]) == (ROOT / name).read_bytes(), name
            preserved[name] = sha(ROOT / name)
        current_sources = {path.relative_to(ROOT).as_posix()
                           for path in (ROOT / "src").rglob("*") if path.is_file()}
        assert current_sources - old_sources == NEW_SOURCES
        assert not old_sources - current_sources
        name = "src/audio/pt8211_score_tx.v"
        assert statements(backup.read(names[name]).decode()) == statements((ROOT / name).read_text())
        name = "src/board/GW_PROBLEM_TOW.sdc"
        old_sdc = [s.strip() for s in backup.read(names[name]).decode().splitlines()
                   if s.strip() and not s.lstrip().startswith("#")]
        new_sdc = [s.strip() for s in (ROOT / name).read_text().splitlines()
                   if s.strip() and not s.lstrip().startswith("#")]
        audio_lines = [s for s in new_sdc if "audio_clk" in s]
        assert len(audio_lines) == 2
        assert audio_lines[0].startswith("create_generated_clock -name audio_clk ")
        assert "-multiply_by 3" in audio_lines[0]
        assert audio_lines[1].startswith("report_timing -setup ")
        assert [s for s in new_sdc if "audio_clk" not in s] == old_sdc

    samples = [int(word, 16) for word in (OUT / "piano_input.hex").read_text().split()]
    samples = [value - 65536 if value >= 32768 else value for value in samples]
    rows = [int(word, 16) for word in (OUT / "piano_result.hex").read_text().split()]
    assert len(samples) == 1024 and len(rows) == 512 and rows == packed_frame(samples)
    for mode, name in enumerate(("spectrum", "waveform"), 1):
        assert (OUT / (name + ".ppm")).read_bytes() == (
            b"P6\n1600 900\n255\n" + reference(mode, rows, 3)), name
    measurements = json.loads((OUT / "sample_measurements.json").read_text())
    parameters = json.loads((OUT / "parameters.json").read_text())
    assert parameters["sample_rate_hz"] == measurements["sample_rate_hz"] == 48828.125
    assert parameters["clock_hz"] == 150000000 and parameters["frame_cycles"] == 3072
    assert measurements["marimba_bit_exact_samples"] == 4096
    assert abs(measurements["piano_a4_peak_hz"] - 440) < 0.5

    nodes = ET.parse(ROOT / "GW_PROBLEM_TOW.gprj").findall("./FileList/File")
    paths = [ROOT / "GW_PROBLEM_TOW.gprj"] + [
        ROOT / node.attrib["path"] for node in nodes if node.attrib.get("enable") == "1"]
    assert sum(node.attrib.get("type") == "file.verilog" and node.attrib.get("enable") == "1"
               for node in nodes) == 58
    roms = sorted((ROOT / "src/rom").glob("*.hex"))
    assert len(roms) == 6
    paths += roms + [ROOT / name for name in IP_INPUTS]
    paths += sorted((ROOT / "src/video").glob("analysis_*.hex"))
    paths += sorted((ROOT / "sim").glob("tb_audio150_*.sv"))
    paths += [ROOT / name for name in (
        "sim/tb_analysis_render.sv", "sim/sd_card_model.v", "sim/ws2812_monitor.sv",
        "sim/audio_gate_cdc_monitor.sv", "sim/uart_test_tasks.vh", "sim/run_audio150.ps1",
        "tools/project_sources.ps1", "tools/generate_audio150_ip.tcl",
        "tools/generate_audio150_parameters.py", "tools/check_audio150_samples.py",
        "tools/check_audio150.py", "tools/check_analysis.py",
        "tools/make_analysis_fixtures.py", "tools/make_key_guide_fixtures.py",
        "tools/check_project.py", "tools/check_timing.py", "tools/check_analysis_build.py",
        "tools/write_build_manifest.py",
    )]
    primitive = Path("D:/Gowin/Gowin_V1.9.12.03_x64/IDE/simlib/gw5a/prim_sim.v")
    result = dict(
        created_at=datetime.now(timezone(timedelta(hours=8))).isoformat(),
        tests=logs, parameters=parameters, measurements=measurements,
        control_clock_hz=50000000, audio_clock_hz=150000000,
        frame_cycles=3072, max_synth_cycles=cycles, native_pcm_samples=10240,
        native_effect_samples=244491, checked_stereo_frames=frames,
        exact_feedback_packets=packets, fft_rows=512, rgb_pixels_per_view=1440000,
        official_ip_generation=True, project_synthesis=False, project_pnr=False,
        physical_timing_verified=False, hardware_tested=False,
        final_compilation_owner="user", pins_bin_and_upload_protocol_unchanged=True,
        changed_existing_sources=sorted(CHANGED), new_sources=sorted(NEW_SOURCES),
        preserved_sources=preserved,
        inputs={path.relative_to(ROOT).as_posix(): sha(path) for path in paths},
        official_simulation_library=dict(path=str(primitive), sha256=sha(primitive)),
    )
    (OUT / "verification.json").write_text(json.dumps(result, indent=2) + "\n", encoding="ascii")
    print("PASS: six native-audio benches, independent PCM/FFT/RGB reference and source audit; "
          "150 MHz physical timing remains unverified; main synthesis/PnR belongs to user")


if __name__ == "__main__":
    main()
