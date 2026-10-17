`timescale 1ns/1ps

// Digital microphone adapter boundary.
// Replace this block with an I2S/PDM/ADC frontend for the selected microphone.
module mic_pcm_adapter (
    input  wire              clk,
    input  wire              rst_n,
    input  wire signed [15:0] pcm_i,
    input  wire               valid_i,
    output reg  [15:0]       envelope_o,
    output reg                activity_o
);
    reg [15:0] abs_sample;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            envelope_o <= 0;
            activity_o <= 1'b0;
        end else if (valid_i) begin
            abs_sample = pcm_i[15] ? (~pcm_i + 16'd1) : pcm_i;
            envelope_o <= envelope_o - (envelope_o >> 6) + (abs_sample >> 6);
            activity_o <= (envelope_o > 16'd700);
        end
    end
endmodule
