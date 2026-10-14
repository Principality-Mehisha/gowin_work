# gowin_work

高云（Gowin）FPGA 工程合集 —— 记录几个基于 **Tang Mega 60K** 平台的小工程 / 小实验，供团队内部参考与交流。

| 项目 | 说明 |
| --- | --- |
| 目标器件 | `GW5AT-LV60PG484AC1/I0`（GW5AT-60B，PBGA484A，Device Version B，器件 ID `gw5at60b-002`） |
| 硬件平台 | Sipeed Tang Mega 60K 核心板（GW5AT-LV60 SOM）+ TANG MEGA NEO Dock 底板 |
| 开发工具 | Gowin EDA **V1.9.12.03 (64-bit)**（各工程的综合 / 布局布线 / 码流均由该版本产生） |
| 仿真工具 | ModelSim（各工程 `sim/` 目录下的测试台） |
| 系统时钟 | 板上 50 MHz 晶振，管脚 `V22`（Bank 7，LVCMOS33） |

| 工程                                           | 硬件平台                                            | 简介                                                                                                                          |
| ---------------------------------------------- | --------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| [`adc_led`](./adc_led)                         | Tang Mega 60K（GW5AT-60B，`GW5AT-LV60PG484AC1/I0`） | 把 ADC 采样值按满量程 8 等分，并将档位以二进制显示在 LED 上；提供并行 ADC 与 SPI（MCP3202 / ADS7816 / ADC128S022 等）两种前端 |
| [`GoWin_FPGA60k_Music`](./GoWin_FPGA60k_Music) | Tang Mega 60K NEO Dock                              | 驱动板载 PT8211 DAC 播放 FPGA 内实时合成的“钢琴音色”音阶（C4–C5–C4 循环），8 个 PMOD LED 指示当前音符位置                     |
| [`Croatian_Rhapsody_Music`](./Croatian_Rhapsody_Music) | Tang Mega 60K NEO Dock                              | 沿用 PT8211 钢琴合成链路循环播放《克罗地亚狂想曲》主题化简片段，8 个 PMOD LED 指示段落位置                     |
---

## 1. 工程列表

| 工程 | 顶层模块 | 简介 | 验证状态 |
| --- | --- | --- | --- |
| [`adc_led`](./adc_led) | `top` | 使用 GW5AT-60 **片上 ADC**（ADCV 差分通道，0…1 V）采样，把有效电压范围 8 等分，档位以二进制写在最低 3 个 LED 上；上电带 PMOD 自检与 ADC 异常指示 | 2026-09-26 用 V1.9.12.03 跑通综合 / 布局布线 / 码流；仿真遍历 0…1 V 全部 2048 个码值通过 |
| [`GoWin_FPGA60k_Music`](./GoWin_FPGA60k_Music) | `test` | 驱动 NEO Dock 板载 **PT8211 DAC**，由 FPGA 实时合成钢琴音色，双声道播放《国际歌》（G 大调，约 120 BPM），8 个 PMOD LED 显示乐曲段落 | 见工程内 [README](./GoWin_FPGA60k_Music/README.md) |
| [`I2S_1`](./I2S_1) | `I2S_1` | 同一 PT8211 通道上的 **32 音等程律音阶发生器**（C3…G5），三个按键控制复位 / 升半音 / 播放停止，带 20 ms 消抖 | 见工程内 [README](./I2S_1/README.md) |
| [`Piano_88`](./Piano_88) | `piano_88` | 真实钢琴 PCM 录音音区覆盖 A0…C8 共 88 音；上电静音，KEY1 每按一次切到下一音，KEY0 暂停 / 继续，KEY2 复位 | 见工程内 [README](./Piano_88/README.md) |

---

## 2. 快速开始

1. 安装 **Gowin EDA**（高云官方 IDE，本仓库使用 V1.9.12.03 x64）；
2. 用 Gowin EDA 打开工程目录下的 `.gprj`（如 `adc_led/adc_led.gprj`）；
3. 依次执行 `Synthesize` → `Place & Route`，生成码流 `impl/pnr/<工程名>.fs`；
4. 用 **Gowin Programmer** 把 `.fs` 下载到板卡；
5. 需要仿真时，在工程 `sim/` 目录里用 ModelSim 运行对应测试台。

命令行方式（三个工程都提供了 `tools/build.tcl`）：

```powershell
& "D:\Gowin\Gowin_V1.9.12.03_x64\IDE\bin\gw_sh.exe" tools/build.tcl
```

> **注意**：`tools/build.tcl` 里的 `set proj_dir {...}` 目前是绝对路径
> （`C:/Users/30415/Desktop/gowin_work/...`），换机器或移动目录后必须先改成实际路径，
> 否则 `open_project` 会失败。

---

## 3. `adc_led` —— 片上 ADC 采样值二进制显示

