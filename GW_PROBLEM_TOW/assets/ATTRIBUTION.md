# Piano Recording Attribution

The source WAV files in `piano/` are from **tonejs-instruments**,
maintained by Nicholaus P. Brosowsky:

https://github.com/nbrosowsky/tonejs-instruments

The upstream `sample-source-info.txt` identifies the piano source as VSCO2:

http://vis.versilstudios.net/vsco-community.html

The upstream repository distributes the samples under **CC BY 3.0**:

https://creativecommons.org/licenses/by/3.0/

The upstream license and source information are preserved in `piano/`.
Source sample names: C1, Fs1, C2, Fs2, C3, Fs3, C4, Fs4,
C5, Fs5, C6, Fs6, C7, Fs7, C8.

Changes made for this FPGA project: stereo-to-mono conversion, trimming,
anti-alias filtering, resampling to 16276.041667 Hz, normalization,
final fade to zero for one-shot playback, and 8-bit mu-law encoding.
The FPGA transposes neighboring recording zones to cover A0 through C8.
Audio previews are derived from the same mu-law bank and playback algorithm.

# Marimba PCM Attribution

The source AIFF files in `marimba/source/` are from the University of Iowa
Electronic Music Studios Musical Instrument Samples (MIS), recorded by
Lawrence Fritts and contributors. The MIS site says its recordings may be
downloaded and used for projects without restrictions:

https://theremin.music.uiowa.edu/MIS.html

Marimba source set: yarn mallet, pp/mf/ff, files named
`Marimba.yarn.{pp,mf,ff}.{C2B2,C3B3,C4B4,C5B5}.aif`. The COMM chunks declare
96 kHz, 24-bit stereo AIFF; the former 44.1 kHz interpretation was an error.
Measured fundamentals validate MIDI 47 through 77 (B2-F5). The fitter
anti-alias resamples to 24 kHz for analysis, retains measured modal frequency
ratios, and tunes the fundamental to equal temperament at A4=440 Hz.

The FPGA does not contain or play these recordings. `tools/fit_marimba_params.py`
fits modal amplitudes, decay per second and a short attack envelope, then
converts decay to the actual output rate and writes compact parameter ROMs.
The separate fixed body-coloration filter is retained and included in the
integer per-note level calibration; its coefficients are not newly measured
body-residual peaks. The coherent mf set drives the ROM; pp/ff measurements
are retained separately, not averaged across unrelated peaks.
`assets/marimba/fit_report.json` records measured values, detected onsets, and
the tuning, disabled modes and complete-chain level calibration method.

# Experimental Apple Marimba Reference

The current KEY0 selection has moved to the Android/Samsung event arrangement
documented in `ANDROID_RINGTONE.md`; the Apple data below remains a reference.

`assets/ringtone/apple_marimba_2007.mp3` is a listening reference obtained from
the Awesome Ringtone collection:

https://raw.githubusercontent.com/w3teal/awesome-ringtone/main/Apple/2007%20-%20Marimba.mp3

The collection states that its ringtone files are third-party copies and that
copyright remains with the relevant brand or creator. This file is included
only for an experimental comparison. Earlier versions stored an IMA ADPCM
representation for KEY0 comparison. As of 2026-10-23 the board-level design
instead reads RINGTONE.BIN note events from SD and performs real-time modal
marimba synthesis. The old ADPCM source, ROM and independent diagnostic test
remain historical references and are not instantiated by the board player.
The spectral event transcription estimates timing, pitches, chords and
velocity; it does not reproduce the original recording waveform.

# Samsung Android Theme Arrangement

`ringtone/android/samsung_over_the_horizon_s3.mid` was downloaded from the
public phone-tone archive at:

http://onj3.andrelouis.com/phonetones/unzipped/Samsung/GT-E1270/01%20Ringtones/07%20Over%20the%20horizon.mid

Samsung's official history identifies Over the Horizon as the Galaxy theme
and describes the 2012 Galaxy S III version:

https://news.samsung.com/global/over-the-horizon-the-evolution-of-the-samsung-galaxy-brand-sound

The MIDI comes from a feature-phone arrangement of the same theme. Only its
GM Marimba part is used, with one simultaneous unison merged to its stronger
velocity. Timing and note velocity are retained; other instruments, pan,
channel volume and the small fixed pitchwheel offset are not reproduced.
This project renders the part with its existing real-time modal marimba.
The original ringtone and MIDI rights remain with their respective owners;
availability in the public archive is not a claim of an official license.
