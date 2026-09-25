# Enumerate valid BGA balls for GW5AT-LV60PG484AC1/I0.
# Strategy: place ALL candidates as IO_LOC for one port in a single tiny design
# and run synthesis+constraint parsing once per chunk; the parser reports every
# unknown ball with "Can't find pad location", so a chunk of N balls costs one
# tool invocation.  We cache the results in valid_balls.txt.
set base {C:/Users/30415/Desktop/gowin_work/_pinprobe}
file mkdir $base/src

set rtl [open $base/src/p.v w]
puts $rtl "module p(input clk, input \[0:0\] a);"
puts $rtl "endmodule"
close $rtl

set rows {A B C D E F G H J K L M N P R T U V W Y AA AB}
set cols {}
for {set i 1} {$i <= 22} {incr i} { lappend cols $i }

set all {}
foreach r $rows { foreach c $cols { lappend all "$r$c" } }
puts "candidate balls: [llength $all]"

set good {}
set chunk {}
set idx 0
foreach ball $all {
    lappend chunk $ball
    incr idx
    if {[llength $chunk] >= 40 || $idx == [llength $all]} {
        # write a constraint file that constrains every ball in the chunk
        set f [open $base/src/p.cst w]
        puts $f "IO_LOC \"clk\" V22;"
        puts $f "IO_PORT \"clk\" IO_TYPE=LVCMOS33 PULL_MODE=NONE BANK_VCCIO=3.3;"
        set i 0
        foreach b $chunk {
            puts $f "IO_LOC \"a\[$i\]\" $b;"
            puts $f "IO_PORT \"a\[$i\]\" IO_TYPE=LVCMOS33 PULL_MODE=NONE BANK_VCCIO=3.3;"
            incr i
        }
        close $f
        # the RTL port must be wide enough; regenerate for the chunk size
        set topidx [expr {[llength $chunk]-1}]
        set rtl [open $base/src/p.v w]
        puts $rtl "module p(input clk, input \[0:$topidx\] a);"
        puts $rtl "endmodule"
        close $rtl

        create_project -name p -dir $base/gen -pn {GW5AT-LV60PG484AC1/I0} -device_version B -force
        add_file $base/src/p.v
        add_file $base/src/p.cst
        set_option -top_module p
        catch {run all} err
        catch {close_project}

        # parse which balls were rejected
        set rejected {}
        foreach line [split $err "\n"] {
            if {[regexp {Can't find pad location '([A-Z0-9]+)'} $line -> bad]} {
                lappend rejected $bad
            }
        }
        foreach b $chunk {
            if {[lsearch -exact $rejected $b] < 0} { lappend good $b }
        }
        puts "  chunk $idx done; good so far [llength $good]"
        set chunk {}
    }
}

set f [open $base/valid_balls.txt w]
foreach b $good { puts $f $b }
close $f
puts "VALID COUNT: [llength $good]"
exit
