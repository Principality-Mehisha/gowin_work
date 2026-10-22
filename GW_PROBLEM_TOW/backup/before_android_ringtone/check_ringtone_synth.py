"""Independently render score events and compare every captured RTL sample."""
import hashlib,json,struct,wave
from pathlib import Path
from fit_marimba_params import np
from marimba_reference import OUT_FS,decode_modes
ROOT=Path(__file__).resolve().parents[1]

def main():
    data=(ROOT/'sd_card/RINGTONE.BIN').read_bytes();assert data[:4]==b'M42S'
    events=[struct.unpack_from('<IBBBB',data,i) for i in range(16,len(data),8)]
    words=[int(x,16) for x in (ROOT/'src/rom/marimba48.hex').read_text().split()]
    attacks=[int(x,16) for x in (ROOT/'src/rom/marimba_attack48.hex').read_text().split()]
    assert words[:42]==[int(x,16) for x in (ROOT/'src/rom/marimba42.hex').read_text().split()]
    assert attacks[:42]==[int(x,16) for x in (ROOT/'src/rom/marimba_attack42.hex').read_text().split()]
    modes=[decode_modes(w) for w in words]
    sine=[int(x,16) for x in (ROOT/'src/rom/sine256.hex').read_text().split()]
    sine=[x-65536 if x>=32768 else x for x in sine]
    frames=(events[-1][0]*50000000+3072000-1)//3072000
    rtl=np.loadtxt(ROOT/'sim/ringtone_synth_pcm.txt',dtype=np.int32);assert len(rtl)==frames
    reference=np.empty(frames,dtype=np.int32);voices={};event_index=0
    r1a=r1b=r2a=r2b=peak=0
    for frame in range(frames):
        while event_index<len(events)-1 and frame*3072000>=events[event_index][0]*50000000:
            _,slot,note,velocity,_=events[event_index];event_index+=1
            if velocity:
                i=note-36
                voices[note]=dict(phase=[0]*4,level=[m[1] for m in modes[i]],dyn=velocity*2,
                                  noise=attacks[i]>>16,noise_step=attacks[i]&65535,lfsr=(0x1a9f+note)&65535)
        mixed=0
        for note,v in voices.items():
            bright=(v['dyn']>>4)**2
            for k,(step,_,decay) in enumerate(modes[note-36]):
                level=v['level'][k]
                if not level:continue
                phase=v['phase'][k];address=phase>>24;fraction=(phase>>16)&255
                sample=sine[address]+((sine[(address+1)&255]-sine[address])*fraction>>8)
                mixed+=((sample*level>>15)*(v['dyn'] if k==0 else bright))>>8
                v['level'][k]=level*decay>>15;v['phase'][k]=(phase+step)&0xffffffff
            if v['noise']:
                lfsr=v['lfsr'];mixed+=((((lfsr&255)-128)*v['noise']>>7)*bright)>>8
                v['noise']=max(0,v['noise']-v['noise_step'])
                bit=((lfsr>>15)^(lfsr>>13)^(lfsr>>12)^(lfsr>>10))&1
                v['lfsr']=((lfsr<<1)|bit)&65535 or 0x1ace
        r1=(mixed>>4)+(r1a*30138>>14)-(r1b*14171>>14)
        r2=(mixed>>5)+(r2a*27708>>14)-(r2b*12688>>14)
        r1b,r1a=r1a,r1;r2b,r2a=r2a,r2
        body=mixed+(r1>>2)+(r2>>3)
        sample=(body+(1 if body<0 else 2))>>2
        peak=max(abs(sample),max(0,peak-max(1,peak>>12)))
        gain=(30000<<20)//peak if peak>30000 else 1<<20
        product=sample*gain
        reference[frame]=(product+(524287 if product<0 else 524288))>>20
    assert np.array_equal(rtl,reference),('RTL mismatch',np.flatnonzero(rtl!=reference)[:10].tolist())
    assert max(abs(rtl))<30000
    output=ROOT/'sim/ringtone_sd_realtime.wav'
    with wave.open(str(output),'wb') as w:
        w.setnchannels(1);w.setsampwidth(2);w.setframerate(round(OUT_FS));w.writeframes(rtl.astype('<i2').tobytes())
    report=dict(source='Full-score marimba_synth RTL, exact independent polyphonic integer model comparison',
                matched_samples=len(rtl),note_on_count=sum(e[3]>0 for e in events[:-1]),
                score_sha256=hashlib.sha256(data).hexdigest(),peak_pcm=int(max(abs(rtl))),
                existing_42_note_rom_unchanged=True,exact_sample_rate=OUT_FS,
                duration_seconds=len(rtl)/OUT_FS,preview=str(output.relative_to(ROOT)))
    (ROOT/'sim/ringtone_sd_audio_report.json').write_text(json.dumps(report,indent=2),encoding='ascii')
    print(json.dumps(report,indent=2));print('PASS: complete polyphonic realtime ringtone audio')
if __name__=='__main__':main()
