# gowin_work

高云（Gowin）FPGA 工程合集，用于记录和分享一些基于高云 FPGA 的小工程 / 小实验。

## 工程列表

| 工程                                           | 硬件平台                                            | 简介                                                                                                                          |
| ---------------------------------------------- | --------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| [`adc_led`](./adc_led)                         | Tang Mega 60K（GW5AT-60B，`GW5AT-LV60PG484AC1/I0`） | 把 ADC 采样值按满量程 8 等分，并将档位以二进制显示在 LED 上；提供并行 ADC 与 SPI（MCP3202 / ADS7816 / ADC128S022 等）两种前端 |
| [`GoWin_FPGA60k_Music`](./GoWin_FPGA60k_Music) | Tang Mega 60K NEO Dock                              | 驱动板载 PT8211 DAC 播放 FPGA 内实时合成的“钢琴音色”音阶（C4–C5–C4 循环），8 个 PMOD LED 指示当前音符位置                     |
| [`Croatian_Rhapsody_Music`](./Croatian_Rhapsody_Music) | Tang Mega 60K NEO Dock                              | 沿用 PT8211 钢琴合成链路循环播放《克罗地亚狂想曲》主题化简片段，8 个 PMOD LED 指示段落位置                     |

## 快速开始

1. 安装 Gowin EDA（高云官方 IDE）；
2. 用 Gowin EDA 打开对应工程目录下的 `.gprj` 文件（如 `adc_led/adc_led.gprj`）；
3. 依次运行综合 / 布局布线，生成 `.fs` 码流（位于 `impl/pnr/`）；
4. 用 Gowin Programmer 把 `.fs` 下载到板卡。

## 验证情况

- `adc_led`：Gowin EDA V1.9.12.03 实测跑通完整流程；ModelSim 功能仿真 256 点全扫描通过。
- `GoWin_FPGA60k_Music`：上板行为（音阶播放、LED 指示、复位）见工程目录内的 README。

## 目录约定

- `src/` —— RTL 源码与约束文件（`.cst` / `.sdc`）
- `sim/` —— ModelSim 功能仿真测试台
- `tools/` —— 工程生成 / 命令行构建脚本（TCL）
- `impl/` —— 综合、布局布线产物（可随时重新生成；部分工程未纳入版本控制）

## 参与方式

1. Fork 本仓库并新建分支（例如 `add-xxx-project`）；
2. 提交并推送修改（可用 GitHub Desktop：Changes → Commit → Push origin）；
3. 向上游仓库发起 Pull Request。

提交新工程时，建议附上：板卡型号、Gowin EDA 验证版本、烧录文件位置与运行现象说明。
