# 当前架构与模块边界

## 钢琴视频显示

板级顶层额外连接 `src/video/piano_video.v`，音频集成层输出钢琴 SD 播放有效标志、实际毫秒时间和已接收事件的 88 位亮键状态。显示通过请求/确认快照跨域，在垂直消隐期按音频时间重建落块；没有独立动画计时器。逐行掩码替代原 dvi_photo 的整幅位图，减少 BSRAM 占用。模块、同步精度、ROM 与 SD 文件一致性及视频引脚见 [钢琴视频说明](PIANO_HDMI.md)。

## 板级与系统集成

`src/board/GW_PROBLEM_TOW.v` 声明引脚，连接 `piano_score_player` 与独立视频输出子系统。
`piano_score_player.v` 保留原模块名和参数接口，负责子模块连接、三种事件来源的互斥选择、错误静音和 DAC 路由。
`board_reset.v` 保存上电计数，KEY2 异步断言复位，两级寄存器同步释放。
`GSR` 是 Gowin 原语；集成测试提供行为占位模块，不作为综合输入。

## 播放控制

`src/control/playback_control.v` 管理曲目、手动/SD 模式、同曲重复选择、停止、单音抢占和错误锁存。
输出 `play_rst_n` 清除演奏状态，`storage_rst_n` 控制整个存储链。
`ringtone_active` 为兼容现有接口保留名称，含义是任意 SD 曲目处于活动状态，包含钢琴。
`SD_SCORE_ENABLE=1` 启用兼容的上电钢琴模式；默认值 0 不影响之后按键或 UART 选播。

`uart_score_control.v` 负责固定帧接收、参数校验、反馈排队；`tjc_status_tx.v` 格式化原生屏幕命令。
`uart_note_audition.v` 分离所选音与发声音，保证 ready/valid 反压下的音符事件不丢失。
虚拟试听分别保存钢琴 0～87、马林巴 15～62、单簧管 29～73 的音名索引；后两种乐器发声时加 21 转为实际 MIDI 音高。
乐器切换请求经 `playback_control` 停止 SD、清除旧音，下一次播放按所选乐器路由。实体 KEY1 和 SD 曲目的原有音源选择独立保留。
`tjc_status_tx` 每次锁存 57 位反馈快照，依次输出六个数字字段、音名和 GB2312 乐器名。
`key_control.v` 内含按键同步与逐音试听模块，`dynamics_fixed.v` 提供固定力度 192，并作为后续力度传感器替换接口。

## 存储与调度

`src/storage/sd_score_stream.v` 封装完整的 SD 到事件链，对外只提供 SPI 引脚、曲目选择、事件握手及状态/错误输出。

1. `sd_spi_byte`：单字节 SPI 传输。
2. `sd_spi_reader`：SD 初始化、扇区读取、CRC 和超时。
3. `fat_file_reader`：FAT16/FAT32 挂载、8.3 文件定位及簇链遍历。
4. `piano_score_reader`：文件头、事件范围、时间顺序和结束记录校验，同时支持 P88S/M42S/C45S；C45S 限定实际 MIDI 50～94 和 slot=0。
5. `piano_score_sequencer`：256 项 FIFO、预填充和毫秒时间调度，通过 ready/valid 交付音符事件。

## 合成与输出

`src/audio/piano_synth.v` 为 88 个音符保存独立相位和包络，用共享数据通路分时计算分音。
`adsr_pipeline.v` 是当前使用的流水包络运算模块。
`marimba_synth.v` 计算 48 音、每音四模态和短起音噪声，经 `marimba_body_filter.v` 着色。
模态相位/幅度打包进同步 RAM，噪声幅度/LFSR 打包进另一块同步 RAM；下一模态提前读取，噪声在 NOTE_START 读取，读延迟被现有状态机周期覆盖。
复位和停止只清除有效标志，旧 RAM 数据在无效时不会进入计算。小型力度表保留现有事件写入方式。
该存储调整不改变状态机周期、合成运算、定点精度或出样时刻，验证方法见 [马林巴存储优化](MARIMBA_STORAGE.md)。
`clarinet_synth.v` 为 D3～B♭6 的 45 音单声部实时加法合成器，分时计算最多 32 个分音，使用 pp/mf/ff 三档实测参数、起音/持续频谱过渡、气息噪声和逐音响度/轻微音高起伏。频谱稳定后缓存系数，动态控制仍逐帧计算。详见 [单簧管说明](CLARINET.md)。
三种音源各自经过 `output_limiter.v`，系统选择其中一路送入 `pt8211_score_tx.v`。
两声道当前输出相同样本，属于单声道复制。

## 时钟与实时预算

所有逻辑直接使用 50 MHz 系统时钟，采样更新由 `sample_tick` 使能。
板级 BCK 半分频为 48，每帧 3072 个系统时钟；采样率为 50000000/3072 ≈ 16276.041667 Hz。
钢琴频率表按 48 kHz 生成，集成层通过 `DDS_PITCH_RATIO=193274` 换算至实际采样率。
`deadline_error` 检测合成未在下一帧前结束的情况，故障将停止或静音。

UART RX 仅将异步输入到第一级同步寄存器的路径排除时序，其余逻辑仍按 50 MHz 检查。
移动存储/控制层不改变 UART 接收层级，SDC 中的同步器定位保持有效。

## 开发入口

新增或删除 RTL 时修改 `.gprj`，仿真从相同清单读取；`tools/check_project.py` 检查源码与清单一致。
`tools/make_test_fixtures.py` 从提交的四首 BIN 生成仿真夹具，无须重新下载或转写原始音乐。
`sim/` 中报告、WAV 和编译库属于生成文件，不作为音源输入。
