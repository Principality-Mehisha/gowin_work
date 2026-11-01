"""Validate active project inputs, score encodings and pin constraints."""
from pathlib import Path
import re
import xml.etree.ElementTree as ET
import subprocess
import sys
ROOT = Path(__file__).resolve().parents[1]
project = ET.parse(ROOT/'GW_PROBLEM_TOW.gprj')
entries = [f.attrib['path'] for f in project.findall('./FileList/File') if f.attrib.get('enable') == '1']
assert len(entries) == len(set(entries)), 'Duplicate project entries'
assert all((ROOT/p).is_file() for p in entries), 'Missing project input'
rtl = {p for p in entries if p.endswith('.v')}
assert rtl == {p.relative_to(ROOT).as_posix() for p in (ROOT/'src').rglob('*.v')}, 'Unlisted or obsolete RTL'
expected = {'sine256.hex':(256,4), 'frequency88.hex':(88,8), 'voicing88.hex':(88,35),
            'marimba48.hex':(48,64), 'marimba_attack48.hex':(48,8)}
assert {p.name for p in (ROOT/'src/rom').iterdir()} == set(expected), 'Unexpected ROM'
for name,(count,width) in expected.items():
    rows = (ROOT/'src/rom'/name).read_text().split()
    assert len(rows) == count and all(re.fullmatch(r'[0-9a-fA-F]{'+str(width)+'}',r) for r in rows), name
for row in (ROOT/'src/rom/marimba48.hex').read_text().split():
    assert all(((int(row,16) >> (mode*64+32)) & 0xffffffff) < 0x80000000 for mode in range(4)), 'Nyquist'
assert not (ROOT/'src/storage/fat_file_reader.v').exists(), 'Obsolete legacy file-search module'
cst = (ROOT/'src/board/GW_PROBLEM_TOW.cst').read_text()
assert 'IO_LOC "uart_rx" B17;' in cst and 'IO_LOC "uart_tx" B18;' in cst
assert 'IO_LOC "bt_rx" D16;' in cst and 'IO_LOC "bt_tx" D15;' in cst
subprocess.run([sys.executable, str(ROOT/'tools/generate_analysis_tables.py'), '--check'], check=True)
subprocess.run([sys.executable, str(ROOT/'tools/generate_numbered_buttons.py'), '--check'], check=True)
print(f'PASS: {len(rtl)} active RTL files, five audio ROMs, 200 numbered slots/buttons, no legacy file reader and both UART pin pairs')
