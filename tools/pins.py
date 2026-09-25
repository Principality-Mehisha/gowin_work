import re, sys
# Balls proven valid for GW5AT-LV60PG484AC1/I0 by evidence gathered in this session:
#  - the official Sipeed Tang Mega 60K example constraints
#  - the previous led_water build (pin report)
#  - the constraint parser accepting them in this project
VALID = """V22 Y14 AB12 AA13 AB13 Y12 Y13 AA12 Y9 AB6 W9 AB8 Y7 AB7 Y8 AA8 AB1 AB5 AB2 AA1 V4 AA5 AB3 Y4
V9 V8 Y3 AA3 M6 P2 M1 K1 K4 H3 L1 H5 J5 J1 G3 H2 J2 J4 G2 K2 L4 L5 P4 L6 L3 K3 V7 AA4
T20 N15 R14 R16 P15 P14 M14 N14 M15 N16 P17 R15 Y21 Y22 AB21 AB22 AA20 AA21 AA19 AB20
P19 R19 T21 U21 P16 R17 R18 T18 V2 J16 K13 G15 G16 J14 H14 J15 H15 K17 J17 M2 M5 D1 P5 R1
C13 C14 C15 C17 C18 C19 C20 AA14 AA15 AA16 AA17 AB14 AB15 AB16 AB17 Y15 Y16 Y17 Y18
"""
order = []
for tok in VALID.split():
    if tok not in order:
        order.append(tok)

used = set("""V22 AA13 Y21 Y22 AB21 AB22 AA20 AA21 AA19 AB20""".split())
free = [b for b in order if b not in used]
print("free candidates:", len(free))
print(free)
