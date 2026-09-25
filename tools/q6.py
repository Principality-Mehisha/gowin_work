import re, zlib, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
exec(open(r"tools\type3match.py").read().split("if __name__")[0])

for num in (10,):
    body = allobj[num]
    print("=== type3 font", num)
    print(repr(body[:800]))
    m = re.search(rb'/CharProcs\s*<<(.*?)>>', body, re.S)
    print("charprocs:", m.group(1).decode('latin-1')[:400] if m else None)
    print()
