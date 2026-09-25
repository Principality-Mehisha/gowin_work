import re, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.path.insert(0, 'tools')
from pdflib import load_pdf
PDF = r"C:\Users\30415\.dsh\attachments\v1\files\e4\e457547f08ca37250b27ccfd4c8e29e3ce44cf309b24324623932fd2626002be\tang_mega_60k_30354_schematics..pdf"
allobj, gs, infl = load_pdf(PDF)

# Hypothesis: CharProcs is listed in DESCENDING glyph order (LastChar..FirstChar),
# so glyph code C maps to charprocs[len-C].
for num in (10, 131, 372, 28, 118, 574, 41):
    body = allobj[num]
    m = re.search(rb'/CharProcs\s*<<([^>]*)>>', body, re.S)
    cp = [g.decode('latin-1') for g, _ in re.findall(rb'/(g\d+)\s+(\d+)\s+0\s+R', m.group(1))]
    enc = re.search(rb'/Encoding\s+(\d+)\s+0\s+R', body)
    e = allobj.get(int(enc.group(1)), b'')
    dd = re.search(rb'/Differences\s*\[([^\]]*)\]', e, re.S)
    print("font", num, "n=", len(cp))
    if dd:
        print("   Differences:", dd.group(1).decode('latin-1').replace('\n', ' ')[:200])
    print("   CharProcs  :", cp)
    print()
