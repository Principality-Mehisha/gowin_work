"""Identify every Type3 glyph by matching its decoded 1-bit mask against the
embedded CFF (Type1) glyph outlines, whose character values are known."""
import re, sys, json
sys.path.insert(0, 'tools')
from pdflib import load_pdf, CFF, rasterize
from ccitt import decode_rows

PDF = sys.argv[1]
allobj, get_stream, inflate = load_pdf(PDF)

def stream_of(o):
    s, h = get_stream(allobj[o])
    return inflate(s, h)

cff = None
for num, body in allobj.items():
    if b'/FontFile3' in body or b'/FontFile2' in body:
        m = re.search(rb'/(?:FontFile[23])\s+(\d+)\s+0\s+R', body)
        if m:
            cff = CFF(stream_of(int(m.group(1))))
            break

# Verified by rendering the outlines (see tools/glyphrender.py output).
CFF_CHAR = {
 'g24':'4','g21':'2','g20':'3','g39':'T','g38':'D','g23':'5','g55':'E','g86':'8',
 'g25':'C','g44':'6','g3':'1','g82':'A','g81':'B','g42':'R','g72':'S','g70':'V',
 'g87':'O','g85':'I','g26':'G','g27':'N','g49':'H','g37':'-','g46':'K','g36':'G',
 'g47':'M','g92':'Q','g48':'J','g51':'F','g40':'P','g41':'Y','g45':'U','g43':'W',
 'g54':'9','g76':'<','g79':'>','g88':'+','g68':'X','g18':'|','g92 ':'Q',
}
# g20 appears twice in the CharSet list because two distinct shapes share widths.
CFF_CHAR.update({'g20':'3'})

RW, RH = 26, 34

def norm(grid, W, H):
    H0 = len(grid); W0 = len(grid[0]) if H0 else 0
    rows = [r for r in range(H0) if any(grid[r])]
    cols = [c for c in range(W0) if any(grid[r][c] for r in range(H0))]
    if not rows or not cols:
        return None
    r0, r1, c0, c1 = rows[0], rows[-1]+1, cols[0], cols[-1]+1
    sub = [row[c0:c1] for row in grid[r0:r1]]
    h, w = len(sub), len(sub[0])
    out = []
    for r in range(H):
        rr = min(h-1, r*h//H)
        row = [sub[rr][min(w-1, c*w//W)] for c in range(W)]
        out.append(row)
    return out

# reference rasters from the CFF outlines
refs = {}
for gi in range(1, len(cff.charstrings)):
    ch = CFF_CHAR.get(cff.glyph_names[gi])
    if ch is None: continue
    g, _ = rasterize(cff.outline(gi), RW, RH)
    if g: refs.setdefault(ch, g)

print("reference chars:", ''.join(sorted(refs)))

def variants(g):
    out = []
    for fv in (False, True):
        for fh in (False, True):
            gg = [list(reversed(r)) for r in g] if fh else [list(r) for r in g]
            if fv: gg = list(reversed(gg))
            out.append(gg)
    return out

def dist(a, b):
    return sum(1 for r in range(len(a)) for c in range(len(a[r])) if a[r][c] != b[r][c])

def decode_charproc(cnum):
    cb = allobj.get(cnum)
    if cb is None: return None
    s, hdr = get_stream(cb)
    d = inflate(s, hdr)
    if d is None or b'BI' not in d: return None
    i = d.find(b'BI'); j = d.find(b'EI', i)
    seg = d[i+2:j]
    mw = re.search(rb'/W\s+(\d+)', seg); mh = re.search(rb'/H\s+(\d+)', seg)
    if not (mw and mh): return None
    W = int(mw.group(1)); H = int(mh.group(1))
    k = seg.find(b'ID')
    body = seg[k+2:]
    if body[:1] == b'\r': body = body[1:]
    if body[:1] == b'\n': body = body[1:]
    if body[:1] == b' ': body = body[1:]
    rows = decode_rows(body, W, H)
    if len(rows) < H:
        rows += [[0]*W]*(H-len(rows))
    return rows

# collect every (font, glyphname) -> charproc
name2char = {}
suspect = []
for num, body in allobj.items():
    if b'/Subtype/Type3' not in body: continue
    m = re.search(rb'/CharProcs\s*<<([^>]*)>>', body, re.S)
    if not m: continue
    for gname, cnum in re.findall(rb'/(g\d+)\s+(\d+)\s+0\s+R', m.group(1)):
        gname = gname.decode('latin-1')
        key = (gname, int(cnum))
        if key in name2char: continue
        rows = decode_charproc(int(cnum))
        if rows is None:
            name2char[key] = None; continue
        n = norm(rows, RW, RH)
        if n is None:
            name2char[key] = None; continue
        best = None; bd = 1e9
        for ch, rg in refs.items():
            for v in variants(n):
                dd = dist(v, rg)
                if dd < bd: bd = dd; best = ch
        name2char[key] = (best, bd)
        if bd > 120:
            suspect.append((key, best, bd))

print("matched:", len(name2char), "suspect:", len(suspect))
for s in suspect[:25]:
    print("  ", s)

json.dump({"%s|%d" % k: v for k, v in name2char.items()},
          open('tools/glyphmatch.json', 'w'), indent=0)
print("saved tools/glyphmatch.json")
