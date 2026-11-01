# 当前工程验证记录

## 仅PN/MB编号曲目（2026-11-01）

当前42个RTL。删除旧三首CMD=0x10、文件名映射、通用fat_file_reader和FAT回退分支，
移除旧自动播放及旧第3首显示绑定。只允许PN001～PN100、MB001～MB100。
初始化工具只建立这200个占位文件，默认3 GiB；未重新生成永久大型镜像，未操作物理SD、COM口或开发板。
原始曲目文件仅保留为离线样本；固定视频ROM和渲染模块仍在工程中，但不再绑定旧第3首或编号曲目。
它们不是当前SD文件查找或初始化依赖，本次没有继续删除视频渲染模块。

保留屏幕CMD=0x12及内部编号4～203，蓝牙v2协议、槽位描述符、100 KiB数据区及有效记录不变。
与改写前源码进行纯内存对比：3 GiB和30000 MiB布局中，200槽地址、目录项、双FAT簇链及描述符完全一致；
FSInfo空闲计数/提示因不再分配旧三首而相应更新。现有卡和已上传PN001/PN002无需重刷或重传。
对比结果在`output/numbered_only/card_compatibility.log`。
默认上电空闲；可选SD_SCORE_ENABLE=1改为PN001单次启动播放。
修正首次扫描前由单音试听进入编号曲目的准入条件，保留已知空槽不打断当前播放的行为。

已通过11项Python测试和28个不同RTL平台：11个上传/播放、13个显示/分析（其中3个重复），
另有4个音频基础和3个控制/等价平台。包含旧命令拒绝、200文件名映射、PN/MB真实合成、
完整PN002的3721个精确事件、CRC/格式错误恢复、100 KiB上传、溢出、复位、清零后READY、
单音抢占/恢复、共享音源逐样本等价、官方视频原语及三个1600×900场景逐像素对照。
编号曲目不输出旧固定瀑布流；钢琴频谱/波形保持工作，马林巴不会误入钢琴分析。

五张音频ROM、系统/视频时钟、CST/SDC及已有关键路径寄存器未改。
完整综合/布局布线通过，当前位流与输入指纹由`output/build_manifest.json`锁定。
系统/像素Fmax为55.224/111.410 MHz，目标仍为50/108 MHz；三个时钟域setup/hold数据路径违例均为0。
原有视频异步复位recovery/removal及V22 PR1014告警保留，reset_review_required=true，
不能描述为全部复位时序通过，也没有为本次删除添加时序豁免。

| 物理资源 | 修改前 | 仅编号曲目 |
| --- | ---: | ---: |
| Logic | 25167 | 21097 |
| Register | 14686 | 13213 |
| CLS | 18534 | 15886 |
| BSRAM / 118 | 94 | 93 |
| DSP | 27.5 | 27.5 |
| pROM / pROMX9 | 24 / 14 | 24 / 14 |

逻辑下降约16.2%，寄存器下降约10.0%；五张音频ROM逐文件哈希与修改前相同。
32 KiB上传FIFO仍为16块SDPB。pROM数量本次没有下降，不把资源变化归因于删除全部视频ROM。
本次归档报告的综合/PnR为3分6秒/3分59秒，总7分5秒；修改前归档报告为2分12秒/4分42秒，总6分54秒。
PnR缩短但本次总耗时未缩短；机器负载未受控，不将这一次测量解释为确定的性能提升。
对比与结构断言见`output/numbered_only/resources.json`。

交付`output/GW_PROBLEM_TOW.fs`与`impl/pnr/GW_PROBLEM_TOW.fs`指纹一致：
`944e104626086b422f50016dbf0301c84c59c36e945f42691cec93cd3ccecf00`。
`python -B tools/check_upload.py --require-build`和
`python -B tools/check_analysis_build.py --baseline output/numbered_only/before/GW_PROBLEM_TOW.rpt.txt`均通过。
构建前源码快照在`output/numbered_only/source_frozen.json`，原始源码与位流备份在`output/numbered_only/before/`。
当前回归证据在`output/numbered_only/verification.json`；本次代码尚未重新上板验证。

## 固定槽位连续上传（2026-10-31，历史）

当前清单为43个RTL。移除动态FAT文件写入器，使用200个预分配的100 KiB文件。
BEGIN通过布局/目录/双FAT检查后，使旧记录无效并清零整个目标文件，READY后接收连续原始字节。
DATA阶段没有分包、块序号或逐块ACK；32 KiB FIFO已在综合网表中映射为16个SDPB。
END检查实际长度、整文件CRC32和乐谱格式，写完独立有效记录后才回复成功。
原五张音频ROM、视频谱面、两种音源、三首旧曲和串口屏播放接口保留。

11个上传/播放RTL平台和11项Python测试通过；另有13个音频/显示平台通过，
包括官方PLL/CLKDIV/OSER10模型。三幅1600×900画面逐像素匹配独立参考，
真实UART钢琴PCM的512行频谱/波形结果逐字匹配。
覆盖100 KiB连续流、SD停顿、32 KiB缓存、强制溢出、短末块、原始字节内同步字、
同名覆盖、先清零后READY、复位/超时、CRC/格式错误、写卡三类故障、
双FAT遍历、邻槽保护、目录/簇链移动拒绝、冷启动有效表和空编号不打断当前曲目。

首轮实现的综合为3分22秒、PnR为8分22秒，逻辑24925、寄存器14659、BSRAM94；
但系统/像素Fmax仅46.674/100.655 MHz，未通过时序，**不是交付版本**。
报告保存在`output/fixed_slots/first_build/`。随后在串口指令译码和视频行启动处各增加一级寄存器，
同时保持反馈快照与实际控制动作对齐；未降低时钟目标、未新增时序豁免。
最终实现及位流指纹以`output/fixed_slots/verification.json`和`output/build_manifest.json`为准，
必须通过`python -B tools/check_upload.py --require-build`，不能使用首轮未通过的实现。

