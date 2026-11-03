"""Audit exact ROM-sharing comparisons without running main synthesis/PnR."""
from datetime import datetime, timezone, timedelta
from pathlib import Path
import hashlib
import json
import re
import xml.etree.ElementTree as ET
import zipfile

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "output/rom_sharing"
CHANGED = {"src/audio/piano_synth.v", "src/audio/marimba_synth.v",
           "src/audio/instrument_voice_bank.v"}
NEW = {"src/audio/sine_pair_rom.v"}
BENCHES = ("tb_sine_pair_rom", "tb_rom_sharing", "tb_marimba", "tb_instrument_bank")


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


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
    cases = {}
    pattern = (r"PASS ROM sharing RATE=(\d+): (\d+) exact samples, (\d+) packed parameters;"
               r".*?max piano=(\d+) marimba=(\d+) clocks")
    for rate, samples, parameters, piano, marimba in re.findall(pattern, texts["tb_rom_sharing"]):
        assert int(samples) >= 2704 and int(parameters) == 240
        assert int(piano) < 3072 and int(marimba) < 3072
        cases[rate] = dict(exact_samples=int(samples), parameter_checks=int(parameters),
                           max_piano_cycles=int(piano), max_marimba_cycles=int(marimba))
    assert set(cases) == {"1", "3"}
    assert "4096 exact" in texts["tb_sine_pair_rom"]

    preserved = {}
    reference_names = ("piano_synth", "marimba_synth", "instrument_voice_bank")
    with zipfile.ZipFile(OUT / "before/sources.zip") as backup:
        names = {n.replace("\\", "/"): n for n in backup.namelist()}
        hardware_suffixes = (".v", ".hex", ".cst", ".sdc")
        original = {n for n in names if n.startswith("src/") and Path(n).suffix in hardware_suffixes}
        current = {p.relative_to(ROOT).as_posix() for p in (ROOT / "src").rglob("*")
                   if p.is_file() and p.suffix in hardware_suffixes}
        assert current - original == NEW and not original - current
        for name in original - CHANGED:
            assert (ROOT / name).read_bytes() == backup.read(names[name]), name
            preserved[name] = sha(ROOT / name)
        before_project = ET.fromstring(backup.read(names["GW_PROBLEM_TOW.gprj"]))
        after_project = ET.parse(ROOT / "GW_PROBLEM_TOW.gprj").getroot()
        before_files = {tuple(sorted(n.attrib.items())) for n in before_project.findall("./FileList/File")}
        after_files = {tuple(sorted(n.attrib.items())) for n in after_project.findall("./FileList/File")}
        assert not before_files - after_files
        assert after_files - before_files == {
            tuple(sorted(dict(path="src/audio/sine_pair_rom.v", type="file.verilog", enable="1").items()))}
        for name in reference_names:
            text = backup.read(names["src/audio/" + name + ".v"]).decode()
            text = re.sub(r"\b(" + "|".join(reference_names) + r")\b",
                          lambda m: m[0] + "_before", text)
            assert (OUT / "before" / (name + "_before.v")).read_text().splitlines() == text.splitlines()
    baseline = json.loads((OUT / "before/inputs.json").read_text())
    assert sha(ROOT / "impl/pnr/GW_PROBLEM_TOW.fs") == baseline["user_built_bitstream_sha256"]
    for name in ("impl/pnr/GW_PROBLEM_TOW.rpt.txt", "impl/pnr/GW_PROBLEM_TOW_tr_content.html",
                 "impl/gwsynthesis/GW_PROBLEM_TOW_syn_rsc.xml"):
        assert sha(ROOT / name) == baseline["inputs"][name], "Main build/report was changed"
    paths = [ROOT / "GW_PROBLEM_TOW.gprj"] + [ROOT / n.attrib["path"] for n in
             ET.parse(ROOT / "GW_PROBLEM_TOW.gprj").findall("./FileList/File")
             if n.attrib.get("enable") == "1"]
    paths += sorted((ROOT / "src/rom").glob("*.hex"))
    paths += [ROOT / name for name in ("sim/tb_rom_sharing.sv", "sim/tb_marimba.sv",
              "sim/tb_instrument_bank.sv", "sim/run_rom_sharing.ps1", "sim/run_all.ps1",
              "sim/tb_audio150_core.sv", "sim/run_audio150.ps1",
              "tools/check_project.py", "tools/check_audio150_samples.py",
              "tools/prepare_rom_sharing.py", "tools/check_rom_sharing.py")]
    result = dict(
        created_at=datetime.now(timezone(timedelta(hours=8))).isoformat(),
        tests=logs, cases=cases, sine_pair_checks=4096, cycle_and_sample_exact=True,
        original_rom_files_unchanged=True, shared_sine_read_ports=2,
        packed_mode_words=192, packed_attack_words=48, parameter_word_bits=64,
        estimated_bsram_before=118, estimated_bsram_after=106, resource_estimate_only=True,
        source_backup_sha256=sha(OUT / "before/sources.zip"),
        changed_sources=sorted(CHANGED), new_sources=sorted(NEW),
        preserved_sources=preserved,
        inputs={p.relative_to(ROOT).as_posix(): sha(p) for p in paths},
        user_built_bitstream_untouched=True, synthesis_run=False, pnr_run=False,
        timing_verified=False, hardware_tested=False, final_compilation_owner="user",
    )
    (OUT / "verification.json").write_text(json.dumps(result, indent=2) + "\n", encoding="ascii")
    print("PASS: four ROM/compatibility benches; exact frozen-reference PCM and timing at both rates; "
          "six original ROMs and all other RTL/constraints preserved; main build untouched")


if __name__ == "__main__":
    main()
