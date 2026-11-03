# Tang Mega 60K 实时钢琴与马林巴播放器

工程入口：`GW_PROBLEM_TOW.gprj`；器件：`GW5AT-LV60PG484AC1/I0`；系统时钟50 MHz。
音频域现改为官方PLL的150 MHz，原生合成及DAC采样率48828.125 Hz；
控制、压力扫描、UART/蓝牙和SD仍为50 MHz，双时钟传输使用官方FIFO。
本轮未编译主工程或更新位流，最终编译由用户执行，详见[150 MHz音频域](docs/AUDIO_150MHZ.md)。
马林巴参数ROM重排和双音色正弦表复用已由用户编译确认BSRAM降至106/118，见[ROM优化](docs/ROM_SHARING.md)。
当前完成首轮效果器流水、事件通路及CDC/复位修正，功能回归通过，但尚未重新综合/PnR，
不能宣称150 MHz时序已收敛；新增系统域专属报告供下一轮定位，见[时序修正](docs/TIMING_150MHZ.md)。
SD卡保存音符事件，FPGA实时合成声音，经PT8211输出。当前仅保留钢琴和马林巴；单簧管及其专用DDR子系统已完整移除。

完整16键压力输入：钢琴支持持续力度及原音高分组，马林巴使用前三组覆盖C2～B5共48音，
按下时的压力决定敲击力度，之后自然衰减，按住不重复敲击。SD播放和串口屏试听期间暂停压力输入。
切回后仍按住的键需先松开再按，KEY2重新校准时保持全部松键。
八路GPIO LED现为长按进度条：每约0.5秒增加一灯，4秒八灯全亮；多键取最长，松键后回落或全灭。
两种压力音色均支持长按灯；SD/试听及校准期间全灭，旧状态灯用途已移除；独立静态彩灯保持不变。
接线、行为及仿真入口见[压力钢琴](docs/PRESSURE_KEYBOARD.md)。当前构建与验证结果见[验证记录](VERIFICATION.md)。

新增16灯SD钢琴演奏指引：LED_indicator_dynamic接C19、3.3 V，灯位置对应物理键，
颜色沿用静态灯前六种配色。最高音所在组优先，同组和弦同时亮灯，其余组仅播放不指引。
PN曲目自动启用，休止/结束/停止/切到马林巴或手动模式后熄灭；原七灯静态配色与八灯长按功能不变。
无需修改已有BIN或串口屏，接线、规则及仿真见[动态指引灯](docs/KEY_GUIDE.md)。
本轮仅做代码检查与仿真，未更新位流，最终Gowin编译由用户执行。

共用数字效果器：原声、延迟、震音（音量调制）、颤音（音高调制）四种互斥模式，效果量0～100，
串口屏命令0x51/0x52控制，适用于两种音色及压力/试听/SD播放。频谱和波形观察处理后的DAC样本，
钢琴瀑布流逻辑不变。默认原声；所有模式增加固定一音频帧约20.48 us流水延迟。
HMI需增加n6/n7、四个模式按钮、一个滑块及定时器，事件脚本和接入说明见[数字效果器](docs/AUDIO_EFFECTS.md)；
本仓库未提供用户实际.HMI/.TFT，脚本尚需在屏幕IDE编译；板上听感仍需试听确认。

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
| KEY2 | 低有效复位，恢复试听选择，并重新校准压力键盘 |
| 压力键盘 | 手动钢琴状态16键演奏，按住可持续改变力度 |
| LEDs[7:0] | 低有效长按进度条，0.5～4秒八档累计点亮 |
| LED_indicator_dynamic | C19，16灯SD钢琴同步指引，最高音所在组优先 |
| UART选曲 | CMD=0x12：PN001～PN100、MB001～MB100 |
| UART单音 | 十六进制40=上一个音，41=下一个音，42=播放 |
| UART乐器 | 十六进制43=钢琴，44=马林巴 |
| UART效果 | 十六进制51：0原声、1延迟、2震音、3颤音；52：效果量0～100 |

UART默认115200/8N1。选音不发声；播放约0.5秒后释放，再保留约1秒尾音窗口。
钢琴支持A0～C8共88音，马林巴支持C2～B5共48音，分别记忆选择，单音试听无需SD卡。
旧三首选曲命令0x10及旧乐器命令0x45均返回不支持，不改变播放状态。
协议和接线见 [UART接口](docs/UART_SCREEN.md)、[单音试听](docs/UART_THREE_KEYS.md)。

HDMI使用UART命令0x50、参数0/1/2切换实时瀑布流、实时频谱和实时波形，详见 [三种显示与按钮帧](docs/PIANO_ANALYSIS.md)。
瀑布流观察钢琴合成器实际接受的开关音符，压力键盘、UART单音试听和SD编号钢琴曲目共用；
按下后在下一视频帧从顶部出现并向下滚动，条长跟随按住时长，琴键跟随当前音符亮灭。
保留最近约3秒轨迹，不依赖固定乐谱ROM、未来音符预读或新增SD文件。
频谱/波形共用实际DAC采样分析，现已支持钢琴和马林巴；瀑布流仍只属于钢琴。
详见 [实时瀑布流](docs/LIVE_WATERFALL.md)。声音仍由PT8211输出。

