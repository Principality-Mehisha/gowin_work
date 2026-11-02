set project_dir [file normalize [file join [file dirname [info script]] ..]]
cd $project_dir
puts [exec python tools/check_project.py 2>@1]
open_project [file join $project_dir GW_PROBLEM_TOW.gprj]
set_option -top_module GW_PROBLEM_TOW
# Placement algorithm 2 for the modulation-effects implementation; retain
# timing-driven routing, fanout allowance and resource replication.
set_option -place_option 2
set_option -timing_driven 1
set_option -route_option 1
set_option -route_maxfan 60
set_option -replicate_resources 1
run all
if {![file exists impl/pnr/GW_PROBLEM_TOW.fs]} {error "No bitstream produced"}
puts [exec python tools/check_timing.py 2>@1]
puts [exec python tools/write_build_manifest.py 2>@1]
file mkdir output
file copy -force impl/pnr/GW_PROBLEM_TOW.fs output/GW_PROBLEM_TOW.fs
puts "Bitstream: [file join $project_dir output GW_PROBLEM_TOW.fs]"
exit
