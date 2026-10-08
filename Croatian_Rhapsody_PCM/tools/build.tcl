set proj_dir [file normalize [file join [file dirname [info script]] ..]]
cd $proj_dir
open_project [file join $proj_dir Croatian_Rhapsody_PCM.gprj]
run all
set bitstreams [glob -nocomplain [file join $proj_dir impl pnr *.fs]]
puts "bitstream: $bitstreams"
exit
