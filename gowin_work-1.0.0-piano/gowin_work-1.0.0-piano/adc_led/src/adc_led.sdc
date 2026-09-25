//======================================================================
//  Timing constraints for adc_led
//  Board clock: 50 MHz crystal on pin V22  ->  period 20 ns
//======================================================================
create_clock -name clk -period 20 -waveform {0 10} [get_ports {clk}]

// The ADC strobes (adc_dv / SPI clock) are asynchronous to clk and are
// resynchronised inside the design; no input delay is required for this
// slow, human-visible application.
