# Piano_88 SD 卡采样数据

`music/PIANO.BIN` 是原手动钢琴工程使用的音色采样库。
使用 `../tools/copy_piano_bank_to_sd.ps1` 复制到 SD 卡根目录。
生成采样库、手动演奏源码及相关仿真仍保留在 `Piano_88`。

自动读取乐谱并演奏的工程已独立至
[`../../Piano_Score`](../../Piano_Score/README.md)。
它使用的 `sd_card/PIANO.BIN` 保存音符事件，与本目录的采样库格式不同。

旧读卡探测、BIN 流水灯及 WAV/PCM 播放测试工程已删除。
`music/` 中保留原音色库、音源署名及已有音频资料，供原工程使用和追溯。
