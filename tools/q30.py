import re, sys, io
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.path.insert(0, 'tools')
from pdflib import load_pdf
PDF = r"C:\Users\30415\.dsh\attachments\v1\files\e4\e457547f08ca37250b27ccfd4c8e29e3ce44cf309b24324623932fd2626002be\tang_mega_60k_30354_schematics..pdf"
allobj, gs, infl = load_pdf(PDF)

src = io.open('tools/glyphrender.py', encoding='utf-8').read().split("labels = sys.argv")[0]
E = {}
exec(compile(src, 'gr', 'exec'), E)
charstrings = E['charstrings']; glyph_names = E['glyph_names']; render = E['render']

# Font 10: code -> charproc object
body = allobj[10]
procs = re.findall(rb'/(g\d+)\s+(\d+)\s+0\s+R',
                   re.search(rb'/CharProcs\s*<<([^>]*)>>', body, re.S).group(1))
print("font 10 procs:", [(g.decode(), int(o)) for g, o in procs])
print("Differences order: 1/g24/g23/g22/g21/g20/g39/g38/g37/g36")
print()
print("Render the CFF glyphs whose names appear in font 10:")
for g, o in procs:
    nm = g.decode()
    if nm in glyph_names:
        gi = glyph_names.index(nm)
        print("--- name %s (cff idx %d) ---" % (nm, gi))
        for ln in render(gi, 18, 22):
            print(ln)