### 3.1 功能与现象

把 ADC 的有效电压范围（0…1 V）8 等分得到档位 0…7，档位以二进制写在 LED2…LED0 上，
LED7…LED3 恒灭。LED 为**低电平点亮**：

| 输入电压 | ADC 码 | LED2 LED1 LED0 | 点亮 |
| ---: | ---: | :---: | --- |
| 0 … < 0.125 V | 0…255 | 000 | 全灭 |
| 0.125 … < 0.250 V | 256…511 | 001 | LED0 |
| 0.250 … < 0.375 V | 512…767 | 010 | LED1 |
| 0.375 … < 0.500 V | 768…1023 | 011 | LED1 + LED0 |
| 0.500 … < 0.625 V | 1024…1279 | 100 | LED2 |
| 0.625 … < 0.750 V | 1280…1535 | 101 | LED2 + LED0 |
| 0.750 … < 0.875 V | 1536…1791 | 110 | LED2 + LED1 |
| 0.875 … 1.000 V | 1792…2047 | 111 | LED2 + LED1 + LED0 |

另外有两处状态指示：

- **上电自检**：配置完成后 LED0…LED7 各点亮约 125 ms，用于确认 PMOD 管脚与极性；
- **ADC 异常**：自检结束后若始终没有收到 `adcrdy`，LED7 以约 1.3 s 周期闪烁（`no_adc_led_o`）。

### 3.2 模拟输入接线（务必先读）

本工程使用 GW5AT-60 的**片上 ADC**，选择 `ADCV` 差分电压通道：

| 用途 | FPGA 球位 | 专用功能 | 外部连接 |
| --- | ---: | --- | --- |
| 正输入 | **L10** | `ADCVP`（原理图 Page 1 标作 `ADVCP`） | 被测信号 |
| 负输入 | **M9** | `ADCVN` | 模拟地 / 信号回路 |

**差分输入只允许 0…1 V，且 `ADCVP` 必须高于 `ADCVN`；禁止直接接入 3.3 V 信号。**
这两个球位由 `ADC_SAR` 硬核直接使用，不是普通数字端口，因此 `adc_led.cst` 中
**没有**对应的 `IO_LOC` / `IO_PORT` 约束。备用温度 / 电压通道 `ADCT` 位于 `N10/ADCTP`
与 `N9/ADCTN`，本工程未使用。

### 3.3 片上 ADC 接口与参数

`src/gowin_adc/gowin_adc.v` 是 Gowin IP Core Generator 生成的 ADC 硬核 IP：

- Voltage mode，`vsenctl = 3'b000`（ADCV 通道），`adcmode = 1`；
- 50 MHz 外部时钟 8 分频 → ADC 时钟 **6.25 MHz**；
- 14 位输出 `adcvalue[13:0]`（器件 ADC 标称 10 位精度）；
- 每次 `adcreqi` 请求一次转换，等待 `adcrdy` 有效后更新显示。

按 UG299，电压模式下实际电压为 `adcvalue / 2048` V，所以 0…1 V 只对应码值 0…2048，
而不是整个 14 位量程；`top.v` 因此把结果钳位为 11 位 0…2047，再用其高 3 位（`[10:8]`）分档。

| 位置 | 参数 | 默认 | 说明 |
| --- | --- | --- | --- |
| `top` | `SAMPLE_GAP` | 1024 | 两次转换之间等待的系统时钟数（50 MHz 下约 20.48 µs） |
| `top` | `REQUEST_CYCLES` | 16 | `adcreqi` 保持高电平的时钟数（320 ns，跨两个 ADC 时钟） |
| `top` | `ADC_TIMEOUT_CYCLES` | 5 000 000 | 未收到 `adcrdy` 的重试超时（约 100 ms） |
| `adc_led` | `ADC_BITS` | 11（由 `top` 传入） | 采样位宽，归一化到 8 位空间后分档 |
| `adc_led` | `HYST` | 0（由 `top` 传入） | 迟滞，0 表示完全跟随 |
| `adc_led` | `ACTIVE_LOW` | 1 | LED 低电平点亮 |

复位说明：NEO Dock 原理图**没有**给 AA13 提供专用复位信号，所以顶层用计数器在配置后
自行产生约 1.3 ms 的上电复位（`power_on_count`），顶层端口只有 `clk` 与 `led_o[7:0]`。

### 3.4 数字管脚（`src/adc_led.cst`）

| 信号 | 管脚 | 说明 |
| --- | --- | --- |
| `clk` | `V22` | 板上 50 MHz 晶振（Bank 7，3.3 V） |
| `led_o[0..7]` | `AB20 AA19 AA21 AA20 AB22 AB21 Y22 Y21` | 硬件照片中的 PMOD1，低电平点亮，8 mA |

### 3.5 仿真

