create_clock -name sys_clk -period 20.000 [get_ports {sys_clk}]
create_generated_clock -name memory_clk -source [get_ports {sys_clk}] -multiply_by 8 [get_pins {u_clock/u_pll/PLLA_inst/CLKOUT2}]
create_generated_clock -name ui_clk -source [get_pins {u_clock/u_pll/PLLA_inst/CLKOUT2}] -divide_by 4 [get_pins {u_ddr3/gw3_top/u_ddr_phy_top/fclkdiv/CLKOUT}]
// Same domain grouping as Sipeed cam_dvi/src/TMDS_60HZ.sdc. The PHY
// stops/restarts memory_clk during calibration, so a fixed phase relationship
// across these domains is not assumed. User status uses two-stage synchronizers;
// MC/PHY crossings and calibrated I/O are owned by the Gowin IP.
set_clock_groups -asynchronous -group [get_clocks {sys_clk}] -group [get_clocks {memory_clk}] -group [get_clocks {ui_clk}]
set_false_path -from [get_ports {reset_button}]
