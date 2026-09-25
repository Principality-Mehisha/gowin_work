import re, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.path.insert(0, 'tools')
from pdflib import load_pdf
PDF = r"C:\Users\30415\.dsh\attachments\v1\files\e4\e457547f08ca37250b27ccfd4c8e29e3ce44cf309b24324623932fd2626002be\tang_mega_60k_30354_schematics..pdf"
allobj, get_stream, inflate = load_pdf(PDF)

names = set()
for num, body in allobj.items():
    if b'/Type/Font' not in body: continue
    enc = re.search(rb'/Encoding\s+(\d+)\s+0\s+R', body)
    enc_body = allobj.get(int(enc.group(1)), b'') if enc else b''
    if not enc_body:
        m2 = re.search(rb'/Encoding\s*<<([^>]*)>>', body, re.S)
        if m2: enc_body = b'<<' + m2.group(1) + b'>>'
    dd = re.search(rb'/Differences\s*\[([^\]]*)\]', enc_body, re.S)
    if not dd: continue
    names.update(t.decode('latin-1').lstrip('/')
                 for t in dd.group(1).split() if not re.fullmatch(rb'\d+', t))

def key(n):
    m = re.match(r'g(\d+)$', n)
    return (0, int(m.group(1))) if m else (1, n)

known = set("""g3 g18 g20 g21 g23 g24 g25 g26 g27 g28 g36 g37 g38 g39 g40 g41 g42 g43 g44 g45
g46 g47 g48 g49 g51 g53 g54 g55 g56 g68 g70 g72 g76 g79 g81 g82 g85 g86 g87 g88 g92""".split())
unk = sorted(names - known, key=key)
print("total names", len(names), " unknown", len(unk))
print('\n'.join(unk))
open('tools/unknown_glyphs.txt', 'w').write('\n'.join(unk))
