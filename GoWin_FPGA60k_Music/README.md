# GoWin FPGA60K Music

This project drives the onboard PT8211 DAC on the Tang Mega 60K NEO Dock.

## Expected behavior

- After configuration, the audio clocks start immediately with zero data.
- The onboard amplifier is enabled after about 50 ms.
- After about 100 ms, both channels play a repeating C4-to-C5-to-C4 scale with
  a piano-like synthesized timbre.
- The eight active-low PMOD LEDs show the current note position.
- Pressing the configured reset button stops the amplifier and restarts playback.

## Piano voice

The voice is synthesized in the FPGA rather than read from a recording:

- triangle fundamental plus 2nd, 3rd, and 4th harmonics;
- a short LFSR-based hammer transient at each note onset;
- frame-rate ADSR-style envelope: fast attack, exponential-like decay toward
  sustain, and a short release before changing notes;
- one-pole low-pass filtering, brighter during the attack and warmer during
  the sustain/tail.

This is an electronic/toy-piano approximation. A more realistic piano would
need per-note PCM samples or a much larger physical-modeling voice.

## Audio interface

The PT8211 uses 16-bit LSBJ/Japanese right-justified data, not standard I2S:

- `HP_BCK`: 1.5625 MHz bit clock
- `HP_WS`: low for right, high for left
- `HP_DIN`: signed 16-bit, MSB first, sampled on BCK rising edges
- `PA_EN`: active-low amplifier enable
- Sample rate: approximately 48.828125 kHz

The current PMOD LED, clock, and reset pin locations in
`src/GoWin_FPGA60k_Music.cst` are preserved. Only the four board-audio pins
were added.

## Build

Open `GoWin_FPGA60k_Music.gprj` in Gowin EDA and run all processes. Program
`impl/pnr/GoWin_FPGA60k_Music.fs`, then connect headphones or suitable speakers
to the NEO Dock audio output. Start with a conservative listening level.
