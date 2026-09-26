# adc_led - GW5AT-60 片上 ADC 二进制 LED 显示

Gowin EDA V1.9.12.03 工程，顶层为 `top`，目标器件为工具实际支持的
`GW5AT-LV60PG484AC1/I0`（Device ID `gw5at60b-002`）。用户给出的 `/10`
不在当前器件库中，因此按原理图对应的 C1/I0 速度等级创建工程。

## 模拟输入接线

本工程使用 GW5AT-60 的片上 ADC，选择 `ADCV` 差分电压通道：

| 用途 | FPGA 球位 | 专用功能 | 外部连接 |
|---|---:|---|---|
| 正输入 | **L10** | `ADCVP`（原理图 Page 1 标作 `ADVCP`） | 被测信号 |
| 负输入 | **M9** | `ADCVN` | 模拟地/信号回路 |

**ADCVP - ADCVN 只允许 0..1 V，且 ADCVP 必须高于 ADCVN。禁止输入超过
1 V 的差分电压，也不能把 3.3 V 信号直接接入。** 这两个球位是 ADC 硬核专用
模拟脚，由 `ADC_SAR` 直接使用，不是顶层数字端口，因此 CST 中没有普通
`IO_LOC` 约束。原理图上它们引到 BTB 连接器 `C2400`。

备用温度/电压通道 `ADCT` 位于 `N10/ADCTP` 与 `N9/ADCTN`；本工程未选择它。

## 工作方式

IP Core Generator 生成的 `Gowin_ADC` 参数如下：

- Voltage mode，`vsenctl=3'b000`（ADCV）
- 50 MHz 外部时钟，8 分频，ADC 时钟 6.25 MHz
- 14 位输出 `adcvalue[13:0]`（器件 ADC 标称 10 位精度）
- 每次 `adcreqi` 上升沿请求转换，等待 `adcrdy` 后更新显示
- 两次转换之间等待 1024 个系统时钟（约 20.48 us）
- 配置完成后自动产生约 1.3 ms 内部复位，不依赖外部复位焊盘

UG299 规定电压模式下实际电压为 `adcvalue / 2048` V，因此 0..1 V 对应
ADC 码 0..2048。程序把这段范围等分为八档，显示在 LED2..LED0；LED7..LED3
通常恒灭。LED 为低电平点亮：

| 输入电压 | ADC 码 | LED2 LED1 LED0 | 点亮 |
|---:|---:|:---:|---|
| 0..<0.125 V | 0..255 | 000 | 全灭 |
| 0.125..<0.250 V | 256..511 | 001 | LED0 |
| 0.250..<0.375 V | 512..767 | 010 | LED1 |
| 0.375..<0.500 V | 768..1023 | 011 | LED1 + LED0 |
| 0.500..<0.625 V | 1024..1279 | 100 | LED2 |
| 0.625..<0.750 V | 1280..1535 | 101 | LED2 + LED0 |
| 0.750..<0.875 V | 1536..1791 | 110 | LED2 + LED1 |
| 0.875..1.000 V | 1792..2048 | 111 | LED2 + LED1 + LED0 |

上电后 LED0 到 LED7 会各点亮约 125 ms，作为 PMOD 管脚和极性的自检。自检
结束后，如果 ADC 一直没有产生 `adcrdy`，LED7 会闪烁；ADC 正常时显示电压档位。

## 数字管脚

| 信号 | 管脚 | 说明 |
|---|---:|---|
| `clk` | V22 | 50 MHz |
| `led_o[0..7]` | AB20, AA19, AA21, AA20, AB22, AB21, Y22, Y21 | 照片中的 PMOD1，低有效 |

## 文件和构建

- `src/top.v`：ADC 请求/完成控制和显示例化
- `src/gowin_adc/gowin_adc.v`：由 Gowin IP Core Generator 生成的 ADC IP
- `src/adc_led.v`：ADC 有效电压范围到三位二进制 LED 映射
- `src/adc_led.cst`：时钟和 PMOD1 LED 管脚约束
- `sim/tb_adc_led.v`：遍历 0..1 V 对应全部 2048 个 ADC 码值

命令行构建：

```powershell
& 'D:\Gowin\Gowin_V1.9.12.03_x64\IDE\bin\gw_sh.exe' tools/build.tcl
```

IDE 打开：

```powershell
& 'D:\Gowin\Gowin_V1.9.12.03_x64\IDE\bin\gw_ide.exe' adc_led.gprj
```

成功构建后的下载码流位于 `impl/pnr/adc_led.fs`。

## 已验证结果

2026-09-26 使用上述 Gowin V1.9.12.03 工具链完成综合、布局布线、时序分析和
码流生成：

- 综合及布局布线：通过，无 error
- ADC 硬核：`ADC_SAR 1/1`
- 时序：50 MHz 约束下 setup/hold 违例均为 0，工具报告 Fmax 218.938 MHz
- 功能仿真：0..1 V 的全部 2048 个 ADC 码值通过，0 error / 0 warning
- 下载码流：`impl/pnr/adc_led.fs`

布局布线仅有一条 `PR1014` 告警：V22 指定的板载时钟使用通用路由进入全局
时钟网络。最终时序报告无违例。
