# 编号曲目架构

只使用PN001.BIN～PN100.BIN、MB001.BIN～MB100.BIN。
串口屏v1的CMD=0x12按乐器及编号选曲；旧CMD=0x10返回不支持，不启动SD。
保留内部编号PN=4～103、MB=104～203，避免改变现有屏幕反馈映射。

## 存储与上传

存储链为sd_spi_byte → sd_spi_reader → fixed_slot_reader/slot_card_query →
piano_score_reader → piano_score_sequencer。不再有通用FAT16/FAT32文件名搜索或旧三首回退。
slot_card_query仍校验固定布局、目录项及FAT簇链，防止在被电脑移动或修改的卡上读写错误区域；
这不等于旧文件搜索分支。乐谱支持P88S和M42S，256项FIFO预填充后按毫秒调度。

bluetooth_file_receiver直接例化在顶层，独立115200/8N1 UART，FPGA TX=D15、RX=D16。
BEGIN验证目标并使其无效，清零100 KiB后回复READY；正文经32 KiB BSRAM FIFO接收，
END校验CRC和格式后提交有效记录。手机可第二次发送“完整乐谱+END”的合并文件。
上传时顶层选择写入方SD引脚，不支持与播放同时读写。

播放器首次扫描200条有效记录并缓存，上传失效/成功脉冲更新对应位。
已知空槽点击不打断现有播放；换卡或电脑外部修改后KEY2复位刷新缓存。
描述符、元数据格式及前200槽位地址保持不变，已有PN001/PN002无需重传或重刷SD。
新初始化镜像只创建200个PN/MB文件，默认3 GiB；不自动写物理SD卡。

## 控制与音频

piano_score_player负责板级复位、串口屏协议、存储及PT8211。
instrument_system/playback_control负责曲目、试听、乐器选择、同曲不重启、停止及错误静音。
默认上电空闲；SD_SCORE_ENABLE=1时仅自动播放PN001一次，结束或失败后回空闲。
uart_note_audition分别记忆钢琴与马林巴的试听音。
选曲准入只读取目录有效表与sd_active；sd_active直连控制器已有的ringtone_active寄存器，
涵盖SD加载和播放。player_state仅用于状态反馈，不再反向决定是否接受播放请求，
避免压力忙状态经control_restart形成组合反馈；没有为此增加寄存器或放宽SDC。

顶层直接例化pressure_adc_scan，连续输出通道号/ADC值到piano_score_player。
新增input/pressure中的校准、滤波、分组选择、事件FIFO及同音高持有者合并，
默认在手动状态工作；SD播放和串口屏试听暂停压力事件。
钢琴沿用原分组和持续力度；马林巴前三组映射MIDI 36～83，其余组拒绝新按压，
但允许旧音符正常松开/衰减。切回有效组不重放无效按压。
切模式只清事件/持有者，不重做校准；返回时仍按住的键需松开再按。
钢琴LIVE_DYNAMICS在原状态RAM高位附加8位已应用力度，event_update只改目标力度，
不重启相位/ADSR，松键冻结力度保留尾音。槽位/蓝牙协议及原五张ROM不变。
旧采样率独立音源对照1152帧PCM一致，当前原生88音实时力度最大2861周期。
压力FIFO溢出锁存0x61并静音，可用停止/重选/KEY2恢复。
八路GPIO LED仅显示压力长按进度，不再承担SD/校准/播放/错误指示。
pressure_keys复用逐键计数，在8档封顶；pressure_keyboard按有效持有键合并阈值，
instrument_system统一取反输出低有效LED。所有中间LED端口已扩为8位。
原有模式互斥、松键重按及校准条件同时约束灯光；LED只是输出观察，不回流到控制。
独立静态彩灯、音高分组、CST及既有sd_active解耦修正保持不变；本轮SDC增加音频时钟。
完整接线及校准说明见PRESSURE_KEYBOARD.md。

顶层ws2812_key_guide增加16灯SD钢琴同步指引，C19/3.3 V输出。
piano_score_player只导出旁路guide_active，条件为PN曲目实际播放且未暂停/报错；
灯带读取已有video_keys门控状态，不改变事件调度或音频握手。
每2 ms锁存快照，88周期顺序扫描选最高音所在组，只显示该组全部有效键位。
六色从ws2812_static新增的常量group_palette端口取得，原静态灯序列不变；
八路长按灯与所有音频/视频源保持原行为，不增加SD文件或UART控制命令。
第6组只提示前8键；停止/休止/结束/马林巴/手动模式在下一完整LED刷新帧清灯。
详细限制、颜色冲突规则及测试见KEY_GUIDE.md。

