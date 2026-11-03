# 当前工程验证记录

## 时序修正第一轮（2026-11-03，当前源码，未综合/PnR）

基于用户16:45报告的106/118块BSRAM版本，保持50/150/108/540 MHz目标及48828.125 Hz采样率。
效果器控制/乘法/地址/饱和分拍，内部最大16周期，不多加DAC整帧；
旧速率251045样本、原生244491样本及两速率48000个冻结参考样本均相同。
音符先寄存类型/代次判断，再握手音源，配置不能越过暂存事件，ACK仍对应实际接收。
FIFO功能读寄存器改为本地同步释放复位，四组官方Gray首级输入受6 ns最大延迟约束，
仅首级Hold取消；九组释放链的35个CLEAR例外不涵盖下游功能复位或OSER10 RESET。
官方CLKDIV /5实测为60%占空比，PCLK约束更正为-edges {1 7 11}，仍108 MHz。
视频串行器采用既有FCLK下降沿的三级复位同步器，仅三个寄存器使用540 MHz；
CST为DCE分出的serializer_clk新增BUFG=CLK支路约束，原IO HCLK和引脚不变，
相关路由与时序需由新报告确认。

八项专项、官方PLL/FIFO、正常突发/背压/重启/溢出/1 ns失锁恢复通过，
三次视频复锁及1500个完整三路TMDS字无丢失/重复/撕裂，并验证PCLK实际高/低电平时间。
真实顶层（VIDEO_ENABLE=0）ADC压力、PN/MB、UART、9434个双声道DAC帧、10131个返回包，
1024个实际采样的FFT及两幅各144万像素独立渲染参考通过；官方视频链路另行验证。
SDC通过安全Tcl语法/范围审计，不等于实际EDA集合匹配或物理时序通过。

新增系统域和跨域专属报告及模块Fmax，防止系统域路径被全局音频路径挤出报告。
check_timing.py严格要求全局及各域数据/复位无违例，不再对历史视频复位端点放行。
本轮没有编译主工程、更新位流或操作硬件，是否收敛仍待用户新PnR报告；
未曝光的50 MHz系统域详细瓶颈将据新报告继续处理，不盲目添加例外。
备份含用户位流，位于output/timing150/before；证据为output/timing150/verification.json。
入口sim/run_timing150.ps1 -Full，说明docs/TIMING_150MHZ.md。

## 参数ROM和正弦表复用（2026-11-03，上一版源码）

用户16:45报告已确认BSRAM从118降至106块，符合预估；该版本仍有时序违例，
以下是当时修改及仿真记录，不是当前时序修正版的综合结果。

修改前源码、报告和三份冻结对照模块在output/rom_sharing/before。
只修改三个音源/银行模块并新增sine_pair_rom，工程清单由58增至59个RTL输入。
原有六张音频ROM、其余RTL、顶层接口、CST/SDC、SD/蓝牙/屏幕及灯光保持不变。

马林巴改为256×64位单同步读口参数表，0～191为完整模态，
192～239为起音，240～255为零；初始化临时数组不用于运行时访问。
利用原FSM预取下一模态和起音，不增加状态或合成计算周期。
银行内两种互斥音源共享两个同步正弦读口，独立音源仿真仍可使用私有表。

sim/run_rom_sharing.ps1覆盖四个测试：
两种采样率各2704个样本及握手/忙/限幅信号与冻结旧源码逐周期相同，
每种速率240条参数逐字相同，正弦表4096次相邻/回卷/保持检查。
包含88音/48音、全部音高、持续力度、重敲、自然松键、计算中换音色和复位；
独立马林巴及1152帧共享银行回归通过。
最坏钢琴2861周期、马林巴2515周期，仍小于3072周期。
另重跑tb_audio150_core，10240个原生PCM样本、4096个独立马林巴定点参考样本通过，
A4测得440.00 Hz，C8二次分音8372 Hz保留。完整工程源码已通过ModelSim编译检查。
结果见output/rom_sharing/verification.json和native_pcm.log。

