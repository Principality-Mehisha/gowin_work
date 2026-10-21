onerror {quit -code 1 -f}
if {![file isdirectory work_score]} {vlib work_score}
vlog -work work_score ../src/adsr_step.v ../src/output_limiter.v ../src/piano_synth.v ../src/marimba_synth.v ../src/dynamics_fixed.v ../src/key_control.v ../src/piano_score_reader.v ../src/piano_score_sequencer.v ../src/piano_score_player.v ../src/sd_spi_byte.v ../src/sd_spi_reader.v ../src/fat_file_reader.v ../src/button_debounce.v ../src/pt8211_score_tx.v sd_card_model.v tb_score_full.v tb_score_player.v
foreach bench {tb_score_full tb_score_player} {
    vsim -voptargs=+acc work_score.$bench
    onfinish stop
    run -all
    if {[examine -radix unsigned /$bench/passed] != 1} {quit -code 1 -f}
    quit -sim
}
quit -code 0 -f