最终数据时序通过：系统/像素Fmax为52.969/120.355 MHz，目标50/108 MHz；
系统、像素和串行域的setup/hold数据路径违例均为0。
原有视频异步复位recovery/removal违例及V22通用时钟布线PR1014告警仍保留，
`reset_review_required=true`，不能描述为全部复位时序均通过。

| 最终资源 | 改写前 | 固定槽位 |
| --- | ---: | ---: |
| Logic | 34894 | 25167 |
| Register | 18919 | 14686 |
| CLS | 23235 | 18534 |
| BSRAM / 118 | 81 | 94 |
| DSP / 118 | 28.5 | 27.5 |
| 蓝牙链路LUT | 16198 | 4809 |
| 蓝牙链路寄存器 | 7104 | 2049 |
| pROM / pROMX9 | 24 / 14 | 24 / 14 |

逻辑减少约28%，蓝牙链路LUT减少约70%。32 KiB FIFO使用16块SDPB，
整体剩余24块BSRAM，旧扇区缓存的4096个RAMREG触发器展开已消失。
最终本次综合8分10秒、PnR13分37秒，合计21分47秒；
基线为3分46秒、15分47秒，合计19分33秒。**本次总编译耗时没有缩短**，
不能把首轮未通过时序的较快结果当成交付成绩。
构建期间并行运行过ModelSim，两轮未控制为相同负载；耗时不是受控A/B测试，资源下降与数据时序通过则已由报告确认。
原始前后报告保存在`output/fixed_slots/before/`与`output/fixed_slots/after/`，
结构检查和对比数据在`output/fixed_slots/resources.json`。

交付位流`output/GW_PROBLEM_TOW.fs`与`impl/pnr/GW_PROBLEM_TOW.fs`指纹一致：
`f0a93bebec7a1fcd25ffa1225a86586e4ef28b362a8cc670ec3230ae81ef7e9c`。
显示回归证据在`output/piano_analysis/verification.json`，使用本轮改写前报告作为显式基线：
`python -B tools/check_analysis_build.py --baseline output/fixed_slots/before/GW_PROBLEM_TOW.rpt.txt`。
`sim/run_upload.ps1`通过后会自动更新构建前源码快照，后续正常修改也应先完成回归再构建。

新的FAT32稀疏镜像位于`output/fixed_slots/slots_30000m.img`，逻辑长度31457280000字节。
200个电脑可见文件各100 KiB，32 KiB簇下每个实际分配128 KiB；有效长度与CRC另存。
生成工具只操作普通镜像文件，拒绝物理设备路径。未写入物理SD、未打开COM口、未下载开发板。
将该镜像整盘写卡会替换卡上原分区和文件，必须先备份并核对目标卡容量和盘号。
初始化、协议v2及失败边界见`docs/BLUETOOTH_UPLOAD.md`。

## 蓝牙动态FAT上传（2026-10-30，历史）

该阶段清单为41个RTL。新增顶层独立蓝牙上传、FAT16/FAT32文件创建/替换，
以及串口屏PN001～PN100、MB001～MB100编号播放。TX=D15、RX=D16，115200/8N1。
原三首、单音试听、音频及显示接口保留；不实现同时读写SD的调度。

`sim/run_upload.ps1` 的11个RTL平台和6项Python发送端测试通过：
200个文件名映射、64 KiB上传、FAT16/SDSC与FAT32/SDHC、活动FAT及镜像、
碎片簇链、根目录扩展、8扇区簇、短末块、SD模型存储逐字节核对、重复包/错误CRC、
取消/超时回收、格式拒绝、写响应拒绝/写忙超时/卡状态失败、
磁盘满/FAT16根目录满、真实串口屏选曲和空编号槽位均有覆盖。
另回归原串口协议、板级按键、三首曲目、两种真实音源试听及完整钢琴谱解码。
未连接物理蓝牙、写物理SD卡、烧录串口屏或下载开发板。

2026-10-31复核：最终综合、布局布线和数据时序检查通过，
`output/upload_test/verification.json` 的 `build_matches_sources=true`，
交付位流与 `impl/pnr/GW_PROBLEM_TOW.fs` 逐字节指纹一致。

| 最终实际实现资源 | 使用量 |
| --- | ---: |
| Logic | 34894/59904 |
| Register | 18919/60780 |
| BSRAM | 81/118 |
| DSP | 28.5/118 |
| CLS | 23235/29952 |

较三模式显示版本增加4块BSRAM，剩余37块。本轮备份PnR报告耗时15分47秒，不含综合。
系统/像素Fmax分别为50.449/108.832 MHz，达到50/108 MHz目标，但时序余量较小。
系统、像素和串行域的数据路径setup/hold违例均为0。
视频复位recovery违例仍存在，`reset_review_required=true`；
V22通用时钟布线PR1014告警仍保留，不能称为全部复位时序通过。
完整时序与输入指纹见 `output/build_manifest.json`。

当时交付位流的SHA256：
`0ead34ccf79f7e2f9687490d6cb59b536c2f0ab7e1a2135b090dd9289f109a43`。

复现：`python -B tools/check_project.py`、`sim/run_upload.ps1`、
`tools/build.tcl`、`python -B tools/check_upload.py --require-build`。
协议、PC工具、200个按钮脚本及断电边界见 `docs/BLUETOOTH_UPLOAD.md`。
新编号钢琴曲目支持频谱/波形，不使用旧第3首的固定瀑布流谱面。

## 钢琴HDMI三模式版本（2026-10-29，历史）

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
