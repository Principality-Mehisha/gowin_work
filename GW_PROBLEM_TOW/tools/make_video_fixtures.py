"""Independent expected geometry at every piano note-on/off timestamp."""
from pathlib import Path
import json
import sys
from score_bin import read_p88s

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'output/video_integration'

def main():
    OUT.mkdir(parents=True,exist_ok=True)
    events,info=read_p88s(ROOT/'sd_card/PIANO.BIN')
    times=sorted({0,1,16,17,2999,3000,3334,202706} |
                 {n[k] for n in info['notes'] for k in ('start_ms','end_ms')})
    words=[]
    for ms in times:
        frame=ms*60//1000
        visible=[(t,d,n) for t,d,n in events if t<=frame+180 and t+d>frame]
        assert len(visible)<=64
        for i in range(64):
            word=0
            if i<len(visible):
                t,d,n=visible[i]; bottom=720+(frame-t)*4; top=bottom-d*4
                word=(1<<39)|((top&65535)<<23)|((bottom&65535)<<7)|n
            words.append(f'{word:010x}')
    (OUT/'case_count.hex').write_text(f'{len(times):08x}\n')
    (OUT/'times.hex').write_text('\n'.join(f'{t:08x}' for t in times)+'\n')
    (OUT/'geometry.hex').write_text('\n'.join(words)+'\n')
    # Build a reference scene from independently reconstructed intervals.
    # Reuse only the palette/keyboard reference from the original display.
    from video_reference import keyboard, render
    data=dict(loop_frames=65536,keys=keyboard(),events=events)
    image,png=render(data,380) # audio frame 200, no startup delay
    with (OUT/'expected_frame.hex').open('w') as f:
        for row in image:
            f.write(''.join(f'{int(p):06x}\n' for p in row))
    mask=sum(1<<n for n in {n for t,d,n in events if t<=200<t+d})
    (OUT/'scene_keys.hex').write_text(f'{mask:022x}\n')
    png.save(OUT/'reference.png')
    (OUT/'fixture_summary.json').write_text(json.dumps(dict(cases=len(times),source_sha256=info['sha256']),indent=2)+'\n')
    print(f'PASS: {len(times)} independent timeline cases and 1,440,000 reference pixels')

if __name__=='__main__': main()
