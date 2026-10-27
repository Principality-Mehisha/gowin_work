"""Independent pixel reference for the waterfall RTL (Pillow + NumPy)."""
from pathlib import Path
import argparse
import json
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]


def render(data, frame):
    frame %= data['loop_frames']
    image = np.full((900, 1600), 0x0b1020, dtype=np.uint32)
    image[0:716:128, :] = 0x152039
    for key in data['keys']:
        if not key['black']:
            image[:716, key['right']-2:key['right']] = 0x172137
    image[716:720, :] = 0x73d8ff
    lit = {note for t, d, note in data['events'] if t+180 <= frame < t+d+180}
    for key in data['keys']:
        if key['black']:
            continue
        left, right, note = key['left'], key['right'], key['note']
        color = (0x56dfff if note < 39 else 0xbb91ff) if note in lit else 0xeef2fa
        image[720:900, left:right] = color
        if note not in lit:
            image[888:900, left:right] = 0xb7bfce
        image[720:900, right-2:right] = 0x343d51
        if key['midi'] % 12 == 0:
            image[865:872, key['center']-2:key['center']+3] = 0x687893
    for key in data['keys']:
        if not key['black']:
            continue
        left, right, note = key['left'], key['right'], key['note']
        color = (0x22bbef if note < 39 else 0x9663e8) if note in lit else 0x121725
        image[720:826, left:right] = color
        if note not in lit:
            image[816:826, left:right] = 0x30394b
    # RTL priority: right-hand rectangles win over left-hand rectangles;
    # any interior within a hand wins over that hand's border.
    for right_hand in (False, True):
        edge_mask = np.zeros((720, 1600), dtype=bool)
        inner_mask = np.zeros_like(edge_mask)
        for start, duration, note in data['events']:
            if not start <= frame < start + duration + 180 or (note >= 39) != right_hand:
                continue
            key = data['keys'][note]
            half = 5 if key['black'] else 10
            left, right = key['center'] - half, key['center'] + half
            bottom = (frame - start) * 4
            top = bottom - duration * 4
            lo, hi = max(0, top), min(720, bottom)
            if lo < hi:
                edge_mask[lo:hi, left:right] = True
            lo, hi = max(0, top+2), min(720, bottom-2)
            if lo < hi:
                inner_mask[lo:hi, left+2:right-2] = True
        view = image[:720]
        view[edge_mask] = 0xd8bcff if right_hand else 0x9aeaff
        view[inner_mask] = 0x9964ed if right_hand else 0x25b9e8
    rgb = np.stack(((image >> 16) & 255, (image >> 8) & 255, image & 255), axis=-1).astype('uint8')
    return image, Image.fromarray(rgb)


BLACK = {1,3,6,8,10}
def keyboard():
    keys, white = [], 0
    for pitch in range(21, 109):
        black = pitch % 12 in BLACK
        center = 20 + white * 30 if black else 35 + white * 30
        width = 18 if black else 30
        keys.append(dict(note=pitch - 21, midi=pitch, black=black,
                         left=center - width // 2, right=center + width // 2,
                         center=center))
        white += not black
    assert white == 52 and sum(k['black'] for k in keys) == 36
    return keys

