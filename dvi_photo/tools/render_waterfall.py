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


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--frame', type=int, default=200)
    parser.add_argument('--reference', action='store_true')
    parser.add_argument('--verify-rtl', action='store_true')
    parser.add_argument('--gif', action='store_true')
    args = parser.parse_args()
    data = json.loads((ROOT / 'sim/waterfall_reference.json').read_text())
    pixels, image = render(data, args.frame)
    image.save(ROOT / 'preview.png')
    if args.reference:
        with (ROOT / 'sim/expected_frame.hex').open('w') as f:
            for row in pixels:
                f.write(''.join(f'{int(p):06x}\n' for p in row))
    if args.verify_rtl:
        actual = np.array(Image.open(ROOT / 'sim/waterfall_rtl.ppm'))
        expected = np.array(image)
        if not np.array_equal(actual, expected):
            mismatch = np.any(actual != expected, axis=-1)
            y, x = np.argwhere(mismatch)[0]
            raise AssertionError(f'{mismatch.sum()} pixels differ; first at ({x},{y})')
        Image.fromarray(actual).save(ROOT / 'preview.png')
        print('PASS: 1,440,000 RTL pixels match the independent reference')
    if args.gif:
        frames = [render(data, f)[1].resize((1000, 562)) for f in range(80, 360, 5)]
        frames[0].save(ROOT / 'waterfall_preview.gif', save_all=True, append_images=frames[1:],
                       duration=83, loop=0)
    print(ROOT / 'preview.png')


if __name__ == '__main__':
    main()
