"""Sample-domain oracle and audible modulation checks, independent of RTL scheduling."""
from pathlib import Path
import json
import math
import random
import wave
import struct

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "output/audio_effects"
FS = 50000000 / 3072
LFO_STEP = round(2**32 * 5 / FS)


def sat(x):
    return max(-32768, min(32767, x))


class Effects:
    def __init__(self):
        self.ram = [None] * 8192
        self.clear(0)

    def clear(self, mode):
        self.mode, self.gain, self.mix, self.tail, self.phase = mode, 0, 0, 0, 0
        self.pos, self.filled = 0, 0

    def read(self, address, valid):
        if not valid:
            return 0
        assert self.ram[address] is not None, "Read of unwritten delay RAM"
        return self.ram[address]

    def step(self, mode, amount, x):
        old_gain, old_mix = self.gain, self.mix
        amount = min(amount, 100)
        target = 0 if mode == 0 else amount + (amount >> 2)
        if mode != self.mode or mode == 0:
            self.gain = max(0, self.gain-1)
        else:
            self.gain += (target > self.gain) - (target < self.gain)
        want_vibrato = mode == self.mode == 3 and amount != 0
        self.mix = min(256, self.mix+1) if want_vibrato else max(0, self.mix-1)
        gain = self.mix if self.mode == 3 else self.gain
        if self.mode in (0, 2):
            self.tail = 0
        elif abs(x) > 4:
            self.tail = 65104 if self.mode == 1 else 114
        else:
            self.tail = max(0, self.tail-1)
        wet = 0
        folded = (self.phase >> 15) & 65535
        if self.phase >> 31:
            folded ^= 65535
        if mode != self.mode and old_gain == old_mix == 0:
            self.clear(mode)
            gain = 0
        elif self.mode == 1:
            wet = self.read(self.pos, self.filled >= 4883)
            self.ram[self.pos] = sat(x + (wet >> 1))
            self.pos = (self.pos+1) % 4883
            self.filled = min(4883, self.filled+1)
        elif self.mode == 2:
            wet = sat(x-((x*(folded >> 8)) >> 7))
            self.phase = (self.phase+LFO_STEP) & 0xffffffff
        elif self.mode == 3:
            q8 = 80*256+(((folded-32768)*32*self.gain) >> 14)
            delay, fraction = q8 >> 8, q8 & 255
            a = self.read((self.pos-delay) & 511, self.filled >= delay)
            b = self.read((self.pos-delay-1) & 511, self.filled >= delay+1)
            wet = sat(a+(((b-a)*fraction) >> 8))
            self.ram[self.pos] = x
            self.pos = (self.pos+1) & 511
            self.filled = min(512, self.filled+1)
            self.phase = (self.phase+LFO_STEP) & 0xffffffff
        y = 0 if x == 0 and self.tail == 0 else sat(x+(((wet-x)*gain) >> 8))
        active = self.tail != 0 and ((self.mode == 1 and self.gain != 0) or
                                    (self.mode == 3 and self.mix != 0))
        return y, active


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    model = Effects()
    vectors, sections, measurements = [], {}, {}

    def add(mode, amount, x, clear=False):
        if clear:
            model.clear(mode)
        y, active = model.step(mode, amount, x)
        word = ((mode << 62) | (amount << 55) | (int(clear) << 54) |
                ((x & 65535) << 38) | ((y & 65535) << 22) |
                (int(active) << 21) | (model.mode << 19) | (model.gain << 12) |
                (model.mix << 3))
        vectors.append(word)
        return y

    def export(name, values, start):
        sections[name] = dict(start=start, samples=len(values))
        with wave.open(str(OUT/(name+"_reference.wav")), "wb") as w:
            w.setparams((1, 2, round(FS), 0, "NONE", "not compressed"))
            w.writeframes(struct.pack("<"+"h"*len(values), *values))

    rng = random.Random(91357)
    for _ in range(256):
        x = rng.randint(-32768, 32767)
        assert add(0, 100, x) == x
    add(1, 100, 0, True)
    for _ in range(300):
        add(1, 100, 0)
    start = len(vectors)
    outputs = [add(1, 100, 16000 if i == 0 else 0) for i in range(65140)]
    assert outputs[4883] > 0 and outputs[9766] > 0 and outputs[-1] == 0
    export("delay", outputs, start)

    for mode, name in ((2, "tremolo"), (3, "vibrato")):
        add(mode, 100, 0, True)
        for _ in range(300):
            add(mode, 100, 0)
        start = len(vectors)
        inputs = [round(16000*math.sin(2*math.pi*440*i/FS)) for i in range(22000)]
        outputs = [add(mode, 100, x) for x in inputs]
        outputs += [add(mode, 100, 0) for _ in range(700)]
        assert outputs[-1] == 0
        export(name, outputs, start)
        if mode == 3:
            assert model.mix == 256, "Steady vibrato must have no dry blend"
            stable = outputs[1000:21000]
            crossings = [i-1-stable[i-1]/(stable[i]-stable[i-1])
                         for i in range(1, len(stable)) if stable[i-1] <= 0 < stable[i]]
            pitches = [FS/(b-a) for a, b in zip(crossings, crossings[1:])]
            assert 420 < min(pitches) < 430 and 450 < max(pitches) < 460
            # Compare cycle peaks to reject accidental amplitude modulation.
            peaks = [max(abs(x) for x in stable[math.ceil(a):math.floor(b)+1])
                     for a, b in zip(crossings, crossings[1:])]
            assert min(peaks) > 15500 and max(peaks) <= 16000
            measurements["vibrato"] = dict(min_pitch_hz=min(pitches), max_pitch_hz=max(pitches),
                                            min_cycle_peak=min(peaks), max_cycle_peak=max(peaks),
                                            steady_wet_weight=model.mix)

    # A DC probe isolates the tremolo envelope from the carrier waveform.
    for amount in (30, 100):
        add(2, amount, 0, True)
        for _ in range(300):
            add(2, amount, 0)
        envelope = [add(2, amount, 16000) for _ in range(20000)]
        low = min(envelope)/16000
        assert max(envelope) == 16000 and all(0 < x <= 16000 for x in envelope)
        assert (0.70 < low < 0.73) if amount == 30 else (0.02 < low < 0.04)
        measurements["tremolo_"+str(amount)] = dict(min_level_ratio=low, max_level_ratio=1)
        assert add(2, amount, 0) == 0 and not model.tail, "Tremolo must not invent a tail"

    for mode in range(1, 4):
        add(mode, 0, 0, True)
        for amount in range(128):
            for i in range(130):
                add(mode, amount, (-32768, 32767, 0, 16000)[i % 4])
            assert model.gain == min(amount, 100) + (min(amount, 100) >> 2)
    for old_mode in range(4):
        for new_mode in range(4):
            add(old_mode, 100, 0, True)
            for _ in range(300):
                add(old_mode, 100, 12000)
            for _ in range(600):
                add(new_mode, 100, -12000)
            assert model.mode == new_mode
    for mode in (2, 3):
        for _ in range(300):
            add(mode, 0, 0)
        for i in range(5000):
            x = 32767 if i % 2 else -32768
            assert add(mode, 0, x) == x, "Zero amount must be bit-exact dry"
        add(mode, 100, 0, True)
        for _ in range(300):
            add(mode, 100, 0)
        for x in (32767, -32768):
            for _ in range(5000):
                add(mode, 100, x)
    for i in range(3000):
        add((i//17) % 4, rng.choice((0, 1, 30, 100, 127)),
            rng.choice((-32768, 32767, 0, rng.randint(-30000, 30000))), i % 139 == 0)
    add(0, 0, 0, True)
    for _ in range(200):
        assert add(0, 0, 0) == 0
    (OUT/"vectors.hex").write_text("".join(f"{v:016x}\n" for v in vectors), encoding="ascii")
    (OUT/"params.vh").write_text(f"`define FX_VECTORS {len(vectors)}\n", encoding="ascii")
    (OUT/"reference.json").write_text(json.dumps(dict(samples=len(vectors), sections=sections,
        sample_rate_hz=FS, modulation_rate_hz=5, measurements=measurements), indent=2)+"\n")
    print(f"PASS: {len(vectors)} fixed-point vectors; delay, measured tremolo envelope/vibrato pitch, bounds/clear/fades")


if __name__ == "__main__":
    main()
