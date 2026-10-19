"""Reject a generated bitstream when the timing report has real violations."""
from html.parser import HTMLParser
from pathlib import Path
import json

class Cells(HTMLParser):
    def __init__(self):
        super().__init__()
        self.rows = []
        self.row = []
        self.cell = None
    def handle_starttag(self, tag, attrs):
        if tag == "tr":
            self.row = []
        if tag in ("td", "th"):
            self.cell = ""
    def handle_data(self, data):
        if self.cell is not None:
            self.cell += data
    def handle_endtag(self, tag):
        if tag in ("td", "th") and self.cell is not None:
            self.row.append(self.cell.strip())
            self.cell = None
        if tag == "tr" and self.row:
            self.rows.append(self.row)

root = Path(__file__).resolve().parents[1]
parser = Cells()
parser.feed((root / "impl/pnr/GW_PROBLEM_TOW_tr_content.html").read_text())
stats = {}
negative_paths = []
for row in parser.rows:
    if len(row) == 2 and row[0].startswith("Numbers of"):
        stats[row[0]] = int(row[1])
    if len(row) == 6 and row[1] in ("sys_clk", "audio_153m6"):
        stats["audio_clock"] = row[1]
        stats["target_mhz"] = float(row[2].replace("(MHz)", ""))
        stats["fmax_mhz"] = float(row[3].replace("(MHz)", ""))
    if len(row) == 9 and row[0].isdigit() and row[1].startswith("-"):
        negative_paths.append({"slack": float(row[1]), "from": row[2], "to": row[3]})
stats["worst_paths"] = negative_paths[:8]
(root / "sim/timing_report.json").write_text(json.dumps(stats, indent=2), encoding="ascii")
print(json.dumps(stats, indent=2))
assert stats.get("Numbers of Setup Violated Endpoints") == 0, "Setup timing failed"
assert stats.get("Numbers of Hold Violated Endpoints") == 0, "Hold timing failed"
assert stats["fmax_mhz"] >= stats["target_mhz"], "Audio engine cannot run at target frequency"
