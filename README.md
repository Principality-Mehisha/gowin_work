# gowin_work

高云（Gowin）FPGA 工程合集 —— 记录几个基于 **Tang Mega 60K** 平台的小工程 / 小实验，供团队内部参考与交流。

| 项目 | 说明 |
| --- | --- |
| 目标器件 | `GW5AT-LV60PG484AC1/I0`（GW5AT-60B，PBGA484A，Device Version B，器件 ID `gw5at60b-002`） |
| 硬件平台 | Sipeed Tang Mega 60K 核心板（GW5AT-LV60 SOM）+ TANG MEGA NEO Dock 底板 |
| 开发工具 | Gowin EDA **V1.9.12.03 (64-bit)**（各工程的综合 / 布局布线 / 码流均由该版本产生） |
| 仿真工具 | ModelSim（`sim/` 目录下的测试台） |
| 系统时钟 | 板上 50 MHz 晶振，管脚 `V22`（Bank 7，LVCMOS33） |

---

## 1. 工程列表

| 工程 | 顶层模块 | 简介 | 验证状态 |
| --- | --- | --- | --- |
| [`adc_led`](./adc_led) | `top` | 把 ADC 采样值按满量程 8 等分，档位以**二进制**写在最低 3 个 LED 上；提供**并行 ADC** 与 **SPI 串行 ADC**（MCP3202 / ADS7816 / ADC128S022 等）两种前端，用参数 `ADC_IF` 切换 | Gowin EDA V1.9.12.03 跑通全流程并生成码流；ModelSim 对 0…255 全量程扫描 + 段边界 + 复位，**全部通过** |
| [`GoWin_FPGA60k_Music`](./GoWin_FPGA60k_Music) | `test` | 驱动 NEO Dock 板载 **PT8211 DAC**，由 FPGA 实时合成"钢琴音色"音阶（C4 → C5 → C4 循环），8 个 PMOD LED 指示当前音符位置 | 上板行为（音阶播放 / LED 指示 / 复位）见工程内 [README](./GoWin_FPGA60k_Music/README.md) |

---

## 2. 快速开始

1. 安装 **Gowin EDA**（高云官方 IDE，本仓库使用 V1.9.12.03 x64）；
2. 用 Gowin EDA 打开工程目录下的 `.gprj`（如 `adc_led/adc_led.gprj`，或直接双击交给 `gw_ide.exe`）；
3. 依次执行 `Synthesize` → `Place & Route`，生成码流 `impl/pnr/<工程名>.fs`；
4. 用 **Gowin Programmer** 把 `.fs` 下载到板卡（也可用 `impl/pnr/<工程名>.bin`）；
5. 需要仿真时，在工程 `sim/` 目录里用 ModelSim 运行对应测试台（见 §3.5）。

> 命令行方式（以 `adc_led` 为例，需先按你的实际路径修改脚本里的 `proj_dir`）：
>
> ```powershell
> # 全流程：综合 + 布局布线 + 码流
> & "D:\Gowin\Gowin_V1.9.12.03_x64\IDE\bin\gw_sh.exe" adc_led/tools/build.tcl
> # 重新生成工程文件
> & "D:\Gowin\Gowin_V1.9.12.03_x64\IDE\bin\gw_sh.exe" adc_led/tools/make_project.tcl
> ```

---

## 3. 工程一：`adc_led` —— ADC 采样值二进制显示

### 3.1 功能

把 ADC 满量程 8 等分得到档位 0…7，再把档位以二进制写在最低 3 个 LED 上（LED7…LED3 恒灭）：

| ADC 输入（占满量程） | 档位 | LED2 LED1 LED0 | 点亮 |
| --- | --- | --- | --- |
| 0 … < 1/8 | 0 | 0 0 0 | 全灭 |
| 1/8 … < 2/8 | 1 | 0 0 1 | LED0 |
| 2/8 … < 3/8 | 2 | 0 1 0 | LED1 |
| 3/8 … < 4/8 | 3 | 0 1 1 | LED0 + LED1 |
| 4/8 … < 5/8 | 4 | 1 0 0 | LED2 |
| 5/8 … < 6/8 | 5 | 1 0 1 | LED2 + LED0 |
| 6/8 … < 7/8 | 6 | 1 1 0 | LED2 + LED1 |
| 7/8 … 满量程 | 7 | 1 1 1 | LED2 + LED1 + LED0 |

即 LED0 为最低位（每档翻转）、LED1 每 2 档翻转、LED2 每 4 档翻转；输入最小全灭，随输入上升按二进制递增。对 8 位 ADC，档位就是采样值高 3 位，段边界为 **32 / 64 / 96 / 128 / 160 / 192 / 224**，因此实现上直接取 `adc_data[7:5]`，不需要比较器。

### 3.2 ADC 接口

顶层 `top` 用参数 `ADC_IF` 选择前端（默认 `"PAR"`）：

