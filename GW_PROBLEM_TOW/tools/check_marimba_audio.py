"""Verify C2-F5 RTL audio, calibration, pitch and preservation of B2-F5."""
from __future__ import annotations
import hashlib
import json
import math
from pathlib import Path
from fit_marimba_params import NOTE_FIRST, loudness_metric
import numpy as np
from marimba_reference import OUT_FS, decode_modes, render_note
ROOT = Path(__file__).resolve().parents[1]
NOTE_LAST = 77  # KEY1 audition remains C2-F5.

def measured_pitch(samples, expected):
    part = samples[round(.025 * OUT_FS):round(.45 * OUT_FS)]
    nfft = 262144
    spectrum = abs(np.fft.rfft(part * np.hanning(len(part)), n=nfft))
    frequencies = np.fft.rfftfreq(nfft, 1 / OUT_FS)
    indices = np.flatnonzero((frequencies >= expected * .98) & (frequencies <= expected * 1.02))
    index = indices[np.argmax(spectrum[indices])]
    a, b, c = np.log(np.maximum(spectrum[index-1:index+2], 1e-30))
    return float((index + .5*(a-c)/(a-2*b+c)) * OUT_FS / nfft)

def main():
    fit = json.loads((ROOT/'assets/marimba/fit_report.json').read_text())
    rom_path = ROOT/'src/rom/marimba48.hex'
    rom_hash = hashlib.sha256(rom_path.read_bytes()).hexdigest()
    assert rom_hash == fit['mode_rom_sha256'], 'ROM/report mismatch'
    words = [int(x,16) for x in rom_path.read_text().split()]
    attacks = [int(x,16) for x in (ROOT/'src/rom/marimba_attack48.hex').read_text().split()]
    sine = [int(x,16) for x in (ROOT/'src/rom/sine256.hex').read_text().split()]
    sine = [x-65536 if x>=32768 else x for x in sine]
    baseline = ROOT/'sim/marimba_before_low_extension'
    old_words = [int(x,16) for x in (baseline/'marimba31.hex').read_text().split()]
    old_attacks = [int(x,16) for x in (baseline/'marimba_attack31.hex').read_text().split()]
    notes = list(range(NOTE_FIRST, NOTE_LAST+1))
    assert fit['notes'][:42] == notes
    assert len(words) == len(attacks) == 48 and len(notes) == 42
    rtl = np.loadtxt(ROOT/'sim/marimba_scale_pcm.txt', dtype=np.int32)
    assert rtl.shape == (len(notes)*16276,3)
    results=[]
    for index,midi in enumerate(notes):
        row=fit['rows'][index]
        block=rtl[index*16276:(index+1)*16276]
        assert np.all(block[:,0] == midi)
        assert np.array_equal(block[:,1], np.arange(16276))
        modes=decode_modes(words[index])
        assert modes[0][1]>0
        expected=440*2**((midi-69)/12)
        assert abs(1200*math.log2(modes[0][0]*OUT_FS/2**32/expected))<.001
        for mode,measurement in zip(modes,row['modes']):
            if measurement['disabled']:
                assert mode[0]==mode[1]==0
            else:
                assert 0<mode[0]<0x80000000 and 0<mode[1]<32768
                assert abs(mode[2]-math.exp(-1/(OUT_FS*measurement['tau_seconds']))*32768)<=.501
        audio=block[:,2]
        reference=render_note(modes,attacks[index],sine,index,note_first=NOTE_FIRST)
        assert np.array_equal(audio,reference),('RTL mismatch',midi)
        peak=int(max(abs(audio)))
        assert 0<peak<12000
        level=loudness_metric(audio)
        error=20*math.log10(level/row['calibration']['target_weighted_rms'])
        assert abs(error)<.12,(midi,error)
        pitch=measured_pitch(audio,expected)
        pitch_error=1200*math.log2(pitch/expected)
        assert abs(pitch_error)<2,(midi,pitch_error)
        if midi>=47:
            old_index=midi-47
            assert words[index]==old_words[old_index] and attacks[index]==old_attacks[old_index]
            previous=render_note(decode_modes(old_words[old_index]),old_attacks[old_index],sine,old_index)
            assert np.array_equal(audio,previous),('B2-F5 changed',midi)
        results.append(dict(midi=midi,pitch_hz=pitch,pitch_error_cents=pitch_error,peak_pcm=peak,
                            weighted_rms=level,target_error_db=error,enabled_modes=sum(m[1]>0 for m in modes)))
        print(f'MIDI {midi}: matched, pitch={pitch_error:.4f} cents, RMS={level:.2f}',flush=True)
    levels=np.array([x['weighted_rms'] for x in results])
    adjacent=20*np.log10(levels[1:]/levels[:-1])
    assert max(abs(adjacent))<.6,'Level discontinuity'
    report=dict(source='ModelSim RTL, checked against independent integer model',mode_rom_sha256=rom_hash,
                matched_samples=len(rtl),first_midi=NOTE_FIRST,last_midi=NOTE_LAST,note_count=len(notes),
                unchanged_B2_F5_samples=31*16276,max_adjacent_level_change_db=float(max(abs(adjacent))),
                max_pitch_error_cents=max(abs(x['pitch_error_cents']) for x in results),
                max_target_error_db=max(abs(x['target_error_db']) for x in results),
                peak_pcm=max(x['peak_pcm'] for x in results),notes=results)
    (ROOT/'sim/marimba42_report.json').write_text(json.dumps(report,indent=2),encoding='ascii')
    print(f'PASS: {len(notes)} notes, {len(rtl)} exact RTL samples, B2-F5 unchanged')

if __name__=='__main__':
    main()
