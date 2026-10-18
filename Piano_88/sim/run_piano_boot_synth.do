onerror {quit -code 1 -f}
if {![file isdirectory work_piano_boot_synth]} {vlib work_piano_boot_synth}
vlog -work work_piano_boot_synth D:/Gowin/Gowin_V1.9.12.03_x64/IDE/simlib/gw5a/prim_sim.v ../impl/gwsynthesis/Piano_88.vg sd_card_model.v tb_piano_boot_synth.v
vsim -L work_piano_boot_synth -voptargs=+acc work_piano_boot_synth.tb_piano_boot_synth
onfinish stop
if {[info exists env(PIANO_BOOT_SIM_ACCELERATE)] && $env(PIANO_BOOT_SIM_ACCELERATE) == 1} {
    # Skip idle waits and accelerate SCK; keep receive, CRC, RAM and FAT logic.
    force -freeze /tb_piano_boot_synth/dut/power_on_count 10#65536
    force -freeze {/tb_piano_boot_synth/dut/\g_sd_bank.u_bank /u_sd/power_count} 10#500000
    force -freeze {/tb_piano_boot_synth/dut/\g_sd_bank.u_bank /u_sd/u_spi/divider} 10#62
    puts "Accelerated functional check: POR wait, SD power wait and SPI divider overridden."
}
for {set step 0} {$step < 60} {incr step} {
    run 1 ms
    puts "Boot simulation progress: step [expr {$step + 1}] of 60"
    if {[examine -radix unsigned /tb_piano_boot_synth/passed] == 1} {break}
}
if {[examine -radix unsigned /tb_piano_boot_synth/passed] != 1} {quit -code 1 -f}
quit -code 0 -f
