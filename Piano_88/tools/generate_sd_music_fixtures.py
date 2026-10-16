"""Build sparse FAT fixtures with intentionally fragmented directory/file chains."""
from __future__ import annotations

import io
import struct
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "output/sd_music_test"


def chunk(kind: bytes, payload: bytes) -> bytes:
    return kind + struct.pack("<I", len(payload)) + payload + b"\0" * (len(payload) & 1)


def make_wav() -> tuple[bytes, list[int]]:
    pcm = [((i * 97) % 20000) - 10000 for i in range(1025)]
    payload = b"WAVE" + chunk(b"JUNK", b"abc")
    payload += chunk(b"fmt ", struct.pack("<HHIIHHH", 1, 1, 16276, 32552, 2, 16, 0))
    payload += chunk(b"data", struct.pack(f"<{len(pcm)}h", *pcm))
    payload += chunk(b"LIST", b"test")
    return b"RIFF" + struct.pack("<I", len(payload)) + payload, pcm


def build(fat32: bool, wav: bytes, *, missing=False, broken=False) -> dict[int, bytearray]:
    sectors: dict[int, bytearray] = {}

    def sector(lba: int) -> bytearray:
        return sectors.setdefault(lba, bytearray(512))

    def u16(block: bytearray, offset: int, value: int) -> None:
        struct.pack_into("<H", block, offset, value)

    def u32(block: bytearray, offset: int, value: int) -> None:
        struct.pack_into("<I", block, offset, value)

    base = 8 if fat32 else 0
    reserved, fat_length, spc = (32, 513, 1) if fat32 else (1, 20, 2)
    root_count = 0 if fat32 else 32
    root_lba = base + reserved + fat_length * 2
    data_lba = root_lba + (root_count + 15) // 16
    boot = sector(base)
    boot[0:3] = b"\xeb\x3c\x90"
    boot[3:11] = b"TESTFAT "
    u16(boot, 11, 512)
    boot[13] = spc
    u16(boot, 14, reserved)
    boot[16] = 2
    u16(boot, 17, root_count)
    boot[21] = 0xF8
    boot[510:512] = b"\x55\xaa"
    if fat32:
        u32(boot, 32, reserved + fat_length * 2 + 65530)
        u32(boot, 36, fat_length)
        u16(boot, 40, 0x81)  # Mirroring off; active FAT is the second copy.
        u32(boot, 44, 2)
        mbr = sector(0)
        mbr[446 + 4] = 0x83
        mbr[462 + 4] = 0x0C
        u32(mbr, 462 + 8, base)
        u32(mbr, 462 + 12, reserved + fat_length * 2 + 65530)
        mbr[510:512] = b"\x55\xaa"
    else:
        u16(boot, 19, 10000)
        u16(boot, 22, fat_length)

    def cluster_lba(number: int) -> int:
        return data_lba + (number - 2) * spc

    fat_base = base + reserved + (fat_length if fat32 else 0)

    def fat_entry(number: int, value: int) -> None:
        offset = number * (4 if fat32 else 2)
        block = sector(fat_base + offset // 512)
        (u32 if fat32 else u16)(block, offset % 512, value)

    eoc = 0x0FFFFFFF if fat32 else 0xFFFF
    fat_entry(0, 0x0FFFFFF8 if fat32 else 0xFFF8)
    fat_entry(1, eoc)
    if fat32:
        fat_entry(2, 9)
        fat_entry(9, eoc)
        first_dir = sector(cluster_lba(2))
        target_dir = sector(cluster_lba(9))
        chain = [3, 7, 4, 12, 5]
    else:
        first_dir = sector(root_lba)
        target_dir = sector(root_lba + 1)
        chain = [3, 8, 4]
    for entry in range(16):
        first_dir[entry * 32] = 0xE5
    # An apparent filename with LFN attributes must not be selected.
    target_dir[0:11] = b"MUSIC   WAV"
    target_dir[11] = 0x0F
    entry = 32
    if missing:
        target_dir[entry] = 0
    else:
        target_dir[entry:entry + 11] = b"MUSIC   WAV"
        target_dir[entry + 11] = 0x20
        u16(target_dir, entry + 26, chain[0])
        u32(target_dir, entry + 28, len(wav))
    for index, number in enumerate(chain):
        fat_entry(number, eoc if broken or index == len(chain) - 1 else chain[index + 1])
    remaining = wav
    for number in chain:
        for within in range(spc):
            block = sector(cluster_lba(number) + within)
            payload = remaining[:512]
            block[:len(payload)] = payload
            remaining = remaining[512:]
    assert not remaining
    return sectors


def save_hex(path: Path, sectors: dict[int, bytearray]) -> None:
    lines = []
    for lba, block in sorted(sectors.items()):
        lines.append(f"@{lba * 512:08X}")
        lines.extend(" ".join(f"{v:02X}" for v in block[i:i + 16])
                     for i in range(0, 512, 16))
    path.write_text("\n".join(lines) + "\n", encoding="ascii")


def save_full_fat32(wav: bytes) -> None:
    # 8 sectors/cluster, fragmented file spanning many FAT sectors.
    base, reserved, fat_length, spc = 8, 32, 1024, 8
    data_base = base + reserved + fat_length * 2
    clusters = (len(wav) + spc * 512 - 1) // (spc * 512)
    chain = [10 + index * 2 for index in range(clusters)]
    chain[1::2] = reversed(chain[1::2])
    with (OUT / "full_fat32.img").open("wb") as output:
        def put(lba: int, payload: bytes) -> None:
            output.seek(lba * 512)
            output.write(payload)

        mbr = bytearray(512)
        mbr[446 + 4] = 0x0C
        struct.pack_into("<II", mbr, 446 + 8, base, 1_000_000)
        mbr[510:] = b"\x55\xaa"
        put(0, mbr)
        boot = bytearray(512)
        boot[:3] = b"\xeb\x58\x90"
        struct.pack_into("<H", boot, 11, 512)
        boot[13] = spc
        struct.pack_into("<H", boot, 14, reserved)
        boot[16] = 2
        struct.pack_into("<I", boot, 32, 1_000_000)
        struct.pack_into("<I", boot, 36, fat_length)
        struct.pack_into("<I", boot, 44, 2)
        boot[510:] = b"\x55\xaa"
        put(base, boot)
        fat = bytearray(fat_length * 512)
        struct.pack_into("<III", fat, 0, 0x0FFFFFF8, 0x0FFFFFFF, 0x0FFFFFFF)
        for index, cluster in enumerate(chain):
            next_cluster = chain[index + 1] if index + 1 < len(chain) else 0x0FFFFFFF
            struct.pack_into("<I", fat, cluster * 4, next_cluster)
        put(base + reserved, fat)
        put(base + reserved + fat_length, fat)
        root = bytearray(spc * 512)
        root[:11] = b"MUSIC   WAV"
        root[11] = 0x20
        struct.pack_into("<H", root, 26, chain[0])
        struct.pack_into("<I", root, 28, len(wav))
        put(data_base, root)
        for index, cluster in enumerate(chain):
            data = wav[index * spc * 512:(index + 1) * spc * 512]
            put(data_base + (cluster - 2) * spc, data.ljust(spc * 512, b"\0"))
    print(f"Generated full-length FAT32 fixture: {len(wav)} bytes in {clusters} fragmented clusters.")


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    wav, pcm = make_wav()
    for fat32 in (False, True):
        save_hex(OUT / ("fat32.hex" if fat32 else "fat16.hex"), build(fat32, wav))
    save_hex(OUT / "missing.hex", build(False, wav, missing=True))
    save_hex(OUT / "broken.hex", build(False, wav, broken=True))
    (OUT / "expected.hex").write_text(
        "\n".join(f"{value & 65535:04X}" for value in pcm) + "\n", encoding="ascii")
    with wave.open(io.BytesIO(wav)) as source:
        assert source.getnframes() == len(pcm)
        assert source.readframes(len(pcm)) == struct.pack(f"<{len(pcm)}h", *pcm)
    print(f"Generated fragmented FAT16/FAT32 fixtures, {len(wav)} WAV bytes, {len(pcm)} samples.")
    music_path = ROOT / "sd_card/music/MUSIC.WAV"
    actual = music_path.read_bytes()
    save_full_fat32(actual)
    with wave.open(str(music_path)) as source:
        frames = source.getnframes()
        actual_pcm = struct.unpack(f"<{frames}h", source.readframes(frames))
    (OUT / "music_bytes.hex").write_text(
        "\n".join(f"{value:02X}" for value in actual) + "\n", encoding="ascii")
    (OUT / "music_expected.hex").write_text(
        "\n".join(f"{value & 65535:04X}" for value in actual_pcm) + "\n", encoding="ascii")
    (OUT / "music_test_params.vh").write_text(
        f"`define MUSIC_BYTES {len(actual)}\n`define MUSIC_FRAMES {frames}\n", encoding="ascii")
    print(f"Generated actual MUSIC.WAV parser vectors: {frames} samples.")


if __name__ == "__main__":
    main()
