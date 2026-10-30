"""Check actual-piano FFT output and every RGB pixel against an independent scene."""
from pathlib import Path
import struct
import sys
import zlib
from make_analysis_fixtures import packed_frame

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT/'output/piano_analysis'
FONT = {
 'A':'01110 10001 10001 11111 10001 10001 10001',
 'C':'01111 10000 10000 10000 10000 10000 01111',
 'E':'11111 10000 10000 11110 10000 10000 11111',
 'F':'11111 10000 10000 11110 10000 10000 10000',
 'G':'01111 10000 10000 10111 10001 10001 01110',
 'H':'10001 10001 10001 11111 10001 10001 10001',
 'I':'11111 00100 00100 00100 00100 00100 11111',
 'K':'10001 10010 10100 11000 10100 10010 10001',
 'L':'10000 10000 10000 10000 10000 10000 11111',
 'M':'10001 11011 10101 10101 10001 10001 10001',
 'N':'10001 11001 10101 10011 10001 10001 10001',
 'O':'01110 10001 10001 10001 10001 10001 01110',
 'P':'11110 10001 10001 11110 10000 10000 10000',
 'R':'11110 10001 10001 11110 10100 10010 10001',
 'S':'01111 10000 10000 01110 00001 00001 11110',
 'T':'11111 00100 00100 00100 00100 00100 00100',
 'U':'10001 10001 10001 10001 10001 10001 01110',
 'V':'10001 10001 10001 10001 10001 01010 00100',
 'W':'10001 10001 10001 10101 10101 10101 01010',
 'Z':'11111 00001 00010 00100 01000 10000 11111',
 '0':'01110 10001 10011 10101 11001 10001 01110',
 '1':'00100 01100 00100 00100 00100 00100 01110',
 '2':'01110 10001 00001 00010 00100 01000 11111',
 '3':'11110 00001 00001 01110 00001 00001 11110',
 '4':'00010 00110 01010 10010 11111 00010 00010',
 '5':'11111 10000 10000 11110 00001 00001 11110',
 '6':'01110 10000 10000 11110 10001 10001 01110',
 '7':'11111 00001 00010 00100 01000 01000 01000',
 '8':'01110 10001 10001 01110 10001 10001 01110',
 '9':'01110 10001 10001 01111 00001 00001 01110',
 '/':'00001 00001 00010 00100 01000 10000 10000',
}


def png(path, data, width, height):
    def chunk(tag, payload):
        return struct.pack('>I', len(payload))+tag+payload+struct.pack('>I', zlib.crc32(tag+payload))
    rows = b''.join(b'\0'+data[y*width*3:(y+1)*width*3] for y in range(height))
    path.write_bytes(b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR', struct.pack('>IIBBBBB', width, height, 8, 2, 0, 0, 0))+
                     chunk(b'IDAT', zlib.compress(rows))+chunk(b'IEND', b''))


def reference(mode, points):
    image = bytearray(bytes.fromhex('0b1020')*(1600*900))
    def put(x, y, color):
        i = (y*1600+x)*3
        image[i:i+3] = color.to_bytes(3, 'big')
    image[:144*1600*3] = bytes.fromhex('101b30')*(144*1600)
    for y in range(191, 705):
        for x in range(287, 1313):
            if x in (287, 1312) or y in (191, 704):
                color = 0x586e8d
            else:
                gx, gy = x-288, y-192
                color = 0x24344e if gx % 256 == 0 or gy % 128 == 0 else 0x0e182a
                word = points[gx//2]
                if mode == 1:
                    height = word & 1023
                    if height and gy >= 512-height:
                        color = 0x37b9d8 if gx % 2 else 0x8be5ff
                else:
                    if gy == 256:
                        color = 0x43566e
                    if ((word >> 19) & 511) <= gy <= ((word >> 10) & 511):
                        color = 0x70edac
            put(x, y, color)
    axis = {0:'0',16:'2',17:'K',32:'4',33:'K',48:'6',49:'K',62:'8',63:'K',65:'H',66:'Z'} if mode == 1 else {
            0:'0',16:'8',32:'1',33:'6',48:'2',49:'4',62:'3',63:'1',65:'M',66:'S'}
    labels = [(96, dict(enumerate('PIANO SPECTRUM' if mode == 1 else 'PIANO WAVEFORM'))),
              (736, axis), (800, dict(enumerate('1024 FFT / HANN   LOG' if mode == 1 else '512  SAMPLES / 31 MS')))]
    for top, letters in labels:
        for index, letter in letters.items():
            for row, bits in enumerate(FONT.get(letter, '').split()):
                for col, bit in enumerate(bits):
                    if bit == '1':
                        for dy in range(2):
                            for dx in range(2):
                                put(288+index*16+col*2+dx, top+row*2+dy, 0x9aeaff if mode == 1 else 0x9ef5bc)
    return image


def main():
    samples = [int(x, 16) for x in (OUT/'piano_input.hex').read_text().split()]
    samples = [v-65536 if v >= 32768 else v for v in samples]
    actual = [int(x, 16) for x in (OUT/'piano_result.hex').read_text().split()]
    assert len(samples) == 1024 and len(actual) == 512
    assert actual == packed_frame(samples), 'Actual piano/DAC analysis differs from reference'
    (OUT/'render_data.hex').write_text(''.join(f'{v:08x}\n' for v in actual))
    print('PASS: actual UART C4 piano PCM -> 512 exact waveform/spectrum rows')
    if '--prepare-render' in sys.argv:
        return
    previews = []
    for mode, name in enumerate(('spectrum', 'waveform'), 1):
        content = (OUT/(name+'.ppm')).read_bytes()
        header = b'P6\n1600 900\n255\n'
        assert content.startswith(header)
        pixels = content[len(header):]
        expected = reference(mode, actual)
        assert len(pixels) == 1600*900*3, (name, len(pixels))
        if pixels != expected:
            mismatches = [i//3 for i, (a, b) in enumerate(zip(pixels, expected)) if a != b][:10]
            raise AssertionError(f'{name}: pixel mismatch at {[(p%1600,p//1600) for p in mismatches]}')
        png(OUT/(name+'.png'), pixels, 1600, 900)
        previews.append(b''.join(pixels[(y*1600+x)*3:(y*1600+x)*3+3]
                                 for y in range(0, 900, 2) for x in range(0, 1600, 2)))
        print(f'PASS: {name}, all 1,440,000 RTL RGB pixels match independent geometry/font reference')
    png(OUT/'preview.png', b''.join(previews), 800, 900)


if __name__ == '__main__':
    main()
