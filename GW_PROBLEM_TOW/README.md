# Tang Mega 60K 实时马林巴与钢琴乐谱播放器

**当前选中音符已通过 UART 自动回传至 `every.tNote` 文本控件。** 切换音调、上电/复位和查询状态都会更新 A0～C8 音名，升号使用 `#`。屏幕需在 every 页的后初始化事件发送一次查询以同步，代码见 [UART_THREE_KEYS.md](UART_THREE_KEYS.md)。三键指令保持不变。

**新增三个固定命令用于 88 音单音试听：40 上一个、41 下一个、42 播放当前音（均为十六进制）。** FPGA 内保存 A0～C8 的选择值，切换时不发声，播放时使用已有钢琴实时合成器并自动释放；屏幕只需三个按钮。马林巴音域及原实体按键功能保持不变。可复制的三条 `printh` 指令见 [UART_THREE_KEYS.md](UART_THREE_KEYS.md)，本次保留用户当前 UART 管脚 RX=B17、TX=B18。

**2026-10-23：已新增淘晶驰 TJC8048X270_011C 的 UART 双向控制，115200/8N1。** 串口屏可选择安卓马林巴 `ANDROID.BIN`、苹果马林巴 `RINGTONE.BIN`、钢琴 `PIANO.BIN`，停止播放和查询状态；三种播放均由 FPGA 实时合成。实体 KEY0/KEY1/KEY2 保持安卓铃声、42 音试听、复位。默认 UART 接线为 PMOD1/J8：11 脚 RX（Y21）、12 脚 TX（Y22）、3/4 脚 GND，屏幕另行供电。屏幕按钮代码、六个反馈控件和完整协议见 [UART_SCREEN.md](UART_SCREEN.md)，可复制脚本在 `screen/tjc_uart/`。位流仍覆盖原 `impl/pnr/GW_PROBLEM_TOW.fs`。下文不含 UART 的操作说明属于历史记录。

**当前 KEY0 已切换为三星安卓主题铃声 Over the Horizon（2012/S3）的马林巴声部演奏版，读取 SD 根目录 `ANDROID.BIN`。** 文件 520 字节、63 条事件、31 次触发，约 24.375 秒。KEY1 仍为 C2–F5 的 42 音试听，KEY2 复位。原苹果 `RINGTONE.BIN` 和钢琴 `PIANO.BIN` 保留；当前位流仍覆盖 `impl/pnr/GW_PROBLEM_TOW.fs`。来源、改编范围及复现方法见 [ANDROID_RINGTONE.md](ANDROID_RINGTONE.md)。以下 KEY0 读取 `RINGTONE.BIN` 的说明属于上一版。

**2026-10-23 当前操作：KEY0 从 SD 卡根目录读取 `RINGTONE.BIN` 的音符指令并实时合成铃声，再按一次停止；播完返回手动试听。KEY1 保持 C2–F5 的 42 音逐音试听，KEY2 复位。** SD 卡只保存时间、MIDI 音高、力度等事件，不保存此播放链所需的 PCM。当前铃声包含 51 次触发、103 条事件，文件 840 字节。为了原音高重现铃声，核心支持 C2–B5 共 48 音，新增高音由同一源 PCM 反演，KEY1 试听上限仍为 F5。旧 KEY0 PCM 播放器已从板级路径和 Gowin 综合文件列表移除，保留源码/测试供历史比较。

当前参数 ROM 为 `src/rom/marimba48.hex` 和 `marimba_attack48.hex`。H: 卡已写入并校验 `RINGTONE.BIN`，原 `PIANO.BIN` 保留；写卡记录见 `sd_card/RINGTONE_SD_WRITE.json`。下载文件仍直接覆盖 `impl/pnr/GW_PROBLEM_TOW.fs`。详细格式、操作及验证见 [SD_RINGTONE.md](SD_RINGTONE.md)，试听为 `sim/ringtone_sd_realtime.wav`。以下旧版说明保留作历史记录，遇到 KEY0 行为和 ROM 文件名差异，以本段及新文档为准。

当前音域已扩展为 **C2–F5，共 42 音（MIDI 36–77）**，新增 C2–A♯2 共 11 音，使用项目内 Iowa 原始 PCM 逐音拟合。KEY1 从 C2 开始逐音试听，F5 后回到 C2；KEY2 复位后回到 C2。新增 C2–B2 保持 +3 dB 补偿平台，再沿用 B2–C4 的平滑回落曲线；原 B2–F5 的参数和逐样本音频不变。

