"""Validate active project inputs, score encodings and pin constraints."""
from pathlib import Path
import re
import struct
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
for name,magic,low,high in [('ANDROID.BIN',b'M42S',36,83),('RINGTONE.BIN',b'M42S',36,83),('PIANO.BIN',b'P88S',0,87)]:
    data = (ROOT/'sd_card'/name).read_bytes()
    header = struct.unpack('<4sBBBBII',data[:16])
    assert header[:6] == (magic,1,8,8,0,1000), name
    assert len(data) == 16+8*header[6] and header[6]>0, name
    records = [struct.unpack_from('<IBBBB',data,i) for i in range(16,len(data),8)]
    assert records[-1][1:] == (255,255,0,0), name
    assert all(a[0]<=b[0] for a,b in zip(records,records[1:])), name
    assert all(slot<8 and low<=note<=high and vel<128 and reserved==0 for _,slot,note,vel,reserved in records[:-1]), name
cst = (ROOT/'src/board/GW_PROBLEM_TOW.cst').read_text()
assert 'IO_LOC "uart_rx" B17;' in cst and 'IO_LOC "uart_tx" B18;' in cst
assert 'IO_LOC "bt_rx" D16;' in cst and 'IO_LOC "bt_tx" D15;' in cst
subprocess.run([sys.executable, str(ROOT/'tools/generate_video_score.py'), '--check'], check=True)
subprocess.run([sys.executable, str(ROOT/'tools/generate_analysis_tables.py'), '--check'], check=True)
subprocess.run([sys.executable, str(ROOT/'tools/generate_numbered_buttons.py'), '--check'], check=True)
print(f'PASS: {len(rtl)} active RTL files, five audio ROMs, video ROM, three legacy scores, 200 buttons and both UART pin pairs')
