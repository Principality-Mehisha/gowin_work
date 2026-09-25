import re, sys, zlib
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.path.insert(0, 'tools')
from pdflib import load_pdf
src = open('tools/type3match.py', encoding='utf-8').read().split("# ---- collect unique")[0]
exec(src)

def show(rows):
    for r in rows:
        print(''.join('#' if v else '.' for v in r))

for cnum in [18, 17, 16, 15, 14, 13, 12, 11, 9]:
    cb = allobj.get(cnum)
    s, hdr = get_stream(cb)
    d = inflate(s, hdr)
    print("=== charproc obj", cnum, "===")
    print(repr(d[:120]))
    p = parse_charproc(cnum)
    if p:
        rows, adv, cmv = p
        print("adv", adv, "cm", cmv, "size", len(rows), len(rows[0]))
        show(rows)
    print()
