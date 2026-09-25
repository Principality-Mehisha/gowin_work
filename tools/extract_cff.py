import pickle, re, zlib, sys, struct

path = sys.argv[1] if len(sys.argv) > 1 else None
data = open(path, 'rb').read() if path else None

# We need raw stream for FontFile3 obj 13651 -> parse from pkl? pkl stores parsed objects (body with stream)
d = pickle.load(open(r"tools\pdf.pkl", "rb"))
a = d["allobj"]
body = a[13651]
print("FontFile3 body head:", body[:200])

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

s, hdr = get_stream(body)
print("hdr:", hdr[:300])
def dec(s, hdr):
    if b'FlateDecode' in hdr:
        return zlib.decompress(s)
    return s
cff = dec(s, hdr)
print("cff len", len(cff))
open(r"tools\font.cff", "wb").write(cff)
print(cff[:80])
