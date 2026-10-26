"""Fit parameter-only, three-dynamic, 32-partial clarinet profiles from Iowa AIFF.

Recordings are used only offline. The FPGA receives spectral/envelope parameters,
never note PCM or a sampled waveform. See assets/clarinet/ATTRIBUTION.md.
"""
from pathlib import Path
import argparse
import hashlib
import json
import math
import struct
import sys

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'output/marimba_tools'))
import numpy as np
from scipy import signal, ndimage

FS=24000
OUT_FS=50000000/3072
PARTIALS=32
REGIONS=[('D3B3',50,59),('C4B4',60,71),('C5B5',72,83),('C6B6',84,95)]
DYNAMICS=['pp','mf','ff']


def read_aiff(path):
    data=path.read_bytes()
    assert data[:4]==b'FORM' and data[8:12]==b'AIFF',path
    pos=12;comm=sound=None
    while pos+8<=len(data):
        size=struct.unpack_from('>I',data,pos+4)[0];payload=data[pos+8:pos+8+size]
        if data[pos:pos+4]==b'COMM':comm=payload
        elif data[pos:pos+4]==b'SSND':sound=payload[8+struct.unpack_from('>I',payload)[0]:]
        pos+=8+size+(size&1)
    channels,frames,bits=struct.unpack_from('>hIh',comm)
    exponent,mantissa=struct.unpack('>HQ',comm[8:18])
    rate=math.ldexp(mantissa,(exponent&32767)-16383-63)
    assert bits==16 and channels==1 and rate==44100,path
    return signal.resample_poly(np.frombuffer(sound,dtype='>i2',count=frames).astype(float)/32768,80,147)


def runs(mask):
    changes=np.diff(np.r_[False,mask,False].astype(int))
    return list(zip(np.flatnonzero(changes==1),np.flatnonzero(changes==-1)))


def locate_notes(x,low,high,path):
    # Expected semitone order plus a harmonic template avoids mistaking breath
    # preparation for pp notes or calling a strong third harmonic the fundamental.
    freqs,times,z=signal.stft(x,FS,nperseg=2048,noverlap=1808,nfft=16384,boundary='zeros')
    mag=np.abs(z);scores=[];confidence=[]
    for midi in range(low,high+1):
        f0=440*2**((midi-69)/12)
        partial=[]
        for h,weight in [(1,1),(3,.5),(5,.25)]:
            band=np.flatnonzero(np.abs(freqs-f0*h)<max(3.5,f0*h*.021))
            partial.append(mag[band].max(axis=0)**2*weight)
        scores.append(sum(partial))
        near=(freqs>f0*.7)&(freqs<f0*1.3)
        fundamental=mag[np.abs(freqs-f0)<max(3.5,f0*.021)].max(axis=0)
        confidence.append(fundamental/np.maximum(np.median(mag[near],axis=0),1e-10))
    scores=np.array(scores);confidence=np.array(confidence)
    scores=np.where(confidence>=10,scores,0)
    best=np.argmax(scores,axis=0);notes=[];last=-1
    for i,midi in enumerate(range(low,high+1)):
        mask=(best==i)&(confidence[i]>10)&(scores[i]>1e-7)
        mask=ndimage.binary_closing(mask,iterations=3)
        options=[(a,b) for a,b in runs(mask) if b-a>=20]
        if not options:raise ValueError(f'No reliable {midi} in {path}')
        a,b=max(options,key=lambda ab:ab[1]-ab[0])
        start=max(0,float(times[a])-.025);end=min(len(x)/FS,float(times[b-1])+.025)
        assert start>last and end-start>.3,(path,midi,start,end,last)
        last=end
        notes.append((midi,start,end))
    return notes


