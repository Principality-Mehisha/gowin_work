# 板载 DDR3 参数存储

2026-10-28 最终实现：BSRAM **118/118 → 90/118**，净释放 28 块；
26 个测试平台通过，五个时钟域的数据路径 Setup/Hold 通过。
原有视频复位 recovery/removal 仍需复核，集成位流尚未实板测试。
具体频率、资源和位流指纹见 `VERIFICATION.md`。

主工程默认 `GW_PROBLEM_TOW.DDR_ENABLE=1`。DDR1 使用与已实板确认的
`ddr3_test` V3 相同的 x16 DDR3 IP、400 MHz CK、100 MHz native 用户接口、
PLL 初始化和 mDRP 控制方式，以及管脚、电平和 PHY 位置约束。
厂商源保留版权；Sipeed mDRP 模块的授权见 `third_party/SIPEED_LICENSE.txt`。
普通构建使用已纳入工程的 IP；需要重新生成时可运行
`tools/generate_ddr_ip.tcl`，保持与参考工程相同的参数。

## 迁移内容与保留的工作集

单簧管的完整 `clarinet45.hex`（45 音 × 三力度 × 32 分音 × 40 bit）和
`clarinet45_env.hex`（135 × 96 bit）迁入 DDR。默认综合不再例化这两个大 ROM。
每个音高、每个分音的 pp/mf/ff 参数装在同一个 128-bit 突发内，一次读取
同时取得力度插值所需的两个端点；包络表每行一个突发。

| DDR 突发编号 | 内容 | 字节范围 |
| --- | --- | --- |
| 0～1439 | `{8'b0, ff40, mf40, pp40}`，按音高、分音排列 | 0～23039 |
| 1440～1574 | `{32'b0, envelope96}`，保留原 profile 顺序 | 23040～25199 |

总计 25,200 字节，DDR 其余空间保留。native `addr` 使用 16-bit word 为单位，
突发编号左移三位，不是字节地址。

种子 ROM 按 128 项分组并寄存两级读出；单簧管的 DDR 配置在乘法器前寄存
操作数。视频行缓存采用 8×8 两级选择和独立的几何/掩码流水，约 69 个像素
时钟完成一行，保留原有像素读出延迟。上述流水只调整计算时刻，整数运算和
图像结果分别由 PCM 对照和逐像素对照检查。

相位、包络状态、32 项分音工作系数，以及钢琴/马林巴的逐样本状态和
视频行缓存继续使用片上存储。它们属于固定时限工作集；把这些小型或高频
随机访问全部改为 DDR 请求，需要另加预取/缓存，不能直接替换成外存数组。
钢琴和马林巴算法、SD 文件及视频谱面保持原数据格式。

## 启动与运行数据流

```text
复位释放 → 200 ms 保护时间 → PLL_INIT → 切换 mDRP 控制权
 → DDR 初始化/校准
 → 逻辑 ROM 顺序写入 1575 个突发
 → 逐突发读回比较
 → ready
 → 50 MHz 合成器请求 / 100 MHz DDR 读取 / 返回参数
```

DDR 掉电丢失数据，所以参数初值仍保存在位流中，由
`ddr_asset_seed.v` 的 **distributed_rom** 自动装载。该逻辑 ROM 使用 LUT，
不使用 BSRAM，也不作为合成器的运行时旁路。因此单音试听仍不需要 SD 卡。
这是以一部分逻辑资源换取块 RAM 空间；资源检查器会确认种子模块没有
推断出 BSRAM，并确认完整单簧管参数 ROM 已从合成器中移除。

写命令和写数据仅在两个 ready 同时为高时同拍提交，写入之间至少有两个
空闲 UI 周期，保留 V3 修复的流水边界要求。每次最多一个未完成读请求。

跨域使用请求/应答翻转位和稳定邮箱：请求地址保持到应答返回，响应数据
在应答跨两级寄存器后捕获。停止或切曲会取消当前请求，旧响应会排空并丢弃，
不能成为下一音符的参数。DDR 校准之前的单簧管 SD 播放保持时间暂停。

