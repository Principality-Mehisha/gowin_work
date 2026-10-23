# 当前工程验证记录

验证日期：2026-10-23。当前验证目标为马林巴状态 RAM 优化；此前目录分层的完整回归记录保存在 `output/verification/`。

## 本次改动与边界

`marimba_synth.v` 将模态相位/幅度和噪声幅度/LFSR 从动态索引寄存器数组改为同步 RAM。
利用原状态机周期提前读取，不增加状态或出样周期；复位/停止仍清除小型有效标志，不复位整块 RAM。
详见 [马林巴存储优化](docs/MARIMBA_STORAGE.md)。

本次没有改变频率表、马林巴模态/起音 ROM、定点运算和截位、力度曲线、衰减、噪声种子、琴体滤波、限幅、采样率或三首乐谱。
没有改变钢琴音源、顶层接口、按键、UART 协议、管脚及时序约束，没有写入 SD 卡。产品 UART 默认波特率保持本次开始时的 115200。

## 音频与实时等价性

- 修改前 RTL 已保存为外部参考输入，来源 Git 版本及 SHA256 见 `output/marimba_storage/before/baseline.json`。
- `tb_marimba_storage` 同时驱动原版与优化版，每个时钟核对 event_ready、mix_valid、pcm_valid、音频值及错误/限幅标志。
- 已通过 1832 个 PCM 样本的逐时钟对照，覆盖全部 48 音、不同力度、复音、重触发、随机输入、采样边界事件、忙时输入、提前采样、各状态的复位/停止。
- 原有 48 音混音测试仍为 2496 个时钟，加入滤波/限幅后对照测试最大完整输出等待 2509 个时钟，低于 3072 个时钟的板级帧预算。
- 完整安卓曲谱的 396729 个 PCM 样本与独立整数模型完全一致，峰值 PCM=5896；生成 WAV 与修改前基线逐字节相同，SHA256 为 86d4b5e7139ee30293932fb9fadf94dc18b1d836ea419e5d8934dfd6bf76981d。

## 本轮功能回归

| 测试范围 | 平台 | 状态 |
| --- | --- | --- |
| 存储优化逐时钟对照 | tb_marimba_storage | 通过 |
| 基础回归 | tb_keys、tb_limiter、tb_dac、tb_synth、tb_marimba、tb_marimba_controls | 6 项通过 |
| UART 选曲/单音集成 | tb_uart_player、tb_uart_notes | 2 项通过 |
| 完整 SD 铃声/音频 | tb_sd_ringtone、tb_ringtone_synth | 2 项通过 |

本轮共 11 个相关测试平台通过，日志、完整音频及报告保存在 `output/marimba_storage/after/`，汇总与日志哈希见 `output/marimba_storage/comparison.json`。

本轮针对修改后的音源与集成路径验证；未修改的 UART 协议、屏幕格式化、钢琴完整谱面等此前完整回归已通过，本轮不把旧结果记作重跑结果。
通用入口仍为 `sim/run_all.ps1`。存储等价性需要修改前 RTL，使用 `sim/run_marimba_storage.ps1 -ReferenceRtl <参考文件>`，不加入通用回归。

## 构建对照

| 项目 | 修改前最后一次构建 | 本次优化构建 |
| --- | ---: | ---: |
| 目标时钟 | 50.000 MHz | 50.000 MHz |
| Fmax | 50.013 MHz | 50.051 MHz |
| Setup / Hold 违例端点 | 0 / 0 | 0 / 0 |
| Logic | 19640 | 11463 |
| Register | 21143 | 6794 |
| CLS | 22825（77%） | 8338（28%） |
| BSRAM | 54 / 118 | 60 / 118 |
| DSP | 22 | 22 |
| 综合报告耗时 | 39 秒 | 30 秒 |
| 布局布线报告耗时 | 122 秒 | 39 秒 |
| 两阶段合计 | 161 秒 | 69 秒 |

Gowin EDA V1.9.12.03 (64-bit) 的综合、布局布线、位流生成与时序检查通过，退出码 0。
耗时是本机单次报告值，不包含 ModelSim 仿真，不代表每次运行的固定耗时。
位流为 `impl/pnr/GW_PROBLEM_TOW.fs`，输入哈希和位流 SHA256 见 `output/build_manifest.json`。
前后报告保存在 `output/marimba_storage/before/` 与 `after/`。

## 工具与硬件边界

旧 UART 集成测试按 9600 的加速时序发送，却隐式继承产品已改为 115200 的默认参数，导致第一次集成超时。两个测试已显式设置 UART_BAUD=9600，产品端及屏幕脚本不变。

第一次 RAM 映射遇到器件不支持的噪声单口 RAM read-first 模式；改为 NOTE_START 读取、NOISE_COMMIT 写入的互斥读写后，重新通过逐时钟对照与物理实现。
原有定点位宽截断提示和 V22 时钟一般布线的 PR1014 警告仍存在，最终 50 MHz 同步时序检查通过。
本机 ModelSim 10.5b 为 32 位版本，受限环境启动有 DLL 问题，本次在本机执行环境运行；一次编译启动异常后复用已验证的测试库继续检查。

没有执行真实开发板下载、串口屏烧录、示波器测量或扬声器试听；仿真样本一致性不能替代板级测量。
