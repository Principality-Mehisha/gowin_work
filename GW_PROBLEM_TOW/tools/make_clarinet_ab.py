"""Export a loudness-matched baseline/expressive RTL excerpt for listening."""
from pathlib import Path
import hashlib
import itertools
import json
import sys
import wave

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'output/marimba_tools'))
import numpy as np
from clarinet_reference import OUT_FS


def read_wav(path):
    with wave.open(str(path),'rb') as w:
        assert w.getnchannels()==1 and w.getsampwidth()==2
        return np.frombuffer(w.readframes(w.getnframes()),'<i2').copy(),w.getframerate()


def main():
    out=ROOT/'output/clarinet_calibration';frames=362516;fs=round(OUT_FS)
    baseline=out/'before/output/nocturne/Chopin_Nocturne_Op9_No2_Clarinet_Realtime.wav'
    old,old_fs=read_wav(baseline);assert old_fs==fs and len(old)>=frames
    old=old[:frames].astype(float)
    # A completed prefix is sufficient even while the full simulation is running.
    with (ROOT/'output/nocturne/nocturne_pcm.txt').open() as f:
        new=np.fromiter((int(s) for s in itertools.islice(f,frames)),dtype=np.int16,count=frames).astype(float)
    rms=lambda x:float(np.sqrt(np.mean(x*x)))
    old_rms,new_rms=rms(old),rms(new);target=min(old_rms,new_rms)
    parts=[];fade=round(fs*.015)
    for raw in (old,new):
        part=raw*target/rms(raw)
        part[:fade]*=np.linspace(0,1,fade);part[-fade:]*=np.linspace(1,0,fade)
        parts.append(np.round(part).astype('<i2'))
    result=np.concatenate([parts[0],np.zeros(fs,dtype=np.int16),parts[1]])
    dest=out/'Nocturne_AB_Old_Then_Expressive_RTL.wav'
    with wave.open(str(dest),'wb') as w:
        w.setnchannels(1);w.setsampwidth(2);w.setframerate(fs);w.writeframes(result.astype('<i2').tobytes())
    prototype=out/'Nocturne_AB_Old_Then_Expressive_Prototype.wav'
    identical=None
    if prototype.exists():
        approved,approved_fs=read_wav(prototype)
        identical=approved_fs==fs and np.array_equal(approved,result)
        assert identical,'RTL listening excerpt differs from the approved prototype'
    report=dict(order='baseline, 1-second silence, expressive RTL',frames_each=frames,
        seconds_each=frames/OUT_FS,old_rms=old_rms,new_rms=new_rms,matched_rms=target,
        identical_to_approved_prototype=identical,edge_fade_ms=15,
        wav_sha256=hashlib.sha256(dest.read_bytes()).hexdigest(),
        source='Both excerpts are actual RTL output; no score timing/pitch edits')
    (out/'expressive_ab_report.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,indent=2))


if __name__=='__main__':main()
