"""Compare source PCM, modal parameters and integer output across registers.

Run after tb_marimba_wav. Requires NumPy/SciPy. No synthesis inputs are written.
"""
from __future__ import annotations

import hashlib
import json
import math
from pathlib import Path
import wave

from fit_marimba_params import ANALYSIS_FS, NOTE_FIRST, NOTE_LAST, loudness_metric, read_aiff
import numpy as np
from scipy import signal
from marimba_reference import OUT_FS, decode_modes, render_note

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'sim/marimba_register_analysis42'


def db(ratio):
    return float(20 * np.log10(max(float(ratio), 1e-15)))


def tail_db(audio, fs):
    def rms(a, b):
        x = audio[round(a * fs):round(b * fs)].astype(float)
        return np.sqrt(np.mean(x * x))
    return db(rms(.3, .5) / max(rms(0, .1), 1e-15))


def body_gain(frequency):
    z = np.exp(-2j * np.pi * frequency / OUT_FS)
    response = (1 + (1 / 64) / (1 - 30138/16384*z + 14171/16384*z*z)
                + (1 / 256) / (1 - 27708/16384*z + 12688/16384*z*z))
    return db(abs(response))


def write_wav(path, audio):
    with wave.open(str(path), 'wb') as out:
        out.setnchannels(1)
        out.setsampwidth(2)
        out.setframerate(round(OUT_FS))
        out.writeframes(np.rint(audio).clip(-32768, 32767).astype('<i2').tobytes())


