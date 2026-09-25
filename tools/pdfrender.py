"""Visualize the original PDF pages as ASCII so glyphs can be read directly."""
import re, zlib, sys, struct
sys.path.insert(0, 'tools')
from pdflib import load_pdf

PDF = sys.argv[1]
allobj, get_stream, inflate = load_pdf(PDF)

W = int(sys.argv[2]) if len(sys.argv) > 2 else 300
H = int(sys.argv[3]) if len(sys.argv) > 3 else 120
x0 = float(sys.argv[4]) if len(sys.argv) > 4 else 0
y0 = float(sys.argv[5]) if len(sys.argv) > 5 else 0
x1 = float(sys.argv[6]) if len(sys.argv) > 6 else 5200
y1 = float(sys.argv[7]) if len(sys.argv) > 7 else 8250
page = int(sys.argv[8]) if len(sys.argv) > 8 else 1

NUM = r'[-+]?[\d.]+'
TOKEN = re.compile(
    r'(?P<n>(?:' + NUM + r'))'
    r'|(?P<op>[A-Za-z\'"*]+)')

pages = []
for num, body in allobj.items():
    if b'/Type/Page' in body and b'/Contents' in body:
        c = re.search(rb'/Contents\s+(\d+)\s+0\s+R', body)
        if c: pages.append((num, int(c.group(1))))
pages.sort()

def render_page(pno, W, H):
    cn = pages[pno-1][1]
    body = allobj[cn]
    s, hdr = get_stream(body)
    d = inflate(s, hdr)
    txt = d.decode('latin-1')
    sx = W/(x1-x0); sy = H/(y1-y0)
    grid = [[0]*W for _ in range(H)]
    stack = []
    ctm = [1,0,0,1,0,0]
    ctm_stack = []
    cur = [(0,0)]
    curpt = (0,0)
    startpt = (0,0)
    def put(px, py, val=1):
        gx = int((px-x0)*sx); gy = int((y1-py)*sy)
        if 0 <= gx < W and 0 <= gy < H: grid[gy][gx] = val
    def line(p0, p1):
        n = max(2, int(max(abs(p1[0]-p0[0])*sx, abs(p1[1]-p0[1])*sy)))
        for i in range(n+1):
            t = i/n
            put(p0[0]+t*(p1[0]-p0[0]), p0[1]+t*(p1[1]-p0[1]))
    def bez(p0, p1, p2, p3):
        prev = p0
        for i in range(1, 13):
            t = i/12.0; mt = 1-t
            p = (mt**3*p0[0]+3*mt*mt*t*p1[0]+3*mt*t*t*p2[0]+t**3*p3[0],
                 mt**3*p0[1]+3*mt*mt*t*p1[1]+3*mt*t*t*p2[1]+t**3*p3[1])
            line(prev, p); prev = p

    toks = []
    for m in TOKEN.finditer(txt):
        if m.group('n') is not None:
            try: toks.append(('n', float(m.group('n'))))
            except ValueError: pass
        else:
            toks.append(('op', m.group('op')))

    i = 0
    while i < len(toks):
        kind, val = toks[i]
        if kind == 'n':
            stack.append(val); i += 1; continue
        op = val
        def nums(k):
            return stack[-k:] if k else []
        if op == 'cm':
            a,b,c,d,e,f = stack[-6:]
            ctm = [a,b,c,d,e,f]
            stack = []
        elif op == 'q':
            ctm_stack.append(list(ctm)); stack = []
        elif op == 'Q':
            if ctm_stack: ctm = ctm_stack.pop()
            stack = []
        elif op == 'm':
            if len(stack) >= 2:
                curpt = (stack[-2], stack[-1]); startpt = curpt; cur = [curpt]
            stack = []
        elif op == 'l':
            if len(stack) >= 2:
                p = (stack[-2], stack[-1])
                line(curpt, p); curpt = p
            stack = []
        elif op == 'c':
            if len(stack) >= 6:
                p1 = (stack[-6], stack[-5]); p2 = (stack[-4], stack[-3]); p3 = (stack[-2], stack[-1])
                bez(curpt, p1, p2, p3); curpt = p3
            stack = []
        elif op == 'v':
            if len(stack) >= 4:
                p1 = curpt; p2 = (stack[-4], stack[-3]); p3 = (stack[-2], stack[-1])
                bez(curpt, p1, p2, p3); curpt = p3
            stack = []
        elif op == 'y':
            if len(stack) >= 4:
                p1 = (stack[-4], stack[-3]); p2 = p1; p3 = (stack[-2], stack[-1])
                bez(curpt, p1, p2, p3); curpt = p3
            stack = []
        elif op == 're':
            if len(stack) >= 4:
                rx, ry, rw, rh = stack[-4:]
                pts = [(rx,ry),(rx+rw,ry),(rx+rw,ry+rh),(rx,ry+rh),(rx,ry)]
                for k in range(4): line(pts[k], pts[k+1])
            stack = []
        elif op == 'h':
            line(curpt, startpt); curpt = startpt; stack = []
        elif op == 'S' or op == 's' or op == 'f' or op == 'F' or op == 'B' or op == 'b' or op == 'n' or op == 'W':
            stack = []
        else:
            stack = []
        i += 1
    return grid

grid = render_page(page, W, H)
for row in grid:
    print(''.join('#' if v else ' ' for v in row))
