# Complete Piano Music

`MUSIC.WAV` is the complete piano MIDI arrangement of **Croatian Rhapsody**
uploaded by **Aemisiya** to Musical Nexus on November 18, 2018.
It is an offline rendering of that piano arrangement, not Maksim Mrvica's commercial recording.

- Arrangement page: https://musicalnexus.net/games/ms2/songs/maksim-mrvica-croatian-rhapsody-r1430
- Public MIDI export: https://musicalnexus.net/songs/1430/download/midi
- Retrieved October 16, 2026.
- Original MIDI saved as `source/croatian_rhapsody_aemisiya.mid`.
- MIDI SHA256: `f2478d9054e6f560546cc2a92b5f29a751697ca8de556f0d8e4d08f836d13b25`.
- MIDI duration: 201.20625 seconds; 1860 note events; General MIDI acoustic piano.

The audio uses this project's existing VSCO2/tonejs recorded piano samples,
with offline transposition, velocity mixing, note release envelopes and quiet room reflections.
Sample credits and the CC BY 3.0 license are preserved in
[`Piano_88/assets/ATTRIBUTION.md`](../../assets/ATTRIBUTION.md) and
[`Piano_88/assets/piano/LICENSE.md`](../../assets/piano/LICENSE.md).
The sample license describes the instrument samples, not the composition or MIDI arrangement.
The MIDI page does not state a separate redistribution license.

`tools/render_full_piano.py` renders the complete MIDI with a two-second tail.
`tools/prepare_sd_music.py` produces the final playback file:

- Duration: 203.206254608 seconds, approximately 3:23.
- PCM16 little endian mono, 16276 Hz.
- 3307385 frames, 6614814 file bytes.
- SHA256: `7e8ada64be4b7b141685ca73fbe919fb79ea62d659688f0acd80f826eb2a1d2d`.

The original 14-second preview is retained as `opening_excerpt.wav`;
it is not the file copied to the card for complete playback.
