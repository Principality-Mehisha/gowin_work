"""Measure real RTL output for every pitch and export an audition WAV."""
from pathlib import Path
import json
import math
import sys
import wave

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT/'output/marimba_tools'))
import numpy as np

FS = 50_000_000 / 3072
out = ROOT/'output/clarinet'
samples = np.loadtxt(out/'clarinet45_pcm.txt', dtype=np.int16)
assert len(samples) == 45*4096
sine = [int(row,16) for row in (ROOT/'src/rom/sine256.hex').read_text().split()]
sine = [value-65536 if value>=32768 else value for value in sine]
frequency = [int(row,16) for row in (ROOT/'src/rom/frequency88.hex').read_text().split()]
profiles = [int(row,16) for row in (ROOT/'src/rom/clarinet45.hex').read_text().split()]


def reference(midi):
    """Independent integer additive model, including release and output rounding."""
    step = (frequency[midi-21]*193274) >> 16
    weights = [(profiles[midi-50] >> (16*i)) & 65535 for i in range(8)]
    phase = envelope = 0
    lfsr = 0x1ace+midi
    for frame in range(4096):
        envelope = min(32767,envelope+128) if frame<3072 else max(0,envelope-64)
        mixed = 2*((lfsr & 255)-128)
        for harmonic, weight in enumerate(weights,1):
            if step*harmonic >= 0x78000000:
                continue
            position = (phase*harmonic) & 0xffffffff
            address, fraction = position >> 24, (position >> 16) & 255
            value = sine[address] + ((sine[(address+1)%256]-sine[address])*fraction >> 8)
            mixed += value*weight >> 15
        value = ((mixed*envelope >> 15)*192) >> 8
        yield (value+(0 if value<0 else 1)) >> 1
        phase = (phase+step) & 0xffffffff
        feedback = ((lfsr >> 15) ^ (lfsr >> 13) ^ (lfsr >> 12) ^ (lfsr >> 10)) & 1
        lfsr = ((lfsr << 1) | feedback) & 65535


report = []
for index, midi in enumerate(range(50, 95)):
    segment = samples[index*4096:(index+1)*4096].astype(float)
    expected_pcm = np.fromiter(reference(midi),dtype=np.int16,count=4096)
    assert np.array_equal(segment,expected_pcm), (midi,'RTL differs from independent integer model')
    steady = segment[1024:3072]
    spectrum = np.abs(np.fft.rfft((steady-steady.mean())*np.hanning(len(steady)), n=65536))
    peak = int(np.argmax(spectrum[1:])+1)
    # Log-parabolic interpolation of the zero-padded Hann spectrum.
    a, b, c = np.log(np.maximum(spectrum[peak-1:peak+2], 1e-12))
    measured = (peak + 0.5*(a-c)/(a-2*b+c))*FS/65536
    expected = 440*2**((midi-69)/12)
    cents = 1200*math.log2(measured/expected)
    rms = float(np.sqrt(np.mean(steady**2)))
    assert abs(cents)<3, (midi, measured, cents)
    assert 500<rms<15000, (midi, rms)
    assert abs(float(steady.mean()))<100, (midi, 'DC bias')
    assert np.max(np.abs(segment[-400:]))==0, (midi, 'release not silent')
    assert np.max(np.abs(segment))<30000, (midi, 'clipping')
    report.append(dict(midi=midi, expected_hz=expected, measured_hz=measured,
                       error_cents=cents, rms=rms, peak=int(np.max(np.abs(segment)))))
wav_path=out/'clarinet45_realtime.wav'
with wave.open(str(wav_path), 'wb') as wav:
    wav.setnchannels(1);wav.setsampwidth(2);wav.setframerate(round(FS))
    wav.writeframes(samples.astype('<i2').tobytes())
result=dict(sample_rate_exact=FS, wav_sample_rate=round(FS), samples=len(samples),
            exact_reference_samples=len(samples), pitches=report,
            max_abs_cents=max(abs(row['error_cents']) for row in report))
(out/'audio_report.json').write_text(json.dumps(result,indent=2)+'\n', encoding='utf-8')
print(f'PASS: 45 real-time synthesized pitches, max error {result["max_abs_cents"]:.3f} cents; {wav_path}')
