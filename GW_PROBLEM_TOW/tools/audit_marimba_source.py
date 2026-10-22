"""Audit the existing marimba ROM against its source without changing synthesis."""
from __future__ import annotations

import hashlib
import json
import math
import struct
import subprocess
import sys
import wave
import zipfile
import zlib
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "sim" / "marimba_source_audit"
OUT_FS = 50_000_000 / 3072
SOURCE = ROOT / "assets" / "marimba" / "source"
BASELINE = ROOT / "sim" / "marimba_before_fix"


def read_aiff(path: Path) -> tuple[np.ndarray, float, dict]:
    data = path.read_bytes()
    assert data[:4] == b"FORM" and data[8:12] == b"AIFF"
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
    assert comm is not None and sound is not None
    channels, frames, width = struct.unpack(">hIh", comm[:8])
    exponent, mantissa = struct.unpack(">HQ", comm[8:18])
    rate = math.ldexp(mantissa, (exponent & 32767) - 16383 - 63)
    if exponent & 32768:
        rate = -rate
    assert channels == 2 and width == 24 and len(sound) >= frames * 6
    packed = np.frombuffer(sound[:frames * 6], dtype=np.uint8)
    packed = packed.reshape(frames, channels, 3).astype(np.int32)
    pcm = (packed[:, :, 0] << 16) | (packed[:, :, 1] << 8) | packed[:, :, 2]
    pcm = np.where(pcm & 0x800000, pcm - 0x1000000, pcm)
    # Match the existing fitter's left-channel selection.
    mono = pcm[:, 0].astype(np.float64) / 8388608
    return mono, rate, {
        "path": str(path.relative_to(ROOT)), "sample_rate": rate,
        "rate_bytes": comm[8:18].hex(), "frames": frames,
        "channels": channels, "bits": width,
        "sha256": hashlib.sha256(data).hexdigest(),
        "crc32": zlib.crc32(data),
    }


def peak_frequency(pcm: np.ndarray, rate: float, expected: float) -> float:
    window = np.hanning(len(pcm))
    nfft = 1 << (len(pcm) * 4 - 1).bit_length()
    spectrum = abs(np.fft.rfft(pcm * window, n=nfft))
    frequencies = np.fft.rfftfreq(nfft, 1 / rate)
    candidates = np.flatnonzero(
        (frequencies >= expected * 0.97) &
        (frequencies <= expected * 1.03))
    index = candidates[np.argmax(spectrum[candidates])]
    a, b, c = np.log(np.maximum(spectrum[index - 1:index + 2], 1e-30))
    correction = 0.5 * (a - c) / (a - 2 * b + c)
    return float((index + correction) * rate / nfft)


