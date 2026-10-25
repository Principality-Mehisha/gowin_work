"""Arrange Mutopia's Chopin Op.9 No.2 upper staff as a C45S clarinet solo.

The source MIDI/engraving is CC BY-SA 3.0, Renato Biolcati Rinaldi / Mutopia.
This derived arrangement is distributed under the same license. No audio data.
"""
from pathlib import Path
from collections import defaultdict, deque
from itertools import groupby
import csv
import hashlib
import json
import struct
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools/vendor'))
import mido

SOURCE = ROOT/'source/chopin_nocturne_op9_no2/chopin_nocturne_op9_n2.mid'
SOURCE_PAGE = 'https://www.mutopiaproject.org/cgibin/piece-info.cgi?id=1590'
LICENSE = 'https://creativecommons.org/licenses/by-sa/3.0/'


def extract_melody(path=SOURCE):
    midi=mido.MidiFile(path)
    staff=[t for t in midi.tracks if t.name=='upper']
    if len(staff)!=1:
        raise ValueError('Expected the documented upper-staff MIDI track')
    channels={msg.channel for msg in staff[0] if msg.type=='note_on' and msg.velocity}
    if channels!={1}:
        raise ValueError('Upper-staff channel changed; review the source')
    # Read tempo from the complete merged MIDI, but select only the upper staff.
    tempo=500000; tick=0; seconds=0.0; timeline=[]
    for msg in mido.merge_tracks(midi.tracks):
        seconds+=mido.tick2second(msg.time,midi.ticks_per_beat,tempo)
        tick+=msg.time
        if msg.type=='set_tempo': tempo=msg.tempo
        if getattr(msg,'channel',-1)==1 and msg.type in ('note_on','note_off'):
            timeline.append((tick,seconds,msg))
    active=defaultdict(deque)
    melody=[]; current=None; current_velocity=0; start=0.0
    for _,group in groupby(timeline,key=lambda row:row[0]):
        group=list(group); now=group[0][1]; attacks=set()
        # Resolve simultaneous chord events atomically. Highest sounding note
        # is the melody; lower chord tones and all left-hand notes are omitted.
        for _,_,msg in group:
            if msg.type=='note_off' or msg.velocity==0:
                if not active[msg.note]:
                    raise ValueError('Unpaired source note-off')
                active[msg.note].popleft()
                if not active[msg.note]: del active[msg.note]
        for _,_,msg in group:
            if msg.type=='note_on' and msg.velocity:
                active[msg.note].append(msg.velocity); attacks.add(msg.note)
        top=max(active) if active else None
        if top!=current or (top is not None and top in attacks):
            if current is not None and now>start:
                melody.append(dict(start_ms=round(start*1000),end_ms=round(now*1000),
                                   source_midi=current,velocity=current_velocity))
            current=top; start=now
            current_velocity=active[top][-1] if top is not None else 0
    if current is not None or active:
        raise ValueError('Source has unterminated notes')
    # One octave down keeps the original Eb major key and the entire melodic
    # contour. The extracted range Eb4..Eb7 becomes Eb3..Eb6, inside D3..Bb6.
    for note in melody:
        note['midi']=note['source_midi']-12
        if not 50<=note['midi']<=94 or note['end_ms']<=note['start_ms']:
            raise ValueError('Arrangement outside clarinet range or invalid duration')
    return melody


def build_score(notes):
    events=[]
    for note in notes:
        events.append((note['start_ms'],0,note['midi'],note['velocity'],0))
        events.append((note['end_ms'],0,note['midi'],0,0))
    events.sort(key=lambda e:(e[0],e[3]!=0)) # off before on at the same millisecond
    end=events[-1][0]+500 # allow the final note's release before EOF clears audio
    events.append((end,255,255,0,0))
    data=struct.pack('<4sBBBBII',b'C45S',1,8,8,0,1000,len(events))
    return data+b''.join(struct.pack('<IBBBB',*e) for e in events),events


def validate_score(data):
    magic,version,width,slots,reserved,tps,count=struct.unpack_from('<4sBBBBII',data)
    assert (magic,version,width,slots,reserved,tps)==(b'C45S',1,8,8,0,1000)
    assert len(data)==16+count*8 and count<=20000
    active=None; last=-1
    for i in range(count):
        time,slot,note,velocity,reserved=struct.unpack_from('<IBBBB',data,16+i*8)
        assert time>=last and reserved==0
        last=time
        if i==count-1:
            assert (slot,note,velocity)==(255,255,0) and active is None
        else:
            assert slot==0 and 50<=note<=94 and 0<=velocity<128
            if velocity:
                assert active is None, 'Polyphonic overlap in a solo score'
                active=note
            else:
                assert active==note, 'Unmatched note-off'
                active=None


def main():
    notes=extract_melody();data,events=build_score(notes);validate_score(data)
    dest=ROOT/'sd_card';dest.mkdir(exist_ok=True)
    (dest/'CLARINET.BIN').write_bytes(data)
    with (dest/'CLARINET_NOTES.csv').open('w',encoding='utf-8-sig',newline='') as f:
        writer=csv.DictWriter(f,fieldnames=list(notes[0]));writer.writeheader();writer.writerows(notes)
    # Preserve the source's metrical grid as well as actual concert pitches.
    # The source has one tempo: eighth=132, i.e. quarter=66 beats/minute.
    midi=mido.MidiFile(ticks_per_beat=384)
    track=mido.MidiTrack();midi.tracks.append(track)
    track.append(mido.MetaMessage('track_name',name='Chopin Op.9 No.2 - clarinet solo'))
    track.append(mido.MetaMessage('text',text='Adapted from Renato Biolcati Rinaldi / Mutopia; CC BY-SA 3.0'))
    track.append(mido.MetaMessage('set_tempo',tempo=909090))
    track.append(mido.MetaMessage('time_signature',numerator=12,denominator=8))
    track.append(mido.MetaMessage('key_signature',key='Eb'))
    track.append(mido.Message('program_change',program=71,channel=0))
    previous=0
    for time,slot,pitch,velocity,_ in events[:-1]:
        absolute_tick=round(time*1000*midi.ticks_per_beat/909090)
        track.append(mido.Message('note_on' if velocity else 'note_off',note=pitch,
                     velocity=velocity,time=absolute_tick-previous,channel=0));previous=absolute_tick
    midi.save(dest/'CLARINET.mid')
    report=dict(title='Chopin Nocturne Op.9 No.2 - monophonic clarinet arrangement',
        source_page=SOURCE_PAGE,source_midi=str(SOURCE.relative_to(ROOT)),
        source_credit='Renato Biolcati Rinaldi / Mutopia Project, 2014',license='CC BY-SA 3.0',license_url=LICENSE,
        source_sha256=hashlib.sha256(SOURCE.read_bytes()).hexdigest(),
        arrangement='Highest sounding upper-staff voice; omit left hand and chord tones; preserve repeated attacks and ornaments; transpose globally down one octave',
        transposition_semitones=-12,source_melody_range=[min(n['source_midi'] for n in notes),max(n['source_midi'] for n in notes)],
        midi_range=[min(n['midi'] for n in notes),max(n['midi'] for n in notes)],
        format='C45S v1, 16-byte header + 8-byte timestamped note events, no PCM',
        notes=len(notes),events=len(events),peak_polyphony=1,duration_ms=events[-1][0],
        music_end_ms=events[-2][0],bytes=len(data),sha256=hashlib.sha256(data).hexdigest())
    (dest/'CLARINET.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(report,ensure_ascii=False,indent=2))


if __name__=='__main__': main()
