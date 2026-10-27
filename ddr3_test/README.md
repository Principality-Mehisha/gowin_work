# Tang Mega 60K DDR3 自动读写测试（无 UART）

**2026-10-27 修正版 V3：**用户反馈诊断版每组闪 3 次，表示写数据通道超时。使用高云实际生成的 MC 网表复现了同样的 3 号故障；旧发送逻辑与控制器输入缓冲的流水时序不匹配。V3 改为命令与写数据同拍提交，每次写入后插入两个空闲时钟，读命令也只在 ready 时提交。保留 LED 故障报码、400 MHz DDR3 参数和 512 MiB 整片测试范围。用户已反馈 V3 实板运行正常。

直接下载当前码流：`output/ddr3_test.fs`，与 `impl/pnr/ddr3_test.fs` 及已确认的 V3 码流内容一致。构建脚本会同步更新默认输出路径。故障报码对照见下表。

打开 `ddr3_test.gprj` 即可综合、布局布线和生成码流。工程已包含由本机 Gowin EDA V1.9.12.03 生成的 DDR3 控制器、PLL 及 PLL 初始化模块，无需自己创建 IP。

## 下载与观察

1. 在 Gowin EDA 中打开本目录的 `ddr3_test.gprj`，顶层为 `ddr3_test`，器件为 `GW5AT-LV60PG484AC1/I0`、Device Version B。
2. 执行 Synthesize、Place & Route，或者在仓库根目录执行：

   ```powershell
   & 'D:/Gowin/Gowin_V1.9.12.03_x64/IDE/bin/gw_sh.exe' ddr3_test/tools/build.tcl
   ```

3. 使用 Gowin Programmer 将 `impl/pnr/ddr3_test.fs` 下载到 FPGA SRAM，即会自动开始测试。
4. 观察**核心板**上的 D2207 / READY 和 D2206 / DONE 两颗橙色 LED。无需 UART、电脑终端、PMOD LED 或其他外设。两灯均为高电平点亮。

| 现象 | D2207 / READY（U12） | D2206 / DONE（G11） |
| --- | --- | --- |
| 上电 / 复位延迟约 200 ms | 灭 | 灭 |
| 等待 DDR3 校准 | 慢闪，约 1.5 Hz | 灭 |
| 已校准，首次完整测试进行中 | 快闪，约 6 Hz | 灭 |
| 至少一整轮六种模式全部通过，继续测试 | 快闪 | 常亮 |
| 故障 | 灭 | 每组闪 N 次，停顿约 1.2 秒，再重复 |

每次短闪约亮 200 ms、灭 200 ms。数**长停顿之间**的一组短闪次数：

| N | 故障含义 |
| --- | --- |
| 1 | 读回数据与写入值不一致 |
| 2 | 等待命令接收或命令/写数据联合提交超时 |
| 3 | 写数据通道持续未就绪，等待 `wr_data_rdy` 超时 |
| 4 | 读命令已接收，等待 `rd_data_valid` 超时 |
| 5 | 曾校准完成，随后校准标志撤销 |
| 6 | 读数据有效但 BL8 结束标志异常 |
| 7 | 上电后约 3 秒仍未完成校准 |
| 8 | 校准后用户域心跳停止（包括用户逻辑持续复位） |
| 9 | 校准后 DDR 控制器再次拉高复位输出 |
| 10 | 校准后 PLL 失锁 |
| 11 | BIST 报错但没有有效错误编号 |

故障编号由 50 MHz 板级时钟域锁存，不会因为 DDR 用户时钟停止而停止报码。多个故障相继发生时，保留最先锁存的编号；例如 PLL 失锁也可能先表现为校准丢失。

按核心板 U1304（`CPU_RESET`，FPGA F4）重新测试，松开后等待约 200 ms。这个按键**按下为高电平**；U1303 / RECONFIG 是重新配置键，不是本程序的逻辑复位键。D8 为电源灯，不表示测试结果。

READY、DONE 复用为 GPIO 的选项已保存在 `impl/ddr3_test_process_config.json`，`tools/build.tcl` 也会显式设置这两个选项。不要删掉选项后直接用 GUI 重新构建，否则这两颗灯会恢复配置管脚功能。如迁移工程，推荐运行构建脚本。

