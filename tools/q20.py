import re, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.path.insert(0, "tools")
from pdflib import load_pdf
PDF = r"C:\Users\30415\.dsh\attachments\v1\files\e4\e457547f08ca37250b27ccfd4c8e29e3ce44cf309b24324623932fd2626002be\tang_mega_60k_30354_schematics..pdf"
allobj, gs, infl = load_pdf(PDF)
e = allobj[13705]
print(repr(e))
dd = re.search(rb"/Differences\s*\[([^\]]*)\]", e, re.S)
print("dd:", dd)
mp={}; code=0
for t in dd.group(1).split():
    if re.fullmatch(rb"\d+", t): code=int(t)
    else:
        mp[code]=t.decode("latin-1").lstrip("/"); code+=1
print(mp)
