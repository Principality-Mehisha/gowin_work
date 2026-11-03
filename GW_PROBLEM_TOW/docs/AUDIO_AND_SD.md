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
| src/rom/marimba48_48828.hex | 当前48828.125 Hz每音四组模态频率、幅度和衰减参数 |
| src/rom/marimba48.hex | 保留的旧采样率模态参考，用于独立旧算法回归 |
| src/rom/marimba_attack48.hex | 每音短起音噪声参数 |

这些表保存函数和参数，不是逐音录音。当前综合路径不含 PCM/ADPCM 录音播放器。
音频域150 MHz、原生采样48828.125 Hz；控制和SD仍50 MHz，音高与衰减时间已按新采样率调整。
原五表不修改，新增模态表由tools/generate_audio150_parameters.py生成，详见AUDIO_150MHZ.md。
当前马林巴在初始化时把每音四模态重排为逐模态64位表，并把起音参数放在同一表中；
两个互斥音色共用正弦查表，未增加ROM文件、改变数值或截断精度，详见ROM_SHARING.md。
`assets/` 的录音仅供离线拟合或乐谱转写；`sim/` 的 WAV 是仿真结果。


## 编号 SD 文件

使用离线工具初始化的固定槽位FAT32卡，再经蓝牙上传。不能直接复制小文件到普通FAT卡使用。

| 编号 | 文件 | 格式／音源 |
| --- | --- | --- |
| 1～100 | PN001.BIN～PN100.BIN | P88S／钢琴 |
| 1～100 | MB001.BIN～MB100.BIN | M42S／马林巴 |

每文件100 KiB，实际正文长度及CRC另存元数据；空占位文件不播放。
旧三首名字、CMD=0x10及普通FAT文件搜索已移除；已有编号槽位位置不变。

两种格式均为小端序：16 字节头，后接每条 8 字节事件。
头部为 `magic[4], version=1, event_bytes=8, slots=8, reserved=0, ticks_per_second=1000(u32), event_count(u32)`。
事件为 `time_ms(u32), slot(u8), note(u8), velocity(u8), reserved=0(u8)`。
slot 为 0～7，velocity 为 1～127 表示 note-on，0 表示 note-off。
结束记录使用 slot=255、note=255、velocity=0。时间戳必须非递减。
P88S 音符为钢琴索引 0～87，M42S 为 MIDI 36～83。内部力度由 velocity 左移一位转换。

SD SPI 的初始化/读取半分频均为 63，时钟约 397 kHz。
错误分类：1x=SD，2x=FAT，3x=乐谱，40=调度，50=合成超时，60=UART反馈溢出，
61=压力溢出，62=效果超期，63=音频跨域/失锁；数值均为十六进制。
播放错误在存储链复位前锁存，通过停止、重选曲目或复位清除。

## 生成与分析工具

- `generate_tables.py`：生成当前钢琴正弦、频率及音色表。
- `fit_marimba_params.py`：从 Iowa AIFF 拟合当前 48 音模态及起音参数；需要 NumPy/SciPy。
- `make_piano_score.py`：从 `source/` 的 MIDI 生成钢琴 BIN；使用 `tools/vendor` 中的 mido。
- `make_android_ringtone.py`：提取当前三星 MIDI 的马林巴声部生成安卓 BIN。
- `make_ringtone_score.py`：从保留的苹果参考 WAV 转写音符事件，需要 NumPy/SciPy。
- `make_upload_fixtures.py`：生成只有200槽的当前集成测试夹具，包含PN/MB和故障样本。
- `make_test_fixtures.py`：仅供历史离线音频模型及旧卡布局样本，不是当前播放器回归入口。
- `check_ringtone_synth.py`：逐样本对照完整安卓谱的 RTL 与独立整数模型，输出 WAV 和 JSON。
- `check_marimba_audio.py`、`export_marimba_wav.py`：校验/导出当前 C2～F5 试听音域。

重新生成音色或乐谱会改写输入文件，应在修改后重新运行检查、仿真和构建。
马林巴校准使用固定力度 192 和前 300 ms 加权 PCM RMS，低音补偿最大 +3 dB；此指标不是 LUFS 或实际声压。

当前部署、BEGIN/READY及合并正文+END流程见[蓝牙上传](BLUETOOTH_UPLOAD.md)。
旧copy_score_to_sd/copy_ringtone_to_sd脚本只适用于历史工程，不能用来更新固定槽位卡，
否则可能改变目录项或簇链。当前修改与回归不会写入物理SD卡。
