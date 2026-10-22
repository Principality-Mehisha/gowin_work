"""Fit measured AIFF modes, then calibrate the complete integer output chain."""
from __future__ import annotations

import hashlib
import json
import math
import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "output/audio_tools"))
sys.path.insert(0, str(ROOT / "output/marimba_tools"))
import numpy as np
from scipy import signal

from marimba_reference import OUT_FS, decode_modes, render_note

SOURCE = ROOT / "assets/marimba/source"
ROM = ROOT / "src/rom"
NOTE_FIRST, NOTE_LAST = 36, 77
ANALYSIS_FS = 24000
CALIBRATION_DYNAMICS = 192
LOUDNESS_TARGET = 1000.0
BASS_BOOST_DB = 3.0  # Mild trim: -1 dB at B2, tapering to no change at C4.
BASS_BOOST_START = 47  # Preserve B2..F5; C2..B2 share the +3 dB plateau.
BASS_BOOST_END = 60  # C4


def bass_boost_db(midi: int) -> float:
    position = min(1.0, max(0.0, (midi - BASS_BOOST_START) /
                            (BASS_BOOST_END - BASS_BOOST_START)))
    return BASS_BOOST_DB * .5 * (1 + math.cos(math.pi * position))


def read_aiff(path: Path) -> tuple[np.ndarray, float]:
    data = path.read_bytes()
    if data[:4] != b"FORM" or data[8:12] != b"AIFF":
        raise ValueError(f"not uncompressed AIFF: {path}")
    pos = 12
    comm = sound = None
    while pos + 8 <= len(data):
        size = struct.unpack_from(">I", data, pos + 4)[0]
        payload = data[pos + 8:pos + 8 + size]
        if data[pos:pos + 4] == b"COMM":
            comm = payload
        elif data[pos:pos + 4] == b"SSND":
            offset = struct.unpack_from(">I", payload)[0]
            sound = payload[8 + offset:]
        pos += 8 + size + (size & 1)
    if comm is None or sound is None:
        raise ValueError(f"missing AIFF chunks: {path}")
    channels, frames, width = struct.unpack(">hIh", comm[:8])
    exponent, mantissa = struct.unpack(">HQ", comm[8:18])
    rate = math.ldexp(mantissa, (exponent & 32767) - 16383 - 63)
    if exponent & 32768:
        rate = -rate
    if channels != 2 or width != 24 or rate <= 0 or len(sound) < frames * 6:
        raise ValueError(f"unsupported or truncated AIFF: {path}")
    packed = np.frombuffer(sound[:frames * 6], dtype=np.uint8)
    packed = packed.reshape(frames, 2, 3).astype(np.int32)
    values = (packed[:, :, 0] << 16) | (packed[:, :, 1] << 8) | packed[:, :, 2]
    values = np.where(values & 0x800000, values - 0x1000000, values)
    return values[:, 0].astype(np.float64) / 8388608, rate


def spectrum(samples: np.ndarray):
    size = 1 << max(16, (len(samples) * 4 - 1).bit_length())
    magnitude = abs(np.fft.rfft(samples * np.hanning(len(samples)), n=size))
    return np.fft.rfftfreq(size, 1 / ANALYSIS_FS), magnitude


def spectral_peak(frequencies, magnitude, low, high):
    candidates, _ = signal.find_peaks(magnitude)
    candidates = candidates[(frequencies[candidates] >= low) &
                            (frequencies[candidates] <= high)]
    if not len(candidates):
        return None
    index = candidates[np.argmax(magnitude[candidates])]
    a, b, c = np.log(np.maximum(magnitude[index - 1:index + 2], 1e-30))
    correction = 0.5 * (a - c) / (a - 2 * b + c)
    return float((index + correction) * frequencies[1]), float(magnitude[index])


