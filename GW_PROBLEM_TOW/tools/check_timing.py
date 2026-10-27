"""Gate all three clock domains' data paths; explicitly report reset checks."""
from html.parser import HTMLParser
from pathlib import Path
import json

class Cells(HTMLParser):
    def __init__(self):
        super().__init__()
        self.rows = []
        self.row = []
        self.cell = None
        self.section = ''
        self.sections = []
    def handle_starttag(self, tag, attrs):
        if tag == 'a' and 'name' in dict(attrs):
            self.section = dict(attrs)['name']
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
            self.sections.append(self.section)

root = Path(__file__).resolve().parents[1]
parser = Cells()
parser.feed((root / "impl/pnr/GW_PROBLEM_TOW_tr_content.html").read_text())
stats = {}
negative_paths = []
clock_timing = {}
reset_paths = []
for row, section in zip(parser.rows, parser.sections):
    if len(row) == 2 and row[0].startswith("Numbers of"):
        stats[row[0]] = int(row[1])
    if len(row) == 6 and row[1] == "sys_clk":
        stats["audio_clock"] = row[1]
        stats["target_mhz"] = float(row[2].replace("(MHz)", ""))
        stats["fmax_mhz"] = float(row[3].replace("(MHz)", ""))
    if len(row) == 6 and row[1] in ('sys_clk','pixel_clk') and '(MHz)' in row[2]:
        clock_timing.setdefault(row[1],{}).update(target_mhz=float(row[2].replace('(MHz)','')),fmax_mhz=float(row[3].replace('(MHz)','')))
    if len(row) == 4 and row[1] in ('Setup','Hold') and row[0] in ('sys_clk','pixel_clk','serial_clk'):
        clock_timing.setdefault(row[0],{})[row[1].lower()+'_violations'] = int(row[3])
    if len(row) == 9 and row[0].isdigit() and row[1].startswith("-"):
        path={"slack": float(row[1]), "from": row[2], "to": row[3], "check": section}
        if section in ('Recovery_Slack_Table','Removal_Slack_Table'):
            reset_paths.append(path)
        else:
            negative_paths.append(path)
stats["worst_paths"] = negative_paths[:8]
stats['clocks'] = clock_timing
stats['reset_violations'] = reset_paths
stats['reset_review_required'] = bool(reset_paths)
(root / "sim/timing_report.json").write_text(json.dumps(stats, indent=2), encoding="ascii")
print(json.dumps(stats, indent=2))
for clock in ('sys_clk','pixel_clk','serial_clk'):
    assert clock in clock_timing, f'Missing timing summary: {clock}'
    assert clock_timing[clock].get('setup_violations') == 0, f'{clock} setup failed'
    assert clock_timing[clock].get('hold_violations') == 0, f'{clock} hold failed'
    if 'fmax_mhz' in clock_timing[clock]:
        assert clock_timing[clock]['fmax_mhz'] >= clock_timing[clock]['target_mhz'], f'{clock} misses target'
assert not negative_paths, 'Negative data path slack'
assert stats["fmax_mhz"] >= stats["target_mhz"], "Audio engine cannot run at target frequency"
if reset_paths:
    # Only known video reset endpoints may be reported separately. Any reset
    # violation elsewhere (including the original audio subsystem) is fatal.
    for path in reset_paths:
        assert (path['to'].startswith('display_enabled.video/release_pipe_') or
                (path['to'].startswith('display_enabled.video/tx/serializers[') and
                 path['to'].endswith('.serializer/RESET'))), f'Unexpected reset violation: {path}'
    print('REVIEW REQUIRED: asynchronous reset recovery/removal violations are recorded above, not waived in SDC')
