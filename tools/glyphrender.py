"""Minimal CFF Type2 charstring -> outline -> ASCII/PNG renderer (no deps)."""
import struct, zlib, sys

cff = open(r"tools\font.cff", "rb").read()
hdrsize = cff[2]
pos = hdrsize

def read_index(p):
    count = struct.unpack(">H", cff[p:p+2])[0]
    if count == 0:
        return [], p+2
    osz = cff[p+2]
    offs = []
    q = p+3
    for i in range(count+1):
        offs.append(int.from_bytes(cff[q:q+osz], "big")); q += osz
    ds = q - 1
    return [cff[ds+offs[i]:ds+offs[i+1]] for i in range(count)], ds+offs[-1]

names, pos = read_index(pos)
topdicts, pos = read_index(pos)
STD = ["","","space","exclam","quotedbl","numbersign","dollar","percent","ampersand","quoteright","parenleft","parenright","asterisk","plus","comma","hyphen","period","slash","zero","one","two","three","four","five","six","seven","eight","nine","colon","semicolon","less","equal","greater","question","at","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","bracketleft","backslash","bracketright","asciicircum","underscore","quoteleft","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","braceleft","bar","braceright","asciitilde"]
strings, pos = read_index(pos)
def sid_name(sid):
    if sid < len(STD): return STD[sid]
    i = sid-390
    return strings[i].decode('latin-1') if 0 <= i < len(strings) else "?%d"%sid

def parse_dict(b):
    out = {}; ops = []; i = 0
    while i < len(b):
        c = b[i]
        if c <= 21:
            if c == 12: op = (12, b[i+1]); i += 2
            else: op = c; i += 1
            out[op] = ops; ops = []
        elif c == 28: ops.append(struct.unpack(">h", b[i+1:i+3])[0]); i += 3
        elif c == 29: ops.append(struct.unpack(">i", b[i+1:i+5])[0]); i += 5
        elif c == 30:
            i += 1; s = ''; done = False
            digits = "0123456789"
            while not done:
                byte = b[i]; i += 1
                for n in (byte>>4, byte&0xF):
                    if n == 0xf: done = True; break
                    if n <= 9: s += digits[n]
                    elif n == 0xa: s += '.'
                    elif n == 0xb: s += 'E'
                    elif n == 0xc: s += 'E-'
                    elif n == 0xe: s += '-'
            try:
                ops.append(float(s))
            except ValueError:
                ops.append(0.0)
        elif 32 <= c <= 246: ops.append(c-139); i += 1
        elif 247 <= c <= 250: ops.append((c-247)*256+b[i+1]+108); i += 2
        elif 251 <= c <= 254: ops.append(-(c-251)*256-b[i+1]-108); i += 2
        else: i += 1
    return out

td = parse_dict(topdicts[0])
charstrings, _ = read_index(td[17][0])
charset_off = td.get(15, [0])[0]
p = charset_off+1
glyph_names = ['.notdef']
fmt = cff[charset_off]
if fmt == 0:
    for g in range(1, len(charstrings)):
        sid = struct.unpack(">H", cff[p:p+2])[0]; p += 2
        glyph_names.append(sid_name(sid))

# private dict
pd_off, pd_len = td[18]
pd = parse_dict(cff[pd_off:pd_off+pd_len])
defaultWidthX = pd[20][0] if pd.get(20) else 0
nominalWidthX = pd[21][0] if pd.get(21) else 0
local_subrs = []
if pd.get(19):
    local_subrs, _ = read_index(pd_off + pd[19][0])
def bez(p0, p1, p2, p3, n=8):
    out = []
    for i in range(1, n+1):
        t = i/n; mt = 1-t
        x = mt**3*p0[0] + 3*mt*mt*t*p1[0] + 3*mt*t*t*p2[0] + t**3*p3[0]
        y = mt**3*p0[1] + 3*mt*mt*t*p1[1] + 3*mt*t*t*p2[1] + t**3*p3[1]
        out.append((x, y))
    return out

