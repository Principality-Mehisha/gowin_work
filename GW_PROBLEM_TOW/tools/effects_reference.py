"""Sample-domain fixed-point oracle, independent of RTL RAM/FSM scheduling."""
from pathlib import Path
import json
import math
import random
import wave
import struct

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "output/audio_effects"
FS = 50000000 / 3072


def sat(x):
    return max(-32768, min(32767, x))


class Effects:
    lengths = (497, 631, 719, 809, 113, 37)
    bases = (0, 497, 1128, 1847, 2656, 2769)

    def __init__(self):
        self.ram = [None] * 8192
        self.clear(0)

    def clear(self, mode):
        self.mode, self.gain, self.tail, self.phase = mode, 0, 0, 0
        self.pos, self.filled = [0]*6, [0]*6

    def read(self, address, valid):
        if not valid:
            return 0
        assert self.ram[address] is not None, "Read of unwritten delay RAM"
        return self.ram[address]

    def step(self, mode, amount, x):
        old_gain = self.gain
        target = 0 if mode == 0 else min(amount, 100) + (min(amount, 100) >> 2)
        if mode != self.mode or mode == 0:
            self.gain = max(0, self.gain-1)
        else:
            self.gain += (target > self.gain) - (target < self.gain)
        gain = self.gain
        if self.mode == 0:
            self.tail = 0
        elif abs(x) > 4:
            self.tail = (0, 65104, 48828, 814)[self.mode]
        else:
            self.tail = max(0, self.tail-1)
        wet = 0
        if mode != self.mode and old_gain == 0:
            self.clear(mode)
            gain = 0
        elif self.mode == 1:
            p = self.pos[0]
            wet = self.read(p, self.filled[0] >= 4883)
            self.ram[p] = sat(x + (wet >> 1))
            self.pos[0] = (p+1) % 4883
            self.filled[0] = min(4883, self.filled[0]+1)
        elif self.mode == 2:
            s = 0
            for line in range(6):
                address = self.bases[line]+self.pos[line]
                old = self.read(address, self.filled[line] >= self.lengths[line])
                if line < 4:
                    s += old
                    self.ram[address] = sat((x >> 2)+old-(old >> 2))
                    if line == 3:
                        ap = s >> 2
                else:
                    y = old-(ap >> 1)
                    self.ram[address] = sat(ap+(y >> 1))
                    ap = y
                self.pos[line] = (self.pos[line]+1) % self.lengths[line]
                self.filled[line] = min(self.lengths[line], self.filled[line]+1)
            wet = sat(ap)
        elif self.mode == 3:
            folded = (self.phase >> 15) & 65535
            if self.phase >> 31:
                folded ^= 65535
            q8 = 244*256+(((folded-32768)*49) >> 7)
            delay, fraction = q8 >> 8, q8 & 255
            p = self.pos[0]
            a = self.read((p-delay) & 511, self.filled[0] >= delay)
            b = self.read((p-delay-1) & 511, self.filled[0] >= delay+1)
            wet = sat(a+(((b-a)*fraction) >> 8))
            self.ram[p] = x
            self.pos[0] = (p+1) & 511
            self.filled[0] = min(512, self.filled[0]+1)
            self.phase = (self.phase+79165) & 0xffffffff
        y = 0 if x == 0 and self.tail == 0 else sat(x+(((wet-x)*gain) >> 8))
        active = self.mode != 0 and self.gain != 0 and self.tail != 0
        return y, active


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    model = Effects()
    vectors, sections = [], {}

    def add(mode, amount, x, clear=False):
        if clear:
            model.clear(mode)
        y, active = model.step(mode, amount, x)
        word = ((mode << 62) | (amount << 55) | (int(clear) << 54) |
                ((x & 65535) << 38) | ((y & 65535) << 22) |
                (int(active) << 21) | (model.mode << 19) | (model.gain << 12))
        vectors.append(word)
        return y

    rng = random.Random(91357)
    for i in range(256):
        x = rng.randint(-32768, 32767)
        assert add(0, 100, x) == x
    for mode, name, n in ((1, "delay", 65140), (2, "reverb", 48860), (3, "chorus", 9000)):
        add(mode, 100, 0, True)
        for _ in range(160):
            add(mode, 100, 0)
        outputs = []
        start = len(vectors)
        for i in range(n):
            x = (16000 if i == 0 else 0) if mode != 3 else (
                round(16000*math.sin(2*math.pi*440*i/FS)) if i < 8000 else 0)
            outputs.append(add(mode, 100, x))
        if mode == 1:
            assert outputs[4883] > 0 and outputs[9766] > 0 and outputs[-1] == 0
        if mode == 2:
            assert sum(v != 0 for v in outputs[:10000]) > 1000 and outputs[-1] == 0
        if mode == 3:
            assert any(outputs[i] != round(16000*math.sin(2*math.pi*440*i/FS))
                       for i in range(500, 4000))
            assert outputs[-1] == 0
        sections[name] = dict(start=start, samples=len(outputs))
        with wave.open(str(OUT/(name+"_reference.wav")), "wb") as w:
            w.setparams((1, 2, round(FS), 0, "NONE", "not compressed"))
            w.writeframes(struct.pack("<"+"h"*len(outputs), *outputs))
        add(mode, 0, 0, True)
        for _ in range(700):
            assert add(mode, 0, 0) == 0
    for i in range(3000):
        add((i//17) % 4, rng.choice((0, 1, 30, 100, 127)),
            rng.choice((-32768, 32767, 0, rng.randint(-30000, 30000))), i % 139 == 0)
    for mode in range(1, 4):
        add(mode, 0, 0, True)
        for amount in range(128):
            for i in range(130):
                add(mode, amount, (-32768, 32767, 0, 16000)[i % 4])
            assert model.gain == min(amount, 100) + (min(amount, 100) >> 2)
    add(0, 0, 0, True)
    for _ in range(200):
        assert add(0, 0, 0) == 0
    (OUT/"vectors.hex").write_text("".join(f"{v:016x}\n" for v in vectors), encoding="ascii")
    (OUT/"params.vh").write_text(f"`define FX_VECTORS {len(vectors)}\n", encoding="ascii")
    (OUT/"reference.json").write_text(json.dumps(dict(samples=len(vectors), sections=sections,
                                                    sample_rate_hz=FS), indent=2)+"\n")
    print(f"PASS: {len(vectors)} independent fixed-point effect vectors, echoes, dense reverb, modulated chorus, bounds/clear/fades")


if __name__ == "__main__":
    main()
