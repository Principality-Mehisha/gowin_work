onerror {quit -code 1 -f}
if {![file isdirectory work]} {vlib work}
vlog ../src/sd_spi_byte.v ../src/sd_spi_reader.v ../sd_card/src/sd_card_probe.v sd_card_model.v tb_sd_spi_reader.v tb_sd_card_probe.v
vsim work.tb_sd_spi_reader
onfinish stop
run -all
if {[examine -radix unsigned /tb_sd_spi_reader/passed] != 1} {quit -code 1 -f}
quit -sim
vsim work.tb_sd_card_probe
onfinish stop
run -all
if {[examine -radix unsigned /tb_sd_card_probe/passed] != 1} {quit -code 1 -f}
quit -code 0 -f
