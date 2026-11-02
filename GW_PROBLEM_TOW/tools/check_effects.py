"""Validate effect vectors, UART scripts and simulation evidence; no EDA build."""
from pathlib import Path
from datetime import datetime, timezone, timedelta
import argparse
import hashlib
import json
import re
import struct
import wave
import xml.etree.ElementTree as ET
import zipfile

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "output/audio_effects"
BENCHES = ("tb_audio_effects", "tb_tjc_status", "tb_uart_protocol", "tb_effects_integration")


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--full-regression", action="store_true")
    args = parser.parse_args()
    logs = {}
    for bench in BENCHES:
        path = OUT / (bench + ".log")
        text = path.read_text(errors="replace")
        assert "# PASS" in text and "# Errors: 0," in text and "** Fatal" not in text, bench
        logs[bench] = sha(path)
    vectors = [int(x, 16) for x in (OUT / "vectors.hex").read_text().split()]
    samples = [int(x, 16) for x in (OUT / "rtl_samples.hex").read_text().split()]
    assert len(vectors) == len(samples) and all((v >> 22) & 65535 == y for v, y in zip(vectors, samples))
    info = json.loads((OUT / "reference.json").read_text())
    for name, section in info["sections"].items():
        values = samples[section["start"]:section["start"] + section["samples"]]
        signed = [v - 65536 if v >= 32768 else v for v in values]
        with wave.open(str(OUT / (name + "_rtl.wav")), "wb") as w:
            w.setparams((1, 2, round(info["sample_rate_hz"]), 0, "NONE", "not compressed"))
            w.writeframes(struct.pack("<" + "h"*len(signed), *signed))
    scripts = ROOT / "screen/tjc_uart"
    for mode, name in enumerate(("original", "delay", "reverb", "chorus")):
        text = (scripts / ("effect_" + name + "_release.txt")).read_text()
        fields = [int(v, 16) for v in text.split()[1:]]
        assert fields == [165, 90, 1, 0, 81, mode, 0, 0, 82+mode, 13]
    pattern = (r"printh A5 5A 01 00 52\s+prints vaFxValue\.val,1\s+printh 00 00"
               r"\s+prints vaFxSum\.val,1\s+printh 0D")
    for name in ("effect_timer.txt", "effect_slider_release.txt"):
        text = (scripts / name).read_text()
        assert re.search(pattern, text) and "vaFxSum.val=83+vaFxValue.val" in text
        for value in range(101):
            frame = bytes((165, 90, 1, 0, 82, value, 0, 0, 83+value, 13))
            assert len(frame) == 10 and frame[8] == sum(frame[2:8]) & 255
    timer = (scripts / "effect_timer.txt").read_text()
    assert "if(hFx.val!=vaFxSent.val)" in timer and "if(vaFxDrag.val==1)" in timer
    assert "tmFx.tim=100" in (scripts / "effect_page_postinitialize.txt").read_text()
    preserved = [
        "src/board/GW_PROBLEM_TOW.v", "src/board/GW_PROBLEM_TOW.cst",
        "src/board/GW_PROBLEM_TOW.sdc", "src/audio/piano_synth.v",
        "src/audio/marimba_synth.v", "src/audio/marimba_body_filter.v",
        "src/audio/instrument_voice_bank.v", "src/audio/output_limiter.v",
        "src/control/bluetooth_file_receiver.v", "src/control/playback_control.v",
        "src/video/piano_live_roll.v", "src/video/piano_scene.v",
        "src/video/piano_roll_line.v", "src/video/playback_video_cdc.v",
        "src/video/video_source.v", "src/video/piano_video.v",
    ]
    preserved += [p.relative_to(ROOT).as_posix() for p in (ROOT / "src/storage").glob("*.v")]
    preserved += [p.relative_to(ROOT).as_posix() for p in (ROOT / "src/rom").glob("*.hex")]
    with zipfile.ZipFile(OUT / "before/sources.zip") as backup:
        for name in preserved:
            assert backup.read(name) == (ROOT / name).read_bytes(), f"Unexpected change: {name}"
    paths = [ROOT / "GW_PROBLEM_TOW.gprj"] + [ROOT / f.attrib["path"] for f in
            ET.parse(ROOT / "GW_PROBLEM_TOW.gprj").findall("./FileList/File") if f.attrib.get("enable") == "1"]
    paths += sorted((ROOT / "src/rom").glob("*.hex"))
    paths += [ROOT / "sim" / (name + ".sv") for name in BENCHES]
    paths += [ROOT / "tools/effects_reference.py", ROOT / "tools/check_effects.py",
              ROOT / "sim/run_effects.ps1", ROOT / "tools/send_uart_command.ps1"]
    paths += sorted(scripts.glob("effect_*.txt"))
    result = dict(created_at=datetime.now(timezone(timedelta(hours=8))).isoformat(),
                  tests=logs, bit_exact_samples=len(samples), screen_packet_cases=105,
                  shared_ram_bytes=16384, fixed_pipeline_audio_frames=1,
                  unchanged_from_backup={name: sha(ROOT / name) for name in preserved},
                  inputs={p.relative_to(ROOT).as_posix(): sha(p) for p in paths},
                  synthesis_run=False, pnr_run=False, hardware_tested=False,
                  screen_ide_compiled=False)
    if args.full_regression:
        suites = {}
        for name, count in (("pressure", 9), ("upload", 11), ("marimba", 5),
                            ("waterfall", 6), ("analysis", 13)):
            path = OUT / (name + "_final.log")
            text = path.read_text(errors="replace")
            assert text.count("# vsim -c ") == count, f"Incomplete {name} suite"
            assert text.count("# PASS") >= count and "** Fatal" not in text, name
            assert not re.search(r"# Errors: [1-9]", text), name
            suites[name] = dict(configurations=count, log_sha256=sha(path))
        result["full_regression"] = suites
        result["total_simulation_configurations"] = len(logs) + sum(
            suite["configurations"] for suite in suites.values())
    (OUT / "verification.json").write_text(json.dumps(result, indent=2) + "\n", encoding="ascii")
    print(f"PASS: {len(logs)} effects/UART/integration benches, {len(samples)} bit-exact samples, "
          "105 screen packets; RTL WAV exports; no synthesis/PnR or screen-IDE compilation")


if __name__ == "__main__":
    main()