`sim/tb_adc_led.v` 对 0…1 V 对应的 11 位码值范围做穷举测试
（厂商 ADC 硬核本身不在行为级测试范围内）：

```powershell
cd adc_led/sim
vlib work
vlog ../src/adc_led.v tb_adc_led.v
vsim -c -do "run -all; quit -f" work.tb_adc_led
```

### 3.6 实测结论（Gowin EDA V1.9.12.03，2026-09-26）

| 项目 | 结果 |
| --- | --- |
| 综合 / 布局布线 | 通过，无 error |
| ADC 硬核 | `ADC_SAR 1/1` |
| 时序 | 50 MHz 约束下 setup / hold 违例均为 0，工具报告 Fmax **218.938 MHz** |
| 功能仿真 | 0…1 V 全部 2048 个 ADC 码值通过 |
| 码流 | `adc_led/impl/pnr/adc_led.fs` |

布局布线仅有一条 `PR1014` 告警：`V22` 是普通 I/O（非专用时钟脚），时钟经通用布线进入
全局时钟网络 —— 官方例程同样如此，最终时序报告无违例。

> `src/spi_adc.v` 是早期"外接并行 / SPI ADC"版本的遗留模块，已不在 `adc_led.gprj` 的
> 文件列表中，保留仅供参考。

---

## 4. `GoWin_FPGA60k_Music` —— 《国际歌》钢琴音色（PT8211）

### 4.1 功能与预期现象

- 配置完成后音频时钟立即启动、数据为 0；
- 约 50 ms 后使能板载功放，约 100 ms 后双声道开始播放《国际歌》（`The Internationale`）；
- 乐谱共 **129 个音符事件**，G 大调、约 120 BPM，从弱起小节 `D-G-F#-A-G-D-B-E` 开始，
  保留附点八分 / 十六分节奏，音域 B3…D5；连续相位、音高滑移与柔和包络让衔接更平滑；
- 单声道混音被显式写入 PT8211 左右两个采样寄存器，两个板载声道都能听到完整波形；
- 8 个 PMOD LED（低电平点亮）显示当前乐曲段落；
- 按下复位键停止功放并重新开始播放。

### 4.2 音色实现

音色由 FPGA 实时合成，而非回放录音：钢琴式基波 + 克制的 2 / 3 次谐波 + 短促确定性击槌分量；
逐帧 ADSR 包络（快起音、指数式衰减到延音、换音前短释放）；两级低通滤波 + 直流阻断 + 低电平噪声门。
属于紧凑的 FPGA 钢琴近似——更真实的音色需要逐音 PCM 采样或更大的物理建模声部。

### 4.3 音频接口与管脚

PT8211 使用 **16 位 LSBJ / 日本右对齐**格式（不是标准 I2S）：`HP_BCK` 上升沿采样 `HP_DIN`，
`HP_WS` 低为右声道、高为左声道，MSB 先发，`PA_EN` 低有效（0 = 功放开）。

| 信号 | 管脚 | 说明 |
| --- | --- | --- |
| `sys_clk` | `V22` | 50 MHz，分频得 `HP_BCK = 50 MHz / 32 = 1.5625 MHz` |
| `sys_rst_n` | `Y12` | LVCMOS15 `PULL_UP`（Bank 9，1.5 V） |
| `LEDs[7:0]` | `AB20 AA19 AA21 AA20 AB22 AB21 Y22 Y21` | PMOD，低电平点亮 |
| `HP_BCK` | `Y17` | 位时钟，采样率 `Fs = 1.5625 MHz / 32 ≈ 48.828125 kHz` |
| `HP_WS` | `AB17` | 左右声道标志（两声道同波形） |
| `HP_DIN` | `AA16` | 16 位有符号 PCM，MSB first |
| `PA_EN` | `AB16` | 功放使能，低有效 |

### 4.4 构建与上板

打开 `GoWin_FPGA60k_Music.gprj` 运行全部流程（或 `gw_sh tools/build.tcl`），下载
`impl/pnr/GoWin_FPGA60k_Music.fs`，在 NEO Dock 音频输出上接耳机或合适的音箱 ——
**请从较小音量开始试听**。

---

## 5. `I2S_1` —— 32 音钢琴音阶发生器

### 5.1 功能与按键

同样驱动 NEO Dock 的 PT8211（16 位 LSBJ 时序，并非 Philips I2S）：

| 按键 | 管脚 | 功能 |
| --- | --- | --- |
| `KEY2` | `Y12` | 低有效复位；复位后选择 C3 并开始播放 |
| `KEY1` | `AB13` | 升一个半音；到 G5 之后回到 C3 |
| `KEY0` | `AA13` | 播放 / 停止切换 |

