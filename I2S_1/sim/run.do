vlib work
vlog ../src/I2S_1_communication.v ../src/I2S_1.v tb_I2S_1.v
vsim work.tb_I2S_1
run -all
quit -f
