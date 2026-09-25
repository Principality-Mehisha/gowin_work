import re, zlib, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
src = open(r"tools\type3match.py").read()
src = src.split("if __name__")[0]
exec(src)

for num in (10, 28, 118, 56, 41, 125):
    body = allobj[num]
    print("=== type3 font", num, "len", len(body))
    print(body[:600].decode('latin-1'))
    m = re.search(rb'/CharProcs\s*<<(.*?)>>', body, re.S)
    if m:
        names = re.findall(rb'/(g\d+)', m.group(1))
        print("glyph names (%d):" % len(names), [n.decode() for n in names])
    print()
