# Check synchronous data paths; review reset recovery/removal separately.
set proj_dir [file normalize [file join [file dirname [info script]] ..]]
set timing_report [file join $proj_dir impl pnr dvi_photo_tr_content.html]
set timing_handle [open $timing_report r]
set timing_text [read $timing_handle]
close $timing_handle
foreach clock {sys_clk pixel_clk} {
    set timing_pattern [format {<td>%s</td>\s*<td>Setup</td>\s*<td>([^<]+)</td>\s*<td>([^<]+)</td>} $clock]
    if {![regexp $timing_pattern $timing_text whole tns endpoints]} {
        error "Cannot find setup timing summary for $clock"
    }
    if {[string trim $endpoints] != 0} {
        error "$clock has $endpoints setup violations (TNS $tns); bitstream is not ready for use"
    }
    puts "$clock data-path setup: PASS"
}