## 故障与操作

使用原有 KEY2 低有效复位。DDR 子系统随后重新延时、校准、装载和核对。
无须接额外外设或增加 SD 文件。

读写超时、初始化数据不匹配、读突发结束标志异常、校准丢失、PLL 失锁、
控制器复位及 UI 心跳停止会阻止 DDR 参数继续使用。单簧管静音，错误 LED
点亮，UART 报告 `0x70`；SD 错误会锁存到现有播放错误字段。
如果参数读取阻塞先触发合成器的采样截止检查，也可能先锁存现有的 `0x50`
实时超时；首个播放错误保留，DDR 细分诊断随后仍可从健康监测模块观察。
硬件健康码可观察 `external_memory.memory.health/fault_code`：1 表示参数服务
异常（读回、返回标志或握手超时），5/7/8/9/10 分别为校准丢失、校准超时、
UI 心跳停止、控制器复位和 PLL 失锁。需要复位才能恢复 DDR 服务；钢琴、
马林巴仍保留本地参数路径。

主工程 `DDR_ENABLE=0` 可用于原 ROM 路径的对照构建，但 DDR 专用约束和
资源检查默认按启用 DDR 配置提供，不把关闭参数当作独立发布配置。
子模块 `piano_score_player.EXTERNAL_CLARINET_TABLES` 默认 0，便于独立音频
回归；板级默认显式设为 1。实际部署应构建板级顶层。

## 生成、构建和验证

修改单簧管参数后，重新生成种子：

```powershell
python tools/generate_ddr_assets.py
python tools/check_project.py
powershell -ExecutionPolicy Bypass -File sim/run_ddr.ps1
powershell -ExecutionPolicy Bypass -File sim/run_ddr_native.ps1
& 'D:/Gowin/Gowin_V1.9.12.03_x64/IDE/bin/gw_sh.exe' tools/build.tcl
```

位流仍为 `impl/pnr/GW_PROBLEM_TOW.fs`，完整构建检查通过后另复制到
`output/GW_PROBLEM_TOW_ddr3.fs`。`output/build_manifest.json` 保存 RTL、ROM、
DDR IPC、公开仿真网表等输入和位流指纹。资源对比保存到
`output/ddr_migration/resources.json`。

完整集成使用脚本设置的布线优先布局、高扇出资源复制、时序驱动路由和
`route_maxfan=60`。这些选项保存在本地 `impl/` 过程配置中；复制工程或重新
创建 `impl/` 后应先运行构建脚本，不能只依赖 GUI 的默认过程配置。
构建清单也会记录这些实现选项。

| 测试 | 检查内容 |
| --- | --- |
| `tb_ddr_assets` | 1575 个突发逐字核对，初始化读回、独立背压、取消、复位、超时、损坏、结束标志和校准丢失 |
| `tb_ddr_clarinet` | DDR/原 ROM 两路逐帧比较 PCM 和混音，45 音 × 7 力度、释放、长音缓存与请求中断，并检查 3072 时钟预算 |
| `tb_ddr_player` | 真实播放器、C45S、FAT16/FAT32、UART、延迟校准、停止/重播/切换/复位 |
| `tb_ddr_native_write` | 实际 Gowin MC 网表：初始化命令、数据、内部写请求数量一致，检查真实写 FIFO |

行为模型不模拟 DDR3 电气时序。native 回归旁路 PHY，只验证控制器输入
流水和写缓冲。最终冷启动、重新校准、长时间试听仍需下载本工程位流到实板
确认，不能把参考 DDR 工程的成功反馈当作集成位流的实测结果。

SDC 延续已验证 DDR 工程的 sys/memory/UI 时钟分组；视频与系统时钟仍作为
同一组处理。跨 DDR 域由邮箱和厂商 MC/PHY 负责。时序检查器现在检查系统、
像素、串行、DDR 用户及内存时钟五个域，并单独报告复位恢复/移除检查。
