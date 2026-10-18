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
