import re, sys, zlib
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.path.insert(0, 'tools')
from pdflib import load_pdf
from ccitt import decode_rows
PDF = r"C:\Users\30415\.dsh\attachments\v1\files\e4\e457547f08ca37250b27ccfd4c8e29e3ce44cf309b24324623932fd2626002be\tang_mega_60k_30354_schematics..pdf"
allobj, get_stream, inflate = load_pdf(PDF)

def image_data(cnum):
    s, hdr = get_stream(allobj[cnum])
    d = inflate(s, hdr)
    i = d.find(b'BI'); j = d.find(b'EI', i)
    seg = d[i+2:j]
    W = int(re.search(rb'/W\s+(\d+)', seg).group(1))
    H = int(re.search(rb'/H\s+(\d+)', seg).group(1))
    k = seg.find(b'ID')
    body = seg[k+2:]
    if body[:1] == b'\r': body = body[1:]
    if body[:1] == b'\n': body = body[1:]
    if body[:1] == b' ': body = body[1:]
    return body, W, H

for cnum in (18, 17, 16, 15, 14, 13, 12, 11, 9):
    body, W, H = image_data(cnum)
    print("=== obj", cnum, "W", W, "H", H, "datalen", len(body))
    rows = decode_rows(body, W, H)
    for r in rows:
        print(''.join('#' if v else '.' for v in r))
    print()
