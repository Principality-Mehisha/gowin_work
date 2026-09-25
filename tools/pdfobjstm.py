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
        for attempt in (0, 1):
            try:
                if attempt == 0:
                    return zlib.decompress(s)
                return zlib.decompressobj().decompress(s)
            except Exception:
                pass
        return None
    return s

# Parse ObjStm contents into pseudo objects
allobj = dict(objs)
for num, body in list(objs.items()):
    s, hdr = get_stream(body)
    if s is None:
        continue
    if b'/ObjStm' not in hdr:
        continue
    d = decode(s, hdr)
    if not d:
        continue
    mN = re.search(rb'/N\s+(\d+)', hdr)
    mF = re.search(rb'/First\s+(\d+)', hdr)
    if not (mN and mF):
        continue
    N = int(mN.group(1)); first = int(mF.group(1))
    hdrpart = d[:first]
    nums = [int(x) for x in hdrpart.split()]
    pairs = list(zip(nums[0::2], nums[1::2]))
    for i, (onum, off) in enumerate(pairs):
        end = pairs[i+1][1] + first if i+1 < len(pairs) else len(d)
        allobj[onum] = d[first+off:end]
    print("ObjStm", num, "-> N=", N, "first=", first, "extracted", len(pairs))

print("total objects now", len(allobj))

cmaps = {}
for num, body in allobj.items():
    if b'beginbfchar' in body or b'beginbfrange' in body:
        cmaps[num] = body
print("cmaps:", sorted(cmaps.keys()))

print("\n--- fonts ---")
for num, body in allobj.items():
    if b'/BaseFont' in body:
        bf = re.search(rb'/BaseFont\s*/([^\s/\]>]+)', body)
        tu = re.search(rb'/ToUnicode\s+(\d+)\s+0\s+R', body)
        sub = re.search(rb'/Subtype\s*/(\w+)', body)
        print(num, bf.group(1).decode() if bf else '?',
              'sub=', sub.group(1).decode() if sub else '?',
              'ToUnicode=', tu.group(1).decode() if tu else 'None')

# dump cmaps
for num, body in cmaps.items():
    print("\n===== CMAP %d =====" % num)
    print(body.decode('latin-1')[:4000])

import pickle
pickle.dump({'allobj': allobj, 'cmaps': cmaps}, open(sys.argv[2], 'wb'))