`KEY0`、`KEY1` 经同步与 **20 ms 消抖**，每次稳定按下只产生一个动作，长按不会连发。
顶层还例化了 Gowin `GSR` 原语：重新下载码流时 `KEY2` 可能已是高电平、无法产生复位边沿，
`GSR` 保证序列化器、启动计数器、包络与按键逻辑每次都从确定状态开始。

### 5.2 音域与音色

32 个等程律音覆盖 **C3…G5**：
`C3 C#3 D3 D#3 E3 F3 F#3 G3 G#3 A3 A#3 B3` / `C4 … B4` / `C5 C#5 D5 D#5 E5 F5 F#5 G5`。
音色由三角波派生基波、受控谐波、ADSR 包络、低通平滑与直流阻断合成，左右声道输出同一样本。

音频时序：系统时钟 50 MHz，位时钟 1.5625 MHz，采样率 48.828125 kHz，功放启动延迟 50 ms；
启动期间功放关闭、PCM 保持为 0，播放与换音使用起音 / 释放包络以减少爆音。

### 5.3 仿真与构建

```powershell
cd I2S_1/sim
vsim -c -do run.do          # run.do 内部：vlib / vlog / vsim / run -all / quit
```

```powershell
& "D:\Gowin\Gowin_V1.9.12.03_x64\IDE\bin\gw_sh.exe" I2S_1/tools/build.tcl
```

生成的码流为 `I2S_1/impl/pnr/I2S_1.fs`。

---

## 6. 目录约定

```
gowin_work/
├── README.md                  # 本文件
├── adc_led/                   # 片上 ADC → 二进制 LED
│   ├── adc_led.gprj           # Gowin 工程文件
│   ├── README.md              # 工程详细说明（接线 / ADC 参数 / 实测数据）
│   ├── src/                   # RTL + 约束；src/gowin_adc/ 为 IP Core Generator 生成的 ADC IP
│   ├── sim/                   # ModelSim 测试台
│   ├── tools/                 # 命令行构建脚本（TCL）
│   └── impl/                  # 综合 / 布局布线产物（码流在 impl/pnr/）
├── GoWin_FPGA60k_Music/       # PT8211 立体声《国际歌》
│   ├── GoWin_FPGA60k_Music.gprj
│   ├── README.md
│   ├── src/                   # test.v（RTL）、.cst、.sdc
│   ├── tools/build.tcl
│   ├── tang_mega_60K_pins.cst # 板卡管脚参考表
│   └── .gitignore             # 忽略 impl/ 构建产物
└── I2S_1/                     # 32 音音阶发生器
    ├── I2S_1.gprj
    ├── README.md
    ├── src/                   # I2S_1.v（顶层）、I2S_1_communication.v（串行发送）、.cst、.sdc
    ├── sim/                   # tb_I2S_1.v 与 run.do
    ├── tools/build.tcl
    └── impl/                  # 构建产物
```

各工程内部约定：`src/` 放 RTL 与约束（`.cst` 物理约束 / `.sdc` 时序约束）、`sim/` 放仿真测试台、
`tools/` 放 TCL 脚本、`impl/` 放可重新生成的构建产物。

---

## 7. 版本控制与分支约定

本仓库有两个远程：

| 远程 | 地址 | 说明 |
| --- | --- | --- |
| `origin` | `https://github.com/windyWHU/gowin_work.git` | 个人 fork，默认分支 **`add-gowin-fpga60k-music`**（即当前分支） |
| `upstream` | `https://github.com/Principality-Mehisha/gowin_work.git` | 团队主仓库，Pull Request 的目标（base） |

- 已发布版本标签：**`v1.0.0-piano`**。
- 参与方式：fork → 新建分支（如 `add-xxx-project`）→ 提交并推送 → 向 `upstream` 发起 Pull Request。
- 提交新工程时建议附上：板卡型号、Gowin EDA 验证版本、烧录文件位置、上板运行现象。
- 入库约定：源码、约束文件、`.gprj`、说明文档、TCL 脚本应入库；`impl/` 下的构建产物可随时
  重新生成，建议不入库（`GoWin_FPGA60k_Music` 已通过 `.gitignore` 忽略 `impl/`，
  `adc_led` 与 `I2S_1` 的产物目前仍在版本控制中）。
- 由于 FPGA 工程涉及板级接线与实测结果，改动 `src/` 下的约束后请同步更新对应工程的 README。

---

## 8. 参考资料

- [Sipeed Tang Mega 60K 文档](https://wiki.sipeed.com/hardware/en/tang/tang-mega-60k/mega-60k.html)
- [Sipeed TangMega-60K-example（本仓库管脚出处）](https://github.com/sipeed/TangMega-60K-example)
- [Gowin 官网（IDE / IP Core Generator / 器件手册）](https://www.gowinsemi.com/)
- Gowin UG299（GW5AT 系列 ADC 使用说明）：电压模式下 `电压 = adcvalue / 2048`