修改前PnR为118/118，按结构估算本轮可减少约12块至106/118，
不代表已获得新资源报告。本轮没有主工程综合/PnR、更新位流或上板，
原用户位流指纹保持不变。最终编译仍由用户执行。
用户12:58报告中音频Fmax=67.860 MHz、音频域1869个Setup违例以及跨域/复位违例，
并未在本轮处理，不能宣称150 MHz物理时序通过。
参数组织、预估依据及重跑入口见docs/ROM_SHARING.md。

## 150 MHz原生音频域（2026-11-03，上一版源码）

用户随后完成主工程编译并反馈上板功能正常；其12:58报告仍存在150 MHz时序违例，
该事实覆盖下述迁移时的“未编译”状态，也不等于当前ROM优化已经编译。

仅音频合成、限幅、效果及PT8211改为官方PLL的150 MHz；控制、压力ADC、SD、UART、
蓝牙、长按灯、指引灯及FFT分析仍50 MHz，视频108/540 MHz不变。
官方32位×16双时钟FIFO传递有序配置/事件及实际接受确认、DAC样本；
停止清队列代次，失锁/溢出锁存0x63，不直接逐位同步多位PCM。
当前.gprj为58个RTL输入，原五张音频ROM保持不变，新增48828.125 Hz马林巴模态表。

原生采样率150000000/3072=48828.125 Hz，不重复旧样本、不把升采样当作原生合成。
相位、噪声及混音逐样本更新，包络/衰减/力度渐变每三帧更新，保持真实时间尺度。
琴体滤波重新计算，马林巴清尾384帧仍约7.86 ms；效果约300 ms延迟14648样本，
四秒尾音195312样本，共享RAM32 KiB，固定一帧效果流水20.48 us。
1024点FFT频率间隔47.684 Hz，覆盖约24.4 kHz，波形512样本约10.486 ms。

专项入口sim/run_audio150.ps1，日志与输入审计在output/audio150/verification.json：

- 官方PLL启动/复位/重锁及FIFO576字的异相时钟、背压、回卷、复位。
- 88音钢琴/48音马林巴，最坏合成2861周期小于3072周期；不是150 MHz物理时序证明。
- 10240个原生PCM样本，马林巴4096样本逐字匹配独立定点参考；
  A4测得440.00 Hz，C8二次分音8372 Hz可见，高于旧采样率8.138 kHz奈奎斯特频率。
- 244491个原生效果样本，验证回声实际长度、反馈和四秒尾音、5 Hz震音及全湿颤音。
- 有序事件确认、正常突发不溢出、STOP取消旧队列、强制溢出和短至1 ns失锁恢复。
- 真实顶层ADC、16键压力、PN/MB SD播放、UART、双声道DAC串行解码、
  返回数据逐包一致，以及1024个实际DAC样本的512行FFT和两幅各144万像素。

原生迁移前源码备份为output/audio150/before/sources.zip。
物理引脚、压力/控制/存储/蓝牙、原静态/动态灯、实时瀑布流及原五张音频表与备份审计；
采样率相关合成器、桥接、系统集成、画面坐标及SDC的改动明确单列。
SD/BIN/屏幕协议不变，已有曲目无需重新上传。

兼容验证另通过压力9项、控制/存储6项、效果5项、马林巴5项及分析4项。
指引灯专项及集成、板级控制本轮重新运行通过；其余压力/UART/视频兼容项复用本轮
output/pressure_keyboard与output/no_clarinet中的同源通过日志，来源记录在
output/key_guide/verification.json的reused_compatible_logs。
重复的指引灯脚本在压力项被主动终止，不能把output/audio150/guide_compatibility.log
结尾的中止异常当成功能失败或宣称该脚本整轮跑完；汇总由tools/check_key_guide.py重新核验。
保留的中止日志为output/audio150/guide_duplicate_interrupted.log。

