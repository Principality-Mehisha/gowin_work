# 验证记录

## 最新：选中音符回传至 every.tNote（2026-10-23）

将 `selected_note` 接入 UART 状态快照并参与变化检测，返回队列从 48 位扩展到 55 位。`tjc_status_tx.v` 在原六个数字字段之后追加 `every.tNote.txt="音名"` 及三个原始 FF 字节，覆盖 A0～C8 的 88 个音名，升号为 ASCII #。每次快照锁存选择值，避免发送中途改选造成混合文字；快照前置三个 FF 清理复位残留半条指令。查询即使选择不变也会返回音名，可用于 every 页后初始化同步。

五项 UART 相关测试均通过，0 错误、0 警告。`tb_tjc_status` 用已有 88 音 CSV 的字面音名逐一比对实际输出，校对原数字字段、引号、升号、FF 边界、字节反压和快照锁存；`tb_uart_protocol` 在真实 50 MHz/115200 下独立解码七条返回指令，并保留校验、超时、队列和停止测试；`tb_note_audition`、`tb_uart_player` 保持通过。2026-10-23 04:01:58 更新后的 `tb_uart_notes` 解码模拟 TX 引脚，验证上电 A0、改选 C8/A0、正在发 A#0 时选择 B0 的显示、无变化查询刷新及 KEY2 返回 A0，并校对合成输出与原有切换控制。没有在真实串口屏上实测。

2026-10-23 04:05:12 综合、布局布线、位流及 50 MHz 时序检查通过：Fmax 50.013 MHz，Setup/Hold 违规 0/0，保留已有 PR1014 提示。原 `impl/pnr/GW_PROBLEM_TOW.fs` 已覆盖。UART 引脚仍为用户原约束 RX=B17、TX=B18；构建前 `.gprj.user` 内容已恢复。音源、ROM、读卡/播放调度均未改变，因此没有重复全长音频和 SD 回归。构建清单见 `output/uart_note_display_manifest.json`。

## 最新：三个固定按键控制 88 音试听（2026-10-23）

新增 CMD 40 上一个、41 下一个、42 播放当前音，参数均为零。FPGA 独立保存钢琴 A0～C8 的 88 音选择值，选择不发声；播放时清除旧声源，使用已有钢琴实时合成器，0.5 秒自动 note-off，再保留 1 秒尾音窗口。停止/选曲/KEY0/KEY1 可中断，KEY2 将选择复位到 A0。马林巴参数和 SD 文件未改变。本次未继续操作上位机。

2026-10-23 03:48:12 `sim/run_uart.ps1` 四项通过，0 错误、0 警告：`tb_note_audition` 验证全部 88 个索引的 on/off、两端循环、ready/valid 反压、选择与发声分离、重触发/取消/复位；`tb_uart_protocol` 验证三条新增命令的串行收发、参数拒绝及原有错误帧/队列行为；`tb_uart_player` 保留三首曲目和错误反馈回归；`tb_uart_notes` 验证 A0/C8 实际钢琴合成非零输出、自动释放和最终静音、播放中选音/重播/停止、从 SD 加载接管、KEY0 和 KEY2。

2026-10-23 03:48:45 基础七项 `sim/run.ps1` 全部通过，0 错误、0 警告。核心合成器、参数 ROM、SD 读卡/解码器未改动，不重复运行之前已通过的全长 WAV 逐点导出和全长 SD 回归。

2026-10-23 03:52:06 综合、布线、位流及自动时序检查通过：目标 50 MHz，Fmax 50.028 MHz，Setup/Hold 违规 0/0；保留既有 PR1014 时钟布线提示。位流直接覆盖 `impl/pnr/GW_PROBLEM_TOW.fs`。保留用户当前约束 RX=B17、TX=B18，并恢复本次构建前的 `.gprj.user` 内容。尚未上板实测。三条可复制指令见 `UART_THREE_KEYS.md`，构建哈希与测试清单见 `output/uart_three_keys_manifest.json`。

## 最新：淘晶驰 UART 双向选曲（2026-10-23）

新增 115200/8N1 接收、发送、固定 10 字节命令校验及原生 TJC 控件反馈。CMD 01 查询、10 选曲、11 停止；1/2/3 分别为安卓马林巴、苹果马林巴和钢琴。UART 只传控制数据，仍使用原有 SD 乐谱和实时合成器。原按键功能不变；选曲时同步复位读谱及音源，重复播放同曲幂等。

