# adc_led — ADC 采样值二进制显示（GW5AT / Tang Mega 60K）

基于工作目录下已有的 `led_water` 流水灯工程改写而成。Gowin EDA 工程，目标器件
**GW5AT-LV60PG484AC1/I0**（GW5AT-60B / PBGA484A，Device Version B），顶层模块 `top`。

- 工程文件：`adc_led.gprj`（双击用 `gw_ide.exe` 打开）
- 已用 Gowin EDA V1.9.12.03 **实测跑通完整流程**，码流在 `impl/pnr/adc_led.fs`
- 已用 ModelSim 做功能仿真，256 点全扫描 **全部通过**

---

## 1. 功能

把 ADC 满量程 8 等分，得到段号 0…7，再把段号以**二进制**写在最低 3 个 LED 上
（LED7…LED3 恒灭）：

| ADC 输入（占满量程） | 段号 | LED2 LED1 LED0 | 点亮的灯 |
|---|---|---|---|
| 0 … < 1/8 | 0 | 0 0 0 | **全灭** |
| 1/8 … < 2/8 | 1 | 0 0 1 | LED0 |
| 2/8 … < 3/8 | 2 | 0 1 0 | LED1 |
| 3/8 … < 4/8 | 3 | 0 1 1 | LED0 + LED1 |
| 4/8 … < 5/8 | 4 | 1 0 0 | LED2 |
| 5/8 … < 6/8 | 5 | 1 0 1 | LED2 + LED0 |
| 6/8 … < 7/8 | 6 | 1 1 0 | LED2 + LED1 |
| 7/8 … 满量程 | 7 | 1 1 1 | LED2 + LED1 + LED0 |

即 LED0 是最低位（每个段翻转一次）、LED1 每 2 段翻转、LED2 每 4 段翻转。
输入最小时**灯全灭**，随 ADC 值上升 LED0→LED1→LED2 按二进制递增。

对 8 位 ADC 而言，段号就是采样值的高 3 位，段边界为
**32 / 64 / 96 / 128 / 160 / 192 / 224**：

```
ADC   0 .. 31 -> 000  全灭
ADC  32 .. 63 -> 001  LED0
ADC  64 .. 95 -> 010  LED1
ADC  96 ..127 -> 011  LED0+LED1
ADC 128 ..159 -> 100  LED2
ADC 160 ..191 -> 101  LED2+LED0
ADC 192 ..223 -> 110  LED2+LED1
ADC 224 ..255 -> 111  全亮
```

实现上直接用采样值的高 3 位 (`lvl_r[7:5]`)，不需要比较器，逻辑最省。

---

## 2. 仿真验证

`sim/tb_adc_led.v` 对 8 位全量程 0…255 逐点扫描，并检查复位、段边界，
以及需求里描述的递增序列：

```
=== tb_adc_led ===
ok   reset: all LEDs off (led_o=ff)
-- level boundaries --
  adc=  0   level=0   led_o=ff   LEDs=........     ok
  adc= 32   level=1   led_o=fe   LEDs=.......+     ok
  adc= 96   level=3   led_o=fc   LEDs=......++     ok
  adc=160   level=5   led_o=fa   LEDs=.....+.+     ok
  adc=224   level=7   led_o=f8   LEDs=.....+++     ok
  adc=255   level=7   led_o=f8   LEDs=.....+++     ok
-- exhaustive sweep 0..255 --
   sweep complete
-- requirement wording --
  smallest  (adc=0)    -> segment 0, LEDs=........  (all off)
  next      (adc=40)   -> segment 1, LEDs=.......+  (LED0)
  next      (adc=100)  -> segment 3, LEDs=......++  (LED0+LED1)
  next      (adc=170)  -> segment 5, LEDs=.....+.+  (LED2+LED0)
=== ALL CHECKS PASSED ===
```

复现方式（ModelSim）：

```
cd sim
vlib work
vlog ../src/adc_led.v tb_adc_led.v
vsim -c -do "run -all; quit -f" work.tb_adc_led
```

---

## 3. 目录结构

```
adc_led/
├── adc_led.gprj                     # 工程文件
├── README.md
├── impl/                            # 综合 / 布局布线产物
│   ├── adc_led_process_config.json
│   ├── gwsynthesis/
│   └── pnr/adc_led.fs               # <-- 下载用码流
├── src/
│   ├── top.v                        # 顶层：ADC 前端选择 + 显示例化
│   ├── adc_led.v                    # ADC → 二进制 LED 映射（核心）
│   ├── spi_adc.v                    # 串行(SPI) ADC 读取控制器
│   ├── adc_led.cst                  # 物理约束（管脚）
│   └── adc_led.sdc                  # 时序约束
├── sim/
│   └── tb_adc_led.v                 # 功能仿真测试台
└── tools/
    ├── make_project.tcl             # 重新生成工程
    └── build.tcl                    # 命令行全流程
```

---

## 4. 管脚约束

### 4.1 已确定的管脚

