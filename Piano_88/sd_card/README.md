# TF / SD 卡 SPI 读取模块

用于本仓库的 Tang Mega 60K 核心板 + NEO Dock 底板，
器件 `GW5AT-LV60PG484AC1/I0`，系统时钟 50 MHz。
当前提供只读的 512 字节扇区接口、独立的上板测试工程，
以及 [SD 音乐播放器](MUSIC_PLAYER.md)。
不会写入、格式化或修改卡片。主钢琴工程也可从卡根目录读取 `PIANO.BIN`。

《克罗地亚狂想曲》乐谱演奏使用 `../Piano_Score.gprj`，
见 [乐谱演奏说明](../SCORE_PLAYER.md)。配套文件为 `score/PIANO.BIN`，
保存音符、力度与时间，由原有钢琴音色生成声音。
旧 `piano_music/PIANO.BIN` 是整曲 PCM，`music/PIANO.BIN` 是音色采样库，
不能当作乐谱使用。

## 已核对的引脚

引脚来自 Sipeed 官方 `tang_mega_60K_pins.cst` 的 SDCARD 部分，
不是根据其他 Tang 板卡推测的编号。

| 模块端口 | TF 卡信号 / SPI 作用 | FPGA 管脚 | 电平 |
| --- | --- | --- | --- |
| `sd_sck` | CLK / 时钟 | V15 | LVCMOS33 |
| `sd_mosi` | CMD / 主机输出 | Y16 | LVCMOS33 |
| `sd_miso` | DAT0 / 卡片输出 | AA15 | LVCMOS33 |
| `sd_cs_n` | DAT3 / 低有效片选 | W15 | LVCMOS33 |

直接使用 NEO Dock 的板载卡槽，不需要另接四根杜邦线。
本工程使用 SPI，不使用 DAT1、DAT2，也没有卡片检测输入。
约束位于 `src/sd_card_probe.cst`。其他型号或版本的底板需重新核对原理图。

官方资料：

