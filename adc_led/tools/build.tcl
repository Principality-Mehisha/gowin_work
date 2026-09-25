#=====================================================================
#  build.tcl - full Gowin flow for adc_led: synthesis + place&route + bitstream
#
#  Usage:
#     "D:\Gowin\Gowin_V1.9.12.03_x64\IDE\bin\gw_sh.exe" tools/build.tcl
#
#  Outputs:
#     impl/gwsynthesis/adc_led_syn.rpt.html   synthesis report
#     impl/pnr/adc_led.rpt.html               place & route report
#     impl/pnr/adc_led.pin.html               pin report
#     impl/pnr/adc_led.fs                      bitstream for the Programmer
#=====================================================================

set proj_dir {C:/Users/30415/Desktop/gowin_work/adc_led}

open_project $proj_dir/adc_led.gprj

puts "===== SYNTHESIS ====="
run all

puts "===== PLACE AND ROUTE ====="
# place & route is part of "run all" for Gowin; report the produced files
set pnr [glob -nocomplain $proj_dir/impl/pnr/*.fs]
puts "bitstream: $pnr"
exit
