# 三首钢琴乐谱与蓝牙上传包

目标槽位PN003～PN005。PN001/PN002未使用；上传会覆盖目标槽位原有内容，请确认对应编号可用。

| 目标 | 曲目 | 时长（含1.5秒结束窗口） | 乐谱字节 | 最大同时发音 |
| --- | --- | --- | ---: | ---: |
| PN003.BIN | 致爱丽丝 | 2:12 | 14504 | 6 |
| PN004.BIN | C大调前奏曲 BWV 846 | 2:22 | 8808 | 5 |
| PN005.BIN | 土耳其进行曲 | 4:16 | 25848 | 8 |

## 手机蓝牙发送

使用与固定槽位布局及蓝牙v2协议匹配的FPGA固件、已初始化的SD卡。串口设置115200/8N1。
先停止SD播放。解压ZIP后打开对应 bluetooth/PNxxx 文件夹，按以下顺序用RAW文件发送：

1. 发送该文件夹的 BEGIN.bin，等待 READY（不是仅等待手机发送完毕）。
2. READY后30秒内开始发送同文件夹的 PNxxx_DATA_END.bin，等待最终成功。
3. 用串口屏选择钢琴和对应编号播放。上传与播放须错开。

每首的BEGIN都不同，不可混用。DATA_END已经包含END，不需再发送根目录BIN或额外END。
READY HEX: 5A A5 02 01 00 00 00 00 00 00 08 2A
SUCCESS HEX: 5A A5 02 03 00 00 00 00 00 00 EB 4A

## 电脑上传

在项目根目录执行，COM8需替换成实际端口：

```powershell
python -B tools/bluetooth_upload.py "sd_card/piano_selected/PN003.BIN" --instrument piano --number 3 --port COM8
python -B tools/bluetooth_upload.py "sd_card/piano_selected/PN004.BIN" --instrument piano --number 4 --port COM8
python -B tools/bluetooth_upload.py "sd_card/piano_selected/PN005.BIN" --instrument piano --number 5 --port COM8
```

## 内容与来源

按源MIDI全部事件转换，保留源文件中的速度、力度和踏板信息，不删音、不裁剪。
实际演奏长度及反复以来源MIDI为准。毫秒量化与合成音色不等同真人录音。
已检查8事件槽位、A0～C8音域、100 KiB大小、音符开关配对及首尾蓝牙帧CRC。
未打开COM口、写入物理SD卡或下载FPGA；未做实板试听。

- 致爱丽丝 / Ludwig van Beethoven: https://www.mutopiaproject.org/cgibin/piece-info.cgi?id=931
  Mutopia marks this edition Public Domain; typeset by Stelios Samelis.
- C大调前奏曲 BWV 846 / Johann Sebastian Bach: https://www.mutopiaproject.org/cgibin/piece-info.cgi?id=117
  Mutopia edition by Jeff Covey, 2009-12-22; CC BY 3.0: https://creativecommons.org/licenses/by/3.0/ . MIDI converted to P88S with millisecond timing; no notes removed.
- 土耳其进行曲 / Wolfgang Amadeus Mozart: https://www.mutopiaproject.org/cgibin/piece-info.cgi?id=108
  Mutopia marks this edition Public Domain; typeset by Rune Zedeler and Chris Sawer.
