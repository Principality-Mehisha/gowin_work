# GoWin FPGA60K Stereo Internationale

This project drives the onboard PT8211 DAC on the Tang Mega 60K NEO Dock.

## Expected behavior

- After configuration, the audio clocks start immediately with zero data.
- The onboard amplifier is enabled after about 50 ms.
- After about 100 ms, both channels play the complete public-domain melody
  `The Internationale` (`国际歌`) in G major at about 120 BPM.
- The 129-event score begins with the written pickup and opening
  `D-G-F#-A-G-D-B-E`, preserves the dotted-eighth/sixteenth figures, and spans
  B3 through D5. Continuous phase, pitch slewing and soft envelopes smooth the
  transitions between notes.
- The mono mix is explicitly loaded into separate PT8211 left and right sample
  registers so both onboard speaker channels receive the complete waveform.
- The eight active-low PMOD LEDs show the current section of the score.
- Pressing the configured reset button stops the amplifier and restarts playback.

## Piano voice

The voice is synthesized in the FPGA rather than read from a recording:

- piano-like fundamental with restrained 2nd/3rd partials and a short
  deterministic hammer partial;
- frame-rate ADSR-style envelope: fast attack, exponential-like decay toward
  sustain, and a short release before changing notes;
- two-stage low-pass filtering, a DC blocker and a low-level noise gate.

This is a compact FPGA piano approximation. A sampled concert piano would need
per-note PCM memory or a larger physical-modeling voice.

## Audio interface

The PT8211 uses 16-bit LSBJ/Japanese right-justified data, not standard I2S:

- `HP_BCK`: 1.5625 MHz bit clock
- `HP_WS`: low for right, high for left; both receive the same mono mix
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
