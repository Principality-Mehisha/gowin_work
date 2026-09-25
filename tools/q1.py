import pickle, re
d = pickle.load(open(r"tools\pdf.pkl","rb"))
a = d["allobj"]
for n in (13656, 13653, 13655, 13657, 20):
    print("=== obj", n, "===")
    print(a[n].decode("latin-1")[:1500])
    print()
