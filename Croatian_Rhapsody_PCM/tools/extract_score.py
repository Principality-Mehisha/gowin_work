"""Extract the first public letter-note groups into assets/score.json."""
import json
import re
from html import unescape
from pathlib import Path

root = Path(__file__).resolve().parents[1]
text = (root / "tools" / "score_source.html").read_text(encoding="utf8")
body = text[text.index("id='post-body'>"):]
rows = list(re.finditer(r"(RH|LH):<span[^>]*>([1-8])\|([a-gA-G\-]+)\|</span>", body))
groups, current = [], []
last = 0
for row in rows:
    if current and re.search(r"<br\s*/?>\s*<br\s*/?>", body[last:row.start()]):
        groups.append(current)
        current = []
    current.append((row[1], int(row[2]), unescape(row[3])))
    last = row.end()
if current:
    groups.append(current)
if len(groups) < 5:
    raise ValueError("score source has fewer than five groups")
semitones = {"c": 0, "d": 2, "e": 4, "f": 5, "g": 7, "a": 9, "b": 11}
tick = 60 / 140 / 4
events, offset = [], 0
for group in groups[:5]:
    width = max(len(line) for _, _, line in group)
    for hand, octave, line in group:
        notes = [(i, char) for i, char in enumerate(line) if char != "-"]
        for index, (column, char) in enumerate(notes):
            next_column = notes[index + 1][0] if index + 1 < len(notes) else width
            events.append({
                "midi": 12 * (octave + 1) + semitones[char.lower()] + int(char.isupper()),
                "start_seconds": round((offset + column) * tick, 8),
                "duration_seconds": round(max(1, next_column - column) * tick * 0.85, 8),
                "gain": 0.70 if hand == "RH" else 0.28,
            })
    offset += width
root.joinpath("assets").mkdir(exist_ok=True)
root.joinpath("assets", "score.json").write_text(json.dumps({
    "title": "Croatian Rhapsody opening excerpt",
    "source": "pianoletternotes.blogspot.com/2022/09/croatian-rhapsody-by-maksim-mrvica.html",
    "duration_seconds": offset * tick + 0.25,
    "events": sorted(events, key=lambda e: (e["start_seconds"], e["midi"])),
}, indent=2), encoding="ascii")
print(f"events={len(events)} duration={offset * tick + 0.25:.3f}s")
