"""Independent integer model of the measured real-time additive clarinet.

This model is used for exact RTL checks and offline previews, not by the FPGA.
"""
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
OUT_FS=50000000/3072


class ClarinetReference:
    def __init__(self):
        self.sine=[int(x,16) for x in (ROOT/'src/rom/sine256.hex').read_text().split()]
        self.sine=[x-65536 if x>=32768 else x for x in self.sine]
        self.frequency=[int(x,16) for x in (ROOT/'src/rom/frequency88.hex').read_text().split()]
        self.words=[int(x,16) for x in (ROOT/'src/rom/clarinet45.hex').read_text().split()]
        self.meta=[[(int(x,16)>>(16*i))&65535 for i in range(6)] for x in (ROOT/'src/rom/clarinet45_env.hex').read_text().split()]
        self.reset()

    def reset(self):
        self.phase=self.envelope=self.color=self.release_age=self.dynamics=self.peak=0
        self.pitch=50;self.gate=False;self.coeff_valid=False;self.lfsr=0x1ace
        self.noise_fast=self.noise_slow=0;self.low=self.high=self.blend=0;self.step=0
        self.coefficients=[(0,0)]*32
        self.note_age=0;self.breath_control=0

    def event(self,on,pitch,dynamics):
        if not 50<=pitch<=94:return
        if on and dynamics:
            # Rearticulate every score note. Automatic legato obscured attacks.
            legato=False
            self.pitch=pitch;self.dynamics=dynamics;self.gate=True;self.release_age=0;self.note_age=0
            self.step=self.frequency[pitch-21]*193274>>16
            index=pitch-50
            if dynamics<=64:self.low=self.high=index;self.blend=0
            elif dynamics<=160:self.low=index;self.high=index+45;self.blend=(dynamics-64)*256//96
            elif dynamics<=240:self.low=index+45;self.high=index+90;self.blend=(dynamics-160)*256//80
            else:self.low=self.high=index+90;self.blend=0
            if legato:self.color=32767
            else:
                self.phase=self.envelope=self.color=0;self.coeff_valid=False
                self.lfsr=0x1ace+pitch;self.noise_fast=self.noise_slow=0
        elif pitch==self.pitch:self.gate=False

    @staticmethod
    def smooth(old,target,phase=False):
        delta=target-old
        if phase:delta=(delta+128)%256-128
        step=delta>>3
        if delta>0 and step==0:step=1
        return (old+step)&255 if phase else old+step

    def frame(self):
        if not self.gate and self.envelope==0:
            mixed=0
        else:
            values=[a+((b-a)*self.blend>>8) for a,b in zip(self.meta[self.low],self.meta[self.high])]
            attack,release,color_step,gain,noise_a,noise_s=values
            attack=max(attack,81) # At most 25 ms: do not hide short score notes.
            release=max(release,51) # At most 40 ms of tail after a note-off.
            if self.note_age%64==0:
                raw=self.lfsr-65536 if self.lfsr>=32768 else self.lfsr
                self.breath_control+=(raw-self.breath_control)>>6
            pitch_delta=(-114+(self.note_age*114>>9)) if self.note_age<512 else 0
            pitch_delta+=self.breath_control>>6
            ratio=193274+(193274*pitch_delta>>16)
            self.step=self.frequency[self.pitch-21]*ratio>>16
            expression=(24576+self.note_age*4) if self.note_age<2048 else max(25600,32767-((self.note_age-2048)>>1))
            expression=max(0,min(32767,expression+(self.breath_control>>2)))
            if self.gate:self.envelope=min(32767,self.envelope+attack);self.release_age=0
            else:self.envelope=max(0,self.envelope-release);self.release_age=min(65535,self.release_age+1)
            self.color=min(32767,self.color+color_step)
            env=self.envelope*self.envelope>>15
            mixed=0
            for i in range(32):
                lo=self.words[self.low*32+i];hi=self.words[self.high*32+i]
                a=(lo&65535)+(((hi&65535)-(lo&65535))*self.blend>>8)
                s=((lo>>16)&65535)+((((hi>>16)&65535)-((lo>>16)&65535))*self.blend>>8)
                target=a+((s-a)*self.color>>15);target_phase=lo>>32
                old_weight,old_phase=self.coefficients[i]
                weight=self.smooth(old_weight,target) if self.coeff_valid else target
                offset=self.smooth(old_phase,target_phase,True) if self.coeff_valid else target_phase
                self.coefficients[i]=(weight,offset)
                if (i+1)*self.step>=0x78000000:continue
                p=(self.phase*(i+1)+(offset<<24))&0xffffffff;addr=p>>24;fraction=(p>>16)&255
                sample=self.sine[addr]+((self.sine[(addr+1)%256]-self.sine[addr])*fraction>>8)
                mixed+=sample*weight>>15
            self.coeff_valid=True;self.phase=(self.phase+self.step)&0xffffffff
            noise_gain=noise_a+((noise_s-noise_a)*self.color>>15)
            raw=self.lfsr-65536 if self.lfsr>=32768 else self.lfsr
            self.noise_fast+=(raw-self.noise_fast)>>1;self.noise_slow+=(raw-self.noise_slow)>>4
            mixed+=(self.noise_fast-self.noise_slow)*noise_gain>>15
            feedback=((self.lfsr>>15)^(self.lfsr>>13)^(self.lfsr>>12)^(self.lfsr>>10))&1
            self.lfsr=((self.lfsr<<1)|feedback)&65535
            mixed=mixed*env>>15;mixed=mixed*gain>>12;mixed=mixed*expression>>15;mixed=mixed*self.dynamics>>8
            self.note_age=min(65535,self.note_age+1)
        scaled=(mixed+(0 if mixed<0 else 1))>>1
        self.peak=max(abs(scaled),max(0,self.peak-max(1,self.peak>>12)))
        gain=(30000<<20)//self.peak if self.peak>30000 else 1<<20
        product=scaled*gain
        return (product+(524287 if product<0 else 524288))>>20


def render_events(events,frames):
    synth=ClarinetReference();index=0
    for frame in range(frames):
        while index<len(events)-1 and frame*3072000>=events[index][0]*50000000:
            _,_,pitch,dynamics,_=events[index];synth.event(dynamics!=0,pitch,dynamics*2);index+=1
        yield synth.frame()
