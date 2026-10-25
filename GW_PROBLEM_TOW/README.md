# Tang Mega 60K 实时钢琴、马林巴与单簧管播放器

工程入口：`GW_PROBLEM_TOW.gprj`。器件：`GW5AT-LV60PG484AC1/I0`，板载时钟 50 MHz。
SD 卡保存音符事件，FPGA 实时计算钢琴、马林巴或单簧管波形，通过 PT8211 输出。

## 当前功能

| 输入 | 默认行为 |
| --- | --- |
| KEY0 | 从 SD 根目录播放 ANDROID.BIN，再按停止；结束返回手动试听 |
| KEY1 | 马林巴 C2～F5 的 42 音逐音试听，F5 后回到 C2 |
| KEY2 | 低有效复位，恢复默认模式及音符选择 |
| 串口选曲 | 1=ANDROID.BIN，2=RINGTONE.BIN，3=PIANO.BIN，4=CLARINET.BIN |
| 串口单音 | 40=上一个，41=下一个，42=播放；43=选择钢琴，44=选择马林巴，45=选择单簧管，命令均为十六进制 |

串口单音支持钢琴 A0～C8 共 88 音、马林巴 C2～B5 共 48 音及单簧管 D3～B♭6 共 45 音，分别记忆选择；复位选中钢琴 A0，马林巴初始 C2，单簧管初始 D3。
选音不发声，切换乐器清音；播放约 0.5 秒后发送释放，再保留约 1 秒尾音窗口。
音名和所选试听乐器自动回传至串口屏 `every.tNote`、`every.tInstrument`。单音试听不需要 SD 卡。

## 目录

```text
src/
  board/       引脚入口、系统集成、复位、CST/SDC
  control/     播放控制、按键、UART、单音试听、屏幕反馈
  storage/     SD SPI、FAT、乐谱解码和事件调度
  audio/       钢琴/马林巴/单簧管合成、包络、琴体滤波、限幅、PT8211
  rom/         当前六个函数/参数 ROM
tools/         构建、结构/时序检查、乐谱和音色生成工具
sim/           当前功能的测试平台和仿真入口
screen/        可复制到串口屏工程的事件脚本
sd_card/       四首 BIN、转换说明 JSON 和写卡记录
assets/        当前参数拟合及乐谱转写所需素材、来源说明
source/        钢琴 MIDI 及来源说明
docs/          架构、串口、音频/存储说明；reference/ 为设计参考资料
impl/          Gowin 生成结果（忽略版本跟踪）
output/        测试夹具、日志和可重建依赖（忽略版本跟踪）
```

`.gprj` 是当前 RTL 文件列表的唯一维护入口，仿真脚本从它读取源码。
`src/` 中只保留当前综合输入；旧 PCM/ADPCM 播放器、历史 ROM 和实现快照已移除。
`docs/reference/` 保留原始硬件和设计资料，当前操作与模块关系以本文及当前源码为准。

## 模块关系

```text
GW_PROBLEM_TOW
└─ piano_score_player：模块连接、事件选择和音频路由
   ├─ board_reset：上电延时、复位同步释放
   ├─ playback_control：播放归属、重启和错误锁存
   ├─ uart_score_control / uart_note_audition：命令、反馈和单音
   ├─ key_audition：实体按键试听
   ├─ sd_score_stream
   │  └─ SD SPI → FAT → 乐谱校验 → FIFO/定时事件
   ├─ piano_synth / marimba_synth / clarinet_synth：实时合成
   └─ pt8211_score_tx：输出采样节拍和 DAC 串行数据
```

单簧管为单声部实时加法合成，ROM 只存参数；接入与验证见 [单簧管说明](docs/CLARINET.md)。
第 4 首 SD 曲目为肖邦《夜曲》Op.9 No.2 单簧管独奏，文件和播放方法见 [夜曲说明](docs/NOCTURNE_CLARINET.md)。

详见 [架构说明](docs/ARCHITECTURE.md)、[音频与乐谱](docs/AUDIO_AND_SD.md)。
马林巴同步 RAM 优化及音频等价性验证见 [存储优化说明](docs/MARIMBA_STORAGE.md)。

