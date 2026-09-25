import re, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.path.insert(0, 'tools')
from pdflib import load_pdf
PDF = r"C:\Users\30415\.dsh\attachments\v1\files\e4\e457547f08ca37250b27ccfd4c8e29e3ce44cf309b24324623932fd2626002be\tang_mega_60k_30354_schematics..pdf"
allobj, gs, infl = load_pdf(PDF)

# valid text codes are the printable ASCII range
VALID = set(range(32, 127))
TITLE = "GW5AT-LV60PG484AC1/10"

for num in (574, 56, 152):
    body = allobj.get(num)
    if body is None: continue
    m = re.search(rb'/CharProcs\s*<<([^>]*)>>', body, re.S)
    procs = [g.decode('latin-1') for g, _ in re.findall(rb'/(g\d+)\s+(\d+)\s+0\s+R', m.group(1))]
    enc = re.search(rb'/Encoding\s+(\d+)\s+0\s+R', body)
    e = allobj[int(enc.group(1))]
    dd = re.search(rb'/Differences\s*\[([^\]]*)\]', e, re.S)
    n2c = {}; code = 0
    for mm in re.finditer(rb'(\d+)?((?:/[\w.]+)+)', dd.group(1)):
        if mm.group(1) is not None: code = int(mm.group(1))
        for nm in re.findall(rb'/([\w.]+)', mm.group(2)):
            n2c[nm.decode('latin-1')] = code; code += 1
    codes = sorted(n2c)
    print("=== font", num, "n_procs", len(procs), "codes", codes)
    # try every (offset, reverse) hypothesis; require max mapped char <= 126
    best = None
    for rev in (False, True):
        for off in range(-60, 61):
            vals = []
            for c in codes:
                nm = [k for k, v in n2c.items() if v == c][0]
                i = procs.index(nm)
                cv = (len(procs) - i + off) if rev else (i + 1 + off)
                vals.append(cv)
            if all(v in VALID for v in vals):
                print("   rev=%s off=%3d -> %s" % (rev, off, ''.join(chr(v) for v in vals)))
    print()
