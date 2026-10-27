set project_dir [file normalize [file join [file dirname [info script]] ..]]
cd $project_dir
open_project ddr3_test.gprj
set_option -top_module ddr3_test
set_option -use_ready_as_gpio 1
set_option -use_done_as_gpio 1
run all
if {![file exists impl/pnr/ddr3_test.fs]} {error "No bitstream generated"}
puts "Bitstream: [file join $project_dir impl pnr ddr3_test.fs]"
file mkdir output
foreach target {output/ddr3_test.fs output/ddr3_test_fix_v3.fs} {
    if {[file exists $target]} {
        file attributes $target -readonly 0
    }
    file copy -force impl/pnr/ddr3_test.fs $target
}
puts "Updated bitstream: [file join $project_dir output ddr3_test.fs]"
exit
