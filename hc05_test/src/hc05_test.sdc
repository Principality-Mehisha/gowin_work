create_clock -name sys_clk -period 20 -waveform {0 10} [get_ports {sys_clk}]
# Asynchronous UART boundary: only the first synchronizer stage is excluded.
set_false_path -from [get_ports {uart_rx}] -to [get_pins {receiver/rx_meta_s0/D}]
