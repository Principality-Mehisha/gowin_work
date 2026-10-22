"""Check rendered pitch, level continuity and integer arithmetic against RTL."""
from __future__ import annotations

import hashlib
import json
import math
from pathlib import Path

import numpy as np

from fit_marimba_params import loudness_metric
from marimba_reference import OUT_FS, decode_modes, render_note

ROOT = Path(__file__).resolve().parents[1]


def measured_pitch(samples, expected):
    part = samples[round(.025 * OUT_FS):round(.45 * OUT_FS)]
    nfft = 262144
    spectrum = abs(np.fft.rfft(part * np.hanning(len(part)), n=nfft))
    frequencies = np.fft.rfftfreq(nfft, 1 / OUT_FS)
    indices = np.flatnonzero(
        (frequencies >= expected * .98) & (frequencies <= expected * 1.02))
    index = indices[np.argmax(spectrum[indices])]
    a, b, c = np.log(np.maximum(spectrum[index - 1:index + 2], 1e-30))
    correction = .5 * (a - c) / (a - 2 * b + c)
    return float((index + correction) * OUT_FS / nfft)


def level_metrics(samples):
    peak = int(np.max(np.abs(samples)))
    return {
        "peak_pcm": peak,
        "weighted_rms": loudness_metric(samples),
        "rms_0_100ms": float(np.sqrt(np.mean(
            samples[:round(.1 * OUT_FS)].astype(np.float64) ** 2))),
    }


def main():
    fit = json.loads((ROOT / "assets/marimba/fit_report.json").read_text())
    rom_path = ROOT / "src/rom/marimba31.hex"
    rom_hash = hashlib.sha256(rom_path.read_bytes()).hexdigest()
    assert rom_hash == fit["mode_rom_sha256"], "ROM/report mismatch"
    rom = [int(line, 16) for line in rom_path.read_text().splitlines()]
    attacks = [int(line, 16) for line in
               (ROOT / "src/rom/marimba_attack31.hex").read_text().splitlines()]
    sine = [int(line, 16) for line in
            (ROOT / "src/rom/sine256.hex").read_text().splitlines()]
    sine = [value - 65536 if value >= 32768 else value for value in sine]
    rows = np.loadtxt(ROOT / "sim/marimba_scale_pcm.txt", dtype=np.int32)
    baseline = np.loadtxt(ROOT / "sim/marimba_before_fix/marimba_scale_pcm.txt",
                          dtype=np.int32)
    bass_baseline_path = ROOT / "sim/marimba_before_bass_boost"
    bass_baseline = np.loadtxt(bass_baseline_path / "marimba_scale_pcm.txt",
                              dtype=np.int32)
    old_modes = [int(line, 16) for line in
                 (bass_baseline_path / "marimba31.hex").read_text().splitlines()]
    old_attacks = [int(line, 16) for line in
                   (bass_baseline_path / "marimba_attack31.hex").read_text().splitlines()]
    assert rows.shape == baseline.shape == (31 * 16276, 3)
    assert rows.shape == bass_baseline.shape
    results = []
    matched = 0
    for index, midi in enumerate(range(47, 78)):
        selected = rows[rows[:, 0] == midi]
        assert np.array_equal(selected[:, 1], np.arange(16276))
        audio = selected[:, 2]
        modes = decode_modes(rom[index])
        expected = 440 * 2 ** ((midi - 69) / 12)
        assert abs(1200 * math.log2(modes[0][0] * OUT_FS / 2**32 / expected)) < .001
        for mode, measurement in zip(modes, fit["rows"][index]["modes"]):
            if measurement["disabled"]:
                assert mode[0] == mode[1] == 0
            else:
                assert 0 < mode[0] < 0x80000000 and 0 < mode[1] < 32768
                tau = measurement["tau_seconds"]
                assert abs(mode[2] - math.exp(-1 / (OUT_FS * tau)) * 32768) <= .501
        reference = render_note(modes, attacks[index], sine, index)
        assert np.array_equal(reference, audio), (
            "RTL arithmetic mismatch", midi,
            np.flatnonzero(reference != audio)[:5].tolist())
        matched += len(audio)
        pitch = measured_pitch(audio, expected)
        cents = 1200 * math.log2(pitch / expected)
        assert abs(cents) < 2, (midi, cents)
        metrics = level_metrics(audio)
        assert 0 < metrics["peak_pcm"] < 12000
        old_metrics = level_metrics(baseline[baseline[:, 0] == midi, 2])
        previous_audio = bass_baseline[bass_baseline[:, 0] == midi, 2]
        previous_metrics = level_metrics(previous_audio)
        boost = fit["rows"][index]["calibration"]["bass_boost_db"]
        measured_boost = 20 * math.log10(
            metrics["weighted_rms"] / previous_metrics["weighted_rms"])
        assert abs(measured_boost - boost) < .12, (midi, measured_boost, boost)
        if midi >= 60:
            assert rom[index] == old_modes[index] and attacks[index] == old_attacks[index]
            assert np.array_equal(audio, previous_audio), ("C4+ changed", midi)
        else:
            for current, previous in zip(modes, decode_modes(old_modes[index])):
                assert current[0] == previous[0] and current[2] == previous[2]
            assert metrics["weighted_rms"] >= previous_metrics["weighted_rms"]
        results.append({"ordinal": index + 1, "midi": midi,
                        "pitch_hz": pitch, "pitch_error_cents": cents,
                        "before_bass_boost": previous_metrics,
                        "target_bass_boost_db": boost,
                        "measured_bass_boost_db": measured_boost,
                        "before": old_metrics, "after": metrics})
    new_levels = np.array([row["after"]["weighted_rms"] for row in results])
    level_spread = float(20 * np.log10(new_levels.max() / new_levels.min()))
    adjacent = 20 * np.log10(new_levels[1:] / new_levels[:-1])
    targets = np.array([row["calibration"]["target_weighted_rms"] for row in fit["rows"]])
    residual = 20 * np.log10(new_levels / targets)
    assert max(abs(residual)) < .12
    assert max(abs(adjacent)) < .6
    boundary = {}
    for stage in ("before", "after"):
        a, b = results[12][stage], results[13][stage]
        boundary[stage] = {
            key + "_jump_db": 20 * math.log10(b[key] / a[key])
            for key in ("weighted_rms", "peak_pcm", "rms_0_100ms")}
    assert abs(boundary["after"]["peak_pcm_jump_db"]) < 1
    assert abs(boundary["after"]["rms_0_100ms_jump_db"]) < 1
    max_mode = max(mode[0] * OUT_FS / 2**32
                   for word in rom for mode in decode_modes(word) if mode[1])
    report = {
        "source": "ModelSim RTL samples, no per-note preview normalization",
        "mode_rom_sha256": rom_hash, "matched_samples": matched,
        "weighted_rms_spread_db": level_spread,
        "max_adjacent_weighted_rms_change_db": float(max(abs(adjacent))),
        "max_target_curve_error_db": float(max(abs(residual))),
        "bass_boost": fit["loudness_calibration"]["bass_boost"],
        "boundary_13_to_14": boundary,
        "maximum_enabled_modal_frequency_hz": max_mode,
        "maximum_rendered_pitch_error_cents": max(
            abs(row["pitch_error_cents"]) for row in results),
        "notes": results,
    }
    (ROOT / "sim/marimba_corrected_report.json").write_text(
        json.dumps(report, indent=2), encoding="ascii")
    print(json.dumps({key: value for key, value in report.items() if key != "notes"},
                     indent=2))
    print("PASS: all 31 notes, measured pitch/levels, 504556 exact RTL samples")


if __name__ == "__main__":
    main()
