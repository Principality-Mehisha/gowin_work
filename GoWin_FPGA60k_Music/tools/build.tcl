# Run synthesis, place and route, and bitstream generation for this project.
# Usage: gw_sh.exe tools/build.tcl

set proj_dir {C:/Users/30415/Desktop/gowin_work/GoWin_FPGA60k_Music}

open_project [file join $proj_dir GoWin_FPGA60k_Music.gprj]
run all

set bitstreams [glob -nocomplain [file join $proj_dir impl pnr *.fs]]
puts "bitstream: $bitstreams"
exit
