onerror {quit -code 1 -f}
if {![file isdirectory work_score]} {vlib work_score}
vlog -work work_score ../src/piano_sample_map.v ../src/piano_pcm_voice.v ../src/piano_polyphony.v ../src/piano_score_reader.v ../src/piano_score_sequencer.v ../src/piano_score_player.v ../src/sd_spi_byte.v ../src/sd_spi_reader.v ../src/fat_file_reader.v ../src/button_debounce.v ../src/pt8211_score_tx.v sd_card_model.v tb_piano_polyphony.v tb_score_full.v tb_score_player.v
foreach bench {tb_piano_polyphony tb_score_full tb_score_player} {
    vsim work_score.$bench
    onfinish stop
    run -all
    if {[examine -radix unsigned /$bench/passed] != 1} {quit -code 1 -f}
    quit -sim
}
quit -code 0 -f