def run(cs, width_only=False, depth=0):
    """Return (contours, width)"""
    stack = []; contours = []; cur = []
    x = y = 0; nStems = 0; haveWidth = False; width = defaultWidthX
    i = 0
    def moveTo(px, py):
        nonlocal cur
        if len(cur) > 1: contours.append(cur)
        cur = [(px, py)]
    def lineTo(px, py):
        cur.append((px, py))
    while i < len(cs):
        c = cs[i]
        if c >= 32 or c == 28:
            if c == 28:
                stack.append(struct.unpack(">h", cs[i+1:i+3])[0]); i += 3
            elif 32 <= c <= 246:
                stack.append(c-139); i += 1
            elif 247 <= c <= 250:
                stack.append((c-247)*256+cs[i+1]+108); i += 2
            elif 251 <= c <= 254:
                stack.append(-(c-251)*256-cs[i+1]-108); i += 2
            elif c == 255:
                stack.append(struct.unpack(">i", cs[i+1:i+5])[0]/65536.0); i += 5
            continue
        # operators
        if c == 1 or c == 3 or c == 18 or c == 23:  # hstem vstem hstemhm vstemhm
            nStems += len(stack)//2
            stack = []; i += 1
        elif c == 19 or c == 20:  # hintmask cntrmask
            nStems += len(stack)//2
            stack = []
            i += 1 + (nStems+7)//8
        elif c == 21:  # rmoveto
            if len(stack) > 2 and not haveWidth:
                width = stack[0]+nominalWidthX; haveWidth = True
                stack = stack[1:]
            haveWidth = True
            dx, dy = stack[-2], stack[-1]
            x += dx; y += dy
            moveTo(x, y); stack = []; i += 1
        elif c == 22:  # hmoveto
            if len(stack) > 1 and not haveWidth:
                width = stack[0]+nominalWidthX; haveWidth = True
                stack = stack[1:]
            haveWidth = True
            x += stack[-1]
            moveTo(x, y); stack = []; i += 1
        elif c == 4:  # vmoveto
            if len(stack) > 1 and not haveWidth:
                width = stack[0]+nominalWidthX; haveWidth = True
                stack = stack[1:]
            haveWidth = True
            y += stack[-1]
            moveTo(x, y); stack = []; i += 1
        elif c == 5:  # rlineto
            j = 0
            while j < len(stack):
                x += stack[j]; y += stack[j+1]
                lineTo(x, y); j += 2
            stack = []; i += 1
        elif c == 6 or c == 7:  # hlineto / vlineto
            horiz = (c == 6)
            for v in stack:
                if horiz: x += v
                else: y += v
                lineTo(x, y)
                horiz = not horiz
            stack = []; i += 1
        elif c == 8:  # rrcurveto
            j = 0
            while j < len(stack):
                c1x = x+stack[j]; c1y = y+stack[j+1]
                c2x = c1x+stack[j+2]; c2y = c1y+stack[j+3]
                x = c2x+stack[j+4]; y = c2y+stack[j+5]
                for pt in bez((x,y),(c1x,c1y),(c2x,c2y),(x,y)): pass
                for pt in bez(cur[-1], (c1x,c1y), (c2x,c2y), (x,y)):
                    cur.append(pt)
                j += 6
            stack = []; i += 1
        elif c == 24:  # rcurveline
            j = 0
            while j + 6 <= len(stack)-2:
                c1x = x+stack[j]; c1y = y+stack[j+1]
                c2x = c1x+stack[j+2]; c2y = c1y+stack[j+3]
                nx = c2x+stack[j+4]; ny = c2y+stack[j+5]
                for pt in bez(cur[-1], (c1x,c1y), (c2x,c2y), (nx,ny)):
                    cur.append(pt)
                x, y = nx, ny; j += 6
            x += stack[j]; y += stack[j+1]; lineTo(x, y)
            stack = []; i += 1
        elif c == 25:  # rlinecurve
            j = 0
            while j + 2 <= len(stack)-6:
                x += stack[j]; y += stack[j+1]; lineTo(x, y); j += 2
            c1x = x+stack[j]; c1y = y+stack[j+1]
            c2x = c1x+stack[j+2]; c2y = c1y+stack[j+3]
            nx = c2x+stack[j+4]; ny = c2y+stack[j+5]
            for pt in bez(cur[-1], (c1x,c1y), (c2x,c2y), (nx,ny)):
                cur.append(pt)
            x, y = nx, ny
            stack = []; i += 1
        elif c == 26 or c == 27:  # vvcurveto / hhcurveto
            j = 0
            if len(stack) % 4 == 1:
                if c == 26: x += stack[0]
                else: y += stack[0]
                j = 1
            while j < len(stack):
                if c == 26:
                    c1x = x; c1y = y+stack[j]
                    c2x = c1x+stack[j+1]; c2y = c1y+stack[j+2]
                    nx = c2x; ny = c2y+stack[j+3]
                else:
                    c1x = x+stack[j]; c1y = y
                    c2x = c1x+stack[j+1]; c2y = c1y+stack[j+2]
                    nx = c2x+stack[j+3]; ny = c2y
                for pt in bez(cur[-1], (c1x,c1y), (c2x,c2y), (nx,ny)):
                    cur.append(pt)
                x, y = nx, ny; j += 4
            stack = []; i += 1
        elif c == 30 or c == 31:  # vhcurveto / hvcurveto
            horiz = (c == 31)
            j = 0
            while j + 4 <= len(stack):
                last = (j + 8 > len(stack)) and (len(stack) - j == 5)
                if horiz:
                    c1x = x+stack[j]; c1y = y
                    c2x = c1x+stack[j+1]; c2y = c1y+stack[j+2]
                    if last:
                        nx = c2x+stack[j+4]; ny = c2y
                    else:
                        nx = c2x; ny = c2y+stack[j+3]
                else:
                    c1x = x; c1y = y+stack[j]
                    c2x = c1x+stack[j+1]; c2y = c1y+stack[j+2]
                    if last:
                        nx = c2x; ny = c2y+stack[j+4]
                    else:
                        nx = c2x+stack[j+3]; ny = c2y
                for pt in bez(cur[-1], (c1x,c1y), (c2x,c2y), (nx,ny)):
                    cur.append(pt)
                x, y = nx, ny
                horiz = not horiz
                j += 4 if not last else 5
            stack = []; i += 1
        elif c == 10:  # callsubr
            idx = int(stack.pop()) + (0 if depth == 0 else 0)
            sub = local_subrs[idx]
            subconts, _ = run(sub, depth=depth+1)
            for ct in subconts:
                for pt in ct:
                    cur.append((x+pt[0], y+pt[1]))
                x += ct[-1][0]; y += ct[-1][1]
            i += 1
        elif c == 11:  # return
            break
        elif c == 14:  # endchar
            if len(cur) > 1: contours.append(cur)
            cur = []
            break
        elif c == 12:
            op2 = cs[i+1]; i += 2
        else:
            i += 1
    if len(cur) > 1: contours.append(cur)
    return contours, width

