import re, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.path.insert(0, 'tools')
from pdflib import load_pdf
PDF = r"C:\Users\30415\.dsh\attachments\v1\files\e4\e457547f08ca37250b27ccfd4c8e29e3ce44cf309b24324623932fd2626002be\tang_mega_60k_30354_schematics..pdf"
allobj, get_stream, inflate = load_pdf(PDF)

font_map = {}
for num, body in allobj.items():
    if b'/Type/Font' not in body: continue
    enc = re.search(rb'/Encoding\s+(\d+)\s+0\s+R', body)
    enc_body = b''
    if enc:
        enc_body = allobj.get(int(enc.group(1)), b'')
    else:
        m2 = re.search(rb'/Encoding\s*<<(.*?)>>', body, re.S)
        if m2: enc_body = b'<<' + m2.group(1) + b'>>'
    if not enc_body: continue
    dd = re.search(rb'/Differences\s*\[(.*?)\]', enc_body, re.S)
    if not dd: continue
    mp = {}; code = 0
    for t in dd.group(1).split():
        if re.fullmatch(rb'\d+', t): code = int(t)
        else:
            mp[code] = t.decode('latin-1').lstrip('/')
            code += 1
    if mp: font_map[num] = mp

print("fonts:", len(font_map))
for k in list(font_map)[:6]:
    print(k, font_map[k])
print("13705 present?", 13705 in allobj if False else None)
print("obj 13705:", allobj.get(13705))
print("obj 13656:", allobj.get(13656))
