"""Preserve the user's 106-BSRAM build and frozen timing-refactor references."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import zipfile

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "output/timing150/before"


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    archive = OUT / "sources.zip"
    assert not archive.exists(), "Never replace the pre-refactor reference"
    paths = [ROOT / "GW_PROBLEM_TOW.gprj", ROOT / "README.md", ROOT / "VERIFICATION.md"]
    for folder in ("src", "tools", "sim", "docs", "ip"):
        paths += [p for p in (ROOT / folder).rglob("*") if p.is_file()
                  and not any(s in ("vendor", "temp", "__pycache__") for s in p.parts)
                  and p.suffix in (".v", ".vo", ".sv", ".vh", ".py", ".ps1", ".tcl",
                                   ".md", ".json", ".hex", ".cst", ".sdc", ".ipc", ".mod")]
    paths += [ROOT / name for name in (
        "impl/pnr/GW_PROBLEM_TOW.rpt.txt", "impl/pnr/GW_PROBLEM_TOW_tr_content.html",
        "impl/pnr/GW_PROBLEM_TOW.timing_paths", "impl/gwsynthesis/GW_PROBLEM_TOW_syn_rsc.xml")]
    paths = sorted(set(paths))
    with zipfile.ZipFile(archive, "w", compression=zipfile.ZIP_DEFLATED) as z:
        for p in paths:
            z.write(p, p.relative_to(ROOT).as_posix())
    for name in ("audio_effects", "instrument_voice_bank", "audio_domain_bridge"):
        text = (ROOT / "src/audio" / (name + ".v")).read_text()
        text = re.sub(r"\bmodule\s+" + name + r"\b", "module " + name + "_before", text)
        (OUT / (name + "_before.v")).write_text(text, encoding="ascii")
    bitstream = ROOT / "impl/pnr/GW_PROBLEM_TOW.fs"
    shutil.copy2(bitstream, OUT / "GW_PROBLEM_TOW.fs")
    info = dict(inputs={p.relative_to(ROOT).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest()
                        for p in paths},
                bitstream_sha256=hashlib.sha256(bitstream.read_bytes()).hexdigest())
    (OUT / "inputs.json").write_text(json.dumps(info, indent=2) + "\n", encoding="ascii")
    print("PASS: pre-timing source/report archive, frozen references and user bitstream preserved")


if __name__ == "__main__":
    main()
