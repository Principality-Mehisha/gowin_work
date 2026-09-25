import re, sys, zlib
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.path.insert(0, 'tools')
from pdflib import load_pdf
PDF = r"C:\Users\30415\.dsh\attachments\v1\files\e4\e457547f08ca37250b27ccfd4c8e29e3ce44cf309b24324623932fd2626002be\tang_mega_60k_30354_schematics..pdf"
allobj, get_stream, inflate = load_pdf(PDF)

def raw_mask(cnum, paint_when_zero=True):
    s, hdr = get_stream(allobj[cnum])
    d = inflate(s, hdr)
    i = d.find(b'BI'); j = d.find(b'EI', i)
    seg = d[i+2:j]
    W = int(re.search(rb'/W\s+(\d+)', seg).group(1))
    H = int(re.search(rb'/H\s+(\d+)', seg).group(1))
    k = seg.find(b'ID')
    body = seg[k+2:]
    if body[:1] in (b'\r', b'\n', b' '):
        body = body[1:]
        if body[:1] == b'\n': body = body[1:]
    stride = (W+7)//8
    need = stride*H
    body = body[:need].ljust(need, b'\x00')
    rows = []
    for r in range(H):
        bits = []
        for b in body[r*stride:(r+1)*stride]:
            for kk in range(7, -1, -1):
                bits.append((b >> kk) & 1)
        bits = bits[:W]
        if paint_when_zero:
            bits = [1-v for v in bits]
        rows.append(bits)
    return rows, W, H

def show(rows):
    for r in rows:
        print(''.join('#' if v else '.' for v in r))

for cnum in (18, 17, 16, 15, 14, 13, 12, 11, 9):
    print("=== obj", cnum)
    for pwz in (True, False):
        rows, W, H = raw_mask(cnum, pwz)
        print(" paint_when_zero =", pwz)
        show(rows)
    print()
