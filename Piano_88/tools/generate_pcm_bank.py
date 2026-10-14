"""Build a recorded-piano mu-law ROM and previews. Run download_samples.ps1 first."""
from __future__ import annotations

import hashlib
import json
import wave
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
FS = 50_000_000 / 3072
SLOT = 15360
DEPTH = 262144
ROOTS = [(f"{name}{octave}", 12 * (octave + 1) + offset)
         for octave in range(1, 8) for name, offset in (("C", 0), ("Fs", 6))]
ROOTS.append(("C8", 108))
NAMES = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]


def encode_ulaw(value: int) -> int:
    sign = 0x80 if value < 0 else 0
    magnitude = min(abs(value), 32635) + 132
    exponent = max(0, magnitude.bit_length() - 8)
    mantissa = (magnitude >> (exponent + 3)) & 15
    return (~(sign | exponent << 4 | mantissa)) & 255


def decode_ulaw(code: int) -> int:
    bits = (~code) & 255
    magnitude = (((bits & 15) << 3) + 132) << ((bits >> 4) & 7)
    magnitude -= 132
    return -magnitude if bits & 128 else magnitude


def load_wav(path: Path) -> tuple[np.ndarray, int]:
    with wave.open(str(path), "rb") as source:
        if source.getsampwidth() != 2:
            raise ValueError(f"{path}: expected 16-bit PCM WAV")
        samples = np.frombuffer(source.readframes(source.getnframes()), "<i2")
        samples = samples.reshape(-1, source.getnchannels()).mean(axis=1) / 32768
        return samples, source.getframerate()


def prepare_sample(name: str, midi: int) -> tuple[np.ndarray, dict]:
    path = ROOT / "assets" / "piano" / f"{name}.wav"
    audio, source_fs = load_wav(path)
    # Suppress frequencies that could alias when the sample is transposed up.
    spectrum = np.fft.rfft(audio)
    frequencies = np.fft.rfftfreq(len(audio), 1 / source_fs)
    taper = np.clip((6500 - frequencies) / 500, 0, 1)
    audio = np.fft.irfft(spectrum * taper, n=len(audio))
    audio -= audio.mean()
    audible = np.flatnonzero(np.abs(audio) > np.max(np.abs(audio)) * 0.005)
    onset = max(0, int(audible[0]) - round(source_fs * 0.002))
    audio = audio[onset:]
    positions = np.arange(SLOT) * source_fs / FS
    pcm = np.interp(positions, np.arange(len(audio)), audio, right=0)
    pcm[:32] *= np.linspace(0, 1, 32)

    # Each key press plays once. Fade the recording to exact zero so the end
    # cannot repeat background noise or create a hard discontinuity.
    width = 2048
    pcm[-width:] *= np.linspace(1, 0, width)
    pcm = np.rint(pcm / max(np.max(np.abs(pcm)), 1e-9) * 18000).astype(np.int16)
    codes = np.array([encode_ulaw(int(value)) for value in pcm], dtype=np.uint8)
    decoded = np.array([decode_ulaw(int(code)) for code in codes], dtype=np.int16)
    if not np.any(decoded) or np.max(np.abs(decoded.astype(np.int32))) >= 32767:
        raise ValueError(f"Silent or clipped root sample {name}")
    return codes, {
        "name": name, "midi": midi, "fade_samples": width,
        "samples": SLOT, "peak": int(np.abs(decoded.astype(np.int32)).max()),
        "source_sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
    }


def render_note(bank: np.ndarray, note: dict, seconds: float) -> np.ndarray:
    # Mirror the RTL's Q16.16 position and signed linear interpolation.
    position = 0
    gain = 0
    result = np.empty(round(seconds * FS), dtype=np.int16)
    age = 0
    finished = False
    for frame in range(len(result)):
        if finished:
            result[frame] = 0
            continue
        if age < 32:
            gain = min(65535, gain + 2048)
        elif gain > 12000:
            gain -= ((gain - 12000) >> 12) + 1
        else:
            gain = 12000
        age += 1
        index = position >> 16
        next_index = min(index + 1, SLOT - 1)
        a = int(bank[note["base"] + index])
        b = int(bank[note["base"] + next_index])
        interpolated = a + (((b - a) * (position & 65535)) >> 16)
        result[frame] = (interpolated * gain) >> 16
        position += note["step"]
        if position >= SLOT << 16:
            finished = True
    return result


def save_wav(path: Path, samples: np.ndarray) -> None:
    with wave.open(str(path), "wb") as target:
        target.setnchannels(1)
        target.setsampwidth(2)
        target.setframerate(round(FS))
        target.writeframes(samples.astype("<i2").tobytes())


