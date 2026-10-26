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


from clarinet_reference import render_events


def main():
    out=ROOT/'output/clarinet_calibration';data=(ROOT/'sd_card/CLARINET.BIN').read_bytes()
    events=[struct.unpack_from('<IBBBB',data,i) for i in range(16,len(data),8)]
    frames=(events[-1][0]*50000000+3072000-1)//3072000
    rtl=np.loadtxt(ROOT/'output/nocturne/nocturne_pcm.txt',dtype=np.int16)
    assert len(rtl)==frames
    expected=np.fromiter(render_events(events,frames),dtype=np.int16,count=frames)
    mismatch=np.flatnonzero(rtl!=expected)
    assert len(mismatch)==0,('Full Nocturne RTL mismatch',mismatch[:10].tolist())
    assert np.max(np.abs(rtl.astype(np.int32)))<30000
    assert np.max(np.abs(rtl[-4000:].astype(np.int32)))==0
    dest=out/'Chopin_Nocturne_Op9_No2_Clarinet_Expressive_Realtime.wav'
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
