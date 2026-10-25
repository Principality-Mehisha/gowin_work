"""Check full Nocturne RTL audio against an independent integer model; export WAV."""
from pathlib import Path
import hashlib
import json
import struct
import sys
import wave

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'output/marimba_tools'))
import numpy as np


def reference(events,frames):
    sine=[int(s,16) for s in (ROOT/'src/rom/sine256.hex').read_text().split()]
    sine=[s-65536 if s>=32768 else s for s in sine]
    freq=[int(s,16) for s in (ROOT/'src/rom/frequency88.hex').read_text().split()]
    weights=[int(s,16) for s in (ROOT/'src/rom/clarinet45.hex').read_text().split()]
    phase=envelope=step=velocity=index=0;gate=False;held=50;lfsr=0x1ace;partials=[]
    for frame in range(frames):
        while index<len(events)-1 and frame*3072000>=events[index][0]*50000000:
            _,_,pitch,dyn,_=events[index]
            if dyn:
                held=pitch;gate=True;velocity=dyn*2;phase=envelope=0;lfsr=0x1ace+pitch
                step=freq[pitch-21]*193274 >> 16
                partials=[(h,weights[pitch-50] >> (16*(h-1)) & 65535) for h in range(1,9) if h*step<0x78000000]
            elif pitch==held:gate=False
            index+=1
        envelope=min(32767,envelope+128) if gate else max(0,envelope-64)
        mixed=2*((lfsr & 255)-128)
        for harmonic,weight in partials:
            p=(phase*harmonic)&0xffffffff;addr=p>>24;fraction=(p>>16)&255
            value=sine[addr]+((sine[(addr+1)%256]-sine[addr])*fraction >> 8)
            mixed+=value*weight >> 15
        value=((mixed*envelope >> 15)*velocity) >> 8
        yield (value+(0 if value<0 else 1)) >> 1
        phase=(phase+step)&0xffffffff
        feedback=((lfsr>>15)^(lfsr>>13)^(lfsr>>12)^(lfsr>>10))&1
        lfsr=((lfsr<<1)|feedback)&65535


def main():
    out=ROOT/'output/nocturne';data=(ROOT/'sd_card/CLARINET.BIN').read_bytes()
    events=[struct.unpack_from('<IBBBB',data,i) for i in range(16,len(data),8)]
    frames=(events[-1][0]*50000000+3072000-1)//3072000
    rtl=np.loadtxt(out/'nocturne_pcm.txt',dtype=np.int16)
    assert len(rtl)==frames
    expected=np.fromiter(reference(events,frames),dtype=np.int16,count=frames)
    mismatch=np.flatnonzero(rtl!=expected)
    assert len(mismatch)==0,('Full Nocturne RTL mismatch',mismatch[:10].tolist())
    assert np.max(np.abs(rtl.astype(np.int32)))<30000
    assert np.max(np.abs(rtl[-4000:].astype(np.int32)))==0
    dest=out/'Chopin_Nocturne_Op9_No2_Clarinet_Realtime.wav'
    with wave.open(str(dest),'wb') as wav:
        wav.setnchannels(1);wav.setsampwidth(2);wav.setframerate(round(50000000/3072))
        wav.writeframes(rtl.astype('<i2').tobytes())
    report=dict(title='Chopin Nocturne Op.9 No.2 - clarinet solo',source='Full C45S BIN through clarinet_synth RTL; exact independent integer model',
        matched_samples=frames,duration_seconds=frames*3072/50000000,
        exact_sample_rate=50000000/3072,peak_pcm=int(np.max(np.abs(rtl.astype(np.int32)))),
        score_sha256=hashlib.sha256(data).hexdigest(),wav_sha256=hashlib.sha256(dest.read_bytes()).hexdigest(),
        source_credit='Renato Biolcati Rinaldi / Mutopia Project',license='CC BY-SA 3.0',
        license_url='https://creativecommons.org/licenses/by-sa/3.0/',preview=str(dest.relative_to(ROOT)))
    (out/'audio_report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(report,indent=2));print('PASS: full real-time clarinet Nocturne audio')


if __name__=='__main__':main()