## 结构

```text
GW_PROBLEM_TOW
├─ piano_score_player：板级接口层
│  ├─ board_reset：上电延时及KEY2复位
│  ├─ uart_score_control：串口屏协议和反馈
│  ├─ sd_score_stream：SPI → 固定槽位读取/CRC → 解码 → FIFO/定时事件
│  ├─ audio_clock150：官方PLL及音频复位
│  ├─ pt8211_score_tx：150 MHz采样节拍与DAC串行输出
│  └─ instrument_system：演奏控制、全局音色、事件选择、错误静音
│     ├─ audio_domain_bridge：官方双时钟FIFO传递事件、确认及DAC样本
│     ├─ instrument_voice_bank：150 MHz钢琴 / 马林巴 → 共用限幅器
│     │  └─ sine_pair_rom：两种音色共用的双读口正弦表
│     └─ audio_effects：共享32 KiB缓存 → 平滑干湿混合/饱和 → DAC
├─ bluetooth_file_receiver：独立UART连续流、32 KiB FIFO及固定槽位写入
└─ piano_video：视频时钟、快照跨域、实时瀑布流/频谱/波形与TMDS
```

`src/board` 保存顶层、复位及CST/SDC；`control` 保存协议与播放控制；`system` 保存演奏集成；
`input/pressure`保存ADC扫描、分组选择、压力校准和事件处理；
`storage` 保存SD/FAT/解码/调度；`audio` 保存合成、滤波、限幅及DAC；`rom` 保存六张音频表（含保留的旧采样率模态表）；`video` 保存视频逻辑。
`tools` 为数据生成、构建和检查工具；`sim` 为测试；`screen` 为串口屏脚本。
`sd_card`、`assets` 和 `source` 保留离线历史样本，不是当前SD部署清单，也不再向初始化镜像加入原三首。
`impl`、`output` 为构建产物和验证证据。`.gprj` 是RTL清单的统一入口，仿真也从它读取源码。

见 [架构说明](docs/ARCHITECTURE.md)、[音频与SD](docs/AUDIO_AND_SD.md)；`docs/instrument_architecture.svg`为历史结构示意。

## 构建与验证

需要Gowin EDA V1.9.12.03、Python 3，以及PATH中的ModelSim `vlib/vlog/vsim`。
新增压力、实时瀑布流及数字效果功能已完成代码检查与仿真；下面的Gowin编译由用户执行。
使用IDE时重新载入工程以识别当前59个RTL文件（含官方PLL/FIFO和sine_pair_rom）；现有位流未因仿真而更新。

```powershell
python tools/check_project.py
powershell -ExecutionPolicy Bypass -File sim/run_timing150.ps1 -Full
powershell -ExecutionPolicy Bypass -File sim/run_rom_sharing.ps1
powershell -ExecutionPolicy Bypass -File sim/run_audio150.ps1
powershell -ExecutionPolicy Bypass -File sim/run_key_guide.ps1
powershell -ExecutionPolicy Bypass -File sim/run_effects.ps1
powershell -ExecutionPolicy Bypass -File sim/run_live_waterfall.ps1
powershell -ExecutionPolicy Bypass -File sim/run_pressure.ps1
powershell -ExecutionPolicy Bypass -File sim/run_upload.ps1
& 'D:/Gowin/Gowin_V1.9.12.03_x64/IDE/bin/gw_sh.exe' tools/build.tcl
python tools/check_upload.py --require-build
```

位流为 `impl/pnr/GW_PROBLEM_TOW.fs`，通过构建检查后复制到 `output/GW_PROBLEM_TOW.fs`。
基础及原有完整音频回归入口为 `sim/run_all.ps1`；三模式显示回归为 `sim/run_analysis.ps1`，
蓝牙上传及编号曲目回归为 `sim/run_upload.ps1`。
验证结果见 [VERIFICATION.md](VERIFICATION.md)，效果专项证据在 `output/audio_effects/verification.json`，
上传证据在 `output/numbered_only/verification.json`。
效果器修改前源码备份在 `output/audio_effects/before/sources.zip`，不包含大型磁盘镜像。
此前编号槽位修改前的源码和位流备份在 `output/numbered_only/before/`。
此前版本的源代码、已删除素材和位流备份在 `output/no_clarinet/before/`。

默认 `SD_SCORE_ENABLE=0`，上电等待UART操作；设为1可在复位后自动播放PN001一次。
原有200槽位地址、描述符和有效记录格式不变，已成功上传的PN001/PN002无需重传，也无需重刷SD卡。
KEY2复位接口及UART、SD和视频时间的仿真加速参数保留。
管脚约束见 `src/board/GW_PROBLEM_TOW.cst`：时钟V22，KEY0/1/2为AA13/AB13/Y12，UART RX/TX为B17/B18。
SD MISO/SCK/CS/MOSI为AA15/V15/W15/Y16，PT8211 BCK/WS/DIN/PA_EN为Y17/AB17/AA16/AB16。
球位不能直接当作排针脚号。
