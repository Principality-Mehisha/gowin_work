onerror {quit -code 1 -f}
if {![file isdirectory work_piano_music]} {vlib work_piano_music}
vlog -work work_piano_music ../src/sd_spi_byte.v ../src/sd_spi_reader.v ../src/fat_file_reader.v ../src/raw_pcm_reader.v ../src/wav_pcm_reader.v ../src/button_debounce.v ../src/pt8211_tx.v ../sd_card/src/sd_music_player.v sd_card_model.v tb_sd_music.v tb_sd_piano_music.v tb_raw_pcm_reader.v tb_piano_bin_full.v
foreach bench {tb_raw_pcm_reader tb_sd_piano_music tb_piano_bin_full tb_sd_music} {
    vsim work_piano_music.$bench
    onfinish stop
    run -all
    if {[examine -radix unsigned /$bench/passed] != 1} {quit -code 1 -f}
    quit -sim
}
quit -code 0 -f
