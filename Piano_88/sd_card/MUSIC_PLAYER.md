# SD 卡音乐播放器

适用本仓库 Tang Mega 60K + NEO Dock，50 MHz 时钟，PT8211 音频输出。
独立工程为 `SD_Music_Player.gprj`，顶层 `sd_music_player`。
用户已确认读卡测试工程对 1GB SDSC 卡初始化、读取第 0 扇区和 CRC 校验成功。
音乐链路已完成仿真；实际卡上的文件播放和声音仍需上板确认。

## 准备卡片

卡片需为 FAT16 或 FAT32，支持无分区的卷及 MBR 主分区。
不支持 FAT12、exFAT、GPT、扩展分区或子目录查找。
已有 FAT16/FAT32 卡无需重新格式化，也无需连续存放文件。

将 `music/MUSIC.WAV` 放到卡根目录，文件名必须为 `MUSIC.WAV`。
当前文件为《克罗地亚狂想曲》完整钢琴 MIDI 编曲的采样演奏版，
约 3 分 23 秒，6614814 字节；并非马克西姆原唱片录音。
完整编曲、钢琴采样和处理说明见 [音源说明](music/ATTRIBUTION.md)。
格式为 16276 Hz、单声道、16-bit 有符号小端 PCM WAV。
不能直接放 MP3、立体声 WAV 或其他采样率的文件。

在 Windows 读卡器中插入约 1GB TF 卡后，可以从仓库根目录执行以下命令，
将 `H` 替换为实际卡片盘符：

```powershell
& .\Piano_88\tools\copy_music_to_sd.ps1 -DriveLetter H
```

脚本检查卡片总容量、USB/SD/MMC 连接及文件系统，只复制文件并校验 SHA256。
已有同名但内容不同的文件时停止；确认需要替换后加 `-Replace`。
它不分区、不格式化，也不直接写扇区。
完成复制并安全弹出卡片后，将卡插回底板 TF 卡槽。

## 下载与操作

使用 Gowin EDA 打开本目录 `SD_Music_Player.gprj` 构建。
或者在仓库根目录执行：

```powershell
& "D:\Gowin\Gowin_V1.9.12.03_x64\IDE\bin\gw_sh.exe" Piano_88/sd_card/build_music.tcl
```

使用 Gowin Programmer 下载 `impl/pnr/SD_Music_Player.fs`。
插卡后下载或复位，播放器自动查找文件、预缓冲并播放一次；播放结束后静音。
耳机或音箱接底板音频输出。

| 按键 | 管脚 | 功能 |
| --- | --- | --- |
| KEY0 | AA13 | 暂停 / 继续，暂停期间保留音频位置 |
| KEY1 | AB13 | 重新初始化卡片，从头重播 |
| KEY2 | Y12 | 整机复位并自动播放 |

按键低电平有效，KEY0/KEY1 经同步和消抖。
读取或格式错误后停止并静音；处理卡片问题后按 KEY1 或 KEY2 重试。
卡片应在复位前插好，不支持热插拔自动恢复。

| LED | 管脚 | 点亮含义 |
| --- | --- | --- |
| 0 | AB20 | SD 初始化成功 |
| 1 | AA19 | 找到根目录 `MUSIC.WAV` |
| 2 | AA21 | 正在播放且未暂停 |
| 3 | AA20 | SD、FAT、WAV 错误或音频缓冲耗尽 |

采用用户实测成功的 LED 管脚，低电平点亮。
正常播放时 0、1、2 亮，3 灭；播放完成后 0、1 亮，2、3 灭。
这与 `SD_Card_Probe` 的灯含义不同：原读卡测试中的 LED1 表示卡片类型。

音频引脚沿用 Piano_88：
`HP_BCK=Y17`、`HP_WS=AB17`、`HP_DIN=AA16`、`PA_EN=AB16`。
SD 引脚为 `MISO=AA15`、`SCK=V15`、`CS=W15`、`MOSI=Y16`。
约束文件为 `src/sd_music_player.cst`。

## 其他音乐

已保存完整 MIDI，可使用项目内真实钢琴采样重新渲染：

```powershell
python -m pip install --target Piano_88/tools/vendor mido==1.3.3
python Piano_88/tools/render_full_piano.py
python Piano_88/tools/prepare_sd_music.py
```

