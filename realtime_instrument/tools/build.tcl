# Portable build: gw_sh.exe realtime_instrument/tools/build.tcl
set proj_dir [file normalize [file join [file dirname [info script]] ..]]
open_project [file join $proj_dir realtime_instrument.gprj]
set_option -top_module realtime_instrument
run all
set bitstream [file join $proj_dir impl pnr realtime_instrument.fs]
if {![file exists $bitstream]} {error "No bitstream generated: $bitstream"}
puts "bitstream: $bitstream"
exit