| 信号 | 管脚 | Bank | 电平 | 来源 |
|---|---|---|---|---|
| `clk` | **V22** | 7 | LVCMOS33 | 板上 50 MHz 晶振（Sipeed 官方例程） |
| `rstn` | **AA13** | 9 | LVCMOS15 | 板上 `rst_n`（Sipeed 官方例程） |
| `led_o[0]` | AB20 | 8 | LVCMOS33 | 沿用 `led_water` 原有 LED 管脚 |
| `led_o[1]` | AA19 | 8 | LVCMOS33 | 同上 |
| `led_o[2]` | AA21 | 8 | LVCMOS33 | 同上 |
| `led_o[3]` | AA20 | 8 | LVCMOS33 | 同上 |
| `led_o[4]` | AB22 | 8 | LVCMOS33 | 同上 |
| `led_o[5]` | AB21 | 8 | LVCMOS33 | 同上 |
| `led_o[6]` | Y22 | 8 | LVCMOS33 | 同上 |
| `led_o[7]` | Y21 | 8 | LVCMOS33 | 同上 |

LED **低电平点亮**（`led_o` 输出 0 时亮），驱动电流 8 mA。

LED 这组管脚对应 Dock 板上 **HDMI 附近那组 PMOD**（`led_water` 原工程用的就是它）。
`adc_led.cst` 底部以注释给出了 Dock 板**左侧 PMOD** 的 LED 管脚
（P19 R19 T21 U21 P16 R17 R18 T18），如果灯插在另一组，对调注释即可。

> **关于 `rstn`**：板上该脚没有外部上拉，所以约束里打开了 FPGA 内部上拉
> （`PULL_MODE=UP`）。`led_water` 原来把它放在 Y12 并写成 LVCMOS33，但 Y12
> 所在 Bank 是 1.5 V，电平类型不匹配；这里换成官方文档给出的 AA13。

### 4.2 必须按实际接线修改：ADC 管脚

`adc_led.cst` 里的 `adc_*` 是**占位值**——都是 GW5AT-60 上确实存在、本工程已经
编译验证过的合法 I/O，但**未必是你 ADC 实际所接的管脚**，请按接线修改：

```
IO_LOC "adc_data[0]" T20;     <-- 改成你的 ADC 数据位实际管脚
...
IO_LOC "adc_dv"      M15;     <-- ADC 数据有效 / 转换完成 信号
```

| 信号 | 占位管脚 | Bank | 电平 |
|---|---|---|---|
| `adc_data[0]` | T20 | 7 | 3.3 V |
| `adc_data[1]` | N15 | 6 | 3.3 V |
| `adc_data[2]` | R14 | 6 | 3.3 V |
| `adc_data[3]` | R16 | 6 | 3.3 V |
| `adc_data[4]` | P15 | 6 | 3.3 V |
| `adc_data[5]` | P14 | 6 | 3.3 V |
| `adc_data[6]` | AA14 | 8 | 3.3 V |
| `adc_data[7]` | N14 | 6 | 3.3 V |
| `adc_dv` | M15 | 6 | 3.3 V |
| `adc_cs_n` | J16 | 11 | 3.3 V |
| `adc_sclk` | P17 | 6 | 3.3 V |
| `adc_din` | K13 | 10 | 3.3 V |

> **注意 Bank 电压**：同一个 Bank 的 VCCIO 必须一致。表里所有 ADC 占位脚
> 都在 3.3 V 的 Bank 6/7/8/10/11 上。若把某个信号挪到 Bank 9，必须改成
> LVCMOS15 + `BANK_VCCIO=1.5`（例如 `rstn` 的 AA13 就是这么配的）。
> 跨 Bank 时务必核对原理图上各 Bank 的供电。

改管脚最省事的办法：IDE 里 `Tools -> FloorPlanner` 图形化分配，会自动回写 `.cst`。

---

## 5. ADC 接口与参数

顶层 `top` 支持两种前端，用参数 `ADC_IF` 选择（默认 `"PAR"`）。

### 5.1 并行 ADC（`ADC_IF = "PAR"`，默认）

```
input [ADC_BITS-1:0] adc_data   // ADC 转换结果
input                adc_dv     // 拉高一个时钟表示 adc_data 有效
```

`adc_dv` 可接 ADC 芯片的转换完成脉冲（EOC / BUSY 下降沿）。若外部没有这个信号，
最简单是接常高（每个时钟都跟随 ADC），或接一个自由运行的采样节拍。

### 5.2 串行 ADC（`ADC_IF = "SPI"`）

```
output adc_cs_n   // 片选，低有效
output adc_sclk   // 时钟
input  adc_din    // 数据输入
```

`spi_adc.v` 是最小 SPI 主机：每 `CLK_FREQ / SAMPLE_DIV` 个时钟启动一次转换，
MSB first、上升沿采样，适合 MCP3202 / ADS7816 / ADC128S022 之类。
默认 12 位、1 kHz 采样。

### 5.3 参数一览

