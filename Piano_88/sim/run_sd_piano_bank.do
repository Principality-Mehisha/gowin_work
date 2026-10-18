onerror {quit -code 1 -f}
if {![file isdirectory work]} {vlib work}
vlog ../src/sd_spi_byte.v ../src/sd_spi_reader.v ../src/fat_file_reader.v ../src/sd_piano_bank_reader.v sd_card_model.v tb_sd_piano_bank.v
vsim work.tb_sd_piano_bank
onfinish stop
run -all
if {[examine -radix unsigned /tb_sd_piano_bank/passed] != 1} {quit -code 1 -f}
quit -code 0 -f
