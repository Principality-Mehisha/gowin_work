"""Protocol-v2 and FAT32 image tests; never open a serial or physical disk."""
import binascii
from contextlib import redirect_stdout
from io import StringIO
from pathlib import Path
import struct
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
from bluetooth_upload import decode_reply, exchange, load_score, packet, upload, validate_score
from slot_card import (SLOT_BYTES, create_image, decode_metadata, descriptor, image_sectors,
                       inspect_image, layout_for_size, metadata, regular_image, slot_name, write_slot)


def reply(operation, status=0, detail=0):
    body = struct.pack("<2sBBHBBH", b"\x5a\xa5", 2, operation, 0, status, detail, 0)
    return body + struct.pack("<H", binascii.crc_hqx(body, 0))


def tiny_score():
    return struct.pack("<4sBBBBII", b"P88S", 1, 8, 8, 0, 1000, 1) + struct.pack("<IBBBB", 0, 255, 255, 0, 0)


class FakePort:
    def __init__(self, responses):
        self.responses = list(responses)
        self.buffer = bytearray()
        self.requests = []

    def write(self, data):
        self.requests.append(data)
        if self.responses:
            self.buffer.extend(self.responses.pop(0))
        return len(data)

    def read(self, count):
        result = bytes(self.buffer[:count])
        del self.buffer[:count]
        return result

    def flush(self):
        pass


class ProtocolTests(unittest.TestCase):
    def test_control_packet_and_crc(self):
        self.assertEqual(binascii.crc_hqx(b"123456789", 0), 0x31C3)
        encoded = packet(1, 0, bytes(range(10)))
        self.assertEqual(encoded[:8], b"\xa5\x5a\x02\x01\x00\x00\x0a\x00")
        self.assertEqual(struct.unpack("<H", encoded[-2:])[0], binascii.crc_hqx(encoded[:-2], 0))
        with self.assertRaises(ValueError):
            packet(2, 0, b"DATA")

    def test_reply_crc_and_old_version_rejection(self):
        self.assertEqual(decode_reply(reply(3)).status, 0)
        damaged = bytearray(reply(3))
        damaged[7] ^= 1
        with self.assertRaises(ValueError):
            decode_reply(damaged)
        with self.assertRaises(ValueError):
            decode_reply(b"\x5a\xa5\x01" + reply(3)[3:])

    def test_control_retransmit(self):
        port = FakePort([b"noise" + reply(1, 1), reply(1)])
        self.assertEqual(exchange(port, 1, 0, bytes(10), timeout=0.1).status, 0)
        self.assertEqual(port.requests[0], port.requests[1])

    def test_stream_has_no_data_packets_or_reads(self):
        data = tiny_score()
        port = FakePort([reply(1), b"", reply(3)])
        with redirect_stdout(StringIO()):
            upload(port, data, "piano", 1)
        self.assertEqual(len(port.requests), 3)
        self.assertEqual(port.requests[1], data)
        self.assertEqual(port.requests[0][3], 1)
        self.assertEqual(port.requests[2][3], 3)

    def test_fifo_failure_is_reported(self):
        with self.assertRaisesRegex(RuntimeError, "FIFO overflow"):
            exchange(FakePort([reply(3, 11)]), 3, 0, timeout=0.1)

    def test_partial_body_does_not_inject_cancel(self):
        class ShortPort(FakePort):
            def write(self, data):
                result = super().write(data)
                return result - 1 if len(self.requests) == 2 else result
        port = ShortPort([reply(1), b""])
        with redirect_stdout(StringIO()), self.assertRaises(OSError):
            upload(port, tiny_score(), "piano", 1)
        self.assertEqual(len(port.requests), 2)
        self.assertEqual(port.requests[-1], tiny_score())

    def test_real_scores_and_padding(self):
        root = Path(__file__).resolve().parents[1]
        piano = (root / "sd_card/PIANO.BIN").read_bytes()
        validate_score(piano, "piano")
        validate_score((root / "sd_card/ANDROID.BIN").read_bytes(), "marimba")
        with self.assertRaises(ValueError):
            validate_score(piano, "marimba")
        with tempfile.TemporaryDirectory() as directory:
            file = Path(directory) / "PN001.BIN"
            file.write_bytes(piano.ljust(SLOT_BYTES, b"\0"))
            self.assertEqual(load_score(file, "piano"), piano)


class ImageTests(unittest.TestCase):
    def test_geometry_and_names(self):
        layout = layout_for_size(30000 * 1024 * 1024)
        blocks = image_sectors(layout)
        self.assertEqual(len(descriptor(layout)), 512)
        self.assertEqual(layout.slot_base, layout.data_base + 64)
        for index in range(200):
            block = blocks[layout.data_base + index // 16]
            entry = block[index % 16 * 32:index % 16 * 32 + 32]
            self.assertEqual(entry[:11], slot_name(index))
            self.assertEqual(struct.unpack_from("<I", entry, 28)[0], SLOT_BYTES)
        self.assertEqual(slot_name(199), b"MB100   BIN")
        # End of directory directly after the 200 reserved entries.
        self.assertEqual(blocks[layout.data_base + 12][256:], bytes(256))
        self.assertEqual(struct.unpack_from("<I", blocks[2080 + 6], 803 * 4 % 512)[0], 0)

    def test_metadata_crc(self):
        block = metadata(199, tiny_score())
        self.assertEqual(decode_metadata(199, block)[0], 24)
        self.assertIsNone(decode_metadata(0, block))
        damaged = bytearray(block)
        damaged[20] ^= 1
        self.assertIsNone(decode_metadata(199, damaged))
        self.assertIsNone(decode_metadata(0, bytes(512)))

    def test_image_round_trip_and_moved_file_guard(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "card.img"
            layout = create_image(path, 3072)
            write_slot(path, 0, tiny_score())
            self.assertEqual(inspect_image(path)["valid_slots"], ["PN001   BIN"])
            with path.open("r+b") as file:
                file.seek(layout.data_base * 512 + 26)
                file.write(b"\x04\x00")
            with self.assertRaisesRegex(ValueError, "moved"):
                write_slot(path, 0, tiny_score())

    def test_no_physical_disk_or_accidental_overwrite(self):
        with self.assertRaises(ValueError):
            regular_image(Path(r"\\.\PhysicalDrive2"))
        with self.assertRaises(ValueError):
            layout_for_size(64 * 1024 * 1024)
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "card.img"
            path.write_bytes(b"user")
            with self.assertRaises(FileExistsError):
                create_image(path, 3072)
            self.assertEqual(path.read_bytes(), b"user")


if __name__ == "__main__":
    unittest.main()
