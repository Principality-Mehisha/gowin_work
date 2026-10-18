onerror {quit -code 1 -f}
if {![file isdirectory work_bin_led]} {vlib work_bin_led}
vlog -work work_bin_led ../src/sd_spi_byte.v ../src/sd_spi_reader.v ../src/fat_file_reader.v ../sd_card/src/sd_bin_led_test.v sd_card_model.v tb_sd_bin_led_test.v
vsim work_bin_led.tb_sd_bin_led_test
onfinish stop
run -all
if {[examine -radix unsigned /tb_sd_bin_led_test/passed] != 1} {quit -code 1 -f}
quit -code 0 -f
