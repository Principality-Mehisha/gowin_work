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
locations = re.findall(r'IO_LOC\s+"([^"]+)"\s+([^;]+);', cst)
pins = [pin.strip() for _, values in locations for pin in values.split(',')]
assert len(pins) == len(set(pins)), 'Duplicate physical pin assignment'
assert len(locations) == len({port for port, _ in locations}), 'Duplicate port assignment'
pressure_pins = dict(zip(
    [f'ADC_DATA[{bit}]' for bit in range(11, -1, -1)],
    'E14 C15 B13 A14 B16 A16 A20 A21 E13 C14 C13 A13'.split()))
pressure_pins.update(dict(zip(
    ['S[3]', 'S[2]', 'S[1]', 'S[0]', 'S_EN', 'CLK_500kHz'] +
    [f'pitch_group[{bit}]' for bit in range(6, -1, -1)],
    'F13 E16 D14 A18 D17 B15 F16 F15 D20 E19 C18 C17 A19'.split())))
assert all(dict(locations).get(port) == pin for port, pin in pressure_pins.items()), 'Pressure pin mismatch'
led_pins = dict(zip([f'LEDs[{bit}]' for bit in range(8)],
                    'AB20 AA19 AA21 AA20 AB22 AB21 Y22 Y21'.split()))
assert all(dict(locations).get(port) == pin for port, pin in led_pins.items()), 'Eight-LED pin mismatch'
assert dict(locations).get('LED_indicator_dynamic') == 'C19', 'Dynamic guide pin mismatch'
assert re.search(r'IO_PORT\s+"LED_indicator_dynamic"\s+[^;]*IO_TYPE=LVCMOS33[^;]*BANK_VCCIO=3\.3;',
                 cst), 'Dynamic guide must use 3.3 V I/O'
for name in ('src/board/GW_PROBLEM_TOW.v', 'src/board/piano_score_player.v',
             'src/system/instrument_system.v'):
    assert re.search(r'output\s+wire\s+\[7:0\]\s+LEDs\b', (ROOT/name).read_text()), \
        f'LED bus must remain eight bits end-to-end: {name}'
subprocess.run([sys.executable, str(ROOT/'tools/generate_analysis_tables.py'), '--check'], check=True)
subprocess.run([sys.executable, str(ROOT/'tools/generate_numbered_buttons.py'), '--check'], check=True)
print(f'PASS: {len(rtl)} active RTL files, five audio ROMs, 200 numbered slots/buttons, no legacy reader, both UARTs, pressure/group pins, eight LEDs and C19/3.3 V dynamic guide without collisions')
