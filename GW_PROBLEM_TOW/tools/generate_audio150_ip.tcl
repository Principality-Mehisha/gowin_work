# Generate official IP only. Never run the top-level synthesis/PnR flow.
set root [file normalize [file join [file dirname [info script]] ..]]
set project [file join $root output audio150 ip_project audio150_ip audio150_ip.gprj]
if {[file exists $project]} {
    open_project $project
} else {
    create_project -name audio150_ip -dir [file join $root output audio150 ip_project] \
        -pn GW5AT-LV60PG484AC1/I0 -device_version B
}
set_device -name GW5AT-60B -device_version B GW5AT-LV60PG484AC1/I0
create_ipc -name fifo -dir [file join $root ip] \
    -module_name Gowin_Audio_FIFO32 -file_name audio_fifo32 -force
set fifo [get_ips Gowin_Audio_FIFO32]
set_property -dict {
    CONFIG.Write_Depth 16 CONFIG.Read_Depth 16 CONFIG.Write_Data_Width 32
    CONFIG.Output_Registers_Selected false CONFIG.Controlled_by_RdEn true
    CONFIG.En_Reset true CONFIG.Reset_Synchronization false
    CONFIG.Read_Data_Num false CONFIG.Write_Data_Num false
    CONFIG.Almost_Full_Flag true CONFIG.Almost_Full_Set 14 CONFIG.Almost_Empty_Flag false
    CONFIG.FIFO_Implimentation BSRAM
} $fifo
report_property $fifo
generate_target all $fifo
create_ipc -name clock_plladv -dir [file join $root ip] \
    -module_name Gowin_Audio_PLL150 -file_name audio_pll150 -force
set pll [get_ips Gowin_Audio_PLL150]
set_property -dict {
    CONFIG.CLKIN_FREQ 50 CONFIG.CLKOUT0_FREQ 150
    CONFIG.PLL_Reset true CONFIG.LOCK_EN true
} $pll
report_property $pll
generate_target all $pll
