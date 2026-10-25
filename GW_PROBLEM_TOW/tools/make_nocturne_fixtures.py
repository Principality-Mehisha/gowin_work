"""Generate full C45S events and short FAT16/FAT32 fixtures from CLARINET.BIN."""
from pathlib import Path
import struct
from fat_test_fixtures import build, save_hex
from make_clarinet_nocturne import validate_score

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'output/nocturne'


def main():
    OUT.mkdir(parents=True,exist_ok=True)
    data=(ROOT/'sd_card/CLARINET.BIN').read_bytes();validate_score(data)
    events=[struct.unpack_from('<IBBBB',data,i) for i in range(16,len(data),8)]
    (OUT/'score_bytes.hex').write_text('\n'.join(f'{b:02x}' for b in data)+'\n',encoding='ascii')
    (OUT/'events.hex').write_text(''.join(f'{int.from_bytes(struct.pack("<IBBBB",*e),"little"):016x}\n' for e in events),encoding='ascii')
    frames=(events[-1][0]*50000000+3072000-1)//3072000
    (OUT/'params.vh').write_text(f'`define NOCTURNE_BYTES {len(data)}\n`define NOCTURNE_EVENTS {len(events)}\n`define NOCTURNE_FRAMES {frames}\n',encoding='ascii')
    notes=[e for e in events if e[1]!=255 and e[3]][:2]
    short_events=[(0,0,notes[0][2],notes[0][3],0),(100,0,notes[0][2],0,0),
                  (200,0,notes[1][2],notes[1][3],0),(300,0,notes[1][2],0,0),
                  (700,255,255,0,0)]
    short=data[:12]+struct.pack('<I',5)+b''.join(struct.pack('<IBBBB',*e) for e in short_events)
    for fat in (False,True):
        save_hex(OUT/('fat32.hex' if fat else 'fat16.hex'),build(fat,short,filename=b'CLARINETBIN'))
    save_hex(OUT/'missing.hex',build(False,short,filename=b'CLARINETBIN',missing=True))
    save_hex(OUT/'wrong_magic.hex',build(False,b'M42S'+short[4:],filename=b'CLARINETBIN'))
    for name,offset,value in [('low_note',21,49),('high_note',21,95),('wrong_slot',20,1)]:
        bad=bytearray(short);bad[offset]=value
        save_hex(OUT/(name+'.hex'),build(False,bytes(bad),filename=b'CLARINETBIN'))
    print(f'PASS: full C45S fixture ({len(events)} events) and seven SD cases')


if __name__=='__main__':main()
