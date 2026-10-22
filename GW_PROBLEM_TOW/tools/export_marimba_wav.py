"""Package RTL-rendered notes as a scale and individual WAV previews."""
import hashlib
import json
from pathlib import Path
import wave

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
FS = 50_000_000 / 3072
RATE = round(FS)
ROM = ROOT / "src/rom/marimba31.hex"


def write_wav(path, samples):
    with wave.open(str(path), "wb") as output:
        output.setnchannels(1)
        output.setsampwidth(2)
        output.setframerate(RATE)
        output.writeframes(np.asarray(samples, dtype="<i2").tobytes())


def main():
    rows = np.loadtxt(ROOT / "sim/marimba_scale_pcm.txt", dtype=np.int32)
    assert rows.shape == (31 * 16276, 3)
    out = ROOT / "sim/marimba_wav"
    out.mkdir(exist_ok=True)
    parts = []
    names = ("C", "Cs", "D", "Ds", "E", "F", "Fs", "G", "Gs", "A", "As", "B")
    notes = []
    for midi in range(47, 78):
        selected = rows[rows[:, 0] == midi]
        assert np.array_equal(selected[:, 1], np.arange(16276))
        audio = selected[:, 2]
        assert audio.max() > 0 and audio.min() < 0
        assert np.abs(audio).max() <= 30001
        # Endpoints are preview packaging, not a change to the synth envelope.
        preview = audio.astype(float)
        fade = round(RATE * .01)
        preview[-fade:] *= np.linspace(1, 0, fade)
        preview = np.rint(preview).astype("<i2")
        name = f"{names[midi % 12]}{midi // 12 - 1}"
        write_wav(out / f"{name}.wav", preview)
        notes.append({"midi": midi, "label": name,
                      "peak": int(np.abs(audio).max()),
                      "scale_start_seconds": len(parts) * (16276 + 1628) / RATE})
        parts.append(np.concatenate((preview, np.zeros(1628, dtype="<i2"))))
    scale = np.concatenate(parts)
    write_wav(ROOT / "sim/marimba_B2_F5_realtime.wav", scale)
    write_wav(ROOT / "sim/marimba_C5_F5_realtime.wav",
              np.concatenate(parts[72 - 47:]))
    write_wav(ROOT / "sim/marimba_notes_14_23_corrected.wav",
              np.concatenate(parts[13:23]))
    write_wav(ROOT / "sim/marimba_B2_F5_corrected.wav", scale)
    write_wav(ROOT / "sim/marimba_B2_F5_bass_boost.wav", scale)
    write_wav(ROOT / "sim/marimba_B2_C4_bass_boost.wav",
              np.concatenate(parts[:14]))
    report = {
        "source": "ModelSim marimba_synth RTL, not PCM reference playback",
        "sample_rate_exact": FS, "wav_sample_rate": RATE,
        "note_duration_seconds": 16276 / RATE, "gap_seconds": 1628 / RATE,
        "preview_end_fade_seconds": fade / RATE,
        "dynamics": 192, "notes": notes,
        "mode_rom_sha256": hashlib.sha256(ROM.read_bytes()).hexdigest(),
        "level_processing": "No per-note normalization; actual RTL amplitude retained",
    }
    (out / "report.json").write_text(json.dumps(report, indent=2), encoding="ascii")
    print(f"Exported {len(notes)} notes; scale duration {len(scale) / RATE:.2f}s")


if __name__ == "__main__":
    main()
