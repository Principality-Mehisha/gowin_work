"""Read the P88S v1 event stream used by GW_PROBLEM_TOW, without MIDI/audio inference."""
from __future__ import annotations

import hashlib
import struct
from pathlib import Path


def frame_at_ms(milliseconds: int) -> int:
    return (milliseconds * 60 + 500) // 1000


def read_p88s(path: Path):
    data = path.read_bytes()
    if len(data) < 24:
        raise ValueError('P88S file is shorter than its header and terminal event')
    magic, version, size, voices, reserved, rate, count = struct.unpack_from('<4sBBBBII', data)
    if (magic, version, size, voices, reserved, rate) != (b'P88S', 1, 8, 8, 0, 1000):
        raise ValueError('Expected P88S v1, 8-byte records, 8 voices, 1000 ticks/second')
    if not 1 <= count <= 20000 or len(data) != 16 + count * 8:
        raise ValueError('P88S event count/file size mismatch')
    active = {}
    notes = []
    last_time = 0
    peak = 0
    for index, record in enumerate(struct.iter_unpack('<IBBBB', data[16:])):
        timestamp, voice, note, velocity, padding = record
        if timestamp < last_time or padding:
            raise ValueError(f'Invalid timestamp/reserved byte at event {index}')
        last_time = timestamp
        if index == count - 1:
            if (voice, note, velocity) != (255, 255, 0):
                raise ValueError('Missing P88S terminal event')
            if active:
                raise ValueError('Terminal event contains unreleased voices')
            break
        if voice >= voices or note >= 88 or velocity >= 128:
            raise ValueError(f'Invalid voice/note/velocity at event {index}')
        if velocity:
            if voice in active:
                raise ValueError(f'Voice {voice} retriggered without note-off at event {index}')
            active[voice] = (timestamp, note, velocity)
            peak = max(peak, len(active))
        else:
            if voice not in active or active[voice][1] != note:
                raise ValueError(f'Unmatched note-off at event {index}')
            start, pitch, dynamics = active.pop(voice)
            if timestamp <= start:
                raise ValueError(f'Non-positive note duration at event {index}')
            notes.append(dict(start_ms=start, end_ms=timestamp, note=pitch,
                              velocity=dynamics, voice=voice))
    if not notes:
        raise ValueError('P88S score contains no notes')
    notes.sort(key=lambda item: (item['start_ms'], item['note'], item['end_ms'], item['voice']))
    events = sorted((frame_at_ms(n['start_ms']),
                     max(1, frame_at_ms(n['end_ms']) - frame_at_ms(n['start_ms'])),
                     n['note']) for n in notes)
    error = max(max(abs(t * 1000 / 60 - n['start_ms']),
                    abs((t + max(1, frame_at_ms(n['end_ms']) - t)) * 1000 / 60 - n['end_ms']))
                for n in notes for t in [frame_at_ms(n['start_ms'])])
    metadata = dict(format='P88S v1', path=str(path.resolve()),
                    sha256=hashlib.sha256(data).hexdigest(), bytes=len(data),
                    event_count=count, note_count=len(notes), duration_ms=last_time,
                    peak_polyphony=peak, used_keys=len({n['note'] for n in notes}),
                    max_quantization_error_ms=round(error, 6), notes=notes)
    return events, metadata
