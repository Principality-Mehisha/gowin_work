"""Record the exact inputs belonging to a successful, timing-checked build."""
from pathlib import Path
from datetime import datetime, timezone, timedelta
import hashlib
import json
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]

def main():
    project = ET.parse(ROOT/'GW_PROBLEM_TOW.gprj')
    inputs = [ROOT/'GW_PROBLEM_TOW.gprj'] + [ROOT/f.attrib['path']
        for f in project.findall('./FileList/File') if f.attrib.get('enable') == '1']
    inputs += sorted((ROOT/'src/rom').glob('*.hex'))
    bitstream = ROOT/'impl/pnr/GW_PROBLEM_TOW.fs'
    timing = json.loads((ROOT/'sim/timing_report.json').read_text())
    assert timing['Numbers of Setup Violated Endpoints'] == 0
    assert timing['Numbers of Hold Violated Endpoints'] == 0
    assert timing['fmax_mhz'] >= timing['target_mhz']
    manifest = dict(created_at=datetime.now(timezone(timedelta(hours=8))).isoformat(),
        timing=timing, bitstream=bitstream.relative_to(ROOT).as_posix(),
        bitstream_sha256=hashlib.sha256(bitstream.read_bytes()).hexdigest(),
        inputs={p.relative_to(ROOT).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in inputs})
    out = ROOT/'output/build_manifest.json'
    out.parent.mkdir(parents=True,exist_ok=True)
    out.write_text(json.dumps(manifest,indent=2),encoding='utf-8')
    print('PASS: build input and bitstream hashes saved to output/build_manifest.json')

if __name__ == '__main__':
    main()