本轮只生成官方IP组件并运行ModelSim/Python检查，未运行主工程综合/PnR、更新位流或操作硬件。
官方IP生成文件中的Gowin Synthesis标识不代表编译了GW_PROBLEM_TOW主工程。
最终编译由用户执行，必须检查audio_clk实际150 MHz、各域setup/hold和新增音频复位时序；
旧位流及以下历史Fmax/资源报告均不能证明当前150 MHz版本可上板。
架构、重生成入口及资源变化见docs/AUDIO_150MHZ.md。

## 16灯SD钢琴指引（2026-11-02，历史源码，未综合/PnR）

新增ws2812_key_guide及C19/LVCMOS33/3.3 V约束，链路16颗灯依次对应16个物理键。
最高门控音所在组优先，只显示该组全部有效音符；六色取自静态灯前六个RGB参数。
同组和弦同时点亮，跨组同键覆盖后可在最高音释放时恢复原低组指引，第6组只用前8灯。
其他音符照常播放，不修改BIN、上传协议、音源算法、已有SD/音频时序或分组开关映射。
PN实际播放时自动启用；马林巴、压力手动、UART试听、上传、休止及停止/结束后发全黑。
不检测按键对错、不等待跟弹、不提前显示音符；SD播放期间原压力输入暂停行为保持不变。

ws2812_static只增加六色常量输出端口，原七颗静态灯发送逻辑逐行核对不变。
动态驱动独立锁存门控快照，用88个时钟顺序扫描；每整帧选组、颜色与掩码固定。
默认50 MHz、63周期/位、15/45周期高电平，至少15000周期复位低电平；
384位数据约0.484 ms，快照周期2 ms。灯珠锁存更新预算约2.8 ms，不是演奏音频延迟。
极短且完全落在快照间隔内的音符可能不显示；KEY2释放后发送全黑，不声称复位拉低数据线即能清色。

sim/run_key_guide.ps1六项仿真全部通过：

- tb_key_guide：加速参数遍历88音及随机组合，默认参数验证真实50 MHz脉宽、位周期及2 ms帧周期；
  覆盖六色、同组和弦、跨组同键优先/回落、C8边界、禁用/空闲、发送中更新及复位。
  独立线级解码同时确认原七颗静态灯颜色，两个参数配置共275帧检查通过。
- tb_key_guide_integration：真实顶层、UART和稀疏SD卡，76帧完整384位灯数据匹配参考，
  验证第2组第7键绿、同组和弦、第4组同键黄、低组回落、C8、休止/曲终/停止/切马林巴/试听/格式错误/KEY2。
  与未接灯带驱动的独立播放器逐周期比较PCM、实际DAC引脚、UART及SD输出，完全一致。
- tb_board_controls、tb_pressure_integration、tb_uart_player、tb_video_player：
  原板级复位、压力16键/力度/长按灯、编号播放与错误、瀑布流和共享分析隔离回归通过。

另通过sim/run_effects.ps1五项当前震音/颤音/延迟兼容回归，251,045个样本与定点参考一致。
共11项仿真配置；未将这些功能测试表述为新的物理时序或零告警证明。
tools/check_project检查52个RTL、原ROM与全部引脚，C19无冲突；
tools/check_key_guide逐字节确认本轮未改音频、压力、存储、蓝牙、瀑布流及SDC，
并确认CST仅增加动态灯两行。输入/日志指纹在output/key_guide/verification.json。

源码及原有报告备份在output/key_guide/before，不复制大型镜像或位流。
没有运行Gowin综合/PnR、更新位流、打开物理串口、写卡或烧录。
以下历史构建报告不代表新增动态灯版本；最终资源、50/108/540 MHz时序和实灯电气/顺序由用户确认。
操作与接线见docs/KEY_GUIDE.md。

## 震音/颤音替换（2026-11-02，指引灯加入前构建记录）

模式2替换为震音（约5 Hz音量调制），模式3替换为颤音（约5 Hz音高调制）。
原声/延迟继续使用模式0/1，UART模式编号、效果量0～100和屏幕n6/n7反馈不变。
颤音经256样本淡入后只输出调制信号，效果量控制音高摆幅；效果量0平滑恢复逐样本原声直通。
震音不产生尾音，颤音仅保留114样本短缓存尾音；停止/切音色/复位清除旧声音。

