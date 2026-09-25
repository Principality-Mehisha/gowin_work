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
G2C = {'g3':'1','g18':'|','g19':'}','g20':'3','g21':'2','g24':'4','g25':'C','g26':'G',
 'g27':'N','g28':'7','g36':'K','g37':'L','g38':'D','g39':'T','g40':'Z','g41':'Y',
 'g42':'X','g43':'W','g44':'6','g45':'U','g46':'R','g47':'M','g48':'J','g49':'H',
 'g51':'F','g53':'9','g54':'P','g55':'E','g56':'0','g68':'+','g70':'V','g72':'S',
 'g76':'<','g79':'>','g81':'B','g82':'A','g85':'I','g86':'8','g87':'O','g88':'/','g92':'Q'}

font_map = {}
for num, body in allobj.items():
    if b'/Type/Font' not in body: continue
    mproc = re.search(rb'/CharProcs\s*<<([^>]*)>>', body, re.S)
    charprocs = []
    if mproc:
        charprocs = [g.decode('latin-1') for g, _ in
                     re.findall(rb'/(g\d+)\s+(\d+)\s+0\s+R', mproc.group(1))]
    enc = re.search(rb'/Encoding\s+(\d+)\s+0\s+R', body)
    enc_body = allobj.get(int(enc.group(1)), b'') if enc else b''
    if not enc_body:
        m2 = re.search(rb'/Encoding\s*<<(.*?)>>', body, re.S)
        if m2: enc_body = b'<<' + m2.group(1) + b'>>'
    if not enc_body: continue
    dd = re.search(rb'/Differences\s*\[([^\]]*)\]', enc_body, re.S)
    if not dd: continue
    def bind(name, cp=charprocs):
        if cp and name in cp:
            return GLYPH_CHAR.get(cp.index(name) + 1)
        return G2C.get(name)
    mp = {}; code = 0
    for mm in re.finditer(rb'(\d+)?((?:/[\w.]+)+)', dd.group(1)):
        if mm.group(1) is not None:
            code = int(mm.group(1))
        for nm in re.findall(rb'/([\w.]+)', mm.group(2)):
            mp[code] = bind(nm.decode('latin-1').lstrip('/'))
            code += 1
    if mp: font_map[num] = mp

print("fonts:", len(font_map))
print("font 10:", font_map.get(10))
print("font 127 is the resources dict; page1 fonts:", )
p1 = allobj[127]
print(p1)
