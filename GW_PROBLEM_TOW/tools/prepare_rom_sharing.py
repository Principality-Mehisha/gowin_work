"""Archive the working inputs and generate frozen, renamed comparison modules."""
from pathlib import Path
import hashlib
import json
import re
import zipfile

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "output/rom_sharing/before"


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    archive = OUT / "sources.zip"
    assert not archive.exists(), "Baseline already exists; never replace the working reference"
    paths = [ROOT / "GW_PROBLEM_TOW.gprj", ROOT / "README.md", ROOT / "VERIFICATION.md"]
    for folder in ("src", "tools", "sim", "docs", "ip"):
        paths += [p for p in (ROOT / folder).rglob("*") if p.is_file()
                  and not any(part in ("__pycache__", "vendor", "temp") for part in p.parts)
                  and p.suffix in (".v", ".vo", ".sv", ".vh", ".py", ".ps1", ".tcl",
                                   ".md", ".json", ".hex", ".cst", ".sdc", ".ipc", ".mod")]
    paths += [ROOT / name for name in (
        "impl/pnr/GW_PROBLEM_TOW.rpt.txt", "impl/pnr/GW_PROBLEM_TOW_tr_content.html",
        "impl/gwsynthesis/GW_PROBLEM_TOW_syn_rsc.xml")]
    paths = sorted(set(paths))
    with zipfile.ZipFile(archive, "w", compression=zipfile.ZIP_DEFLATED) as backup:
        for path in paths:
            backup.write(path, path.relative_to(ROOT).as_posix())
    names = ("piano_synth", "marimba_synth", "instrument_voice_bank")
    for name in names:
        text = (ROOT / "src/audio" / (name + ".v")).read_text()
        text = re.sub(r"\b(" + "|".join(names) + r")\b", lambda m: m[0] + "_before", text)
        (OUT / (name + "_before.v")).write_text(text, encoding="ascii")
    info = dict(inputs={p.relative_to(ROOT).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest()
                        for p in paths})
    bitstream = ROOT / "impl/pnr/GW_PROBLEM_TOW.fs"
    info["user_built_bitstream_sha256"] = hashlib.sha256(bitstream.read_bytes()).hexdigest()
    (OUT / "inputs.json").write_text(json.dumps(info, indent=2) + "\n", encoding="ascii")
    print("PASS: working-source/report archive and three frozen comparison modules prepared")


if __name__ == "__main__":
    main()
