import re, zlib
data = open(r"C:\Users\30415\.dsh\attachments\v1\files\e4\e457547f08ca37250b27ccfd4c8e29e3ce44cf309b24324623932fd2626002be\tang_mega_60k_30354_schematics..pdf","rb").read()
objs={}
for m in re.finditer(rb"(\d+)\s+(\d+)\s+obj", data):
    n=int(m.group(1)); s=m.end(); e=data.find(b"endobj", s)
    objs[n]=data[s:e]
for n in (126,127,164,165,368,395,420,509,597):
    b=objs[n]
    print("=== obj",n,"len",len(b))
    print(repr(b[:500]))
    print()
