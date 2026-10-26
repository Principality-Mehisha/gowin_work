"""Verify measured clarinet RTL against an independent model and export tones."""
from pathlib import Path
import argparse,json,math,sys,wave
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'output/marimba_tools'))
import numpy as np
from clarinet_reference import ClarinetReference,OUT_FS

def main():
    parser=argparse.ArgumentParser();parser.add_argument('--smoke',action='store_true');args=parser.parse_args()
    out=ROOT/'output/clarinet_calibration';samples=np.loadtxt(out/'tone_pcm.txt',dtype=np.int16)
    count=len(samples)//6144
    assert len(samples)==count*6144 and (count==45 or args.smoke)
    report=[]
    for index,midi in enumerate(range(50,50+count)):
        segment=samples[index*6144:(index+1)*6144].astype(float)
        model=ClarinetReference();model.event(True,midi,192);expected=[]
        for frame in range(6144):
            if frame==4096:model.event(False,midi,192)
            expected.append(model.frame())
        mismatch=np.flatnonzero(segment!=expected)
        assert not len(mismatch),(midi,'RTL/model mismatch',mismatch[:10].tolist(),segment[mismatch[:5]].tolist(),np.array(expected)[mismatch[:5]].tolist())
        steady=segment[3072:4096];window=np.hanning(len(steady))
        spectrum=abs(np.fft.rfft((steady-steady.mean())*window,n=131072))
        nominal=440*2**((midi-69)/12);freq=np.fft.rfftfreq(131072,1/OUT_FS)
        band=np.flatnonzero(abs(freq-nominal)<nominal*.03)
        peak=int(band[np.argmax(spectrum[band])]);a,b,c=np.log(np.maximum(spectrum[peak-1:peak+2],1e-12))
        measured=(peak+.5*(a-c)/(a-2*b+c))*OUT_FS/131072
        cents=1200*math.log2(measured/nominal);rms=float(np.sqrt(np.mean(steady**2)))
        assert abs(cents)<4,(midi,measured,cents)
        assert 500<rms<15000,(midi,rms)
        assert abs(steady.mean())<500,(midi,'DC')
        assert np.max(abs(segment[-64:]))==0,(midi,'release not silent')
        assert np.max(abs(segment))<30000,(midi,'clipping')
        report.append(dict(midi=midi,measured_hz=measured,error_cents=cents,rms=rms,peak=int(max(abs(segment)))))
    # This held gate must keep moving after the attack, without replaying PCM.
    held=np.loadtxt(out/'long_tone_pcm.txt',dtype=np.int16)
    assert len(held)==22000
    model=ClarinetReference();model.event(True,69,192);expected=[];steps=[]
    for frame in range(len(held)):
        expected.append(model.frame());steps.append(model.step)
    assert np.array_equal(held,expected),'Held-note RTL/model mismatch'
    early_rms=float(np.sqrt(np.mean(held[2200:4200].astype(float)**2)))
    late_rms=float(np.sqrt(np.mean(held[18000:20000].astype(float)**2)))
    assert 0<late_rms<early_rms*math.sqrt(.9),'Held-note level did not relax'
    pitch_cents=1200*np.log2(np.array(steps,dtype=float)*OUT_FS/(2**32*440))
    assert np.max(abs(pitch_cents))<20 and np.ptp(pitch_cents[2048:])>.01,'Pitch movement missing or excessive'
    held_report=dict(exact_reference_samples=len(held),early_rms=early_rms,late_rms=late_rms,
        late_to_early_db=20*math.log10(late_rms/early_rms),
        pitch_min_cents=float(min(pitch_cents)),pitch_max_cents=float(max(pitch_cents)),
        settled_pitch_span_cents=float(np.ptp(pitch_cents[2048:])))
    wav_path=out/'clarinet45_expressive_realtime.wav'
    with wave.open(str(wav_path),'wb') as w:
        w.setnchannels(1);w.setsampwidth(2);w.setframerate(round(OUT_FS));w.writeframes(samples.astype('<i2').tobytes())
    result=dict(notes_checked=count,exact_reference_samples=len(samples),sample_rate=OUT_FS,
                max_abs_cents=max(abs(r['error_cents']) for r in report),held_note=held_report,pitches=report)
    (out/'tone_report.json').write_text(json.dumps(result,indent=2)+'\n')
    print(f'PASS: {count} measured-profile pitches, {len(samples)} exact samples, max pitch error {result["max_abs_cents"]:.3f} cents')
if __name__=='__main__':main()
