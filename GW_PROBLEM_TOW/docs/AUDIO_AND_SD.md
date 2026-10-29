# 实时音频、ROM 与 SD 乐谱

## 当前音源

钢琴覆盖 A0～C8，事件编号 0～87。每键最多八个分音，使用 DDS、线性插值和 ADSR，包含低音音色及音量补偿。
马林巴覆盖 C2～B5，事件直接使用 MIDI 36～83；四模态参数、短槌击噪声和琴体滤波由 FPGA 逐样本计算。
马林巴是 one-shot 衰减，note-off 不截断自然尾音。UART 试听覆盖 C2～B5 全部 48 音。

| 当前 ROM | 内容 |
| --- | --- |
| src/rom/sine256.hex | 256 点有符号正弦函数 |
| src/rom/frequency88.hex | 88 音的 32 位 DDS 频率字，按 48 kHz 归一化 |
| src/rom/voicing88.hex | 每键分音权重、增益、衰减及弦刚度参数 |
| src/rom/marimba48.hex | 每音四组模态频率、幅度和衰减参数 |
| src/rom/marimba_attack48.hex | 每音短起音噪声参数 |

这些表保存函数和参数，不是逐音录音。当前综合路径不含 PCM/ADPCM 录音播放器。
`assets/` 的录音仅供离线拟合或乐谱转写；`sim/` 的 WAV 是仿真结果。


## 三首 SD 文件

文件放在开发板 SD 卡根目录，使用 FAT16/FAT32，文件名保持 ASCII 8.3 格式。

| 编号 | 文件 | 格式／音源 |
| --- | --- | --- |
| 1 | ANDROID.BIN | M42S／马林巴，三星主题的马林巴声部改编 |
| 2 | RINGTONE.BIN | M42S／马林巴，苹果 Marimba 参考铃声的音符转写 |
| 3 | PIANO.BIN | P88S／钢琴，Croatian Rhapsody MIDI 改编 |

两种格式均为小端序：16 字节头，后接每条 8 字节事件。
头部为 `magic[4], version=1, event_bytes=8, slots=8, reserved=0, ticks_per_second=1000(u32), event_count(u32)`。
事件为 `time_ms(u32), slot(u8), note(u8), velocity(u8), reserved=0(u8)`。
slot 为 0～7，velocity 为 1～127 表示 note-on，0 表示 note-off。
结束记录使用 slot=255、note=255、velocity=0。时间戳必须非递减。
P88S 音符为钢琴索引 0～87，M42S 为 MIDI 36～83。内部力度由 velocity 左移一位转换。

SD SPI 的初始化/读取半分频均为 63，时钟约 397 kHz。
错误分类：1x=SD，2x=FAT，3x=乐谱，40=调度，50=合成超时，60=UART 反馈溢出；数值均为十六进制。
播放错误在存储链复位前锁存，通过停止、重选曲目或复位清除。

## 生成与分析工具

- `generate_tables.py`：生成当前钢琴正弦、频率及音色表。
- `fit_marimba_params.py`：从 Iowa AIFF 拟合当前 48 音模态及起音参数；需要 NumPy/SciPy。
- `make_piano_score.py`：从 `source/` 的 MIDI 生成钢琴 BIN；使用 `tools/vendor` 中的 mido。
- `make_android_ringtone.py`：提取当前三星 MIDI 的马林巴声部生成安卓 BIN。
- `make_ringtone_score.py`：从保留的苹果参考 WAV 转写音符事件，需要 NumPy/SciPy。
- `make_test_fixtures.py`：仅从现有 BIN 生成测试夹具，不改写 BIN。
- `check_ringtone_synth.py`：逐样本对照完整安卓谱的 RTL 与独立整数模型，输出 WAV 和 JSON。
- `check_marimba_audio.py`、`export_marimba_wav.py`：校验/导出当前 C2～F5 试听音域。

重新生成音色或乐谱会改写输入文件，应在修改后重新运行检查、仿真和构建。
马林巴校准使用固定力度 192 和前 300 ms 加权 PCM RMS，低音补偿最大 +3 dB；此指标不是 LUFS 或实际声压。

写卡脚本保留为显式操作入口，重构和回归不会执行写卡：

```powershell
powershell -ExecutionPolicy Bypass -File tools/copy_score_to_sd.ps1 -DriveLetter H
powershell -ExecutionPolicy Bypass -File tools/copy_ringtone_to_sd.ps1 -DriveLetter H -FileName ANDROID.BIN
powershell -ExecutionPolicy Bypass -File tools/copy_ringtone_to_sd.ps1 -DriveLetter H -FileName RINGTONE.BIN
```

H 仅为示例，使用实际 SD 盘符。写卡脚本检查可移动 FAT 卷并处理已有文件备份/替换；PIANO 替换不同文件时需 `-Replace`。
历史写卡记录不代表当前卡已插入或与工程同步。
