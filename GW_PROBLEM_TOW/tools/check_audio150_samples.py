"""Independent native-rate marimba arithmetic and sine-frequency checks."""
from pathlib import Path
import json
import math
import struct
import wave

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "output/audio150"
FS = 150_000_000 / 3072


def signed(value):
    return value-65536 if value >= 32768 else value


def load(name):
    return [signed(int(word, 16)) for word in (OUT/name).read_text().split()]


def marimba_reference(frames):
    row = int((ROOT/"src/rom/marimba48_48828.hex").read_text().split()[33], 16)
    attack = int((ROOT/"src/rom/marimba_attack48.hex").read_text().split()[33], 16)
    sine = [signed(int(word, 16)) for word in (ROOT/"src/rom/sine256.hex").read_text().split()]
    modes = [((row >> (i*64+32)) & 0xffffffff, (row >> (i*64+16)) & 65535,
              (row >> (i*64)) & 65535) for i in range(4)]
    phase, level = [0]*4, [mode[1] for mode in modes]
    noise, noise_step, lfsr = attack >> 16, attack & 65535, 0x1a9f+69
    r11 = r12 = r21 = r22 = peak = 0
    result = []
    for frame in range(frames):
        control = frame % 3 == 0
        mixed = 0
        for i, (step, _, decay) in enumerate(modes):
            if not level[i]:
                continue
            index, fraction = phase[i] >> 24, (phase[i] >> 16) & 255
            value = sine[index] + ((sine[(index+1)&255]-sine[index])*fraction >> 8)
            mixed += ((value*(level[i]&32767) >> 15)*(192 if i == 0 else 144)) >> 8
            if control:
                level[i] = level[i]*(decay&32767) >> 15
            phase[i] = (phase[i]+step) & 0xffffffff
        if noise:
            mixed += (((lfsr&255)-128)*(noise&32767) >> 7)*144 >> 8
            if control:
                noise = max(0, noise-noise_step)
            feedback = ((lfsr >> 15) ^ (lfsr >> 13) ^ (lfsr >> 12) ^ (lfsr >> 10)) & 1
            lfsr = ((lfsr << 1) | feedback) & 65535
            if not lfsr:
                lfsr = 0x1ace
        r1 = (mixed*118 >> 14) + (r11*31946 >> 14) - (r12*15610 >> 14)
        r2 = (mixed*62 >> 14) + (r21*31264 >> 14) - (r22*15046 >> 14)
        r12, r11, r22, r21 = r11, r1, r21, r2
        body = mixed + (r1 >> 2) + (r2 >> 3)
        sample = (body+(1 if body < 0 else 2)) >> 2
        released = max(0, peak-max(1, peak >> 12)) if control else peak
        peak = max(abs(sample), released)
        gain = (30000 << 20)//peak if peak > 30000 else 1 << 20
        product = sample*gain
        result.append((product+(524287 if product < 0 else 524288)) >> 20)
    return result


def amplitude(values, frequency):
    count = len(values)
    windowed = [value*(.5-.5*math.cos(2*math.pi*i/(count-1))) for i, value in enumerate(values)]
    omega = 2*math.pi*frequency/FS
    re = sum(value*math.cos(omega*i) for i, value in enumerate(windowed))
    im = sum(value*math.sin(omega*i) for i, value in enumerate(windowed))
    return math.hypot(re, im)


def main():
    piano, marimba, c8 = load("piano_a4.hex"), load("marimba_a4.hex"), load("piano_c8.hex")
    assert len(piano) == len(marimba) == 4096 and len(c8) == 2048
    expected = marimba_reference(len(marimba))
    if marimba != expected:
        index = next(i for i, (a, b) in enumerate(zip(marimba, expected)) if a != b)
        raise AssertionError(f"Native marimba sample {index}: {marimba[index]} != {expected[index]}")
    tail = piano[-2048:]
    frequencies = [438+i*.05 for i in range(81)]
    peak_hz = max(frequencies, key=lambda f: amplitude(tail, f))
    assert abs(peak_hz-440) < .5, peak_hz
    c8_hz = 440*2**((108-69)/12)
    harmonic_ratio = amplitude(c8[-1024:], 2*c8_hz)/amplitude(c8[-1024:], c8_hz)
    assert harmonic_ratio > .03, "No independently synthesized C8 harmonic above old 8.138 kHz Nyquist"
    for name, values in (("piano_a4", piano), ("marimba_a4", marimba), ("piano_c8", c8)):
        with wave.open(str(OUT/(name+".wav")), "wb") as w:
            w.setparams((1, 2, round(FS), 0, "NONE", "not compressed"))
            w.writeframes(struct.pack("<"+"h"*len(values), *values))
    metrics = dict(sample_rate_hz=FS, marimba_bit_exact_samples=len(marimba),
                   piano_a4_peak_hz=peak_hz, c8_fundamental_hz=c8_hz,
                   c8_second_harmonic_hz=2*c8_hz, c8_second_to_fundamental=harmonic_ratio)
    (OUT/"sample_measurements.json").write_text(json.dumps(metrics, indent=2)+"\n", encoding="ascii")
    print(f"PASS: 4096 native marimba samples bit-exact; A4={peak_hz:.2f} Hz; "
          f"C8 harmonic {2*c8_hz:.1f} Hz present, ratio={harmonic_ratio:.3f}; RTL WAV exports")


if __name__ == "__main__":
    main()
