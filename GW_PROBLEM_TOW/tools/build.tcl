set project_dir [file normalize [file join [file dirname [info script]] ..]]
cd $project_dir
puts [exec python tools/check_project.py 2>@1]
open_project [file join $project_dir GW_PROBLEM_TOW.gprj]
set_option -top_module GW_PROBLEM_TOW
run all
if {![file exists impl/pnr/GW_PROBLEM_TOW.fs]} {error "No bitstream produced"}
puts [exec python tools/check_timing.py 2>@1]
puts [exec python tools/write_build_manifest.py 2>@1]
exit
