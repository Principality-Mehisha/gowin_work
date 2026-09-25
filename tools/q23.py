import re, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.path.insert(0, "tools")
from pdflib import load_pdf
PDF = r"C:\Users\30415\.dsh\attachments\v1\files\e4\e457547f08ca37250b27ccfd4c8e29e3ce44cf309b24324623932fd2626002be\tang_mega_60k_30354_schematics..pdf"
allobj, gs, infl = load_pdf(PDF)
G2C = {"g3":"1","g18":"|","g20":"3","g21":"2","g23":"5","g24":"4","g25":"C","g26":"G","g27":"N","g28":"7","g36":"K","g37":"L","g38":"D","g39":"T","g40":"Z","g41":"Y","g42":"X","g43":"W","g44":"6","g45":"U","g46":"R","g47":"M","g48":"J","g49":"H","g51":"F","g53":"9","g54":"P","g55":"E","g56":"0","g68":"+","g70":"V","g72":"S","g76":"<","g79":">","g81":"B","g82":"A","g85":"I","g86":"8","g87":"O","g88":"/","g92":"Q"}
body = allobj[10]
enc = re.search(rb"/Encoding\s+(\d+)\s+0\s+R", body)
e = allobj[int(enc.group(1))]
print("enc:", e)
dd = re.search(rb"/Differences\s*\[([^\]]*)\]", e, re.S)
toks = dd.group(1).split()
print("toks:", toks)
mp={}; code=0
for t in toks:
    if re.fullmatch(rb"\d+", t): code=int(t)
    else:
        nm = t.decode("latin-1").lstrip("/")
        mp[code]=G2C.get(nm, "??"+nm); code+=1
print("mp:", mp)
