# 安卓三星铃声的实时马林巴演奏版

本次选用三星 Galaxy 的经典主题铃声 **Over the Horizon（2012/S3）**，从公开原机 MIDI 中提取独立马林巴声部，再用本工程的实时模态音源演奏。它是马林巴声部编排版，保留该声部的乐句间留白，没有重现原曲的其他乐器伴奏。

## 来源与处理

- [三星官方：Over the Horizon 的演变与 Galaxy S III 的 2012 版本](https://news.samsung.com/global/over-the-horizon-the-evolution-of-the-samsung-galaxy-brand-sound)。Android 各品牌铃声并不统一，这里具体选择三星主题。
- [原机 MIDI 公开档案：GT-E1270 的 Over the horizon](http://onj3.andrelouis.com/phonetones/unzipped/Samsung/GT-E1270/01%20Ringtones/07%20Over%20the%20horizon.mid)。该 MIDI 来自功能机的同曲编配，不能将它描述成从 Android 系统直接提取的文件。
- [同曲 2012 版参考音频来源](https://github.com/w3teal/awesome-ringtone/tree/main/Samsung)。参考音频仅用于来源对照，不进入 FPGA 播放链。

原始 MIDI 3314 字节、时长 24.375 秒，`Marimba` 音轨为 GM program 12、通道 0，音域 B3–B5。保留原记录的 note-on/note-off 时间和力度。源文件有 32 次 note-on，其中一处同刻同音高的弱叠层与强叠层合并为较强力度，共 31 次实际触发，避免单音高声部状态被弱触发覆盖。原始 note-off 时序保留用于事件控制；马林巴仍按 one-shot 自然衰减。

原文件的固定 pitchwheel=100 对应很小的音高偏移；本版按现有十二平均律合成，不应用该偏移，也不保留原 MIDI 的通道混音音量、声像及其他乐器。原始资料权利仍归相应权利人；公开档案不等同于官方授权发布。

## 文件和操作

| 文件 | 用途 |
| --- | --- |
| `assets/ringtone/android/samsung_over_the_horizon_s3.mid` | 保留的原始 MIDI |
| `assets/ringtone/android/samsung_2012_over_the_horizon.mp3` | 下载的参考音频 |
| `sd_card/ANDROID.BIN` | M42S 事件：31 次 note-on、31 次 note-off、1 条结束记录，共 520 字节 |
| `sd_card/ANDROID.json` | 来源、哈希、转换策略和事件清单 |
| `sd_card/ANDROID_SD_WRITE.json` | SD 写入及读回校验记录 |
| `sim/android_ringtone_sd_realtime.wav` | 实际 RTL 生成的马林巴试听 |
| `sim/android_ringtone_sd_audio_report.json` | 完整音频与独立整数模型核对 |

KEY0 从 SD 根目录读取 `ANDROID.BIN`（FAT 短文件名字段为 `ANDROID BIN`），按原节奏播放一次；再按停止，再次启动从头读取；播完返回手动模式。KEY1 的 C2–F5 42 音循环和 KEY2 复位行为保持原样。合成核心仍支持 C2–B5，不需要改动原有音色参数。

卡上保留苹果 `RINGTONE.BIN` 和钢琴 `PIANO.BIN`；新固件 KEY0 只选择 `ANDROID.BIN`。文件缺失时会报错停止，不自动播放其他文件。SD 只保存事件，波形由 FPGA 实时生成。

下载文件直接覆盖原 `impl/pnr/GW_PROBLEM_TOW.fs`，没有另外建立新的下载入口。把 SD 卡装回开发板并下载此位流后使用。

## 复现

1. `python tools/make_android_ringtone.py`：从本地 MIDI 生成 `ANDROID.BIN`、报告及 FAT 测试夹具。
2. `powershell -ExecutionPolicy Bypass -File sim/run_ringtone.ps1`：验证 FAT16/FAT32、播放控制、错误处理与完整 RTL 音频。
3. `powershell -ExecutionPolicy Bypass -File tools/copy_ringtone_to_sd.ps1 -DriveLetter H -FileName ANDROID.BIN`：验证可移动 FAT 卷，写入、刷盘及读回 SHA256，原钢琴文件哈希保持一致。
4. Gowin 执行 `tools/build.tcl`：综合、布局布线、覆盖位流并检查时序。

测试平台的事件数和预期触发数改为读取生成的 `params.vh`，避免更换曲目后仍固定检查苹果版本的 51 次触发。旧版本输入、试听和相关工具快照在 `backup/before_android_ringtone/`。

本版验证结果：FAT16/FAT32 和控制/错误测试通过；396729 个 RTL 音频采样与独立整数模型逐点一致，PCM 峰值 5896；50 MHz 布局时序通过，Fmax 50.076 MHz，Setup/Hold 违规 0/0。本次已写 SD 卡，未烧录 FPGA 或进行板上实测。