当前综合输入为 `src/rom/marimba42.hex` 与 `marimba_attack42.hex`；`marimba31.hex` 等旧文件只用于历史比较。最新试听为 `sim/marimba_C2_B2_realtime.wav`（低音区）、`sim/marimba_C2_C3_realtime.wav`（跨原边界）和 `sim/marimba_C2_F5_realtime.wav`（完整 42 音）。当前音频校验报告为 `sim/marimba42_report.json`，扩展说明见 [MARIMBA_LOW_EXTENSION.md](MARIMBA_LOW_EXTENSION.md)。下文 31 音记录为扩展前历史。

当前开发核心为 **31 音实时马林巴**。2026-10-22 最新微调将低音补偿最大值从 +4 dB 降为 +3 dB，C4 以上参数和采样保持一致。最新试听为 `sim/marimba_B2_F5_bass_trim.wav`；低音削减校验、高音区音色分析及源 PCM/RTL 对照见 [MARIMBA_REGISTER_ANALYSIS.md](MARIMBA_REGISTER_ANALYSIS.md)，当前验证数据为 `sim/marimba_register_analysis/report.json`。下文及 `sim/marimba_corrected_report.json` 中的 +4 dB 数据属于此前版本。

工程：`GW_PROBLEM_TOW.gprj`。器件：`GW5AT-LV60PG484AC1/I0`。
工程提供可选的 SD 卡 FAT16/FAT32 乐谱播放路径、默认马林巴逐音试听路径，以及一个用于听感对比的 PCM 铃声实验。默认 `SD_SCORE_ENABLE=0`，不访问 SD 卡；马林巴由 DDS 实时生成并输出到 PT8211。KEY0 播放/停止实验性立体声 PCM 铃声，KEY1 触发默认马林巴音符。

## 架构速览

```text
SD 卡 -> SPI -> FAT16/FAT32 -> P88S 解码 -> 事件 FIFO/调度 ─┐
按键 -> 去抖/逐音试听/力度接口 ──────────────────────────┤
                                                         v
                                      88 键 DDS -> 包络/限幅 -> PT8211
```

| 层次 | 主要文件 | 职责 |
| --- | --- | --- |
| 板级入口 | `GW_PROBLEM_TOW.v`, `piano_score_player.v` | 引脚顶层、复位、模式控制与模块连接 |
| 时钟与复位 | `piano_score_player.v` | 直接使用板载 50 MHz `sys_clk`，上电复位和 KEY2 异步复位、同步释放 |
| SD 与乐谱 | `sd_spi_byte.v`, `sd_spi_reader.v`, `fat_file_reader.v`, `piano_score_reader.v`, `piano_score_sequencer.v` | SPI 扇区读取、FAT 文件定位、P88S 校验与定时调度 |
| 演奏输入 | `button_debounce.v`, `key_control.v`, `dynamics_fixed.v` | 按键同步/去抖、逐音试听；`dynamics_fixed` 是后续压力输入的替换接口，需保留 |
| 音频链 | `piano_synth.v`, `marimba_synth.v`, `ringtone_pcm_player.v`, `adsr_step.v`, `output_limiter.v`, `pt8211_score_tx.v` | 实时合成、实验性 PCM/IMA 解码、包络、峰值限制与 PT8211 串行输出 |

`src/rom/` 中的 HEX 文件是合成输入；`sd_card/PIANO.BIN` 是示例乐谱。`sim/` 保存测试平台、运行脚本和可复查的仿真证据；`output/score_test/` 是乐谱/FAT 测试夹具。ModelSim 编译库、临时波形和 Python 缓存均为可再生成文件，不属于工程输入。

根目录按用途划分：`src/` 与 `src/rom/` 是 RTL/综合输入；`tools/` 是 ROM、乐谱、构建和验证工具；`sim/` 是 testbench、运行脚本和有意保留的报告/WAV证据；`output/score_test/` 是自动生成的 FAT/乐谱测试夹具；`backup/` 存放明确标记的历史源码快照；`assets/`、`source/`、`sd_card/` 保存授权、MIDI 来源和示例乐谱；`impl/` 保存 Gowin 综合、时序报告和可下载位流，ModelSim work 库是可重建缓存。清理仿真缓存时运行 `powershell -ExecutionPolicy Bypass -File tools/clean_generated.ps1`；该脚本保留 `impl/`、WAV、报告、日志、ROM、乐谱、MIDI 和历史快照。

