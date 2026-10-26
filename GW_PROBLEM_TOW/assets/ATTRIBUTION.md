# 当前素材来源与使用方式

## 单簧管参数拟合

`clarinet/source/{pp,mf,ff}/` 保存 Iowa 大学三个力度、四个音区的 12 份 44.1 kHz/16-bit/mono AIFF。`fit_clarinet_params.py` 离线分割并测量 D3～B♭6 共 135 组音高/力度参数，生成 32 分音起音/持续权重、相对相位、包络和噪声参数。来源、使用说明及指纹见 `clarinet/ATTRIBUTION.md`、`clarinet/source_manifest.json`；测量与拟合结果见 `clarinet/measurements.json`、`clarinet/fit_report.json`。逐音表情及轻微音高变化为另行设计的动态控制。FPGA 只读取参数，继续实时合成。

## 马林巴参数拟合

`marimba/source/{pp,mf,ff}/` 的 AIFF 来自 University of Iowa Electronic Music Studios Musical Instrument Samples，录制者为 Lawrence Fritts 及贡献者。
来源页面：[Iowa MIS](https://theremin.music.uiowa.edu/MIS.html)。项目原有来源记录说明其录音可下载用于项目。
源文件为 yarn mallet，96 kHz、24 位、双声道，保留各力度的实际测量来源。
`tools/fit_marimba_params.py` 从源录音拟合当前 MIDI 36～83 的模态和起音参数，并以 A4=440 Hz 校准。
`marimba/fit_report.json` 保存测量及校准结果。FPGA 只读取参数 ROM，不播放这些录音。

## 苹果铃声音符转写

`ringtone/apple_marimba_2007.mp3` 的原有下载地址：
[Awesome Ringtone Apple Marimba](https://raw.githubusercontent.com/w3teal/awesome-ringtone/main/Apple/2007%20-%20Marimba.mp3)。
`apple_marimba_pcm_board.wav` 为保留的离线转写输入，`tools/make_ringtone_score.py` 估计音符起音、音高和力度，生成 `sd_card/RINGTONE.BIN`。
原录音及音乐权利仍归相应品牌或作者；公开收录不代表获得额外授权。当前 FPGA 用实时马林巴模型演奏转写事件。

## 三星安卓主题

`ringtone/android/samsung_over_the_horizon_s3.mid` 的原有来源：
[Samsung GT-E1270 phone-tone archive](http://onj3.andrelouis.com/phonetones/unzipped/Samsung/GT-E1270/01%20Ringtones/07%20Over%20the%20horizon.mid)。
`tools/make_android_ringtone.py` 仅提取 GM Marimba 声部，合并同刻同音，保留音符时序和力度。
其他乐器、声像、通道音量和固定弯音偏移不重现。音乐和 MIDI 权利仍归原权利人。

## 钢琴

当前钢琴波形使用数学函数和人工音色参数，不依赖旧采样钢琴素材。
乐谱 MIDI 来源及改编记录见 `source/ATTRIBUTION.md` 和 `sd_card/PIANO.json`。