2026-10-23 02:33:46 最新 `sim/run_uart.ps1` 通过，0 错误、0 警告。协议测试使用实际 50 MHz/115200，独立采样物理 TX 并解析全部六条 ASCII 控件赋值和 FF FF FF 结束符；覆盖有效帧、校验/版本/帧尾错误、参数与未知命令、滑动重同步、半帧超时、break/短毛刺恢复、连续请求排队、帧头/帧尾字节作为序号及 255 的十进制反馈、反馈溢出时仍能停止。集成测试使用真实 SD SPI/FAT/解码/时序/合成链，短谱音高与力度取自现有三首 BIN；校对音符、力度和音源选择，覆盖 EOF、播放中切歌、加载/播放停止、同曲重复请求、缺文件/错格式错误锁存、实体按键及 KEY2。

2026-10-23 02:25:11 `sim/run.ps1` 七项回归通过：按键、限幅、DAC、钢琴、马林巴、历史 PCM 独立模块及 42 音按键循环。马林巴与钢琴合成器、参数 ROM 均未改动。

2026-10-23 02:32:39 Gowin 综合、布线、位流及 50 MHz 时序检查通过：Fmax **50.007 MHz**，Setup/Hold 违规 **0/0**。裕量很小；保留原有 PR1014 通用时钟布线提示，不宣称额外时序余量。RX 异步输入仅到第一级同步寄存器 D 端设置 false path，报告确认约束 Actived，UART 内部/音频路径正常计时。引脚报告确认 RX=Y21、TX=Y22、Bank8=3.3 V。

位流仍为 `impl/pnr/GW_PROBLEM_TOW.fs`。接线依据工程 NEO Dock rev1.4 原理图第 7、19 页，使用 J8/PMOD1 的 11/12 脚；未使用与 BL616 相连的板载 UART。屏幕端提供源码片段，未生成或下载 .HMI/.TFT，也未进行开发板烧录及屏幕实测。完整接线、屏幕工程配置和错误码见 [UART_SCREEN.md](UART_SCREEN.md)。

2026-10-23 02:34:49 `sim/run_score.ps1` 全部通过，0 错误、0 警告：3721 条 Croatian Rhapsody 事件经过碎片 FAT32 精确读取/调度，钢琴 FAT16/FAT32 的和弦、重触发、DAC、EOF/重播/CRC 失败，以及默认逐音试听和复位保持通过。构建清单见 `output/uart_build_manifest.json`。

2026-10-23 02:39:19 完整 `tb_sd_ringtone` 通过，0 错误、0 警告：现有安卓乐谱的 31 次触发、63 条事件经过 FAT16/FAT32 和实时合成链，覆盖完整播放/EOF、停止/重播/加载复位、KEY1 隔离，以及缺文件、错格式、越界音符、CRC 错误。此次不重复导出 WAV，因为合成器及 ROM 未改动；测试直接验证新控制集成后的完整事件/音频活动。

## 最新：KEY0 切换安卓三星马林巴铃声（2026-10-23）

选择 Over the Horizon（2012/S3），从公开 GT-E1270 同曲 MIDI 的 GM Marimba 通道提取时间和力度；原 32 次 note-on 中一处同刻同音高叠层合并，输出 31 次 note-on、31 次 note-off、1 条结束记录，`ANDROID.BIN` 共 520 字节，时长 24.375 秒。没有改动马林巴参数 ROM，也没有改变 KEY1 的 42 音试听范围。

H: FAT32 卡已写入 `ANDROID.BIN`、刷盘并读回 SHA256，哈希为 `c655f0c909c5d34d6d61bdc6907184be4beaa0d4d29c88dc10d28b4354741768`。原 `RINGTONE.BIN` 和 `PIANO.BIN` 哈希与写入前一致；记录见 `sd_card/ANDROID_SD_WRITE.json`。旧版备份在 `backup/before_android_ringtone/`。

`tb_sd_ringtone` 对安卓事件通过 FAT16/FAT32 的顺序/力度/EOF、加载与播放停止、重播、复位、KEY1 隔离及缺文件、错格式、越界 MIDI、CRC 错误测试。测试平台从生成的 `params.vh` 读取事件数，不再固定为苹果铃声的计数。