def main():
    OUT.mkdir(exist_ok=True)
    fit = json.loads((ROOT / 'assets/marimba/fit_report.json').read_text())
    baseline = ROOT / 'sim/marimba_before_bass_trim'
    before = json.loads((baseline / 'fit_report.json').read_text())
    words = [int(x, 16) for x in (ROOT / 'src/rom/marimba42.hex').read_text().split()]
    attacks = [int(x, 16) for x in
               (ROOT / 'src/rom/marimba_attack42.hex').read_text().split()]
    old_words = [int(x, 16) for x in (baseline / 'marimba31.hex').read_text().split()]
    old_attacks = [int(x, 16) for x in
                   (baseline / 'marimba_attack31.hex').read_text().split()]
    sine = [int(x, 16) for x in (ROOT / 'src/rom/sine256.hex').read_text().split()]
    sine = [x - 65536 if x >= 32768 else x for x in sine]
    rtl = np.loadtxt(ROOT / 'sim/marimba_scale_pcm.txt', dtype=np.int32)
    assert rtl.shape == ((NOTE_LAST - NOTE_FIRST + 1) * 16276, 3)
    cache, results, comparisons = {}, [], []
    for index, row in enumerate(fit['rows']):
        midi = row['midi']
        block = rtl[index * 16276:(index + 1) * 16276]
        assert np.all(block[:, 0] == midi)
        assert np.array_equal(block[:, 1], np.arange(16276))
        audio = render_note(decode_modes(words[index]), attacks[index], sine, index, note_first=NOTE_FIRST)
        assert np.array_equal(audio, block[:, 2]), ('RTL mismatch', midi)
        assert 0 < np.max(abs(audio)) < 12000
        change = None
        if midi >= 47:
            old_index = midi - 47
            previous = render_note(decode_modes(old_words[old_index]), old_attacks[old_index], sine, old_index)
            change = db(loudness_metric(audio) / loudness_metric(previous))
            target_change = (row['calibration']['bass_boost_db'] -
                             before['rows'][old_index]['calibration']['bass_boost_db'])
            assert abs(change - target_change) < .12, (midi, change, target_change)
            for old, new in zip(decode_modes(old_words[old_index]), decode_modes(words[index])):
                assert old[0] == new[0] and old[2] == new[2], ('pitch/decay changed', midi)
            if midi >= 60:
                assert words[index] == old_words[old_index] and attacks[index] == old_attacks[old_index]
                assert np.array_equal(audio, previous), ('C4+ changed', midi)
        path = row['source_file']
        if path not in cache:
            source, rate = read_aiff(ROOT / path)
            cache[path] = signal.resample_poly(source, 1, 4)
            assert rate == 96000
        onset = round(row['onset_seconds'] * ANALYSIS_FS)
        source = cache[path][onset:onset + ANALYSIS_FS]
        modes = decode_modes(words[index])
        mode_metrics = []
        for measured, (_, gain, decay) in zip(row['modes'], modes):
            level, frames, t20 = gain, 0, None
            while level and frames < round(3 * OUT_FS):
                level = level * decay >> 15
                frames += 1
                if t20 is None and level <= gain * .1:
                    t20 = frames / OUT_FS
            mode_metrics.append({
                'frequency_hz': measured['frequency'], 'enabled': gain > 0,
                'source_gain_relative_fundamental_db': db(measured['gain'] / row['modes'][0]['gain']) if gain else None,
                'fitted_tau_seconds': measured['tau_seconds'],
                'integer_t20_seconds': t20 if gain else None,
                'integer_zero_seconds': frames / OUT_FS if gain and not level else None,
                'disabled': measured['disabled'],
            })
        # Early-window spectral energy outside a broad fundamental band.
        # This includes mallet/noise components; it is not a harmonic-only metric.
        part = source[:round(.1 * ANALYSIS_FS)]
        spectrum = abs(np.fft.rfft(part * np.hanning(len(part)), n=65536)) ** 2
        frequency = np.fft.rfftfreq(65536, 1 / ANALYSIS_FS)
        f0 = row['source_fundamental']
        valid = (frequency >= 40) & (frequency < OUT_FS / 2)
        outside = valid & (abs(frequency - f0) > max(35, f0 * .08))
        source_nonfundamental = float(spectrum[outside].sum() / spectrum[valid].sum())
        results.append({
            'midi': midi, 'bass_change_db': change,
            'weighted_rms': loudness_metric(audio),
            'enabled_modes': sum(gain > 0 for _, gain, _ in modes),
            'source_tail_to_attack_db': tail_db(source, ANALYSIS_FS),
            'rtl_tail_to_attack_db': tail_db(audio, OUT_FS),
            'body_gain_at_fundamental_db': body_gain(440 * 2 ** ((midi - 69) / 12)),
            'source_early_nonfundamental_energy_fraction': source_nonfundamental,
            'measured_dynamics': {
                dynamics: {
                    'fundamental_tau_seconds': measured['modes'][0]['tau_seconds'],
                    'second_mode_relative_db': db(measured['modes'][1]['gain'] / measured['modes'][0]['gain'])
                    if measured['modes'][1]['gain'] else None,
                    'second_mode_disabled': measured['modes'][1]['disabled'],
                }
                for dynamics in ('pp', 'mf', 'ff')
                for measured in [fit['measured_by_dynamics'][dynamics][str(midi)]]
            },
            'modes': mode_metrics,
        })
        if midi in (36, 47, 60, 69, 72, 77):
            resampled = signal.resample_poly(source, 15625, 23040)[:16276]
            resampled *= loudness_metric(audio) / loudness_metric(resampled)
            for name, sound in (('source', resampled), ('rtl', audio)):
                preview = sound.astype(float).copy()
                preview[-163:] *= np.linspace(1, 0, 163)
                write_wav(OUT / f'{midi}_{name}.wav', preview)
                comparisons.extend((preview, np.zeros(round(.15 * OUT_FS))))
        print(midi, 'trim dB', None if change is None else round(change, 3), 'modes', results[-1]['enabled_modes'],
              'source/RTL tail dB', round(results[-1]['source_tail_to_attack_db'], 2),
              round(results[-1]['rtl_tail_to_attack_db'], 2), flush=True)
    write_wav(OUT / 'source_then_rtl_C2_B2_C4_A4_C5_F5.wav', np.concatenate(comparisons))
    report = {
        'rom_sha256': hashlib.sha256((ROOT / 'src/rom/marimba42.hex').read_bytes()).hexdigest(),
        'matched_rtl_samples': len(rtl), 'unchanged_C4_and_above': True,
        'scope': 'mf source left channel; source onsets and modal identities from fitter',
        'preview': 'Each selected note: source then RTL; source gain matched to RTL 300 ms weighted RMS, no synth normalization',
        'tail_metric': 'RMS 300-500 ms / RMS 0-100 ms; includes integer noise floor',
        'notes': results,
    }
    (OUT / 'report.json').write_text(json.dumps(report, indent=2), encoding='utf-8')
    print(f'PASS: {len(rtl)} exact RTL samples; C2-F5 analysis; C4+ unchanged')


if __name__ == '__main__':
    main()
