//==========================================================================
//  croatian_rhapsody.sdc —— 时序约束 (Timing Constraints)
//  CST 只管物理/电气约束，时钟周期必须在这里声明，否则报 TA1132
//  写法与官方 pmod_led_neo/src/timing.sdc 保持一致
//==========================================================================

// 核心板 50MHz 振荡器 (V22)，周期 20ns
create_clock -name sys_clk -period 20 -waveform {0 10} [get_ports {sys_clk}]
