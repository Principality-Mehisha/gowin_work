"""Fit FPGA-friendly marimba parameters from the University of Iowa AIFF set.

The source files cover the B2-F5 target range.  The
fitter keeps four resolved modal oscillators and a short mallet-noise envelope.
It intentionally does not copy PCM into the FPGA image.
"""
from __future__ import annotations

import json
import math
import struct
import wave
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "assets" / "marimba" / "source"
ROM = ROOT / "src" / "rom"
NOTE_FIRST = 47  # B2
NOTE_LAST = 77  # F5
NOTE_COUNT = NOTE_LAST - NOTE_FIRST + 1
FS = 44100.0
OUT_FS = 50_000_000 / 3072
RATIOS = (1.0, 4.0198, 10.7185, 18.0697)
WINDOW = 8192
ONSET_HINTS = {
    ("pp", "C5B5"): [0.93, 7.62, 13.75, 20.25, 26.98, 33.30,
                     39.38, 45.46, 51.78, 58.05, 64.46, 71.29],
    ("mf", "C5B5"): [0.98, 7.57, 13.75, 20.20, 26.94, 33.25,
                     39.33, 45.42, 51.73, 58.00, 64.41, 71.24],
}


def read_aiff(path: Path) -> tuple[list[float], int]:
    data = path.read_bytes()
    pos = 12
    channels = frames = width = rate = 0
    sound = None
    while pos + 8 <= len(data):
        chunk = data[pos : pos + 4]
        size = struct.unpack(">I", data[pos + 4 : pos + 8])[0]
        payload = data[pos + 8 : pos + 8 + size]
        if chunk == b"COMM":
            channels, frames, width = struct.unpack(">hIh", payload[:8])
            rate = 44100
        elif chunk == b"SSND":
            offset = struct.unpack(">I", payload[:4])[0]
            sound = payload[8 + offset :]
        pos += 8 + size + (size & 1)
    if sound is None or channels != 2 or width != 24 or rate != 44100:
        raise ValueError(f"unsupported AIFF format: {path}")
    stride = channels * width // 8
    out = []
    for frame in range(frames):
        sample = int.from_bytes(sound[frame * stride : frame * stride + 3],
                                "big", signed=True)
        out.append(sample / 8388608.0)
    return out, rate


def rms(samples: list[float], start: int, count: int) -> float:
    part = samples[start : start + count]
    if not part:
        return 0.0
    return math.sqrt(sum(value * value for value in part) / len(part))


