// 50 MHz oscillator on V22.
create_clock -name sys_clk -period 20 -waveform {0 10} [get_ports {sys_clk}]