2026-10-23 01:28:29 完成 Gowin 综合、布局布线、位流生成和自动时序检查；Fmax 50.076 MHz，Setup/Hold 违规 0/0。原 `impl/pnr/GW_PROBLEM_TOW.fs` 已直接覆盖，KEY0 文件名为 FAT 字段 `ANDROID BIN`。本次未上板烧录或试听。

完整 396729 帧实际 RTL 输出与独立复音整数模型逐点一致，时长约 24.37503 秒，PCM 峰值 5896，无计算超期或饱和。当前试听与逐点核对报告分别为 `sim/android_ringtone_sd_realtime.wav`、`sim/android_ringtone_sd_audio_report.json`。来源和转换边界见 [ANDROID_RINGTONE.md](ANDROID_RINGTONE.md)。以下为历史记录。

## 最新：KEY0 的 SD 事件铃声（2026-10-23）

KEY0 改为从 SD 卡读取 `RINGTONE.BIN`（M42S 事件格式）并用马林巴实时合成。文件 840 字节、103 条事件，其中 note-on 51 条；约 9.355 秒含末尾尾音时间。H: FAT32 可移动卡已完成写入、刷盘和 SHA256 读回校验，原 `PIANO.BIN` 哈希不变，记录见 `sd_card/RINGTONE_SD_WRITE.json`。

当前核心支持 C2–B5 的 48 音，以容纳铃声 G5/B5；KEY1 仍为 C2–F5 的 42 音循环。原 42 音的模态/起音 ROM 与扩展前逐项相同。板级不再实例化 PCM/ADPCM 铃声播放器，旧源码仅供独立历史测试。

`tb_sd_ringtone` 通过 FAT16/FAT32 下的完整 51 音及和弦事件顺序、力度和调度检查，加载/播放停止、重播、EOF、复位、KEY1 隔离，以及缺文件、错魔数、越界 MIDI 和 CRC16 失败处理。集成测试加速了乐谱毫秒计时；完整音频测试按实际 16.276 kHz 采样节拍调度事件。

`tb_ringtone_synth` 导出 152263 个实际 RTL 采样，`tools/check_ringtone_synth.py` 与独立复音整数模型逐点一致，PCM 峰值 8111。证据为 `sim/tb_sd_ringtone.log`、`sim/tb_ringtone_synth.log`、`sim/ringtone_sd_audio_report.json`，试听为 `sim/ringtone_sd_realtime.wav`。`sim/run.ps1` 七个测试通过；48 音同时触发首帧 2496 时钟，低于 3072 时钟预算；42 音手动遍历、回绕和 KEY2 复位仍通过。

原钢琴 SD 回归也通过：完整长曲的 3721 个事件经过碎片化 FAT32 和调度器逐条核对，FAT16/FAT32 的钢琴播放、重复音、EOF、重播和 CRC 错误处理均通过。为新增可选输入补齐了测试平台的常量连线，兼容模式仍按原 P88S 格式运行。

Gowin 最终构建于 2026-10-23 01:02:06 完成：Fmax 56.776 MHz，Setup/Hold 违规 0/0，Logic 14939/59904、寄存器 18133/60780、BSRAM 21/118。原 `impl/pnr/GW_PROBLEM_TOW.fs` 已直接覆盖。保留时钟管脚 PR1014 一般布线警告。本次已写 SD 卡，未烧录 FPGA 或进行板上实测。完整操作说明见 [SD_RINGTONE.md](SD_RINGTONE.md)。

## 最新：C2–F5 的 42 音低音扩展（2026-10-22）

由项目原有 Iowa yarn mallet C2B2 的 pp/mf/ff PCM 逐音定位并拟合，新增 MIDI 36–46 共 11 音。ROM 使用连贯 mf 参数；C2–B2 的补偿保持 +3 dB，B2–C4 延续原平滑曲线。原 B2–F5 的 ROM 参数不变，噪声种子改为按 MIDI 音高计算，避免扩展后索引偏移改变已有音色。

通过结构检查、统一 `sim/run.ps1` 的七个测试，以及完整 `tb_marimba_wav` 音频导出。`tb_marimba` 覆盖 MIDI 35/78 拒绝、C2 重触发/自然衰减和全部 42 音同时触发；首帧耗时 2184 时钟，小于 3072 时钟预算。新增 `tb_marimba_controls` 覆盖 KEY1 从 C2 到 F5 的遍历及回绕、KEY2 复位回 C2、实际合成输出和默认 SD 隔离。更新了 SD 集成测试的马林巴 ROM 路径及默认音符断言，本次未重复 SD/FAT 全套回归。

