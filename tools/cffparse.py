import struct

cff = open(r"tools\font.cff", "rb").read()
pos = 0
major, minor, hdrsize, offSize = cff[0], cff[1], cff[2], cff[3]
print("hdr", major, minor, hdrsize, offSize)
pos = hdrsize

def read_index(p):
    count = struct.unpack(">H", cff[p:p+2])[0]
    if count == 0:
        return [], p+2
    osz = cff[p+2]
    offs = []
    q = p+3
    for i in range(count+1):
        v = int.from_bytes(cff[q:q+osz], "big")
        offs.append(v); q += osz
    dataStart = q - 1
    items = []
    for i in range(count):
        items.append(cff[dataStart+offs[i]:dataStart+offs[i+1]])
    return items, dataStart + offs[-1]

names, pos = read_index(pos)
print("names:", [n.decode('latin-1') for n in names])
topdicts, pos = read_index(pos)
print("topdict len", len(topdicts))

STD_STRINGS = ["", "", "space","exclam","quotedbl","numbersign","dollar","percent","ampersand","quoteright","parenleft","parenright","asterisk","plus","comma","hyphen","period","slash","zero","one","two","three","four","five","six","seven","eight","nine","colon","semicolon","less","equal","greater","question","at","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","bracketleft","backslash","bracketright","asciicircum","underscore","quoteleft","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","braceleft","bar","braceright","asciitilde"]

strings, pos = read_index(pos)
print("num custom strings", len(strings))

def sid_name(sid):
    if sid < len(STD_STRINGS):
        return STD_STRINGS[sid]
    i = sid - 390
    if 0 <= i < len(strings):
        return strings[i].decode('latin-1')
    return "?sid%d" % sid

def parse_dict(b):
    out = {}
    operands = []
    i = 0
    while i < len(b):
        c = b[i]
        if c <= 21:
            if c == 12:
                op = (12, b[i+1]); i += 2
            else:
                op = c; i += 1
            out[op] = operands
            operands = []
        elif c == 28:
            operands.append(struct.unpack(">h", b[i+1:i+3])[0]); i += 3
        elif c == 29:
            operands.append(struct.unpack(">i", b[i+1:i+5])[0]); i += 5
        elif c == 30:
            # real number
            s = ''
            i += 1
            done = False
            nibbles = {0xa:'.',0xb:'E',0xc:'E-',0xd:'',0xe:'-',0xf:None}
            while not done:
                byte = b[i]; i += 1
                for nib in (byte >> 4, byte & 0xF):
                    if nib == 0xf:
                        done = True; break
                    s += str(nibbles.get(nib, str(nib)))
            operands.append(float(s))
        elif 32 <= c <= 246:
            operands.append(c - 139); i += 1
        elif 247 <= c <= 250:
            operands.append((c-247)*256 + b[i+1] + 108); i += 2
        elif 251 <= c <= 254:
            operands.append(-(c-251)*256 - b[i+1] - 108); i += 2
        else:
            i += 1
    return out

td = parse_dict(topdicts[0])
for k, v in td.items():
    print("topdict op", k, v)

# Charstrings INDEX (op 17)
cs_off = td[17][0]
charstrings, _ = read_index(cs_off)
print("num glyphs", len(charstrings))

# Charset (op 15)
charset_off = td.get(15, [0])[0]
print("charset off", charset_off)
glyph_names = ['.notdef']
if charset_off == 0:
    print("ISOAdobe predefined charset")
elif charset_off in (1, 2):
    print("expert predefined", charset_off)
else:
    fmt = cff[charset_off]
    print("charset fmt", fmt)
    p = charset_off + 1
    if fmt == 0:
        for g in range(1, len(charstrings)):
            sid = struct.unpack(">H", cff[p:p+2])[0]; p += 2
            glyph_names.append(sid_name(sid))
    elif fmt == 1:
        while len(glyph_names) < len(charstrings):
            first = struct.unpack(">H", cff[p:p+2])[0]; p += 2
            nLeft = cff[p]; p += 1
            for k in range(nLeft+1):
                glyph_names.append(sid_name(first+k))
    elif fmt == 2:
        while len(glyph_names) < len(charstrings):
            first = struct.unpack(">H", cff[p:p+2])[0]; p += 2
            nLeft = struct.unpack(">H", cff[p:p+2])[0]; p += 2
            for k in range(nLeft+1):
                glyph_names.append(sid_name(first+k))

print("glyph names:")
for i, n in enumerate(glyph_names):
    print(" ", i, n)
