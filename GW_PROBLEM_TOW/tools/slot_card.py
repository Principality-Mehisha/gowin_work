"""Offline FAT32 image builder for 200 preallocated 100 KiB score files.

This tool accepts regular .img files only. It never opens a physical disk.
The MBR gap contains the checked layout descriptor and per-slot validity records.
"""
from __future__ import annotations

import argparse
from dataclasses import dataclass
import json
import os
from pathlib import Path
import stat
import struct
import zlib

SECTOR = 512
SLOTS = 200
SLOT_BYTES = 100 * 1024
SLOT_SECTORS = SLOT_BYTES // SECTOR
STRIDE = 256
PARTITION = 2048
RESERVED = 32
SPC = 64
META_BASE = 8
LAYOUT_MAGIC = b"GW100K02"
META_MAGIC = b"GWSLOT02"
VALID = 0xA55AA55A
ROOT = Path(__file__).resolve().parents[1]


def slot_index(instrument: str, number: int) -> int:
    if instrument not in ("piano", "marimba") or not 1 <= number <= 100:
        raise ValueError("Expected piano/marimba and number 1..100")
    return number - 1 + (100 if instrument == "marimba" else 0)


def slot_name(index: int) -> bytes:
    if not 0 <= index < SLOTS:
        raise ValueError("Slot out of range")
    return f"{'PN' if index < 100 else 'MB'}{index % 100 + 1:03}   BIN".encode("ascii")


@dataclass(frozen=True)
class Layout:
    total_sectors: int
    fat_sectors: int
    clusters: int
    data_base: int

    @property
    def slot_base(self):
        return self.data_base + SPC

    @property
    def partition_sectors(self):
        return self.total_sectors - PARTITION

    def lba(self, index):
        if not 0 <= index < SLOTS:
            raise ValueError("Slot out of range")
        return self.slot_base + index * STRIDE


def layout_for_size(size_bytes: int) -> Layout:
    if size_bytes % SECTOR or size_bytes // SECTOR > 0xFFFFFFFF:
        raise ValueError("Image must fit a 32-bit sector address and be sector aligned")
    total = size_bytes // SECTOR
    partition = total - PARTITION
    denominator = 128 * SPC + 2
    fat = (partition - RESERVED + 2 * SPC + denominator - 1) // denominator
    data = PARTITION + RESERVED + 2 * fat
    clusters = (total - data) // SPC
    if not 65525 <= clusters < 0x0FFFFFF0 or clusters + 2 > fat * 128:
        raise ValueError("Use an image of at least 2050 MiB for this FAT32 layout")
    return Layout(total, fat, clusters, data)


def descriptor(layout: Layout) -> bytes:
    body = struct.pack(
        "<8s13I", LAYOUT_MAGIC, 2, SECTOR, SLOTS, SLOT_BYTES, STRIDE, PARTITION,
        layout.partition_sectors, layout.data_base, layout.slot_base,
        META_BASE, 2, SPC, 0,
    )
    assert len(body) == 60
    return (body + struct.pack("<I", zlib.crc32(body))).ljust(SECTOR, b"\0")


def metadata(index: int, data: bytes) -> bytes:
    if not 0 <= index < SLOTS or not 24 <= len(data) <= SLOT_BYTES:
        raise ValueError("Invalid slot payload")
    body = struct.pack("<8s5I", META_MAGIC, 2, index, len(data), zlib.crc32(data), VALID)
    return (body + struct.pack("<I", zlib.crc32(body))).ljust(SECTOR, b"\0")


def decode_metadata(index: int, block: bytes):
    if len(block) != SECTOR:
        raise ValueError("Short metadata sector")
    magic, version, stored_index, length, checksum, valid, record_crc = struct.unpack_from("<8s6I", block)
    if (magic, version, stored_index, valid) != (META_MAGIC, 2, index, VALID):
        return None
    if not 24 <= length <= SLOT_BYTES or length % 8 or zlib.crc32(block[:28]) != record_crc:
        return None
    return length, checksum


def directory_entry(name: bytes, cluster: int, length: int, attributes=0x20) -> bytes:
    if len(name) != 11:
        raise ValueError("Expected an 8.3 directory name")
    result = bytearray(32)
    result[:11] = name
    result[11] = attributes
    for offset in (16, 18, 24):
        struct.pack_into("<H", result, offset, 0x21)  # 1980-01-01.
    struct.pack_into("<H", result, 20, cluster >> 16)
    struct.pack_into("<HI", result, 26, cluster & 65535, length)
    return bytes(result)