Gowin 于 2026-10-22 23:32:50 完成综合、布局布线、位流与自动时序检查：Fmax 58.827 MHz，Setup/Hold 违规均为 0。资源 Logic 10793/59904、寄存器 16039/60780、BSRAM 94/118、DSP 10.5/118。位流为 `impl/pnr/GW_PROBLEM_TOW.fs`，本次未烧录开发板。保留原时钟管脚的一般布线警告 PR1014。

全部 683592 个实际 RTL 采样与独立整数模型逐点一致，其中原 B2–F5 的 504556 个采样与扩展前保持一致。全音区最大音高误差约 0.0171 音分，相邻音符加权 RMS 最大变化约 0.3679 dB，目标曲线最大误差约 0.0355 dB，单音 PCM 峰值最大 7848。

音频逐点校验、音高和响度结果见 `sim/marimba42_report.json`；最新试听见 `sim/marimba_C2_F5_realtime.wav`。扩展前快照保存在 `sim/marimba_before_low_extension/`，其余下文均为历史记录。

## 最新：低音补偿从 +4 dB 微调至 +3 dB（2026-10-22）

`tools/fit_marimba_params.py` 重新生成参数后，通过结构检查、ModelSim Intel FPGA Edition 10.5b 的 `tb_marimba` 和 `tb_marimba_wav`。新导出的全部 504556 个采样与独立整数模型一致；C4–F5 ROM/采样与调整前逐点相同，全部音符的频率字与衰减系数不变。B2 加权 RMS 从 1589.36 降至 1410.89（-1.035 dB），低音补偿仍平滑过渡至 C4 的 0 dB。

Gowin 于 2026-10-22 23:15:07 完成综合、布局布线、位流生成及自动时序检查，Fmax 77.538 MHz，Setup/Hold 违规 0/0；位流 `impl/pnr/GW_PROBLEM_TOW.fs`。本次未烧录开发板。31 音首帧 1612 时钟，低于 3072 时钟预算。未重复钢琴、SD 和 PCM 铃声的历史全套回归。

当前证据：`sim/tb_marimba_trim.log`、`sim/tb_marimba_wav_trim.log`、`sim/marimba_register_analysis/report.json`。试听 `sim/marimba_B2_F5_bass_trim.wav`。原 +4 dB 参数及试听保存在 `sim/marimba_before_bass_trim/`。高音分析见 [MARIMBA_REGISTER_ANALYSIS.md](MARIMBA_REGISTER_ANALYSIS.md)；本次未改高音合成结构或参数。

以下为历史记录，其中 `sim/marimba_corrected_report.json` 对应本次削减前的 +4 dB 版本，不能作为最新 ROM 的哈希校验报告。

验证日期：2026-10-22，修正 31 音马林巴参数反演、跨音符音量突变，并增加平滑低音增益补偿；下文保留此前钢琴和 SD 验证记录。
工具：Gowin IDE V1.9.12.03，ModelSim SE-64 2020.4，Icarus Verilog，Python/NumPy。

当前工程统一使用板载 50 MHz `sys_clk`，包含 B2–F5 的 31 音实时马林巴和独立的 KEY0 PCM 参考铃声实验。报告和可下载位流位于 `impl/pnr/`，解析摘要位于 `sim/timing_report.json`。

参数反演修复时重新运行 `tools/check_project.py`、ModelSim `tb_marimba` 和完整 `tb_marimba_wav`，均通过。31 音复音首帧需要 1612 时钟，小于 3072 时钟预算。`tools/check_marimba_audio.py` 对 504556 个 RTL 采样与独立整数模型逐点核对一致，导出音高最大误差约 0.0171 音分。低音补偿前，全音区 300 ms 加权 RMS 指标跨度约 0.0738 dB；第 13→14 音的指标跳变从 +12.107 dB 变为约 0 dB，峰值跳变从 +5.982 dB 变为 +0.598 dB。指标不是 LUFS，不代替扬声器和板上试听。

低音补偿将 B2 的加权 RMS 目标提升 4 dB，按半音位置的余弦曲线逐渐回落，到 C4 为 0 dB。源拟合、频率、衰减保持原值；C4–F5 参数和采样与补偿前逐点一致。补偿前的正确版本保存在 `sim/marimba_before_bass_boost/`；原有错误版本另保存在 `sim/marimba_before_fix/`。

