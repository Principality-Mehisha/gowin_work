create_clock -name sys_clk -period 20.000 [get_ports {sys_clk}]
set_false_path -from [get_ports {KEY0 KEY1 KEY2}]
# Only the asynchronous RX pad -> first synchronizer stage is excepted.
# The synchronizer and all UART/parser/audio logic remain timed at 50 MHz.
set_false_path -from [get_ports {uart_rx}] -to [get_pins {score_player/uart_control.link/receiver/rx_meta_s0/D}]
create_generated_clock -name serial_clk -source [get_ports {sys_clk}] -multiply_by 54 -divide_by 5 [get_pins {display_enabled.video/clocks/pll/CLKOUT0}]
create_generated_clock -name pixel_clk -source [get_pins {display_enabled.video/clocks/pll/CLKOUT0}] -divide_by 5 [get_pins {display_enabled.video/clocks/pixel_divider/CLKOUT}]
# Request/acknowledge synchronizers: only the asynchronous first stages.
set_false_path -to [get_pins {display_enabled.video/display_cdc/req_meta_s0/D display_enabled.video/display_cdc/ack_meta_s0/D}]
# Bundled snapshot is held until ACK traverses two pixel registers; capture
# occurs one cycle later. Its coherency is enforced by the mailbox protocol.
set_false_path -from [get_cells {display_enabled.video/display_cdc/mailbox*}] -to [get_clocks {pixel_clk}]
