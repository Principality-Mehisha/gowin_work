src = open(r"tools\type3match.py", encoding="utf-8").read()
print("has marker:", "__main__" in src, len(src))
parts = src.split("if __name__")
print("parts:", len(parts))
