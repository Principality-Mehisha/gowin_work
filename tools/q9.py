import re, sys, zlib
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.path.insert(0, 'tools')
from pdflib import load_pdf
PDF = r"C:\Users\30415\.dsh\attachments\v1\files\e4\e457547f08ca37250b27ccfd4c8e29e3ce44cf309b24324623932fd2626002be\tang_mega_60k_30354_schematics..pdf"
allobj, get_stream, inflate = load_pdf(PDF)
b = allobj[10]
print("=== obj 10 ===")
print(b.decode('latin-1')[:1200])
print()
# follow CharProcs
m = re.search(rb'/CharProcs\s+(\d+)\s+0\s+R', b)
print("charprocs ref:", m.group(1) if m else None)
if m:
    print(allobj[int(m.group(1))].decode('latin-1')[:500])
m2 = re.search(rb'/Encoding\s+(\d+)\s+0\s+R', b)
if m2:
    print("encoding:", allobj[int(m2.group(1))].decode('latin-1')[:500])
# one charproc
for g in re.finditer(rb'/(g\d+)\s+(\d+)\s+0\s+R', b):
    print("proc", g.group(1), g.group(2))
    cb = allobj[int(g.group(2))]
    s, hdr = get_stream(cb)
    d = inflate(s, hdr)
    print(repr(d[:400]))
    break
