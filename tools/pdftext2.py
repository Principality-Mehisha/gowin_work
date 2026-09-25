"""Decode the Tang Mega 60K schematic PDF text (Type1 subset + Type3 fonts), with positions."""
import re, sys, zlib

PDF = sys.argv[1]
OUT = sys.argv[2]
data = open(PDF, 'rb').read()

objs = {}
for m in re.finditer(rb'(\d+)\s+(\d+)\s+obj', data):
    num = int(m.group(1)); start = m.end()
    e = data.find(b'endobj', start)
    objs[num] = data[start:e]

def get_stream(body):
    i = body.find(b'stream')
    if i < 0: return None, body
    hdr = body[:i]; j = i + 6
    if body[j:j+2] == b'\r\n': j += 2
    elif body[j:j+1] in (b'\n', b'\r'): j += 1
    return body[j:body.rfind(b'endstream')], hdr

def inflate(s, hdr):
    if not s: return s
    if b'FlateDecode' in hdr:
        for fn in (zlib.decompress, lambda x: zlib.decompressobj().decompress(x)):
            try: return fn(s)
            except Exception: pass
        return None
    return s

allobj = dict(objs)
for num, body in list(objs.items()):
    s, hdr = get_stream(body)
    if s is None or b'/ObjStm' not in hdr: continue
    d = inflate(s, hdr)
    if not d: continue
    mN = re.search(rb'/N\s+(\d+)', hdr); mF = re.search(rb'/First\s+(\d+)', hdr)
    if not (mN and mF): continue
    first = int(mF.group(1))
    nums = [int(x) for x in d[:first].split()]
    pairs = list(zip(nums[0::2], nums[1::2]))
    for i, (onum, off) in enumerate(pairs):
        end = pairs[i+1][1] + first if i+1 < len(pairs) else len(d)
        allobj[onum] = d[first+off:end]

# ---------- glyph name -> char, derived by rendering the embedded CFF ----------
G2C = {
 'g3':'1','g18':'|','g19':'}','g20':'3','g21':'2','g22':'?','g23':'5','g24':'4',
 'g25':'C','g26':'G','g27':'N','g28':'7','g36':'K','g37':'L','g38':'D','g39':'T',
 'g40':'Z','g41':'Y','g42':'X','g43':'W','g44':'6','g45':'U','g46':'R','g47':'M',
 'g48':'J','g49':'H','g50':'~','g51':'F','g53':'9','g54':'P','g55':'E','g56':'0',
 'g68':'+','g70':'V','g72':'S','g76':'<','g79':'>','g81':'B','g82':'A','g85':'I',
 'g86':'8','g87':'O','g88':'/','g92':'Q',
}

# ---------- font tables ----------
# Type1: named glyphs via Differences. Type3: /CharProcs entries, share one CFF.
font_map = {}       # objnum -> {code: char}
type1_of = {}
for num, body in allobj.items():
    if b'/Subtype/Type1' in body and b'/BaseFont' in body:
        enc = re.search(rb'/Encoding\s+(\d+)\s+0\s+R', body)
        if not enc: continue
        e = allobj.get(int(enc.group(1)), b'')
        d = re.search(rb'/Differences\s*\[(.*?)\]', e, re.S)
        if not d: continue
        mp = {}; code = 0
        for t in d.group(1).split():
            if re.fullmatch(rb'\d+', t): code = int(t)
            else:
                mp[code] = G2C.get(t.decode('latin-1').lstrip('/'), None)
                code += 1
        font_map[num] = mp
        type1_of[num] = 'TT1A2o00'

# Type3 fonts: group by CharProcs signature
def charprocs_sig(body):
    m = re.search(rb'/CharProcs\s*<<(.*?)>>', body, re.S)
    return tuple(sorted(re.findall(rb'/(g\d+)', m.group(1)))) if m else None

groups = {}
for num, body in allobj.items():
    if b'/Subtype/Type3' not in body: continue
    sig = charprocs_sig(body)
    if sig: groups.setdefault(sig, []).append(num)
