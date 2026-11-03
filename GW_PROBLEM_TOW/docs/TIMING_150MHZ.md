# 150 MHz时序修正：第一轮

## 状态与边界

基于2026-11-03 16:45的用户PnR报告：BSRAM已降至106/118，
但sys_clk目标50 MHz、Fmax46.571 MHz；audio_clk目标150 MHz、Fmax66.040 MHz，
最差Setup为-8.476 ns。此报告仍是修改前的报告，不能证明本轮修改后已收敛。

本轮只修改audio_effects、audio_domain_bridge、audio_cdc_fifo、audio_clock150、
piano_video、SDC及一条CST时钟网约束。时钟频率目标、采样率、59个RTL清单、
ROM内容、音源运算、SD/蓝牙/屏幕协议、压力映射和全部IO引脚保持不变。
没有运行主工程综合/PnR或烧录，最后编译仍由用户执行。

## 真长路径拆分

原最差效果路径把效果量限幅、目标增益、渐变、颤音乘法、分数延迟、
地址减法和warm比较串在同一个周期。
现在在采样边界锁存控制，依次进行目标/渐变、深度乘法、增益乘法、
偏移、地址与缓存有效判断。反馈、调制及最终混合的加法/饱和也分拍处理。
18位有符号混合中间值保留完整范围；乘法及舍入结果与原参考逐样本相同。
内部最长处理从8增至16个时钟，仍远小于3072周期，不增加DAC整帧延迟，
也不改变回声长度、LFO速度、渐变、尾音时间或32 KiB效果缓存。

FIFO读出后增加一个有序事件寄存级，先完成类型/代次判断，再送入音源。
该事件未被音源接受前，后续配置不得越过它；ACK仍只在实际音源握手时产生，
不是FIFO一读出就提前确认。STOP/失锁会连同旧事件一起清除。
事件通路多一个音频时钟，不降低合成吞吐预算或改变SD毫秒时间基准。

## 复位与CDC

FIFO适配器的读状态机及rd_data/rd_valid改由rd_release[3]本地同步释放复位，
不再把组合restart/PLL锁定请求直接作为这些功能寄存器的释放边沿。
保留官方双时钟FIFO及其Gray指针同步器，不修改加密IP。

SDC对四组Gray指针Q到首级D各施加6 ns最大延迟，合计20个首级引脚。
仅取消这些首级D的同步Hold检查，Setup仍保留最大延迟约束；
第二级、FIFO数据与所有普通50/150 MHz路径继续检查。
本版工具不使用未支持的-datapath_only或set_bus_skew语法。

异步复位例外只到九组专用释放同步链的CLEAR，共35个管脚；
同步链最终Q到功能寄存器复位的路径仍然计时。PLL锁状态仅豁免第一级D。
未增加整域false_path、clock_groups、multicycle或降低频率/调整速度等级。

官方CLKDIV /5模型高电平为三个FCLK周期、低电平为两个，并非50%占空比。
SDC据此把PCLK改为-edges {1 7 11}，频率仍108 MHz，不能把PCLK下降沿误当成
FCLK的半周期错相。测试直接测量了高/低电平时间，核对真实模型与约束一致。

视频OSER10复位改用既有540 MHz FCLK下降沿的三级释放同步器。
仅新增三个复位控制寄存器，视频主体仍108 MHz，音频/系统仍150/50 MHz。
CST增加serializer_clk的BUFG=CLK约束，用常使能的官方DCE为这三个寄存器
分出全局时钟支路，不直接约束原serial_clk的IO HCLK网络。
不能让真实时钟挤在普通布线上；原IOLOGIC的HCLK连接及全部引脚不变。
下一份报告需额外确认该时钟路由资源分配和540 MHz寄存器路径。
串行器RESET路径没有豁免，其Recovery/Removal仍必须通过用户的新PnR报告确认。

## 新报告与下一步

此前全局最差25条路径全部被音频占据，50 MHz系统域只有汇总、没有详细路径。
SDC现在单列sys→sys、audio→audio、sys→audio、audio→sys、pixel→pixel报告，
并增加Gray最大延迟例外报告，以及效果器/两音源/桥接/SD/蓝牙的模块Fmax。
因此本轮不盲改没有详细路径的系统逻辑，下一份报告据实际瓶颈继续迭代。

tools/check_timing.py不再接受历史视频复位端点白名单：
全局与各域Setup/Hold、Recovery/Removal、跨域数据及约束例外负裕量均须为零。
模块Fmax不会覆盖TOP的Fmax，避免读取模块报表后误判整机通过。
V22外部时钟的PR1014一般布线警告也应继续关注，未擅自更换硬件引脚。

tools/check_timing150_constraints.py在安全Tcl解释器内检查语法和例外范围，
并核对官方FIFO模型中20个首级引脚。它不是实际EDA集合匹配或物理时序分析；
重新编译时还须检查SDC是否有空集合、未匹配管脚或被忽略的约束。
具体语法按本机SDK的SUG940第5.4/5.5节核对，OSER10异步复位按UG304第4.3.5节核对。

## 功能验证

```powershell
powershell -ExecutionPolicy Bypass -File sim/run_timing150.ps1
powershell -ExecutionPolicy Bypass -File sim/run_timing150.ps1 -Full
python -B tools/check_timing150.py --require-system
```

八项专项覆盖251045个旧速率参考、244491个原生效果参考、48000个冻结源码对照样本，
官方PLL/FIFO的576字背压/复位、旧代次取消、溢出与1 ns失锁恢复，
视频启动/复锁、1500个完整三路TMDS字、60% PCLK占空比及分析帧CDC。
真实顶层在VIDEO_ENABLE=0下另验证ADC压力、PN/MB、UART、9434个双声道DAC帧、
10131个精确返回包；用其1024个实际DAC样本验证512行FFT，再独立渲染两幅各144万像素画面。
实际官方PLL/OSER10链路由上述独立视频复锁/解码测试覆盖。
上述均为功能仿真，不是150 MHz时序证明。

修改前源码/报告、冻结参考及用户位流保存在output/timing150/before；
结果与指纹为output/timing150/verification.json。编译前建议保留该备份。
旧阶段的“与当时其他源码完全不变”存档审计只适用于对应历史阶段，不能把本轮
有意修改的CDC/复位/效果器误判为未授权变化；本轮由新的定向审计记录。