## 测试内容

- 针对单颗 H5TQ4G63EFR-RDC：x16、8 Bank、15 位行地址、10 位列地址，共 **512 MiB**。
- DDR3 CK 为 400 MHz，即 800 MT/s；用户接口为 100 MHz，时钟比 1:4，BL8，每次传输 128 bit / 16 byte。CL=6、CWL=5，tRCD/tRP=15 ns、tRAS=37.5 ns、tRC=52.5 ns、tRFC=260 ns；其余配置见生成脚本。
- 默认遍历 33,554,432 个突发，覆盖地址范围 `0x00000000` 至 `0x0FFFFFFF`（单位为 **16-bit DDR word**）。最后一个突发的起始地址为 `0x0FFFFFF8`。IP 的第 28 位是 rank 位，本板固定为 0。
- 六种模式：全 0、全 1、AAAA、5555、地址相关数据、地址相关数据取反。每一种模式先写完整片，再从头逐突发读回比较，能检测地址别名；128 bit 中的四个 32-bit 字使用不同异或常量，覆盖所有 BL8 beat 和两个字节通道。
- 仅当 `cmd_ready` 和 `wr_data_rdy` 同时为高时，同拍发送一次写命令和一拍 128-bit 数据；每次写提交后插入两个空闲用户时钟，避免当前 MC 的输入流水在背压边界重复入队。等待期间保持地址和数据，使能保持低。读命令也只在 `cmd_ready` 为高时发出；最多一个未完成读命令，按 `rd_data_valid` 接收结果。
- 全部通过一次才点亮通过灯，之后连续循环；后续故障优先显示并锁存，直到按键复位。整片六模式测试需要耐心等待，时间受控制器延迟和刷新影响。
- 校准超过约 3 秒、读写无进展超过约 0.336 秒、已校准后用户时钟超过约 0.1 秒没有心跳，均报告故障。时钟故障检测由独立的板载 50 MHz 时钟运行。

这会覆盖 DDR3 内原有内容。它是功能自检程序，不是峰值带宽测试或完整的工业存储器故障诊断算法。

## 原理图适配

依据提供的 `tang_mega_60k_30354_schematics. (1).pdf` 第 2、3、6 页核对：

- 时钟 V22，50 MHz，3.3 V。
- DDR1 接不带 `_1` 后缀的 DQ0..15；本工程只使用这组 x16 连接。原理图还画了第二颗 DDR2 的 `_1` 数据组，本工程不使用它。
- DDR3 电平为 SSTL15，Bank 9/10/11 为 1.5 V；DDR3 地址 A15 在该 4 Gbit 颗粒上是 NC，所以控制器生成 15 位地址，CST 不分配 A15。
- LED READY=U12、DONE=G11，Bank 3 / VCCIO_CFG=3.3 V。
- 完整 DDR3 数据、地址、控制和差分 CK/DQS 引脚见 `src/ddr3_test.cst`，已经与原理图及官方示例交叉核对。

60K 的 PLLA 没有 138K 那样的 `enclk2` 接口。因此 `pll_stop` 通过官方 `pll_mDRP_intf` 控制 PLL，而不是悬空或普通逻辑门控时钟。先运行 Gowin `PLL_INIT`，检测初始化完成后锁存 `pll_init_bypass=1`，再允许 DDR3 IP 开始初始化，保证 mDRP 交给 DDR 校准逻辑使用。

## 代码与调试

| 文件 | 用途 |
| --- | --- |
| `src/ddr3_test.v` | 板级顶层、复位、PLL / DDR3 IP 接线 |
| `src/ddr3_bist.v` | 读写 / 比较 / 超时状态机 |
| `src/ddr3_status.v` | 状态同步、时钟看门狗、LED |
| `src/ddr3_test.cst` / `.sdc` | 管脚、电平、PLL / DDRDLL 位置、时钟约束 |
| `src/ip/`、`src/pll_init.v` | Gowin EDA 生成的 IP，保留原版权 |
| `src/pll_mDRP_intf.v` | 来自 Sipeed 官方示例的加密模块 |
| `tools/generate_ip.tcl` | IP 参数与生成脚本，仅需重新生成 IP 时使用 |
| `sim/` | ModelSim 行为仿真及故障注入 |
| `tools/extract_native_mc.py` / `sim/run_native.ps1` | 包装生成的实际 MC 仿真网表，回归控制器写 FIFO |

