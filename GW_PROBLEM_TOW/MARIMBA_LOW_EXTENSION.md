# C2–F5 马林巴低音扩展

本次将最低音从 B2（MIDI 47）降到 C2（MIDI 36，约 65.406 Hz），上限仍为 F5（MIDI 77），共 42 个半音。新增 C2、C♯2、D2、D♯2、E2、F2、F♯2、G2、G♯2、A2、A♯2 共 11 音。

C2 是常见五组马林巴的最低音，本次不继续扩展至 C2 以下。参考 [Yamaha 对五组马林巴音域发展的说明](https://hub.yamaha.com/music-educators/instruments/perc/what-marimba-should-i-purchase/)。

新增音符直接来自工程内 `assets/marimba/source/{pp,mf,ff}/Marimba.yarn.*.C2B2.aif`，按实际 96 kHz 采样率解析、抗混叠重采样到 24 kHz 后逐音验证起音，再拟合基音/模态频率、增益、衰减与槌击瞬态。三种力度分别测量，当前 ROM 继续使用 mf。基音调至 A4=440 Hz 十二平均律，保留实测模态比；FPGA 仍逐样本实时生成，不播放这些源录音。

低音补偿在 C2–B2 保持 +3 dB，B2–C4 沿用上一版的余弦曲线，不因最低音变化而重算原曲线。300 ms 加权 RMS 校准包含模态、噪声、琴体滤波和限幅。该指标不是 LUFS，也不保证扬声器声压一致。

RTL 的音符索引扩至 6 位，四模态地址扩至 8 位，状态数组容纳 42 音/168 模态。噪声起始种子按 MIDI 音高固定，因此原 B2–F5 不会因内存槽位移动而改变起音。原包络精度、模态算法和琴体滤波维持原设计，本次没有混入此前高音分析中提出的其他音色改动。

默认 KEY1 试听顺序为 C2 → C♯2 → … → F5 → C2；KEY2 复位后回到 C2，KEY0 保持参考铃声播放/停止。

| 文件 | 作用 |
| --- | --- |
| `src/rom/marimba42.hex` | 当前 42 音模态参数 |
| `src/rom/marimba_attack42.hex` | 当前 42 音起音参数 |
| `assets/marimba/fit_report.json` | 完整源数据、三力度拟合与校准 |
| `sim/marimba_before_low_extension/` | 原 31 音 ROM、报告、工具和试听快照 |
| `sim/marimba42_report.json` | 当前 42 音 RTL/整数模型、音高、音量及旧音保留校验 |
| `sim/marimba_C2_B2_realtime.wav` | 新增低音加原 B2 的衔接试听 |
| `sim/marimba_C2_C3_realtime.wav` | 含跨原边界的低音试听 |
| `sim/marimba_C2_F5_realtime.wav` | 完整 42 音试听 |
| `sim/marimba_wav/` | 各音独立 WAV |

仿真 WAV 保留实际 RTL 幅度，不逐音归一化；每音末尾加 10 ms 淡出只用于试听封装。WAV 为单声道，板级合成输出仍复制到左右声道。

验证入口：`sim/run.ps1` 包含边界/复音与按键回绕测试；完整 WAV 导出测试平台为 `sim/tb_marimba_wav.sv`，完成后运行 `python tools/check_marimba_audio.py` 和 `python tools/export_marimba_wav.py`。脚本依赖优先读取本地 `output/marimba_tools`。`tools/build.tcl` 生成位流并检查布局时序。

42 音同时触发的首帧耗时 2184 时钟，预算为 3072；50 MHz 布局时序通过，Fmax 58.827 MHz，Setup/Hold 违规 0/0。状态规模增大后 BSRAM 为 94/118，后续再扩大音域需要重新检查资源和时序。本次未烧录或进行板级音响实测。
