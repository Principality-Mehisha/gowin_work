# 当前工程验证记录

验证日期：2026-10-23。本记录针对目录分层与模块拆分后的当前工程。

## 本次改动

- `src/` 按 board、control、storage、audio、rom 分层。
- 从系统集成中提取 `board_reset`、`playback_control`、`sd_score_stream`。
- 保留现有顶层、参数、按键、三曲播放、88 音试听和 UART 屏幕接口。
- 删除退出板级路径的 PCM/ADPCM 播放器、旧 ROM、历史快照、过时对照工具与缓存。
- 只保留当前使用的 `adsr_pipeline`；音色生成源、授权与原始设计参考资料保留。
- 仿真统一读取 `.gprj` 源码清单，测试夹具直接从三首现有 BIN 生成。

## 输入一致性

当前结构检查通过：24 个 RTL 文件与工程清单一致，五份 ROM、三首乐谱及 UART 管脚校验通过。
与重构前 Git 版本对照，钢琴/马林巴音源、琴体滤波、限幅和 PT8211 逻辑内容一致；比较文本时忽略 CRLF/LF 差异。
五份当前 ROM 内容一致，三首 BIN 及 CST/SDC 与重构前一致。
本次未重新拟合音色、转写乐谱或写入 SD 卡。

## 功能回归

| 入口 | 测试平台 | 覆盖内容 | 本次结果 |
| --- | --- | --- | --- |
| sim/run.ps1 | tb_keys、tb_limiter、tb_dac、tb_synth、tb_marimba、tb_marimba_controls | 按键、限幅、DAC、88 音钢琴、48 音马林巴、42 音实体试听 | 6 项通过 |
| sim/run_uart.ps1 | tb_tjc_status、tb_note_audition、tb_uart_protocol、tb_uart_player、tb_uart_notes | 全部音名、88 音选择、9600/8N1、错误帧、反馈、三曲与单音切换 | 5 项通过 |
| sim/run_score.ps1 | tb_score_full、tb_score_player | 3721 条完整钢琴事件、碎片 FAT32、FAT16/FAT32 板级播放、重播、CRC/格式/缺文件错误与静音 | 2 项通过 |
| sim/run_ringtone.ps1 | tb_sd_ringtone、tb_ringtone_synth | 完整安卓事件播放、SD 错误处理、切换/停止及实时音频 | 2 项通过 |

共 15 个测试平台通过。完整安卓音频 396729 个样本与独立整数模型逐点一致，峰值 PCM=5896。

`output/verification/` 保存本次测试日志、音频/时序报告及试听 WAV，`regression_summary.json` 保存汇总和日志哈希。

`run_all.ps1` 顺序调用上述四组。`sim/run_marimba_audio.ps1` 为额外的完整 42 音音频导出，不包含在默认回归；本次未运行该可选导出。
Python 工具与 PowerShell 脚本已进行语法检查，当前文档的本地链接已检查。

## 综合、布局布线与位流

Gowin EDA V1.9.12.03 (64-bit) 的综合、布局布线、位流生成与时序检查通过，构建退出码为 0。

| 项目 | 当前结果 |
| --- | --- |
| 目标时钟 | sys_clk，50.000 MHz |
| 布局 Fmax | 50.753 MHz |
| Setup / Hold 违例端点 | 0 / 0 |
| Logic | 19507 / 59904（33%） |
| Register | 21151 / 60780（35%） |
| BSRAM | 54 / 118（46%） |
| DSP | 22 / 118（19%） |

位流：`impl/pnr/GW_PROBLEM_TOW.fs`。
当前 UART 球位仍为 RX=B17、TX=B18；时序与引脚约束位置改为 `src/board/`。
`output/build_manifest.json` 保存当前工程输入及位流的 SHA256，可用于确认构建对应的源文件。
编译时原有位宽截断提示和 V22 时钟采用一般布线的 PR1014 警告仍存在，最终同步时序检查通过。

## 工具环境与边界

本机 32 位 ModelSim 在受限执行环境中出现 DLL 重定位问题，本次使用本机执行环境完成回归。
铃声独立编译缓存曾在编译启动阶段异常退出并留下锁，入口已改为复用基础测试的 `sim/work` 库。
Python 启动有安装位置提示，但检查程序退出码为 0；Tcl 构建脚本已合并标准错误输出，同时保留非零退出码检查。

没有执行真实开发板下载、串口屏烧录、示波器测量或实际扬声器试听。
历史写卡 JSON 仅作既有操作记录，不能证明当前插卡状态。