钢琴为88音DDS/ADSR，马林巴为48音四模态及短起音噪声，经过共用output_limiter。
当前音频域由官方PLL提供150 MHz，PT8211的BCK半分频48、每帧3072周期，
原生采样率48828.125 Hz，DDS_PITCH_RATIO=64425。原五张音频表保留，
新增新采样率马林巴模态表，ADSR/衰减控制每三样本更新，保持原实际时长。
控制/压力/SD/UART仍50 MHz；官方双时钟FIFO传递事件、实际接受确认及DAC样本。
STOP刷新队列代次，PLL锁定后释放音频复位；跨域故障锁存0x63。
详见AUDIO_150MHZ.md。deadline_error仍检查逐帧计算预算。
马林巴参数现按模态重排为256×64位表，起音参数放在同一表的192～239地址；
利用原FSM预取，不增加计算周期。两种互斥音色共用sine_pair_rom的两个同步读口，
原有六张音频表内容和参数精度不变，资源估算与对照测试见ROM_SHARING.md。

公共限幅器后增加audio_effects，所有音源共用一条处理链：
selected_pcm → audio_effects共享同步RAM → 干湿混合/16位饱和 → PCM门控寄存器 → PT8211。
原声/延迟/震音/颤音互斥，延迟和颤音复用16384×16缓存，震音直接调制音量。
指针和有效长度隐藏旧内容，不复位整块RAM；颤音稳定后仅输出调制延迟信号。
效果模式/量分别由UART 0x51/0x52控制，n6/n7回显已接受设置，默认0/30。
参数逐样本平滑；普通松键和SD自然结束保留尾音，停止/新曲/切乐器清除旧效果状态，
但不改变所选效果。原声也固定增加一帧流水延迟约20.48 us。
audio_analysis_active包含效果尾音；瀑布流和长按LED仍观察原音符和按压。
效果器处理超期锁存0x62，静音，停止/KEY2恢复；与音源错误分开清除，避免故障自清组合环。
音频门控增加一个系统时钟寄存级；SD几何检查提前寄存，缩短控制信号到DAC和读卡状态机的长路径。
算法和屏幕脚本见AUDIO_EFFECTS.md；资源/时序以VERIFICATION.md及最新Gowin报告为准。

## 显示与构建

视频108 MHz像素、540 MHz串行时钟及快照跨域保持不变。
显示模式0改为实际演奏事件驱动的实时瀑布流，支持压力键盘、UART单音和SD钢琴。
instrument_system跟踪钢琴合成器实际接受的开关音符，力度更新不重新触发；
playback_video_cdc传输当前亮键及帧间活动并锁存短清屏命令，避免短按漏显及旧轨迹复活。
piano_live_roll在像素域保存180帧×88键的循环历史，每帧向下移动4像素；
按下从顶部出现，持续时长决定条长，松开后继续下落。键盘亮键跟随当前按键，不等待音块落地。
模式1/2通过audio_analysis_active分析当前钢琴或马林巴实际DAC采样，
同用一套FFT、波形缓存和显示，标题为AUDIO。马林巴只有敲击事件改变初始力度，
更新事件由音源银行消费但不送入马林巴音源；当前合成采样率调整见前述音频域说明。
马林巴忙标志覆盖pending、模态和噪声，结束后保留384帧滤波尾音窗口，约7.86 ms。
切换显示不影响音频，也不清除最近轨迹；切换音源会取消旧分析代次。
固定谱面ROM和旧渲染分支仅供历史独立仿真；piano_video通过REALTIME=1选择实时分支，
生产顶层不再例化固定乐谱瀑布流。SD文件格式、缓存和调度均不变。

board_reset保持KEY2异步断言、同步释放；保留已有关键路径寄存器及原引脚/时钟约束。
CST新增25个ADC/分组IO；SDC只为分组输入到首级同步寄存器增加例外，未放宽ADC内部时序。
本轮SDC另加audio_clk三倍频及报告，未豁免50/150 MHz内部路径。
.gprj统一列出RTL。check_project检查59个RTL、六张音频ROM、编号按钮及无冲突引脚。
run_effects/run_upload/run_analysis/run_pressure为当前集成回归；效果证据在output/audio_effects/verification.json。
压力证据见output/pressure_keyboard/verification.json。
run_key_guide覆盖动态灯、真实SD与原压力/播放显示兼容，证据在output/key_guide/verification.json。
本轮音频迁移未运行主工程综合或PnR，最后编译及150 MHz物理时序确认由用户执行，旧位流不包含此修改。
