# 肖邦《夜曲》Op.9 No.2：单簧管独奏 BIN

文件为 `sd_card/CLARINET.BIN`，不是音频录音。FPGA 从 SD 读取音符事件后，使用现有 `clarinet_synth.v` 逐样本实时合成。

## 来源与改编

来源是 Mutopia Project 的完整 MIDI 与 LilyPond 乐谱，整理者 Renato Biolcati Rinaldi，版本 Mutopia-2014/12/18-1590。来源页：https://www.mutopiaproject.org/cgibin/piece-info.cgi?id=1590 。原文件保存在 `source/chopin_nocturne_op9_no2/`。

这是从钢琴谱自动提取的单声部改编：选择右手谱表每个时刻最高的发声音，去掉左手及较低和声音，保留装饰音、重复起音和原 MIDI 的时间。统一下降一个八度，保持降 E 大调及旋律音程，实际音域由 E♭4～E♭7 变成 E♭3～E♭6（MIDI 51～87），无需逐音折叠或截掉高音。

原 MIDI 按固定的八分音符 132 拍/分钟播放；本文件保留它的机械节奏，没有额外模拟钢琴家的自由速度或呼吸分句。源 MIDI 所有音符力度为 90，本改编如实保留，内部力度为 180。

2026-10-26 音源更新在 FPGA 内加入每音响度轮廓、轻微气息/音高变化并恢复逐音起音，不修改此 BIN 的时间戳、音高或力度。已有夜曲播放成功的 SD 卡无需重写，只需更新固件。音源的实时动态不等于对乐谱增加自由速度或呼吸休止。

共 421 个单音、843 条记录（含一个结束记录）、6760 字节。最后一个音于 202273 ms 释放，保留 500 ms 释放窗口，文件结束于 202773 ms，约 3 分 23 秒。全部音符严格单声部，note-off 与 note-on 同时出现时先发送释放。

原始版本及衍生音乐资产使用 CC BY-SA 3.0，署名和修改说明见 `source/chopin_nocturne_op9_no2/ATTRIBUTION.md`、`sd_card/CLARINET_LICENSE.md`。转换脚本、CSV 和 MIDI 便于检查和继续编辑。

## 开发板播放

1. 下载本轮重新构建的 `impl/pnr/GW_PROBLEM_TOW.fs`。上一轮只有单音试听的固件不能识别 C45S。
2. 将 `sd_card/CLARINET.BIN` 以同名放入 FAT16/FAT32 SD 卡根目录，保留原三首文件即可。
3. 串口屏增加“夜曲／单簧管独奏”按钮，在弹起事件发送：

```text
printh A5 5A 01 00 10 04 00 00 15 0D
```

脚本为 `screen/tjc_uart/clarinet_release.txt`。主机工具为 `powershell -ExecutionPolicy Bypass -File tools/send_uart_command.ps1 -Command Clarinet`；不提供 `-Port` 只打印帧。UART 仍为 115200/8N1。

第 4 首曲目自动使用单簧管，不依赖虚拟试听当前选择的乐器。停止命令仍为 `11`；同曲重复选择不重启，换曲会从头加载；结束后返回手动模式。KEY0 仍控制安卓铃声，KEY1 仍为马林巴实体试听。

注意区分：`CMD=45` 只选择单簧管逐音试听；播放整首夜曲使用 `CMD=10, P0=04`。数字状态控件 `page0.n1` 将显示曲目编号 4，`every.tInstrument` 仍表示虚拟试听选择。

## BIN 格式与复现

`C45S` v1 与原格式共用 16 字节头、8 字节记录和毫秒时间戳。头为 `magic="C45S", version=1, event_bytes=8, slots=8, reserved=0, ticks_per_second=1000, event_count`。普通事件仅使用 slot=0，音符为实际 MIDI 50～94，力度 1～127 为 note-on，0 为 note-off；末尾记录为 slot=255、note=255、velocity=0。

```powershell
python tools/make_clarinet_nocturne.py
python tools/check_project.py
powershell -ExecutionPolicy Bypass -File sim/run_nocturne.ps1
powershell -ExecutionPolicy Bypass -File sim/run_nocturne.ps1 -RenderAudio
```

转换只需项目已有 mido；完整音频整数模型检查需要 NumPy。普通测试核对完整 843 条记录、FIFO/反压、FAT16/FAT32、第 4 曲命令及错误文件。`-RenderAudio` 额外运行全曲真实 RTL，并与独立整数模型逐样本对照，当前动态音源输出为 `output/clarinet_calibration/Chopin_Nocturne_Op9_No2_Clarinet_Expressive_Realtime.wav` 和同目录 `audio_report.json`。原初版 WAV 保存在 `output/clarinet_calibration/before/`。WAV 为检查/试听结果，不是板卡播放输入。

本轮不自动写卡、连接串口或下载开发板。