`ddr3_test` 顶层参数 `TEST_BURSTS` 默认 `33554432`。只想先做小范围测试时，可改为 `65536`（1 MiB）再重新综合，但这样不会覆盖高位行地址或其他 Bank，不能据此宣称整片通过。

如需进一步定位错误，可在 Gowin **RTL** Analyzer Oscilloscope 中接入 `ui_clk` 域的 `error_code`、`first_error_addr`、`first_expected`、`first_actual`、`pattern`、`test_state`、`pass_count` 后重建。默认工程没有插入 GAO，未接出的调试寄存器可能被综合优化；顶层的 `syn_keep` 不保证保留没有负载的寄存器。GAO 使用 JTAG，不需要 UART。

`error_code` 的 1～6 与上表一致；7～11 由 `u_status/fault_code` 记录。`first_error_addr` 是 16-bit word 地址，乘以 2 可换算成字节地址；只记录第一个错误。

## 仿真与验证边界

```powershell
& ./ddr3_test/sim/run.ps1
```

测试台模拟高云 native 用户接口，检查独立背压、六模式多轮循环、单 bit 错误、地址别名、命令 / 数据 / 读返回超时、校准丢失、BL8 结束标志、测试中复位恢复，以及 LED 模块的校准超时、时钟停止和错误锁存。

实际控制器网表回归（需要本机 Gowin primitive 库）：

```powershell
& ./ddr3_test/sim/run_native.ps1
```

此回归从 Gowin 生成的公开 `.vo` 中包装 MC 实例，使用厂商原始 LUT、寄存器、BSRAM 仿真模型，执行 32768 个写事务，核对用户命令、用户数据与 MC 写请求数量。PHY 初始化在此测试中旁路，重点覆盖写缓冲、连续背压和自动刷新；它不检查实板 DDR3 电气时序或颗粒返回数据。

`sim/evidence/ddr3_bist_v2.v` 和 `native_v2_failure.log` 保存导致故障的旧代码和网表复现日志；`run_native.ps1 -Baseline` 可重现旧版失败，预期返回非零状态。

这不是 DDR3 颗粒或模拟 PHY 的仿真。校准、PCB 信号完整性和真实读写需要下载实板确认。SDC 的三个时钟域分组沿用 Sipeed 官方 `cam_dvi` 示例：校准会停启存储器时钟，MC/PHY 内部跨域与外部 DDR3 时序依赖厂商 IP 和训练机制；通过 FPGA 内部时序检查不能替代实板校准验证。构建日志若保留 PR1014（50 MHz 参考时钟至固定 BPLL 位置使用通用布线），应一并保留在验证记录中。

## 参考和版权

- [Sipeed Tang Mega 60K 硬件说明](https://wiki.sipeed.com/hardware/en/tang/tang-mega-60k/mega-60k.html)
- [Sipeed 官方 cam_dvi 示例](https://github.com/sipeed/TangMega-60K-example/tree/main/cam_dvi)：DDR 管脚、物理位置、时钟域分组和 `pll_mDRP_intf.v`；仓库授权声明保存在 `third_party/SIPEED_LICENSE.txt`。
- [Gowin DDR3 IP 用户指南 IPUG281](https://cdn.gowinsemi.com.cn/IPUG281.pdf)：native 接口与 `pll_stop`。
- [SK hynix 4Gb DDR3 SDRAM 数据手册（分销商镜像）](https://atta.szlcsc.com/upload/public/pdf/source/20220111/8B04D85F9A19E6B0B631132A7D0CF6CD.pdf)：颗粒组织、CL/CWL 和时序范围。
- 本机 Gowin EDA 随附 UG306-1.0.7E 第 5.2.4 节：PLLA 初始化和 mDRP 控制权切换；SUG1220-2.0E：Tcl IP 生成与 READY/DONE GPIO 复用。

Gowin 加密 IP 继续受厂商原有授权约束，构建需使用支持该器件的 Gowin EDA。
