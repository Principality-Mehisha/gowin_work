import re, zlib, pickle
data = open(r"C:\Users\30415\.dsh\attachments\v1\files\e4\e457547f08ca37250b27ccfd4c8e29e3ce44cf309b24324623932fd2626002be\tang_mega_60k_30354_schematics..pdf","rb").read()
objs={}
for m in re.finditer(rb"(\d+)\s+(\d+)\s+obj", data):
    n=int(m.group(1)); s=m.end(); e=data.find(b"endobj", s)
    objs[n]=data[s:e]
for n in (4,128,166,369,396,421,510,5):
    print("=== obj",n,"===")
    print(objs[n][:600].decode("latin-1"))
    print()
