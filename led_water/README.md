# led_water — GW5AT 流水灯工程

Gowin EDA 工程，目标器件 **GW5AT-LV60PG484AC1/I0**（GW5AT-60B 系列 / PBGA484A 封装）。

## 器件说明（重要）

需求中写的 `GW5AT-LV60PG484AC1/10` 在 Gowin 器件库中**不存在**。
GW5AT-60B 的 PBGA484A 封装下只有三种料号：

| 料号 | 器件ID | 速度等级 |
|---|---|---|
| `GW5AT-LV60PG484AC1/I0` | `gw5at60b-002` | C1/I0 |
| `GW5AT-LV60PG484AC2/I1` | `gw5at60b-003` | C2/I1 |
| `GW5AT-LV60PG484AES` | `gw5at60b-009` | ES |

其中 `C1/10` 判定为 `C1/I0` 的笔误，本工程按 **`GW5AT-LV60PG484AC1/I0`** 建立。
若实际是 `C2/I1`，在 IDE 中 `Project -> Configuration -> Device` 里改选即可，
或在 `tools/make_project.tcl` 中修改 `-pn` 后重新生成。

## 目录结构

```
led_water/
├── led_water.gprj                     # 工程文件（Gowin IDE 双击打开）
├── impl/
│   └── led_water_process_config.json  # 由 IDE/gw_sh 生成的器件默认配置
├── src/
│   ├── led_water.v                    # 流水灯 RTL（顶层模块 led_water）
│   ├── led_water.cst                  # 物理约束（管脚）—— 模板，需按板卡修改
│   └── led_water.sdc                  # 时序约束（时钟周期）
├── tools/
│   ├── make_project.tcl               # 重新生成工程的 Tcl 脚本
│   └── validate_flow.tcl              # 全流程验证脚本（综合+布局布线+码流）
└── README.md
```

## 打开工程

双击 `led_water.gprj`，或命令行：

```
"D:\Gowin\Gowin_V1.9.12.03_x64\IDE\bin\gw_ide.exe" "C:\Users\30415\Desktop\gowin_work\led_water\led_water.gprj"
```

## 设计说明

- 顶层模块：`led_water`，端口 `clk`（输入时钟）、`rstn`（异步复位，低有效）、`led_o[7:0]`（8 位 LED 输出）。
- 行为：点亮的 LED 从左到右循环流动（流水灯），每步约 0.2 s。
- **LED 低电平点亮**（`led_o = 8'b1111_1110` 时 LED0 亮）。若板卡为高电平点亮，
  把 RTL 里的初值改为 `8'b0000_0001`，并确认移位方向即可。
- 时钟频率通过参数调整：`CLK_FREQ`（默认 50 MHz）、`STEP_HZ`（默认 5 Hz，即 0.2 s/步）。

```
parameter CLK_FREQ = 26'd50_000_000;  // 输入时钟频率
parameter STEP_HZ  = 26'd5;           // 流水速度
```

## 必须修改：管脚约束

`src/led_water.cst` 中的管脚是**合法的 PBGA484A 球号占位值**，不是实际板卡管脚。
工程可以正常编译通过，但下载前必须按原理图改成真实管脚：

| 信号 | 占位管脚 | 说明 |
|---|---|---|
| `clk` | `D17` | 专用时钟输入脚 GCLKT_0（**保持放在时钟脚上**） |
| `rstn` | `C18` | 复用时钟脚 GCLKT_3，用作普通输入 |
| `led_o[0..7]` | `A13 A14 A15 A16 B13 B15 B16 C13` | 均为 Bank 1 普通 I/O |

两点注意事项：

1. **时钟必须放在专用时钟脚**。若放到普通 I/O，布线会回退到通用布线资源并报
   `WARN (PR1014)`，导致时钟偏斜过大。
2. 占位管脚全部选在 **Bank 1**，保证单一 Bank 电压设置有效。若实际板卡把信号跨了
   Bank，需按原理图核对各 Bank 的 VCCIO。

本封装可用的专用时钟脚（GCLK）：

```
Bank 1 : D17(GCLKT_0) C17(GCLKC_0) B17(GCLKT_1) B18(GCLKC_1)
Bank 2 : E19(GCLKT_2) D19(GCLKC_2) C18(GCLKT_3) C19(GCLKC_3)
Bank 5 : J19 J20 J21 K18 K19
Bank 8 : U20 V18 V19 V20 W19 W20 Y18 Y19
Bank 9 : R4 T4 T5 U5 V4 W4 Y4 AA4
Bank 10: J4 K4 L3 K3        Bank 11: G3 G4 H3 H4
```

推荐做法：在 IDE 中用 `Tools -> FloorPlanner` 图形化分配管脚，它会自动回写 `.cst`。

## 时序约束

`src/led_water.sdc` 中 `-period 20` 对应 50 MHz。请按板卡实际时钟修改：

| 时钟频率 | period |
|---|---|
| 100 MHz | 10 |
| 50 MHz | 20 |
| 25 MHz | 40 |

## 编译

IDE 中依次执行 `Synthesize` → `Place & Route`，码流输出在
`impl/pnr/led_water.fs`。

命令行全流程：

```
"D:\Gowin\Gowin_V1.9.12.03_x64\IDE\bin\gw_sh.exe" < tools/validate_flow.tcl
```

## 验证结论

本工程已用 Gowin EDA V1.9.12.03 实测通过完整流程（在临时副本中执行，
因此交付目录内不含编译产物）：

- GowinSynthesis 综合通过，无错误
- 布局布线通过，无 `PR1014` 时钟布线告警
- 码流生成成功（`led_water.fs`）
- 器件识别：`GW5AT-LV60PG484AC1/I0` / GW5AT-60 / Version B
- 时钟 `clk_d` 走全局时钟网络 PRIMARY
- 资源占用：LUT 50、寄存器 32/60780、I/O 10/297