`sim/run_effects.ps1`五项回归全部通过，251,045个样本与Python定点参考逐字一致。
覆盖全部硬件输入效果量0～127、全部模式互切、正负满幅、清除/复位、尾音超时和超期检测，
并通过真实UART/压力输入、演奏中切换、效果量归零、马林巴、SD自然结束、双声道DAC串行解码。
为达到50 MHz时序，音频门控增加一个系统时钟寄存级（20 ns），SD几何检查提前寄存。
补充固定槽读取回归，覆盖FAT大小为0/1的无效几何拒绝、正常32/102400字节读取、目录扫描及CRC。
效果FSM实测最多8个系统时钟。

`tools/build.tcl`完成综合和布局布线，系统/像素Fmax为50.450/128.964 MHz，
目标50/108 MHz，系统、像素、串行域的数据路径setup/hold违例均为0。
Logic 23712/59904、Register 14002/60780、BSRAM 104/118、DSP 27.5/118。
视频异步复位仍有4条recovery及4条removal负路径，reset_review_required=true；
未放宽SDC约束，也不能宣称全部时序通过。详情见`sim/timing_report.json`。
`verification.json`中的synthesis_run/pnr_run=false仅描述仿真检查器范围，
实际构建证据为`output/build_manifest.json`；已核对65项构建输入和78项仿真输入指纹。

新下载文件为`output/GW_PROBLEM_TOW_tremolo_vibrato.fs`，与
`output/GW_PROBLEM_TOW.fs`和`impl/pnr/GW_PROBLEM_TOW.fs`逐字节相同。
SHA256：`db87590ebf00440ca8550270ed18fe81c3f4f75dc3549aabfb2d051f9aa488d3`。
本次构建日志为`output/audio_effects/build_pipelined.log`。

独立听感指标：效果量30/100时震音最低音量为71.206%/2.725%，最高均为100%。
效果量100的440 Hz颤音测试，周期频率423.062～456.932 Hz，周期峰值15912～16000，
稳定干湿权重为256/256，确认音高变化且幅度接近恒定。
证据见`output/audio_effects/verification.json`和`reference.json`，音频示例为
`tremolo_rtl.wav`/`vibrato_rtl.wav`，均为数字仿真，不是实板录音。

主机命令改为EffectTremolo/EffectVibrato，旧EffectReverb/EffectChorus保留模式编号兼容别名。
屏幕事件脚本新增effect_tremolo_release.txt/effect_vibrato_release.txt，旧模式2/3的帧仍可使用，
实际HMI中的“混响/合唱”按钮文字需改为“震音/颤音”，字库需包含新文字。
本轮未提供或修改实际.HMI/.TFT，也未下载开发板。
上一版源码和位流备份在`output/modulation_effects_before/`。

## 混响响度补偿（2026-11-02，上一版记录）

混响末级全通输出增加4倍（约12 dB）湿声补偿，使用32位有符号移位后饱和到16位。
补偿不写回反馈缓存，保留原有反馈系数、衰减时间、干湿比例及模式淡入淡出。
原声、延迟和合唱算法保持原设置。

`sim/run_effects.ps1`四项回归全部通过：300,450个音频样本与Python定点参考逐字一致，
覆盖默认/最大效果量的尾音增益、正负满幅持续输入、和弦、零效果量直通、
模式切换、清除、尾音过期，以及UART/屏幕反馈/压力演奏/实际DAC串行输出。
幅度16000的单脉冲，效果量30/100的第一处反射从36/122提高为144/488；
前约0.74秒尾音能量分别增加12.010/12.042 dB。
日志、参考/RTL WAV与输入指纹见`output/audio_effects/verification.json`；
该JSON中的synthesis_run/pnr_run=false仅描述仿真检查器的范围，本轮实际构建证据另存于`output/build_manifest.json`。

