onfinish stop
add wave -divider "LIVE EVENTS"
add wave /tb_synth/clk /tb_synth/tick /tb_synth/valid /tb_synth/ready /tb_synth/note_on
add wave -radix unsigned /tb_synth/note /tb_synth/dynamics /tb_synth/pitch
add wave /tb_synth/stop_all
add wave -divider "A4 PHASE / ADSR"
add wave -radix hex /tb_synth/phase_a4
add wave -radix unsigned /tb_synth/state_a4 /tb_synth/envelope_a4
add wave -radix unsigned /tb_synth/release_a4
add wave -divider "SHARED REAL-TIME DATAPATH"
add wave -radix unsigned /tb_synth/dut/voice /tb_synth/dut/harmonic
add wave -radix hex /tb_synth/dut/phase_h /tb_synth/dut/voice_step
add wave -radix decimal /tb_synth/dut/interpolated /tb_synth/dut/harmonic_sum
add wave -divider "MIX / LIMIT / PCM"
add wave -radix unsigned /tb_synth/active
add wave -radix decimal /tb_synth/mix /tb_synth/pcm
add wave /tb_synth/mix_valid /tb_synth/pcm_valid /tb_synth/limiting
add wave /tb_synth/saturated /tb_synth/deadline
run -all
wave zoom full
