# Croatian Rhapsody PCM Player

这是一个独立的新工程，不依赖旧的实时合成器。Python 在烧录前离线渲染
《克罗地亚狂想曲》开头片段，使用钢琴谐波、击弦瞬态、衰减和释放包络生成
单声道 PCM，然后编码到外置的 `src/croatian_rhapsody.hex`。
FPGA 端只做 ROM 读取、8-bit μ-law 解码和 PT8211 串行发送，因此不会发生
实时乘法位宽截断或音频数据溢出。

## 构建

```powershell
& "C:\Users\30415\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe" `
  tools\generate_pcm_hex.py
& "D:\Gowin\Gowin_V1.9.12.03_x64\IDE\bin\gw_sh.exe" tools\build.tcl
```

生成文件：

- `src/croatian_rhapsody.hex`：8-bit μ-law 音乐 ROM；
- `src/rom_params.vh`：由生成器自动更新的 ROM 参数；
- `output/piano_preview.wav`：烧录前的电脑端预览；
- `impl/pnr/Croatian_Rhapsody_PCM.fs`：高云烧录文件。

当前采样率约为 16.276 kHz，片段约 14.18 秒，ROM 深度 262,144 字节。
工程使用 PT8211 的低 WS=右声道、高 WS=左声道、MSB first 时序。
`PA_EN` 为低有效，启动约 50 ms 后才打开功放，避免上电噪声。

`tools\generate_pcm_hex.py --audio <file>` 仍可用于诊断外部录音，但需要
额外的 PyAV；正常构建不依赖它。
