onerror {quit -code 1 -f}
if {![file isdirectory work]} {vlib work}
vlog ../src/button_debounce.v ../src/piano_sample_map.v ../src/piano_pcm_voice.v ../src/pt8211_tx.v ../src/sd_spi_byte.v ../src/sd_spi_reader.v ../src/fat_file_reader.v ../src/sd_piano_bank_reader.v ../src/piano_88.v tb_pt8211_tx.v tb_piano_88.v tb_pcm_voice.v
vsim work.tb_pt8211_tx
onfinish stop
run -all
if {[examine -radix unsigned /tb_pt8211_tx/passed] != 1} {quit -code 1 -f}
quit -sim
vsim work.tb_piano_88
onfinish stop
run -all
if {[examine -radix unsigned /tb_piano_88/passed] != 1} {quit -code 1 -f}
quit -sim
vsim work.tb_pcm_voice
onfinish stop
run -all
if {[examine -radix unsigned /tb_pcm_voice/passed] != 1} {quit -code 1 -f}
quit -code 0 -f
