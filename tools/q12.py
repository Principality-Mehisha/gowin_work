import io, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
src = io.open('tools/type3match.py', encoding='utf-8').read()
print("len", len(src), "marker count", src.count("# ---- collect unique"))
parts = src.split("# ---- collect unique")
print("parts", len(parts))
