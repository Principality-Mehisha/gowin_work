# Run synthesis, place and route, and bitstream generation for I2S_1.
# Usage: gw_sh.exe tools/build.tcl

set proj_dir {C:/Users/30415/Desktop/gowin_work/I2S_1}

open_project [file join $proj_dir I2S_1.gprj]
run all

set bitstreams [glob -nocomplain [file join $proj_dir impl pnr *.fs]]
puts "bitstream: $bitstreams"
exit