# Render
def render(glyph_idx, W=40, H=44):
    conts, w = run(charstrings[glyph_idx])
    xs = [p[0] for c in conts for p in c]
    ys = [p[1] for c in conts for p in c]
    if not xs: return ["(empty)"]*H
    minx, maxx, miny, maxy = min(xs), max(xs), min(ys), max(ys)
    sc = min((W-2)/max(1e-6, maxx-minx), (H-2)/max(1e-6, maxy-miny))
    def tr(p):
        return (1 + (p[0]-minx)*sc, H-2-(p[1]-miny)*sc)
    P = [[tr(p) for p in c] for c in conts]
    # even-odd scanline
    lines = []
    for row in range(H):
        yc = row + 0.5
        xs_ = []
        for c in P:
            n = len(c)
            for i in range(n):
                x1, y1 = c[i]; x2, y2 = c[(i+1) % n]
                if (y1 <= yc < y2) or (y2 <= yc < y1):
                    t = (yc-y1)/(y2-y1)
                    xs_.append(x1 + t*(x2-x1))
        xs_.sort()
        s = [' ']*W
        for i in range(0, len(xs_)-1, 2):
            a, b = int(round(xs_[i])), int(round(xs_[i+1]))
            for k in range(max(0,a), min(W, b)):
                s[k] = '#'
        lines.append(''.join(s))
    return lines

labels = sys.argv[1:] if len(sys.argv) > 1 else None
if labels and labels[0] == '--all':
    W, H = 22, 30
    per_row = 6
    cols = []
    for gi in range(len(charstrings)):
        cols.append((gi, render(gi, W, H)))
    for r in range(0, len(cols), per_row):
        chunk = cols[r:r+per_row]
        hdr = ''
        for gi, _ in chunk:
            hdr += ('[%2d %-5s]' % (gi, glyph_names[gi])).ljust(W+3)
        print(hdr)
        for row in range(H):
            line = ''
            for gi, lines in chunk:
                line += lines[row].ljust(W+3)
            print(line)
        print()
    sys.exit(0)

targets = [int(x) for x in labels] if labels else range(len(charstrings))
for gi in targets:
    print("=== glyph %d  name=%s  width=%s ===" % (gi, glyph_names[gi], run(charstrings[gi])[1]))
    for ln in render(gi):
        print(ln)
    print()
