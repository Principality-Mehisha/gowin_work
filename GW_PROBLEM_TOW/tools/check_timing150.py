"""Collect functional evidence for a timing iteration, never claim timing closure."""
from pathlib import Path
from datetime import datetime, timezone, timedelta
import argparse
import hashlib
import json
import re
import xml.etree.ElementTree as ET
import zipfile

from check_timing150_constraints import main as check_constraints

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "output/timing150"
BENCHES = ("tb_audio_effects", "tb_audio150_effects", "tb_timing150_effects",
           "tb_audio150_ip", "tb_audio150_bridge", "tb_video_hardware",
           "tb_serializer_reset", "tb_analysis_cdc")
CHANGED = {
    "src/audio/audio_effects.v", "src/audio/audio_cdc_fifo.v",
    "src/audio/audio_clock150.v", "src/audio/audio_domain_bridge.v",
    "src/video/piano_video.v", "src/board/GW_PROBLEM_TOW.sdc",
    "src/board/GW_PROBLEM_TOW.cst",
}


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def passed_log(path):
    text = path.read_text(errors="replace")
    assert "# PASS" in text and "# Errors: 0," in text and "# End time:" in text, path.name
    assert "** Fatal" not in text, path.name
    return dict(sha256=sha(path), results=[s for s in text.splitlines() if s.startswith("# PASS")])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--require-system", action="store_true")
    args = parser.parse_args()
    check_constraints()
    tests = {name: passed_log(OUT / (name + ".log")) for name in BENCHES}
    assert "251045 bit-exact" in " ".join(tests["tb_audio_effects"]["results"])
    assert "244491 samples" in " ".join(tests["tb_audio150_effects"]["results"])
    assert "1500 exact" in " ".join(tests["tb_serializer_reset"]["results"])
    fx_text = " ".join(tests["tb_timing150_effects"]["results"])
    for rate in (1, 3):
        assert f"RATE={rate}: 24000 exact" in fx_text
    preserved = {}
    with zipfile.ZipFile(OUT / "before/sources.zip") as z:
        original = {n for n in z.namelist() if n.startswith("src/")}
        current = {p.relative_to(ROOT).as_posix() for p in (ROOT / "src").rglob("*") if p.is_file()}
        assert current == original, "No new/removed hardware modules or ROM files expected"
        for name in original - CHANGED:
            assert (ROOT / name).read_bytes() == z.read(name), name
            preserved[name] = sha(ROOT / name)
        assert (ROOT / "GW_PROBLEM_TOW.gprj").read_bytes() == z.read("GW_PROBLEM_TOW.gprj")
        cst = (ROOT / "src/board/GW_PROBLEM_TOW.cst").read_text()
        clock_line = 'CLOCK_LOC "display_enabled.video/serializer_clk" BUFG = CLK;'
        assert cst.count(clock_line) == 1
        assert [line for line in cst.splitlines() if line != clock_line] == (
            z.read("src/board/GW_PROBLEM_TOW.cst").decode().splitlines())
        reference = re.sub(r"\bmodule\s+audio_effects\b", "module audio_effects_before",
                           z.read("src/audio/audio_effects.v").decode())
        assert reference.splitlines() == (OUT / "before/audio_effects_before.v").read_text().splitlines()
    fifo = (ROOT / "src/audio/audio_cdc_fifo.v").read_text()
    assert "always @(posedge rd_clk or negedge rd_reset_n)" in fifo
    assert "wire rd_reset_n=rd_release[3]" in fifo
    assert "always @(negedge serializer_clk or negedge video_reset_n)" in (
        ROOT / "src/video/piano_video.v").read_text()

    system = None
    if args.require_system:
        system = {name: passed_log(ROOT / "output/audio150" / (name + ".log"))
                  for name in ("tb_audio150_system", "tb_analysis_render")}
        from make_analysis_fixtures import packed_frame
        from check_analysis import reference as render_reference
        directory = ROOT / "output/audio150"
        samples = [int(x, 16) for x in (directory / "piano_input.hex").read_text().split()]
        samples = [x - 65536 if x >= 32768 else x for x in samples]
        rows = [int(x, 16) for x in (directory / "piano_result.hex").read_text().split()]
        assert len(samples) == 1024 and len(rows) == 512 and rows == packed_frame(samples)
        for mode, name in enumerate(("spectrum", "waveform"), 1):
            assert (directory / (name + ".ppm")).read_bytes() == (
                b"P6\n1600 900\n255\n" + render_reference(mode, rows, 3))

    paths = [ROOT / "GW_PROBLEM_TOW.gprj"] + [ROOT / n.attrib["path"] for n in
             ET.parse(ROOT / "GW_PROBLEM_TOW.gprj").findall("./FileList/File")
             if n.attrib.get("enable") == "1"]
    paths += sorted((ROOT / "src/rom").glob("*.hex"))
    paths += [ROOT / "sim" / (name + ".sv") for name in BENCHES]
    paths += [ROOT / name for name in ("sim/run_timing150.ps1", "sim/tb_audio150_system.sv",
              "sim/run_audio150.ps1", "tools/check_timing150.py",
              "tools/check_timing150_constraints.py", "tools/check_timing.py",
              "tools/prepare_timing150.py", "ip/audio_fifo32/audio_fifo32.vo",
              "sim/tb_analysis_render.sv", "sim/sd_card_model.v", "sim/uart_test_tasks.vh",
              "sim/ws2812_monitor.sv", "sim/key_guide_reference.vh",
              "tools/project_sources.ps1", "tools/effects_reference.py",
              "tools/check_analysis.py", "tools/make_analysis_fixtures.py")]
    baseline = json.loads((OUT / "before/inputs.json").read_text())
    result = dict(
        created_at=datetime.now(timezone(timedelta(hours=8))).isoformat(),
        tests=tests, system_tests=system, modified_hardware=sorted(CHANGED),
        preserved_sources=preserved,
        effects_legacy_reference_samples=251045, effects_native_reference_samples=244491,
        effects_frozen_reference_samples=48000, tmds_words=1500,
        control_clock_hz=50000000, audio_clock_hz=150000000, sample_rate_hz=48828.125,
        functional_simulation_passed=True, current_sources_synthesized=False,
        physical_timing_verified=False, timing_closed=False, hardware_tested=False,
        synthesis_run=False, pnr_run=False, final_compilation_owner="user",
        next_report_requires_sys_domain_paths=True,
        current_bitstream_matches_pre_refactor=sha(ROOT / "impl/pnr/GW_PROBLEM_TOW.fs") == baseline["bitstream_sha256"],
        constraint_scope=json.loads((OUT / "constraint_scope.json").read_text()),
        source_archive_sha256=sha(OUT / "before/sources.zip"),
        inputs={p.relative_to(ROOT).as_posix(): sha(p) for p in paths},
    )
    (OUT / "verification.json").write_text(json.dumps(result, indent=2) + "\n", encoding="ascii")
    print("PASS: timing-iteration functional/constraint audit; clocks and non-target sources preserved; "
          "physical timing is NOT yet verified and requires the user's next PnR report")


if __name__ == "__main__":
    main()
