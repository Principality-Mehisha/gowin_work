import re, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.path.insert(0, 'tools')
from pdflib import load_pdf
PDF = r"C:\Users\30415\.dsh\attachments\v1\files\e4\e457547f08ca37250b27ccfd4c8e29e3ce44cf309b24324623932fd2626002be\tang_mega_60k_30354_schematics..pdf"
allobj, gs, infl = load_pdf(PDF)
VALID = set(range(32, 127))

def parse(num):
    body = allobj[num]
    m = re.search(rb'/CharProcs\s*<<([^>]*)>>', body, re.S)
    procs = [g.decode('latin-1') for g, _ in re.findall(rb'/(g\d+)\s+(\d+)\s+0\s+R', m.group(1))]
    enc = re.search(rb'/Encoding\s+(\d+)\s+0\s+R', body)
    eb = allobj.get(int(enc.group(1)), b'') if enc else b''
    if not eb:
        m2 = re.search(rb'/Encoding\s*<<([^>]*)>>', body, re.S)
        eb = b'<<' + m2.group(1) + b'>>' if m2 else b''
    dd = re.search(rb'/Differences\s*\[([^\]]*)\]', eb, re.S)
    if not dd: return None
    pairs = []; code = 0
    for mm in re.finditer(rb'(\d+)?((?:/[\w.]+)+)', dd.group(1)):
        if mm.group(1) is not None: code = int(mm.group(1))
        for nm in re.findall(rb'/([\w.]+)', mm.group(2)):
            pairs.append((code, nm.decode('latin-1'))); code += 1
    return procs, pairs

for num in (574, 56, 152, 125, 41, 10):
    r = parse(num)
    if not r: continue
    procs, pairs = r
    print("=== font %d  n_procs=%d  codes=%s" % (num, len(procs), [c for c, _ in pairs]))
    found = []
    for rev in (False, True):
        for off in range(-70, 71):
            vals = []
            ok = True
            for c, nm in pairs:
                i = procs.index(nm) if nm in procs else None
                if i is None: ok = False; break
                cv = (len(procs) - i + off) if rev else (i + 1 + off)
                if cv not in VALID: ok = False; break
                vals.append(cv)
            if ok:
                found.append("rev=%d off=%3d -> %s" % (rev, off, ''.join(chr(v) for v in vals)))
    for f in found: print("   ", f)
    print()