## SD 播放与音色

工程自带 `sd_card/PIANO.BIN` 示例乐谱和 DDS 所需的正弦表、频率表、音色参数表。将 `SD_SCORE_ENABLE` 设为 1 才会启用 SD 乐谱读取；音高、谐波、ADSR、力度和复音状态均在 FPGA 内实时计算，不依赖整段录音或每键 PCM 波形。

启用 SD 乐谱模式后，可将示例乐谱放到 SD 卡根目录并校验：

```powershell
powershell -ExecutionPolicy Bypass -File tools/copy_score_to_sd.ps1 -DriveLetter H
```

该脚本只在目标文件缺失或内容一致时直接写入；若卡上已有不同的 `PIANO.BIN`，必须额外指定 `-Replace`，旧文件会先备份到 `output/sd_backup`。目前检测到的 H: 卡根目录没有 `PIANO.BIN`，所以需要先运行该命令，播放器才有乐谱可读。

默认配置禁用 SD 乐谱读取，启动后默认进入马林巴逐音试听。参数 `SD_SCORE_ENABLE=1` 可显式启用 SD 乐谱路径，SD 模式仍使用钢琴音源。KEY0 每按一次播放/停止经典 Marimba PCM 参考铃声；PCM 播放期间 KEY1 不触发合成音。手动模式下 KEY1 在停止 PCM 后触发下一个马林巴音符；KEY2 是低有效复位，复位后回到默认马林巴试听。SD SPI 控制器在默认模式下保持复位。

钢琴使用 88 键 DDS 与 ADSR。马林巴为独立的 31 音参数合成器，手动音域 B2–F5，事件号直接使用 MIDI 47–77。这个手动事件编号与钢琴的 A0 起始索引不同，不能混用。`assets/marimba/source/` 保存 University of Iowa MIS 的 96 kHz、24 位、双声道 yarn mallet pp/mf/ff 源 AIFF。`tools/fit_marimba_params.py` 解码文件实际采样率，按音高验证逐音起音，独立测量三种力度；当前 ROM 使用一套连贯的 mf 模态，并保留实测频率比例，将基音校准为 A4=440 Hz 的十二平均律。

每音最多四个模态，加短槌击噪声和独立琴体滤波。源录音按秒拟合衰减，再换算到输出采样率，生成 `src/rom/marimba31.hex` 和 `marimba_attack31.hex`。弱到无法可靠拟合及超过奈奎斯特频率的模态关闭。音量在完整整数合成、噪声、琴体和限幅链之后逐音校准。低音补偿在 B2 取 +4 dB，沿半音位置按余弦曲线平滑降至 C4 的 0 dB，C4 及以上保持原参数；补偿幅度可在 `tools/fit_marimba_params.py` 的 `BASS_BOOST_DB` 调整。校准指标为固定力度 192 时的 300 ms 加权 RMS，不是 LUFS 或实测声压。FPGA 仍逐样本实时合成，不读取录音。note-off 不截断尾音。硬件采样率约 16.276 kHz、奈奎斯特约 8.138 kHz。

重新拟合运行 `python tools/fit_marimba_params.py`（NumPy/SciPy；优先使用 `output/audio_tools` 的依赖）。`sim/tb_marimba_wav.sv` 导出实际 RTL 采样；随后运行 `python tools/check_marimba_audio.py` 和 `python tools/export_marimba_wav.py`。检查报告为 `sim/marimba_corrected_report.json`，试听 WAV 不做逐音归一化。错误版本保存在 `sim/marimba_before_fix/`，历史诊断见 `sim/marimba_source_audit/FINDINGS.md`。

低音补偿前的正确音色保存在 `sim/marimba_before_bass_boost/`。最新试听为 `sim/marimba_B2_F5_bass_boost.wav`（完整 31 音）和 `sim/marimba_B2_C4_bass_boost.wav`（低音至中音过渡）。