`tools/build.tcl`完成综合和布局布线，系统/像素Fmax为50.343/115.327 MHz，
目标50/108 MHz，系统、像素、串行域的数据路径setup/hold违例均为0。
Logic 23957/59904、Register 14236/60780、BSRAM 104/118、DSP 27.5/118。
视频复位仍有12条负recovery路径（部分端点同时记录上升沿/下降沿检查），
reset_review_required=true；没有通过放宽约束忽略这些路径，不能宣称全部时序通过。

新下载文件为`output/GW_PROBLEM_TOW.fs`，与`impl/pnr/GW_PROBLEM_TOW.fs`逐字节相同。
SHA256：`ac808a358234b40991576448367792ce7dbbe0088d9131d75edf338fcbd1b9dd`。
旧位流保存在`output/audio_effects/before/build/`。本轮未下载开发板或改写串口屏，听感尚需上板确认。

## 共用数字效果器（2026-11-02，初始实现阶段记录）

增加audio_effects并接在原公共限幅器之后，钢琴/马林巴的压力、UART试听及PN/MB播放共用。
原声/延迟/混响/合唱互斥，串口屏0x51选择模式、0x52设置0～100效果量；
n6/n7锁存回显已接受目标，原n0～n5及文本字段保持含义。参数平滑，不重触发原音符。
上电/KEY2为原声和30。自然松键/SD结束保留尾音，停止/新曲/切音色清除旧尾音并保留选择。
频谱/波形观察最终DAC样本及尾音；瀑布流/长按LED继续观察原音符与物理按压。

共享8192×16同步RAM，不复位整块RAM；指针/有效长度隐藏旧数据。
三种算法均作干湿混合和16位饱和，全部模式固定增加一音频帧约61.44 us延迟，
不改50 MHz时钟或DAC采样率。效果FSM实测最多20周期，但这不是物理时序证明。
效果器deadline故障0x62独立锁存，不通过错误自清形成组合反馈。

sim/run_effects.ps1四项仿真通过：

- tb_audio_effects：178,966样本与独立Python定点模型逐字一致，含全部0～127硬件输入量、缓存回卷、淡入淡出、饱和、清除、尾音过期和超期故障。
- tb_tjc_status：88音×两种乐器、n0～n7、GB2312、FF边界、反压及原子快照。
- tb_uart_protocol：新增51/52有效/无效参数、设置后ACK；保留原坏帧、超时、重同步、FIFO溢出与停止优先测试。
- tb_effects_integration：真实UART/压力扫描，钢琴按住切换效果不重敲，马林巴演奏、停止/切音色、自然SD结束后回声与分析、实际双声道DAC串行解码及KEY2。

