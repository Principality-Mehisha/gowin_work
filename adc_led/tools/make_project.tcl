#=====================================================================
#  make_project.tcl - (re)generate the adc_led Gowin project
#
#  Target device : GW5AT-60B / GW5AT-LV60PG484AC1/I0  (id gw5at60b-002)
#  Top module    : top
#
#  Usage:
#     "D:\Gowin\Gowin_V1.9.12.03_x64\IDE\bin\gw_sh.exe" tools/make_project.tcl
#
#  Notes:
#   * -dir must NOT include the project name.
#   * Do NOT call "saveto <name>.gprj": saveto writes a Tcl replay script and
#     would overwrite the XML .gprj that create_project produced.
#   * .gprj paths are normalised to relative src/... afterwards so the folder
#     can be moved.
#=====================================================================

set proj_dir  {C:/Users/30415/Desktop/gowin_work/adc_led}
set proj_name adc_led
set gen_dir   $proj_dir/_gen

puts "== create_project =="
create_project -name $proj_name -dir $gen_dir \
    -pn {GW5AT-LV60PG484AC1/I0} -device_version B -force

puts "== add_file =="
add_file $proj_dir/src/top.v
add_file $proj_dir/src/adc_led.v
add_file $proj_dir/src/gowin_adc/gowin_adc.v
add_file $proj_dir/src/adc_led.cst
add_file $proj_dir/src/adc_led.sdc

puts "== set_option =="
set_option -top_module top

puts "== generated: $gen_dir/$proj_name/$proj_name.gprj =="
puts "== copy that .gprj into $proj_dir and normalise its paths =="
exit
