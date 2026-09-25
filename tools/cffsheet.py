import sys, io
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
src = io.open('tools/glyphrender.py', encoding='utf-8').read().split("labels = sys.argv")[0]
E = {}
exec(compile(src, 'gr', 'exec'), E)
charstrings = E['charstrings']; glyph_names = E['glyph_names']; render = E['render']
W, H = 16, 20
for start in (1, 11, 21, 31):
    chunk = list(range(start, min(start+10, len(charstrings))))
    print('|'.join(('%d:%s' % (g, glyph_names[g])).center(W+1) for g in chunk))
    r = [render(g, W, H) for g in chunk]
    for row in range(H):
        print('|'.join(r[i][row].ljust(W+1) for i in range(len(chunk))))
    print()
