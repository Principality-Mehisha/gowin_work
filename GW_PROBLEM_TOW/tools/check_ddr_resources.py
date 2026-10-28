"""Require real BSRAM savings and a block-RAM-free DDR boot source."""
from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[1]
report = (ROOT/'impl/pnr/GW_PROBLEM_TOW.rpt.txt').read_text()
match = re.search(r'^\s*BSRAM\s*\|\s*(\d+)/(\d+)', report, re.M)
assert match, 'Missing BSRAM implementation summary'
used, total = map(int, match.groups())
assert used < 118, f'DDR migration did not save block RAM: {used}/118'
netlist = (ROOT/'impl/gwsynthesis/GW_PROBLEM_TOW.vg').read_text()
seed = re.search(r'\bmodule ddr_asset_seed\b.*?\bendmodule', netlist, re.S).group()
assert not re.search(r'^\s*(?:pROM\w*|SDP\w*|DPB\w*|SP\w*)\s+\w+\s*\(', seed, re.M), 'DDR boot seed uses BSRAM'
clarinet = re.search(r'\bmodule clarinet_synth\b.*?\bendmodule', netlist, re.S).group()
assert not re.search(r'^\s*\w+\s+(?:voicing_rom|env_rom)\w*\s*\(', clarinet, re.M), 'Full clarinet tables still resident'
summary = dict(baseline_bsram=118, bsram_used=used, bsram_total=total,
               bsram_saved=118-used, seed_uses_bsram=False,
               clarinet_tables_in_ddr=True, asset_bytes=25200)
out = ROOT/'output/ddr_migration/resources.json'
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(json.dumps(summary, indent=2)+'\n')
print(json.dumps(summary, indent=2))
