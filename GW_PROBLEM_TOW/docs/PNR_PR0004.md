# PR0004「0 unrouted nets」排查（2026-11-03）

## 结论与修正

在 Gowin V1.9.12.03、GW5AT-60B 上，当前设计的直接触发条件是 CST 中新增的这一行：

```text
CLOCK_LOC "display_enabled.video/serializer_clk" BUFG = CLK;
```

删除此行即可完成布局布线及位流生成。保留 RTL 中的官方 DCE、三个下降沿复位寄存器，
SDC、IO 引脚和时钟目标均不变。成功报告确认 `serializer_clk` 仍使用 PRIMARY 全局时钟，
`serial_clk` 仍使用 IO HCLK，因此修正没有把这个 540 MHz 分支改成普通布线。

这条额外强制路由约束在当前设计与工具版本组合下触发 PnR 失败。
日志没有给出内部失败原因，不能仅由「0 条未布线」认定成功，也不能认定为逻辑资源超限。

## 单变量对照

三个对照使用同一份用户综合生成的 `GW_PROBLEM_TOW.vg`，器件与 PnR 参数一致：
place=2、route=1、timing_driven=1、route_maxfan=60、replicate_resources=1。
独立工程使用全新输出目录，不读取主工程旧的 `.p/.pr/.fs`。

| 对照 | 唯一改动 | 结果 |
| --- | --- | --- |
| 00_baseline | 无 | 复现 PR0004，未生成位流 |
| 01_without_clockloc | 删除上述 CST 行 | PnR 完成，生成新位流 |
| 02_explicit_serializer_clock | 保留 CST，给 DCE 输出增加 1:1 生成时钟定义 | 仍报 PR0004 |

因此仅补充 DCE 输出时钟定义不能解决这个错误；已采用通过实际编译的单行 CST 修正。
未运行其他预备对照，也没有修改 RTL 或添加时序豁免。
完整对照现场在工作区 `tmp/pr0004_20261103`，精简证据在 `output/pnr_pr0004`。

## 时序状态

消除 PR0004 与满足时序是两项独立结论。成功的单变量对照报告仍有时序违例：

| 时钟 | 目标 MHz | Fmax MHz |
| --- | ---: | ---: |
| sys_clk | 50 | 43.918 |
| audio_clk | 150 | 96.138 |
| pixel_clk | 108 | 126.020 |
| serial_clk | 540 | 882.272 |

全局 Setup 违例端点 2217 个，Hold 违例端点为 0；OSER10 RESET 的 Recovery 仍有负裕量。
串行域 Fmax 高于目标不代表跨域复位路径通过。`tools/check_timing.py` 应继续拒绝此结果。
主工程已于 21:21 再次完成 PnR 和位流生成，Fmax 与违例数量均与成功对照一致。
实际执行 `tools/check_timing.py` 返回 1，报 `sys_clk setup failed`；检查未被放宽。
最终报告与时序检查结果保存至 `output/pnr_pr0004`。

新位流用于编译排查，没有烧录硬件，也不替换 `output/GW_PROBLEM_TOW.fs` 中的历史发布文件。
主工程新文件为 `impl/pnr/GW_PROBLEM_TOW.fs`；16:45 的原位流已备份至
`output/pnr_pr0004/before/GW_PROBLEM_TOW.fs`。
