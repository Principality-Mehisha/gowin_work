import re, zlib, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
data = open(r"C:\Users\30415\.dsh\attachments\v1\files\e4\e457547f08ca37250b27ccfd4c8e29e3ce44cf309b24324623932fd2626002be\tang_mega_60k_30354_schematics..pdf","rb").read()
objs={}
for m in re.finditer(rb"(\d+)\s+(\d+)\s+obj", data):
    n=int(m.group(1)); s=m.end(); e=data.find(b"endobj", s)
    objs[n]=data[s:e]
def gs(body):
    i=body.find(b"stream")
    if i<0: return None,body
    h=body[:i]; j=i+6
    if body[j:j+2]==b"\r\n": j+=2
    elif body[j:j+1] in (b"\n",b"\r"): j+=1
    return body[j:body.rfind(b"endstream")],h
def infl(s,h):
    if b"FlateDecode" in h:
        try: return zlib.decompress(s)
        except Exception: return zlib.decompressobj().decompress(s)
    return s
allobj=dict(objs)
for n,b in list(objs.items()):
    s,h=gs(b)
    if s is None or b"/ObjStm" not in h: continue
    d=infl(s,h); first=int(re.search(rb"/First\s+(\d+)",h).group(1))
    nums=[int(x) for x in d[:first].split()]
    pairs=list(zip(nums[0::2],nums[1::2]))
    for i,(on,off) in enumerate(pairs):
        end=pairs[i+1][1]+first if i+1<len(pairs) else len(d)
        allobj[on]=d[first+off:end]
print("obj5 present:", 5 in allobj, 5 in objs)
b=allobj.get(5)
print("raw head:", repr(b[:200]))
s,h=gs(b)
print("hdr",h[:200])
d=infl(s,h)
print("len",len(d) if d else None)
print(repr(d[:2000]))
