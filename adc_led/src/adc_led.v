//======================================================================
//  Module   : adc_led
//  Function : ADC -> 8-bit binary LED display  (ADC 采样值二进制显示)
//  Target   : Gowin GW5AT-60B / GW5AT-LV60PG484AC1/I0
//  Board    : Sipeed Tang Mega 60K (TANG MEGA NEO dock board)
//
//  Behaviour (per requirement):
//    The ADC result is quantised into the eight equal segments 0..7 and the
//    segment number is written on the three lowest LEDs as a plain binary
//    number.  LED7..LED3 stay dark.
//
//      ADC input (of full scale)   level   LED2 LED1 LED0   active LEDs
//      -----------------------------------------------------------------
//      0      .. < 1/8 FS            0      0    0    0     all off
//      1/8 FS .. < 2/8 FS            1      0    0    1     LED0
//      2/8 FS .. < 3/8 FS            2      0    1    0     LED1
//      3/8 FS .. < 4/8 FS            3      0    1    1     LED0 + LED1
//      4/8 FS .. < 5/8 FS            4      1    0    0     LED2
//      5/8 FS .. < 6/8 FS            5      1    0    1     LED2 + LED0
//      6/8 FS .. < 7/8 FS            6      1    1    0     LED2 + LED1
//      7/8 FS .. FS                  7      1    1    1     LED2 + LED1 + LED0
//
//    So a dark input lights nothing, and the three LEDs count 0,1,2,3,4,5,6,7
//    in binary as the analogue input rises: LED0 is the LSB (toggles every
//    level), LED1 toggles every 2 levels, LED2 every 4 levels.
//
//    To use all eight LEDs as a bar graph (one more LED lit per level)
//    instead, swap the `decoded` assignment near the bottom of this file.
//
//  Clock    : 50 MHz crystal, pin V22 (bank 7)
//  Reset    : rstn, active LOW; the dock board has no pull-up on this pin,
//             so the constraint enables the FPGA internal pull-up.
//======================================================================
`timescale 1ns / 1ps

module adc_led #(
    // Resolution of the converter feeding adc_data.  The sample is normalised
    // into a uniform 8-bit space (top 8 bits when ADC_BITS > 8, left justified
    // when ADC_BITS < 8) so the thresholds below are resolution independent.
    parameter ADC_BITS  = 8,
    // Reject sample changes smaller than HYST 8-bit LSBs.  HYST = 0 follows
    // the ADC exactly; HYST = 2 suppresses +/-1 LSB flicker.
    parameter HYST      = 2,
    // 1 = LEDs are active LOW (pin low lights the LED) - true for this board,
    // 0 = active HIGH.
    parameter ACTIVE_LOW = 1
)(
    input                     clk,       // 50 MHz system clock
    input                     rstn,      // asynchronous reset, active LOW
    input  [ADC_BITS-1:0]     adc_data,  // ADC conversion result
    input                     adc_dv,    // 1-clock pulse: adc_data is valid
    output reg [7:0]          led_o      // 8 x LED
);

    //------------------------------------------------------------------
    // 1. Normalise the sample into the 8-bit range used by the thresholds.
    //------------------------------------------------------------------
    wire [7:0] level = (ADC_BITS >= 8) ? adc_data[ADC_BITS-1 -: 8]
                                       : (adc_data << (8 - ADC_BITS));

    //------------------------------------------------------------------
    // 2. Sample register with hysteresis, so an ADC output sitting exactly on
    //    a segment boundary does not make the LEDs flicker.
    //------------------------------------------------------------------
    reg [7:0] lvl_r;

    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            lvl_r <= 8'd0;
        else if (adc_dv)
            lvl_r <= (level >= lvl_r) ? ((level - lvl_r >= HYST) ? level : lvl_r)
                                      : ((lvl_r - level >= HYST) ? level : lvl_r);
    end

    //------------------------------------------------------------------
    // 3. Quantise into the eight segments.  With an 8-bit sample full scale
    //    is 256, so each segment is 32 wide and the segment number is
    //    simply the top three bits of the sample.
    //------------------------------------------------------------------
    wire [2:0] seg = lvl_r[7:5];

    //------------------------------------------------------------------
    // 4. Display decode.
    //    Default: the 3-bit segment number on LED2..LED0, LED7..LED3 dark.
    //    Alternative (bar graph, one more LED lit per segment):
    //      wire [7:0] decoded = { seg[2], seg[2]&seg[1], seg[2]&seg[0],
    //                             seg[2]|seg[1], seg[1]&seg[0],
    //                             seg[1], seg[0], 1'b0 };
    //------------------------------------------------------------------
    wire [7:0] decoded = {5'b00000, seg};

    //------------------------------------------------------------------
    // 5. Registered output with polarity selection.
    //------------------------------------------------------------------
    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            led_o <= ACTIVE_LOW ? 8'hFF : 8'h00;
        else
            led_o <= ACTIVE_LOW ? ~decoded : decoded;
    end

endmodule
