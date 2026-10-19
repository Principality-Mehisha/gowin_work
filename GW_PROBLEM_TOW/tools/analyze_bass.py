"""Compare A/B RTL renders at fixed DAC gain; do not normalize the WAVs."""
from pathlib import Path
import json
import math
import wave
import numpy as np
from piano_reference import render_note, parameters, spectral_level, FS

ROOT = Path(__file__).resolve().parents[1]
data = np.loadtxt(ROOT / "sim/bass_pcm.txt", dtype=np.int64)
results = []
for note in (0, 12, 24, 48):
    rows = data[data[:, 0] == note]
    assert len(rows) == 54000 and np.array_equal(rows[:, 1], np.arange(54000))
    for enhanced, column in ((False, 2), (True, 3)):
        reference, _ = render_note(
            note, 36000, 18000, enhanced, hammer_transient=enhanced)
        error = int(np.max(np.abs(rows[:, column] - reference)))
        assert error == 0, f"note {note}, enhanced={enhanced}: error={error}"
    old = rows[2400:24000, 2].astype(float)
    new = rows[2400:24000, 3].astype(float)
    gain_db = 10 * math.log10(np.mean(new**2) / np.mean(old**2))
    if note == 48:
        assert not np.array_equal(rows[:512, 2], rows[:512, 3]), \
            "A4 hammer transient is missing"
        assert np.array_equal(rows[512:, 2], rows[512:, 3]), \
            "A4 changed after its hammer transient"
    else:
        assert gain_db > 3, f"Missing bass compensation: {note}: {gain_db}"
    word, _, _, _, stiffness = parameters(note)
    fundamental = word * FS / 2**32
    partial_frequencies = [
        (h * word + (h**3 - h) * stiffness) * FS / 2**32 for h in range(1, 9)
    ]
    # Long window resolves bass fundamental independently of the stronger overtones.
    amplitudes = [spectral_level(rows[2400:33000, 3], f) for f in partial_frequencies]
    assert amplitudes[0] > 10, f"Missing standard fundamental, note {note}"
    assert np.all(rows[-5:, 2:] == 0)
    results.append({
        "note_index": note, "name": f"A{note//12}",
        "fundamental_hz": fundamental,
        "rms_change_db_50_to_500_ms": round(gain_db, 3),
        "old_rms": round(float(np.sqrt(np.mean(old**2))), 2),
        "new_rms": round(float(np.sqrt(np.mean(new**2))), 2),
        "new_peak_pcm": int(np.max(np.abs(rows[:, 3]))),
        "all_54000_samples_bit_exact_both_versions": True,
        "partial_hz": [round(v, 6) for v in partial_frequencies],
        "partial_amplitudes": [round(v, 2) for v in amplitudes],
    })
for column, name in ((2, "bass_before.wav"), (3, "bass_after.wav")):
    mono = data[:, column].astype("<i2")
    with wave.open(str(ROOT / "sim" / name), "wb") as out:
        out.setnchannels(2)
        out.setsampwidth(2)
        out.setframerate(FS)
        out.writeframes(np.column_stack((mono, mono)).tobytes())

# Parameter checks cover every key, including profile monotonicity and headroom.
gains = []
max_tuning_cents = 0.0
for note in range(88):
    word, weights, gain, decay, stiff = parameters(note)
    intended = 27.5 * 2 ** (note / 12)
    cents = abs(1200 * math.log2(word * FS / 2**32 / intended))
    max_tuning_cents = max(max_tuning_cents, cents)
    assert sum(weights) == 1024 and min(weights) >= 0
    assert 256 <= gain <= 1126 and 64 <= decay <= 256
    if note >= 48:
        assert gain == 256 and stiff == 0
    gains.append(gain)
assert all(a >= b for a, b in zip(gains, gains[1:]))
assert max(abs(20 * math.log10(a/b)) for a, b in zip(gains, gains[1:])) < 0.4
assert max_tuning_cents < 0.001
report = {
    "sample_rate": FS,
    "source": "ModelSim core output; omitted idle clocks, not prerecorded RTL inputs",
    "wav_note_order": ["A0", "A1", "A2", "A4"],
    "wav_gain": "identical fixed gain; no peak/RMS normalization",
    "all_88_fundamental_max_error_cents": max_tuning_cents,
    "notes": results,
}
(ROOT / "sim/bass_report.json").write_text(json.dumps(report, indent=2), encoding="ascii")
print(json.dumps(report, indent=2))
