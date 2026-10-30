"""Independent complex FFT cross-check plus exact fixed-point reference vectors."""
from pathlib import Path
import cmath
import math
import random
from generate_analysis_tables import tables

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT/'output/piano_analysis'


def floating_fft(x):
    if len(x) == 1:
        return x
    a, b = floating_fft(x[::2]), floating_fft(x[1::2])
    t = [cmath.exp(-2j*math.pi*k/len(x))*v for k, v in enumerate(b)]
    return [u+v for u, v in zip(a, t)] + [u-v for u, v in zip(a, t)]


def fixed_fft(x):
    window, twiddle = tables()
    a = [(v*w >> 15, 0) for v, w in zip(x, window)]
    a = [a[int(f'{i:010b}'[::-1], 2)] for i in range(1024)]
    for stage in range(10):
        half = 1 << stage
        for base in range(0, 1024, half*2):
            for j in range(half):
                word = twiddle[j*512//half]
                c, s = word >> 16, word & 65535
                c = c-65536 if c >= 32768 else c
                s = s-65536 if s >= 32768 else s
                ar, ai = a[base+j]
                br, bi = a[base+j+half]
                tr, ti = (br*c-bi*s) >> 15, (br*s+bi*c) >> 15
                a[base+j] = ((ar+tr) >> 1, (ai+ti) >> 1)
                a[base+j+half] = ((ar-tr) >> 1, (ai-ti) >> 1)
    reference = floating_fft([v*w/32768 for v, w in zip(x, window)])
    assert max(abs(complex(*v)-f/1024) for v, f in zip(a, reference)) < 20
    return a


def packed_frame(x):
    a = fixed_fft(x)
    result = []
    previous = 256
    for i, (r, im) in enumerate(a[:512]):
        magnitude = abs(r)+abs(im)
        top = max(0, magnitude.bit_length()-1)
        fraction = (magnitude >> (top-4) if top >= 4 else magnitude << (4-top)) & 15
        level = top*16+fraction
        height = min(511, max(0, (level-48)*3))
        y = min(511, 256-(x[i] >> 7))
        result.append((min(y, previous) << 19) | (max(y, previous) << 10) | height)
        previous = y
    return result


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    rng = random.Random(4917)
    vectors = [[0]*1024,
               [round(24000*math.sin(2*math.pi*32*n/1024)) for n in range(1024)],
               [round(12000*math.sin(2*math.pi*17*n/1024)+7000*math.sin(2*math.pi*81*n/1024)) for n in range(1024)],
               [12000]*1024,
               [32767 if n % 2 == 0 else -32768 for n in range(1024)],
               [0]+[rng.randint(-30000, 30000) for _ in range(1023)]]
    (OUT/'input.hex').write_text(''.join(f'{v & 65535:04x}\n' for x in vectors for v in x))
    packed = [p for x in vectors for p in packed_frame(x)]
    (OUT/'expected.hex').write_text(''.join(f'{p:08x}\n' for p in packed))
    print('PASS: six FFT/wave fixtures, independently checked against complex floating FFT')


if __name__ == '__main__':
    main()
