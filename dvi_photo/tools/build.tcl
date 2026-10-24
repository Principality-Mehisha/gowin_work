# Portable build: gw_sh.exe dvi_photo/tools/build.tcl
set proj_dir [file normalize [file join [file dirname [info script]] ..]]
open_project [file join $proj_dir dvi_photo.gprj]
set_option -top_module dvi_photo
run all
set bitstream [file join $proj_dir impl pnr dvi_photo.fs]
if {![file exists $bitstream]} {error "No bitstream generated: $bitstream"}
source [file join $proj_dir tools check_timing.tcl]
puts "bitstream: $bitstream"
exit
