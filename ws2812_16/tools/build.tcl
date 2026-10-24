set project_dir [file normalize [file join [file dirname [info script]] ..]]
cd $project_dir
open_project [file join $project_dir ws2812_16.gprj]
set_option -top_module ws2812_16
run all
set bitstream [file join $project_dir impl pnr ws2812_16.fs]
if {![file exists $bitstream]} {error "No bitstream generated: $bitstream"}
puts "bitstream: $bitstream"
exit
