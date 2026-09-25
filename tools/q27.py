import re, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.path.insert(0, 'tools')
from pdflib import load_pdf
PDF = r"C:\Users\30415\.dsh\attachments\v1\files\e4\e457547f08ca37250b27ccfd4c8e29e3ce44cf309b24324623932fd2626002be\tang_mega_60k_30354_schematics..pdf"
allobj, gs, infl = load_pdf(PDF)

GLYPH_CHAR = {1:'4',2:'2',3:'3',4:'T',5:'D',6:'C',7:'E',8:'8',9:'6',10:'A',11:'/',
 12:'S',13:'B',14:'R',15:'L',16:'V',17:'O',18:'I',19:'G',20:'7',21:'H',22:'-',
 23:'K',24:'G',25:'M',26:'Q',27:'N',28:'F',29:'P',30:'Y',31:'U',32:'W',33:'9',
 34:'<',35:'>',36:'+',37:'X',38:'|',39:'5'}

for num in (10, 574, 41):
    body = allobj[num]
    m = re.search(rb'/CharProcs\s*<<([^>]*)>>', body, re.S)
    charprocs = [g.decode('latin-1') for g, _ in
                 re.findall(rb'/(g\d+)\s+(\d+)\s+0\s+R', m.group(1))]
    enc = re.search(rb'/Encoding\s+(\d+)\s+0\s+R', body)
    e = allobj[int(enc.group(1))]
    dd = re.search(rb'/Differences\s*\[([^\]]*)\]', e, re.S)
    mp = {}; code = 0
    for mm in re.finditer(rb'(\d+)?((?:/[\w.]+)+)', dd.group(1)):
        if mm.group(1) is not None: code = int(mm.group(1))
        for nm in re.findall(rb'/([\w.]+)', mm.group(2)):
            name = nm.decode('latin-1')
            idx = charprocs.index(name) + 1 if name in charprocs else None
            mp[code] = (name, idx, GLYPH_CHAR.get(idx))
            code += 1
    print("font", num, "charprocs:", charprocs)
    print("  map:", mp)
    print()
