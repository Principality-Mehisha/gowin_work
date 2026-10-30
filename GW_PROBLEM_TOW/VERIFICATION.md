# 当前工程验证记录

## 钢琴HDMI三模式版本（2026-10-29，当前）

当前综合清单为38个RTL。保留瀑布流，新增实际DAC PCM驱动的1024点Hann窗FFT频谱与512采样波形；UART命令0x50选择三种画面。系数及字体位于片上ROM，不增加SD文件。

| 实际实现资源 | 增加显示前 | 当前 |
| --- | ---: | ---: |
| BSRAM | 68/118 | 77/118 |
| Logic | 14539 | 15744 |
| Register | 10730 | 11074 |
| DSP | 22/118 | 27.5/118 |

新增9块BSRAM，剩余41块。布局布线耗时97秒；系统/像素Fmax分别为60.088/116.744 MHz，目标为50/108 MHz。系统、像素、串行三个域的数据路径setup/hold违例均为0。已有视频复位recovery/removal各4项违例及V22时钟布线警告仍保留，reset_review_required=true；不能据此宣称全部复位时序通过。

13项回归通过：FFT六类向量3072行逐字匹配；真实UART钢琴C4的512行结果逐字匹配；切换画面前后PCM及DAC串行输出相同；跨域双缓冲、消隐期换帧、快速停止/重触发、待确认状态复位、模式参数拒绝均覆盖。三种场景共432万个RGB像素与独立参考完全一致，官方PLL/CLKDIV/OSER10模型回归通过。

复现入口为sim/run_analysis.ps1、tools/build.tcl及tools/check_analysis_build.py，详情见docs/PIANO_ANALYSIS.md。证据及日志位于output/piano_analysis/verification.json；变更前源码/位流备份位于output/piano_analysis/before/。本轮未下载开发板、烧录串口屏或进行实机测试。

最终位流output/GW_PROBLEM_TOW.fs的SHA256：
`11a99e2f0c53a505296525b0c429bc049c207e13b8370ed4c496e0aa39426618`。

## 两种乐器版本（2026-10-29）

该阶段综合清单为35个RTL、五张音频ROM、三首SD乐谱及钢琴视频谱面，以下为移除单簧管时的历史记录。
单簧管音源、选音状态、中文反馈、第4曲、参数/素材/生成工具和专用DDR控制器、IP、PLL/mDRP、参数种子、DDR引脚及约束均已移除。
视频所需的PLL_INIT保留；钢琴和马林巴继续共用一个限幅器，保留独立声部和包络。

| 实际实现资源 | 移除前 | 移除后 |
| --- | ---: | ---: |
| BSRAM | 104/118 | 68/118 |
| Logic | 20241 | 14539 |
| Register | 16876 | 10730 |
| DSP | 26.5/118 | 22/118 |

实际释放36块BSRAM，剩余50块，数量比此前估算的28块更多；物理资源以最终实现报告为准。
完整构建通过；系统/像素Fmax分别为58.308/115.500 MHz，系统、像素、串行三个域的数据路径setup/hold违例均为0。
现有视频复位recovery/removal违例和V22时钟布线警告仍明确记录，reset_review_required=true，不能描述为所有复位时序均已通过。

## 回归入口及证据

运行sim/run_structure.ps1验证以下11个平台，tools/check_structure.py汇总每项日志、SHA256、网表和最终构建指纹：

- tb_instrument_bank：钢琴/马林巴共用限幅路径与原独立音源1152帧PCM逐样本相同，覆盖和弦、力度、释放和切换。
- tb_board_controls：KEY0/KEY1无功能影响，KEY2保持复位，UART发声和SD隔离。
- tb_note_audition：88/48音完整映射、循环、独立记忆、事件反压及切换。
- tb_tjc_status：176份屏幕快照、两种GB2312乐器名、数字字段、音名及反压。
- tb_uart_protocol：8时钟/位加速协议、校验/超时/队列/停止优先，选曲4被拒绝为参数错误，0x45被拒绝为不支持且状态不变。
- tb_uart_notes：真实串口收发、两种实际音源、选音与发声分离、记忆与屏幕反馈。
- tb_uart_player、tb_video_player：三首曲目的加载/选播/停止/切换/异常，以及实际播放时间和亮键状态。
- tb_sd_ringtone：完整安卓SD事件与实际马林巴音频、FAT16/FAT32、停止/复位及四类异常。
- tb_score_full：完整钢琴谱精确解码、调度与反压。
- tb_score_player：钢琴FAT16/FAT32、和弦、重复音、DAC串行帧、结束静音、异常及KEY2重启。

最终结果保存在output/no_clarinet/verification.json；构建清单为output/build_manifest.json。
当前位流为output/GW_PROBLEM_TOW.fs，和impl/pnr/GW_PROBLEM_TOW.fs一致。
旧代码、素材、报告及位流已保存于output/no_clarinet/before/，旧的DDR版交付文件已在核对备份后移除。
没有下载开发板、写物理SD卡或进行新的实板音画测试。历史三乐器版本的说明见备份sources.zip。
