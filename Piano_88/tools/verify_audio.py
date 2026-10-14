"""Check the generated piano bank and export audio captured from RTL simulation."""
import json
from pathlib import Path

import numpy as np

from generate_pcm_bank import FS, ROOT, decode_ulaw, render_note, save_wav

report = json.loads((ROOT / "output" / "audio_report.json").read_text())
codes = np.array([int(line, 16) for line in
                  (ROOT / "src" / "piano_bank.hex").read_text().splitlines()])
bank = np.array([decode_ulaw(int(code)) for code in codes], dtype=np.int16)
assert len(codes) == 262144
checks = []
for note in report["notes"]:
    pcm = render_note(bank, note, 0.55).astype(np.float64)
    assert np.max(np.abs(pcm)) < 32767
    assert np.max(np.abs(pcm)) > 1000
    assert np.sqrt(np.mean(pcm * pcm)) > 50
    full = render_note(bank, note, 3)
    assert np.all(full[round(2 * FS):] == 0), f"{note['name']}: post-note noise"
    spectrum = np.abs(np.fft.rfft(pcm * np.hanning(len(pcm)), 131072))
    frequencies = np.fft.rfftfreq(131072, 1 / FS)
    nominal = note["frequency_hz"]
    # Acoustic piano bass can have a stronger second partial than fundamental.
    region = np.flatnonzero((frequencies > nominal * 0.95)
                            & (frequencies < nominal * 1.05))
    best = int(region[np.argmax(spectrum[region])])
    measured = float(frequencies[best])
    cents = float(1200 * np.log2(measured / nominal))
    if abs(cents) > 50:
        raise ValueError(f"{note['name']}: source pitch differs by {cents:.1f} cents")
    checks.append({"note": note["name"], "nominal_hz": nominal,
                   "measured_fundamental_hz": measured, "error_cents": cents})

capture = ROOT / "sim" / "samples.txt"
if capture.exists():
    captured = np.loadtxt(capture, dtype=np.int16)
    reference = render_note(bank, report["notes"][48], len(captured) / FS)
    if not np.array_equal(captured, reference):
        raise ValueError("RTL A4 capture differs from generated preview")
    save_wav(ROOT / "output" / "piano_A4_rtl.wav", captured)
    print(f"PASS: RTL A4 capture matches all {len(captured)} preview samples.")
(ROOT / "output" / "audio_checks.json").write_text(
    json.dumps(checks, indent=2), encoding="ascii")
print("PASS: 88 notes have valid source pitch, no clipping and exact post-note silence.")
print(f"Maximum measured deviation: {max(abs(c['error_cents']) for c in checks):.2f} cents.")
