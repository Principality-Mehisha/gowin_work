import re, sys, zlib

path = sys.argv[1]
data = open(path, 'rb').read()

objs = {}
for m in re.finditer(rb'(\d+)\s+(\d+)\s+obj', data):
    num = int(m.group(1))
    start = m.end()
    e = data.find(b'endobj', start)
    objs[num] = data[start:e]

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

def decode(s, hdr):
    if b'FlateDecode' in hdr:
        try:
            return zlib.decompress(s)
        except Exception:
            try:
                return zlib.decompressobj().decompress(s)
            except Exception:
                return None
    return s

# Find ToUnicode CMaps: objects containing "beginbfchar" or "beginbfrange"
cmaps = {}
for num, body in objs.items():
    s, hdr = get_stream(body)
    if s is None:
        continue
    d = decode(s, hdr)
    if d and (b'beginbfchar' in d or b'beginbfrange' in d):
        cmaps[num] = d
        print("CMAP obj", num, len(d))

print("total cmaps", len(cmaps))

# Also enumerate font objects and pages content
print("\n--- font objects ---")
for num, body in objs.items():
    if b'/Font' in body and b'/BaseFont' in body:
        bf = re.search(rb'/BaseFont\s*/([^\s/\]>]+)', body)
        tu = re.search(rb'/ToUnicode\s+(\d+)\s+0\s+R', body)
        enc = re.search(rb'/Encoding\s*/?([^\s/\]>]*)', body)
        sub = re.search(rb'/Subtype\s*/(\w+)', body)
        print(num, bf.group(1).decode() if bf else '?', 
              'sub=', sub.group(1).decode() if sub else '?',
              'tounicode=', tu.group(1).decode() if tu else 'None',
              'enc=', enc.group(1).decode() if enc else 'None')
