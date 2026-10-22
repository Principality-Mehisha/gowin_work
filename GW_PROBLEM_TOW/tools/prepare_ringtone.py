"""Prepare the experimental stereo ringtone ROM and PCM listening references.

Dependencies (local to this project):
  python -m pip install --target output/audio_tools --no-deps scipy imageio-ffmpeg
The MP3 is only a listening reference; it is not input to the modal synth.
"""
from fractions import Fraction
import hashlib
import json
from pathlib import Path
import struct
import subprocess
import sys
import wave

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "output/audio_tools"))
import imageio_ffmpeg
import numpy as np
from scipy.signal import resample_poly

ASSETS = ROOT / "assets/ringtone"
ROM = ROOT / "src/rom"
SOURCE = ASSETS / "apple_marimba_2007.mp3"
FS = Fraction(50_000_000, 3072)
BANK_SIZE = 32768


def ffmpeg(*args):
    return subprocess.check_output([
        imageio_ffmpeg.get_ffmpeg_exe(), "-v", "error", "-y", *map(str, args)])


def write_wav(path, audio, rate):
    with wave.open(str(path), "wb") as output:
        output.setnchannels(2)
        output.setsampwidth(2)
        output.setframerate(rate)
        output.writeframes(np.asarray(audio, dtype="<i2").tobytes())


def wav_chunks(data):
    assert data[:4] == b"RIFF" and data[8:12] == b"WAVE"
    chunks = {}
    position = 12
    while position + 8 <= len(data):
        key, size = struct.unpack_from("<4sI", data, position)
        chunks[key] = data[position + 8 : position + 8 + size]
        position += 8 + size + (size & 1)
    return chunks


