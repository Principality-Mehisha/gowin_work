"""Final decoder.

Key insight: the PDF reuses the same glyph objects (CharProcs) across many font
subsets, but each subset assigns its own glyph codes.  So we resolve, for each
font, code -> CharProc object, and then object -> character via a global catalog.
The catalog is seeded from font 574 (the full 39-glyph subset) whose /Differences
order is code = CharProcs index + 1, and from font 10 (verified by rendering).
"""
import re, sys
sys.path.insert(0, 'tools')
from pdflib import load_pdf

PDF = sys.argv[1]
OUT = sys.argv[2]
allobj, get_stream, inflate = load_pdf(PDF)

# ---------------------------------------------------------------- fonts
# font obj -> (ordered CharProcs object list, {code: charproc index})
fonts = {}
for num, body in allobj.items():
    if b'/Type/Font' not in body or b'/Subtype/Type3' not in body: continue
    m = re.search(rb'/CharProcs\s*<<([^>]*)>>', body, re.S)
    if not m: continue
    procs = [(g.decode('latin-1'), int(o)) for g, o in
             re.findall(rb'/(g\d+)\s+(\d+)\s+0\s+R', m.group(1))]
    enc = re.search(rb'/Encoding\s+(\d+)\s+0\s+R', body)
    e = allobj.get(int(enc.group(1)), b'') if enc else b''
    dd = re.search(rb'/Differences\s*\[([^\]]*)\]', e, re.S)
    if not dd: continue
    codemap = {}; code = 0
    for mm in re.finditer(rb'(\d+)?((?:/[\w.]+)+)', dd.group(1)):
        if mm.group(1) is not None: code = int(mm.group(1))
        for nm in re.findall(rb'/([\w.]+)', mm.group(2)):
            codemap[code] = nm.decode('latin-1'); code += 1
    fonts[num] = (procs, codemap)

# ------------------------------------------------- global object -> character
# The first drawing line of the title block carries this board's part number.
TITLE = "GW5AT-LV60PG484AC1/10"
catalog = {}

def seed(fontobj, plaintext):
    procs, codemap = fonts[fontobj]
    byobj = {o: n for n, o in procs}
    # code order of the plaintext = ascending code, starting at FirstChar
    codes = sorted(codemap)
    if len(codes) != len(plaintext):
        print("warn: font %d has %d codes but title has %d chars"
              % (fontobj, len(codes), len(plaintext)))
    for c, ch in zip(codes, plaintext):
        name = codemap.get(c)
        if name is None: continue
        for nm, o in procs:
            if nm == name:
                catalog[o] = ch
                break

# font 574 / 56 share the 39-glyph set that carries the title line
seed(574, TITLE)
print("catalog after seeding:", len(catalog))

# Propagate: a font whose CharProcs objects are all already known lets us learn
# new objects?  No - instead, use fonts that share the SAME object set.
shared = {}
for f, (procs, cm) in fonts.items():
    key = tuple(sorted(o for _, o in procs))
    shared.setdefault(key, []).append(f)
for key, fl in shared.items():
    known = [o for o in key if o in catalog]
    if known and len(known) != len(key):
        pass
print("distinct glyph-object sets:", len(shared))
for key, fl in sorted(shared.items(), key=lambda kv: -len(kv[1]))[:12]:
    got = sum(1 for o in key if o in catalog)
    print("   fonts %-30s glyphs %3d known %3d" % (fl[:6], len(key), got))

# ---------------------------------------------------------------- pages
pages = []
for num, body in allobj.items():
    if b'/Type/Page' not in body or b'/Contents' not in body: continue
    c = re.search(rb'/Contents\s+(\d+)\s+0\s+R', body)
    if not c: continue
    rf = re.search(rb'/Font\s*<<([^>]*)>>', body, re.S)
    if rf: src = rf.group(1)
    else:
        m2 = re.search(rb'/Font\s+(\d+)\s+0\s+R', body)
        src = allobj.get(int(m2.group(1)), b'') if m2 else b''
    fmap = {}
    for mm in re.finditer(rb'/(\w+)\s+(\d+)\s+0\s+R', src):
        fmap[mm.group(1).decode()] = int(mm.group(2))
    pages.append((num, int(c.group(1)), fmap))
pages.sort()

NUM = r'[-+]?[\d.]+'
TOK = re.compile(
    r'(?P<font>/(\w+))\s+[\d.]+\s+Tf'
    r'|(?P<td>(?:' + NUM + r')\s+(?:' + NUM + r')\s+(?:TD|Td))'
    r'|(?P<tm>(?:' + NUM + r'\s+){6}Tm)'
    r'|(?P<str>\((?:\\.|[^\\()])*\))'
    r'|(?P<arr>\[(?:[^\[\]\\]|\\.)*\])\s*TJ', re.S)

def unescape(b):
    out = bytearray(); i = 0
    while i < len(b):
        c = b[i]
        if c == 0x5c and i+1 < len(b):
            n = b[i+1]
            mp = {0x6e:10,0x72:13,0x74:9,0x62:8,0x66:12,0x28:0x28,0x29:0x29,0x5c:0x5c}
            if n in mp: out.append(mp[n]); i += 2; continue
            if 0x30 <= n <= 0x37:
                j = i+1; o = b''
                while j < len(b) and len(o) < 3 and 0x30 <= b[j] <= 0x37:
                    o += bytes([b[j]]); j += 1
                out.append(int(o,8) & 0xFF); i = j; continue
            out += bytes([n]); i += 2; continue
        out.append(c); i += 1
    return bytes(out)

# per font: code -> object
font_code_obj = {}
for f, (procs, cm) in fonts.items():
    byname = {}
    for nm, o in procs:
        byname.setdefault(nm, o)
    font_code_obj[f] = {c: byname.get(nm) for c, nm in cm.items() if nm in byname}

with open(OUT, 'w', encoding='utf-8') as fh:
    for pno, (pn, cn, fmap) in enumerate(pages, 1):
        body = allobj.get(cn)
        if body is None: continue
        s, hdr = get_stream(body)
        d = inflate(s, hdr)
        if d is None: continue
        txt = d.decode('latin-1')
        cur = None; x = y = 0; items = []
        for m in TOK.finditer(txt):
            g = m.group(0)
            if m.group('font'): cur = m.group('font')[1:]
            elif m.group('tm'):
                v = [float(z) for z in re.findall(NUM, g)]
                if len(v) >= 6: x, y = v[4], v[5]
            elif m.group('td'):
                v = [float(z) for z in re.findall(NUM, g)]
                if len(v) >= 2: x += v[0]; y += v[1]
            else:
                segs = re.findall(r'\((?:\\.|[^\\()])*\)', g, re.S)
                raw = b''.join(unescape(sg[1:-1].encode('latin-1')) for sg in segs)
                com = font_code_obj.get(fmap.get(cur), {})
                o = ''.join(catalog.get(com.get(ch), '') for ch in raw)
                items.append((y, x, o))
        items.sort(key=lambda t: (-t[0], t[1]))
        fh.write("\n##### PAGE %d (obj %d) #####\n" % (pno, pn))
        ly = None; line = []
        for yy, xx, t in items:
            if ly is None or abs(yy-ly) > 1.2:
                if line: fh.write(''.join(line) + '\n')
                line = []; ly = yy
                fh.write('y=%7.1f | ' % yy)
            line.append(t)
        if line: fh.write(''.join(line) + '\n')
print("wrote", OUT, "catalog size", len(catalog))
