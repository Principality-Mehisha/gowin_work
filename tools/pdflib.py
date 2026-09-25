"""Shared helpers: PDF object extraction, embedded CFF parsing/rendering, Type3 rendering."""
import re, zlib, struct

def load_pdf(path):
    data = open(path, 'rb').read()
    objs = {}
    for m in re.finditer(rb'(\d+)\s+(\d+)\s+obj', data):
        n = int(m.group(1)); s = m.end(); e = data.find(b'endobj', s)
        objs[n] = data[s:e]

    def get_stream(body):
        i = body.find(b'stream')
        if i < 0: return None, body
        hdr = body[:i]; j = i + 6
        if body[j:j+2] == b'\r\n': j += 2
        elif body[j:j+1] in (b'\n', b'\r'): j += 1
        return body[j:body.rfind(b'endstream')], hdr

    def inflate(s, hdr):
        if not s: return s
        if b'FlateDecode' in hdr:
            for fn in (zlib.decompress, lambda x: zlib.decompressobj().decompress(x)):
                try: return fn(s)
                except Exception: pass
            return None
        return s

    allobj = dict(objs)
    for num, body in list(objs.items()):
        s, hdr = get_stream(body)
        if s is None or b'/ObjStm' not in hdr: continue
        d = inflate(s, hdr)
        if not d: continue
        fm = re.search(rb'/First\s+(\d+)', hdr)
        if not fm: continue
        first = int(fm.group(1))
        nums = [int(x) for x in d[:first].split()]
        pairs = list(zip(nums[0::2], nums[1::2]))
        for i, (on, off) in enumerate(pairs):
            end = pairs[i+1][1] + first if i+1 < len(pairs) else len(d)
            allobj[on] = d[first+off:end]
    return allobj, get_stream, inflate


