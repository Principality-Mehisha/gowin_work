set proj_dir [file normalize [file dirname [info script]]]
cd $proj_dir
open_project [file join $proj_dir SD_Piano_Music_Player.gprj]
set_option -top_module sd_piano_music_player
run all
set bitstream [file join $proj_dir impl pnr SD_Piano_Music_Player.fs]
if {![file exists $bitstream]} {
    error "Build did not produce a bitstream."
}
puts "bitstream: $bitstream"
exit
