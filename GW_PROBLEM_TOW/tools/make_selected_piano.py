"""Build the three selected piano scores and matched offline Bluetooth bundles."""
from __future__ import annotations

import argparse
import binascii
import json
from pathlib import Path
import shutil
import struct
import tempfile
import zipfile
import zlib

from make_classical_scores import CATALOG, convert_song, download_midi
from prepare_bluetooth_files import prepare
from score_bin import read_p88s

ROOT = Path(__file__).resolve().parents[1]
SELECTED = (
    dict(CATALOG[0], number=3),
    dict(number=4, title="C大调前奏曲 BWV 846", composer="Johann Sebastian Bach",
         midi="bach_prelude_c_major.mid",
         page="https://www.mutopiaproject.org/cgibin/piece-info.cgi?id=117",
         url="https://www.mutopiaproject.org/ftp/BachJS/BWV846/wtk1-prelude1/wtk1-prelude1.mid",
         source_notice="Mutopia edition by Jeff Covey, 2009-12-22; CC BY 3.0: "
                       "https://creativecommons.org/licenses/by/3.0/ . "
                       "MIDI converted to P88S with millisecond timing; no notes removed."),
    dict(CATALOG[2], number=5),
)


def verify_bundle(directory, song, report):
    """Independently decode transfer framing and compare the decoded note stream."""
    score = (directory / report["file"]).read_bytes()
    _, decoded = read_p88s(directory / report["file"])
    assert decoded["note_count"] == report["note_count"]
    assert decoded["peak_polyphony"] == report["peak_polyphony"] <= 8
    bundle = directory / "bluetooth" / report["file"][:-4]
    begin = (bundle / "BEGIN.bin").read_bytes()
    merged = (bundle / f'{report["file"][:-4]}_DATA_END.bin').read_bytes()
    for frame in (begin, merged[-10:]):
        assert struct.unpack_from("<H", frame, len(frame)-2)[0] == binascii.crc_hqx(frame[:-2], 0)
    assert struct.unpack("<2sBBHHBBIIH", begin)[:-1] == (
        b"\xa5\x5a", 2, 1, 0, 10, 1, song["number"], len(score), zlib.crc32(score))
    assert struct.unpack("<2sBBHHH", merged[-10:])[:-1] == (b"\xa5\x5a", 2, 3, 0, 0)
    assert merged[:-10] == score
    assert 24 <= len(score) <= 102400


def generate(source_dir, destination, download=False):
    archive = destination.with_suffix(".zip")
    if destination.exists() or archive.exists():
        raise FileExistsError("Output exists; choose another --output-dir")
    for song in SELECTED:
        midi = source_dir / song["midi"]
        if not midi.exists():
            if not download:
                raise FileNotFoundError(f"Missing {midi}; supply MIDI or use --download")
            download_midi(song, midi)
    destination.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix=".selected_piano_", dir=destination.parent) as temporary:
        staged = Path(temporary) / destination.name
        reports = []
        for song in SELECTED:
            report = convert_song(song, source_dir / song["midi"], staged)
            bundle = staged / "bluetooth" / report["file"][:-4]
            files, transport = prepare((staged / report["file"]).read_bytes(), "piano", song["number"])
            bundle.mkdir(parents=True)
            for name, data in files.items():
                (bundle / name).write_bytes(data)
            transport["title"] = song["title"]
            (bundle / "manifest.json").write_text(json.dumps(transport, ensure_ascii=False, indent=2)+"\n", encoding="utf-8")
            verify_bundle(staged, song, report)
            reports.append(report)
        manifest = dict(format="P88S v1", bluetooth_protocol=2,
                        physical_device_accessed=False, offline_validation_passed=True, songs=reports)
        (staged / "manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2)+"\n", encoding="utf-8")
        lines = ["# 三首钢琴乐谱与蓝牙上传包", "",
                 "目标槽位PN003～PN005。PN001/PN002未使用；上传会覆盖目标槽位原有内容，请确认对应编号可用。", "",
                 "| 目标 | 曲目 | 时长（含1.5秒结束窗口） | 乐谱字节 | 最大同时发音 |",
                 "| --- | --- | --- | ---: | ---: |"]
        for report in reports:
            seconds = round(report["duration_ms"]/1000)
            lines.append(f'| {report["file"]} | {report["title"]} | {seconds//60}:{seconds%60:02} | {report["bytes"]} | {report["peak_polyphony"]} |')
        lines += ["", "## 手机蓝牙发送", "",
                  "使用与固定槽位布局及蓝牙v2协议匹配的FPGA固件、已初始化的SD卡。串口设置115200/8N1。",
                  "先停止SD播放。解压ZIP后打开对应 bluetooth/PNxxx 文件夹，按以下顺序用RAW文件发送：", "",
                  "1. 发送该文件夹的 BEGIN.bin，等待 READY（不是仅等待手机发送完毕）。",
                  "2. READY后30秒内开始发送同文件夹的 PNxxx_DATA_END.bin，等待最终成功。",
                  "3. 用串口屏选择钢琴和对应编号播放。上传与播放须错开。", "",
                  "每首的BEGIN都不同，不可混用。DATA_END已经包含END，不需再发送根目录BIN或额外END。",
                  "READY HEX: 5A A5 02 01 00 00 00 00 00 00 08 2A",
                  "SUCCESS HEX: 5A A5 02 03 00 00 00 00 00 00 EB 4A", "",
                  "## 电脑上传", "", "在项目根目录执行，COM8需替换成实际端口：", "", "```powershell"]
        for song in SELECTED:
            name = f'PN{song["number"]:03}.BIN'
            relative = (destination/name).relative_to(ROOT).as_posix() if destination.is_relative_to(ROOT) else str(destination/name)
            lines.append(f'python -B tools/bluetooth_upload.py "{relative}" --instrument piano --number {song["number"]} --port COM8')
        lines += ["```", "", "## 内容与来源", "",
                  "按源MIDI全部事件转换，保留源文件中的速度、力度和踏板信息，不删音、不裁剪。",
                  "实际演奏长度及反复以来源MIDI为准。毫秒量化与合成音色不等同真人录音。",
                  "已检查8事件槽位、A0～C8音域、100 KiB大小、音符开关配对及首尾蓝牙帧CRC。",
                  "未打开COM口、写入物理SD卡或下载FPGA；未做实板试听。", ""]
        for song in SELECTED:
            lines += [f'- {song["title"]} / {song["composer"]}: {song["page"]}', f'  {song["source_notice"]}']
        (staged / "README.md").write_text("\n".join(lines)+"\n", encoding="utf-8")
        with zipfile.ZipFile(archive, "x", zipfile.ZIP_DEFLATED) as zip_file:
            for file in sorted(staged.rglob("*")):
                if file.is_file():
                    zip_file.write(file, file.relative_to(staged.parent))
        shutil.copytree(staged, destination)
    return reports


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-dir", type=Path, default=ROOT/"source/piano_selected")
    parser.add_argument("--output-dir", type=Path, default=ROOT/"sd_card/piano_selected")
    parser.add_argument("--download", action="store_true")
    args = parser.parse_args()
    for item in generate(args.source_dir.resolve(), args.output_dir.resolve(), args.download):
        print(f'{item["file"]}: {item["bytes"]} bytes, {item["duration_ms"]} ms, peak {item["peak_polyphony"]}')
    print("PASS: all three score/transfer bundles independently validated; ZIP created")
