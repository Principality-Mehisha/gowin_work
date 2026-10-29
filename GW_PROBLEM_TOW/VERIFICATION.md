# 当前工程验证记录

## 两种乐器版本（2026-10-29）

当前综合清单为35个RTL、五张音频ROM、三首SD乐谱及钢琴视频谱面。
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
