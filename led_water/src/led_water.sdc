//======================================================================
//  Timing constraints for led_water
//  Adjust -period to match your board's real input clock frequency.
//  10 ns  ==  100 MHz ;  20 ns == 50 MHz ;  40 ns == 25 MHz
//======================================================================
create_clock -name clk -period 20 -waveform {0 10} [get_ports {clk}]
