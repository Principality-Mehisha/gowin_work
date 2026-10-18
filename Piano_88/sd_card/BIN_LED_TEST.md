# BIN 文件读取与流水灯测试

工程：`SD_Bin_LED_Test.gprj`，顶层：`sd_bin_led_test`。
目标：Tang Mega 60K（GW5AT-60B）+ NEO Dock，50 MHz 时钟。

卡根目录放 `SDTEST.BIN`，长度 1024 字节，内容为 `00..FF` 重复四次。
本地文件为本目录的 `SDTEST.BIN`。2026-10-18 已复制到 `H:\SDTEST.BIN`，
两者 SHA256 均为：

```text
785B0751FC2C53DC14A4CE3D800E69EF9CE1009EB327CCF458AFE09C242C26C9
```

FPGA 使用 SPI 读取卡片，自动识别 FAT16/FAT32 卷及 MBR 主分区。
每个扇区先通过 CRC16 校验，再解析文件；必须逐字节匹配并读到文件结尾，
且文件长度与接收计数均为 1024，才允许流水。

| LED 状态 | 含义 |
| --- | --- |
| 全灭 | 上电等待或初始化尚未完成 |
| LED1 常亮 | SD 初始化完成，正在查找文件 |
| LED1、LED2 常亮 | 已找到文件，正在读取并校验 |
| LED0 → LED1 → LED2 → LED3 循环 | 全部 1024 字节及文件长度校验正确 |
| 四灯全亮 | SD/FAT 错误、文件缺失、文件长度错误或数据不匹配 |

流水每步 100 ms。KEY2 复位后重新读取文件。
卡片从电脑读卡器移到板载卡槽后，按 KEY2 重试。

在工作区根目录构建：

```powershell
& "D:\Gowin\Gowin_V1.9.12.03_x64\IDE\bin\gw_sh.exe" Piano_88/sd_card/build_bin_led_test.tcl
```

生成：`impl/pnr/SD_Bin_LED_Test.fs`。通过 SRAM Program 下载，掉电后不保留。

验证记录（2026-10-18）：

- ModelSim：FAT16 无分区卷、FAT32 MBR 分区、碎片文件、完整读取与流水顺序通过。
- 数据不匹配、文件缺失、长度错误、CRC 错误均保持错误状态，不进入流水。
- 验证了 KEY2 清除成功状态并重新读取；测试包括上电时 KEY2 保持高电平。
- Gowin：综合、布局布线、码流生成通过，50 MHz 内部 setup/hold 违例均为 0。
- V22 沿用现有工程的时钟引脚，仍有 PR1014 通用时钟路由告警。
- 下载尝试失败：下载工具未扫描到下载线；实际板上读取和流水结果待验证。

重新生成本地测试文件和仿真镜像：

```powershell
& .\Piano_88\tools\make_sd_test_bin.ps1
& .\Piano_88\tools\make_sd_bin_led_fixtures.ps1
cd Piano_88/sim
vsim -c -l transcript_bin_led -do run_sd_bin_led_test.do
```
