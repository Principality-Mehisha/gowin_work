# 实时单簧管

单簧管是第三套 FPGA 实时合成音源，覆盖实际音高 D3～B♭6（MIDI 50～94），共 45 个半音。屏幕使用统一升号音名，因此最高音显示为 A#6；这里不按降 B 调乐器的移调记谱显示。

## 合成方法

`src/audio/clarinet_synth.v` 是单声部 DDS 加法合成器。每帧实时计算最多 32 个分音，分别使用 pp、mf、ff 三档实测音色，在力度层之间插值；起音频谱逐步过渡到持续段频谱，再加入经过滤波的确定性气息噪声。

参数来自 [Iowa MIS 单簧管录音](https://theremin.music.uiowa.edu/MISBbclarinet.html) 的离线分析：12 个原始音阶文件、45 个实际音高、三档力度，共 135 组。来源、哈希与测量结果保存在 `assets/clarinet/`。实测频谱参数与下面的演奏动态是两部分：动态曲线是听感调整后的设计值，不是对真实演奏逐时刻的完整复刻。

| ROM | 排列与字段 |
| --- | --- |
| `clarinet45.hex` | 4320 行 × 40 位；profile=`dynamic*45+MIDI-50`，每组 32 行；高至低为相对相位 8 位、持续权重 16 位、起音权重 16 位 |
| `clarinet45_env.hex` | 135 行 × 96 位；低至高每 16 位为起音步进、释放步进、频谱过渡步进、Q12 增益、起音噪声 Q15、持续噪声 Q15 |

两组权重均归一化为 32760。三档力度共用 mf 相对相位，避免力度插值引入相位跳变。内部力度 64、160、240 对应三个测量层，中间线性插值，低于/高于端点使用端点音色并继续缩放音量。`sine256.hex` 是共享正弦函数表，`frequency88.hex` 是共享频率参数表。FPGA 只读取这些参数，继续逐样本合成；没有 WAV/PCM/ADPCM 录音播放路径。

相位累加器为 32 位，正弦函数使用线性插值。每个分音的频率增量以 36 位检查，超过 0.46875 倍采样率的分音不参与计算，避免谐波越过 Nyquist 后折返。上部音域因此使用更少的分音。

单声部采用后到音符优先；每个新的 note-on 都重新开始相位、起音包络和频谱过渡，其他音高的 note-off 不会截断当前音。力度为零等同 note-off。取消自动连奏，避免相邻音听起来连成一条拖长的持续音；原乐谱时间戳和音符时长不改动。包络进度采用平方曲线，起音步进至少 81、释放至少 51，默认采样率下分别不超过约 25 ms 和 40 ms。

保持 gate 后仍持续计算演奏起伏：每音约前 126 ms 的表情增益从 0.75 渐至 1，之后渐缓至约 0.781；平滑的低频气息扰动同时影响增益与频率。起音有约 -3 音分的短暂偏移，约 31 ms 内回到标准音高附近；之后只有微小、不规则的音高浮动，不做明显的规则颤音。气息状态跨音保留，停止/复位清零。音龄计数在 65535 帧（约 4.03 s）饱和，之后保留当时的气息值；当前曲目与 0.5 s 单音试听不触及此限制。

频率沿用系统 `DDS_PITCH_RATIO=193274` 换算，PT8211 提供的实际采样率为 `50 MHz / 3072 = 16276.041667 Hz`，所有逻辑使用 50 MHz 时钟。分音的力度/起音/持续插值、包络和表情增益分时复用乘法器。频谱收敛后缓存系数，频率与表情仍逐帧更新。仿真最大输出等待 554 个时钟，低于每帧 3072 个时钟预算。调整 DAC 分频时需要同时检查频率换算和包络时间。保留 ready/valid 反压、停止清音、超时检测及独立 `output_limiter`。

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
python tools/fit_clarinet_params.py --reuse-measurements
python tools/check_project.py
powershell -ExecutionPolicy Bypass -File sim/run_clarinet.ps1
powershell -ExecutionPolicy Bypass -File sim/run_nocturne.ps1 -RenderAudio
```

整曲也可用 `sim/run_clarinet_segments.ps1` 分四段并行渲染。分段点选在新音符起音前，只恢复跨音保留的气息和限幅峰值；各段结束时 RTL 检查下一段的初始状态，再对拼接后的全部样本进行独立模型核对。会话中断后，使用 `-Prepared -Resume` 复用未变更输入下已经通过的段。

如需从 AIFF 重新测量，运行 `python tools/fit_clarinet_params.py`；兼容入口 `generate_clarinet_tables.py` 调用同一拟合器。这些工具需要 NumPy/SciPy，可复用 `output/marimba_tools` 中的依赖。

专用回归会编译 `.gprj` 清单中的 RTL，覆盖全部 45 音、135 档音色组合及 18 个插值边界、长音动态、包络、无关音符释放、反压、各计算状态的清音/复位，以及三乐器独立记忆、真实 UART、中文和音名反馈、SD/实体按键仲裁。

`check_clarinet_audio.py` 精确对照 45 音的 276480 个 RTL 样本及 22000 个长音样本，检查音高、直流、音量、削波、释放静音以及长音的响度/音高变化。`check_clarinet_layers.py` 再精确对照 78336 个多力度样本。整曲检查对照《夜曲》的全部 3300342 个 RTL 样本。

输出在 `output/clarinet_calibration/`：`clarinet45_expressive_realtime.wav`、`tone_report.json`、`layer_report.json`、`Chopin_Nocturne_Op9_No2_Clarinet_Expressive_Realtime.wav`、`audio_report.json` 和日志。

通用 `sim/run_all.ps1` 也包含单簧管 RTL 测试；完整音频模型对照通过上述专用入口执行。早期“实测频谱 + 自动连奏”版本虽改善频谱误差，用户试听认为变差；当前版本以用户认可“起伏更自然了”的逐音动态原型为实现目标。频谱拟合、音准和整数模型一致性都不能替代音色听感或开发板扬声器试听。
