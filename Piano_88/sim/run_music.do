onerror {quit -code 1 -f}
if {![file isdirectory work]} {vlib work}
vlog ../src/sd_spi_byte.v ../src/sd_spi_reader.v ../src/fat_file_reader.v ../src/wav_pcm_reader.v ../src/button_debounce.v ../src/pt8211_tx.v ../sd_card/src/sd_music_player.v sd_card_model.v tb_sd_music.v tb_wav_pcm_reader.v tb_fat_full_music.v
vsim work.tb_sd_music
onfinish stop
run -all
if {[examine -radix unsigned /tb_sd_music/passed] != 1} {quit -code 1 -f}
quit -sim
vsim work.tb_wav_pcm_reader
onfinish stop
run -all
if {[examine -radix unsigned /tb_wav_pcm_reader/passed] != 1} {quit -code 1 -f}
quit -sim
vsim work.tb_fat_full_music
onfinish stop
run -all
if {[examine -radix unsigned /tb_fat_full_music/passed] != 1} {quit -code 1 -f}
quit -code 0 -f