SD 接口使用 3.3 V SPI：MISO AA15、SCK V15、CS W15、MOSI Y16。其余 PT8211 和按键沿用原板卡引脚。SD 初始化和读取都使用约 397 kHz SPI 时钟。音频输出保持参考采样库的 16.276 kHz 采样率。

## 乐谱格式与音源

`PIANO.BIN` 使用 P88S v1：16 字节头部，之后每事件 8 字节，字段均为小端序。事件含毫秒时间、声部槽位 0--7、音符索引 0--87（A0--C8）、力度和保留字节；最后是结束事件。FPGA 检查头部、长度、事件顺序、结束记录、文件 EOF，以及 SD 扇区 CRC16。

SD 卡只保存乐谱事件，不保存钢琴 PCM 波形；音频波形由 DDS 在 FPGA 内实时生成。

## 快速构建

在工程根目录运行：

```powershell
& "D:\Gowin\Gowin_V1.9.12.03_x64\IDE\bin\gw_sh.exe" tools/build.tcl
powershell -ExecutionPolicy Bypass -File sim/run.ps1
powershell -ExecutionPolicy Bypass -File sim/run_score.ps1
```

第二条仿真命令覆盖 SD 卡、FAT、P88S 解析和乐谱调度的端到端测试。

完整回归命令为 `sim/run.ps1`、`sim/run_score.ps1`、`sim/demo.ps1`、`sim/bass.ps1` 和 `sim/tone_realism.ps1`。需要生成 ROM 表时运行 `python tools/generate_tables.py`。Gowin 版本、成功记录及板级验证限制见 `VERIFICATION.md`。

## 操作

默认配置为逐音试听，不访问 SD 卡。将 `SD_SCORE_ENABLE` 设为 1 后可启用乐谱路径；SD 仍只提供事件，音频波形由 DDS 实时合成。

| 按键 | 行为 |
| --- | --- |
| KEY2 | 低有效复位；复位后回到默认马林巴 |
| KEY0 | 播放/停止实验性经典 Marimba PCM 参考铃声 |
| KEY1（默认模式） | 停止 PCM 后触发下一个马林巴音符：B2–F5 |
| KEY1（启用 SD 乐谱时） | 从头重播 SD 卡乐谱 |

钢琴新音触发时释放前一个音；马林巴按 one-shot 衰减，不受 note-off 截断。KEY0/KEY1 使用双触发器同步与去抖；KEY2 作为异步低有效复位输入，并在系统时钟域同步释放。逐音模式沿用 `dynamics_fixed.v` 的 Q0.8 力度接口，后续可替换为压力传感器。
正在发送的一帧必须保持左右声道字一致，不能从半个字中间截断；因此模拟输出最迟在下一完整帧更新，约 20.83 us，另有 DAC 自身的更新延迟。

## 实时生成与存储边界

可综合代码只读以下函数、参数文件：

| 文件 | 内容 | 大小 |
| --- | --- | --- |
| `src/rom/sine256.hex` | 一个周期的数学正弦函数，16 位有符号、峰值 30000 | 256 点，512 字节 |
| `src/rom/frequency88.hex` | A0 至 C8 的 32 位 DDS 频率控制字 | 88 项，352 字节 |
| `src/rom/voicing88.hex` | 每键 8 个泛音权重、响度增益、衰减比例、弦刚度步进 | 88 项，每项 140 位 |

ADSR 基础参数写在 RTL 中；每键的衰减步长 ROM 在综合时由这些常量计算。
钢琴和马林巴实时合成链不读取录音。PCM 实验例外：`ringtone_pcm_player.v` 使用 IMA ADPCM 参数和 ROM 播放一段 8.78 秒的立体声参考铃声，专门用于听感对比，不参与马林巴实时音源。
`tools/generate_tables.py` 根据 `sin()`、十二平均律及人工设置的音色锚点生成上述函数、参数表。
`voicing88.hex` 不存逐时刻幅度曲线，也不含从录音提取的参数轨迹。

每个采样时刻依次执行：

1. 读取声部当前的 gate、触发标志、DDS 相位和 ADSR 状态。
2. 更新包络与相位；相位步进由当前音高倍率乘以频率字产生。
3. 更新 1～8 阶分音的独立相位，访问同一张正弦表；双端口同时读取邻点并进行线性插值。
4. 乘谐波权重、动态亮度与高频防混叠权重，累加各次谐波。
5. 乘 ADSR、该音符锁存的 dynamics 及每键响度补偿；累加所有活跃声部。
6. 固定主增益、峰值限制、四舍五入和最终饱和，再生成本帧的 16 位 PCM。

