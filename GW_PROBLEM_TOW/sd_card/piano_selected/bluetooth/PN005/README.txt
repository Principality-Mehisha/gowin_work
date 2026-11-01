TARGET: PN005.BIN. The target is encoded in BEGIN, NOT inferred from the transport filename.
Use these two files as a matched pair; do not reuse BEGIN from a different score.
1. Send BEGIN.bin as RAW; wait for READY.
2. Within 30 seconds of READY, send PN005_DATA_END.bin as RAW; wait for final success.
Merged content: 25848 original score bytes + 10 END control bytes.
Do not send another score header, score file or END frame in this session.
READY HEX: 5A A5 02 01 00 00 00 00 00 00 08 2A
SUCCESS HEX: 5A A5 02 03 00 00 00 00 00 00 EB 4A
The merged file is a transport envelope, not a standalone score.
No COM port, physical card or disk image was opened by this tool.
