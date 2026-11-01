# 三首钢琴曲的原始 MIDI（待取得）

当前目录尚未取得以下 MIDI，不能将转换工具测试通过视为三首实际乐曲已经生成。

| 预期源文件 | 曲目 | 建议上传编号 |
| --- | --- | --- |
| fur_elise.mid | 致爱丽丝 | PN001 |
| canon_piano.mid | 卡农（钢琴版） | PN002 |
| turkish_march.mid | 土耳其进行曲 | PN003 |

在项目根目录执行以下命令，可下载缺少的 MIDI 并生成三首 BIN：

```powershell
python -B tools/make_classical_scores.py --download
```

也可以将上述三个 MIDI 以表中名字放到本目录，然后离线执行：

```powershell
python -B tools/make_classical_scores.py
```

输出目录为 `sd_card/piano_classics/`，包含三个 BIN、校验清单和上传说明。
工具保留速度变化、力度和踏板；检查 A0～C8 音域、8 个事件槽位和 100 KiB 大小限制。
如果真实 MIDI 超过限制，会拒绝生成，不会静默裁剪曲目或删除其他音高。
它不会打开 COM 口、修改物理 SD 卡或改写已有三首预置乐谱。

来源页面和原始下载链接在 `tools/make_classical_scores.py` 的 `CATALOG` 中。
下载后清单记录实际源文件与 BIN 的 SHA256、事件数、时长、最大同时发音和 CRC32。
