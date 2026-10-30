set project_dir [file normalize [file join [file dirname [info script]] ..]]
cd $project_dir
open_project [file join $project_dir hc05_test.gprj]
set_option -top_module hc05_test
run all
set bitstream [file join $project_dir impl pnr hc05_test.fs]
if {![file exists $bitstream]} {error "No bitstream generated: $bitstream"}
set timing_report [file join $project_dir impl pnr hc05_test_tr_content.html]
set timing_file [open $timing_report r]
set timing_text [read $timing_file]
close $timing_file
foreach check {Setup Hold} {
    set pattern [format {Numbers of %s Violated Endpoints</td>\s*<td>([0-9]+)</td>} $check]
    if {![regexp $pattern $timing_text match count]} {error "Missing $check timing summary"}
    if {$count != 0} {error "$check timing violations: $count"}
    puts "$check violated endpoints: $count"
}
file mkdir output
file copy -force $bitstream [file join $project_dir output hc05_test.fs]
file copy -force [file join $project_dir impl pnr hc05_test.rpt.txt] [file join $project_dir output hc05_test.rpt.txt]
file copy -force $timing_report [file join $project_dir output timing.html]
puts "Bitstream: [file join $project_dir output hc05_test.fs]"
exit
