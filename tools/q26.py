import re, sys, json
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.path.insert(0, 'tools')
from pdflib import load_pdf
PDF = r"C:\Users\30415\.dsh\attachments\v1\files\e4\e457547f08ca37250b27ccfd4c8e29e3ce44cf309b24324623932fd2626002be\tang_mega_60k_30354_schematics..pdf"
allobj, gs, infl = load_pdf(PDF)

for num in (10, 28, 574, 41, 118, 125, 56, 131, 372, 152):
    body = allobj.get(num)
    if body is None: continue
    m = re.search(rb'/CharProcs\s*<<([^>]*)>>', body, re.S)
    procs = re.findall(rb'/(g\d+)\s+(\d+)\s+0\s+R', m.group(1)) if m else []
    enc = re.search(rb'/Encoding\s+(\d+)\s+0\s+R', body)
    e = allobj.get(int(enc.group(1)), b'') if enc else b''
    dd = re.search(rb'/Differences\s*\[([^\]]*)\]', e, re.S)
    print("font", num)
    print("  CharProcs order:", [p[0].decode() for p in procs])
    print("  Differences   :", dd.group(1).split() if dd else None)
