# Tang Mega 60K 实时钢琴与马林巴播放器

工程入口：`GW_PROBLEM_TOW.gprj`；器件：`GW5AT-LV60PG484AC1/I0`；系统时钟50 MHz。
SD卡保存音符事件，FPGA实时合成声音，经PT8211输出。当前仅保留钢琴和马林巴；单簧管及其专用DDR子系统已完整移除。

## 操作

| 输入 | 行为 |
| --- | --- |
| KEY0 / KEY1 | 仅保留顶层引脚，不参与控制 |
| KEY2 | 低有效复位，恢复钢琴A0和马林巴C2的试听选择 |
| UART选曲 | 1=ANDROID.BIN，2=RINGTONE.BIN，3=PIANO.BIN |
| UART单音 | 十六进制40=上一个音，41=下一个音，42=播放 |
| UART乐器 | 十六进制43=钢琴，44=马林巴 |

UART默认115200/8N1。选音不发声；播放约0.5秒后释放，再保留约1秒尾音窗口。
钢琴支持A0～C8共88音，马林巴支持C2～B5共48音，分别记忆选择，单音试听无需SD卡。
旧的选曲4返回参数错误，旧的乐器命令0x45返回不支持，不改变播放状态。
协议和接线见 [UART接口](docs/UART_SCREEN.md)、[单音试听](docs/UART_THREE_KEYS.md)。

播放第3首钢琴乐谱时，1600×900/60 Hz HDMI/DVI瀑布流跟随实际音频时间，琴键按已接收事件点亮。
声音由PT8211输出。替换PIANO.BIN后须同步生成视频谱面ROM，见 [钢琴视频](docs/PIANO_HDMI.md)。

## 结构

```text
GW_PROBLEM_TOW
├─ piano_score_player：板级接口层
│  ├─ board_reset：上电延时及KEY2复位
│  ├─ uart_score_control：串口屏协议和反馈
│  ├─ sd_score_stream：SPI → FAT → 解码 → FIFO/定时事件
│  ├─ pt8211_score_tx：采样节拍与DAC串行输出
│  └─ instrument_system：演奏控制、全局音色、事件选择、错误静音
│     └─ instrument_voice_bank：钢琴 / 马林巴 → 共用限幅器
└─ piano_video：视频时钟、快照跨域、瀑布流与TMDS
```

`src/board` 保存顶层、复位及CST/SDC；`control` 保存协议与播放控制；`system` 保存演奏集成；
`storage` 保存SD/FAT/解码/调度；`audio` 保存合成、滤波、限幅及DAC；`rom` 保存五张音频表；`video` 保存视频逻辑。
`tools` 为数据生成、构建和检查工具；`sim` 为测试；`screen` 为串口屏脚本；`sd_card` 为三首部署乐谱；`assets` 和 `source` 保存来源素材。
`impl`、`output` 为构建产物和验证证据。`.gprj` 是RTL清单的统一入口，仿真也从它读取源码。

见 [架构说明](docs/ARCHITECTURE.md)、[音频与SD](docs/AUDIO_AND_SD.md)、[SVG架构图](docs/instrument_architecture.svg)。

## 构建与验证

需要Gowin EDA V1.9.12.03、Python 3，以及PATH中的ModelSim `vlib/vlog/vsim`。

```powershell
python tools/check_project.py
powershell -ExecutionPolicy Bypass -File sim/run_structure.ps1
& 'D:/Gowin/Gowin_V1.9.12.03_x64/IDE/bin/gw_sh.exe' tools/build.tcl
python tools/check_structure.py
```

位流为 `impl/pnr/GW_PROBLEM_TOW.fs`，通过构建检查后复制到 `output/GW_PROBLEM_TOW.fs`。
基础及原有完整音频回归入口为 `sim/run_all.ps1`；当前变更的针对性集成回归为 `sim/run_structure.ps1`。
验证结果见 [VERIFICATION.md](VERIFICATION.md)，当前证据在 `output/no_clarinet/verification.json`。
此前版本的源代码、已删除素材和位流备份在 `output/no_clarinet/before/`。

默认 `SD_SCORE_ENABLE=0`，上电等待UART操作；设为1可在复位后自动播放钢琴乐谱。
KEY2复位接口及UART、SD和视频时间的仿真加速参数保留。
管脚约束见 `src/board/GW_PROBLEM_TOW.cst`：时钟V22，KEY0/1/2为AA13/AB13/Y12，UART RX/TX为B17/B18。
SD MISO/SCK/CS/MOSI为AA15/V15/W15/Y16，PT8211 BCK/WS/DIN/PA_EN为Y17/AB17/AA16/AB16。
球位不能直接当作排针脚号。
