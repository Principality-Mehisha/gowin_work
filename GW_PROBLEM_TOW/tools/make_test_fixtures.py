"""Generate SD/FAT test inputs from committed scores without rewriting SD files."""
from pathlib import Path
import struct
from fat_test_fixtures import build, save_hex, save_full_fat32
from make_uart_fixtures import main as make_uart
from make_nocturne_fixtures import main as make_nocturne

ROOT = Path(__file__).resolve().parents[1]

def main():
    out = ROOT / 'output/score_test'
    out.mkdir(parents=True, exist_ok=True)
    data = (ROOT / 'sd_card/PIANO.BIN').read_bytes()
    events = [data[i:i+8] for i in range(16, len(data), 8)]
    (out/'events.hex').write_text(''.join(f'{int.from_bytes(e,"little"):016x}\n' for e in events))
    (out/'params.vh').write_text(f'`define SCORE_EVENTS {len(events)}\n`define SCORE_BYTES {len(data)}\n')
    save_full_fat32(data, output=out/'full.img', filename=b'PIANO   BIN')
    short_events = [(0,0,39,127,0),(0,1,43,100,0),(0,2,46,80,0),
                    (35,0,39,0,0),(35,1,43,0,0),(35,2,46,0,0),
                    (50,0,39,110,0),(80,0,39,0,0),(100,255,255,0,0)]
    short = struct.pack('<4sBBBBII',b'P88S',1,8,8,0,1000,len(short_events)) + b''.join(
        struct.pack('<IBBBB', *e) for e in short_events)
    for fat in (False, True):
        save_hex(out/('fat32.hex' if fat else 'fat16.hex'),build(fat,short))
    save_hex(out/'missing.hex',build(False,short,missing=True))
    save_hex(out/'wrong_format.hex',build(False,b'RIFF'+short[4:]))
    out = ROOT/'output/ringtone_test'
    out.mkdir(parents=True, exist_ok=True)
    data = (ROOT/'sd_card/ANDROID.BIN').read_bytes()
    events = [struct.unpack_from('<IBBBB',data,i) for i in range(16,len(data),8)]
    for fat in (False,True):
        save_hex(out/('fat32.hex' if fat else 'fat16.hex'),build(fat,data,filename=b'ANDROID BIN'))
    save_hex(out/'missing.hex',build(False,data,missing=True,filename=b'ANDROID BIN'))
    save_hex(out/'wrong_format.hex',build(False,b'P88S'+data[4:],filename=b'ANDROID BIN'))
    bad = bytearray(data); bad[21] = 35
    save_hex(out/'bad_note.hex',build(False,bytes(bad),filename=b'ANDROID BIN'))
    frames = (events[-1][0]*50000000+3072000-1)//3072000
    (out/'params.vh').write_text(f'`define RINGTONE_EVENTS {len(events)}\n`define RINGTONE_NOTE_ONS {sum(e[3]>0 for e in events)}\n`define RINGTONE_FRAMES {frames}\n')
    (out/'events.hex').write_text(''.join(f'{int.from_bytes(struct.pack("<IBBBB",*e),"little"):016x}\n' for e in events))
    make_uart()
    make_nocturne()
    print('PASS: piano, ringtone, clarinet and UART fixtures generated from current SD scores')

if __name__ == '__main__':
    main()
