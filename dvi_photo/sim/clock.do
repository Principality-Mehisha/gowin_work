onerror {quit -code 1 -f}
if {![file isdirectory sim/work_clock]} {vlib sim/work_clock}
vlog -work sim/work_clock D:/Gowin/Gowin_V1.9.12.03_x64/IDE/simlib/gw5a/prim_sim.v
vlog -sv -work sim/work_clock src/video_clock.v src/pll_init.v sim/tb_video_clock.v
vsim -lib sim/work_clock tb_video_clock
onfinish stop
run -all
if {[examine -radix unsigned /tb_video_clock/passed] != 1} {quit -code 1 -f}
quit -code 0 -f