# ---------------- CFF (embedded Type1C subset font) ----------------
class CFF:
    def __init__(self, blob):
        self.b = blob
        pos = blob[2]
        self.names, pos = self._index(pos)
        self.topdicts, pos = self._index(pos)
        self.strings, pos = self._index(pos)
        self.td = self._dict(self.topdicts[0])
        self.charstrings, _ = self._index(self._dget(self.td, 17))
        cs_off = self._dget(self.td, 15, 0)
        self.glyph_names = ['.notdef']
        if cs_off > 2:
            fmt = blob[cs_off]; p = cs_off + 1
            if fmt == 0:
                for g in range(1, len(self.charstrings)):
                    sid = struct.unpack('>H', blob[p:p+2])[0]; p += 2
                    self.glyph_names.append(self._sid(sid))
        self.pd_off, self.pd_len = self.td.get(18, [0, 0])
        self.pd = self._dict(blob[self.pd_off:self.pd_off+self.pd_len])
        self.subrs = []
        if self.pd.get(19):
            self.subrs, _ = self._index(self.pd_off + self.pd[19][0])

    def _index(self, p):
        b = self.b
        count = struct.unpack('>H', b[p:p+2])[0]
        if count == 0: return [], p+2
        osz = b[p+2]; offs = []; q = p+3
        for i in range(count+1):
            offs.append(int.from_bytes(b[q:q+osz], 'big')); q += osz
        ds = q - 1
        return [b[ds+offs[i]:ds+offs[i+1]] for i in range(count)], ds+offs[-1]

    STD = ["","","space","exclam","quotedbl","numbersign","dollar","percent","ampersand","quoteright","parenleft","parenright","asterisk","plus","comma","hyphen","period","slash","zero","one","two","three","four","five","six","seven","eight","nine","colon","semicolon","less","equal","greater","question","at","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","bracketleft","backslash","bracketright","asciicircum","underscore","quoteleft","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","braceleft","bar","braceright","asciitilde"]

    def _sid(self, sid):
        if sid < len(self.STD): return self.STD[sid]
        i = sid - 390
        return self.strings[i].decode('latin-1') if 0 <= i < len(self.strings) else '?%d' % sid

    def _dict(self, b):
        out = {}; ops = []; i = 0
        while i < len(b):
            c = b[i]
            if c <= 21:
                if c == 12: op = (12, b[i+1]); i += 2
                else: op = c; i += 1
                out[op] = ops; ops = []
            elif c == 28: ops.append(struct.unpack('>h', b[i+1:i+3])[0]); i += 3
            elif c == 29: ops.append(struct.unpack('>i', b[i+1:i+5])[0]); i += 5
            elif c == 30:
                i += 1; s = ''; done = False
                while not done:
                    byte = b[i]; i += 1
                    for n in (byte >> 4, byte & 0xF):
                        if n == 0xf: done = True; break
                        if n <= 9: s += '0123456789'[n]
                        elif n == 0xa: s += '.'
                        elif n == 0xb: s += 'E'
                        elif n == 0xc: s += 'E-'
                        elif n == 0xe: s += '-'
                try: ops.append(float(s))
                except ValueError: ops.append(0.0)
            elif 32 <= c <= 246: ops.append(c-139); i += 1
            elif 247 <= c <= 250: ops.append((c-247)*256+b[i+1]+108); i += 2
            elif 251 <= c <= 254: ops.append(-(c-251)*256-b[i+1]-108); i += 2
            else: i += 1
        return out

    def _dget(self, d, k, default=0):
        v = d.get(k)
        return v[0] if v else default

    def outline(self, gi):
        """Return list of contours (device units) for glyph index gi."""
        cs = self.charstrings[gi]
        S = {
            'x': 0, 'y': 0, 'nStems': 0, 'haveWidth': False,
            'contours': [], 'cur': [],
        }
        self._run(cs, S, 0)
        if len(S['cur']) > 1:
            S['contours'].append(S['cur'])
        return S['contours']

    def _run(self, cs, S, depth):
        stack = []
        i = 0
        def moveTo(px, py):
            if len(S['cur']) > 1:
                S['contours'].append(S['cur'])
            S['cur'] = [(px, py)]
        def lineTo(px, py):
            S['cur'].append((px, py))
        def bez(p0, p1, p2, p3, n=8):
            out = []
            for k in range(1, n+1):
                t = k/n; mt = 1-t
                out.append((mt**3*p0[0]+3*mt*mt*t*p1[0]+3*mt*t*t*p2[0]+t**3*p3[0],
                            mt**3*p0[1]+3*mt*mt*t*p1[1]+3*mt*t*t*p2[1]+t**3*p3[1]))
            return out
        x = S['x']; y = S['y']
        while i < len(cs):
            c = cs[i]
            if c == 28:
                stack.append(struct.unpack('>h', cs[i+1:i+3])[0]); i += 3; continue
            if c >= 32:
                if c <= 246: stack.append(c-139); i += 1
                elif c <= 250: stack.append((c-247)*256+cs[i+1]+108); i += 2
                elif c <= 254: stack.append(-(c-251)*256-cs[i+1]-108); i += 2
                else: stack.append(struct.unpack('>i', cs[i+1:i+5])[0]/65536.0); i += 5
                continue
            if c in (1, 3, 18, 23):
                S['nStems'] += len(stack)//2; stack = []; i += 1
            elif c in (19, 20):
                S['nStems'] += len(stack)//2; stack = []
                i += 1 + (S['nStems']+7)//8
            elif c in (21, 22, 4):
                need = 2 if c == 21 else 1
                if len(stack) > need and not S['haveWidth']:
                    S['haveWidth'] = True; stack = stack[1:]
                S['haveWidth'] = True
                if c == 21: x += stack[-2]; y += stack[-1]
                elif c == 22: x += stack[-1]
                else: y += stack[-1]
                moveTo(x, y); stack = []; i += 1
            elif c == 5:
                j = 0
                while j+1 < len(stack):
                    x += stack[j]; y += stack[j+1]; lineTo(x, y); j += 2
                stack = []; i += 1
            elif c in (6, 7):
                horiz = (c == 6)
                for v in stack:
                    if horiz: x += v
                    else: y += v
                    lineTo(x, y); horiz = not horiz
                stack = []; i += 1
            elif c == 8:
                j = 0
                while j+5 < len(stack):
                    c1 = (x+stack[j], y+stack[j+1]); c2 = (c1[0]+stack[j+2], c1[1]+stack[j+3])
                    nx, ny = c2[0]+stack[j+4], c2[1]+stack[j+5]
                    S['cur'] += bez(S['cur'][-1], c1, c2, (nx, ny)); x, y = nx, ny; j += 6
                stack = []; i += 1
            elif c == 24:
                j = 0
                while j+7 < len(stack):
                    c1 = (x+stack[j], y+stack[j+1]); c2 = (c1[0]+stack[j+2], c1[1]+stack[j+3])
                    nx, ny = c2[0]+stack[j+4], c2[1]+stack[j+5]
                    S['cur'] += bez(S['cur'][-1], c1, c2, (nx, ny)); x, y = nx, ny; j += 6
                if j+1 < len(stack):
                    x += stack[j]; y += stack[j+1]; lineTo(x, y)
                stack = []; i += 1
            elif c == 25:
                j = 0
                while j+1 < len(stack)-6:
                    x += stack[j]; y += stack[j+1]; lineTo(x, y); j += 2
                if j+5 < len(stack):
                    c1 = (x+stack[j], y+stack[j+1]); c2 = (c1[0]+stack[j+2], c1[1]+stack[j+3])
                    nx, ny = c2[0]+stack[j+4], c2[1]+stack[j+5]
                    S['cur'] += bez(S['cur'][-1], c1, c2, (nx, ny)); x, y = nx, ny
                stack = []; i += 1
            elif c in (26, 27):
                j = 0
                if len(stack) % 4 == 1:
                    if c == 26: x += stack[0]
                    else: y += stack[0]
                    j = 1
                while j+3 < len(stack):
                    if c == 26:
                        c1 = (x, y+stack[j]); c2 = (c1[0]+stack[j+1], c1[1]+stack[j+2])
                        nx, ny = c2[0], c2[1]+stack[j+3]
                    else:
                        c1 = (x+stack[j], y); c2 = (c1[0]+stack[j+1], c1[1]+stack[j+2])
                        nx, ny = c2[0]+stack[j+3], c2[1]
                    S['cur'] += bez(S['cur'][-1], c1, c2, (nx, ny)); x, y = nx, ny; j += 4
                stack = []; i += 1
            elif c in (30, 31):
                horiz = (c == 31); j = 0
                while j+3 < len(stack):
                    last = (len(stack)-j == 5)
                    if horiz:
                        c1 = (x+stack[j], y); c2 = (c1[0]+stack[j+1], c1[1]+stack[j+2])
                        nx = c2[0] + (stack[j+4] if last else 0)
                        ny = c2[1] + (0 if last else stack[j+3])
                    else:
                        c1 = (x, y+stack[j]); c2 = (c1[0]+stack[j+1], c1[1]+stack[j+2])
                        nx = c2[0] + (0 if last else stack[j+3])
                        ny = c2[1] + (stack[j+4] if last else 0)
                    S['cur'] += bez(S['cur'][-1], c1, c2, (nx, ny)); x, y = nx, ny
                    horiz = not horiz; j += 5 if last else 4
                stack = []; i += 1
            elif c == 10:
                idx = int(stack.pop()) if stack else 0
                if 0 <= idx < len(self.subrs):
                    save = S['cur']
                    S['cur'] = []
                    self._run(self.subrs[idx], S, depth+1)
                    if len(S['cur']) > 1:
                        S['contours'].append(S['cur'])
                    S['cur'] = save
                i += 1
            elif c == 11:
                break
            elif c == 14:
                if len(S['cur']) > 1: S['contours'].append(S['cur'])
                S['cur'] = []
                break
            elif c == 12:
                i += 2
            else:
                i += 1
        S['x'] = x; S['y'] = y


def rasterize(contours, W=16, H=20, box=None):
    pts = [p for c in contours for p in c]
    if not pts: return None, None
    xs = [p[0] for p in pts]; ys = [p[1] for p in pts]
    if box is None:
        minx, maxx, miny, maxy = min(xs), max(xs), min(ys), max(ys)
    else:
        minx, maxx, miny, maxy = box
    w = maxx-minx or 1e-9; h = maxy-miny or 1e-9
    grid = []
    for row in range(H):
        yc = miny + h*(row+0.5)/H
        xi = []
        for c in contours:
            n = len(c)
            for i in range(n):
                x1, y1 = c[i]; x2, y2 = c[(i+1) % n]
                if (y1 <= yc < y2) or (y2 <= yc < y1):
                    t = (yc-y1)/(y2-y1)
                    xi.append(x1 + t*(x2-x1))
        xi.sort()
        bits = [0]*W
        for i in range(0, len(xi)-1, 2):
            a = int((xi[i]-minx)/w*W); b = int((xi[i+1]-minx)/w*W)
            for k in range(max(0, min(W, a)), max(0, min(W, b))): bits[k] = 1
        grid.append(bits)
    return grid, (minx, maxx, miny, maxy)
