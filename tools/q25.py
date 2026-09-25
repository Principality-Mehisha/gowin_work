import re, sys, io
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.path.insert(0, "tools")
from pdflib import load_pdf
import ccitt
PDF = r"C:\Users\30415\.dsh\attachments\v1\files\e4\e457547f08ca37250b27ccfd4c8e29e3ce44cf309b24324623932fd2626002be\tang_mega_60k_30354_schematics..pdf"
allobj, gs, infl = load_pdf(PDF)
s, h = gs(allobj[18]); d = infl(s, h)
i = d.find(b"BI"); j = d.find(b"EI", i)
seg = d[i+2:j]; k = seg.find(b"ID")
raw = seg[k+2:]
if raw[:1] == b"\n": raw = raw[1:]

src = io.open("tools/ccitt.py", encoding="utf-8").read()
ns = {}
exec(compile(src, "ccitt.py", "exec"), ns)
br = ns["_Bits"](raw)
for n in range(1, 13):
    print(n, format(br.peek(n) or 0, "0%db" % n))
