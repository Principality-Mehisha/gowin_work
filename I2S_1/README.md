# I2S_1 32-note piano tone generator

This project drives the PT8211 DAC on the Tang Mega 60K NEO Dock. The serial
audio format is PT8211 16-bit LSBJ/Japanese timing rather than Philips I2S.

## Controls

- `KEY2`: active-low reset. Reset selects C3 and enables playback.
- `KEY1`: advance one semitone. After G5, the selection wraps to C3.
- `KEY0`: toggle playback and stop.

KEY0 and KEY1 are synchronized and debounced for 20 ms. Each stable press
causes exactly one action, even when the button is held.

The top-level also instantiates the Gowin `GSR` primitive. This is important
for configuration-time initialization: if the board is reprogrammed while
`KEY2` is high, the user reset input may not produce a low-to-high reset edge.
GSR guarantees that the serializer, startup counter, envelope, and controls
still begin from known state on every configuration.

## Notes

The 32 equal-tempered notes cover C3 through G5:

`C3 C#3 D3 D#3 E3 F3 F#3 G3 G#3 A3 A#3 B3`

`C4 C#4 D4 D#4 E4 F4 F#4 G4 G#4 A4 A#4 B4`

`C5 C#5 D5 D#5 E5 F5 F#5 G5`

The sound is synthesized in the FPGA from a triangle-derived fundamental,
restrained harmonics, an ADSR-style envelope, low-pass smoothing, and a DC
blocker. Both output channels receive the same sample.

## Audio timing

- System clock: 50 MHz
- Bit clock: 1.5625 MHz
- Sample rate: 48.828125 kHz
- Power-amplifier startup delay: 50 ms

The amplifier remains disabled and PCM remains at zero during startup. Playback
and note changes use attack/release shaping to reduce clicks.

## Build

Open `I2S_1.gprj` in Gowin EDA and run all processes, or run:

```text
gw_sh.exe tools/build.tcl
```

The generated bitstream is `impl/pnr/I2S_1.fs`.