print("type3 groups:", {len(v): v for k, v in groups.items()})

# ---------- parse content streams ----------
NUM = r'[-+]?[\d.]+'
TEXT_RE = re.compile(
    r'(?P<font>/(F\d+))\s+[\d.]+\s+Tf'
    r'|(?P<td>(?:' + NUM + r')\s+(?:' + NUM + r')\s+(?:TD|Td))'
    r'|(?P<tm>(?:' + NUM + r'\s+){6}Tm)'
    r'|(?P<tl>(?:' + NUM + r')\s+TL)'
    r'|(?P<tstar>T\*)'
    r'|(?P<str>\((?:\\.|[^\\()])*\))'
    r'|(?P<arr>\[(?:[^\[\]\\]|\\.)*\])\s*TJ'
, re.S)

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

# find pages with resources dict available
pages = []
for num, body in allobj.items():
    if not (b'/Type/Page' in body and b'/Contents' in body): continue
    c = re.search(rb'/Contents\s+(\d+)\s+0\s+R', body)
    if not c: continue
    rf = re.search(rb'/Font\s*<<(.*?)>>', body, re.S)
    fmap = {}
    if rf:
        for mm in re.finditer(rb'/(\w+)\s+(\d+)\s+0\s+R', rf.group(1)):
            fmap[mm.group(1).decode()] = int(mm.group(2))
    else:
        rr = re.search(rb'/Font\s+(\d+)\s+0\s+R', body)
        fo = int(rr.group(1)) if rr else None
        if fo is not None:
            inner = allobj.get(fo, b'')
            for mm in re.finditer(rb'/(\w+)\s+(\d+)\s+0\s+R', inner):
                fmap[mm.group(1).decode()] = int(mm.group(2))
    pages.append((num, int(c.group(1)), fmap))
print("pages:", [(p[0], p[1], p[2]) for p in pages])

def _rr(fontobj, depth=0):
    """Given a font OBJECT number, return {code: char} for it."""
    return font_map.get(fontobj)

def write_page_text(pno, cnum, fmap, fh):
    body = allobj.get(cnum)
    if body is None: return 0
    s, hdr = get_stream(body)
    d = inflate(s, hdr)
    if d is None: return 0
    txt = d.decode('latin-1')
    cur = None; x = y = 0
    items = []
    for m in TEXT_RE.finditer(txt):
        g = m.group(0)
        if m.group('font'):
            cur = m.group('font')[1:]
        elif m.group('tm'):
            nums = [float(v) for v in re.findall(NUM, g)]
            if len(nums) >= 6: x, y = nums[4], nums[5]
        elif m.group('td'):
            nums = [float(v) for v in re.findall(NUM, g)]
            if len(nums) >= 2: x += nums[0]; y += nums[1]
        elif m.group('str') or m.group('arr'):
            segs = re.findall(r'\((?:\\.|[^\\()])*\)', g, re.S)
            raw = b''.join(unescape(sg[1:-1].encode('latin-1')) for sg in segs)
            fo = fmap.get(cur)
            mp = font_map.get(fo) if fo is not None else None            out = ''
            for ch in raw:
                if mp is None: out += ''
                else: out += (mp.get(ch) or '')
            items.append((y, x, out))
    items.sort(key=lambda t: (-t[0], t[1]))
    fh.write("\n########## PAGE %d (obj %d) ##########\n" % (pno, cnum))
    lasty = None; line = []
    for yy, xx, t in items:
        if lasty is None or abs(yy-lasty) > 1.2:
            if line: fh.write(''.join(line) + '\n')
            line = []; lasty = yy
            fh.write('y=%7.1f | ' % yy)
        line.append(t)
    if line: fh.write(''.join(line) + '\n')
    return len(items)

total = 0
with open(OUT, 'w', encoding='utf-8') as fh:
    for i, (pn, cn, rn) in enumerate(pages, 1):
        total += write_page_text(i, cn, rn, fh)
print("total items", total, "->", OUT)
