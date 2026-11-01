# 本次选定的三首钢琴MIDI

来自Mutopia Project，2026-11-01下载。使用 `python -B tools/make_selected_piano.py`
生成PN003～PN005的P88S乐谱和蓝牙v2配套传输包；输出目录已经存在时工具拒绝覆盖。
通过 `--download` 可获取缺少的MIDI。原有三首工具 `make_classical_scores.py` 保持原配置。

| MIDI | 作品 | 目标编号 | 编辑版本与许可 |
| --- | --- | --- | --- |
| fur_elise.mid | 贝多芬《致爱丽丝》WoO 59 | PN003 | Stelios Samelis；Public Domain |
| bach_prelude_c_major.mid | 巴赫《C大调前奏曲》BWV 846 | PN004 | Jeff Covey；CC BY 3.0 |
| turkish_march.mid | 莫扎特《土耳其进行曲》K.331第三乐章 | PN005 | Rune Zedeler、Chris Sawer；Public Domain |

来源及许可：

- https://www.mutopiaproject.org/cgibin/piece-info.cgi?id=931
- https://www.mutopiaproject.org/cgibin/piece-info.cgi?id=117
- https://www.mutopiaproject.org/cgibin/piece-info.cgi?id=108
- 巴赫版本署名：Johann Sebastian Bach，排版Jeff Covey，Mutopia 2009-12-22。
  许可：https://creativecommons.org/licenses/by/3.0/

转换将MIDI音符时间量化为毫秒，保留源文件中的速度、力度和踏板事件含义；
这三份文件无需删音、缩短曲长或进行同音冲突修正。P88S合成音色与原MIDI播放器的音色不同。
时长与反复以此处MIDI为准，不表示所有演奏版本具有相同长度。
原MIDI及生成BIN的SHA256、事件数、时长、CRC32详见输出manifest.json。
