"""Transcribe tonal attacks in the local reference into an M42S event score."""
from __future__ import annotations
import hashlib,json,struct,wave
from pathlib import Path
from fit_marimba_params import np,signal
ROOT=Path(__file__).resolve().parents[1]
VOICES=32

def main():
    source=ROOT/'assets/ringtone/apple_marimba_pcm_board.wav'
    with wave.open(str(source)) as w:
        fs=w.getframerate(); audio=np.frombuffer(w.readframes(w.getnframes()),dtype='<i2').reshape(-1,2)/32768
    f,t,z=signal.stft(audio,fs,nperseg=1024,noverlap=992,nfft=8192,axis=0)
    mag=abs(z).mean(axis=1)
    pitches=[67,71,74,76,79,83]  # Verified isolated peaks; reject neighboring-bin leakage
    envelopes=[]
    for midi in pitches:
        hz=440*2**((midi-69)/12)
        envelopes.append(mag[abs(f-hz)<6].max(axis=0))
    envelopes=np.array(envelopes); maximum=float(envelopes.max()); attacks=[]
    for midi,env in zip(pitches,envelopes):
        if env.max()<maximum*.09: continue
        delta=np.maximum(0,env-np.r_[np.zeros(8),env[:-8]])
        peaks,_=signal.find_peaks(delta,distance=round(.10/(t[1]-t[0])),prominence=max(delta)*.12)
        for p in peaks:
            if env[p]<maximum*(.065 if midi==67 else .17) or delta[p]<maximum*.012: continue
            local,_=signal.find_peaks(mag[:,p]); hz=440*2**((midi-69)/12)
            nearby=[i for i in local if abs(1200*np.log2(max(f[i],1)/hz))<35]
            if not nearby: continue
            onset=max(0,float(t[p])-.010)
            attacks.append(dict(time_ms=round(onset*1000),midi=midi,strength=float(env[p]),
                                velocity=int(np.clip(round(110*np.sqrt(env[p]/maximum)),38,116))))
    attacks.sort(key=lambda x:(x['time_ms'],x['midi']))
    # Different partial envelopes of a simultaneous strike peak a few ms apart.
    for i,a in enumerate(attacks):
        if i and a['time_ms']-attacks[i-1]['time_ms']<22:
            a['time_ms']=attacks[i-1]['time_ms']
    events=[]
    for i,a in enumerate(attacks):
        slot=i%VOICES
        events.append((a['time_ms'],slot,a['midi'],a['velocity'],0))
        events.append((a['time_ms']+90,slot,a['midi'],0,0))
    events.sort(key=lambda x:(x[0],x[3]!=0,x[1]))
    end=max(round(len(audio)/fs*1000),max(x[0] for x in events)+1200)
    events.append((end,255,255,0,0))
    payload=struct.pack('<4sBBBBII',b'M42S',1,8,VOICES,0,1000,len(events))+b''.join(struct.pack('<IBBBB',*e) for e in events)
    out=ROOT/'sd_card';out.mkdir(parents=True,exist_ok=True);(out/'RINGTONE.BIN').write_bytes(payload)
    report=dict(format='M42S v1; MIDI 36..83; timestamps ms; velocity 1..127; zero=note off',
                source=str(source.relative_to(ROOT)),source_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),
                source_duration_ms=round(len(audio)/fs*1000),duration_ms=end,note_on_count=len(attacks),
                event_count=len(events),score_bytes=len(payload),score_sha256=hashlib.sha256(payload).hexdigest(),
                transcription='Offline spectral attack transcription; preserves detected chords; timbre uses Iowa modal synthesis, not the reference PCM',
                notes=attacks,events=[dict(zip(('time_ms','slot','midi','velocity','reserved'),e)) for e in events])
    (out/'RINGTONE.json').write_text(json.dumps(report,indent=2),encoding='utf8')
    print(json.dumps({k:v for k,v in report.items() if k not in ('events','notes')},indent=2))
    print([(a['time_ms'],a['midi'],a['velocity']) for a in attacks])
if __name__=='__main__': main()
