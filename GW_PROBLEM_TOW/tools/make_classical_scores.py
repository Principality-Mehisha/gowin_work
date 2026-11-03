"""Generate three numbered P88S piano scores; downloads require --download.

No serial ports or physical SD cards are accessed. Existing files are kept
unless --force is supplied. MIDI tempo, dynamics and sustain are decoded by
the project's existing reader; notes are never stolen to fit 32 slots.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import shutil
import tempfile
import urllib.request
import zlib

from bluetooth_upload import MAX_FILE_BYTES, load_score, validate_score
from make_piano_score import compile_notes, pack_score
from midi_notes import read_notes
from score_bin import read_p88s

ROOT = Path(__file__).resolve().parents[1]
CATALOG = (
    dict(number=1, title="致爱丽丝", composer="Ludwig van Beethoven",
         midi="fur_elise.mid",
         page="https://www.mutopiaproject.org/cgibin/piece-info.cgi?id=931",
         url="https://www.mutopiaproject.org/ftp/BeethovenLv/WoO59/fur_Elise_WoO59/fur_Elise_WoO59.mid",
         source_notice="Mutopia marks this edition Public Domain; typeset by Stelios Samelis."),
    dict(number=2, title="卡农（钢琴版）", composer="Johann Pachelbel",
         midi="canon_piano.mid",
         page="https://www.pachelbelcanon.com/pachelbel-canon-files/category/1-pachelbel-canon.html",
         url="https://www.pachelbelcanon.com/pachelbel-canon-files/category/1-pachelbel-canon.html?download=1%3Acanonpiano.mid",
         source_notice="canonpiano.mid: site identifies a piano version; no separate MIDI redistribution licence is stated."),
    dict(number=3, title="土耳其进行曲", composer="Wolfgang Amadeus Mozart",
         midi="turkish_march.mid",
         page="https://www.mutopiaproject.org/cgibin/piece-info.cgi?id=108",
         url="https://www.mutopiaproject.org/ftp/MozartWA/KV331/KV331_3_RondoAllaTurca/KV331_3_RondoAllaTurca.mid",
         source_notice="Mutopia marks this edition Public Domain; typeset by Rune Zedeler and Chris Sawer."),
)


def prepare_notes(notes):
    """Match the synth's one-state-per-pitch note-off/retrigger semantics.

    Unison notes with the exact same quantized onset become one key strike.
    A repeated key ends its previous sustained interval before retriggering.
    Other pitches, onsets and dynamics are retained; there is no voice stealing.
    """
    grouped = {}
    merged = 0
    for note in notes:
        start = round(note["start"] * 1000)
        end = max(start + 1, round(note["end"] * 1000))
        key = (note["pitch"], start)
        if key in grouped:
            previous = grouped[key]
            previous["end_ms"] = max(previous["end_ms"], end)
            previous["gain"] = max(previous["gain"], note["gain"])
            merged += 1
        else:
            grouped[key] = dict(pitch=note["pitch"], start_ms=start,
                                end_ms=end, gain=note["gain"])
    by_pitch = {}
    shortened = 0
    result = []
    for note in sorted(grouped.values(), key=lambda n: (n["start_ms"], n["pitch"])):
        previous = by_pitch.get(note["pitch"])
        if previous is not None and previous["end_ms"] > note["start_ms"]:
            previous["end_ms"] = note["start_ms"]
            shortened += 1
        by_pitch[note["pitch"]] = note
        result.append(note)
    return [dict(pitch=n["pitch"], start=n["start_ms"] / 1000,
                 end=n["end_ms"] / 1000, gain=n["gain"]) for n in result], dict(
                     merged_unisons=merged, shortened_same_pitch_retriggers=shortened)


def convert_song(song, midi_path, output_dir):
    source_notes, duration = read_notes(midi_path, min_notes=1, min_duration=0)
    notes, adjustments = prepare_notes(source_notes)
    events, peak = compile_notes(notes, duration)
    data = pack_score(events)
    validate_score(data, "piano")
    if len(data) > MAX_FILE_BYTES:
        raise ValueError(f"{song['title']}: score exceeds the 100 KiB slot")
    output_dir.mkdir(parents=True, exist_ok=True)
    name = f"PN{song['number']:03}.BIN"
    destination = output_dir / name
    destination.write_bytes(data)
    _, checked = read_p88s(destination)
    assert load_score(destination, "piano") == data
    pitches = [n["pitch"] for n in notes]
    return dict(number=song["number"], title=song["title"], composer=song["composer"],
                file=name, format="P88S v1", protocol=2,
                voices=checked["voices"],
                bytes=len(data), event_count=len(events),
                source_note_count=len(source_notes), note_count=len(notes),
                peak_polyphony=peak, duration_ms=checked["duration_ms"],
                midi_note_range=[min(pitches), max(pitches)],
                crc32=f"{zlib.crc32(data):08X}",
                sha256=hashlib.sha256(data).hexdigest(),
                midi_file=midi_path.name,
                midi_sha256=hashlib.sha256(midi_path.read_bytes()).hexdigest(),
                source_page=song["page"], source_midi_url=song["url"],
                source_notice=song["source_notice"], **adjustments)


def download_midi(song, destination):
    request = urllib.request.Request(song["url"], headers={"User-Agent": "GW-P88S-score-converter/1.0"})
    with urllib.request.urlopen(request, timeout=60) as response:
        data = response.read(4 * 1024 * 1024 + 1)
    if len(data) > 4 * 1024 * 1024 or data[:4] != b"MThd":
        raise ValueError(f"{song['midi']}: download is not a standard MIDI file")
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_bytes(data)


def generate(source_dir, output_dir, *, download=False, force=False):
    outputs = [f"PN{song['number']:03}.BIN" for song in CATALOG] + ["manifest.json", "README.md"]
    if not force:
        for name in outputs:
            if (output_dir / name).exists():
                raise FileExistsError(f"Keeping {output_dir / name}; use --force to replace")
    for song in CATALOG:
        source = source_dir / song["midi"]
        if not source.exists():
            if not download:
                raise FileNotFoundError(f"Missing {source}. Supply the MIDI or use --download.")
            print(f"Downloading {song['midi']}...", flush=True)
            download_midi(song, source)
    # Validate all three songs in a temporary folder before publishing any BIN.
    output_dir.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix=".gw_piano_classics_", dir=output_dir.parent) as staging:
        staged = Path(staging)
        manifest = [convert_song(song, source_dir / song["midi"], staged) for song in CATALOG]
        (staged / "manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        lines = ["# 三首钢琴乐谱", "", "格式：P88S v1；蓝牙上传协议：v2。", "",
                 "| 文件 | 曲目 | 时长 | 字节 | 最大同时发音 | CRC32 |", "| --- | --- | --- | ---: | ---: | --- |"]
        for item in manifest:
            seconds = round(item["duration_ms"] / 1000)
            lines.append(f"| {item['file']} | {item['title']} | {seconds // 60}:{seconds % 60:02} | {item['bytes']} | {item['peak_polyphony']} | {item['crc32']} |")
        lines += ["", "三个编号是建议映射；上传时以 --number 指定的目标槽位为准。",
                  "已保留 MIDI 速度变化与力度，未裁剪曲长、未丢弃其他音高来凑32声部。",
                  "同音同刻合并；踏板延长的同音在下一次击键前释放，适配合成器的同音重触发。", "",
                  "## 上传", "", "在项目根目录运行；将 COM8 替换成实际蓝牙串口：", "", "```powershell"]
        for song in CATALOG:
            file = output_dir / f"PN{song['number']:03}.BIN"
            lines.append(f'python -B tools/bluetooth_upload.py "{file}" --instrument piano --number {song["number"]} --port COM8')
        lines += ["```", "", "省略 --port 只做离线检查。上传前停止播放，等待最终 Upload committed 后再播放。",
                  "SD 卡和 FPGA 固件必须支持项目的固定槽位布局、蓝牙 v2及32音符槽；文件不需要填充到 100 KiB。",
                  "BEGIN/READY → BIN 原始字节 → END/最终成功；普通裸文件发送不能省略首尾控制帧。",
                  "新增曲目可用频谱/波形；当前内置瀑布流谱面不随这三个文件更新。", "",
                  "## 来源", ""]
        for item in manifest:
            lines += [f"- {item['title']}：{item['source_page']}", f"  {item['source_notice']}"]
        (staged / "README.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
        output_dir.mkdir(parents=True, exist_ok=True)
        for name in outputs:
            shutil.copyfile(staged / name, output_dir / name)
    return manifest


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-dir", type=Path, default=ROOT / "source/piano_classics")
    parser.add_argument("--output-dir", type=Path, default=ROOT / "sd_card/piano_classics")
    parser.add_argument("--download", action="store_true", help="Download missing source MIDIs")
    parser.add_argument("--force", action="store_true", help="Replace existing generated outputs")
    args = parser.parse_args()
    try:
        manifest = generate(args.source_dir.resolve(), args.output_dir.resolve(),
                            download=args.download, force=args.force)
    except (OSError, ValueError) as exc:
        parser.exit(1, f"Scores not published: {exc}\n")
    for item in manifest:
        print(f"{item['file']}: {item['bytes']} bytes, {item['note_count']} notes, "
              f"{item['duration_ms'] / 1000:.3f}s, peak {item['peak_polyphony']}, CRC32={item['crc32']}")


if __name__ == "__main__":
    main()
