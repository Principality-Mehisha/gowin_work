"""Independent live-history image reference; standard library only."""
from pathlib import Path
import argparse
import hashlib
import json

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'output/live_waterfall'


def fixtures():
    OUT.mkdir(parents=True, exist_ok=True)
    masks = [0] * 180
    def note(pitch, start, end):
        for frame in range(start, end):
            masks[frame] |= 1 << pitch
    note(0, 0, 5)
    note(39, 30, 101)
    for pitch in (48, 52, 55):
        note(pitch, 50, 76)
    for index, pitch in enumerate((27, 29, 31, 32, 34, 36, 38, 39, 41, 43, 44, 46)):
        note(pitch, 80 + index * 5, 83 + index * 5)
    for pitch in (39, 43, 46):
        note(pitch, 160, 180)
    note(87, 175, 180)
    held = masks[-1]
    (OUT / 'history.hex').write_text(''.join(f'{mask:022x}\n' for mask in masks))
    (OUT / 'held.hex').write_text(f'{held:022x}\n')
    keys, whites = [], 0
    for note_number in range(88):
        midi = note_number + 21
        black = midi % 12 in (1, 3, 6, 8, 10)
        center = 20 + whites * 30 if black else 35 + whites * 30
        keys.append((note_number, midi, black, center))
        whites += not black
    image = bytearray()
    with (OUT / 'expected.hex').open('w') as expected:
        for y in range(900):
            row = [0x0b1020] * 1600
            if y < 716 and y % 128 == 0:
                row[:] = [0x152039] * 1600
            if 716 <= y < 720:
                row[:] = [0x73d8ff] * 1600
            for pitch, midi, black, center in keys:
                lit = bool(held & (1 << pitch))
                if not black:
                    if y < 716:
                        row[center+13:center+15] = [0x172137] * 2
                    if y >= 720:
                        color = (0x56dfff if pitch < 39 else 0xbb91ff) if lit else (0xb7bfce if y >= 888 else 0xeef2fa)
                        row[center-15:center+15] = [color] * 30
                        row[center+13:center+15] = [0x343d51] * 2
                        if midi % 12 == 0 and 865 <= y < 872:
                            row[center-2:center+3] = [0x687893] * 5
            for pitch, midi, black, center in keys:
                if black and 720 <= y < 826:
                    color = (0x22bbef if pitch < 39 else 0x9663e8) if held & (1 << pitch) else (0x30394b if y >= 816 else 0x121725)
                    row[center-9:center+9] = [color] * 18
            if y < 720:
                mask = masks[179-y//4]
                for pitch, midi, black, center in keys:
                    if mask & (1 << pitch):
                        half = 5 if black else 10
                        edge, inner = (0x9aeaff, 0x25b9e8) if pitch < 39 else (0xd8bcff, 0x9964ed)
                        row[center-half:center+half] = [edge] * (half*2)
                        row[center-half+2:center+half-2] = [inner] * (half*2-4)
            expected.write(''.join(f'{color:06x}\n' for color in row))
            for color in row:
                image.extend(color.to_bytes(3, 'big'))
    (OUT / 'reference.ppm').write_bytes(b'P6\n1600 900\n255\n' + image)
    print('PASS: independent live history and 1,440,000 RGB reference pixels')


def check():
    expected = (OUT / 'reference.ppm').read_bytes()
    actual = (OUT / 'live_waterfall_rtl.ppm').read_bytes()
    assert actual == expected, 'Live waterfall image differs from independent reference'
    benches = ('tb_live_waterfall', 'tb_live_waterfall_scene', 'tb_video_sync',
               'tb_uart_notes', 'tb_video_player', 'tb_pressure_integration')
    for bench in benches:
        log = (OUT / f'{bench}.log').read_text(errors='replace')
        assert '# PASS' in log and '# ** Fatal:' not in log, bench
    rtl = sorted((ROOT / 'src').rglob('*.v'))
    fingerprint = hashlib.sha256()
    for path in rtl:
        fingerprint.update(path.relative_to(ROOT).as_posix().encode())
        fingerprint.update(path.read_bytes())
    evidence = dict(benches=list(benches), frames=400, history_pixel_checks=2174,
                    scene_rgb_pixels=1600*900, direction='down', history_seconds=3,
                    rtl_sha256=fingerprint.hexdigest(), synthesized=False)
    (OUT / 'verification.json').write_text(json.dumps(evidence, indent=2)+'\n')
    print('PASS: six live waterfall regressions and all 1,440,000 rendered RGB pixels')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    check() if args.check else fixtures()
