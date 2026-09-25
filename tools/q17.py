import re, sys, json
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.path.insert(0, 'tools')
from pdflib import load_pdf
PDF = r"C:\Users\30415\.dsh\attachments\v1\files\e4\e457547f08ca37250b27ccfd4c8e29e3ce44cf309b24324623932fd2626002be\tang_mega_60k_30354_schematics..pdf"
allobj, get_stream, inflate = load_pdf(PDF)

# what do the actual font objects look like?
cnt = 0
for num, body in sorted(allobj.items()):
    if b'/Type/Font' not in body: continue
    cnt += 1
    if cnt <= 8:
        print("=== font obj", num, "===")
        print(body[:400].decode('latin-1'))
        print()
print("total font objects:", cnt)

# check page 1 fmap
for num, body in sorted(allobj.items()):
    if b'/Type/Page' in body and b'/Contents' in body:
        print("page", num)
        rf = re.search(rb'/Font\s*<<(.*?)>>', body, re.S)
        if rf:
            print("  fonts:", rf.group(1)[:400].decode('latin-1'))
        break
