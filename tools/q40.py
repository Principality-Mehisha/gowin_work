import re, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.path.insert(0, 'tools')
from pdflib import load_pdf
PDF = r"C:\Users\30415\.dsh\attachments\v1\files\e4\e457547f08ca37250b27ccfd4c8e29e3ce44cf309b24324623932fd2626002be\tang_mega_60k_30354_schematics..pdf"
allobj, gs, infl = load_pdf(PDF)

TITLE = "GW5AT-LV60PG484AC1/10"

num = 574
body = allobj[num]
m = re.search(rb'/CharProcs\s*<<([^>]*)>>', body, re.S)
procs = [g.decode('latin-1') for g, _ in re.findall(rb'/(g\d+)\s+(\d+)\s+0\s+R', m.group(1))]
enc = re.search(rb'/Encoding\s+(\d+)\s+0\s+R', body)
e = allobj[int(enc.group(1))]
dd = re.search(rb'/Differences\s*\[([^\]]*)\]', e, re.S)
name2code = {}; code = 0
for mm in re.finditer(rb'(\d+)?((?:/[\w.]+)+)', dd.group(1)):
    if mm.group(1) is not None: code = int(mm.group(1))
    for nm in re.findall(rb'/([\w.]+)', mm.group(2)):
        name2code[nm.decode('latin-1')] = code; code += 1

print("n =", len(procs))
print("procs (index order):", list(enumerate(procs)))
print()
# Hypothesis: code C -> procs[len-C]  (reverse listing)
print("reverse rule  code -> name:")
rev = {}
for i, nm in enumerate(procs):
    rev[len(procs) - i] = nm
codes = sorted(name2code.values())
line = []
for c in codes:
    line.append((c, name2code_rev := [k for k, v in name2code.items() if v == c]))
print("Differences code -> name:", {c: [k for k, v in name2code.items() if v == c][0] for c in codes})
print()
print("Now assume the title text is drawn with codes in ascending order:")
print("  code order  :", codes)
print("  title chars :", ' '.join(TITLE[:len(codes)]))
print()
# derive object-index -> char from the reverse rule + title
objchar = {}
for c, ch in zip(codes, TITLE):
    nm = [k for k, v in name2code.items() if v == c][0]
    i = procs.index(nm)
    objchar[(num, nm)] = ch
    print("  code %2d -> name %-5s procs_index %2d  char '%s'" % (c, nm, i, ch))
