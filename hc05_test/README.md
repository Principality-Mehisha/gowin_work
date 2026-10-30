# HC-05 蓝牙串口测试

平台：Tang Mega 60K 核心板 + TANG MEGA NEO Dock，器件
`GW5AT-LV60PG484AC1/I0`（GW5AT-60B，Device Version B，`gw5at60b-002`）。
板上 50 MHz 时钟，默认 UART 为 **115200 / 8N1，无流控、3.3 V TTL**。

本工程生成可通过 Gowin Programmer 下载的 FPGA 码流，实现 HC-05 双向透传测试。
不包含经蓝牙更新 FPGA 配置的加载器。

## 接线

方向全部以 FPGA 为准，TX/RX 必须交叉接线：

| FPGA 信号 | FPGA 球位 | NEO Dock rev1.4 接口 | HC-05 |
| --- | --- | --- | --- |
| `uart_tx`，输出 | **R17** | PMOD0_IO5，**J9 第 8 脚** | RXD |
| `uart_rx`，输入 | **T18** | PMOD0_IO7，**J9 第 6 脚** | TXD |
| GND | — | J9 第 3 或第 4 脚 | GND |
| 可选外接 LED，低有效 | AB20 | 沿用现有项目 PMOD1 的 LED[0] 信号 | 不接模块 |
| `sys_clk` | V22 | 板上 50 MHz，无需外接 | — |

接口映射核对自仓库 [NEO Dock rev1.4 原理图](../GW_PROBLEM_TOW/docs/reference/Tang_Mega_NEO_Dock-60K_31004_Schematics.pdf) 第 6、19 页。
旧原理图的部分 Bank 标号与当前 B 版工具数据库不同，因此 `.cst` 以器件数据库为准；
最终 PnR 报告确认 R17/T18 位于 Bank 6，均为 LVCMOS33。
实际插针朝向按板上 1 脚标记核对，不要把球位名称当作排针脚号。
PMOD0 与其他扩展接口复用，测试时移除同一组信号上的 LED、摄像头或其他外设。

**模块供电需按实物底板标注选择。**常见带稳压底板的 HC-05 可接 5 V，裸模块只能接 3.3 V；
不要把模块的 5 V 电源接到 FPGA UART 信号上。J9 的第 1/2 脚是 3.3 V，并非 5 V。
带底板且标注需 5 V 的模块，应使用开发板核实过的 5 V 电源端或独立稳压 5 V，必须共地。
本工程 FPGA UART 为 3.3 V，直接连接模块的 3.3 V UART。
KEY/EN、STATE 第一版悬空；模块保持普通透传模式。

## 最快上手

1. 下载 `output/hc05_test.fs` 到匹配的 FPGA；初次测试可使用 SRAM 下载。
2. 按上述表格接 HC-05，供电并共地。可选 LED 初始熄灭。
3. 用安卓手机配对模块，再用支持 **经典蓝牙 SPP** 的串口工具建立连接。
   配对 PIN 按模块资料填写；常见原厂配置为 1234，也可能已被修改。
4. 手机工具选择文本发送，并设置每条末尾自动附加 **LF 或 CRLF**。
   命令区只输入 `PING`，不要输入字面的反斜线和字母 `\n`。
5. 收到 `PONG` 后，再测试下表中的 LED、回显和状态命令。

