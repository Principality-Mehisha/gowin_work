# Tang Mega 60K 实时钢琴与马林巴播放器

工程入口：`GW_PROBLEM_TOW.gprj`；器件：`GW5AT-LV60PG484AC1/I0`；系统时钟50 MHz。
SD卡保存音符事件，FPGA实时合成声音，经PT8211输出。当前仅保留钢琴和马林巴；单簧管及其专用DDR子系统已完整移除。

新增HC-05蓝牙上传：115200/8N1，FPGA TX=D15、RX=D16，模块直接例化在顶层。
使用预分配的PN001.BIN～PN100.BIN和MB001.BIN～MB100.BIN共200个100 KiB文件槽位，
BEGIN后先清零目标槽位，回复READY；手机随后连续透传文件字节，DATA阶段不分包、不逐块确认。
SD卡需先用离线工具生成专用FAT32布局镜像，不能直接在普通格式的卡上上传。
蓝牙使用协议v2，与旧分包协议不兼容；串口屏协议保持原v1。
播放仍由串口屏CMD=0x12按乐器及编号控制。上传和播放由操作者错开，不支持同时读写。
协议、PC发送工具、200个按钮脚本及失败边界见 [蓝牙上传](docs/BLUETOOTH_UPLOAD.md)。

## 操作

| 输入 | 行为 |
| --- | --- |
| KEY0 / KEY1 | 仅保留顶层引脚，不参与控制 |
| KEY2 | 低有效复位，恢复钢琴A0和马林巴C2的试听选择 |
| UART选曲 | CMD=0x12：PN001～PN100、MB001～MB100 |
| UART单音 | 十六进制40=上一个音，41=下一个音，42=播放 |
| UART乐器 | 十六进制43=钢琴，44=马林巴 |

UART默认115200/8N1。选音不发声；播放约0.5秒后释放，再保留约1秒尾音窗口。
钢琴支持A0～C8共88音，马林巴支持C2～B5共48音，分别记忆选择，单音试听无需SD卡。
旧三首选曲命令0x10及旧乐器命令0x45均返回不支持，不改变播放状态。
协议和接线见 [UART接口](docs/UART_SCREEN.md)、[单音试听](docs/UART_THREE_KEYS.md)。

HDMI使用UART命令0x50、参数0/1/2切换键盘背景、实时频谱和实时波形，详见 [三种显示与按钮帧](docs/PIANO_ANALYSIS.md)。
分析直接使用钢琴DAC采样，无需SD查表。已解除旧第3首与固定瀑布流ROM的绑定；
编号曲目不显示旧乐谱，当前也没有上传曲目的动态瀑布流。声音仍由PT8211输出。

## 结构

```text
GW_PROBLEM_TOW
├─ piano_score_player：板级接口层
│  ├─ board_reset：上电延时及KEY2复位
│  ├─ uart_score_control：串口屏协议和反馈
│  ├─ sd_score_stream：SPI → 固定槽位读取/CRC → 解码 → FIFO/定时事件
│  ├─ pt8211_score_tx：采样节拍与DAC串行输出
│  └─ instrument_system：演奏控制、全局音色、事件选择、错误静音
│     └─ instrument_voice_bank：钢琴 / 马林巴 → 共用限幅器
├─ bluetooth_file_receiver：独立UART连续流、32 KiB FIFO及固定槽位写入
└─ piano_video：视频时钟、快照跨域、键盘/频谱/波形与TMDS
```

`src/board` 保存顶层、复位及CST/SDC；`control` 保存协议与播放控制；`system` 保存演奏集成；
`storage` 保存SD/FAT/解码/调度；`audio` 保存合成、滤波、限幅及DAC；`rom` 保存五张音频表；`video` 保存视频逻辑。
`tools` 为数据生成、构建和检查工具；`sim` 为测试；`screen` 为串口屏脚本。
`sd_card`、`assets` 和 `source` 保留离线历史样本，不是当前SD部署清单，也不再向初始化镜像加入原三首。
`impl`、`output` 为构建产物和验证证据。`.gprj` 是RTL清单的统一入口，仿真也从它读取源码。

见 [架构说明](docs/ARCHITECTURE.md)、[音频与SD](docs/AUDIO_AND_SD.md)；`docs/instrument_architecture.svg`为历史结构示意。

## 构建与验证

需要Gowin EDA V1.9.12.03、Python 3，以及PATH中的ModelSim `vlib/vlog/vsim`。

```powershell
python tools/check_project.py
powershell -ExecutionPolicy Bypass -File sim/run_upload.ps1
& 'D:/Gowin/Gowin_V1.9.12.03_x64/IDE/bin/gw_sh.exe' tools/build.tcl
python tools/check_upload.py --require-build
```

位流为 `impl/pnr/GW_PROBLEM_TOW.fs`，通过构建检查后复制到 `output/GW_PROBLEM_TOW.fs`。
基础及原有完整音频回归入口为 `sim/run_all.ps1`；三模式显示回归为 `sim/run_analysis.ps1`，
蓝牙上传及编号曲目回归为 `sim/run_upload.ps1`。
验证结果见 [VERIFICATION.md](VERIFICATION.md)，当前证据在 `output/numbered_only/verification.json`。
本次修改前的源码和位流备份在 `output/numbered_only/before/`，不包含大型磁盘镜像。
此前版本的源代码、已删除素材和位流备份在 `output/no_clarinet/before/`。

默认 `SD_SCORE_ENABLE=0`，上电等待UART操作；设为1可在复位后自动播放PN001一次。
原有200槽位地址、描述符和有效记录格式不变，已成功上传的PN001/PN002无需重传，也无需重刷SD卡。
KEY2复位接口及UART、SD和视频时间的仿真加速参数保留。
管脚约束见 `src/board/GW_PROBLEM_TOW.cst`：时钟V22，KEY0/1/2为AA13/AB13/Y12，UART RX/TX为B17/B18。
SD MISO/SCK/CS/MOSI为AA15/V15/W15/Y16，PT8211 BCK/WS/DIN/PA_EN为Y17/AB17/AA16/AB16。
球位不能直接当作排针脚号。
