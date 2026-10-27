open_project ddr3_test/ddr3_test.gprj
foreach p {src/ddr3_test.v src/ddr3_bist.v src/ddr3_status.v src/pll_mDRP_intf.v src/ddr3_test.cst src/ddr3_test.sdc} {add_file [file join ddr3_test $p]}
set_option -top_module ddr3_test
set_option -use_ready_as_gpio 1
set_option -use_done_as_gpio 1
exit
