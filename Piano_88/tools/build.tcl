# Usage: gw_sh.exe <path>/Piano_88/tools/build.tcl
set proj_dir [file normalize [file join [file dirname [info script]] ..]]
cd $proj_dir
open_project [file join $proj_dir Piano_88.gprj]
set_option -top_module piano_88
run all
set bitstreams [glob -nocomplain [file join $proj_dir impl pnr *.fs]]
if {[llength $bitstreams] == 0} {
    error "Build did not produce a bitstream."
}
puts "bitstream: $bitstreams"
exit
