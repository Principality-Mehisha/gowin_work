"""Build Samsung Over the Horizon's marimba-only M42S arrangement."""
from __future__ import annotations
import hashlib,heapq,json,math,struct,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent/'vendor'))
import mido
from fat_test_fixtures import build,save_hex
ROOT=Path(__file__).resolve().parents[1]
SOURCE=ROOT/'assets/ringtone/android/samsung_over_the_horizon_s3.mid'
SOURCE_URL='http://onj3.andrelouis.com/phonetones/unzipped/Samsung/GT-E1270/01%20Ringtones/07%20Over%20the%20horizon.mid'

def main():
    midi=mido.MidiFile(SOURCE)
    tracks=[t for t in midi.tracks if any(m.type=='program_change' and m.program==12 for m in t)]
    assert len(tracks)==1 and tracks[0].name=='Marimba'
    channels={m.channel for m in tracks[0] if m.type=='program_change' and m.program==12}
    tempo=500000;seconds=0;free=list(range(8));heapq.heapify(free)
    active={};events=[];notes=[];note_slots={};peak=0;fixed_pitchwheel=set()
    for message in mido.merge_tracks(midi.tracks):
        seconds+=mido.tick2second(message.time,midi.ticks_per_beat,tempo)
        if message.type=='set_tempo':tempo=message.tempo
        if getattr(message,'channel',None) not in channels:continue
        if message.type=='pitchwheel':fixed_pitchwheel.add(message.pitch)
        if message.type not in ('note_on','note_off'):continue
        milliseconds=round(seconds*1000)
        if message.type=='note_on' and message.velocity:
            assert 36<=message.note<=83
            assert free,'More than eight simultaneous MIDI notes'
            slot=heapq.heappop(free);active.setdefault(message.note,[]).append(slot)
            events.append((milliseconds,slot,message.note,message.velocity,0))
            notes.append(dict(time_ms=milliseconds,midi=message.note,velocity=message.velocity,slot=slot))
            note_slots[(message.note,slot)]=notes[-1]
            peak=max(peak,sum(len(x) for x in active.values()))
        else:
            assert active.get(message.note),('Unmatched note off',message.note)
            slot=active[message.note].pop(0);heapq.heappush(free,slot)
            events.append((milliseconds,slot,message.note,0,0))
            note_slots[(message.note,slot)]["end_ms"]=milliseconds
    assert not any(active.values())
    assert len(notes)==32
    raw_count=len(notes)
    unique={}
    for note in notes:
        key=(note['time_ms'],note['midi'])
        if key not in unique or note['velocity']>unique[key]['velocity']:unique[key]=note
    notes=list(unique.values())
    events=[]
    for note in notes:
        events.extend([(note['time_ms'],note['slot'],note['midi'],note['velocity'],0),
                       (note['end_ms'],note['slot'],note['midi'],0,0)])
    events.sort(key=lambda e:(e[0],e[3]!=0,e[1]))
    end=max(math.ceil(midi.length*1000),events[-1][0]+1200)
    events.append((end,255,255,0,0))
    payload=struct.pack('<4sBBBBII',b'M42S',1,8,8,0,1000,len(events))+b''.join(struct.pack('<IBBBB',*e) for e in events)
    out=ROOT/'sd_card';(out/'ANDROID.BIN').write_bytes(payload)
    report=dict(title='Samsung Over the Horizon (2012/S3) - marimba part arrangement',
        source=str(SOURCE.relative_to(ROOT)),source_url=SOURCE_URL,
        source_sha256=hashlib.sha256(SOURCE.read_bytes()).hexdigest(),source_device='Samsung GT-E1270 public phone-tone archive',
        brand_reference='https://news.samsung.com/global/over-the-horizon-the-evolution-of-the-samsung-galaxy-brand-sound',
        source_audio_reference='https://raw.githubusercontent.com/w3teal/awesome-ringtone/main/Samsung/2012%20-%20Over%20the%20Horizon%20-%20Ringtone.mp3',
        arrangement='Extract GM program 12 Marimba channel; preserve MIDI note timing/velocity; render with existing modal marimba',
        pitchwheel_ignored=sorted(fixed_pitchwheel),pitch_policy='Equal temperament; fixed source pitchwheel offset not applied',
        format='M42S v1',source_note_on_count=raw_count,merged_same_time_unisons=raw_count-len(notes),note_on_count=len(notes),event_count=len(events),score_bytes=len(payload),
        score_sha256=hashlib.sha256(payload).hexdigest(),duration_ms=end,source_duration_ms=round(midi.length*1000),
        note_range=[min(n['midi'] for n in notes),max(n['midi'] for n in notes)],max_midi_overlap=peak,
        notes=notes,events=[dict(zip(('time_ms','slot','midi','velocity','reserved'),e)) for e in events])
    (out/'ANDROID.json').write_text(json.dumps(report,indent=2),encoding='utf8')
    fixtures=ROOT/'output/ringtone_test';fixtures.mkdir(exist_ok=True)
    for fat in (False,True):save_hex(fixtures/('fat32.hex' if fat else 'fat16.hex'),build(fat,payload,filename=b'ANDROID BIN'))
    save_hex(fixtures/'missing.hex',build(False,payload,missing=True,filename=b'ANDROID BIN'))
    wrong=bytearray(payload);wrong[:4]=b'P88S';save_hex(fixtures/'wrong_format.hex',build(False,bytes(wrong),filename=b'ANDROID BIN'))
    bad=bytearray(payload);bad[21]=35;save_hex(fixtures/'bad_note.hex',build(False,bytes(bad),filename=b'ANDROID BIN'))
    (fixtures/'params.vh').write_text(f'`define RINGTONE_EVENTS {len(events)}\n`define RINGTONE_NOTE_ONS {len(notes)}\n`define RINGTONE_FRAMES {(end*50000000+3072000-1)//3072000}\n',encoding='ascii')
    (fixtures/'events.hex').write_text(''.join(f'{int.from_bytes(struct.pack("<IBBBB",*e),"little"):016x}\n' for e in events),encoding='ascii')
    print(json.dumps({k:v for k,v in report.items() if k not in ('notes','events')},indent=2))
    print([(n['time_ms'],n['midi'],n['velocity']) for n in notes])
if __name__=='__main__':main()
