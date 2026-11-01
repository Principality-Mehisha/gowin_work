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

钢琴为88音DDS/ADSR，马林巴为48音四模态及短起音噪声，经过共用output_limiter。
五张音频ROM及合成运算不改。PT8211双声道输出相同16位PCM，
50 MHz、BCK半分频48、每帧3072周期，采样率约16276.041667 Hz。
DDS_PITCH_RATIO=193274及deadline_error检查保留。

## 显示与构建

视频108 MHz像素、540 MHz串行时钟及快照跨域保持不变。
解除旧第3首与固定谱面ROM绑定，编号曲目不会显示旧谱面的落块或亮键；
显示模式0保留键盘背景，模式1/2继续分析钢琴实际DAC采样，不采集马林巴。
固定谱面ROM和通用渲染模块仍保留在工程中，独立仿真可激活；当前播放器不再激活旧谱面。
它们不是当前SD曲目或上传依赖，本次没有继续删除视频渲染模块。

board_reset保持KEY2异步断言、同步释放；CST/SDC及已有关键路径寄存器保留。
.gprj统一列出RTL。check_project检查42个RTL、五张音频ROM、编号按钮与引脚。
run_upload/run_analysis为当前集成回归，证据见output/numbered_only与VERIFICATION.md。