因此改变 note-on/note-off 时刻或运行中的音高倍率，会改变后续逐样本计算，不涉及选择一段现成录音。
`sim` 下生成的 TXT/WAV 是**仿真结果**，不在工程输入文件中，也不被任何可综合模块读取。
保留了这些结果用于频谱检查和试听，不应把它们重新接入 FPGA 播放链。

## 合成参数

音符索引 `0=A0`，`48=A4`，`87=C8`；对应 MIDI 编号 `21+index`。
频率公式为 `27.5 * 2^(index/12)`，DDS 字为 `round(f * 2^32 / 48000)`。
A4 控制字为 **39370534**，不是 39406372。
当前播放器的 PT8211 采样率约为 16.276 kHz，因此 `piano_score_player` 将
`pitch_ratio` 设为 **193274/65536 ≈ 2.94912**，把 48 kHz 归一化的频率表换算到实际板级采样率；
独立 `piano_synth` 接口仍以 `65536=1.0` 作为 48 kHz 标准倍率。

本次低音改进的资料来源、取舍及公式见 `BASS_VOICING.md`。
A3 及以上的基础权重仍为 `[420,220,140,90,60,42,30,22] / 1024`。
A0 的基础权重为 `[150,250,215,155,105,70,45,34] / 1024`，突出第 2、3 分音，
在 A0/A1/A2/A3 锚点间逐半音平滑插值；每键基础权重的总和始终为 1024。
低音还保留一个每声部独立的亮度衰减状态，较高阶分音较快变暗，较低阶分音保留更多能量。
音区补偿增益分别约为 A0 的 4.40 倍、A1 的 3.02 倍、A2 的 1.875 倍、
A3 的 1.125 倍、A4 的 1 倍；
各锚点之间按分贝逐半音插值，相邻键的补偿差小于 0.4 dB。
本次仅将 A0、A1 增益上调约 10%（约 0.83 dB），A2 上调约 7%（约 0.6 dB），
A3 及以上不变；锚点间采用等分贝步进，限制相邻键的补偿变化。
A4 至 C8 的基础频谱权重、包络和增益沿用原版；所有音符均使用相同的短起音增强。

`HAMMER_TRANSIENT` 保留约 10.7 ms 的确定性高阶分音起音增强。
另外实现了逐分音衰减、慢速拍频和琴槌噪声的实验分支，可分别通过
`PARTIAL_DECAY`、`UNISON_BEAT`、`HAMMER_NOISE` 参数启用。
这些分支在默认 FPGA 配置中关闭；
启用前必须重新检查流水线预算并通过 50 MHz 布局时序检查。它们不是完整琴槌—多弦物理模型。

低音分音频率采用轻微弦刚度近似 `step_h = h*step_1 + (h^3-h)*stiffness_step`。
标准基频保持原来的频率字，h=1 的修正严格为零；不对整个键盘做拉伸调律。
例如 A0 基频仍约 27.5 Hz，第 8 分音约 220.214 Hz；A3 起刚度修正为零。
必须保存各分音相位并逐样本累加，不能把已经回绕的基相位乘一个非整数倍率，
否则会产生相位跳变。本工程用状态 RAM 保存全部分音相位。

这是一种钢琴倾向的八谐波加法合成音色，88 键音高遵循十二平均律；不能把它描述成高保真采样钢琴。
已经近似弦非谐性并加入确定性的高阶分音起音增强；真实击弦噪声、多弦耦合、音板共鸣与踏板均未完整建模。
由于仅使用前 8 个分音，A0 的最高分音仍只在 220 Hz 附近。
本版补偿是通用起点，不能保证不同音响上的主观响度完全一致；音箱不能重放的低频也无法靠数字增益恢复。

谐波频率在 21～24 kHz 之间线性衰减，达到或超过 24 kHz 时权重为零。
例如 C8 的 6～8 次谐波不参与输出，避免折叠到可听频带。
线性插值使用 8 位表地址和后续 8 位小数，不额外存储谐波表。

