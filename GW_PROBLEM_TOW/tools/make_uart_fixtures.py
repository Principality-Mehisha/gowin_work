"""Short three-file FAT fixtures; source SD scores are never modified."""
from pathlib import Path
import struct
import csv
import re
from fat_test_fixtures import build, save_hex

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'output/uart_test'

def excerpt(name):
    source = (ROOT / 'sd_card' / name).read_bytes()
    events = [struct.unpack_from('<IBBBB', source, i)
              for i in range(16, len(source), 8)]
    notes = [e for e in events if e[1] != 255 and e[3]][:2]
    short = [(0, 0, notes[0][2], notes[0][3], 0),
             (100, 0, notes[0][2], 0, 0),
             (200, 1, notes[1][2], notes[1][3], 0),
             (300, 1, notes[1][2], 0, 0), (700, 255, 255, 0, 0)]
    return source[:12] + struct.pack('<I', len(short)) + b''.join(
        struct.pack('<IBBBB', *e) for e in short)

def main():
    OUT.mkdir(parents=True,exist_ok=True)
    # Independent literal note names from the existing documented 88-key list.
    with (ROOT/'screen/tjc_uart/piano_88_notes.csv').open(encoding='utf-8-sig',newline='') as f:
        names=[row['Note'] for row in csv.DictReader(f)]
    assert len(names)==88 and names[0]=='A0' and names[-1]=='C8'
    assert all(re.fullmatch(r'[A-G]#?[0-8]',name) for name in names)
    (OUT/'note_names.vh').write_text(''.join(
        f'expected[{i}]="{name}";\n' for i,name in enumerate(names)),encoding='ascii')
    android = excerpt('ANDROID.BIN')
    apple = excerpt('RINGTONE.BIN')
    piano = excerpt('PIANO.BIN')
    (OUT/'expected.hex').write_text(''.join(
        f'{(event[3]*2<<8)|event[2]:04x}\n'
        for data in (android, apple, piano)
        for event in (struct.unpack_from('<IBBBB', data, i) for i in range(16,len(data),8))
        if event[1]!=255 and event[3]), encoding='ascii')
    # FAT16 root LBA41, second directory sector42, two sectors per cluster.
    sectors = build(False, android, filename=b'ANDROID BIN')
    for slot, cluster, name, payload in (
        (2, 10, b'RINGTONEBIN', apple), (3, 12, b'PIANO   BIN', piano)):
        root = sectors[42]
        offset = slot * 32
        root[offset:offset+11] = name
        root[offset+11] = 0x20
        struct.pack_into('<H', root, offset+26, cluster)
        struct.pack_into('<I', root, offset+28, len(payload))
        struct.pack_into('<H', sectors[1], cluster*2, 0xffff)
        lba = 43 + (cluster-2)*2
        sectors[lba] = bytearray(payload.ljust(512, b'\0'))
    save_hex(OUT/'three_scores.hex', sectors)
    missing = {k: bytearray(v) for k, v in sectors.items()}
    missing[42][64] = 0xe5
    save_hex(OUT/'missing_apple.hex', missing)
    bad = {k: bytearray(v) for k, v in sectors.items()}
    bad[59][:4] = b'P88S'
    save_hex(OUT/'bad_apple.hex', bad)
    print('PASS generated three-score FAT fixtures from existing score notes')

if __name__ == '__main__':
    main()
