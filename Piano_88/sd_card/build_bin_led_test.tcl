set proj_dir [file normalize [file join [file dirname [info script]]]]
cd $proj_dir
open_project [file join $proj_dir SD_Bin_LED_Test.gprj]
set_option -top_module sd_bin_led_test
run all
set bitstream [file join $proj_dir impl pnr SD_Bin_LED_Test.fs]
if {![file exists $bitstream]} {
    error "Build did not produce a bitstream."
}
puts "bitstream: $bitstream"
exit
