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

# DDR3 uses a separate PLL and trained PHY (same groups as ddr3_test V3).
create_generated_clock -name memory_clk -source [get_ports {sys_clk}] -multiply_by 8 [get_pins {external_memory.memory/u_clock/u_pll/PLLA_inst/CLKOUT2}]
create_generated_clock -name ui_clk -source [get_pins {external_memory.memory/u_clock/u_pll/PLLA_inst/CLKOUT2}] -divide_by 4 [get_pins {external_memory.memory/u_ddr3/gw3_top/u_ddr_phy_top/fclkdiv/CLKOUT}]
set_clock_groups -asynchronous -group [get_clocks {sys_clk pixel_clk serial_clk}] -group [get_clocks {memory_clk}] -group [get_clocks {ui_clk}]
# Audio mailbox buses are held until request/acknowledge returns. Capture is
# one extra receiver cycle after the synchronized toggle. Grouping above
# covers these CDC paths; synchronizers are explicitly marked in the RTL.

# Keep each domain's critical path visible even when another domain has many
# repeated violations. These commands affect reports, not timing exceptions.
report_timing -setup -max_paths 25 -max_common_paths 1
report_timing -setup -from_clock [get_clocks {pixel_clk}] -to_clock [get_clocks {pixel_clk}] -max_paths 25 -max_common_paths 1
report_timing -setup -from_clock [get_clocks {ui_clk}] -to_clock [get_clocks {ui_clk}] -max_paths 25 -max_common_paths 1
report_timing -hold -max_paths 25 -max_common_paths 1
report_timing -recovery -max_paths 25 -max_common_paths 1
report_timing -removal -max_paths 25 -max_common_paths 1
