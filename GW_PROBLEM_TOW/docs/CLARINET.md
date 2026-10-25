# 实时单簧管

单簧管是第三套 FPGA 实时合成音源，覆盖实际音高 D3～B♭6（MIDI 50～94），共 45 个半音。屏幕使用统一升号音名，因此最高音显示为 A#6；这里不按降 B 调乐器的移调记谱显示。

## 合成方法

`src/audio/clarinet_synth.v` 是单声部 DDS 加法合成器。每帧实时计算最多八个分音，低音以奇次分音为主，随音区平滑改变各次分音的权重，再加入少量确定性气息噪声。

`src/rom/clarinet45.hex` 仅保存 45 行、每行八个 Q1.15 分音权重，总权重为 32768。它是手工设计的音色参数，不是录音、逐音 PCM 或拟合实测值。`sine256.hex` 是共享正弦函数表，`frequency88.hex` 是共享频率参数表。没有新增 WAV/PCM/ADPCM 播放路径；仿真生成的 WAV 只用于试听。

相位累加器为 32 位，正弦函数使用线性插值。每个分音的频率增量以 36 位检查，超过 0.46875 倍采样率的分音不参与计算，避免谐波越过 Nyquist 后折返。上部音域因此使用更少的分音。

单声部采用后到音符优先；新的 note-on 重新开始相位和起音包络，其他音高的 note-off 不会截断当前音。力度为零等同 note-off。保持 gate 时包络达到持续电平并保持，松键后逐步释放。默认采样率下起音约 15.7 ms、释放约 31.5 ms。

频率沿用系统 `DDS_PITCH_RATIO` 换算，采样节拍仍由 PT8211 提供，所有逻辑使用 50 MHz 时钟。调整 DAC 分频时需要同时检查频率换算和包络时间。合成器保留 ready/valid 反压、停止清音和超时检测，随后使用独立 `output_limiter`。

## 串口屏操作

在 `every` 页增加“单簧管”按钮，触摸弹起事件填入：

```text
printh A5 5A 01 00 45 00 00 00 46 0D
```

脚本为 `screen/tjc_uart/instrument_clarinet_release.txt`。仍使用原来的 40/41/42（十六进制）上一个、下一个、播放命令，45 只选择乐器，不自动发声。

单簧管首次选中 D3，前后按半音循环，独立记忆自己的音符。切换或再次选择乐器会停止当前 SD/单音/实体试听并清音。试听仍保持 0.5 秒 gate、1 秒尾音窗口。上/下一个只改变选择，不改变正在发声的音。

`every.tInstrument` 自动回传“单簧管”，GB2312 为 `B5 A5 BB C9 B9 DC`；屏幕字库需增加“单、簧、管”。容量继续保留至少 8 字节，以兼容“马林巴琴”。`every.tNote` 显示实际音高。内部显示索引为 MIDI-21，即 29～73；对合成器发送的事件仍为 MIDI 50～94。

主机工具可用 `powershell -File tools/send_uart_command.ps1 -Command InstrumentClarinet` 打印命令帧。仅在显式提供 `-Port` 时才连接硬件。

KEY0/KEY1/KEY2 及原三首 SD 乐谱保留原有行为。另增加第 4 首 `CLARINET.BIN`，使用 C45S 格式播放肖邦《夜曲》Op.9 No.2，详见 [夜曲播放](NOCTURNE_CLARINET.md)。

## 再生成与验证

从工程根目录运行：

```powershell
python tools/generate_clarinet_tables.py
python tools/check_project.py
powershell -ExecutionPolicy Bypass -File sim/run_clarinet.ps1
```

专用回归会编译 `.gprj` 清单中的 RTL，覆盖全部 45 音、包络、力度、无关音符释放、反压、各计算状态的清音/复位，以及三乐器独立记忆、真实 UART、中文和音名反馈、SD/实体按键仲裁。

`tools/check_clarinet_audio.py` 将全部 45 音的 184320 个 RTL 样本与独立整数模型精确对照，同时检查实际音高、直流偏置、音量、削波和释放后的静音。它需要 NumPy，可复用 `output/marimba_tools` 中的依赖。输出在 `output/clarinet/`：`clarinet45_realtime.wav`、`audio_report.json` 和仿真日志。

通用 `sim/run_all.ps1` 也包含单簧管 RTL 测试；完整音频模型对照通过上述专用入口执行。参数与音准的数值验证不能替代音色听感评价，当前音色为手工参数初版，尚待开发板和扬声器试听。
