set proj_dir [file normalize [file dirname [info script]]]
cd $proj_dir
open_project [file join $proj_dir LED_Check.gprj]
set_option -top_module led_check
run all
set bitstream [file join $proj_dir impl pnr LED_Check.fs]
if {![file exists $bitstream]} {
    error "Build did not produce a bitstream."
}
puts "bitstream: $bitstream"
exit
