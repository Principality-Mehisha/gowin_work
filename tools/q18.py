import re, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.path.insert(0, 'tools')
from pdflib import load_pdf
PDF = r"C:\Users\30415\.dsh\attachments\v1\files\e4\e457547f08ca37250b27ccfd4c8e29e3ce44cf309b24324623932fd2626002be\tang_mega_60k_30354_schematics..pdf"
allobj, get_stream, inflate = load_pdf(PDF)

body = allobj[4]
rf = re.search(rb'/Font\s*<<(.*?)>>', body, re.S)
print("inline font dict:", rf.group(1)[:400] if rf else None)
m = re.search(rb'/Font\s+(\d+)\s+0\s+R', body)
print("indirect /Font:", m.group(1) if m else None)
if m:
    print(repr(allobj[int(m.group(1))][:400]))
