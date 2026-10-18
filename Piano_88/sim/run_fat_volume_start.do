onerror {quit -code 1 -f}
if {![file isdirectory work]} {vlib work}
vlog ../src/fat_file_reader.v tb_fat_volume_start.v
vsim work.tb_fat_volume_start
onfinish stop
run -all
if {[examine -radix unsigned /tb_fat_volume_start/passed] != 1} {quit -code 1 -f}
quit -code 0 -f