def image_sectors(layout: Layout, legacy=True) -> dict[int, bytes]:
    sectors = {}
    mbr = bytearray(SECTOR)
    struct.pack_into("<I", mbr, 440, 0x47575332)
    mbr[446:454] = b"\x00\xfe\xff\xff\x0c\xfe\xff\xff"
    struct.pack_into("<II", mbr, 454, PARTITION, layout.partition_sectors)
    mbr[510:] = b"\x55\xaa"
    sectors[0] = bytes(mbr)
    sectors[1] = descriptor(layout)
    boot = bytearray(SECTOR)
    boot[:11] = b"\xeb\x58\x90GWINSLOT"
    struct.pack_into("<HBHBHHBHHHII", boot, 11, SECTOR, SPC, RESERVED, 2, 0, 0,
                     0xF8, 0, 63, 255, PARTITION, layout.partition_sectors)
    struct.pack_into("<IHHIHH", boot, 36, layout.fat_sectors, 0, 0, 2, 1, 6)
    boot[64] = 0x80
    boot[66] = 0x29
    struct.pack_into("<I", boot, 67, 0x47575332)
    boot[71:82] = b"GOWIN SLOTS"
    boot[82:90] = b"FAT32   "
    boot[510:] = b"\x55\xaa"
    sectors[PARTITION] = sectors[PARTITION + 6] = bytes(boot)
    # Only the used prefix needs materializing in an initially zero sparse image.
    fat = bytearray(8192)
    struct.pack_into("<III", fat, 0, 0x0FFFFFF8, 0x0FFFFFFF, 0x0FFFFFFF)
    directory = bytearray(SPC * SECTOR)
    for index in range(SLOTS):
        first = 3 + index * 4
        for offset in range(4):
            struct.pack_into("<I", fat, (first + offset) * 4,
                             first + offset + 1 if offset != 3 else 0x0FFFFFFF)
        directory[index * 32:(index + 1) * 32] = directory_entry(slot_name(index), first, SLOT_BYTES)
    next_cluster = 803
    if legacy:
        for entry_index, name in enumerate(("ANDROID.BIN", "RINGTONE.BIN", "PIANO.BIN"), SLOTS):
            data = (ROOT / "sd_card" / name).read_bytes()
            count = (len(data) + SPC * SECTOR - 1) // (SPC * SECTOR)
            short = name.split(".")[0].ljust(8).encode() + b"BIN"
            directory[entry_index * 32:(entry_index + 1) * 32] = directory_entry(short, next_cluster, len(data))
            for offset in range(count):
                struct.pack_into("<I", fat, (next_cluster + offset) * 4,
                                 next_cluster + offset + 1 if offset + 1 < count else 0x0FFFFFFF)
            base = layout.data_base + (next_cluster - 2) * SPC
            for offset in range(0, len(data), SECTOR):
                sectors[base + offset // SECTOR] = data[offset:offset + SECTOR].ljust(SECTOR, b"\0")
            next_cluster += count
    for offset in range(0, len(fat), SECTOR):
        block = bytes(fat[offset:offset + SECTOR])
        if any(block):
            sectors[PARTITION + RESERVED + offset // SECTOR] = block
            sectors[PARTITION + RESERVED + layout.fat_sectors + offset // SECTOR] = block
    for offset in range(0, len(directory), SECTOR):
        block = bytes(directory[offset:offset + SECTOR])
        if any(block):
            sectors[layout.data_base + offset // SECTOR] = block
    info = bytearray(SECTOR)
    struct.pack_into("<I", info, 0, 0x41615252)
    struct.pack_into("<I", info, 484, 0x61417272)
    struct.pack_into("<II", info, 488, layout.clusters - (next_cluster - 2), next_cluster)
    struct.pack_into("<I", info, 508, 0xAA550000)
    sectors[PARTITION + 1] = sectors[PARTITION + 7] = bytes(info)
    return sectors


def regular_image(path: Path):
    if str(path).startswith(("\\\\.\\", "\\\\?\\")) or path.suffix.lower() != ".img":
        raise ValueError("Only regular .img files are accepted; physical disks are forbidden")
    if path.exists() and not stat.S_ISREG(path.stat().st_mode):
        raise ValueError("Not a regular file")


def mark_sparse(file):
    if os.name == "nt":
        import ctypes
        import msvcrt
        returned = ctypes.c_ulong()
        handle = ctypes.c_void_p(msvcrt.get_osfhandle(file.fileno()))
        if not ctypes.windll.kernel32.DeviceIoControl(
            handle, 0x900C4, None, 0, None, 0, ctypes.byref(returned), None
        ):
            raise OSError("Filesystem cannot create a sparse image; use an NTFS destination")


def create_image(path: Path, size_mib=30000, *, legacy=True, replace=False) -> Layout:
    regular_image(path)
    layout = layout_for_size(size_mib * 1024 * 1024)
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w+b" if replace else "x+b") as file:
        mark_sparse(file)
        file.truncate(layout.total_sectors * SECTOR)
        for lba, block in image_sectors(layout, legacy).items():
            file.seek(lba * SECTOR)
            file.write(block)
        file.flush()
    return layout


def read_layout(file) -> Layout:
    file.seek(SECTOR)
    block = file.read(SECTOR)
    if len(block) != SECTOR or block[:8] != LAYOUT_MAGIC or zlib.crc32(block[:60]) != struct.unpack_from("<I", block, 60)[0]:
        raise ValueError("Not a prepared fixed-slot image")
    fields = struct.unpack_from("<13I", block, 8)
    layout = layout_for_size((fields[6] + PARTITION) * SECTOR)
    if block != descriptor(layout):
        raise ValueError("Layout constants or geometry mismatch")
    return layout


def verify_file(file, layout: Layout, index: int):
    file.seek(layout.data_base * SECTOR + index * 32)
    entry = file.read(32)
    first = struct.unpack_from("<H", entry, 26)[0] | struct.unpack_from("<H", entry, 20)[0] << 16
    if entry[:11] != slot_name(index) or entry[11] & 0x19 or first != 3 + index * 4 or struct.unpack_from("<I", entry, 28)[0] != SLOT_BYTES:
        raise ValueError(f"Slot {index} file was moved, renamed, resized or protected")
    for copy in range(2):
        for offset in range(4):
            file.seek((PARTITION + RESERVED + copy * layout.fat_sectors) * SECTOR + (first + offset) * 4)
            value = struct.unpack("<I", file.read(4))[0] & 0x0FFFFFFF
            if value != (first + offset + 1 if offset != 3 else 0x0FFFFFFF):
                raise ValueError(f"Slot {index} FAT chain changed")


def write_slot(path: Path, index: int, data: bytes):
    regular_image(path)
    from bluetooth_upload import validate_score
    validate_score(data, "piano" if index < 100 else "marimba")
    with path.open("r+b") as file:
        layout = read_layout(file)
        verify_file(file, layout, index)
        file.seek((META_BASE + index) * SECTOR)
        file.write(bytes(SECTOR))
        file.seek(layout.lba(index) * SECTOR)
        file.write(bytes(SLOT_BYTES))
        file.seek(layout.lba(index) * SECTOR)
        file.write(data)
        file.seek((META_BASE + index) * SECTOR)
        file.write(metadata(index, data))
        file.flush()


def inspect_image(path: Path):
    regular_image(path)
    with path.open("rb") as file:
        layout = read_layout(file)
        valid = []
        for index in range(SLOTS):
            verify_file(file, layout, index)
            file.seek((META_BASE + index) * SECTOR)
            record = decode_metadata(index, file.read(SECTOR))
            if record:
                length, checksum = record
                file.seek(layout.lba(index) * SECTOR)
                if zlib.crc32(file.read(length)) != checksum:
                    raise ValueError(f"Slot {index} payload CRC mismatch")
                valid.append(slot_name(index).decode().strip())
    return {"image_bytes": layout.total_sectors * SECTOR, "slot_bytes": SLOT_BYTES,
            "slot_count": SLOTS, "allocated_stride_bytes": STRIDE * SECTOR, "valid_slots": valid}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--image", type=Path, required=True)
    parser.add_argument("--size-mib", type=int, default=30000)
    parser.add_argument("--initialize", action="store_true", help="Create a new sparse image; never a physical SD card")
    parser.add_argument("--replace", action="store_true", help="Explicitly overwrite an existing image")
    args = parser.parse_args()
    if args.initialize:
        create_image(args.image, args.size_mib, replace=args.replace)
    print(json.dumps(inspect_image(args.image), indent=2))
    print("No physical disk was opened. Flashing this image later will replace the target card's contents.")


if __name__ == "__main__":
    main()