- [Tang Mega 60K 说明](https://wiki.sipeed.com/hardware/en/tang/tang-mega-60k/mega-60k.html)
- [官方引脚资料目录](https://dl.sipeed.com/shareURL/TANG/Mega_138K_60K/08_Misc)
- [60K 完整约束文件](https://api.dl.sipeed.com/fileList/TANG/Mega_138K_60K/08_Misc/tang_mega_60K_pins.cst)
- [SD SPI 命令与初始化参考](https://elm-chan.org/docs/mmc/mmc_e.html)

## 支持范围

- SD v1 SDSC，例如常见的 1GB 卡；兼容 CMD8 返回非法命令状态。
- SD v2 SDSC，以及使用 512 字节块寻址的 SDHC/SDXC。
- 上电等待 10 ms，片选和 MOSI 保持高电平，先发送 80 个时钟。
- 初始化时约 396.8 kHz，初始化成功后切换到 12.5 MHz。
- CMD0、CMD8、CMD55/ACMD41 重试、CMD58；SDSC 额外发送 CMD16(512)。
- CMD17 单扇区读取；将 SDSC 的 LBA 自动转换为字节地址。
- CRC16 校验、初始化和读取超时、错误通知、接收端反压。

底层扇区模块不支持 MMC、SDUC、热插拔自动重新初始化或写卡。
FAT16/FAT32 文件查找和 WAV 解析由新增音乐工程的上层模块实现，不支持 MP3 解码。
1GB 卡属于何种文件系统不影响底层扇区读取，不需要为本测试重新格式化。

## 独立上板测试

使用 Gowin EDA 打开 `SD_Card_Probe.gprj`，顶层为 `sd_card_probe`。
或者在仓库根目录执行：

```powershell
& "D:\Gowin\Gowin_V1.9.12.03_x64\IDE\bin\gw_sh.exe" Piano_88/sd_card/build.tcl
```

生成码流 `impl/pnr/SD_Card_Probe.fs`。
插卡并下载此测试码流后，自动初始化卡片、读取第 0 扇区并校验 CRC。
这会暂时运行读卡测试程序；恢复钢琴播放时下载主工程的码流。
按 KEY2（Y12，低有效）复位并重新测试。

测试顶层使用四个 LED，输出低电平表示相应状态成立：

| 信号 | FPGA 管脚 | 含义 |
| --- | --- | --- |
| `LEDs[0]` | AB20 | 卡片初始化成功 |
| `LEDs[1]` | AA19 | 检测为 SDHC/SDXC；SDSC 此位不成立 |
| `LEDs[2]` | AA21 | 第 0 扇区完整读取且 CRC 正确 |
| `LEDs[3]` | AA20 | 出现错误 |

因此 1GB SDSC 卡正常时，状态 0、2 成立，状态 1、3 不成立。
以上 LED 管脚采用用户修正并实测成功的分配；用户已确认 1GB 卡插入后 0、2 亮。
没有检查 MBR/FAT 签名，因此空卡或未格式化的卡也可以完成底层读卡测试。
音乐工程沿用这组 LED 管脚，但各灯的含义不同，见音乐播放器说明。

## 接口约定

实现文件位于主工程目录的 `../src/sd_spi_byte.v` 和 `../src/sd_spi_reader.v`。
二者只使用系统时钟，不把 SPI 时钟作为 FPGA 内部时钟。

| 信号 | 方向 | 约定 |
| --- | --- | --- |
| `clk`、`rst_n` | 输入 | 50 MHz；低有效复位。复位释放后自动初始化 |
| `initialized` | 输出 | 初始化成功后保持高，复位清除 |
| `high_capacity` | 输出 | 1 表示块寻址；0 表示 SDSC 字节寻址 |
| `read_ready` | 输出 | 可以接收新的读取请求 |
| `read_start`、`read_lba[31:0]` | 输入 | 在 `read_ready=1` 时给一个时钟的请求脉冲及扇区号 |
| `busy` | 输出 | 正在初始化、读取或进行错误后的总线收尾 |
| `data[7:0]`、`data_index[8:0]` | 输出 | 当前字节及其在扇区内的位置，位置为 0～511 |
| `data_valid`、`data_ready` | 输出 / 输入 | 在二者均为 1 的系统时钟上升沿接收一个字节 |
| `read_done` | 输出 | 512 字节均接收、CRC 正确且片选释放后，产生一个时钟脉冲 |
| `error_pulse`、`error_code[3:0]` | 输出 | 错误事件脉冲及保持的错误码 |

`data_ready=0` 时，字节、位置和 `data_valid` 保持，SPI 时钟停止在低电平。
此处没有接收端超时；接收端必须最终继续接收，或通过复位中止。

**字节流在 `read_done` 之前尚未通过完整扇区校验。**
接入音乐播放时，应先存入至少 512 字节缓冲，再在 `read_done` 后提交；
若收到错误则丢弃该扇区。连续播放可使用两个 512 字节缓冲。
读取错误后，等 `read_ready` 恢复再重试；初始化失败后需要复位。
错误码在复位或接收下一次有效读取请求时清除。

模块没有读取 CSD 获取卡容量，访问超出卡容量的地址由卡片返回错误。
SDSC 的 LBA 到 32 位字节地址转换若会溢出，模块直接拒绝请求。
`read_start` 不是保持型握手信号，不能持续拉高。

| 错误码 | 含义 |
| ---: | --- |
| 0 | 无错误 |
| 1 | 初始化超过默认 2 秒 |
| 2 | 卡片持续忙，无法开始命令 |
| 3 | 命令响应超时 / 无卡 |
| 4 | R1 返回非预期状态 |
| 5 | CMD8 回应或电压检查模式不符 |
| 6 | OCR 上电完成或 3.3V 电压窗口不符 |
| 7 | SDSC 地址转换溢出 |
| 8 | 等待数据起始标记超过默认 250 ms |
| 9 | 收到错误或非法数据标记 |
| 10 | 扇区 CRC16 不匹配 |

## 验证

在 `Piano_88/sim` 下执行：

```powershell
vsim -c -l transcript_sd -do run_sd.do
```

`sd_card_model.v` 是独立的 SPI 卡片行为模型，在引脚层接收命令并返回数据，
对 512 字节逐字节比对。测试使用缩短的等待时间和时钟分频。

覆盖 SD v1 SDSC、SD v2 SDSC、SDHC、ACMD41 多次重试、
CMD16、LBA 与字节地址转换、32 位地址保留、连续扇区、接收暂停、
CRC 错误、数据标记错误、响应和数据超时、错误后重读、
CMD8/OCR 错误、卡片持续忙、无卡、初始化超时及读途中复位。
CRC 参考实现另用 ASCII `123456789` 的 `31C3` 校验值自检。
另以默认时钟和上电等待参数验证测试顶层，检查 SDSC/SDHC 状态、
第 0 扇区只读取一次、LED 状态以及 KEY2 复位后重新初始化。

2026-10-16 本地验证：

- ModelSim 10.5b：全部读卡测试通过，编译及仿真错误、告警均为 0。
- Gowin V1.9.12.03：测试工程综合、布局布线、码流生成通过。
- 测试顶层使用 755 个逻辑资源、343 个寄存器，BSRAM 和 DSP 均为 0。
- 50 MHz 内部时序检查 setup/hold 违例均为 0，Fmax 为 112.275 MHz。
- 沿用 V22 系统时钟引脚，有 `PR1014` 通用时钟路由告警。
- 用户已实测 1GB 卡的初始化和第 0 扇区 CRC 读取成功；
  音乐文件读取及实际音频输出仍待上板确认。
  当前 SDC 仅约束系统时钟，内部时序通过不代表完成卡片接口时序签核。

日志为 `../sim/transcript_sd` 和 `impl/pnr/SD_Card_Probe.log`，
报告为 `impl/pnr/SD_Card_Probe.rpt.txt` 和 `impl/pnr/SD_Card_Probe.tr.html`。
