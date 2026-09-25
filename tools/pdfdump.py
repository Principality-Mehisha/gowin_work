import re, sys, zlib, collections

path = sys.argv[1]
data = open(path, 'rb').read()
print("size", len(data))

# find all stream objects
objs = {}
for m in re.finditer(rb'(\d+)\s+(\d+)\s+obj', data):
    num = int(m.group(1))
    start = m.end()
    e = data.find(b'endobj', start)
    objs[num] = data[start:e]
print("objects:", len(objs))

def get_stream(body):
    i = body.find(b'stream')
    if i < 0:
        return None, body
    hdr = body[:i]
    j = i + 6
    if body[j:j+2] == b'\r\n':
        j += 2
    elif body[j:j+1] in (b'\n', b'\r'):
        j += 1
    k = body.rfind(b'endstream')
    return body[j:k], hdr

streams = []
for num, body in objs.items():
    s, hdr = get_stream(body)
    if s is None:
        continue
    if b'FlateDecode' in hdr:
        try:
            s = zlib.decompress(s)
        except Exception as ex:
            try:
                s = zlib.decompressobj().decompress(s)
            except Exception:
                continue
    streams.append((num, hdr[:200], s))

print("streams:", len(streams))

def unescape(b):
    out = bytearray()
    i = 0
    while i < len(b):
        c = b[i]
        if c == 0x5c and i + 1 < len(b):
            n = b[i+1]
            mp = {0x6e: 10, 0x72: 13, 0x74: 9, 0x62: 8, 0x66: 12,
                  0x28: 0x28, 0x29: 0x29, 0x5c: 0x5c}
            if n in mp:
                out.append(mp[n]); i += 2; continue
            if 0x30 <= n <= 0x37:
                j = i + 1; oct_s = b''
                while j < len(b) and len(oct_s) < 3 and 0x30 <= b[j] <= 0x37:
                    oct_s += bytes([b[j]]); j += 1
                out.append(int(oct_s, 8) & 0xFF); i = j; continue
            i += 2; continue
        out.append(c); i += 1
    return bytes(out)

# Extract text-showing operators with positions
all_lines = []
for num, hdr, s in streams:
    if b'Tj' not in s and b'TJ' not in s:
        continue
    try:
        txt = s.decode('latin-1')
    except Exception:
        continue
    # tokenize: track Td/TD/Tm/T* for y positions, and (..) Tj / [..] TJ
    items = []
    for m in re.finditer(
            r'\((?:\\.|[^\\()])*\)\s*Tj'
            r'|\[(?:[^\[\]\\]|\\.)*\]\s*TJ'
            r'|([-\d.]+)\s+([-\d.]+)\s+(Td|TD)'
            r'|([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)\s+Tm'
            r'|(T\*)', txt, re.S):
        g = m.group(0)
        if g.endswith('Tj'):
            raw = g[:g.rfind(')')+1]
            raw = raw[raw.find('('):]
            inner = raw[1:-1]
            try:
                items.append(('t', unescape(inner.encode('latin-1'))))
            except Exception:
                pass
        elif g.endswith('TJ'):
            inner = g[g.find('[')+1:g.rfind(']')]
            parts = re.findall(r'\((?:\\.|[^\\()])*\)', inner, re.S)
            buf = b''
            for p in parts:
                buf += unescape(p[1:-1].encode('latin-1'))
            items.append(('t', buf))
        elif g.endswith('Td') or g.endswith('TD'):
            items.append(('m', (float(m.group(1)), float(m.group(2)))))
        elif g.endswith('Tm'):
            items.append(('m', (float(m.group(4)), float(m.group(5)))))
        else:
            items.append(('m', None))
    if items:
        all_lines.append((num, items))

print("text streams:", len(all_lines))

out = open(sys.argv[2], 'w', encoding='utf-8')
for num, items in all_lines:
    out.write("\n===== obj %d =====\n" % num)
    cur = []
    for kind, val in items:
        if kind == 't':
            cur.append(val.decode('latin-1'))
        else:
            if cur:
                out.write(''.join(cur) + "\n")
                cur = []
    if cur:
        out.write(''.join(cur) + "\n")
out.close()
print("written", sys.argv[2])
