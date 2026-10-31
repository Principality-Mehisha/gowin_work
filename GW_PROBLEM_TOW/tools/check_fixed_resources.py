"""Compare fixed-slot implementation with its archived dynamic-FAT baseline."""
from html.parser import HTMLParser
from pathlib import Path
import json
import re
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
BEFORE = ROOT / "output/fixed_slots/before"


class Rows(HTMLParser):
    def __init__(self):
        super().__init__()
        self.rows, self.row, self.cell = [], [], None

    def handle_starttag(self, tag, attrs):
        if tag == "tr":
            self.row = []
        elif tag in ("td", "th"):
            self.cell = ""

    def handle_data(self, data):
        if self.cell is not None:
            self.cell += data

    def handle_endtag(self, tag):
        if tag in ("td", "th") and self.cell is not None:
            self.row.append(self.cell.strip())
            self.cell = None
        elif tag == "tr" and self.row:
            self.rows.append(self.row)


def seconds(text):
    hours, minutes, secs = re.search(r"Elapsed time = (\d+)h (\d+)m ([\d.]+)s", text).groups()
    return int(hours) * 3600 + int(minutes) * 60 + float(secs)


def report(pnr, synthesis, resources):
    text = pnr.read_text()
    parser = Rows()
    parser.feed(synthesis.read_text())
    total = next(row[1] for row in parser.rows if row[0] == "Total Time and Memory Usage")
    physical = {}
    for name in ("Logic", "Register", "CLS", "BSRAM", "DSP", "--pROM", "--pROMX9"):
        physical[name] = float(re.search(r"^\s*" + re.escape(name) + r"\s*\|\s*([\d.]+)", text, re.M)[1])
    module = ET.parse(resources).getroot().find("./SubModule[@name='bluetooth_upload']")
    return {
        "physical": physical, "synthesis_seconds": seconds(total),
        "pnr_seconds": seconds(next(line for line in text.splitlines() if "Total Time and Memory Usage:" in line)),
        "bluetooth_lut": int(module.attrib["T_Lut"].split("(")[0]),
        "bluetooth_register": int(module.attrib["T_Register"].split("(")[0]),
        "bluetooth_bsram": int(module.attrib["T_Bsram"].split("(")[0]),
    }


def main():
    assert (ROOT / "impl/pnr/GW_PROBLEM_TOW.rpt.txt").stat().st_mtime_ns >= \
        (ROOT / "impl/gwsynthesis/GW_PROBLEM_TOW_syn.rpt.html").stat().st_mtime_ns, \
        "PnR report predates current synthesis"
    before = report(BEFORE / "GW_PROBLEM_TOW.rpt.txt", BEFORE / "GW_PROBLEM_TOW_syn.rpt.html",
                    BEFORE / "GW_PROBLEM_TOW_syn_rsc.xml")
    after = report(ROOT / "impl/pnr/GW_PROBLEM_TOW.rpt.txt",
                   ROOT / "impl/gwsynthesis/GW_PROBLEM_TOW_syn.rpt.html",
                   ROOT / "impl/gwsynthesis/GW_PROBLEM_TOW_syn_rsc.xml")
    netlist = (ROOT / "impl/gwsynthesis/GW_PROBLEM_TOW.vg").read_text()
    receiver = re.search(r"(?ms)^module bluetooth_file_receiver\b.*?^endmodule", netlist)[0]
    fifo_blocks = re.findall(r"^\s*SDPB\s+(fifo_fifo_\w+)\s*\(", receiver, re.M)
    assert len(fifo_blocks) == 16, f"32 KiB FIFO must use 16 SDPB blocks, got {len(fifo_blocks)}"
    assert "sector_sector_RAMREG" not in netlist, "Old 4096-register sector expansion returned"
    assert "fifo_fifo_RAMREG" not in netlist, "UART FIFO expanded to registers"
    assert after["bluetooth_bsram"] == 16
    assert after["bluetooth_lut"] < before["bluetooth_lut"]
    for name in ("--pROM", "--pROMX9"):
        assert after["physical"][name] == before["physical"][name], f"Unexpected ROM change: {name}"
    frozen = json.loads((ROOT / "output/fixed_slots/source_frozen.json").read_text())
    import hashlib
    assert all(hashlib.sha256((ROOT / name).read_bytes()).hexdigest() == digest
               for name, digest in frozen["rtl_and_constraints"].items()), "RTL changed during full build"
    result = {"before": before, "after": after, "fifo_sdpb_blocks": len(fifo_blocks),
              "old_sector_ramreg_count": 0, "rtl_unchanged_during_build": True}
    out = ROOT / "output/fixed_slots/resources.json"
    out.write_text(json.dumps(result, indent=2) + "\n", encoding="ascii")
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