- `ADC_IF = "PAR"`：并行 ADC —— `adc_data[ADC_BITS-1:0]` + `adc_dv`（一个时钟的有效脉冲，可接 EOC / BUSY 下降沿）；
- `ADC_IF = "SPI"`：串行 ADC —— FPGA 输出 `adc_cs_n` / `adc_sclk`，从 `adc_din` 移入数据，每 `CLK_FREQ / SAMPLE_DIV` 个时钟启动一次转换（MSB first、上升沿采样）。

未选中的前端端口不会被约束，综合器只会看到实际用到的管脚。`adc_led` 内部先把采样值归一化到统一 8 位空间（`ADC_BITS > 8` 取高 8 位、`< 8` 左对齐），因此更换不同位宽的 ADC 不必改逻辑；档位边界始终按 8 等分满量程计算。

### 3.3 参数

| 参数 | 默认 | 说明 |
| --- | --- | --- |
| `ADC_BITS` | 8 | 并行 ADC 位宽 |
| `HYST` | 2 | 迟滞（8 位 LSB），抑制 ±1 LSB 抖动闪灯，设 0 则完全跟随 |
| `ADC_IF` | `"PAR"` | `"PAR"` 并行 / `"SPI"` 串行 |
| `SPI_BITS` | 12 | 串行 ADC 位宽 |
| `SAMPLE_DIV` | 50000 | SPI 采样分频（50 MHz / 50000 = 1 kHz） |
| `SPI_CPOL` | 0 | SCLK 空闲电平 |
| `ACTIVE_LOW` | 1 | LED 低电平点亮 |

把 `src/adc_led.v` 里的 `decoded` 赋值换成文件注释给出的"进度条"表达式，即可变成 1、2、3…8 个灯依次点亮的效果。

### 3.4 管脚约束（`src/adc_led.cst`）

已按 Sipeed 官方例程核对确定的管脚：

| 信号 | 管脚 | 电平 | 说明 |
| --- | --- | --- | --- |
| `clk` | `V22` | LVCMOS33 | 板上 50 MHz 晶振（Bank 7） |
| `rstn` | `AA13` | LVCMOS15 `PULL_UP` | 板上复位键；该脚无外部上拉，故打开内部上拉（Bank 9 为 1.5 V） |
| `led_o[7:0]` | `AB20 AA19 AA21 AA20 AB22 AB21 Y22 Y21` | LVCMOS33 / 8 mA | HDMI 附近那组 PMOD 的 8 个 LED，**低电平点亮** |

`adc_data[*]` / `adc_dv` / `adc_cs_n` / `adc_sclk` / `adc_din` 目前是**占位管脚**：都是本器件上确实存在且已编译验证过的合法 I/O，但**未必与你的 ADC 实际接线一致**，接线后请修改 `src/adc_led.cst`（或用 IDE 的 `Tools → FloorPlanner` 图形化分配，会自动回写 `.cst`）。同一 Bank 的 VCCIO 必须一致：占位脚都在 3.3 V 的 Bank 6/7/8/10/11；若挪到 Bank 9，需改为 LVCMOS15 + `BANK_VCCIO=1.5`。

### 3.5 仿真

```powershell
cd adc_led/sim
vlib work
vlog ../src/adc_led.v tb_adc_led.v
vsim -c -do "run -all; quit -f" work.tb_adc_led
```

测试台对 8 位全量程 0…255 逐点扫描，并检查复位与段边界，输出以 `=== ALL CHECKS PASSED ===` 结束。

> 最近一次核对（本机 ModelSim - Intel FPGA Edition 10.5b）：`vlog` 编译 **0 error / 0 warning**，`vsim` 运行结束于 `=== ALL CHECKS PASSED ===`。

### 3.6 实测结论（Gowin EDA V1.9.12.03）

| 项目 | 结果 |
| --- | --- |
| GowinSynthesis / 布局布线 | 通过，无 error |
| 码流 | 生成成功：`adc_led/impl/pnr/adc_led.fs` |
| 器件识别 | `GW5AT-LV60PG484AC1/I0` / GW5AT-60 / Version B |
| 资源占用 | LUT/ALU 38（11 LUT + 27 ALU），寄存器 11 / 60780，I/O 30 / 297 |
| 时序 | 最差建立路径约 10 ns < 20 ns（50 MHz），满足 |

编译时两条无害告警：并行模式下 `adc_din` 未使用（`WARN (CV0016)`）；`clk` 走通用布线资源（`WARN (PR1014)`，V22 不是专用时钟脚，官方例程同样如此）。

---

## 4. 工程二：`GoWin_FPGA60k_Music` —— PT8211 钢琴音色合成

### 4.1 功能与预期现象

- 配置完成后音频时钟立即启动、数据为 0；
- 约 50 ms 后使能板载功放；
- 约 100 ms 后左右声道循环播放 **C4 → C5 → C4** 音阶（15 个音，每音约 500 ms，整轮约 7.5 s）；
- 8 个 PMOD LED（低电平点亮）指示当前音符位置；
- 按下复位键停止功放并重新开始播放。

### 4.2 音色实现