def detect_strikes(pcm: np.ndarray, rate: float, first_midi: int) -> list[int]:
    step = round(rate * 0.01)
    blocks = pcm[:len(pcm) // step * step].reshape(-1, step)
    energy = np.sqrt(np.mean(blocks * blocks, axis=1))
    candidates = np.flatnonzero(
        (energy[1:-1] > energy[:-2]) &
        (energy[1:-1] >= energy[2:])) + 1
    selected = []
    for index in sorted(candidates, key=lambda i: energy[i], reverse=True):
        if all(abs(index - old) > 150 for old in selected):
            selected.append(int(index))
        if len(selected) == 12:
            break
    selected.sort()
    assert len(selected) == 12
    onsets = []
    for ordinal, index in enumerate(selected):
        # Refine back to the first 10 ms block above 15% of the strike peak.
        start = index
        while start > max(0, index - 30) and energy[start - 1] > energy[index] * .15:
            start -= 1
        onset = start * step
        expected = 440 * 2 ** ((first_midi + ordinal - 69) / 12)
        measured = peak_frequency(pcm[onset:onset + round(rate * .15)],
                                  rate, expected)
        cents = 1200 * math.log2(measured / expected)
        if 47 <= first_midi + ordinal <= 77:
            assert abs(cents) < 35, (first_midi + ordinal, cents)
        onsets.append(onset)
    return onsets


def decode_modes(row: int) -> list[tuple[int, int, int]]:
    return [((row >> (i * 64 + 32)) & 0xffffffff,
             (row >> (i * 64 + 16)) & 65535,
             (row >> (i * 64)) & 65535) for i in range(4)]


def tail_ratio_db(pcm: np.ndarray, rate: float) -> float:
    early = pcm[:round(rate * .1)].astype(np.float64)
    late = pcm[round(rate * .3):round(rate * .5)].astype(np.float64)
    return 20 * math.log10(
        max(float(np.sqrt(np.mean(late * late))), 1e-10) /
        max(float(np.sqrt(np.mean(early * early))), 1e-10))


def render_note(modes, attack, sine, note_index, frames=16276):
    phase = [0] * 4
    level = [mode[1] for mode in modes]
    noise_level, noise_step = attack >> 16, attack & 65535
    lfsr = (0x1ace + note_index) & 65535
    r1_y1 = r1_y2 = r2_y1 = r2_y2 = 0
    pcm = np.empty(frames, dtype=np.int32)
    for frame in range(frames):
        mixed = 0
        for i, (step, _, decay) in enumerate(modes):
            if level[i] == 0:
                continue
            address = phase[i] >> 24
            fraction = (phase[i] >> 16) & 255
            value = sine[address] + (
                (sine[(address + 1) & 255] - sine[address]) * fraction >> 8)
            amplitude = value * (level[i] & 32767) >> 15
            mixed += amplitude * (192 if i == 0 else 144) >> 8
            level[i] = level[i] * (decay & 32767) >> 15
            phase[i] = (phase[i] + step) & 0xffffffff
        if noise_level:
            mixed += (((lfsr & 255) - 128) *
                      (noise_level & 32767) >> 7) * 144 >> 8
            noise_level = max(0, noise_level - noise_step)
            feedback = ((lfsr >> 15) ^ (lfsr >> 13) ^
                        (lfsr >> 12) ^ (lfsr >> 10)) & 1
            lfsr = ((lfsr << 1) | feedback) & 65535
            if lfsr == 0:
                lfsr = 0x1ace
        r1 = (mixed >> 4) + (r1_y1 * 30138 >> 14) - (r1_y2 * 14171 >> 14)
        r2 = (mixed >> 5) + (r2_y1 * 27708 >> 14) - (r2_y2 * 12688 >> 14)
        r1_y2, r1_y1 = r1_y1, r1
        r2_y2, r2_y1 = r2_y1, r2
        body = mixed + (r1 >> 2) + (r2 >> 3)
        sample = (body + (1 if body < 0 else 2)) >> 2
        # The current isolated-note render never needs limiter attenuation.
        assert abs(sample) <= 30000
        pcm[frame] = sample
    return pcm


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    # Preserve this diagnosis of the faulty version after the current ROM
    # has been corrected. The audio/parameter snapshot was saved before edits.
    old = json.loads((BASELINE / "fit_report.json").read_text())
    rom_path = BASELINE / "marimba31.hex"
    rom = [int(row, 16) for row in rom_path.read_text().splitlines()]
    attack = [int(row, 16) for row in
              (BASELINE / "marimba_attack31.hex").read_text().splitlines()]
    sine = [int(row, 16) for row in
            (ROOT / "src/rom/sine256.hex").read_text().splitlines()]
    sine = [value - 65536 if value >= 32768 else value for value in sine]
    rtl = np.loadtxt(BASELINE / "marimba_scale_pcm.txt", dtype=np.int32)
    assert rtl.shape == (31 * 16276, 3)
    report = {"mode_rom_sha256": hashlib.sha256(rom_path.read_bytes()).hexdigest(),
              "source_files": [], "notes": [], "rtl_match_frames": 0}
    clips = {}
    for dynamics in ("pp", "mf", "ff"):
        with zipfile.ZipFile(SOURCE / f"Marimba.yarn.{dynamics}.zip") as archive:
            for band, first in (("C2B2", 36), ("C3B3", 48),
                                ("C4B4", 60), ("C5B5", 72)):
                path = SOURCE / dynamics / f"Marimba.yarn.{dynamics}.{band}.aif"
                pcm, rate, metadata = read_aiff(path)
                metadata["matches_archive_crc"] = (
                    metadata["crc32"] == archive.getinfo(path.name).CRC)
                assert metadata["matches_archive_crc"] and rate == 96000
                # pp has secondary energy peaks that need a separate pitched
                # onset detector; do not label those heuristic picks as verified.
                onsets = (detect_strikes(pcm, rate, first)
                          if dynamics in ("mf", "ff") else [])
                metadata["detected_onsets_seconds"] = [
                    round(onset / rate, 5) for onset in onsets]
                metadata["old_onsets_real_seconds"] = [
                    round(value * old["sample_rate"] / rate, 5)
                    for value in old["onsets_seconds"][dynamics][band]]
                report["source_files"].append(metadata)
                if dynamics != "mf":
                    continue
                for midi in range(max(47, first), min(78, first + 12)):
                    onset = onsets[midi - first]
                    segment = pcm[onset:onset + round(rate)]
                    clips[midi] = segment
                    expected = 440 * 2 ** ((midi - 69) / 12)
                    source_f0 = peak_frequency(segment[:round(rate * .20)],
                                               rate, expected)
                    i = midi - 47
                    modes = decode_modes(rom[i])
                    fundamental = modes[0][0] * OUT_FS / 2**32
                    levels = [mode[1] for mode in modes]
                    predicted = render_note(modes, attack[i], sine, i)
                    observed = rtl[rtl[:, 0] == midi, 2]
                    assert np.array_equal(predicted, observed), (
                        midi, np.flatnonzero(predicted != observed)[:5])
                    report["rtl_match_frames"] += len(observed)
                    decay = modes[0][2] / 32768
                    report["notes"].append({
                        "ordinal": i + 1, "midi_label": midi,
                        "source_file": path.name,
                        "source_onset_seconds": onset / rate,
                        "nominal_f0_hz": expected,
                        "source_measured_f0_hz": source_f0,
                        "rom_f0_hz": fundamental,
                        "rom_pitch_error_cents": 1200 * math.log2(fundamental / expected),
                        "source_tail_to_attack_rms_db": tail_ratio_db(segment, rate),
                        "rtl_tail_to_attack_rms_db": tail_ratio_db(observed, OUT_FS),
                        "rom_mode_frequencies_hz": [
                            mode[0] * OUT_FS / 2**32 for mode in modes],
                        "rom_mode_gain_q15": levels,
                        "mode2_to_fundamental_db": 20 * math.log10(
                            max(levels[1], 1) / max(levels[0], 1)),
                        "fundamental_decay_q15": modes[0][2],
                        "fundamental_exponential_tau_seconds_before_integer_floor":
                            -1 / (OUT_FS * math.log(decay)),
                    })
    report["notes"].sort(key=lambda row: row["ordinal"])
    report["decay_time_stretch_from_source_to_output"] = 96000 / OUT_FS
    report["old_source_rate_assumed"] = old["sample_rate"]
    report["actual_source_rate"] = 96000
    report["output_sample_rate"] = OUT_FS
    report["tail_rms_windows_seconds"] = {"early": [0, .1], "late": [.3, .5]}
    report["preview"] = {
        "ordinals": [14, 23], "midi_labels": [60, 69],
        "sample_rate": round(OUT_FS),
        "source_resampler": "FFmpeg, source 96000 Hz to 16276 Hz",
        "per_note_peak_normalization": 20000,
        "end_fade_seconds": .01, "gap_seconds": .1,
    }
    (OUT / "report.json").write_text(json.dumps(report, indent=2), encoding="ascii")

    # Use FFmpeg solely to create a source listening reference with anti-alias
    # filtering, retaining the hardware output rate for a fair bandwidth check.
    sys.path.insert(0, str(ROOT / "output/audio_tools"))
    import imageio_ffmpeg
    raw_parts = []
    old_parts = []
    rate = round(OUT_FS)
    for midi in range(60, 70):
        converted = subprocess.run(
            [imageio_ffmpeg.get_ffmpeg_exe(), "-v", "error",
             "-f", "f64le", "-ar", "96000", "-ac", "1", "-i", "pipe:0",
             "-ar", str(rate), "-f", "s16le", "pipe:1"],
            input=clips[midi].astype("<f8").tobytes(), capture_output=True,
            check=True).stdout
        source_audio = np.frombuffer(converted, dtype="<i2").copy()
        old_audio = rtl[rtl[:, 0] == midi, 2].astype("<i2").copy()
        for audio, parts in ((source_audio, raw_parts), (old_audio, old_parts)):
            # Identical per-note peak normalization is for this A/B preview only.
            scaled = audio.astype(np.float64)
            scaled *= 20000 / max(float(np.max(np.abs(scaled))), 1)
            fade = round(rate * .01)
            scaled[-fade:] *= np.linspace(1, 0, fade)
            parts.append(np.rint(scaled).astype("<i2"))
            parts.append(np.zeros(round(rate * .1), dtype="<i2"))
    for name, parts in (("source_notes_14_23.wav", raw_parts),
                        ("current_notes_14_23.wav", old_parts)):
        with wave.open(str(OUT / name), "wb") as output:
            output.setnchannels(1)
            output.setsampwidth(2)
            output.setframerate(rate)
            output.writeframes(np.concatenate(parts).tobytes())
    print("PASS: all 12 AIFF files match source archives and declare 96000 Hz")
    print(f"PASS: Python integer model matches {report['rtl_match_frames']} RTL samples")
    for row in report["notes"]:
        if row["ordinal"] in (12, 13, 14, 15, 18, 21, 23, 24, 26):
            print(f"{row['ordinal']:2}: label={row['midi_label']} "
                  f"source_f0={row['source_measured_f0_hz']:.2f} "
                  f"rom_f0={row['rom_f0_hz']:.2f} "
                  f"mode2/f0={row['mode2_to_fundamental_db']:+.2f} dB")
    print("Reports and source/current previews:", OUT)


if __name__ == "__main__":
    main()
