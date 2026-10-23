create_clock -name sys_clk -period 20.000 [get_ports {sys_clk}]
set_false_path -from [get_ports {KEY0 KEY1 KEY2}]
# Only the asynchronous RX pad -> first synchronizer stage is excepted.
# The synchronizer and all UART/parser/audio logic remain timed at 50 MHz.
set_false_path -from [get_ports {uart_rx}] -to [get_pins {score_player/uart_control.link/receiver/rx_meta_s0/D}]
