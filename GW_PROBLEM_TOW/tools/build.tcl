set project_dir [file normalize [file join [file dirname [info script]] ..]]
cd $project_dir
open_project [file join $project_dir GW_PROBLEM_TOW.gprj]
set_option -top_module GW_PROBLEM_TOW
run all
if {![file exists impl/pnr/GW_PROBLEM_TOW.fs]} {error "No bitstream produced"}
puts [exec python tools/check_timing.py]
exit
