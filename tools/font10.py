import re, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.path.insert(0, 'tools')
from pdflib import load_pdf
from ccitt import decode_rows
PDF = r"C:\Users\30415\.dsh\attachments\v1\files\e4\e457547f08ca37250b27ccfd4c8e29e3ce44cf309b24324623932fd2626002be\tang_mega_60k_30354_schematics..pdf"
allobj, gs, infl = load_pdf(PDF)

def rows_of(cnum):
    cb = allobj[cnum]
    s, h = gs(cb); d = infl(s, h)
    i = d.find(b'BI'); j = d.find(b'EI', i); seg = d[i+2:j]
    W = int(re.search(rb'/W\s+(\d+)', seg).group(1))
    H = int(re.search(rb'/H\s+(\d+)', seg).group(1))
    k = seg.find(b'ID'); b = seg[k+2:]
    for p in (b'\r\n', b'\n', b'\r', b' '):
        if b.startswith(p): b = b[len(p):]; break
    r = decode_rows(b, W, H)
    while len(r) < H: r.append([0]*W)
    return r, W, H

# font 10: CharProcs order g36,g37,g38,g39,g20,g21,g22,g23,g24  -> objs 18,17,16,15,14,13,12,11,9
procs = [('g36',18),('g37',17),('g38',16),('g39',15),('g20',14),
         ('g21',13),('g22',12),('g23',11),('g24',9)]
print("Differences says: code1=g24 code2=g23 code3=g22 code4=g21 code5=g20")
print("                  code6=g39 code7=g38 code8=g37 code9=g36")
print()
for nm, o in procs:
    r, W, H = rows_of(o)
    print("--- %s (obj %d) %dx%d ---" % (nm, o, W, H))
    for row in r:
        print(''.join('#' if v else '.' for v in row))
    print()
