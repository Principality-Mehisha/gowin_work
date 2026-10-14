# DVI 静态图片显示

这是一个独立的 Gowin 工程，不修改原音乐工程。目标器件为 Tang Mega 60K SOM / TANG MEGA NEO Dock 上的 GW5AT-LV60PG484AC1/I0（GW5AT-60B）。

## 实现内容

- DVI-D 单链路 TMDS，640×480、负极性同步，像素时钟约 25.156 MHz，刷新率约 59.90 Hz。
- 附图按比例缩放到 208×240 RGB565 片上 ROM，再以最近邻 2 倍放大到 416×480；居中显示，左右各留 112 像素黑边，不裁切原图。
- `KEY0` 按下时显示彩条，松开恢复照片；`KEY2` 为低有效复位。
- 只输出 DVI 视频，不含音频或 HDMI 数据包；图像固化在 FPGA 中，无需外部存储器或启动时传图。

本实现的 DVI 引脚按工程现有 Tang Mega NEO Dock 管脚约束设置，直接接到该板相应的 DVI 输出。若你的载板/转接板不同，先核对原理图并调整 `src/dvi_photo.cst`。显示器、连接线和实际链路尚未在硬件上验证；需要使用数字 DVI-D 链路或兼容的 HDMI 转 DVI-D 线缆，不适用于无源 DVI-VGA 转接头。请确认显示器所接输入为数字 DVI，并在显示器菜单中选择该输入。

## 构建和下载

在 Gowin IDE 中打开 `dvi_photo.gprj`，执行 Place & Route / bitstream 生成，然后用 Programmer 下载生成的 `impl/pnr/dvi_photo.fs` 到目标 FPGA。

也可在已安装 Gowin V1.9.12.03 的 PowerShell 中运行：

```powershell
& 'D:\Gowin\Gowin_V1.9.12.03_x64\IDE\bin\gw_sh.exe' `
  'D:\GitHub\gowin_work\dvi_photo\tools\build.tcl'
```

构建结果：[`impl/pnr/dvi_photo.fs`](impl/pnr/dvi_photo.fs)。

## 更换图片

安装 Python Pillow 后运行：

```powershell
python tools/prepare_image.py 'C:\path\to\image.jpg'
```

脚本生成 `src/photo_rgb565.hex`、综合用 `src/photo_rom.v` 和 `preview.png`。再重新构建并下载 bitstream。由于图片固化在 ROM，改图需要重新综合。

## 验证情况

`tools/simulate.ps1` 运行 TMDS 编码器测试及完整视频帧仿真。仿真检查了 TMDS 控制码、8192 个测试样本、像素映射、缩放、黑边、彩条与同步时序；仿真输出帧与 `preview.png` 逐像素一致。仿真定义 `PHOTO_ROM_SIM` 时用 `$readmemh` 加速 ROM 读取；综合仍使用同一脚本生成的自包含 ROM `case` 表。

Gowin V1.9.12.03 综合和 P&R 已成功，器件资源报告为 66/118 BSRAM、592 个逻辑单元和 4 个 OSER10。STA 建立时间报告为 0 个违例；工具仍报告少量保持路径和主时钟普通布线警告（PR1014），且未做板上测量。因此在接上 HP LE2001wm 后，请先检查彩条模式、显示器输入选择及同步锁定；若无图像，优先核对板卡版本、DVI 接口引脚和线缆类型。