ADSR 状态编码：`0=OFF, 1=A, 2=D, 3=S, 4=R`。
默认 A 约 5 ms，A0 的 D 约 1.60 秒，A1 约 0.80 秒，A2 约 0.53 秒，A3 及以上约 0.40 秒。
S 为峰值的 18.75%，R 最多约 341.4 ms。
R 步长在松键时根据**当时**的包络电平计算，A/D/S 任意阶段松开均可正常释放。
重复触发同一个音符时，该音符声部重新起音；不为同一音高额外分配第二份 Release 尾音。

## 复音与扩展接口

`piano_synth` 固定保存 88 份独立相位、包络、释放步长、力度和起音亮度状态。
不同音高可同时发声，KEY1 的轮询试听也允许上一音符的 R 与下一音符重叠。
这不是 88 路完整算术电路并行铺开，而是 88 份独立声部状态共用一个分时运算单元。
每个声部的 8 个分音各自保存相位，以支持弦非谐性并保持相位连续；
音高和包络仍由所属声部控制，不是 704 个可任意独立演奏的音符。

外部事件源后续接在核心模块的这些端口：

| 端口 | 约定 |
| --- | --- |
| `event_valid` / `event_ready` | 同一音频时钟域；在二者同时为 1 的上升沿接受事件 |
| `event_on` | 1 为 note-on，0 为 note-off |
| `event_note[6:0]` | 0～87；非法编号被忽略 |
| `event_dynamics[7:0]` | 无符号 Q0.8，note-on 时锁存 |
| `stop_all` | 同步高有效，优先级最高，立即清除所有声部和输出缓存 |
| `pitch_ratio[17:0]` | 全局无符号 Q2.16 音高倍率；65536=原音高，98304=1.5 倍 |

发送者应保持 valid 和负载直到握手成功。FETCH 状态每次只占一个周期，其间 ready 为 0。
同一个音符的密集 note-on 在声部处理前合并为一次重触发；该接口不是任意长度的事件 FIFO。
跨时钟域接入时需要另加事件 FIFO，不能直接连接异步串口解析脉冲。
松键事件必须携带原 note-on 对应的音符编号，不应依据已经切换的选音组重新计算。

`dynamics_fixed` 单独保留了力度接口，当前固定输出 `192/256=0.75`。
以后只需替换该模块及事件来源，不能把当前常量视为已经实现了压力感应。
本版只接入按键这一种演奏维度，整项赛题要求的第二个演奏维度仍需后续加入。

## 时钟与位宽

工程全部模块直接使用板载 **50 MHz `sys_clk`**，没有额外的倍频时钟链。
`pt8211_score_tx` 的 `BCK_HALF_DIV=48`，所以 BCK 为 `50 MHz/(2*48)=520.833 kHz`；
每个立体声帧 32 个 BCK，当前硬件采样率约为 **16.276 kHz**，与原板卡播放器时序一致。

当前硬件每帧有 `32*2*48=3072` 个系统时钟。全 88 声部均活跃时会处理 704 个谐波分量，高于奈奎斯特频率的分量权重为零。
本次回归测得最坏情况下 PCM 在触发后 2861 周期内就绪，原版为 3121 周期；
在当前 50 MHz 顶层下仍有约 211 个系统时钟的帧内余量。独立 `piano_synth` 回归验证核心算法，板级 50 MHz 时钟及 3072 周期帧节拍由播放器集成测试覆盖。
`deadline_error` 是错过采样预算的粘滞标志，仿真必须检查它。
逻辑上只有一张 256 点正弦函数表；当前 Gowin 综合器为实现双路读取，
将同一内容映射为两个 pROM 读副本。它们不是不同音符或谐波的专用波表。

正弦峰值 30000，基础谐波权重总和不超过 1；ADSR 与 dynamics 均不放大，
每键响度补偿最多放大约 4.4 倍。
谐波用 32 位有符号累加，乘包络和力度时继续扩展，声部混合使用 32 位有符号数。
主增益固定为 1/4，不按活跃音符数直接相除，避免每次按键都改变其他音符音量。
在大和弦需要更多余量时，当前样本的峰值先被检测，再计算安全增益：
峰值瞬时跟随上升，以约 85 ms 时间常数回落，输出峰值限制在约 30000。
限制器用 36 周期恢复除法计算 Q20 增益，每周期移位、比较、减法，不使用大组合除法器。
峰值路径扩为 22 位，即使保守假设全部 88 键都使用最大 4 倍补偿也有足够空间。
不靠硬削顶调音量；末端另有 16 位饱和作为最后保护。
`limiting` 指示正在降低增益，`saturated` 指示末端出现越界；正常测试要求 saturated 为 0。
外部功放只负责模拟增益，不能修复数字溢出。