def harmonic_frame(x,start,duration,midi,reference_f0=None):
    segment=x[round(start*FS):round((start+duration)*FS)]
    window=np.hanning(len(segment));size=1<<max(16,(len(segment)*8-1).bit_length())
    spectrum=np.fft.rfft(segment*window,n=size);freqs=np.fft.rfftfreq(size,1/FS)
    expected=440*2**((midi-69)/12)
    band=np.flatnonzero(np.abs(freqs-expected)<expected*.04)
    k=int(band[np.argmax(np.abs(spectrum[band]))])
    a,b,c=np.log(np.maximum(np.abs(spectrum[k-1:k+2]),1e-20))
    f0=(k+.5*(a-c)/(a-2*b+c))*FS/size if reference_f0 is None else reference_f0
    cents=1200*math.log2(f0/expected)
    assert abs(cents)<65,(midi,start,f0,cents)
    time=np.arange(len(segment))/FS
    h=np.arange(1,PARTIALS+1)
    basis=np.exp(-2j*np.pi*(h[:,None]*f0)*time)
    coeff=basis@(segment*window)*2/window.sum()
    coeff[h*expected>=.46875*OUT_FS]=0
    # Phase relative to a sine fundamental. This removes arbitrary recording
    # offset, and one mf phase profile is shared across dynamics for smooth blends.
    relative=np.angle(coeff)-h*np.angle(coeff[0])+(1-h)*np.pi/2
    approximation=np.real(np.conjugate(basis).T@coeff)
    residual=segment-approximation
    residual=signal.sosfilt(signal.butter(3,[250,7000],btype='bandpass',fs=FS,output='sos'),residual)
    return dict(amplitude=np.abs(coeff),phase=relative,f0=f0,
                rms=float(np.sqrt(np.mean(segment**2))),noise=float(np.sqrt(np.mean(residual**2))))


