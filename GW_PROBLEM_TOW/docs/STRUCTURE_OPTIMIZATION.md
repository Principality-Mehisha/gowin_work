# 当前结构与资源优化

当前仅保留钢琴和马林巴两种实时音色、UART串口屏、三首SD乐谱、PT8211及钢琴HDMI瀑布流。
板级接口与instrument_system分离，instrument_voice_bank按全局乐器选择分发事件与采样使能，保留各自声部/包络算法并共用一个限幅器。架构图见instrument_architecture.svg。

## 本次完整移除的内容

- 单簧管合成器、频谱/包络参数表、单音选择状态、中文反馈和第4首SD曲目。
- 专用DDR控制器、PLL/mDRP、启动ROM、参数邮箱、DDR引脚及CST/SDC约束。
- 专用IP、素材、生成工具、测试平台及串口屏按钮脚本。
- 公共限幅器仅为单簧管准备的动态缩放分支。

视频仍需要PLL_INIT，继续保留；KEY2复位及钢琴/马林巴的事件与采样格式保留。
旧的0x45命令返回“不支持”，旧的选曲4返回“参数错误”，不会改变状态。

## Gowin实际实现结果

| 项目 | 移除前 | 移除后 |
| --- | ---: | ---: |
| BSRAM | 104/118 | 68/118 |
| Logic | 20241 | 14539 |
| Register | 16876 | 10730 |
| DSP | 26.5/118 | 22/118 |
| 布局布线阶段总耗时 | 2分49秒 | 1分37秒 |

实际释放36块BSRAM，剩余50块。此前按综合层级估算为28块，最终以完整实现报告的物理资源计数为准。
系统域Fmax=58.308 MHz，像素域Fmax=115.500 MHz；系统、像素、串行域数据路径setup/hold违例均为0。
现有视频复位recovery/removal违例及V22时钟布线警告仍被记录，reset_review_required=true。
以上是同一工具/器件/实现选项下的一次前后测量；耗时只包含PnR报告阶段，不包括综合。

## 复现

```powershell
python tools/check_project.py
powershell -ExecutionPolicy Bypass -File sim/run_structure.ps1
& 'D:/Gowin/Gowin_V1.9.12.03_x64/IDE/bin/gw_sh.exe' tools/build.tcl
python tools/check_structure.py
```

当前35个RTL、五张音频ROM、三首乐谱。结构回归覆盖两种音色的独立/共用限幅PCM对照、88/48音选音映射、屏幕反馈、协议、KEY2、SD正常与异常、完整钢琴谱及音画状态。
证据保存到output/no_clarinet/verification.json；新位流为output/GW_PROBLEM_TOW.fs。
旧代码、素材、报告及位流完整备份在output/no_clarinet/before/；此前三乐器/DDR优化记录属于已移除版本。
没有下载开发板、写物理SD卡或进行新的实板音画测试。
