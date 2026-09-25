"""Decode the schematic text under a chosen Type3 code->character rule and report
how much recognisable English/identifier content results."""
import re, sys, json
sys.path.insert(0, 'tools')
from pdflib import load_pdf

PDF = sys.argv[1]
RULE = sys.argv[2] if len(sys.argv) > 2 else 'A'
allobj, get_stream, inflate = load_pdf(PDF)

# glyph code -> character (code values 1..39 as used by these subsets)
CODE_CHAR = {
 1:'4', 2:'2', 3:'3', 4:'T', 5:'D', 6:'C', 7:'E', 8:'8', 9:'6',
 10:'A', 11:'/', 12:'S', 13:'B', 14:'R', 15:'L', 16:'V', 17:'O', 18:'I',
 19:'G', 20:'7', 21:'H', 22:'-', 23:'K', 24:'G', 25:'M', 26:'Q', 27:'N',
 28:'F', 29:'P', 30:'Y', 31:'U', 32:'W', 33:'9', 34:'<', 35:'>', 36:'+',
 37:'X', 38:'|', 39:'5',
}

font_map = {}
for num, body in allobj.items():
    if b'/Type/Font' not in body: continue
    mproc = re.search(rb'/CharProcs\s*<<([^>]*)>>', body, re.S)
    cp = []
    if mproc:
        cp = [g.decode('latin-1') for g, _ in
              re.findall(rb'/(g\d+)\s+(\d+)\s+0\s+R', mproc.group(1))]
    enc = re.search(rb'/Encoding\s+(\d+)\s+0\s+R', body)
    eb = allobj.get(int(enc.group(1)), b'') if enc else b''
    if not eb: continue
    dd = re.search(rb'/Differences\s*\[([^\]]*)\]', eb, re.S)
    if not dd: continue
    n = len(cp)
    mp = {}; code = 0
    for mm in re.finditer(rb'(\d+)?((?:/[\w.]+)+)', dd.group(1)):
        if mm.group(1) is not None: code = int(mm.group(1))
        for nm in re.findall(rb'/([\w.]+)', mm.group(2)):
            name = nm.decode('latin-1')
            if name in cp:
                i = cp.index(name)
                c = (i + 1) if RULE == 'A' else (n - i)
                mp[code] = CODE_CHAR.get(c)
            code += 1
    if mp: font_map[num] = mp

pages = []
for num, body in allobj.items():
    if b'/Type/Page' in body and b'/Contents' in body:
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

out = open(sys.argv[3], 'w', encoding='utf-8')
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
            mp = font_map.get(fmap.get(cur))
            o = ''
            if mp:
                for ch in raw: o += (mp.get(ch) or '')
            items.append((y, x, o))
    items.sort(key=lambda t: (-t[0], t[1]))
    out.write("\n##### PAGE %d #####\n" % pno)
    ly = None; line = []
    for yy, xx, t in items:
        if ly is None or abs(yy-ly) > 1.2:
            if line: out.write(''.join(line) + '\n')
            line = []; ly = yy
            out.write('y=%7.1f | ' % yy)
        line.append(t)
    if line: out.write(''.join(line) + '\n')
out.close()

# score readability
t = open(sys.argv[3], encoding='utf-8').read()
import collections
letters = collections.Counter(ch for ch in t if ch.isalpha())
common = sum(letters[c] for c in 'ETAOIN SHRDLUetaoinshrdlu')
print("rule", RULE, "-> letters", sum(letters.values()), "common-letter score", common)
print("  top:", letters.most_common(12))
