"""Make reproducible checkpoints for four parallel, continuous RTL song segments.

Every split is a new note-on, which resets all per-note synthesis state.
Only breath pressure and limiter peak carry across it; RTL checks those values
at both ends. Concatenated output still receives the full independent check.
"""
from pathlib import Path
import bisect
import hashlib
import json
import struct
from clarinet_reference import ClarinetReference, ROOT


def main():
    out=ROOT/'output/clarinet_calibration/segments';out.mkdir(parents=True,exist_ok=True)
    data=(ROOT/'sd_card/CLARINET.BIN').read_bytes()
    events=[struct.unpack_from('<IBBBB',data,i) for i in range(16,len(data),8)]
    frame_at=lambda ms:(ms*50000000+3072000-1)//3072000
    total=frame_at(events[-1][0]);times=[frame_at(e[0]) for e in events]
    starts=[0]+[min((times[i] for i,e in enumerate(events[:-1]) if e[3]),key=lambda f:abs(f-total*k/4)) for k in (1,2,3)]+[total]
    assert starts==sorted(set(starts))
    checkpoints={};model=ClarinetReference();index=0
    for frame in range(total+1):
        if frame in starts:checkpoints[frame]=(model.breath_control,model.peak)
        if frame==total:break
        while index<len(events)-1 and times[index]<=frame:
            _,_,pitch,velocity,_=events[index];model.event(velocity!=0,pitch,velocity*2);index+=1
        model.frame()
        if frame%500000==0:print(f'Preparing reference checkpoints: {frame}/{total}',flush=True)
    segments=[]
    for number,(start,end) in enumerate(zip(starts,starts[1:])):
        first=bisect.bisect_left(times,start)
        assert start==0 or any(e[3] for i,e in enumerate(events[:-1]) if times[i]==start)
        values=[start,end,first,*checkpoints[start],*checkpoints[end]]
        (out/f'segment{number}.meta').write_text(' '.join(map(str,values))+'\n')
        segments.append(dict(number=number,start_frame=start,end_frame=end,event_index=first,
            start_breath=checkpoints[start][0],start_peak=checkpoints[start][1],
            end_breath=checkpoints[end][0],end_peak=checkpoints[end][1]))
    paths=['src/audio/clarinet_synth.v','src/audio/output_limiter.v','tools/clarinet_reference.py',
           'src/rom/sine256.hex','src/rom/frequency88.hex','src/rom/clarinet45.hex','src/rom/clarinet45_env.hex','sd_card/CLARINET.BIN']
    report=dict(frames=total,method='Four contiguous RTL segments split at new-note boundaries; carried breath and limiter states checked by RTL; full concatenated PCM independently verified',
        inputs={p:hashlib.sha256((ROOT/p).read_bytes()).hexdigest() for p in paths},segments=segments)
    (out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n')
    print('PASS: four segment checkpoints prepared',flush=True)


if __name__=='__main__':main()
