import re, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.path.insert(0, "tools")
from pdflib import load_pdf
from ccitt import decode_rows
PDF = r"C:\Users\30415\.dsh\attachments\v1\files\e4\e457547f08ca37250b27ccfd4c8e29e3ce44cf309b24324623932fd2626002be\tang_mega_60k_30354_schematics..pdf"
allobj, gs, infl = load_pdf(PDF)
s, h = gs(allobj[18]); d = infl(s, h)
i = d.find(b"BI"); j = d.find(b"EI", i)
seg = d[i+2:j]
k = seg.find(b"ID")
raw = seg[k+2:]
print("raw after ID:", repr(raw))
if raw[:1] == b"\n": raw = raw[1:]
print("len", len(raw))
# print bits
bits = "".join(format(b, "08b") for b in raw)
print(bits)
try:
    rows = decode_rows(raw, 19, 21)
    for r in rows: print("".join("#" if v else "." for v in r))
except Exception as e:
    import traceback; traceback.print_exc()