补偿后再次通过完整 ModelSim 音频导出和 504556 个采样的独立整数模型核对。相邻音符加权 RMS 最大变化约 0.5024 dB，目标曲线最大误差约 0.0387 dB；第 13→14 音加权 RMS 变化约 -0.0408 dB、峰值变化约 +0.5498 dB。最新试听 `sim/marimba_B2_F5_bass_boost.wav` 保留实际 RTL 幅度，不做逐音归一化。

低音补偿后的 Gowin 综合、布局布线、位流生成及自动时序检查通过：2026-10-22 21:45:51，Fmax 77.538 MHz，setup/hold 违规均为 0。新版位流为 `impl/pnr/GW_PROBLEM_TOW.fs`，本次未烧录开发板。

修正包含实际 96 kHz AIFF 采样率解析、起音音高验证、真实基音/模态选择、输出采样率下的衰减换算，以及完整整数链的逐音增益校准。全部 12 个来源文件的 pp/mf/ff 测量单独保留，ROM 采用连贯 mf 模态，不再跨错误频带平均。可用实测模态最高频率约 5121.62 Hz；其余不可靠或越过奈奎斯特的模态关闭。详见 `assets/marimba/fit_report.json` 和 `sim/marimba_corrected_report.json`。下方完整钢琴、SD 和按键测试是此前记录，本次未重复运行整个历史回归。

## 已完成的功能验证

`sim/run.ps1` 中的五个 ModelSim 测试全部通过：

- `tb_keys`：去抖、按住不重触发、88 音循环、松开事件、停止后的按键锁定。
- `tb_synth`：A/D/S/R、A 期间松键、R 尾音与新音符重叠、88 声部、实时音高倍率和强制停止；
  额外核对全部 704 个分音在相位回绕及实时变调时的连续性。
- `tb_marimba`：31 音、四模态查表、音域边界、力度触发、one-shot 衰减、槌击瞬态和琴体滤波。
- `tb_ringtone`：142858 帧立体声 IMA ADPCM 解码逐点匹配 FFmpeg 参考，并覆盖停止、重播、EOF 和复位。
- `tb_limiter`：正负数四舍五入、正常主增益、过载限制和 16 位输出边界；
  包括正负 10518750 的保守最大混合输入。
- `tb_dac`：每帧 3200 时钟、16 位 LSBJ、左右声道一致和整帧静音。

原版四个行为测试均通过 Icarus；本次改变的合成核已再次通过 Icarus 交叉检查。
本次 ModelSim 证据波形已重新生成并保存为 `sim/realtime_evidence.wlf`。

板级播放器集成测试直接使用 50 MHz 时钟，并检查实际 DAC 帧输出和按键操作。

## 连续音频与数学核对

`tb_demo` 使用默认包络和实际 3200 周期帧间隔，生成 126010 帧，约 2.625 秒：
A4 按住/松开、A 大三和弦、C8、88 键同时发声、强制停止。
结果见 `sim/tb_demo.log` 和 `sim/audio_report.json`：

| 项目 | 实测 |
| --- | --- |
| 最大活跃声部数 | 88 |
| PCM 绝对峰值 | 30000 |
| 限制器起作用帧数 | 11977 |
| 末端硬饱和或采样超期 | 未发生 |
| A4 前 24000 样本与含击弦亮度包络的独立模型最大差值 | 0 |
| C8 第 6/7/8 谐波折叠位置相对基频 | -109.15 / -94.52 / -103.56 dB |

频谱值为加窗单频测量，不是模拟 DAC 的失真指标，也不是完整混叠频谱的全带宽噪底。
八个 A4 谐波与三和弦三个音高均通过检出检查。

生成的 `sim/realtime_synth_demo.wav` 为左右相同、48 kHz、16 位的仿真试听结果，
不被 FPGA 工程读取。完整逐样本检查模型位于 `tools/analyze_audio.py`。

## 低音 A/B 验证

`sim/bass.ps1` 同时运行增强音色及 `BASS_VOICING=0` 原版音色，生成 216000 对样本。
A0、A1、A2、A4 每键保持 0.75 秒并释放 0.375 秒。
核心测试省略两帧运算之间的空闲时钟；真实采样节拍由前述 `tb_demo`、`tb_dac` 检查。

