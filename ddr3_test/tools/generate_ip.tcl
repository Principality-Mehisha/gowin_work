set project_dir [file normalize [file join [file dirname [info script]] ..]]
cd $project_dir
open_project ddr3_test.gprj
create_ipc -name ddr3 -module_name DDR3_Memory_Interface_Top -file_name ddr3_memory_interface -dir [file join $project_dir src ip ddr3]
foreach {key value} {
    User_Interface Controller Memory_Type Components Memory_Clock 400
    CLK_Ratio 1:4 Dq_Width 16 Dram_Width 16
    Rank_Address 1 Bank_Address 3 Row_Address 15 Column_Address 10
    SIM false Burst_Type SEQ
    CAS_Latency 6 CW_Latency 5 Additive_Latency 0
    Rtt_Nom 60 Rtt_Wr OFF Addr_Cmd_Mode 1T OUTPUT_DRV LOW
    User_Refresh false tRTP_Period 10000 tRP_Period 15000
    tWTR_Period 10000 tRC_Period 52500 tRAS_Period 37500
    tRCD_Period 15000 tFAW_Period 50000 tRRD_Period 10000
    tCKE_Period 7500 tREFI_Period 7800000 tRFC_Period 260000
    AXI4_Interface false Debug_Port_Enable false
} {
    set_property CONFIG.$key $value [get_ips DDR3_Memory_Interface_Top]
}
generate_target [get_ips DDR3_Memory_Interface_Top]
create_ipc -name clock_plladv -module_name DDR3_PLL -file_name ddr3_pll -dir [file join $project_dir src ip pll]
foreach {key value} {
    CLKIN_FREQ 50 CLKOUT0_FREQ 400 CLKOUT2_EN true CLKOUT2_FREQ 400
    PLL_Reset true LOCK_EN true MDRP_EN true
} {
    set_property CONFIG.$key $value [get_ips DDR3_PLL]
}
generate_target [get_ips DDR3_PLL]
exit
