set proj_dir [file normalize [file join [file dirname [info script]] ..]]
cd $proj_dir
open_project [file join $proj_dir Piano_Score.gprj]
set_option -top_module piano_score_player
run all
set bitstream [file join $proj_dir impl pnr Piano_Score.fs]
if {![file exists $bitstream]} {error "Score build did not produce a bitstream."}
puts "bitstream: $bitstream"
exit
