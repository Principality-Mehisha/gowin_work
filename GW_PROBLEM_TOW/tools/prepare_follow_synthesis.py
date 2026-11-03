"""Prepare an isolated synthesis project without changing deployed build outputs."""
from pathlib import Path
import shutil
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "output/follow_guide/synthesis"
OUT.mkdir(parents=True, exist_ok=True)
project = ET.parse(ROOT / "GW_PROBLEM_TOW.gprj")
for entry in project.findall("./FileList/File"):
    entry.set("path", (ROOT / entry.attrib["path"]).as_posix())
project.write(OUT / "follow_guide.gprj", encoding="UTF-8", xml_declaration=True)
for path in (ROOT / "src").rglob("*.hex"):
    target = OUT / path.relative_to(ROOT)
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(path, target)
(OUT / "run.tcl").write_text(
    'set isolated_dir [file normalize [file dirname [info script]]]\n'
    'cd $isolated_dir\n'
    'open_project [file join $isolated_dir follow_guide.gprj]\n'
    'set_option -top_module GW_PROBLEM_TOW\n'
    'run syn\n'
    'exit\n', encoding="ascii")
print(OUT / "run.tcl")
