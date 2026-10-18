onerror {quit -code 1 -f}
if {![file isdirectory work_fat_synth]} {vlib work_fat_synth}
vlog -work work_fat_synth D:/Gowin/Gowin_V1.9.12.03_x64/IDE/simlib/gw5a/prim_sim.v ../impl/gwsynthesis/Piano_88.vg tb_fat_synth.v
vsim -L work_fat_synth -voptargs=+acc work_fat_synth.tb_fat_synth
onfinish stop
run -all
if {[examine -radix unsigned /tb_fat_synth/passed] != 1} {quit -code 1 -f}
quit -code 0 -f
