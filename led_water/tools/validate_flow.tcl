#=====================================================================
#  validate_flow.tcl - prove the project is valid end to end.
#
#  Runs GowinSynthesis + place&route + bitstream generation in a THROWAWAY
#  COPY of the project, so the delivered project folder stays free of
#  build artifacts (impl/gwsynthesis, impl/pnr, .fs ...).
#
#  Usage:
#    1) copy the project folder to a scratch location, e.g.
#         robocopy led_water _verify\led_water /E
#    2) point PROJ below at the copy
#    3) "D:\...\IDE\bin\gw_sh.exe" < tools/validate_flow.tcl
#
#  Expected tail:  SYN OK / PNR OK / DONE
#  The .fs bitstream appears in <copy>/impl/pnr/.
#=====================================================================

set PROJ {C:/Users/30415/Desktop/gowin_work/_verify/led_water/led_water.gprj}

puts "== open_project =="
if {[catch {open_project $PROJ} e]} { puts "OPEN FAILED: $e"; exit 1 }
puts "OPEN OK"

puts "== run syn =="
if {[catch {run syn} e]} { puts "SYN FAILED: $e"; exit 1 }
puts "SYN OK"

puts "== run pnr =="
if {[catch {run pnr} e]} { puts "PNR FAILED: $e"; exit 1 }
puts "PNR OK"

puts "== DONE =="
exit 0