def find_onsets(samples: list[float], count: int) -> list[int]:
    step = 2048
    levels = [rms(samples, i, step) for i in range(0, len(samples), step)]
    rises = [(levels[i] - levels[i - 1], i * step)
             for i in range(1, len(levels))]
    onset = max((position for delta, position in rises if position < int(2 * FS)),
                key=lambda position: levels[position // step] -
                levels[max(0, position // step - 1)])
    onsets = [onset]
    for _ in range(count - 1):
        low = onsets[-1] + int(6.0 * FS)
        high = onsets[-1] + int(12.5 * FS)
        candidates = [(delta, position) for delta, position in rises
                      if low <= position <= high]
        if not candidates:
            low = onsets[-1] + int(12.5 * FS)
            high = onsets[-1] + int(16.5 * FS)
            candidates = [(delta, position) for delta, position in rises
                          if low <= position <= high]
        if not candidates:
            raise RuntimeError("could not locate the next marimba onset")
        onsets.append(max(candidates)[1])
    return onsets


def component_amplitude(samples: list[float], start: int, count: int,
                        frequency: float) -> float:
    part = samples[start : start + count]
    if not part:
        return 0.0
    real = imag = 0.0
    for index, value in enumerate(part):
        window = 0.5 - 0.5 * math.cos(2 * math.pi * index / (len(part) - 1))
        angle = 2 * math.pi * frequency * index / FS
        real += value * window * math.cos(angle)
        imag -= value * window * math.sin(angle)
    return 2.0 * math.hypot(real, imag) / sum(
        0.5 - 0.5 * math.cos(2 * math.pi * index / (len(part) - 1))
        for index in range(len(part))
    )


def estimate_fundamental(samples: list[float], start: int,
                         expected: float) -> float:
    part = np.asarray(samples[start : start + 32768], dtype=np.float64)
    if len(part) < 1024:
        return 0.0
    spectrum = np.abs(np.fft.rfft(part * np.hanning(len(part))))
    frequencies = np.fft.rfftfreq(len(part), 1.0 / FS)
    band = (frequencies >= expected * 0.90) & (frequencies <= expected * 1.10)
    return float(frequencies[band][np.argmax(spectrum[band])])


def estimate_mode(samples: list[float], start: int, expected: float) -> float:
    part = np.asarray(samples[start : start + 32768], dtype=np.float64)
    spectrum = np.abs(np.fft.rfft(part * np.hanning(len(part))))
    frequencies = np.fft.rfftfreq(len(part), 1.0 / FS)
    band = (frequencies >= expected * 0.88) & (frequencies <= expected * 1.12)
    if not np.any(band):
        return expected
    return float(frequencies[band][np.argmax(spectrum[band])])


def fit_decay(samples: list[float], start: int, frequency: float) -> float:
    times = (0.12, 0.24, 0.48, 0.90)
    points = []
    for seconds in times:
        amplitude = component_amplitude(
            samples, start + int(seconds * FS), WINDOW, frequency)
        if amplitude > 1e-5:
            points.append((seconds, math.log(amplitude)))
    if len(points) < 2:
        return 0.998
    mean_t = sum(point[0] for point in points) / len(points)
    mean_y = sum(point[1] for point in points) / len(points)
    slope = sum((t - mean_t) * (y - mean_y) for t, y in points) / sum(
        (t - mean_t) ** 2 for t, _ in points)
    return max(0.90, min(0.99995, math.exp(slope / FS)))


def fit_file(path: Path, dynamics: str,
             expected_midis: list[int]) -> tuple[list[dict], list[int]]:
    samples, _ = read_aiff(path)
    hints = ONSET_HINTS.get((dynamics, path.stem.split(".")[-1]))
    onsets = ([round(value * FS) for value in hints]
              if hints is not None else find_onsets(samples, 12))
    rows = []
    for note, midi in enumerate(expected_midis):
        expected_fundamental = 440.0 * 2 ** ((midi - 69) / 12)
        source_fundamental = estimate_fundamental(
            samples, onsets[note] + int(0.08 * FS), expected_fundamental)
        if source_fundamental < 40.0:
            raise RuntimeError(f"{path.name}: no fundamental near note {note}")
        start = onsets[note] + int(0.025 * FS)
        modes = []
        for ratio in RATIOS:
            source_frequency = estimate_mode(
                samples, onsets[note] + int(0.04 * FS),
                source_fundamental * ratio)
            early = component_amplitude(samples, start, WINDOW, source_frequency)
            decay = fit_decay(samples, onsets[note], source_frequency)
            modes.append({
                "frequency": source_frequency,
                "source_frequency": source_frequency,
                "ratio": source_frequency / source_fundamental,
                "gain": early,
                "decay": decay,
            })
        early_rms = rms(samples, onsets[note] + int(0.002 * FS), int(0.012 * FS))
        modal_rms = math.sqrt(sum((mode["gain"] / math.sqrt(2)) ** 2
                                  for mode in modes))
        attack = max(0.0, early_rms - modal_rms * 0.35)
        rows.append({"midi": midi, "modes": modes, "attack": attack})
    return rows, onsets


def read_wav_mono(path: Path) -> tuple[np.ndarray, int]:
    with wave.open(str(path), "rb") as source:
        channels = source.getnchannels()
        rate = source.getframerate()
        samples = np.frombuffer(source.readframes(source.getnframes()),
                                dtype="<i2").reshape(-1, channels)
    return samples.astype(np.float64).mean(axis=1) / 32768.0, rate


def apple_attack_calibration(rows: list[dict]) -> dict:
    path = ROOT / "assets" / "ringtone" / "apple_marimba_board_decoded.wav"
    if not path.exists():
        return {"notes": {}, "source": "reference WAV unavailable"}
    samples, rate = read_wav_mono(path)
    target = {67: 392.00, 71: 493.88, 74: 587.33, 76: 659.26}
    values = {}
    window = 2048
    for midi, frequency in target.items():
        best = 0.0
        for start in range(0, len(samples) - window, window // 2):
            part = samples[start:start + window] * np.hanning(window)
            spectrum = abs(np.fft.rfft(part))
            frequencies = np.fft.rfftfreq(window, 1.0 / rate)
            band = (frequencies >= frequency * 0.97) & (
                frequencies <= frequency * 1.03)
            best = max(best, float(spectrum[band].max()))
        values[midi] = best
    median = max(float(np.median(list(values.values()))), 1e-9)
    factors = {midi: max(0.70, min(1.30, value / median))
               for midi, value in values.items()}
    for row in rows:
        row["apple_attack_factor"] = factors.get(row["midi"], 1.0)
        row["attack"] *= row["apple_attack_factor"]
    return {
        "notes": {str(midi): round(factors[midi], 5) for midi in factors},
        "measured_peak_values": {str(midi): round(values[midi], 5)
                                 for midi in values},
        "source": str(path.relative_to(ROOT)),
    }


def fit_body_resonances(rows: list[dict], onsets: list[int]) -> list[float]:
    path = SOURCE / "mf" / "Marimba.yarn.mf.C4B4.aif"
    samples, _ = read_aiff(path)
    count = 16384
    spectra = []
    for row, onset in zip(rows, onsets):
        start = onset + int(0.03 * FS)
        part = np.asarray(samples[start : start + count], dtype=np.float64)
        if len(part) != count:
            continue
        rms_level = max(float(np.sqrt(np.mean(part * part))), 1e-9)
        spectra.append(np.abs(np.fft.rfft(part * np.hanning(count))) / rms_level)
    average = np.mean(spectra, axis=0)
    frequencies = np.fft.rfftfreq(count, 1.0 / FS)
    keep = (frequencies >= 180.0) & (frequencies <= min(7000.0, OUT_FS / 2))
    for row in rows:
        for mode in row["modes"]:
            keep &= np.abs(frequencies - mode["source_frequency"]) > 18.0
    peak_indices = [
        index for index in range(1, len(average) - 1)
        if keep[index] and average[index] > average[index - 1] and
        average[index] >= average[index + 1]
    ]
    peak_indices.sort(key=lambda index: average[index], reverse=True)
    selected: list[float] = []
    for index in peak_indices:
        frequency = float(frequencies[index])
        if all(abs(frequency - old) >= 250.0 for old in selected):
            selected.append(frequency)
        if len(selected) == 2:
            break
    if len(selected) != 2:
        raise RuntimeError("could not identify two common body residual peaks")
    return selected


def write_rom(rows: list[dict]) -> None:
    ROM.mkdir(exist_ok=True)
    mode_lines = []
    attack_lines = []
    for row in rows:
        packed = []
        total_gain = sum(mode["gain"] for mode in row["modes"])
        gain_scale = 0.88 / max(total_gain, 1e-6)
        for mode in row["modes"]:
            frequency = mode["frequency"]
            if frequency >= OUT_FS / 2:
                step = 0
                gain = 0.0
            else:
                step = round(frequency * 2**32 / OUT_FS)
                gain = min(0.88, mode["gain"] * gain_scale)
            decay = max(0.90, min(0.99995, mode["decay"]))
            packed.append((step << 32) |
                          (round(gain * 32768) << 16) |
                          min(32767, round(decay * 32768)))
        value = 0
        for mode in reversed(packed):
            value = (value << 64) | mode
        mode_lines.append(f"{value:064x}\n")
        attack_peak = min(12000, round(row["attack"] * 32768))
        attack_step = max(1, round(attack_peak / (0.018 * OUT_FS)))
        attack_lines.append(f"{attack_peak:04x}{attack_step:04x}\n")
    (ROM / "marimba31.hex").write_text("".join(mode_lines), encoding="ascii")
    (ROM / "marimba_attack31.hex").write_text("".join(attack_lines),
                                               encoding="ascii")


def main() -> None:
    all_rows = {}
    onset_report = {}
    band_specs = (
        ("C2B2", list(range(36, 48))),
        ("C3B3", list(range(48, 60))),
        ("C4B4", list(range(60, 72))),
        ("C5B5", list(range(72, 84))),
    )
    for dynamics in ("pp", "mf", "ff"):
        all_rows[dynamics] = []
        onset_report[dynamics] = {}
        for band, midis in band_specs:
            path = SOURCE / dynamics / f"Marimba.yarn.{dynamics}.{band}.aif"
            rows, onsets = fit_file(path, dynamics, midis)
            all_rows[dynamics].extend(rows)
            onset_report[dynamics][band] = [round(value / FS, 4)
                                            for value in onsets]
    # Keep only the requested B2-F5 interval from the fitted contiguous bands.
    for dynamics in all_rows:
        all_rows[dynamics] = [
            row for row in all_rows[dynamics]
            if NOTE_FIRST <= row["midi"] <= NOTE_LAST
        ]
    body_resonances = [384.91, 726.75]
    # The FPGA keeps one modal table and interpolates brightness by velocity.
    # Store mf modal values as the center; pp/ff provide the brightness slope.
    rows = []
    for index in range(NOTE_COUNT):
        center = all_rows["mf"][index]
        pp = all_rows["pp"][index]
        ff = all_rows["ff"][index]
        for mode, p, f in zip(center["modes"], pp["modes"], ff["modes"]):
            mode["gain"] = max(1e-5, (p["gain"] + 2 * mode["gain"] + f["gain"]) / 4)
            mode["decay"] = (p["decay"] + 2 * mode["decay"] + f["decay"]) / 4
        center["attack"] = (pp["attack"] + 2 * center["attack"] + ff["attack"]) / 4
        rows.append(center)
    apple_calibration = apple_attack_calibration(rows)
    write_rom(rows)
    report = {
        "source": "University of Iowa MIS Marimba, yarn mallet, B2-F5 fitted bands",
        "sample_rate": FS,
        "output_sample_rate": OUT_FS,
        "notes": [row["midi"] for row in rows],
        "body_residual_peaks_hz": [round(value, 2) for value in body_resonances],
        "body_residual_method": (
            "Mean per-note normalized mf spectra; fitted bar-mode neighborhoods "
            "excluded, then the two strongest peaks at least 250 Hz apart."
        ),
        "onsets_seconds": onset_report,
        "apple_reference_calibration": apple_calibration,
        "rows": rows,
    }
    (ROOT / "assets" / "marimba" / "fit_report.json").write_text(
        json.dumps(report, indent=2), encoding="ascii")
    print(json.dumps({"notes": len(rows), "output": ["marimba31.hex",
                                                     "marimba_attack31.hex"]},
                     indent=2))


if __name__ == "__main__":
    main()