四个模式按钮和101个效果量帧检查通过。output/audio_effects/verification.json
记录51个RTL与测试/脚本输入指纹，并逐字节确认原合成器、限幅器、音频ROM、蓝牙/存储、
实时瀑布流和CST/SDC未变。WAV导出来自RTL数字样本，不是开发板录音。
最终RTL另通过9项压力/兼容、11项蓝牙上传/播放、5项压力马林巴、
6项实时瀑布流和13项分析/视频配置（含官方视频器件模型），连同效果专项共48项配置。
频谱和波形的钢琴/马林巴数据及完整RGB像素仍匹配独立参考；
日志保存在output/audio_effects/*_final.log，完整索引由
`python -B tools/check_effects.py --full-regression`生成。
集成测试仍有原调试输出及测试台未连接输出的ModelSim告警；不能将功能通过表述为综合零告警。

屏幕事件脚本在screen/tjc_uart/effect_*.txt，控件清单见docs/AUDIO_EFFECTS.md。
未提供或修改用户实际.HMI/.TFT，未在TJC IDE编译或实屏验证。
源码备份output/audio_effects/before/sources.zip，不包含大型卡镜像。
没有运行Gowin综合/PnR、生成位流、打开物理串口、写卡或烧录；
RAM/DSP最终映射、50/108/540 MHz物理时序及实际听感由用户最终构建和上板确认。

## 压力马林巴与共享分析（效果器加入前历史）

开放手动压力马林巴，使用原CMD=0x44/0x43切换乐器，校准/ADC/引脚不变。
马林巴前三组分别映射MIDI 36～51、52～67、68～83，4～7组不产生新音符或灯光；
原组优先级及钢琴全部分组不变。无效按压即使切回有效组也需松开重按，
有效按压切组后的更新/松开仍匹配原音高。乐器切换清音及事件，不重播仍按住键。

压力决定敲击时的初始力度；持续压力更新由接口消费但不会重敲或改变本次马林巴响度，
松开后按原模态/噪声/琴体滤波自然衰减。原音频运算、五张音频ROM及公共限幅器不变。
马林巴输出只读voice_busy，音源银行在模态/噪声/pending结束后保留128音频帧滤波清尾窗口。
压力长按灯同样支持马林巴，但表示按压时间，不表示声音持续时间。

将钢琴专用有效标志改为audio_analysis_active；钢琴/马林巴压力、UART试听、PN/MB播放
共用一套既有FFT/波形/帧缓存及DAC实际样本。切音源/停止/复位取消旧分析代次。
标题AUDIO SPECTRUM/AUDIO WAVEFORM、空闲WAITING FOR AUDIO；字体只新增D字形，
窗函数和旋转因子不变。钢琴瀑布流源码、CDC和场景保持不动，马林巴不发送亮键或瀑布流数据。

新增tb_marimba_mapping，遍历48音、四个无效组及无效按压/LED、捕获松键和重新按下。
新增tb_marimba_pressure，真实UART选择和压力采样驱动B5及16键和弦，
验证起音力度锁存、不重敲、松键后继续分析、自然衰减和128帧清尾、
1024个实际DAC样本、512行FFT/波形结果、analysis_frame_cdc完整换帧、
无效组及重新按下、切音源清除旧画面和KEY2。
马林巴频谱和波形各1,440,000个RGB像素与独立字体/几何参考完全一致，
512行数据与定点FFT/波形参考逐字一致，参考另与浮点复数FFT交叉检查。
原常规事件1152帧PCM对照、马林巴核心、压力钢琴、上传/播放、音频显示及实时瀑布流回归通过。
完整配置/日志指纹索引见output/marimba_pressure/verification.json，
专项入口sim/run_marimba_pressure.ps1（仅静态检查和仿真，不运行Gowin）。

备份output/marimba_pressure/before/sources.zip保留用户现有实时瀑布流与八灯功能；
没有复制大型磁盘镜像，没有运行综合/PnR或生成位流，也没有写卡/打开串口/烧录。
物理资源、50/108/540 MHz时序与实际声音由用户最终编译及上板确认。

## 实时钢琴瀑布流（2026-11-01，压力马林巴加入前历史）

模式0统一观察压力键盘、UART单音试听和SD钢琴实际被合成器接受的开关音符。
按下从顶部出现，60 Hz每帧向下滚动4像素，保持最近180帧约3秒的历史；
条长跟随按住时间，键盘亮键跟随当前门控状态。压力力度更新不重触发。
停止、换曲、切换乐器、错误及KEY2清屏，普通释放和自然结束后历史继续滚出。
不改变SD文件格式、音频合成算法、DAC、引脚或时钟约束。

新增piano_live_roll及生产REALTIME分支，原固定谱面分支只保留用于历史测试。
快照增加帧间活动锁存和短清屏命令锁存，当前亮键与帧间活动分开传输。
50个RTL、五张音频ROM、200个编号槽位/按钮及引脚检查通过。

sim/run_live_waterfall.ps1六项回归通过：

- tb_live_waterfall：400帧、2174次历史像素检查，短按、和弦、持续时长、向下滚动、两轮以上回卷、短清屏、模式切换及传输中复位。
- tb_live_waterfall_scene：独立Python参考与全部1,440,000个RGB像素完全一致，含键位、历史长条、亮键及五拍流水。
- tb_video_sync：201次原有跨时钟域快照兼容检查。
- tb_uart_notes：串口试听的瀑布流亮键与合成器门控一致，包含两种乐器隔离。
- tb_video_player：真实SD编号钢琴播放的音符、PCM分析及马林巴隔离。
- tb_pressure_integration：真实ADC扫描、16键和弦、持续力度、尾音、UART/SD接管、压力错误恢复和KEY2；瀑布流亮键逐周期对照合成器门控。

另通过官方Gowin PLL/CLKDIV/OSER10模型启动、差分输出和复位重锁定检查。
tb_piano_views也通过：显示0/1/2切换及无效参数处理期间，PCM/DAC与独立播放器逐拍一致，
包含1024个真实钢琴采样、马林巴隔离及停止/复位；日志在output/live_waterfall/tb_piano_views.log。
结果及RTL指纹在output/live_waterfall/verification.json；实际RTL渲染图为live_waterfall_rtl.ppm，
preview.png为同一PPM转换的预览。未重新综合、布局布线或烧录，旧.fs不包含新功能。

## 八路长按LED进度条（2026-11-01，当前源码，未重新综合）

用户确认实际为八路GPIO LED，第3/4组顺序问题来自实物接线，故分组译码及引脚不改。
原SD初始化/文件找到/播放/错误灯用途全部移除，LEDs[0]～LEDs[7]改为
约0.5～4秒、每0.5秒一档的累计长按进度，低有效。
多键取当前有效按住键中最长的时长，确认松键后显示剩余键的最长时间，
全部松开即灭，不把不同按键或不同次按压的时间累加，也不显示音源尾音。
SD、试听/其尾音、马林巴、复位、校准和压力故障时全灭；恢复压力模式仍需松开重按。
独立LED_indicator_static静态彩灯保留。

复用pressure_keys逐键held_frames，增加八档阈值输出并并行合并，
默认计数在8336帧封顶，用14位而非原32位计数；不增加八套独立计时器或串联最大值比较链。
顶层按50 MHz与扫描周期计算每半秒的帧数，默认1042帧/档，
实际每档约0.50016秒，八档约4.00128秒。
修复用户顶层已为8位、播放器和系统层仍为4位的端口宽度不一致，
现三层均为LEDs[7:0]。保留全部用户新增的八路LED球位，CST/SDC逐字节不变。
静态检查新增八路LED球位与三层端口位宽的一致性检查。

新增tb_hold_progress，在4帧加速档位和1042帧默认档位下检查全部阈值边界、
封顶、多键最长/回落、不累加、模式重入、16键及复位。
扩展真实顶层/DAC测试验证LED极性、八位全亮、校准及所有暂停条件、
松键后声音仍有尾音但LED全灭、返回时旧按键不重新点灯。
准入测试同时验证SD/UI反馈状态不再触发任何旧灯光指示。
九项压力/LED/兼容配置及十一项上传/播放配置全部通过，合计20项仿真配置，
另有11项Python测试通过；1152帧常规PCM对照一致，88音最大计算延迟仍为2861周期。
完整回归结果与当前输入指纹在output/hold_leds/verification.json。

源码备份output/hold_leds/before/sources.zip包含用户本次的8位顶层及八路引脚约束，
不含大型镜像或位流。没有运行Gowin综合、布局布线、更新位流或操作开发板，
最终资源与物理时序由用户编译确认。

## 选曲组合反馈修正（2026-11-01，LED改写前历史）

修正用户综合日志中的AG0100相关依赖：
uart_play → uart_start → control_restart → pressure_enable → pressure_busy →
player_state → uart_play。虽然原状态编码中的空闲/压力忙都允许冷启动请求，
功能仿真可以稳定通过，但RTL仍存在结构性反馈，不能以此忽略综合告警。

仅修改两个RTL文件：instrument_system输出sd_active，直连playback_control已有的
ringtone_active寄存器；piano_score_player用目录有效表和sd_active进行选曲准入，
不再读取显示用player_state。没有新增状态寄存器、延迟控制动作或修改反馈协议，
没有改动CST/SDC/时钟、音频运算、蓝牙协议及SD布局。

新增tb_play_admission：主动将反馈状态设为播放、空闲或非法值，
验证冷启动请求、SD加载期阻止未知槽位抢占、已上传槽位切换、同曲不重启、
串口屏试听转入SD及复位。修改前在“Cold selection depends on display state”
断言处失败，修改后通过；红/绿日志为output/logical_loop_fix/admission_before.log及admission_after.log。
扩展tb_pressure_integration，验证尚未扫描目录时从正在发声的压力钢琴首次选曲，
转交SD后清音，并在返回时抑制仍按住的键。

压力/兼容回归8项（包含新增准入测试）、上传/播放11项、PCM分析/显示归属2项，
合计21项仿真配置和11项Python测试通过。完整日志/指纹索引为output/logical_loop_fix/verification.json。
八项压力证据在output/pressure_keyboard/verification.json；原上传/播放证据重新收集。
本次不运行Gowin综合/PnR、不更新位流；CST/SDC与修正前逐字节核对。
用户随后反馈重新编译成功且未再出现AG0100；该确认属于本节代码版本，
新增LED功能仍未由代理运行Gowin，不能将功能仿真等同于物理时序验证。

## 完整压力钢琴（2026-11-01，组合反馈修正前历史）

当前49个RTL，包含用户此前添加的静态LED模块及本次新增的六个ADC/压力/分组模块。
参考D:\GW_basic_KEYBOARD复用采样、校准、滤波、力度曲线、边沿队列、分组与同音高持有者处理，
只为钢琴增加event_update及平滑增益状态，不合入旧FAT播放器或其他历史音源。
顶层默认PRESSURE_ENABLE=1；SD_SCORE_ENABLE仍只控制可选启动播放。
压力仅在手动钢琴状态运行，SD、试听及马林巴选择互斥；校准连续保留。
切换清除待发事件，已按住的键需先松再按，防止返回时突然重放。
压力FIFO溢出锁存0x61、清音并暂停，停止/重新选择/KEY2可恢复。
KEY2恢复默认试听选择，并重新进行16键基线校准。

七项压力/兼容仿真配置通过：tb_pressure_curve、tb_pressure_events、tb_pressure、
tb_pitch_groups、tb_pressure_integration、tb_instrument_bank，以及tb_synth的LIVE_DYNAMICS=1配置。
包括4096力度值扫描、16键和弦、持续增减力度、释放尾音、128组输入掩码、
共享C8最大力度/最后持有者释放、反压与溢出、实际顶层ADC/UART/SD/PT8211、
模式切换、仍按住键的抑制和KEY2复位/重新校准。
新实时力度与旧固定力度常规事件1152帧PCM逐样本一致。
开启实时力度的88音测试最大计算延迟仍为2861周期，低于3072周期音频帧预算；
这是周期预算验证，不是布局布线后的物理时序通过。

现有11项上传/播放、13项显示/分析、5项音频基础配置及11项Python测试也通过。
其中上传/显示共有3项重复，音频基础与上传共有1项重复；合计32项不同仿真配置。
覆盖原PN/MB播放、100 KiB上传、覆盖、清零、CRC、溢出、复位、试听、完整3721事件、
实际PCM分析、三个1600×900场景及官方视频原语。
五张音频ROM、马林巴引擎、蓝牙协议、固定槽位读写及全部原有球位逐文件/逐项核对未改。
新增25个ADC/分组球位与参考工程一致；分组加下拉，无重复球位。
保留50/108/540 MHz时钟目标，只增加分组异步输入到首级同步寄存器的例外，
未给ADC添加整条false path或捏造外部时序值。

备份为output/pressure_keyboard/before/sources.zip，不含大型磁盘镜像。
压力回归及当前输入指纹在output/pressure_keyboard/verification.json；
仿真入口sim/run_pressure.ps1和sim/run_all.ps1均不会运行Gowin综合/PnR。
**按用户要求，本次没有综合、布局布线或生成新位流，也没有写卡/打开串口/下载FPGA。**
当前impl/pnr与output中的既有位流均不能当作已包含压力功能的新交付。
最终编译、资源和时序确认由用户执行，实际ADC时序/阈值与声音仍需上板验证。

## 仅PN/MB编号曲目（2026-11-01，压力接入前历史）

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
