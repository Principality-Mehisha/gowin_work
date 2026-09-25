import re, sys, zlib, pickle

d = pickle.load(open(sys.argv[1], 'rb'))
allobj = d['allobj']

# show font descriptor and font object fully
for num in (19,):
    print("=== obj", num, "===")
    b = allobj[num]
    print(b.decode('latin-1')[:3000])
    print()

# find FontDescriptor -> FontFile2
for num, body in allobj.items():
    if b'/FontFile2' in body or b'/FontFile3' in body:
        print("fontfile obj", num, body.decode('latin-1')[:500])
        m = re.search(rb'/(FontFile2|FontFile3)\s+(\d+)\s+0\s+R', body)
        print("  ->", m.group(2) if m else None)

# page / resources
for num, body in allobj.items():
    if b'/Font' in body and b'R' in body and len(body) < 800:
        print("resource-ish", num, body.decode('latin-1')[:400])
