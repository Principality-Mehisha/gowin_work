#=====================================================================
#  make_project.tcl - regenerate the led_water Gowin project from scratch
#
#  Target device : GW5AT-60B / GW5AT-LV60PG484AC1/I0  (id gw5at60b-002)
#
#  Usage (from the project's parent directory):
#     "D:\Gowin\Gowin_V1.9.12.03_x64\IDE\bin\gw_sh.exe" < tools/make_project.tcl
#
#  Notes:
#   * -dir must NOT include the project name. create_project appends the
#     project name itself; passing "C:/x/led_water" yields a doubly nested
#     "C:/x/led_water/led_water/" layout.
#   * Do NOT call "saveto <name>.gprj": saveto writes a Tcl replay script,
#     which would overwrite the XML .gprj that create_project already
#     produced. The XML .gprj is what Gowin IDE / gw_sh actually open.
#   * File paths in the generated .gprj are absolute; the delivered .gprj
#     has been normalized to relative paths (src/...) so the folder can be
#     moved or copied.
#=====================================================================

# --- EDIT THIS: absolute path of the project folder -----------------
set proj_dir {C:/Users/30415/Desktop/gowin_work/led_water}
# --------------------------------------------------------------------

set proj_name led_water
set gen_dir   $proj_dir/_gen

puts "== create_project =="
create_project -name $proj_name -dir $gen_dir -pn {GW5AT-LV60PG484AC1/I0} -device_version B -force

puts "== add_file (rtl / cst / sdc) =="
add_file $proj_dir/src/led_water.v
add_file $proj_dir/src/led_water.cst
add_file $proj_dir/src/led_water.sdc

puts "== set_option =="
set_option -top_module led_water

puts "== generated: $gen_dir/$proj_name/$proj_name.gprj =="
puts "== copy that .gprj (and its impl/) into $proj_dir =="
exit