def measure_note(x,midi,start,end):
    length=end-start
    offsets=[.3,.48,.65]
    centers=[start+min(length*.65,o+length*.1) for o in offsets]
    steady=[harmonic_frame(x,min(end-.24,max(start+.12,c)),.2,midi) for c in centers]
    sustain=np.median([s['amplitude'] for s in steady],axis=0)
    attack=harmonic_frame(x,max(0,start+.01),min(.09,length*.2),midi,
                          reference_f0=float(np.median([s['f0'] for s in steady])))
    phase=np.angle(np.mean(np.exp(1j*np.array([s['phase'] for s in steady])),axis=0))
    # Measure the local RMS rise/fall, excluding low-level preparation noise.
    hop=120;begin=max(0,round((start-.15)*FS));finish=min(len(x),round((end+.2)*FS))
    part=x[begin:finish];rms=np.sqrt(np.mean(part[:len(part)//hop*hop].reshape(-1,hop)**2,axis=1))
    rms=np.convolve(rms,[.2,.6,.2],mode='same');level=np.median([s['rms'] for s in steady])
    loud=np.flatnonzero(rms>level*.8);quiet=np.flatnonzero(rms>level*.15)
    if len(loud) and len(quiet):
        attack_ms=float(np.clip((loud[0]-quiet[0])*.005/.632*1000,8,80))
        release_ms=float(np.clip((quiet[-1]-loud[-1])*.005/.632*1000,18,120))
    else:attack_ms=30.;release_ms=60.
    return dict(midi=midi,start_seconds=start,end_seconds=end,
        f0_hz=float(np.median([s['f0'] for s in steady])),attack_ms=attack_ms,release_ms=release_ms,
        attack_amplitudes=attack['amplitude'].tolist(),sustain_amplitudes=sustain.tolist(),
        phases=phase.tolist(),source_rms=level,attack_noise=attack['noise'],
        sustain_noise=float(np.median([s['noise'] for s in steady])))


def quantize(amplitudes):
    a=np.asarray(amplitudes)
    result=np.round(a/max(a.sum(),1e-20)*32760).astype(int)
    result[0]+=32760-int(result.sum())
    assert result.min()>=0 and result.max()<=32767
    return result


def template(weights,phases,midi):
    word=round(440*2**((midi-69)/12)*2**32/48000)*193274>>16
    p=(np.arange(4096,dtype=np.uint64)*word)&0xffffffff
    sine=np.array([int(s,16) for s in (ROOT/'src/rom/sine256.hex').read_text().split()],dtype=np.int64)
    sine=np.where(sine>=32768,sine-65536,sine);mix=np.zeros(len(p),dtype=np.int64)
    for i,weight in enumerate(weights):
        if (i+1)*word>=0x78000000:continue
        position=(p*(i+1)+(int(phases[i])<<24))&0xffffffff
        address=(position>>24).astype(int);fraction=((position>>16)&255).astype(int)
        value=sine[address]+((sine[(address+1)%256]-sine[address])*fraction>>8)
        mix+=value*int(weight)>>15
    return mix


def write_roms(measurements):
    # Each word: {phase8, sustain16, attack16}; profile = dynamic*45 + MIDI-50.
    phase={m:np.round((np.array(measurements['mf'][str(m)]['phases'])%(2*np.pi))*256/(2*np.pi)).astype(int)%256 for m in range(50,95)}
    quant={};peak={};noise_std=11000.
    for d in DYNAMICS:
        for m in range(50,95):
            note=measurements[d][str(m)]
            aw=quantize(note['attack_amplitudes']);sw=quantize(note['sustain_amplitudes'])
            attack=template(aw,phase[m],m);steady=template(sw,phase[m],m)
            quant[d,m]=(aw,sw,attack,steady)
            peak[m]=max(peak.get(m,0),float(np.max(np.abs(attack))),float(np.max(np.abs(steady))))
    words=[];metadata=[];profiles=[]
    for bank,d in enumerate(DYNAMICS):
        velocity=[64,160,240][bank];target=[1200,4800,7200][bank]
        for midi in range(50,95):
            n=measurements[d][str(midi)];aw,sw,attack,steady=quant[d,midi]
            rms=float(np.sqrt(np.mean(steady.astype(float)**2)))
            gain=min(target/max(rms,1)*512/velocity,23000/max(peak[midi],1)*512/255)
            gain_q=int(np.clip(round(gain*4096),1,32767))
            attack_step=math.ceil(32767/(n['attack_ms']*.001*OUT_FS))
            release_step=math.ceil(32767/(n['release_ms']*.001*OUT_FS))
            color_ms=max(60.,min(180.,n['attack_ms']*2))
            color_step=math.ceil(32767/(color_ms*.001*OUT_FS))
            # A conservative breath component from measured residual energy.
            ratio_s=min(.035,n['sustain_noise']/max(n['source_rms'],1e-10))
            ratio_a=min(.10,n['attack_noise']/max(n['source_rms'],1e-10))
            noise_s=round(rms*ratio_s/noise_std*32768)
            noise_a=round(rms*ratio_a/noise_std*32768)
            fields=[attack_step,release_step,color_step,gain_q,noise_a,noise_s]
            assert all(0<v<65536 for v in fields[:4]) and all(0<=v<65536 for v in fields[4:])
            metadata.append(sum(v<<(16*i) for i,v in enumerate(fields)))
            words.extend((int(phase[midi][i])<<32)|(int(sw[i])<<16)|int(aw[i]) for i in range(PARTIALS))
            profiles.append(dict(dynamic=d,midi=midi,attack_step=attack_step,release_step=release_step,
                color_step=color_step,gain_q12=gain_q,noise_attack_q15=noise_a,noise_sustain_q15=noise_s,
                normalized_sustain_rms=rms,calibrated_rms=rms*gain_q/4096*velocity/512))
    rom=ROOT/'src/rom'
    (rom/'clarinet45.hex').write_text(''.join(f'{w:010x}\n' for w in words),encoding='ascii')
    (rom/'clarinet45_env.hex').write_text(''.join(f'{w:024x}\n' for w in metadata),encoding='ascii')
    return profiles


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--analyze-only',action='store_true')
    parser.add_argument('--reuse-measurements',action='store_true');args=parser.parse_args()
    dest=ROOT/'assets/clarinet';cache=dest/'measurements.json'
    if args.reuse_measurements:measurements=json.loads(cache.read_text())
    else:
        measurements={d:{} for d in DYNAMICS}
        for d in DYNAMICS:
            for region,low,high in REGIONS:
                path=dest/f'source/{d}/BbClar.{d}.{region}.aiff';x=read_aiff(path)
                found=locate_notes(x,low,high,path.name)
                print(d,region,'located',len(found),'notes',flush=True)
                for midi,start,end in found:
                    if midi<=94:measurements[d][str(midi)]=measure_note(x,midi,start,end)
        assert all(len(measurements[d])==45 for d in DYNAMICS)
        cache.write_text(json.dumps(measurements,indent=2)+'\n',encoding='utf-8')
    if args.analyze_only:return
    profiles=write_roms(measurements)
    report=dict(source='University of Iowa, Bb clarinet pp/mf/ff, offline parameter fitting',
        source_manifest_sha256=hashlib.sha256((dest/'source_manifest.json').read_bytes()).hexdigest(),
        partials=32,notes=45,dynamics=DYNAMICS,parameter_words=4320,metadata_words=135,
        exact_output_fs=OUT_FS,profiles=profiles)
    (dest/'fit_report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print('PASS: 135 measured profiles, 32 partials each; parameter ROMs generated')


if __name__=='__main__':main()
