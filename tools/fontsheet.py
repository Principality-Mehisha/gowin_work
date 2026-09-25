"""Render each Type3 font's own glyphs (by CharProc object) as ASCII, labelled with
the code from that font's /Differences list."""
import re, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.path.insert(0, 'tools')
from pdflib import load_pdf
from ccitt import decode_rows

PDF = r"C:\Users\30415\.dsh\attachments\v1\files\e4\e457547f08ca37250b27ccfd4c8e29e3ce44cf309b24324623932fd2626002be\tang_mega_60k_30354_schematics..pdf"
allobj, gs, infl = load_pdf(PDF)

def charproc_rows(cnum):
    cb = allobj.get(cnum)
    if cb is None: return None
    s, hdr = gs(cb)
    d = infl(s, hdr)
    if d is None or b'BI' not in d: return None
    i = d.find(b'BI'); j = d.find(b'EI', i)
    seg = d[i+2:j]
    mw = re.search(rb'/W\s+(\d+)', seg); mh = re.search(rb'/H\s+(\d+)', seg)
    if not (mw and mh): return None
    W = int(mw.group(1)); H = int(mh.group(1))
    k = seg.find(b'ID'); body = seg[k+2:]
    for pref in (b'\r\n', b'\n', b'\r', b' '):
        if body.startswith(pref):
            body = body[len(pref):]; break
    rows = decode_rows(body, W, H)
    while len(rows) < H: rows.append([0]*W)
    return rows

def show(rows, W=18, H=22):
    h = len(rows); w = len(rows[0]) if h else 0
    out = []
    for r in range(H):
        rr = min(h-1, r*h//H)
        line = ''.join('#' if rows[rr][min(w-1, c*w//W)] else '.'
                       for c in range(W)) if w else '.'*W
        out.append(line)
    return out

def font_info(num):
    body = allobj[num]
    m = re.search(rb'/CharProcs\s*<<([^>]*)>>', body, re.S)
    procs = re.findall(rb'/(g\d+)\s+(\d+)\s+0\s+R', m.group(1)) if m else []
    enc = re.search(rb'/Encoding\s+(\d+)\s+0\s+R', body)
    e = allobj.get(int(enc.group(1)), b'') if enc else b''
    dd = re.search(rb'/Differences\s*\[([^\]]*)\]', e, re.S)
    mp = {}; code = 0
    if dd:
        for mm in re.finditer(rb'(\d+)?((?:/[\w.]+)+)', dd.group(1)):
            if mm.group(1) is not None: code = int(mm.group(1))
            for nm in re.findall(rb'/([\w.]+)', mm.group(2)):
                mp[nm.decode('latin-1')] = code; code += 1
    return procs, mp

for num in [int(x) for x in sys.argv[1:]]:
    procs, mp = font_info(num)
    print("##### font %d  (%d glyphs) #####" % (num, len(procs)))
    items = [(mp.get(g.decode(), '?'), g.decode(), int(o)) for g, o in procs]
    items.sort(key=lambda t: (t[0] if isinstance(t[0], int) else 999))
    per = 9
    for start in range(0, len(items), per):
        chunk = items[start:start+per]
        print(' '.join(('code%-3s%-6s' % (c, g)).ljust(18) for c, g, _ in chunk))
        renders = [show(charproc_rows(o)) for _, _, o in chunk]
        renders = [r if r else ['.'*18]*22 for r in renders]
        for r in range(22):
            print(' '.join(renders[i][r].ljust(18) for i in range(len(chunk))))
        print()
