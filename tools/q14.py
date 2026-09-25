import re, sys, zlib
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.path.insert(0, 'tools')
from pdflib import load_pdf
PDF = r"C:\Users\30415\.dsh\attachments\v1\files\e4\e457547f08ca37250b27ccfd4c8e29e3ce44cf309b24324623932fd2626002be\tang_mega_60k_30354_schematics..pdf"
allobj, get_stream, inflate = load_pdf(PDF)

for cnum in (18, 17, 9):
    s, hdr = get_stream(allobj[cnum])
    d = inflate(s, hdr)
    print("=== obj", cnum)
    print(repr(d[:400]))
    print()
