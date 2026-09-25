"""Final schematic text extractor: uses the shared glyph-name space of the embedded
font (Type1 + Type3 subsets) so no CCITT decoding is required."""
import re, sys, json
sys.path.insert(0, 'tools')
from pdflib import load_pdf

PDF = sys.argv[1]
OUT = sys.argv[2]
allobj, get_stream, inflate = load_pdf(PDF)

# --- glyph object index -> character.  Verified by rendering every outline of the
#     embedded CFF subset font (tools/glyphrender.py) and reading the ASCII bitmaps.
GLYPH_CHAR = {
 1:'4',  2:'2',  3:'3',  4:'T',  5:'D',  6:'C',  7:'E',  8:'8',  9:'6',
 10:'A', 11:'/', 12:'S', 13:'B', 14:'R', 15:'L', 16:'V', 17:'O', 18:'I',
 19:'G', 20:'7', 21:'H', 22:'-', 23:'K', 24:'G', 25:'M', 26:'Q', 27:'N',
 28:'F', 29:'P', 30:'Y', 31:'U', 32:'W', 33:'9', 34:'<', 35:'>', 36:'+',
 37:'X', 38:'|', 39:'5',
}
# glyph name (gNN) -> character, used only for the Type1 font (which also has a
# /Differences list).  Object indexes and names differ; names are stable per glyph.
G2C = {
 'g3':'1','g18':'|','g19':'}','g20':'3','g21':'2','g24':'4','g25':'C','g26':'G',
 'g27':'N','g28':'7','g36':'K','g37':'L','g38':'D','g39':'T','g40':'Z','g41':'Y',
 'g42':'X','g43':'W','g44':'6','g45':'U','g46':'R','g47':'M','g48':'J','g49':'H',
 'g51':'F','g53':'9','g54':'P','g55':'E','g56':'0','g68':'+','g70':'V','g72':'S',
 'g76':'<','g79':'>','g81':'B','g82':'A','g85':'I','g86':'8','g87':'O','g88':'/',
 'g92':'Q',
}

# --- font obj -> {code: char} for every font (Type1 via Differences, Type3 via Differences) ---
font_map = {}
for num, body in allobj.items():
    if b'/Type/Font' not in body: continue
    mproc = re.search(rb'/CharProcs\s*<<([^>]*)>>', body, re.S)
    charprocs = []
    if mproc:
        charprocs = [g.decode('latin-1') for g, _ in
                     re.findall(rb'/(g\d+)\s+(\d+)\s+0\s+R', mproc.group(1))]
    # Type3: glyph code -> glyph name comes from the Encoding Differences list,
    # so only map a name to a character when it has been identified in the CFF.
    name_is_subset_local = bool(charprocs)
    enc = re.search(rb'/Encoding\s+(\d+)\s+0\s+R', body)
    enc_body = b''
    if enc:
        enc_body = allobj.get(int(enc.group(1)), b'')
    else:
        m2 = re.search(rb'/Encoding\s*<<(.*?)>>', body, re.S)
        if m2: enc_body = b'<<' + m2.group(1) + b'>>'
    if not enc_body: continue
    dd = re.search(rb'/Differences\s*\[([^\]]*)\]', enc_body, re.S)
    if not dd: continue

    def bind(name, cp=charprocs):
        # In this drawing every Type3 subset lists /CharProcs in code order,
        # i.e. the Nth entry corresponds to glyph code N (FirstChar is 1).
        if cp and name in cp:
            return GLYPH_CHAR.get(cp.index(name) + 1)
        return G2C.get(name)

    mp = {}; code = 0
    for mm in re.finditer(rb'(\d+)?((?:/[\w.]+)+)', dd.group(1)):
        if mm.group(1) is not None:
            code = int(mm.group(1))
        for nm in re.findall(rb'/([\w.]+)', mm.group(2)):
            mp[code] = bind(nm.decode('latin-1').lstrip('/'))
            code += 1
    if mp: font_map[num] = mp
own = {k: v for k, v in font_map.items() if any(x is not None for x in v.values())}
print("fonts with maps:", len(font_map), "with decoded chars:", len(own))

# --- pages ---
pages = []
for num, body in allobj.items():
    if b'/Type/Page' not in body or b'/Contents' not in body: continue
    c = re.search(rb'/Contents\s+(\d+)\s+0\s+R', body)
    if not c: continue
    rf = re.search(rb'/Font\s*<<([^>]*)>>', body, re.S)
    fmap = {}
    if rf:
        src = rf.group(1)
    else:
        m2 = re.search(rb'/Font\s+(\d+)\s+0\s+R', body)
        src = allobj.get(int(m2.group(1)), b'') if m2 else b''
    for mm in re.finditer(rb'/(\w+)\s+(\d+)\s+0\s+R', src):
        fmap[mm.group(1).decode()] = int(mm.group(2))
    pages.append((num, int(c.group(1)), fmap))
pages.sort()

NUM = r'[-+]?[\d.]+'
TOK = re.compile(
    r'(?P<font>/(\w+))\s+[\d.]+\s+Tf'
    r'|(?P<td>(?:' + NUM + r')\s+(?:' + NUM + r')\s+(?:TD|Td))'
    r'|(?P<tm>(?:' + NUM + r'\s+){6}Tm)'
    r'|(?P<tl>(?:' + NUM + r')\s+TL)'
    r'|(?P<tstar>T\*)'
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

total = 0
with open(OUT, 'w', encoding='utf-8') as fh:
    for pno, (pn, cn, fmap) in enumerate(pages, 1):
        body = allobj.get(cn)
        if body is None: continue
        s, hdr = get_stream(body)
        d = inflate(s, hdr)
        if d is None: continue
        txt = d.decode('latin-1')
        cur = None; x = y = 0
        items = []
        for m in TOK.finditer(txt):
            g = m.group(0)
            if m.group('font'):
                cur = m.group('font')[1:]
            elif m.group('tm'):
                v = [float(z) for z in re.findall(NUM, g)]
                if len(v) >= 6: x, y = v[4], v[5]
            elif m.group('td'):
                v = [float(z) for z in re.findall(NUM, g)]
                if len(v) >= 2: x += v[0]; y += v[1]
            elif m.group('str') or m.group('arr'):
                segs = re.findall(r'\((?:\\.|[^\\()])*\)', g, re.S)
                raw = b''.join(unescape(sg[1:-1].encode('latin-1')) for sg in segs)
                fo = fmap.get(cur)
                mp = font_map.get(fo) if fo is not None else None
                out = ''
                if mp:
                    for ch in raw:
                        c = mp.get(ch)
                        out += (c if c else '')
                items.append((y, x, out))
        items.sort(key=lambda t: (-t[0], t[1]))
        fh.write("\n########## PAGE %d (page obj %d, content obj %d) ##########\n" % (pno, pn, cn))
        lasty = None; line = []
        for yy, xx, t in items:
            if lasty is None or abs(yy-lasty) > 1.2:
                if line: fh.write(''.join(line) + '\n')
                line = [] ; lasty = yy
                fh.write('y=%7.1f | ' % yy)
            line.append(t)
        if line: fh.write(''.join(line) + '\n')
        total += len(items)
print("total items", total, "->", OUT)
