# 串口屏一键88音钢琴试听

## 屏幕按钮

在现有淘晶驰屏幕工程新增一个“88音同时发声”按钮，关闭默认“发送组件ID”，
在触摸弹起事件加入 `screen/tjc_uart/piano88_release.txt` 的内容：

```text
printh A5 5A 01 00 46 00 00 00 47 0D
```

沿用115200/8N1、`recmod=0`。无需新增全局控件、SD文件或更改SD卡布局。
停止按钮继续使用原脚本：

```text
printh A5 5A 01 00 11 00 00 00 12 0D
```

CMD=0x46的P0/P1/P2均须为0，非零返回参数错且不影响演奏。
SEQ及校验规则沿用UART v1。主机工具仅打印帧的示例：

```powershell
powershell -File tools/send_uart_command.ps1 -Command Piano88
```

工程内没有用户实际的.HMI/.TFT；需在屏幕IDE中添加按钮、编译并下载屏幕工程。
FPGA也必须重新编译并下载，旧位流不识别此命令。

## 演奏行为

- 自动选择钢琴，A0～C8共88个音符同帧起奏，力度192。
- 约0.5秒后同帧释放全部音符，再保留约1秒自然尾音后清音。
- 时长沿用`NOTE_GATE_CYCLES=25000000`、`NOTE_TAIL_CYCLES=50000000`，控制时钟50 MHz。
- 重按按钮清音重奏；停止、选曲、单音试听、切换/重选音色及KEY2均中断当前全音试听。
- 启动时中断SD演奏或加载；试听期间暂停压力输入，结束后遵循原来的松键后重新按下规则。
- 不改变分别记忆的钢琴和马林巴单音选择；上/下音只修改选择，不改变全音试听。
- 沿用数字效果和共用限幅器。满复音会触发动态限幅，听感不能等同于单音音量乘88。
- `page0.n0.val=4`表示试听/尾音，`every.tInstrument.txt`回显钢琴；
  `every.tNote.txt`仍表示单音选择，并非全音播放清单。查询和命令接受结果沿用原协议。
- 视频按音频域实际接受的广播ACK一次性点亮/释放88个琴键，瀑布流记录全部88音。
- 这是独立试听功能，不把SD乐谱事件槽从32改为88，也不扩展马林巴的48音范围。

## 实现

`uart_score_control`输出单周期`note_all_play`，通过板级入口交给`instrument_system`。
全音请求与单音请求共用播放所有权、会话重启、压力互斥、尾音计时及错误静音路径。
`uart_note_audition`选择钢琴并发送内部音符地址127的广播on/off。
50到150 MHz的官方FIFO保持命令顺序，音频接受后沿原ACK路径回传。

`piano_synth`仅在`IDLE && !sample_tick`时接受广播，将88个gate同时置位/清零，
on同时置位88个pending，下一次完整音频帧扫描统一启动全部ADSR及相位；
off则在下一次完整扫描统一进入release。不会逐音下发88次note-on形成扫奏。
等待ready时保持事件，禁止在扫描中间提交广播。

广播力度用一个8位寄存器和88位有效掩码保存，保留原有单音力度RAM的单地址写入，
不增加88路并行RAM写口。普通note-on或有效压力更新只覆盖对应音符的力度；
停止/会话重启清除广播掩码。除内部地址127外，原0～87音符接口和PCM计算路径不变。
广播地址127的update不作为广播执行；马林巴不使用此广播。

## 验证

```powershell
powershell -ExecutionPolicy Bypass -File sim/run_piano88.ps1
```

专项回归覆盖：

- `tb_piano88_core`：固定/持续力度两种配置，扫描中间反压、同帧88音相位/ADSR起奏、
  全音保持、统一释放、单音力度覆盖/压力更新、重奏、停止及停止后的单音恢复。
- `tb_piano88_uart`：实际UART RX、官方150 MHz PLL及CDC FIFO、88个活动音符、
  非零PCM、ACK/视频键同步、自动释放/尾音、错误参数/校验、重按、停止、
  单音/音色/SD互相抢占和KEY2复位。
- 原有`tb_note_audition`、`tb_uart_protocol`、`tb_uart_notes`回归，
  额外验证0x46的参数及回包和广播on/off反压。

日志和六次专项运行的源码指纹汇总`verification.json`在`output/piano88/`，
源码备份在`output/piano88/before/sources.zip`。两种力度配置实测最大2861/3072个时钟，
没有计算超期或输出饱和；保留共用限幅器的动态增益。
仿真验证的计算周期预算不等于布局布线时序收敛；本次未更新发布位流，
完整综合/PnR、资源/150 MHz时序检查、屏幕IDE编译和上板听感仍需后续完成。