def main() -> None:
    output = ROOT / "output"
    output.mkdir(exist_ok=True)
    zones = []
    codes = np.full(DEPTH, 255, dtype=np.uint8)
    for zone_index, (name, midi) in enumerate(ROOTS):
        zone_codes, meta = prepare_sample(name, midi)
        base = zone_index * SLOT
        codes[base:base + SLOT] = zone_codes
        meta["base"] = base
        zones.append(meta)
        print(f"Prepared one-shot piano {name}, {meta['fade_samples']} fade samples")
    decoded_bank = np.array([decode_ulaw(int(code)) for code in codes], dtype=np.int16)
    notes = []
    for index in range(88):
        midi = index + 21
        zone = min(zones, key=lambda root: abs(root["midi"] - midi))
        notes.append({
            "index": index, "midi": midi,
            "name": NAMES[midi % 12] + str(midi // 12 - 1),
            "frequency_hz": 440 * 2 ** ((midi - 69) / 12),
            "root": zone["name"], "root_midi": zone["midi"],
            "base": zone["base"],
            "step": round(65536 * 2 ** ((midi - zone["midi"]) / 12)),
            "duration_seconds": (SLOT << 16) / round(
                65536 * 2 ** ((midi - zone["midi"]) / 12)) / FS,
        })
    (ROOT / "src" / "piano_bank.hex").write_text(
        "".join(f"{int(code):02X}\n" for code in codes), encoding="ascii")
    rom = [
        "// Generated by tools/generate_pcm_bank.py. Recorded PCM zone metadata.",
        "module piano_sample_map (",
        "    input wire [6:0] note_index,",
        "    output reg [17:0] sample_base,",
        "    output reg [31:0] sample_step",
        ");", "    always @* begin", "        case (note_index)",
    ]
    for note in notes:
        rom.extend([
            f"            7'd{note['index']}: begin // {note['name']}, root {note['root']}",
            f"                sample_base = 18'd{note['base']};",
            f"                sample_step = 32'd{note['step']};",
            "            end",
        ])
    rom.extend([
        "            default: begin",
        f"                sample_base = 18'd{notes[0]['base']};",
        f"                sample_step = 32'd{notes[0]['step']};",
        "            end", "        endcase", "    end", "endmodule", "",
    ])
    (ROOT / "src" / "piano_sample_map.v").write_text("\n".join(rom), encoding="ascii")
    sweep = []
    peaks = []
    for note in notes:
        pcm = render_note(decoded_bank, note, 0.55)
        peaks.append(int(np.abs(pcm.astype(np.int32)).max()))
        pcm[-160:] = np.rint(pcm[-160:] * np.linspace(1, 0, 160)).astype(np.int16)
        sweep.extend([pcm, np.zeros(round(0.06 * FS), dtype=np.int16)])
        if note["index"] in (0, 27, 39, 48, 63, 87):
            save_wav(output / f"piano_{note['name']}_preview.wav",
                     render_note(decoded_bank, note, 4))
    save_wav(output / "piano_88_preview.wav", np.concatenate(sweep))
    report = {
        "voice": "recorded acoustic piano PCM from tonejs-instruments / VSCO2",
        "sample_rate_hz": FS, "rom_depth_bytes": DEPTH,
        "used_rom_bytes": len(zones) * SLOT, "root_sample_count": len(zones),
        "note_count": 88, "pcm_max_peak": max(peaks),
        "playback": "one-shot with final fade and exact zero after completion",
        "clipped_samples": 0, "zones": zones, "notes": notes,
    }
    (output / "audio_report.json").write_text(json.dumps(report, indent=2), encoding="ascii")
    table = [
        "# 88 音 PCM 映射表", "",
        "原始钢琴录音分区转调，十二平均律；表中频率为名义音高。",
        "采样率 50 MHz / 3072，采样地址步进为 Q16.16。", "",
        "| 次数 | 音名 | 名义频率 / Hz | 录音音区 | ROM 基地址 | 步进 |",
        "| ---: | --- | ---: | --- | ---: | ---: |",
        *[f"| {n['index'] + 1} | {n['name']} | {n['frequency_hz']:.6f} | {n['root']} | {n['base']} | {n['step']} |"
          for n in notes], "",
    ]
    (ROOT / "NOTES.md").write_text("\n".join(table), encoding="utf8")
    with (output / "pcm_vectors.txt").open("w", encoding="ascii") as vectors:
        offsets = [0, 1, 15, 31, 32, 255, 1023, 16000, 24000, 31999]
        for note in notes:
            pcm = render_note(decoded_bank, note, 32000 / FS)
            for offset in offsets:
                vectors.write(f"{note['index']} {offset} {int(pcm[offset])}\n")
    print(f"Generated {len(zones)} roots, 88 notes, {len(zones) * SLOT} ROM bytes.")


if __name__ == "__main__":
    main()