| 参数 | 默认 | 说明 |
|---|---|---|
| `ADC_BITS` | 8 | 并行 ADC 位宽 |
| `HYST` | 2 | 迟滞（8 位 LSB）；抑制 ±1 LSB 抖动闪灯，设 0 则完全跟随 |
| `ADC_IF` | `"PAR"` | `"PAR"` 并行 / `"SPI"` 串行 |
| `SPI_BITS` | 12 | 串行 ADC 位宽 |
| `SAMPLE_DIV` | 50000 | SPI 采样分频（50 MHz / 50000 = 1 kHz） |
| `SPI_CPOL` | 0 | SCLK 空闲电平 |
| `ACTIVE_LOW`（`adc_led`） | 1 | LED 低电平点亮 |

`adc_led` 内部把采样值归一化到统一的 8 位空间再取高 3 位
（`ADC_BITS > 8` 取高 8 位，`< 8` 左对齐），所以换不同位宽的 ADC 时不用改逻辑。
注意：段边界固定按 **8 等分满量程** 计算，与 ADC 位宽无关。

### 5.4 改成"进度条"效果

把 `src/adc_led.v` 里

```verilog
wire [7:0] decoded = {5'b00000, seg};
```

换成下面这行（文件注释里已给出），就变成 1、2、3…8 个灯依次点亮：

```verilog
wire [7:0] decoded = { seg[2], seg[2]&seg[1], seg[2]&seg[0],
                       seg[2]|seg[1], seg[1]&seg[0],
                       seg[1], seg[0], 1'b0 };
```

---

## 6. 编译

IDE：

```
"D:\Gowin\Gowin_V1.9.12.03_x64\IDE\bin\gw_ide.exe" "C:\Users\30415\Desktop\gowin_work\adc_led\adc_led.gprj"
```

然后 `Synthesize` → `Place & Route`。

命令行全流程：

```
"D:\Gowin\Gowin_V1.9.12.03_x64\IDE\bin\gw_sh.exe" tools/build.tcl
```

重新生成工程：

```
"D:\Gowin\Gowin_V1.9.12.03_x64\IDE\bin\gw_sh.exe" tools/make_project.tcl
```

---

## 7. 实测结论（V1.9.12.03）

| 项目 | 结果 |
|---|---|
| GowinSynthesis | 通过，无 error |
| 布局布线 | 通过，无 error |
| 码流生成 | 成功，`impl/pnr/adc_led.fs` |
| 器件识别 | `GW5AT-LV60PG484AC1/I0` / GW5AT-60 / Version B |
| 资源占用 | LUT/ALU 38（11 LUT + 27 ALU），寄存器 11/60780，I/O 端口 30/297 |
| 时钟 | `clk_d` 走全局时钟网络 PRIMARY |
| 时序 | 最差建立路径数据到达约 10 ns < 20 ns（50 MHz），满足 |
| 功能仿真 | 0…255 全扫描 + 段边界 + 复位，**全部通过** |

编译时会出现两条告警，都是无害的：

1. `WARN (CV0016) Input adc_din is unused`
   并行模式下不使用串行输入，正常。
2. `WARN (PR1014) Generic routing resource will be used to clock signal 'clk_d'`
   V22 是板上晶振所在的普通 I/O（不是专用时钟脚），所以时钟走了通用布线。
   Sipeed 官方例程也用 V22，实机运行正常；本设计只有 50 MHz 纯同步低速逻辑，
   偏斜影响可忽略。

---

## 8. 与需求的两点差异（需要你确认/处理）

1. **器件型号**：需求写的 `GW5AT-LV60PG484AC1/10` 在 Gowin 器件库里不存在，
   按 `C1/I0` 处理（`led_water` 工程也是这么建的）。GW5AT-60B 的 PBGA484A
   封装只有三种料号：

   | 料号 | 器件ID |
   |---|---|
   | `GW5AT-LV60PG484AC1/I0` | `gw5at60b-002` |
   | `GW5AT-LV60PG484AC2/I1` | `gw5at60b-003` |
   | `GW5AT-LV60PG484AES` | `gw5at60b-009` |

2. **ADC 管脚**：见 §4.2。原理图 PDF 的文字用 Type3 子集字体嵌入、字形无法可靠
   还原，管脚表没能从 PDF 里提出来，所以 ADC 的实际管脚请按板卡接线核对后填入
   `src/adc_led.cst`。（`clk` / `rstn` / 8 个 LED 的管脚已按 Sipeed 官方例程
   核对确定，可以直接用。）

---

## 9. 参考资料

- [Sipeed Tang Mega 60K 文档](https://wiki.sipeed.com/hardware/en/tang/tang-mega-60k/mega-60k.html)
- [Sipeed TangMega-60K-example（本工程管脚出处）](https://github.com/sipeed/TangMega-60K-example)
- [pmod_led.cst（LED / clk / rst_n 管脚）](https://github.com/sipeed/TangMega-60K-example/blob/main/pmod_led_neo/src/pmod_led.cst)
- [NEO_DOCK.cst（Dock 板外设管脚）](https://github.com/sipeed/TangMega-60K-example/blob/main/cam_dvi/src/NEO_DOCK.cst)
