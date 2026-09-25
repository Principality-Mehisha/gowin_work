import re, sys, io, json
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.path.insert(0, 'tools')
from pdflib import load_pdf
PDF = r"C:\Users\30415\.dsh\attachments\v1\files\e4\e457547f08ca37250b27ccfd4c8e29e3ce44cf309b24324623932fd2626002be\tang_mega_60k_30354_schematics..pdf"
allobj, gs, infl = load_pdf(PDF)

src = io.open('tools/glyphrender.py', encoding='utf-8').read().split("labels = sys.argv")[0]
E = {}
exec(compile(src, 'gr', 'exec'), E)
glyph_names = E['glyph_names']

# Font 574 is the full 39-glyph subset. Its /Differences gives the code of each
# glyph name; the plaintext of the first title line ("GW5AT-LV60PG484AC1/10",
# which is this board's part number) fixes the character for codes 1..39.
TITLE = "GW5AT-LV60PG484AC1/10"
body = allobj[574]
procs = [g.decode('latin-1') for g, _ in re.findall(
    rb'/(g\d+)\s+(\d+)\s+0\s+R',
    re.search(rb'/CharProcs\s*<<([^>]*)>>', body, re.S).group(1))]
enc = re.search(rb'/Encoding\s+(\d+)\s+0\s+R', body)
e = allobj[int(enc.group(1))]
dd = re.search(rb'/Differences\s*\[([^\]]*)\]', e, re.S)
name2code = {}; code = 0
for mm in re.finditer(rb'(\d+)?((?:/[\w.]+)+)', dd.group(1)):
    if mm.group(1) is not None: code = int(mm.group(1))
    for nm in re.findall(rb'/([\w.]+)', mm.group(2)):
        name2code[nm.decode('latin-1')] = code; code += 1

print("font 574 name->code:", name2code)

# The 39 codes of the title, in order.
print("title      :", TITLE, len(TITLE))
codes = sorted(name2code.values())
print("codes      :", codes)

# Careful: the visible order of the title text does NOT have to follow code order.
# Instead use font 10, whose nine codes are 1..9 and which was rendered: the
# glyph at /CharProcs index i has code (len - i).  We already know from rendering
# that index 8 is '4', 7 is '2', ... so code 1='4' ... code 9='6' for THAT font.
# For font 574 the same rule gives code = len(procs) - index.
n = len(procs)
by_code = {}
for i, nm in enumerate(procs):
    by_code[n - i] = nm
print("font574 code->name (via len-index):", dict(sorted(by_code.items())))
