"""Decode Type3 1-bit image-mask glyphs and match them against the embedded CFF font."""
import re, sys, zlib, json
sys.path.insert(0, 'tools')
from pdflib import load_pdf, CFF, rasterize

PDF = sys.argv[1]
allobj, get_stream, inflate = load_pdf(PDF)

def stream_of(objnum):
    s, hdr = get_stream(allobj[objnum])
    return inflate(s, hdr)

cff = None
for num, body in allobj.items():
    if b'/FontFile3' in body or b'/FontFile2' in body:
        m = re.search(rb'/(FontFile[23])\s+(\d+)\s+0\s+R', body)
        if m:
            cff = CFF(stream_of(int(m.group(2))))
            break

G2C = {
 'g3':'1','g18':'|','g19':'}','g20':'3','g21':'2','g22':'?','g23':'5','g24':'4',
 'g25':'C','g26':'G','g27':'N','g28':'7','g36':'K','g37':'L','g38':'D','g39':'T',
 'g40':'Z','g41':'Y','g42':'X','g43':'W','g44':'6','g45':'U','g46':'R','g47':'M',
 'g48':'J','g49':'H','g50':'~','g51':'F','g53':'9','g54':'P','g55':'E','g56':'0',
 'g68':'+','g70':'V','g72':'S','g76':'<','g79':'>','g81':'B','g82':'A','g85':'I',
 'g86':'8','g87':'O','g88':'/','g92':'Q',
}

# ---- decode a 1-bit image mask ----
def decode_mask(data, W, H, BPC=1):
    stride = (W*BPC + 7)//8
    rows = []
    for r in range(H):
        chunk = data[r*stride:(r+1)*stride]
        bits = []
        for b in chunk:
            for k in range(7, -1, -1):
                bits.append((b >> k) & 1)
        rows.append(bits[:W])
    return rows

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
    # image data: after 'ID' plus one whitespace byte, until 'EI'
    k = seg.find(b'ID')
    body = seg[k+2:]
    if body[:1] in (b'\r', b'\n', b' '):
        body = body[1:]
        if body[:1] == b'\n': body = body[1:]
    body = body.rstrip(b'\r\n ')
    stride = (W*BPC + 7)//8
    need = stride*H
    body = body[:need]
    if len(body) < need:
        body = body + b'\x00'*(need-len(body))
    rows = decode_mask(body, W, H, BPC)
    # decode array: decoded = dec[0]*x + dec[1]; for image mask, 1 => paint
    paint1 = (dec[0] > 0)
    if not paint1:
        rows = [[1-v for v in r] for r in rows]
    pre = d[:i]
    m = re.match(rb'\s*([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)\s+d1', pre)
    adv = (float(m.group(1)), float(m.group(2))) if m else (0, 0)
    # the cm inside: q A 0 0 D E F cm
    cm = re.search(rb'q\s+([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)\s+cm', pre)
    cmv = [float(x) for x in cm.groups()] if cm else [1,0,0,1,0,0]
    return rows, adv, cmv

# ---- Build CFF reference rasters at 24x30 ----
RW, RH = 24, 30
refs = {}
for gi in range(1, len(cff.charstrings)):
    name = cff.glyph_names[gi]
    ch = G2C.get(name)
    if ch is None: continue
    conts = cff.outline(gi)
    g, box = rasterize(conts, RW, RH)
    if g: refs[name] = g

def norm(grid, W, H):
    H0, W0 = len(grid), len(grid[0])
    # tight crop
    rows = [r for r in range(H0) if any(grid[r])]
    cols = [c for c in range(W0) if any(grid[r][c] for r in range(H0))]
    if not rows or not cols: return None
    r0, r1 = rows[0], rows[-1]+1
    c0, c1 = cols[0], cols[-1]+1
    sub = [row[c0:c1] for row in grid[r0:r1]]
    h, w = len(sub), len(sub[0])
    out = []
    for r in range(H):
        row = []
        for c in range(W):
            rr = min(h-1, int(r*h/H)); cc = min(w-1, int(c*w/W))
            row.append(sub[rr][cc])
        out.append(row)
    return out

def variants(g):
    out = []
    for flipv in (False, True):
        for fliph in (False, True):
            gg = [list(reversed(r)) for r in g] if fliph else [list(r) for r in g]
            if flipv: gg = list(reversed(gg))
            out.append(gg)
    return out

def dist(a, b):
    return sum(1 for r in range(len(a)) for c in range(len(a[r])) if a[r][c] != b[r][c])

# ---- collect unique charproc signatures ----
sig2proc = {}
for num, body in allobj.items():
    if b'/Subtype/Type3' not in body: continue
    for m in re.finditer(rb'/(g\d+)\s+(\d+)\s+0\s+R', body):
        sig2proc.setdefault(int(m.group(2)), set()).add((num, m.group(1).decode()))

print("unique charprocs:", len(sig2proc))

mapping = {}   # (fontobj, glyphname) -> char or None
cache = {}
for cnum, users in sig2proc.items():
    parsed = parse_charproc(cnum)
    if parsed is None:
        ch = None
    else:
        rows, adv, cmv = parsed
        n = norm(rows, RW, RH)
        if n is None:
            ch = None
        else:
            best = None; bd = 1e9
            for rn, rg in refs.items():
                for v in variants(n):
                    d = dist(v, rg)
                    if d < bd: bd = d; best = rn
            ch = (G2C.get(best), bd, best)
    cache[cnum] = ch
    for u in users:
        mapping[u] = ch

print("sample:", list(mapping.items())[:15])
json.dump({"%d|%s" % k: (None if v is None else [v[0], v[1], v[2]])
           for k, v in mapping.items()},
          open('tools/type3map.json', 'w'), indent=0)
# report bad matches
bad = {k: v for k, v in mapping.items() if v is None or v[0] is None or v[1] > 90}
print("suspect matches:", len(bad), "of", len(mapping))
for k, v in list(bad.items())[:20]:
    print("  ", k, v)
