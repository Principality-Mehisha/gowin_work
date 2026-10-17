# realtime_instrument

基于 Tang Mega 60K / GW5AT-60B 的实时多音色合成电子乐器基础框架，对应宣讲 PDF 第 18-19 页的“选题 2：基于 FPGA 的实时多音色合成电子乐器引擎”。

## 当前框架

```text
麦克风 PCM 适配 ─┐
串口屏 UART ─────┼─> 演奏事件路由 ─> 4 声部轮询分配 ─> 波表/包络声源 ─> 混音 ─> PT8211 音响
4x4 矩阵键盘 ────┘                                      └──────────> HDMI 状态可视化
```

第一版已提供：

- 4 路独立复音声部，支持 C4-C5 的基础音高表；
- 2 位音色选择接口：波形、叠加谐波、方波三种占位音色；
- 4x4 矩阵键盘扫描和按键变化事件；
- UART 8-N-1 命令接收：`90 note` 音符按下、`80 note` 音符释放、`B0 value` 切换音色；
- 麦克风数字 PCM 输入边界和活动度量；
- PT8211 音频输出，50 MHz 系统时钟下 BCK 约 1.5625 MHz、采样率约 48.8 kHz；
- HDMI/DVI 640x480 状态画面：4 个声部活动条、麦克风活动条、音色状态条。

## 接口约定

顶层模块为 `realtime_instrument`。`mic_pcm_i` / `mic_valid_i` 是为了隔离具体麦克风硬件而设置的数字 PCM 边界。实际接入 I2S 麦克风、PDM 麦克风或外置 ADC 时，只替换 `mic_pcm_adapter.v` 前面的适配模块，不改合成器和输出链路。

`realtime_instrument.cst` 已填入现有工程验证过的系统时钟、PT8211 和 HDMI 管脚。矩阵键盘、串口屏和麦克风管脚依赖你的实际底板接线，暂留 TODO，避免把未经确认的球位写进工程。

## 建议的扩展顺序

1. 先为矩阵键盘、串口屏、麦克风补齐 `.cst`，用逻辑分析仪确认输入事件和音频采样率。
2. 将 `voice_synth.v` 的固定音高表扩展到 88 键或 32 路，并把轮询分配替换为带释放优先级的 voice allocator。
3. 增加独立波表 RAM、FM/物理建模声部和 ADSR 状态机，满足至少两种可切换音色。
4. 在 `poly_synth4.v` 后加入混响、延迟或合唱，使用 BRAM 做环形缓冲。
5. 在 HDMI 状态画面中加入音符、波形、频谱和延迟计数显示。

## 构建和仿真

```powershell
& "D:\Gowin\Gowin_V1.9.12.03_x64\IDE\bin\gw_sh.exe" realtime_instrument/tools/build.tcl
```

工程使用与仓库已有项目相同的 `GW5AT-LV60PG484AC1/I0` 器件。若只做 RTL 烟测，可在 `sim/` 中用 ModelSim 编译：

```powershell
vlib work
vlog -sv realtime_instrument/src/*.v realtime_instrument/sim/gowin_primitives_stub.v realtime_instrument/sim/tb_realtime_instrument.v
vsim -c work.tb_realtime_instrument -do "run 100us; quit -f"
```

`gowin_primitives_stub.v` 只用于仿真装载，真实综合仍使用 Gowin 器件库。

## 与题目指标的对应关系

当前基线优先闭环验证“多输入 → FPGA 实时合成 → 音响 + HDMI”。四声部、低延迟、音色切换和可视化接口已留出明确模块边界；后续可沿模块边界逐项扩展到 32 声部、3 维演奏表情和效果器。
