//======================================================================
//  Module   : led_water
//  Function : 8-bit flowing LED (running light / "流水灯")
//  Target   : Gowin GW5AT-60B  (GW5AT-LV60PG484AC1/I0)
//  Clock    : 50 MHz crystal on the board (adjust CNT_MAX for other freq)
//
//  Behaviour:
//    led_o[0] -> led_o[7] lights up one at a time and the lit position
//    rotates left continuously, i.e. the classic "flowing water" effect.
//    LED is active LOW (0 = lit) on most Gowin dev boards; if your board
//    is active HIGH, invert led_o or swap the reset value below.
//======================================================================
`timescale 1ns / 1ps

module led_water (
    input             clk,    // system clock, e.g. 50 MHz
    input             rstn,   // asynchronous reset, active LOW
    output reg [7:0]  led_o   // 8 x LED, active LOW
);

    //------------------------------------------------------------------
    // 0.2 s time base  ->  50_000_000 * 0.2 = 10_000_000 counts
    //    Change CNT_MAX if your input clock frequency differs.
    //------------------------------------------------------------------
    parameter CLK_FREQ = 26'd50_000_000; // input clock in Hz
    parameter STEP_HZ  = 26'd5;          // flow speed in Hz (5 => 0.2s/step)
    parameter CNT_MAX  = CLK_FREQ / STEP_HZ;

    reg [25:0] cnt;
    wire       tick;

    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            cnt <= 26'd0;
        else if (cnt >= CNT_MAX - 26'd1)
            cnt <= 26'd0;
        else
            cnt <= cnt + 26'd1;
    end

    assign tick = (cnt >= CNT_MAX - 26'd1);

    //------------------------------------------------------------------
    // Flow register: one hot pattern rotating left.
    //------------------------------------------------------------------
    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            led_o <= 8'b1111_1110;      // LED0 lit (active low)
        else if (tick)
            led_o <= {led_o[6:0], led_o[7]};  // rotate left
    end

endmodule