def locate_notes(samples: np.ndarray, midis: list[int]):
    block = round(ANALYSIS_FS * .005)
    blocks = samples[:len(samples) // block * block].reshape(-1, block)
    energy = np.sqrt(np.mean(blocks * blocks, axis=1))
    smooth = np.convolve(energy, [0.25, 0.5, 0.25], mode="same")
    novelty = np.maximum(0, smooth - np.r_[np.zeros(6), smooth[:-6]])
    candidates, _ = signal.find_peaks(
        novelty, distance=round(.35 / .005), prominence=novelty.max() * .002)
    spectra = []
    for candidate in candidates:
        start = max(0, candidate * block - round(.02 * ANALYSIS_FS))
        frequencies, magnitude = spectrum(
            samples[start:start + round(.22 * ANALYSIS_FS)])
        useful = (frequencies > 40) & (frequencies < 1500)
        spectra.append((candidate, frequencies, magnitude, magnitude[useful].max()))
    result = {}
    for midi in midis:
        expected = 440 * 2 ** ((midi - 69) / 12)
        choices = []
        for candidate, frequencies, magnitude, maximum in spectra:
            peak = spectral_peak(frequencies, magnitude, expected * .97, expected * 1.03)
            if peak is None:
                continue
            measured, strength = peak
            cents = 1200 * math.log2(measured / expected)
            if abs(cents) < 35 and strength > maximum * .45:
                choices.append((novelty[candidate] * strength, candidate))
        if not choices:
            raise RuntimeError(f"no validated strike for MIDI {midi}")
        _, candidate = max(choices)
        # Refine each isolated strike at 1 ms resolution rather than allowing
        # a late 5 ms energy block to discard its short upper-mode transient.
        first = max(0, candidate * block - round(.20 * ANALYSIS_FS))
        last = candidate * block + round(.04 * ANALYSIS_FS)
        step = round(.001 * ANALYSIS_FS)
        part = samples[first:last]
        envelope = np.sqrt(np.mean(
            part[:len(part) // step * step].reshape(-1, step) ** 2, axis=1))
        baseline = envelope[:max(1, round(.05 / .001))]
        median = np.median(baseline)
        noise = median + 8 * np.median(abs(baseline - median))
        envelope = np.convolve(envelope, np.ones(3) / 3, mode="same")
        threshold = max(noise, envelope.max() * .06)
        anchor = int(np.argmax(envelope))
        crossing = anchor
        # Follow the actual strike back to its threshold crossing. An earlier
        # isolated room-noise burst is not the start of the bar excitation.
        while crossing > 0 and envelope[crossing - 1] > threshold:
            crossing -= 1
        onset = first + max(0, crossing - 2) * step
        result[midi] = onset
    assert all(result[a] < result[b] for a, b in zip(midis, midis[1:]))
    return result


def modal_envelope(samples: np.ndarray, frequency: float):
    duration = max(.006, min(.060, 6 / frequency))
    size = round(duration * ANALYSIS_FS)
    hop = max(24, size // 3)
    window = np.hanning(size)
    kernel = window * np.exp(-2j * np.pi * frequency *
                             np.arange(size) / ANALYSIS_FS)
    starts = np.arange(0, min(len(samples) - size, round(.9 * ANALYSIS_FS)), hop)
    amplitudes = np.array([
        2 * abs(np.dot(samples[start:start + size], kernel)) / window.sum()
        for start in starts])
    times = (starts + (size - 1) / 2) / ANALYSIS_FS
    return times, amplitudes


def fit_mode(samples: np.ndarray, frequency: float):
    times, amplitudes = modal_envelope(samples, frequency)
    early = np.flatnonzero(times < .10)
    peak_index = early[np.argmax(amplitudes[early])]
    peak = float(amplitudes[peak_index])
    keep = (np.arange(len(times)) >= peak_index) & (times <= .75)
    keep &= amplitudes > max(peak * .035, 1e-6)
    if np.count_nonzero(keep) < 3 or peak < 2e-6:
        return None
    for _ in range(3):
        slope, intercept = np.polyfit(times[keep], np.log(amplitudes[keep]), 1)
        residual = np.log(np.maximum(amplitudes, 1e-30)) - (slope * times + intercept)
        keep &= abs(residual) < max(.35, 2.5 * float(np.std(residual[keep])))
        if np.count_nonzero(keep) < 3:
            return None
    if slope >= 0:
        return None
    tau = -1 / slope
    if not .003 <= tau <= 3.0:
        return None
    gain = min(math.exp(intercept), peak * 2)
    return {"gain": gain, "tau_seconds": tau, "fit_points": int(keep.sum()),
            "decay": math.exp(-1 / (OUT_FS * tau))}


def fit_note(samples: np.ndarray, midi: int, onset: int):
    note = samples[onset:onset + round(1.2 * ANALYSIS_FS)]
    expected = 440 * 2 ** ((midi - 69) / 12)
    frequencies, magnitude = spectrum(note[:round(.25 * ANALYSIS_FS)])
    fundamental = spectral_peak(frequencies, magnitude, expected * .97, expected * 1.03)
    if fundamental is None:
        raise RuntimeError(f"missing source fundamental MIDI {midi}")
    measured, _ = fundamental
    assert abs(1200 * math.log2(measured / expected)) < 35
    modes = []
    ranges = ((.97, 1.03), (3.7, 4.35), (9.0, 11.8), (16.5, 20.5))
    for index, (low, high) in enumerate(ranges):
        choices = []
        for seconds in (.018, .045, .12):
            f, mag = spectrum(note[:round(seconds * ANALYSIS_FS)])
            peak = spectral_peak(f, mag, measured * low, min(11000, measured * high))
            if peak is not None:
                choices.append((peak[1] / np.hanning(round(seconds * ANALYSIS_FS)).sum(),
                                peak[0]))
        source_frequency = measured if index == 0 else (
            max(choices)[1] if choices else measured * (low + high) / 2)
        fitted = fit_mode(note, source_frequency)
        frequency = expected * source_frequency / measured
        disabled = None
        if frequency >= OUT_FS / 2:
            disabled = "above output Nyquist"
        elif fitted is None:
            disabled = "no reliable decaying component"
        elif index and fitted["gain"] < modes[0]["gain"] * 10 ** (-52 / 20):
            disabled = "below -52 dB relative to fundamental"
        elif index >= 2 and fitted["tau_seconds"] > modes[0]["tau_seconds"]:
            disabled = "stationary residual, not a short upper mode"
        if index == 0 and disabled:
            raise RuntimeError(f"unreliable fundamental MIDI {midi}: {disabled}")
        modes.append({
            "frequency": frequency, "source_frequency": source_frequency,
            "ratio": source_frequency / measured,
            "gain": 0.0 if disabled else fitted["gain"],
            "tau_seconds": None if fitted is None else fitted["tau_seconds"],
            "decay": 0.0 if disabled else fitted["decay"],
            "fit_points": 0 if fitted is None else fitted["fit_points"],
            "disabled": disabled,
        })
    # Estimate the broadband mallet residual after removing measured decaying
    # sinusoids with freely fitted source phases; no waveform goes into ROM.
    count = round(.04 * ANALYSIS_FS)
    time = np.arange(count) / ANALYSIS_FS
    columns = []
    for mode in modes:
        if mode["gain"]:
            envelope = np.exp(-time / mode["tau_seconds"])
            angle = 2 * np.pi * mode["source_frequency"] * time
            columns.extend((envelope * np.sin(angle), envelope * np.cos(angle)))
    basis = np.array(columns).T
    residual = note[:count] - basis @ np.linalg.lstsq(basis, note[:count], rcond=None)[0]
    band = signal.butter(2, [1500, 7500], btype="bandpass",
                         fs=ANALYSIS_FS, output="sos")
    residual = signal.sosfilt(band, residual)[:round(.018 * ANALYSIS_FS)]
    attack = min(float(np.sqrt(np.mean(residual ** 2))) * 2.5,
                 sum(mode["gain"] for mode in modes) * .15)
    return {"midi": midi, "source_fundamental": measured,
            "source_detuning_cents": 1200 * math.log2(measured / expected),
            "onset_seconds": onset / ANALYSIS_FS,
            "modes": modes, "attack": attack, "attack_seconds": .018}


def loudness_metric(samples: np.ndarray):
    # A repeatable loudness proxy, not LUFS: suppress low-frequency/DC energy
    # and modestly emphasize the mallet band before a 300 ms RMS measurement.
    part = samples[:round(.3 * OUT_FS)].astype(np.float64)
    body = signal.sosfilt(signal.butter(
        2, 80, btype="highpass", fs=OUT_FS, output="sos"), part)
    bright = signal.sosfilt(signal.butter(
        1, 1500, btype="highpass", fs=OUT_FS, output="sos"), body)
    weighted = body + .5 * bright
    return float(np.sqrt(np.mean(weighted ** 2)))


def pack_note(row, scale):
    packed = []
    for index, mode in enumerate(row["modes"]):
        # Compensate the existing upper-mode velocity curve at reference mf.
        gain = mode["gain"] * scale * (1 if index == 0 else 192 / 144)
        if gain > .95:
            raise RuntimeError(f"calibration gain overflow: MIDI {row['midi']}")
        step = round(mode["frequency"] * 2**32 / OUT_FS) if gain else 0
        decay = min(32767, max(0, round(mode["decay"] * 32768)))
        packed.append((step << 32) | (round(gain * 32768) << 16) | decay)
    attack_gain = round(row["attack"] * scale * (192 / 144) * 32768)
    if attack_gain > 30000:
        raise RuntimeError("attack gain overflow")
    attack_step = max(1, round(attack_gain / (row["attack_seconds"] * OUT_FS)))
    value = sum(mode << (64 * index) for index, mode in enumerate(packed))
    return value, (attack_gain << 16) | attack_step


def main():
    rows_by_dynamics = {}
    sources = []
    for dynamics in ("pp", "mf", "ff"):
        rows_by_dynamics[dynamics] = {}
        for band, first in (("C2B2", 36), ("C3B3", 48),
                            ("C4B4", 60), ("C5B5", 72)):
            path = SOURCE / dynamics / f"Marimba.yarn.{dynamics}.{band}.aif"
            samples, rate = read_aiff(path)
            if rate != 96000:
                raise ValueError(f"unexpected source rate; review resampling: {path}")
            samples = signal.resample_poly(samples, 1, 4)
            midis = list(range(max(NOTE_FIRST, first), min(NOTE_LAST + 1, first + 12)))
            onsets = locate_notes(samples, midis)
            for midi in midis:
                row = fit_note(samples, midi, onsets[midi])
                row["source_file"] = str(path.relative_to(ROOT))
                rows_by_dynamics[dynamics][midi] = row
            sources.append({"file": str(path.relative_to(ROOT)), "sample_rate": rate,
                            "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
                            "onsets_seconds": {str(midi): onsets[midi] / ANALYSIS_FS
                                               for midi in midis}})
            print(f"Validated and fitted {dynamics} {band}", flush=True)
    # Keep a coherent mf modal set. Other dynamics are independently measured
    # and recorded, never averaged across unrelated spectral peaks.
    rows = [rows_by_dynamics["mf"][midi] for midi in range(NOTE_FIRST, NOTE_LAST + 1)]
    sine = [int(line, 16) for line in (ROM / "sine256.hex").read_text().splitlines()]
    sine = [value - 65536 if value >= 32768 else value for value in sine]
    mode_lines, attack_lines = [], []
    for index, row in enumerate(rows):
        boost_db = bass_boost_db(row["midi"])
        target = LOUDNESS_TARGET * 10 ** (boost_db / 20)
        scale = .65 / max(sum(mode["gain"] for mode in row["modes"]), 1e-9)
        for _ in range(6):
            mode_word, attack_word = pack_note(row, scale)
            audio = render_note(decode_modes(mode_word), attack_word, sine, index,
                                note_first=NOTE_FIRST)
            measured = loudness_metric(audio)
            error_db = 20 * math.log10(measured / target)
            if abs(error_db) < .04:
                break
            scale *= target / measured
        assert abs(error_db) < .12, (row["midi"], error_db)
        assert max(abs(audio)) < 12000, row["midi"]
        row["calibration"] = {
            "gain_scale": scale, "weighted_rms": measured, "error_db": error_db,
            "target_weighted_rms": target, "bass_boost_db": boost_db,
            "peak_pcm": int(max(abs(audio))),
            "rms_0_100ms": float(np.sqrt(np.mean(audio[:round(.1 * OUT_FS)] ** 2))),
        }
        mode_lines.append(f"{mode_word:064x}\n")
        attack_lines.append(f"{attack_word:08x}\n")
        print(f"MIDI {row['midi']}: RMS={measured:.2f}, peak={max(abs(audio))}", flush=True)
    (ROM / "marimba42.hex").write_text("".join(mode_lines), encoding="ascii")
    (ROM / "marimba_attack42.hex").write_text("".join(attack_lines), encoding="ascii")
    report = {
        "version": 4, "source": "University of Iowa MIS yarn mallet AIFF",
        "sample_rate": 96000, "analysis_sample_rate": ANALYSIS_FS,
        "output_sample_rate": OUT_FS, "notes": [row["midi"] for row in rows],
        "tuning": "equal temperament A4=440 Hz; measured source modal ratios retained",
        "decay_method": "fit log amplitude per second, exp(-1/(output_rate*tau)), Q15",
        "dynamics_method": "mf modes; existing linear fundamental/quadratic brightness",
        "body_filter": "existing fixed 385/727 Hz coloration, included in calibration",
        "apple_reference_calibration": "KEY0 reference retained; no four-note attack offsets",
        "loudness_calibration": {
            "dynamics": CALIBRATION_DYNAMICS, "target": LOUDNESS_TARGET,
            "bass_boost": {
                "maximum_db": BASS_BOOST_DB, "first_midi": NOTE_FIRST,
                "plateau_end_midi": BASS_BOOST_START,
                "end_midi": BASS_BOOST_END,
                "curve": "flat C2-B2; raised cosine B2-C4; zero at and above C4",
            },
            "method": "80 Hz highpass, +0.5 of 1500 Hz highpass, RMS of first 300 ms",
            "unit": "weighted PCM RMS proxy, not LUFS",
            "scope": "complete integer modal/noise/body/limiter chain; one gain per note",
        },
        "sources": sources, "rows": rows,
        "measured_by_dynamics": rows_by_dynamics,
    }
    report["mode_rom_sha256"] = hashlib.sha256((ROM / "marimba42.hex").read_bytes()).hexdigest()
    (ROOT / "assets/marimba/fit_report.json").write_text(
        json.dumps(report, indent=2), encoding="ascii")
    print("PASS: regenerated 42 measured, tuned, loudness-calibrated notes")


if __name__ == "__main__":
    main()
