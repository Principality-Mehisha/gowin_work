`timescale 1ns/1ps

// Compact wavetable voice used as the first hardware bring-up sound source.
// It is intentionally small so the four-voice path remains easy to extend.
module voice_synth #(
    parameter integer VOICE_ID = 0
) (
    input  wire               clk,
    input  wire               rst_n,
    input  wire               sample_tick,
    input  wire               note_on,
    input  wire               note_off,
    input  wire [6:0]         note_i,
    input  wire [1:0]         timbre_i,
    output reg signed [15:0] sample_o,
    output wire               active_o
);
    reg [31:0] phase;
    reg [6:0] note;
    reg [15:0] level;
    reg gate;
    reg [1:0] timbre;
    reg signed [16:0] shaped;
    reg signed [16:0] scaled;

    function [31:0] note_inc;
        input [6:0] n;
        begin
            case (n)
                7'd60: note_inc = 32'd23012828;
                7'd61: note_inc = 32'd24399486;
                7'd62: note_inc = 32'd25867837;
                7'd63: note_inc = 32'd27424688;
                7'd64: note_inc = 32'd29074730;
                7'd65: note_inc = 32'd30823536;
                7'd66: note_inc = 32'd32677472;
                7'd67: note_inc = 32'd34642772;
                7'd68: note_inc = 32'd36726490;
                7'd69: note_inc = 32'd38936509;
                7'd70: note_inc = 32'd41281787;
                7'd71: note_inc = 32'd43772282;
                7'd72: note_inc = 32'd46319236;
                default: note_inc = 32'd23012828;
            endcase
        end
    endfunction

    always @* begin
        shaped = phase[31] ? -$signed({1'b0, phase[30:16]}) :
                              $signed({1'b0, phase[30:16]});
        if (timbre == 2'd1)
            shaped = shaped + (phase[30] ? -$signed({2'b0, phase[29:17]}) :
                                           $signed({2'b0, phase[29:17]}));
        else if (timbre == 2'd2)
            shaped = phase[31] ? -17'sd16384 : 17'sd16384;
        scaled = (shaped * $signed({1'b0, level[15:1]})) >>> 15;
    end

    assign active_o = gate || (level != 0);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            phase <= 0; note <= 60; level <= 0; gate <= 1'b0;
            timbre <= 0; sample_o <= 0;
        end else begin
            if (note_on) begin
                note <= note_i;
                gate <= 1'b1;
                timbre <= timbre_i;
                phase <= 0;
            end
            if (note_off)
                gate <= 1'b0;
            if (sample_tick) begin
                phase <= phase + note_inc(note);
                if (gate) begin
                    if (level < 16'd30000) level <= level + 16'd1200;
                end else if (level > 16'd700) begin
                    level <= level - 16'd700;
                end else begin
                    level <= 0;
                end
                sample_o <= scaled[15:0];
            end
        end
    end
endmodule