两版的每一个样本均与 `tools/piano_reference.py` 独立定点模型一致。
该模型直接由时间索引计算各分音相位，不复用 RTL 的分时状态机或相位 RAM。
报告为 `sim/bass_report.json`；下表统计 50～500 ms 窗口，不做单音归一化：

| 音符 | 原版数字 RMS | 改进数字 RMS | 数字 RMS 变化 |
| --- | --- | --- | --- |
| A0 | 975.42 | 4479.23 | +13.240 dB |
| A1 | 1002.63 | 3239.20 | +10.186 dB |
| A2 | 991.35 | 1897.90 | +5.641 dB |
| A4 | 991.44 | 991.44 | 0 dB，50～500 ms保持段不变 |

所有 88 键基频的 DDS 量化误差小于 0.000246 音分。
A0 第一分音约 27.499996 Hz，第 8 分音约 220.214009 Hz；
第 8 分音的轻微偏移来自弦刚度近似，第一分音及标准键序没有变化。
新增的起音亮度包络仅抬高第 4～8 分音，按键触发时置满并每采样减 128，
512 帧（约 10.67 ms）后完全归零；A4此前 512 帧允许出现瞬态，之后与关闭该支路的输出逐样本相同。
该模块可由 `HAMMER_TRANSIENT=0` 关闭，不新增时分谐波计算周期。
`sine256.hex` 与 `frequency88.hex` 的 SHA256 均与优化前相同。

`sim/bass_before.wav` 与 `sim/bass_after.wav` 采用完全相同的固定数字输出增益，
顺序为 A0、A1、A2、A4。它们是仿真输出，不是 FPGA 的输入音频。
数字 RMS 不是扬声器声压，也不能替代实际听感校准。

## 实现状态

2026-10-22 PCM 反演马林巴加入琴体滤波和短起音噪声后，Gowin 综合、布局布线、时序检查及位流生成均已通过。当前顶层时序报告：

| 项目 | 结果 |
| --- | --- |
| 当前顶层时钟约束 | 50.000 MHz `sys_clk` |
| 布局 Fmax | 68.179 MHz |
| Setup / Hold 违例端点 | 0 / 0 |
| Logic | 7244 / 59904（13%） |
| 寄存器 | 6823 / 60780（12%） |
| BSRAM | 45 / 118（39%） |
| DSP | 22 / 118（19%） |

KEY0 切换钢琴和马林巴；两套模型独立跟踪事件状态。

本次位流为 `impl/pnr/GW_PROBLEM_TOW.fs`。`tools/build.tcl` 在生成后运行
`tools/check_timing.py` 检查 Setup/Hold 违例与目标频率；最终以同一轮生成的报告、位流和脚本退出状态为准。
旧位流不会因为文件存在就单独作为通过依据。

声部状态存储已使用同步 RAM，波表读出、插值、加权、包络和输出限制分别流水处理。
停止播放时清除状态有效标记，不给整块 RAM 增加异步复位；RAM 中旧内容会被忽略，
下一次触发从新相位和 Attack 开始。
完整音频测试与最终状态存储、流水线的功能保持逐点核对。

钢琴独立合成器回归测得最大出样延迟为 2861 周期；马林巴 12 音、四模态、起音噪声和琴体滤波测试的最大出样延迟为 624 周期；PCM 播放器按一个 DAC 帧读取一个已解码立体声样本。当前配置下，PT8211 的帧周期为 3072 个 50 MHz 时钟，实时合成未触发 `deadline_error`。
本次选择用更多状态 RAM 保存非谐性分音的连续相位，并用寄存器拆分运算路径；
资源增加但仍在器件容量内，不能把它描述为所有资源都比原版更少。
原版快照保留在 `backup/before_bass_voicing_20261018`，不加入 Gowin 工程源文件列表。

工具保留一条 `PR1014`：V22 输入时钟使用一般布线资源，可能增加延迟或偏斜。
这是当前板卡固定时钟管脚的实现警告；没有改动板卡引脚，也没有把音频运算路径设为假路径。
异步按键输入以及复位同步器的异步清除端被排除出同步时序检查，
复位释放由 50 MHz 系统时钟域的两级寄存器完成。最终同步路径仍要求正常满足时序。
没有连接实际板卡，尚未执行下载、示波器测量或音响试听。
