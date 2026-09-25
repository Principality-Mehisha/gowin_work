//======================================================================
//  Timing constraints for adc_led
//  Board clock: 50 MHz crystal on pin V22  ->  period 20 ns
//======================================================================
create_clock -name clk -period 20 -waveform {0 10} [get_ports {clk}]

// The Gowin ADC hard macro and its request/ready handshake use this clock.
// ADCVP/ADCVN are dedicated analogue balls, not timed digital input ports.