## 硬件与串口

当前有效约束：`src/board/GW_PROBLEM_TOW.cst`、`src/board/GW_PROBLEM_TOW.sdc`。

| 信号 | FPGA 球位 |
| --- | --- |
| sys_clk | V22 |
| KEY0 / KEY1 / KEY2 | AA13 / AB13 / Y12 |
| UART RX / TX | B17 / B18 |
| SD MISO / SCK / CS / MOSI | AA15 / V15 / W15 / Y16 |
| PT8211 BCK / WS / DIN / PA_EN | Y17 / AB17 / AA16 / AB16 |

UART 波特率由 `piano_score_player.UART_BAUD` 决定，当前默认 115200/8N1；屏幕 TX 接 FPGA RX=B17，屏幕 RX 接 FPGA TX=B18，共地。
屏幕配置脚本和主机工具默认已对齐为 115200；沿用旧 9600 屏幕工程时须同步修改波特率。
串口屏供电按其规格独立提供。球位不能直接当作排针脚号。
屏幕设置、全部命令与返回字段见 [UART 接口](docs/UART_SCREEN.md)，五键与音名/乐器显示见 [三乐器逐音试听](docs/UART_THREE_KEYS.md)。

## 构建与验证

从本工程根目录运行。需要 Gowin EDA V1.9.12.03 和 PATH 中可用的 ModelSim `vlib/vlog/vsim`、Python 3。

```powershell
python tools/check_project.py
powershell -ExecutionPolicy Bypass -File sim/run_all.ps1
& "D:\Gowin\Gowin_V1.9.12.03_x64\IDE\bin\gw_sh.exe" tools/build.tcl
```

位流：`impl/pnr/GW_PROBLEM_TOW.fs`。构建脚本在完成后检查 50 MHz 时序。
`run_all.ps1` 覆盖基础、UART、钢琴读谱和安卓铃声回归，测试夹具自动从现有 BIN 生成，不改写 SD 文件。
铃声音频逐样本核对需要 NumPy/SciPy；若本地尚未安装，可运行：

```powershell
python -m pip install --target output/marimba_tools numpy scipy
```

单项入口：`sim/run.ps1`、`run_uart.ps1`、`run_score.ps1`、`run_ringtone.ps1`。
`sim/demo.ps1` 生成钢琴试听，`sim/gui.ps1` 打开合成器波形。
`sim/run_marimba_audio.ps1` 可额外渲染、核对并导出 42 音马林巴试听（不在默认回归中）。
`sim/run_clarinet.ps1` 可独立验证三乐器控制，并将 45 音单簧管 RTL 输出与整数模型逐样本核对、导出试听 WAV。
`sim/run_nocturne.ps1` 检查完整夜曲事件、SD 读卡与第 4 首命令；加 `-RenderAudio` 可导出全曲 RTL 试听并逐样本对照。
验证覆盖范围和本次实际结果见 [VERIFICATION.md](VERIFICATION.md)。

## 参数与维护

默认 `DEFAULT_MARIMBA=1`、`SD_SCORE_ENABLE=0`，实体 KEY1 上电试听马林巴；串口虚拟试听键独立默认选择钢琴 A0。
`SD_SCORE_ENABLE` 控制上电钢琴乐谱模式；设为 0 时，KEY0 和 UART 仍可启动 SD 播放。
系统集成层保留原参数接口，测试可以加速复位、串口和谱面时间。

当前合成器支持钢琴 88 音、马林巴 C2～B5 共 48 音及单簧管 D3～B♭6 共 45 音；实体 KEY1 仅循环马林巴的 C2～F5。
钢琴事件使用 0～87 索引，马林巴使用 MIDI 36～83，单簧管使用 MIDI 50～94，不能混用。

清理可重建的仿真缓存、日志、音频和测试夹具：

```powershell
powershell -ExecutionPolicy Bypass -File tools/clean_generated.ps1
```

该脚本保留位流、素材、ROM、SD 文件、已安装依赖和写卡备份。
素材出处及权利说明见 [assets/ATTRIBUTION.md](assets/ATTRIBUTION.md) 和 [source/ATTRIBUTION.md](source/ATTRIBUTION.md)。
