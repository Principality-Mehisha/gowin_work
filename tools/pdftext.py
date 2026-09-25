"""Decode the schematic PDF text using the embedded subset font, with positions."""
import re, sys, zlib, struct, pickle

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

def decode(s, hdr):
    if not s: return s
    if b'FlateDecode' in hdr:
        for fn in (lambda x: zlib.decompress(x),
                   lambda x: zlib.decompressobj().decompress(x)):
            try: return fn(s)
            except Exception: pass
        return None
    return s

allobj = dict(objs)
for num, body in list(objs.items()):
    s, hdr = get_stream(body)
    if s is None or b'/ObjStm' not in hdr: continue
    d = decode(s, hdr)
    if not d: continue
    mN = re.search(rb'/N\s+(\d+)', hdr); mF = re.search(rb'/First\s+(\d+)', hdr)
    if not (mN and mF): continue
    N = int(mN.group(1)); first = int(mF.group(1))
    nums = [int(x) for x in d[:first].split()]
    pairs = list(zip(nums[0::2], nums[1::2]))
    for i, (onum, off) in enumerate(pairs):
        end = pairs[i+1][1] + first if i+1 < len(pairs) else len(d)
        allobj[onum] = d[first+off:end]

# ---- glyph name -> character (derived from rendering the embedded CFF) ----
G2C = {
 'g3':'1','g18':'|','g19':'}','g20':'3','g21':'2','g22':'?','g23':'5','g24':'4',
 'g25':'C','g26':'G','g27':'N','g28':'7','g36':'K','g37':'L','g38':'D','g39':'T',
 'g40':'Z','g41':'Y','g42':'X','g43':'W','g44':'6','g45':'U','g46':'R','g47':'M',
 'g48':'J','g49':'H','g50':'~','g51':'F','g53':'9','g54':'P','g55':'E','g56':'0',
 'g57':'?','g59':'?','g68':'+','g70':'V','g72':'S','g76':'<','g79':'>','g81':'B',
 'g82':'A','g85':'I','g86':'8','g87':'O','g88':'/','g92':'Q',
 'g24_':'?',
}

# Build per-font code->char maps from Encoding Differences
cmaps = {}   # fontobj -> {code: char}
for num, body in allobj.items():
    if b'/BaseFont' not in body: continue
    m = re.search(rb'/Encoding\s+(\d+)\s+0\s+R', body)
    if not m: continue
    enc = allobj.get(int(m.group(1)), b'')
    d = re.search(rb'/Differences\s*\[(.*?)\]', enc, re.S)
    if not d: continue
    toks = d.group(1).split()
    mp = {}; code = 0
    for t in toks:
        if re.fullmatch(rb'\d+', t): code = int(t)
        else:
            name = t.decode('latin-1').lstrip('/')
            mp[code] = G2C.get(name, '{%s}' % name)
            code += 1
    cmaps[num] = mp
    print("font obj", num, "codes:", len(mp))

# ---- Walk content streams ----
def unescape(b):
    out = bytearray(); i = 0
    while i < len(b):
        c = b[i]
        if c == 0x5c and i+1 < len(b):
            n = b[i+1]
            mp = {0x6e:10, 0x72:13, 0x74:9, 0x62:8, 0x66:12, 0x28:0x28, 0x29:0x29, 0x5c:0x5c}
            if n in mp: out.append(mp[n]); i += 2; continue
            if 0x30 <= n <= 0x37:
                j = i+1; o = b''
                while j < len(b) and len(o) < 3 and 0x30 <= b[j] <= 0x37:
                    o += bytes([b[j]]); j += 1
                out.append(int(o, 8) & 0xFF); i = j; continue
            i += 2; continue
        out.append(c); i += 1
    return bytes(out)

NUM = r'[-+]?[\d.]+'
TOK = re.compile((
    r'(?P<font>/(F\w+))\s+(?P<fsize>[\d.]+)\s+Tf'
    r'|(?P<td>(' + NUM + r')\s+(' + NUM + r')\s+(?P<tdop>TD|Td))'
    r'|(?P<tm>(' + NUM + r'\s+){6}Tm)'
    r'|(?P<tl>(' + NUM + r')\s+TL)'
    r'|(?P<tstar>T\*)'
    r'|(?P<str>\((?:\\.|[^\\()])*\))'
    r'|(?P<arr>\[(?:[^\[\]\\]|\\.)*\])\s*TJ'
    r'|(?P<bt>BT)'
    r'|(?P<et>ET)'
), re.S)

# page content streams: find content object numbers via /Contents
page_content = []
for num, body in allobj.items():
    if b'/Type/Page' in body or b'/Type /Page' in body:
        m = re.search(rb'/Contents\s+(\d+)\s+0\s+R', body)
        if m: page_content.append((num, int(m.group(1))))
print("pages:", page_content)

# font name -> obj mapping from resources
resmap = {}
for num, body in allobj.items():
    if b'/Font' in body and b'>>' in body and len(body) < 900:
        for mm in re.finditer(rb'/(F\d+)\s+(\d+)\s+0\s+R', body):
            resmap[mm.group(1).decode()] = int(mm.group(2))
print("resource font map:", resmap)

def decode_with_font(raw, fontobj):
    mp = cmaps.get(fontobj, {})
    s = ''
    for ch in raw:
        c = chr(ch) if isinstance(ch, int) else ch
        s += mp.get(ord(c), '{%d}' % ord(c))
    return s

items = []
for pnum, cnum in page_content:
    body = allobj.get(cnum)
    if body is None: continue
    s, hdr = get_stream(body)
    d = decode(s, hdr)
    if d is None: continue
    txt = d.decode('latin-1')
    curfont = None; x = y = 0; fsize = 10
    for m in TOK.finditer(txt):
        g = m.group(0)
        if m.group('font'):
            curfont = m.group('font')[1:]
        elif m.group('tm'):
            nums = [float(v) for v in re.findall(NUM, g)]
            x, y = nums[4], nums[5]
        elif m.group('td'):
            nums = [float(v) for v in re.findall(NUM, g)]
            x += nums[0]; y += nums[1]
        elif m.group('tl'):
            pass
        elif m.group('str'):
            raw = unescape(m.group('str')[1:-1].encode('latin-1'))
            fo = resmap.get(curfont)
            items.append((y, x, decode_with_font(raw, fo)))

print("text items:", len(items))

items.sort(key=lambda t: (-t[0], t[1]))
with open(OUT, 'w', encoding='utf-8') as f:
    lasty = None
    line = []
    for y, x, t in items:
        if lasty is None or abs(y-lasty) > 1.5:
            if line: f.write(''.join(line) + '\n')
            line = []
            f.write('y=%8.1f | ' % y)
            lasty = y
        line.append(t)
    if line: f.write(''.join(line) + '\n')
print("written", OUT)
