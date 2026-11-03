create_clock -name sys_clk -period 20.000 [get_ports {sys_clk}]
create_generated_clock -name audio_clk -source [get_ports {sys_clk}] -multiply_by 3 [get_pins {score_player/audio_clocks/pll/u_pll/PLLA_inst/CLKOUT0}]
set_false_path -from [get_ports {KEY0 KEY1 KEY2}]
# Only the first group-switch synchronizer stages are asynchronous.
set_false_path -from [get_ports {pitch_group[0] pitch_group[1] pitch_group[2] pitch_group[3] pitch_group[4] pitch_group[5] pitch_group[6]}] -to [get_pins {score_player/system/pressure_input.groups/group_meta*_s0/D}]
# ADC capture/dividers remain timed at 50 MHz. External ADC tCO/settling
# must be measured; no fabricated input delays or blanket ADC exceptions.
# Only the asynchronous RX pad -> first synchronizer stage is excepted.
# UART synchronizers/parsers stay at 50 MHz; audio is timed by audio_clk.
set_false_path -from [get_ports {uart_rx}] -to [get_pins {score_player/uart_control.link/receiver/rx_meta_s0/D}]
set_false_path -from [get_ports {bt_rx}] -to [get_pins {bluetooth_upload/receiver/rx_meta_s0/D}]
create_generated_clock -name serial_clk -source [get_ports {sys_clk}] -multiply_by 54 -divide_by 5 [get_pins {display_enabled.video/clocks/pll/CLKOUT0}]
# Official CLKDIV /5 is high for three FCLK cycles and low for two.
create_generated_clock -name pixel_clk -source [get_pins {display_enabled.video/clocks/pll/CLKOUT0}] -edges {1 7 11} [get_pins {display_enabled.video/clocks/pixel_divider/CLKOUT}]
# Asynchronous status enters only this first lock synchronizer stage.
set_false_path -to [get_pins {score_player/system/clock_bridge/lock_sync_0_s0/D}]

# Official FIFO registered Gray pointers: bound each crossing to less than
# one 150 MHz period. Only the first metastability-catching D pins have their
# synchronous hold check removed; second stages and all payload paths stay timed.
set_max_delay -from [get_pins {score_player/system/clock_bridge/commands/fifo/fifo_inst/Equal.wptr*_s0/Q}] -to [get_pins {score_player/system/clock_bridge/commands/fifo/fifo_inst/Equal.rq1_wptr*_s0/D}] 6.000
set_max_delay -from [get_pins {score_player/system/clock_bridge/commands/fifo/fifo_inst/Equal.rptr*_s0/Q}] -to [get_pins {score_player/system/clock_bridge/commands/fifo/fifo_inst/Equal.wq1_rptr*_s0/D}] 6.000
set_max_delay -from [get_pins {score_player/system/clock_bridge/feedback/fifo/fifo_inst/Equal.wptr*_s0/Q}] -to [get_pins {score_player/system/clock_bridge/feedback/fifo/fifo_inst/Equal.rq1_wptr*_s0/D}] 6.000
set_max_delay -from [get_pins {score_player/system/clock_bridge/feedback/fifo/fifo_inst/Equal.rptr*_s0/Q}] -to [get_pins {score_player/system/clock_bridge/feedback/fifo/fifo_inst/Equal.wq1_rptr*_s0/D}] 6.000
set_false_path -hold -to [get_pins {score_player/system/clock_bridge/commands/fifo/fifo_inst/Equal.rq1_wptr*_s0/D score_player/system/clock_bridge/commands/fifo/fifo_inst/Equal.wq1_rptr*_s0/D score_player/system/clock_bridge/feedback/fifo/fifo_inst/Equal.rq1_wptr*_s0/D score_player/system/clock_bridge/feedback/fifo/fifo_inst/Equal.wq1_rptr*_s0/D}]

# Raw reset requests may assert/deassert at any phase. Exempt only CLEAR on
# the dedicated release pipelines. Their final Q -> functional reset paths
# (including FIFO output registers and OSER10 RESET) remain checked.
set_false_path -to [get_pins {score_player/audio_clocks/release_pipe*_s0/CLEAR score_player/system/clock_bridge/engine_release*_s0/CLEAR score_player/system/clock_bridge/commands/wr_release*_s0/CLEAR score_player/system/clock_bridge/commands/rd_release*_s0/CLEAR score_player/system/clock_bridge/feedback/wr_release*_s0/CLEAR score_player/system/clock_bridge/feedback/rd_release*_s0/CLEAR display_enabled.video/release_pipe*_s0/CLEAR display_enabled.video/sys_release*_s0/CLEAR display_enabled.video/serializer_release*_s0/CLEAR}]
# Request/acknowledge synchronizers: only the asynchronous first stages.
set_false_path -to [get_pins {display_enabled.video/display_cdc/req_meta_s0/D display_enabled.video/display_cdc/ack_meta_s0/D}]
# Bundled snapshot is held until ACK traverses two pixel registers; capture
# occurs one cycle later. Its coherency is enforced by the mailbox protocol.
set_false_path -from [get_cells {display_enabled.video/display_cdc/mailbox*}] -to [get_clocks {pixel_clk}]

# Analysis frame mailbox: only first synchronizer stages and held payloads.
set_false_path -to [get_pins {display_enabled.video/analysis_frames/req_meta_s0*/D display_enabled.video/analysis_frames/ack_meta_s0*/D display_enabled.video/analysis_frames/epoch_meta_s0*/D}]
set_false_path -from [get_cells {display_enabled.video/analysis_frames/published_*}] -to [get_clocks {pixel_clk}]

# Keep each domain's critical path visible even when another domain has many
# repeated violations. These commands affect reports, not timing exceptions.
report_timing -setup -max_paths 25 -max_common_paths 1
report_timing -setup -from_clock [get_clocks {sys_clk}] -to_clock [get_clocks {sys_clk}] -max_paths 25 -max_common_paths 1
report_timing -setup -from_clock [get_clocks {pixel_clk}] -to_clock [get_clocks {pixel_clk}] -max_paths 25 -max_common_paths 1
report_timing -setup -from_clock [get_clocks {audio_clk}] -to_clock [get_clocks {audio_clk}] -max_paths 25 -max_common_paths 1
report_timing -setup -from_clock [get_clocks {sys_clk}] -to_clock [get_clocks {audio_clk}] -max_paths 25 -max_common_paths 1
report_timing -setup -from_clock [get_clocks {audio_clk}] -to_clock [get_clocks {sys_clk}] -max_paths 25 -max_common_paths 1
report_timing -hold -max_paths 25 -max_common_paths 1
report_timing -recovery -max_paths 25 -max_common_paths 1
report_timing -removal -max_paths 25 -max_common_paths 1
report_exceptions -setup
report_max_frequency -mod_ins {score_player/system/effects score_player/system/voices/piano score_player/system/voices/marimba score_player/system/clock_bridge score_player/score_stream bluetooth_upload display_enabled.video}
