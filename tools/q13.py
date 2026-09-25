import re, sys, zlib
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.path.insert(0, 'tools')
from pdflib import load_pdf
PDF = r"C:\Users\30415\.dsh\attachments\v1\files\e4\e457547f08ca37250b27ccfd4c8e29e3ce44cf309b24324623932fd2626002be\tang_mega_60k_30354_schematics..pdf"
allobj, get_stream, inflate = load_pdf(PDF)

def parse_charproc(cnum):
    cb = allobj.get(cnum)
    if cb is None: return None
    s, hdr = get_stream(cb)
    d = inflate(s, hdr)
    if d is None or b'BI' not in d: return None
    i = d.find(b'BI'); j = d.find(b'EI', i)
    seg = d[i+2:j]
    def gv(name, default=None):
        m = re.search(b'/' + name.encode() + rb'\s+([-\d.]+)', seg)
        return float(m.group(1)) if m else default
    W = int(gv('W', 0)); H = int(gv('H', 0)); BPC = int(gv('BPC', 1))
    dm = re.search(rb'/D\s*\[([^\]]*)\]', seg)
    dec = [float(v) for v in dm.group(1).split()] if dm else [1, 0]
    k = seg.find(b'ID')
    body = seg[k+2:]
    if body[:1] in (b'\r', b'\n', b' '):
        body = body[1:]
        if body[:1] == b'\n': body = body[1:]
    stride = (W*BPC + 7)//8
    need = stride*H
    body = body[:need]
    if len(body) < need:
        body = body + b'\x00'*(need-len(body))
    rows = []
    for r in range(H):
        chunk = body[r*stride:(r+1)*stride]
        bits = []
        for b in chunk:
            for kk in range(7, -1, -1):
                bits.append((b >> kk) & 1)
        rows.append(bits[:W])
    if dec[0] < 0:
        rows = [[1-v for v in r] for r in rows]
    pre = d[:i]
    m = re.match(rb'\s*([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)\s+d1', pre)
    adv = (float(m.group(1)), float(m.group(2))) if m else (0, 0)
    cm = re.search(rb'q\s+([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)\s+cm', pre)
    cmv = [float(x) for x in cm.groups()] if cm else [1,0,0,1,0,0]
    return rows, adv, cmv

def show(rows):
    for r in rows:
        print(''.join('#' if v else '.' for v in r))

for cnum in [18, 17, 16, 15, 14, 13, 12, 11, 9]:
    p = parse_charproc(cnum)
    print("=== charproc obj", cnum, "===")
    if p:
        rows, adv, cmv = p
        print("adv", adv, "cm", cmv, "size", len(rows), len(rows[0]))
        show(rows)
    print()