手机蓝牙端通常无需设置 UART 波特率；**115200 指 HC-05 与 FPGA 之间的有线串口**。
HC-05 的 UART 必须同步设为 115200；若当前配置不同，先通过 USB-TTL/AT 模式修改，或修改顶层 `BAUD` 参数后重新构建。
AT 配置模式常见波特率为 38400，不能直接当作本工程透传波特率。
配置细节可参考 [Cytron HC-05 说明](https://www.cytrontech.vn/tutorial/hc-05-hc-05zg)。

## 命令

区分大小写，每行执行一次。以下“发送”均省略末尾 LF；回复固定带 CRLF。

| 发送 | 回复 | 行为 |
| --- | --- | --- |
| `PING` | `PONG` | 测试双向链路 |
| `LED 1` | `OK` | AB20 输出低，点亮可选外接 LED |
| `LED 0` | `OK` | AB20 输出高，熄灭可选外接 LED |
| `ECHO hello` | `hello` | 回显负载 |
| `ECHO ` | 空行 | 允许空负载，ECHO 后须有空格 |
| `STAT` | 见下例 | 返回状态快照 |
| 其他非空行 | `ERR CMD` | 不改变 LED |
| 超过 64 个非 CR 字符的行 | `ERR LONG` | 整行丢弃，不执行 |

状态格式示例（数值随实际收发变化）：

```text
LED=0 RX=00000005 TX=00000000 FE=00000000 OV=00000000 LEN=00000000
```

除 LED 外，字段均为 **8 位大写十六进制**、32 位循环计数：

- `RX`：收到且停止位正确的字节数，包括 CR/LF；快照包括当前 `STAT` 的 LF。
- `TX`：已交给 UART 发送器、开始发送的字节数；不代表对端已收到。
- `FE`：UART 停止位错误次数；持续低电平 break 计一次，恢复高电平后才重新接收。
- `OV`：回复生成器忙或发送队列余量不足而丢弃的命令数。
- `LEN`：超长行次数，每行只计一次。

所有 CR 字节忽略；空行无回复。每行最多 64 字符，ECHO 负载最多 59 字符。
只有 LF 触发执行；未完成行会一直保留到 LF、错误或重新下载/断电复位。
串口帧错误会丢弃当前行直到下一个有效 LF，避免受损命令改变 LED。
出现帧错误后可先发一个空行，再发 `PING` 恢复测试。

发送 FIFO 为 256 字节，每条命令预留至少 96 字节再执行；余量不足时整条命令丢弃，
不执行 LED 动作、不生成半条回复，只增加 `OV`。待发送队列排空后用 `STAT` 查询。
普通手动操作不会积压；自动发送时建议等待上一条回复，再发下一条命令。

配置完成后约 1.31 ms 自动复位结束，不主动发送欢迎文字；连接后发送 `PING` 即可。
不接 LED 扩展板也可以通过 `STAT` 中的 LED 状态确认命令执行。

## 工程与构建

用 Gowin EDA V1.9.12.03 打开 `hc05_test.gprj`，顶层为 `hc05_test`。
在仓库根目录也可运行：

```powershell
& 'D:\Gowin\Gowin_V1.9.12.03_x64\IDE\bin\gw_sh.exe' hc05_test/tools/build.tcl
```

脚本按自身位置定位工程，执行综合、布局布线及码流生成，检查 setup/hold 违例均为 0 后，
将码流、资源报告和时序报告复制到 `output/`。

```text
hc05_test.gprj             Gowin 工程
src/hc05_test.v            顶层，50 MHz、115200 参数及上电复位
src/uart_rx.v             输入同步、起始/停止位验证和 break 恢复
src/uart_tx.v             ready/valid 发送器
src/hc05_commands.v        行解析、LED、回复及计数快照
src/byte_fifo.v            256 字节同步 FIFO
src/board_reset.v          上电复位及同步释放
src/hc05_test.cst/.sdc     引脚与时序约束
sim/                      测试台及 ModelSim run.do
tools/sim.ps1             一键仿真
tools/build.tcl           构建与时序检查
output/hc05_test.fs        便于下载的最终码流
output/hc05_test.rpt.txt   资源及最终引脚报告
output/timing.html        时序报告
```

UART 与复位模块复用本仓库 `GW_PROBLEM_TOW` 的独立副本。
改动本测试工程不会影响原音乐工程。

## 验证记录（2026-10-30）

- ModelSim 10.5b：编译 0 errors / 0 warnings，三个测试台均 PASS。
- `tb_hc05_commands`：容量预留边界、队列不足时无 LED 副作用、反压、半条命令及回复中途复位。
- `tb_hc05_test`：从 TX 引脚独立解码回复，验证所有命令、LF/CRLF、空行、64/65 字符边界、
  停止位错误、break、状态计数快照、90 条连续命令、FIFO 指针回绕，以及 400 条过载命令整条接受/丢弃。
- `tb_hc05_nominal`：实际 50 MHz / 115200 配置，与精确 115200 baud 的对端互通。
- Gowin EDA V1.9.12.03：综合、布局布线和码流生成通过；50 MHz 下 setup/hold 违例均为 0，
  工具报告 Fmax 为 100.798 MHz（115200 版本）。
- 资源：1162 个逻辑单元，1466 个寄存器，1 个 BSRAM，4 个 IO；无锁存器。
- PnR 有一条与现有项目一致的 PR1014 告警：V22 经通用布线进入全局时钟，最终时序检查通过。
- **尚未连接实物 HC-05 / 手机进行上板验证。**

仿真命令（ModelSim 命令在 PATH 中）：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File hc05_test/tools/sim.ps1
```

本机旧版 32 位 ModelSim 在受限沙箱内会报系统 DLL 重定位错误；本次仿真在沙箱外执行通过。

## 无回复时检查

1. 确认手机工具已经建立 SPP 连接，系统配对成功还不等于应用已连接。
2. 确认发送末尾带 LF，命令为大写 `PING`。
3. 检查 R17 接模块 RXD、T18 接模块 TXD、双方共地，以及 J9 的针脚方向。
4. 确认模块处于透传模式，有线 UART 配置为 115200/8N1。
5. 可临时用 3.3 V 逻辑的 USB-TTL 替代 HC-05 接 FPGA，PC 串口终端发 `PING`。
   有线能返回 `PONG` 时，再检查 HC-05 配置和手机连接。
