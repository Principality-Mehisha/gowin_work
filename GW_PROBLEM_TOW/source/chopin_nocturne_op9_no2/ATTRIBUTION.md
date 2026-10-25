# Chopin Nocturne Op.9 No.2 source

- Composer: Frédéric Chopin; Nocturne in E-flat major, Op.9 No.2.
- MIDI / LilyPond engraving: Renato Biolcati Rinaldi, Mutopia Project.
- Edition identifier: Mutopia-2014/12/18-1590.
- Source edition: G. Schirmer, New York, 1881; scans from the Library of Congress.
- Source page: https://www.mutopiaproject.org/cgibin/piece-info.cgi?id=1590
- Files: https://www.mutopiaproject.org/ftp/ChopinFF/O9/chopin_nocturne_op9_n2/
- License: Creative Commons Attribution-ShareAlike 3.0 Unported, https://creativecommons.org/licenses/by-sa/3.0/
- Downloaded 2026-10-25 from the original Mutopia server.
- Original MIDI SHA256: `e202d3941ce5f26397f57f59f0e2e4e3ad9e19061fa3c4dc596c5ee6a6a2548e`.

The original `.mid`, `.ly`, and `.rdf` files are preserved here without changes.
`tools/make_clarinet_nocturne.py` derives a monophonic clarinet arrangement by
selecting the highest sounding voice in the upper staff, omitting the left hand
and lower chord tones, retaining note timing/repeated attacks, and transposing
the complete melody down one octave. This is an adaptation, not the original
piano score or a professional human clarinet transcription.

The resulting `sd_card/CLARINET.BIN`, `CLARINET.mid`, `CLARINET_NOTES.csv` and
the generated Nocturne audio preview are also distributed under CC BY-SA 3.0.
The license applies to these music assets and their source, independently of
the FPGA source code. The score BIN contains note events, not recorded audio.