## 模块与引脚

`GW_PROBLEM_TOW.v` 仅有端口、连线和模块例化。
`piano_score_player.v` 管 50 MHz 系统集成与复位；`key_control.v` 管独立按键试听；
`dynamics_fixed.v` 提供后续替换为压力传感器的 Q0.8 力度接口；
`adsr_step.v` 中的 `adsr_pipeline` 管包络；`piano_synth.v` 管 DDS/谐波/复音；
`output_limiter.v` 管主增益与限制；`pt8211_score_tx.v` 管当前串行音频输出。

引脚沿用板卡原理图和参考工程已使用的 PT8211 连接：

| 信号 | 管脚 | 电平 |
| --- | --- | --- |
| sys_clk | V22 | 3.3 V |
| KEY0 / KEY1 / KEY2 | AA13 / AB13 / Y12 | 1.5 V，上拉，低有效 |
| HP_BCK / HP_WS / HP_DIN | Y17 / AB17 / AA16 | 3.3 V |
| PA_EN | AB16 | 3.3 V，低电平开启功放 |

PT8211 使用 16 位 LSBJ、MSB 先发，不能换成带一位延迟的标准 I2S。
WS=0 右声道，WS=1 左声道；两个声道来自同一帧锁存的同一个 PCM 字。
复位后等待约 50 ms 再开启板载功放。

## 深入验证

`sim/run.ps1` 在 ModelSim 中验证按键、88 音轮询、ADSR、尾音重叠、88 复音、变调、强制停止、增益限制和 PT8211 帧格式。
`sim/run_score.ps1` 运行完整乐谱链路及 50 MHz 播放器集成测试。
快速合成测试缩短了包络时间，便于观察状态转换；完整音频测试使用默认实际参数。
`sim/demo.ps1` 生成约 2.63 秒的 RTL 音频，并将前 24000 个样本与独立数学模型逐点核对，检查频谱、混叠与限幅，输出 `sim/audio_report.json`。
该音频测试需要 NumPy，仅分析脚本依赖它；RTL 和 Gowin 构建不依赖 NumPy。

`sim/bass.ps1` 比较原版与当前版本 A0、A1、A2、A4 的起音、保持、松开，共 216000 对样本；
两版均由 RTL 实时生成，并分别与独立定点模型逐样本核对；当前版包含击弦起音增强。
为缩短比较时间，该核心测试省略运算完成后的空闲时钟，PCM 序列仍按 48 kHz 解释；
真实 3200 周期采样间隔另由 `tb_demo` 和 `tb_dac` 验证。
`sim/bass_before.wav` 和 `sim/bass_after.wav` 均为固定增益、左右相同、48 kHz 的仿真试听结果，
没有分别归一化音量，可直接比较。`sim/bass_report.json` 保存响度和频率测量结果。
`sim/tone_realism.ps1` 显式启用实验性逐分音衰减、拍频和琴槌噪声，
生成单音 A4 试听 `sim/tone_realism.wav`；该试听不是默认 FPGA 配置。
`BASS_VOICING=0` 仅用于同一 RTL 的原版音色对照；顶层默认启用新音色。

现场运行 `powershell -ExecutionPolicy Bypass -File sim/gui.ps1` 打开 ModelSim 波形界面；
已有 `tb_synth` 仿真时可直接执行 `do sim/waves.do`。
观察 `valid/ready/note_on/note`、A4 的 `phase_a4/envelope_a4/state_a4`、分时谐波计算和最终 PCM：
松开时钢琴声部进入 R，R 期间相位继续变化；马林巴的 note-off 不会截断正在衰减的模态尾音。
波形脚本默认使用缩短 ADSR 的快速自测，完整默认时长可运行 `tb_demo`。
这些测试提供实时生成的技术证据，最终赛题判定仍以评审检查实际 RTL 和演示为准。

构建结果与实际验证数据见 `VERIFICATION.md`。尚未完成板上试听，仿真不能替代下载后的电气和音质检查。