def main():
    ASSETS.mkdir(exist_ok=True)
    ROM.mkdir(exist_ok=True)
    source = np.frombuffer(ffmpeg(
        "-i", SOURCE, "-ar", 44100, "-ac", 2,
        "-f", "f32le", "-acodec", "pcm_f32le", "pipe:1"), dtype="<f4").reshape(-1, 2)
    original = np.clip(np.rint(source.astype(float) * 32768), -32768, 32767).astype("<i2")
    write_wav(ASSETS / "apple_marimba_pcm_44100.wav", original, 44100)
    ratio = FS / 44100
    target = resample_poly(source.astype(float), ratio.numerator, ratio.denominator,
                           axis=0, window=("kaiser", 8.6))
    # Retain the full clip; a short boundary fade prevents hard file edges.
    fade = min(round(float(FS) * .003), len(target) // 2)
    target[:fade] *= np.linspace(0, 1, fade)[:, None]
    target[-fade:] *= np.linspace(1, 0, fade)[:, None]
    pcm = np.clip(np.rint(target * 32768), -32768, 32767).astype("<i2")
    pcm_path = ASSETS / "apple_marimba_pcm_board.wav"
    write_wav(pcm_path, pcm, round(float(FS)))
    (ASSETS / "apple_marimba_stereo_s16le.pcm").write_bytes(pcm.tobytes())
    packed_path = ASSETS / "apple_marimba_ima.wav"
    ffmpeg("-i", pcm_path, "-c:a", "adpcm_ima_wav", "-block_size", 1024,
           packed_path)
    chunks = wav_chunks(packed_path.read_bytes())
    tag, channels, rate, _, align, bits = struct.unpack_from("<HHIIHH", chunks[b"fmt "])
    block_frames = struct.unpack_from("<H", chunks[b"fmt "], 18)[0]
    assert (tag, channels, align, bits) == (17, 2, 1024, 4)
    stream = bytearray()
    headers = []
    payload = chunks[b"data"]
    for offset in range(0, len(payload), align):
        block = payload[offset:offset + align]
        assert len(block) == align
        left, li, _, right, ri, _ = struct.unpack_from("<hBBhBB", block)
        assert li <= 88 and ri <= 88
        headers.append(((ri << 16 | (right & 65535)) << 24) |
                       (li << 16 | (left & 65535)))
        stream.append(0)  # The block's first sample comes from its header.
        for group in range(8, align, 8):
            for nibble in range(8):
                left_code = block[group + nibble // 2] >> ((nibble % 2) * 4) & 15
                right_code = block[group + 4 + nibble // 2] >> ((nibble % 2) * 4) & 15
                stream.append(left_code | right_code << 4)
    assert len(stream) == len(headers) * block_frames
    stream = stream[:len(pcm)]
    banks = (len(stream) + BANK_SIZE - 1) // BANK_SIZE
    for bank in range(banks):
        data = stream[bank * BANK_SIZE:(bank + 1) * BANK_SIZE]
        data += bytes(BANK_SIZE - len(data))
        (ROM / f"ringtone_bank{bank}.hex").write_text(
            "".join(f"{value:02x}\n" for value in data), encoding="ascii")
    (ROM / "ringtone_headers.hex").write_text(
        "".join(f"{value:012x}\n" for value in headers), encoding="ascii")
    # Decoder lookup values from the IMA reference format (also used by FFmpeg).
    steps = [7,8,9,10,11,12,13,14,16,17,19,21,23,25,28,31,34,37,41,45,
             50,55,60,66,73,80,88,97,107,118,130,143,157,173,190,209,230,
             253,279,307,337,371,408,449,494,544,598,658,724,796,876,963,
             1060,1166,1282,1411,1552,1707,1878,2066,2272,2499,2749,3024,
             3327,3660,4026,4428,4871,5358,5894,6484,7132,7845,8630,9493,
             10442,11487,12635,13899,15289,16818,18500,20350,22385,24623,
             27086,29794,32767]
    (ROM / "ima_steps.hex").write_text(
        "".join(f"{value:04x}\n" for value in steps), encoding="ascii")
    decoded = np.frombuffer(ffmpeg("-i", packed_path, "-f", "s16le",
                                   "-acodec", "pcm_s16le", "pipe:1"),
                            dtype="<i2").reshape(-1, 2)[:len(pcm)].copy()
    assert len(decoded) == len(pcm)
    # Zero endpoints at playback; the two boundary samples are not audible data.
    decoded[0] = 0
    decoded[-1] = 0
    write_wav(ASSETS / "apple_marimba_board_decoded.wav", decoded, rate)
    # FFmpeg's independent decoder is the whole-clip RTL test oracle.
    (ROOT / "sim/ringtone_expected.hex").write_text(
        "".join(f"{int(l) & 65535:04x}{int(r) & 65535:04x}\n" for l, r in decoded),
        encoding="ascii")
    config = ("// Generated by tools/prepare_ringtone.py.\n"
              f"`define RINGTONE_FRAMES {len(pcm)}\n"
              f"`define RINGTONE_BLOCK_FRAMES {block_frames}\n"
              f"`define RINGTONE_HEADER_COUNT {len(headers)}\n"
              f"`define RINGTONE_BANK_COUNT {banks}\n")
    (ROOT / "src/ringtone_config.vh").write_text(config, encoding="ascii")
    error = decoded.astype(float) - pcm.astype(float)
    snr = 10 * np.log10(np.sum(pcm.astype(float) ** 2) / np.sum(error ** 2))
    report = {
        "source_url": "https://raw.githubusercontent.com/w3teal/awesome-ringtone/main/Apple/2007%20-%20Marimba.mp3",
        "source_sha256": hashlib.sha256(SOURCE.read_bytes()).hexdigest(),
        "source_format": "MP3 stereo 44100 Hz; decoded PCM is not a lossless original recording",
        "source_frames": len(source), "source_rate": 44100,
        "source_duration_seconds": len(source) / 44100,
        "hardware_sample_rate": float(FS), "wav_header_rate": rate,
        "output_frames": len(pcm), "output_channels": 2,
        "output_duration_seconds": len(pcm) / float(FS),
        "storage": "IMA ADPCM, 4 bits per channel per frame, block headers separate",
        "storage_rom_banks": banks, "storage_bytes_padded": banks * BANK_SIZE + len(headers) * 6,
        "block_frames": block_frames, "header_count": len(headers),
        "adpcm_snr_db": float(snr), "decoded_peak": int(np.abs(decoded.astype(int)).max()),
        "anti_alias_resampling": "scipy.signal.resample_poly, Kaiser beta=8.6, exact rational rate",
        "boundary_fade_ms": 3,
    }
    (ASSETS / "conversion_report.json").write_text(json.dumps(report, indent=2), encoding="ascii")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
