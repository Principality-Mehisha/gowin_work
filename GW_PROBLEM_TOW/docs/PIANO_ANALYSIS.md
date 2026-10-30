# 钢琴 HDMI：瀑布流、频谱与波形

默认仍为钢琴瀑布流。新增频谱图和波形图只观察钢琴实际送入PT8211的16位PCM，支持SD第3首PIANO.BIN和UART钢琴单音试听，不采集马林巴。
三种显示共用原来的1600×900/60 Hz输出、TMDS引脚及显示器接线。

## 串口屏按钮

增加三个按钮，将以下指令分别放入触摸弹起事件，关闭组件ID发送。现有115200/8N1、recmod=0保持不变。

| 显示 | 完整printh指令 | 事件脚本 |
| --- | --- | --- |
| 瀑布流 | printh A5 5A 01 00 50 00 00 00 51 0D | screen/tjc_uart/view_waterfall_release.txt |
| 频谱图 | printh A5 5A 01 00 50 01 00 00 52 0D | screen/tjc_uart/view_spectrum_release.txt |
| 波形图 | printh A5 5A 01 00 50 02 00 00 53 0D | screen/tjc_uart/view_waveform_release.txt |

CMD=0x50，P0为0/1/2，P1/P2必须为0。无效参数返回原反馈结果1，保持当前画面；有效命令返回原反馈结果0，page0.n5回显命令80。无需增加新的状态控件。
模式选择不停止、重播或切换乐器；停止/切曲也不会自动改变所选画面。KEY2复位恢复瀑布流。显示选择在下一次垂直消隐期通过快照更新，避免半帧切换。

可在没有SD卡时先选择频谱或波形，再选择钢琴、用UART单音按钮试听。没有钢琴数据或播放马林巴时，两种分析画面显示空坐标和WAITING FOR PIANO，不沿用旧波形。

主机工具只打印帧，显式指定-Port才发送到串口：

```powershell
powershell -File tools/send_uart_command.ps1 -Command ViewWaterfall
powershell -File tools/send_uart_command.ps1 -Command ViewSpectrum
powershell -File tools/send_uart_command.ps1 -Command ViewWaveform
```

## 数据与刷新

- 采样率来自当前DAC节拍：50 MHz / 3072 ≈ 16276.041667 Hz。
- 频谱采用1024点Hann窗、定点radix-2 FFT，显示512个非负频率点，频率间隔约15.8946 Hz，横轴约0～8.1 kHz。柱高为归一化FFT的近似对数幅度，不是校准声压或功率谱密度。
- 波形使用同一段PCM的前512个样本，时间窗口约31.46毫秒，按上升过零触发；无过零时最多等待1024个采样后触发。幅度保留实际PCM尺度，不自动增益。
- 每块采样约62.91毫秒，计算及输出约0.66毫秒；等待视频换帧确认后采集下一块。因此分析数据约每秒12～15次刷新，HDMI扫描仍为60 Hz。首次显示需要一次触发和完整采样块。
- 系数为片上的1024项窗函数和512项复数旋转因子ROM，由tools/generate_analysis_tables.py生成，不需要SD查表，也不增加SD文件。

## 模块边界

piano_score_player从DAC已锁存的样本输出分析接口；instrument_system仅输出钢琴有效标志及清除状态。piano_video在50 MHz运行piano_audio_analysis，在像素域使用analysis_frame_cdc双缓冲读取，piano_analysis_scene渲染频谱/波形，video_source选择三种场景。

生产者在整块写完后发布银行及代次信息，消费者只在垂直消隐期交换，并回传确认。写侧在确认前不会重用可见银行。停止、重触发、切曲和复位清除当前采集；Gray代次计数避免旧的未确认结果重新出现。模式沿用原请求/确认快照跨域，数据/控制保持原五拍像素延迟。

## 验证与构建

```powershell
python tools/check_project.py
powershell -ExecutionPolicy Bypass -File sim/run_analysis.ps1
& 'D:/Gowin/Gowin_V1.9.12.03_x64/IDE/bin/gw_sh.exe' tools/build.tcl
python tools/check_analysis_build.py
```

FFT六类向量共3072行和真实UART钢琴C4的512行结果均与定点参考逐字相同，参考另与浮点复数FFT交叉检查。
两个新增画面各144万个RGB像素与独立字体/几何参考完全一致。截图来自真实钢琴合成器RTL数据，不是开发板实拍：

![频谱与波形RTL预览](../output/piano_analysis/preview.png)

最终资源、时序、回归日志和指纹见output/piano_analysis/verification.json。原版本源代码及位流已备份在output/piano_analysis/before/。
当前使用77/118块BSRAM，比增加分析显示前多9块，剩余41块；DSP为27.5/118。布局布线耗时97秒。系统/像素Fmax为60.088/116.744 MHz，对应目标50/108 MHz；三个数据时钟域的setup/hold违例均为0。
新位流仍为output/GW_PROBLEM_TOW.fs。本轮没有下载开发板或烧录串口屏；已有视频复位恢复/移除违例仍单独记录。
