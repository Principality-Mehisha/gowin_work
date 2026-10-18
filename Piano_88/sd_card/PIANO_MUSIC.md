# Croatian Rhapsody BIN Player

Open `SD_Piano_Music_Player.gprj`, or run `build_piano_music.tcl`.
Device: Tang Mega 60K, GW5AT-LV60PG484AC1/I0, 50 MHz system clock.

Copy `piano_music/PIANO.BIN` into the FAT16/FAT32 card root as `PIANO.BIN`.
This is a complete piano MIDI arrangement rendered with recorded piano samples.
It is not the commercial Maksim recording. Source and sample credits are in
`music/ATTRIBUTION.md`. The original MIDI was downloaded again on 2026-10-18,
with the same SHA256 as the credited source.

- Format: headerless signed PCM16 little-endian mono, 16276 Hz.
- Size: 6614770 bytes / 3307385 samples / approximately 3:23.
- SHA256: `003f6e5d339d809ca4e996cfbe3bd67b6f35e133af5f42b78834ec1002e00ead`.
- Actual DAC rate: 50000000 / 3072 = 16276.041667 Hz.
- SD SPI initialization and reading: divider 63, approximately 397 kHz.
- 8192-sample FIFO, 4096-sample prefill, per-sector CRC verification.
- Autoplay once at startup; KEY0 pauses/resumes, KEY1 restarts, KEY2 resets.
- LED0: SD initialized; LED1: file found; LED2: playing; LED3: error.
- Audio: onboard PT8211, dual mono, amplifier enabled low on AB16.

The complete-song BIN differs from `music/PIANO.BIN`, which is the 88-key
instrument's sample bank. These formats are not interchangeable.

Rebuild the song with `tools/render_full_piano.py` and
`tools/prepare_sd_music.py`, then run `tools/prepare_piano_music_bin.py`.
Run `sim/run_piano_music.do` in ModelSim for exact signed sample comparisons,
FAT16/FAT32 and DAC serial output, pause/replay/error handling, full-file FAT32
decoding, and sustained supply at the hardware SPI divider.

At divider 63, the card needs multi-sector clusters for PCM16 throughput.
The card checked on 2026-10-18 has 64 sectors per cluster.
SRAM download is volatile; reload after removing FPGA power.