渲染输出 `Piano_88/output/croatian_rhapsody_full.wav`，
转换器现在默认使用完整音乐，而非原 14 秒片段。
转换脚本也接受其他未压缩 PCM16 WAV，可下混单声道并转换采样率：

```powershell
python Piano_88/tools/prepare_sd_music.py --input "D:\Music\song.wav"
```

默认输出 `Piano_88/sd_card/music/MUSIC.WAV`，另写 `MUSIC.json` 记录参数和 SHA256。
脚本需要 NumPy；转换会覆盖电脑端输出文件，不会自动写入卡片。
生成后重新运行复制脚本，无需重新生成 FPGA 码流。
音乐长度由卡片文件和 FAT 卷容量决定，不要求放进片上 BSRAM。
旧的开头预览另存为 `music/opening_excerpt.wav`。

## 实现与验证

数据流：SPI 只读扇区接口 → 512 字节 CRC 校验缓冲 → FAT16/FAT32
根目录查找和簇链遍历 → WAV 解析 → 8192 个样本 FIFO → PT8211 双声道。
FIFO 为 16 KiB，预缓冲 4096 个样本，约 252 ms 后开始播放。
硬件实际采样时钟为 `50 MHz / 3072 = 16276.041667 Hz`。
WAV 头中使用最接近的整数采样率 16276 Hz。

FAT 支持一或两份 FAT、FAT32 活动 FAT、碎片文件及碎片根目录；
每个扇区只有在 CRC 通过后才交付解析。异常簇链、缺少文件、格式错误均会停止。
播放器支持 RIFF 的未知块、奇数长度块填充和扩展 fmt 块；
输出首个 data 块中的 PCM，尾部其他块不播放。

在仓库根目录重新生成测试数据，再切换到仿真目录运行：

```powershell
python Piano_88/tools/generate_sd_music_fixtures.py
cd Piano_88/sim
vsim -c -l transcript_music -do run_music.do
vsim -c -l transcript_sd -do run_sd.do
```

测试覆盖碎片 FAT16/FAT32、MBR 分区、活动第二份 FAT、WAV 块解析、
PT8211 引脚逐帧比对、暂停/继续、重播、结束静音、缺失文件、断裂簇链及 CRC 错误。
另将实际完整 `MUSIC.WAV` 的 3307385 个样本逐一与 Python 解码结果比对，加入接收反压，
并检查 RIFF 错误、错误声道数、错误采样率和提前结束。
完整文件 FAT32 专项测试在 1615 个碎片簇中读取全部 6614814 个字节，
覆盖每簇 8 扇区、多个 FAT 扇区、读取反压和文件末尾。
2026-10-16 整曲测试通过：3307385 个 PCM 样本逐一匹配，
FAT 专项执行 14537 次扇区读取，全部文件字节一致；编译及仿真无错误和告警。
已将完整文件复制到用户 1GB FAT32 卡的 `H:\MUSIC.WAV` 并通过 SHA256 校验。
这张卡的实际布局为：分区起始 LBA 32、512 字节扇区、每簇 8 扇区、
4438 个保留扇区、两份各 1877 扇区的 FAT、根目录簇 2，符合读取器支持范围。
播放器的文件大小及剩余长度使用 32 位计数，不存在旧 ROM 工程的 14 秒容量限制；
整曲仍使用固定的 16 KiB FIFO，BSRAM 不随音乐长度增长。
低层读卡回归另覆盖 SD v1/v2 SDSC、SDHC、初始化和超时恢复。

音乐工程占用 9 / 118 块 BSRAM；无采样 ROM，原钢琴工程的 113 块 BSRAM 不加载。
2026-10-16 使用 ModelSim 10.5b 执行上述两组脚本全部通过，编译及仿真无错误和告警。
Gowin V1.9.12.03 综合、布局布线及码流生成成功，
逻辑资源 4400 / 59904，寄存器 2031 / 60780；
50 MHz 内部时序 setup/hold 违例均为 0，Fmax 为 71.963 MHz。
时序报告为 `impl/pnr/SD_Music_Player.tr.html`，
资源报告为 `impl/pnr/SD_Music_Player.rpt.txt`。
系统时钟 V22 沿用原工程，仍有通用时钟路由告警 PR1014；
SD 外部接口仍需通过实际播放确认。
