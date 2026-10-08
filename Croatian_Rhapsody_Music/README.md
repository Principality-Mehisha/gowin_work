# Croatian Rhapsody Piano

这是一个仿照 `GoWin_FPGA60k_Music` 的 Tang Mega 60K + NEO Dock 音频工程，
使用板载 PT8211 DAC 实时合成一段《克罗地亚狂想曲》的钢琴风格主题片段。

## 运行效果

- 上电后先让音频时钟稳定约 50 ms，再打开功放；
- 约 100 ms 后开始播放，64 个音符事件循环演奏；
- 旋律使用小型正弦查表基音、衰减谐波、锤击起音、ADSR 风格包络和低通
  滤波，避免三角波带来的明显电子蜂鸣感，不需要外部音频采样文件；
- 包络乘法使用显式 37 位扩展，避免 Verilog 窄位宽乘法导致的 PCM
  溢出、杂音和旋律丢失；
- 左右声道发送相同的单声道钢琴混音；
- 8 个 PMOD LED 按照旋律段落指示当前播放位置；
- 拉低 `sys_rst_n` 会停止功放并从头重新播放。

这里实现的是适合 FPGA 资源规模的主题化简编曲，不是录音或完整多声部
伴奏。若需要更完整的钢琴编曲，可以继续扩展 `song_note` 和
`song_units` 两个函数，或改成双音符/采样 ROM 结构。正弦查表版本已经在
Gowin V1.9.12.03 下重新生成并通过布局布线。

## 音频接口

PT8211 使用 16-bit LSBJ/Japanese right-justified 时序，而不是标准 Philips
I2S：

- `HP_BCK`：1.5625 MHz bit clock；
- `HP_WS`：低电平右声道，高电平左声道；
- `HP_DIN`：有符号 16-bit PCM，MSB first；
- `PA_EN`：低有效功放使能；
- 采样率约 48.828 kHz。

## 构建

用 Gowin EDA 打开 `Croatian_Rhapsody_Music.gprj`，运行综合、布局布线和
生成码流；也可以在 Gowin Shell 中运行：

```text
gw_sh.exe tools/build.tcl
```

生成的烧录文件位于 `impl/pnr/Croatian_Rhapsody_Music.fs`。

## 引脚

`src/Croatian_Rhapsody_Music.cst` 沿用国际歌工程中已经验证的时钟、复位、
LED 和 NEO Dock 音频引脚，不需要重新接线。
