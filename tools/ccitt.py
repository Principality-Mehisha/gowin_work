"""CCITT Group 4 (T.6) decoder - canonical implementation.

The decoder tracks the current colour explicitly and derives each mode's effect
from the standard 2D rules.  Reference line changing elements are padded with a
sentinel at width,width so b1/b2 lookups are simple.
"""

WHITE = {
 0:'00110101',1:'000111',2:'0111',3:'1000',4:'1011',5:'1100',6:'1110',7:'1111',
 8:'10011',9:'10100',10:'00111',11:'01000',12:'001000',13:'000011',14:'110100',
 15:'110101',16:'101010',17:'101011',18:'0100111',19:'0001100',20:'0001000',
 21:'0010111',22:'0000011',23:'0000100',24:'0101000',25:'0101011',26:'0010011',
 27:'0100100',28:'0011000',29:'00000010',30:'00000011',31:'00011010',
 32:'00011011',33:'00010010',34:'00010011',35:'00010100',36:'00010101',
 37:'00010110',38:'00010111',39:'00101000',40:'00101001',41:'00101010',
 42:'00101011',43:'00101100',44:'00101101',45:'00000100',46:'00000101',
 47:'00001010',48:'00001011',49:'01010010',50:'01010011',51:'01010100',
 52:'01010101',53:'00100100',54:'00100101',55:'01011000',56:'01011001',
 57:'01011010',58:'01011011',59:'01001010',60:'01001011',61:'00110010',
 62:'00110011',63:'00110100',
 64:'11011',128:'10010',192:'010111',256:'0110111',320:'00110110',
 384:'00110111',448:'01100100',512:'01100101',576:'01101000',
 640:'01100111',704:'011001100',768:'011001101',832:'011010010',
 896:'011010011',960:'011010100',1024:'011010101',1088:'011010110',
 1152:'011010111',1216:'011011000',1280:'011011001',1344:'011011010',
 1408:'011011011',1472:'010011000',1536:'010011001',1600:'010011010',
 1664:'011000',1728:'010011011',
}
BLACK = {
 0:'0000110111',1:'010',2:'11',3:'10',4:'011',5:'0011',6:'0010',7:'00011',
 8:'000101',9:'000100',10:'0000100',11:'0000101',12:'0000111',13:'00000100',
 14:'00000111',15:'000011000',16:'0000010111',17:'0000011000',18:'0000001000',
 19:'00001100111',20:'00001101000',21:'00001101100',22:'00000110111',
 23:'00000101000',24:'00000010111',25:'00000011000',26:'000011001010',
 27:'000011001011',28:'000011001100',29:'000011001101',30:'000001101000',
 31:'000001101001',32:'000001101010',33:'000001101011',34:'000011010010',
 35:'000011010011',36:'000011010100',37:'000011010101',38:'000011010110',
 39:'000011010111',40:'000001101100',41:'000001101101',42:'000011011010',
 43:'000011011011',44:'000001010100',45:'000001010101',46:'000001010110',
 47:'000001010111',48:'000001100100',49:'000001100101',50:'000001010010',
 51:'000001010011',52:'000000100100',53:'000000110111',54:'000000111000',
 55:'000000100111',56:'000000101000',57:'000001011000',58:'000001011001',
 59:'000000101011',60:'000000101100',61:'000001011010',62:'000001100110',
 63:'000001100111',
 64:'0000001111',128:'000011001000',192:'000011001001',256:'000001011011',
 320:'000000110011',384:'000000110100',448:'000000110101',512:'0000001101100',
 576:'0000001101101',640:'0000001001010',704:'0000001001011',768:'0000001001100',
 832:'0000001001101',896:'0000001110010',960:'0000001110011',1024:'0000001110100',
 1088:'0000001110101',1152:'0000001110110',1216:'0000001110111',
 1280:'0000001010010',1344:'0000001010011',1408:'0000001010100',
 1472:'0000001010101',1536:'0000001011010',1600:'0000001011011',
 1664:'0000001100100',1728:'0000001100101',
}
W_DEC = {v: k for k, v in WHITE.items()}
B_DEC = {v: k for k, v in BLACK.items()}
W_MAX = max(len(k) for k in WHITE.values())
B_MAX = max(len(k) for k in BLACK.values())


class Reader:
    def __init__(self, data):
        self.d = data; self.p = 0

    def get(self, n=1):
        v = 0
        for _ in range(n):
            if self.p >= len(self.d)*8: return None
            v = (v << 1) | ((self.d[self.p >> 3] >> (7 - (self.p & 7))) & 1)
            self.p += 1
        return v

    def peek(self, n):
        s = self.p; v = self.get(n); self.p = s; return v

    def s(self, n):
        v = self.peek(n)
        return format(v, '0%db' % n) if v is not None else None


def read_run(rd, table, maxlen):
    code = ''
    for _ in range(maxlen):
        b = rd.get(1)
        if b is None: return None
        code += '1' if b else '0'
        if code in table:
            return table[code]
    return None


def read_mode(rd):
    """Return ('V', d) or ('H', None) or ('P', None) or ('EOL', None) or None."""
    if rd.s(12) == '000000000001':
        rd.get(12); return ('EOL', None)
    for n, tab in ((1, {'1': 0}), (3, {'011': 1, '010': -1}),
                   (6, {'000011': 2, '000010': -2}),
                   (7, {'0000011': 3, '0000010': -3})):
        s = rd.s(n)
        if s in tab:
            rd.get(n); return ('V', tab[s])
    if rd.s(4) == '0001':
        rd.get(4); return ('P', None)
    if rd.s(3) == '001':
        rd.get(3); return ('H', None)
    return None


def decode(data, width, height):
    """Return a list of `height` rows of 0/1 ints (1 = black)."""
    rd = Reader(data)
    # optional leading EOL
    if rd.s(12) == '000000000001':
        rd.get(12)
    ref = [width, width]
    rows = []
    for _ in range(height):
        cur = []
        a0 = 0
        color = 0
        guard = 0
        while a0 < width:
            guard += 1
            if guard > 4000: break
            m = read_mode(rd)
            if m is None: return rows
            kind, val = m
            if kind == 'EOL':
                break
            if kind == 'P':
                b1 = next_gt(ref, a0, width)
                b2 = next_gt(ref, b1, width)
                a0 = b2
                cur.append(b2)
            elif kind == 'H':
                r1 = read_run(rd, W_DEC, W_MAX)
                if r1 is None: return rows
                a0 += r1
                cur.append(a0)
                r2 = read_run(rd, B_DEC, B_MAX)
                if r2 is None: return rows
                a0 += r2
                cur.append(a0)
            else:
                b1 = next_gt(ref, a0, width)
                a1 = b1 + val
                if a1 < 0: a1 = 0
                if a1 > width: a1 = width
                a0 = a1
                cur.append(a0)
        while cur and cur[-1] >= width:
            cur.pop()
        rows.append(cur)
        ref = cur if cur else [width, width]
    # convert change lists to pixel rows
    out = []
    for ch in rows:
        row = []
        pos = 0; col = 0
        for c in ch:
            c = min(c, width)
            while pos < c:
                row.append(col); pos += 1
            col ^= 1
        while pos < width:
            row.append(col); pos += 1
        out.append(row[:width])
    return out


def next_gt(seq, a0, width):
    for v in seq:
        if v > a0: return v
    return width