音色由 FPGA 实时合成，而非回放录音：三角波基波 + 2/3/4 次谐波叠加 → 每个音起始处由 LFSR 产生短促"击槌"瞬态 → 逐帧 ADSR 包络（快起音、指数式衰减到延音、换音前短释放）→ 一阶低通滤波（起音段更亮、延音/尾音更暖）。属于电子琴/玩具钢琴级别的近似；若要更真实的钢琴音色，需要逐音 PCM 采样或更大的物理建模声部。

### 4.3 音频接口（PT8211，非标准 I2S）

PT8211 使用 16 位 **LSBJ / 日本右对齐**格式：`HP_BCK` 上升沿采样 `HP_DIN`，`HP_WS = 0` 为右声道、`1` 为左声道，MSB 先发，`PA_EN` 低有效（0 = 功放开）。

| 信号 | 管脚 | 说明 |
| --- | --- | --- |
| `sys_clk` | `V22` | 50 MHz，分频得 `HP_BCK = 50 MHz / 32 = 1.5625 MHz` |
| `sys_rst_n` | `Y12` | LVCMOS15 `PULL_UP` |
| `LEDs[7:0]` | `AB20 AA19 AA21 AA20 AB22 AB21 Y22 Y21` | 低电平点亮 |
| `HP_BCK` | `Y17` | 采样率 `Fs = 1.5625 MHz / 32 ≈ 48.828125 kHz` |
| `HP_WS` | `AB17` | 左右声道标志 |
| `HP_DIN` | `AA16` | 16 位有符号 PCM，MSB first |
| `PA_EN` | `AB16` | 功放使能，低有效 |

### 4.4 编译与上板

在 Gowin EDA 中打开 `GoWin_FPGA60k_Music.gprj` 并运行全部流程，下载 `impl/pnr/GoWin_FPGA60k_Music.fs`，然后在 NEO Dock 音频输出上接耳机或合适的音箱 —— **请从较小音量开始试听**。

> 最近一次核对（本机 ModelSim 10.5b）：`vlog src/test.v` 编译 **0 error / 0 warning**（该工程未附测试台，上板现象以上表为准）。

---

## 5. 目录约定

```
gowin_work/
├── README.md                  # 本文件
├── adc_led/                   # 工程一
│   ├── adc_led.gprj           # Gowin 工程文件
│   ├── README.md              # 工程详细说明（功能 / 管脚 / 实测数据）
│   ├── src/                   # RTL 源码 + 约束（.cst 物理约束、.sdc 时序约束）
│   ├── sim/                   # ModelSim 测试台
│   ├── tools/                 # TCL 脚本：生成工程 / 命令行全流程
│   └── impl/                  # 综合与布局布线产物（.fs 码流在 impl/pnr/）
├── GoWin_FPGA60k_Music/       # 工程二
│   ├── GoWin_FPGA60k_Music.gprj
│   ├── README.md
│   ├── src/                   # test.v（RTL）、.cst、.sdc
│   ├── tang_mega_60K_pins.cst # 板卡管脚参考表
│   └── .gitignore             # 忽略 impl/ 构建产物
└── Notes/                     # 本地备忘（被 .gitignore 忽略，不入库）
```

各工程内部约定：`src/` 放 RTL 与约束、`sim/` 放仿真测试台、`tools/` 放 TCL 脚本、`impl/` 放可重新生成的构建产物。

---

## 6. 版本控制与分支约定

本仓库有两个远程：

| 远程 | 地址 | 说明 |
| --- | --- | --- |
| `origin` | `https://github.com/windyWHU/gowin_work.git` | 个人 fork，默认分支 `add-gowin-fpga60k-music` |
| `upstream` | `https://github.com/Principality-Mehisha/gowin_work.git` | 团队主仓库，PR 的目标（base） |

- 本地已发布版本标签：**`v1.0.0-piano`**（`5e787d4`，含 `GoWin_FPGA60k_Music` 工程与本 README 的首次重写）。
- 参与方式：fork → 新建分支（如 `add-xxx-project`）→ 提交并推送 → 向 `upstream` 发 Pull Request。
- 提交新工程时建议附上：板卡型号、Gowin EDA 验证版本、烧录文件位置、上板运行现象。
- 入库约定：源码、约束文件、`.gprj`、说明文档、TCL 脚本应入库；`impl/` 下的综合 / 布局布线产物与 `impl/temp/` 可随时重新生成，建议不入库（`GoWin_FPGA60k_Music` 已通过 `.gitignore` 忽略 `impl/`，`adc_led` 的产物目前仍在版本控制中）。
- `GoWin_FPGA60k_Music` 的完整源码随 `add-gowin-fpga60k-music` 分支一起发布（`upstream/main` 亦已包含）；若在某个分支上只看到 `impl/` 而没有 `src/`，切到该分支或先同步 `upstream` 即可。

---

## 7. 参考资料

- [Sipeed Tang Mega 60K 文档](https://wiki.sipeed.com/hardware/en/tang/tang-mega-60k/mega-60k.html)
- [Sipeed TangMega-60K-example（本仓库管脚出处）](https://github.com/sipeed/TangMega-60K-example)
- [Gowin 官网（IDE / 器件手册下载）](https://www.gowinsemi.com/)
