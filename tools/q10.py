import re, sys, zlib
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.path.insert(0, 'tools')
from pdflib import load_pdf
PDF = r"C:\Users\30415\.dsh\attachments\v1\files\e4\e457547f08ca37250b27ccfd4c8e29e3ce44cf309b24324623932fd2626002be\tang_mega_60k_30354_schematics..pdf"
allobj, get_stream, inflate = load_pdf(PDF)

# Find all distinct CharProc content signatures across the doc
sigs = {}
for num, body in allobj.items():
    if b'/Subtype/Type3' not in body: continue
    for m in re.finditer(rb'/(g\d+)\s+(\d+)\s+0\s+R', body):
        gname = m.group(1).decode(); cnum = int(m.group(2))
        cb = allobj.get(cnum)
        if cb is None:
            sigs.setdefault(('MISSING', cnum), set()).add((num, gname))
            continue
        s, hdr = get_stream(cb)
        d = inflate(s, hdr)
        if d is None:
            sig = ('NOSTREAM', cnum)
        else:
            # signature: the numeric part before BI
            pre = d.split(b'BI')[0]
            sig = re.sub(rb'\s+', b' ', pre).strip()
        sigs.setdefault(sig, set()).add((num, gname))

print("distinct signatures:", len(sigs))
for i, (sig, users) in enumerate(sorted(sigs.items(), key=lambda kv: -len(kv[1]))[:20]):
    print(i, len(users), repr(sig)[:180])
    print("   users:", sorted(users)[:12])
