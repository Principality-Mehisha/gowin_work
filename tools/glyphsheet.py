import sys, io
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
src = io.open('tools/glyphrender.py', encoding='utf-8').read()
src = src.split("labels = sys.argv")[0]
exec(src)

lo = int(sys.argv[1]); hi = int(sys.argv[2])
W, H = 18, 24
per = 8
for start in range(lo, hi, per):
    chunk = list(range(start, min(start+per, hi)))
    print(' | '.join(('[%2d %-4s]' % (g, glyph_names[g])).ljust(W+2) for g in chunk))
    renders = [render(g, W, H) for g in chunk]
    for r in range(H):
        print(' | '.join(renders[i][r].ljust(W+2) for i in range(len(chunk))))
    print()
