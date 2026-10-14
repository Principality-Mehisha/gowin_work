create_clock -name sys_clk -period 20 -waveform {0 10} [get_ports {sys_clk}]
create_generated_clock -name serial_clk -source [get_ports {sys_clk}] -multiply_by 161 -divide_by 64 [get_pins {clocks/pll/CLKOUT0}]
create_generated_clock -name pixel_clk -source [get_pins {clocks/pll/CLKOUT0}] -divide_by 5 [get_pins {clocks/pixel_divider/CLKOUT}]
// The reset and human-operated test-mode button are asynchronous inputs.
set_false_path -from [get_ports {KEY2 KEY0}]
