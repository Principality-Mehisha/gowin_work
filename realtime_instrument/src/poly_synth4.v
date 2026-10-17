`timescale 1ns/1ps

module poly_synth4 (
    input  wire               clk,
    input  wire               rst_n,
    input  wire               sample_tick,
    input  wire               event_valid,
    input  wire               event_down,
    input  wire [6:0]         event_note,
    input  wire [1:0]         timbre_select,
    output wire signed [15:0] pcm_o,
    output wire [3:0]         active_mask_o
);
    reg [1:0] alloc_ptr;
    reg [3:0] note_on_pulse;
    reg [3:0] note_off_pulse;
    reg [6:0] note_latched;
    reg [1:0] timbre_latched;
    wire signed [15:0] v0, v1, v2, v3;
    wire a0, a1, a2, a3;
    wire [2:0] select_voice = alloc_ptr;
    reg signed [18:0] sum;
    reg signed [15:0] mixed;

    always @* begin
        sum = v0 + v1 + v2 + v3;
        if (sum > 19'sd32767) mixed = 16'sh7fff;
        else if (sum < -19'sd32768) mixed = 16'sh8000;
        else mixed = sum[15:0];
    end
    assign pcm_o = mixed;
    assign active_mask_o = {a3, a2, a1, a0};

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            alloc_ptr <= 0;
            note_on_pulse <= 0;
            note_off_pulse <= 0;
            note_latched <= 60;
            timbre_latched <= 0;
        end else begin
            note_on_pulse <= 0;
            note_off_pulse <= 0;
            if (event_valid) begin
                note_latched <= event_note;
                timbre_latched <= timbre_select;
                if (event_down) begin
                    note_on_pulse[alloc_ptr] <= 1'b1;
                    alloc_ptr <= alloc_ptr + 1'b1;
                end else begin
                    note_off_pulse[alloc_ptr] <= 1'b1;
                end
            end
        end
    end

    voice_synth #(.VOICE_ID(0)) voice0(
        .clk(clk), .rst_n(rst_n), .sample_tick(sample_tick),
        .note_on(note_on_pulse[0]), .note_off(note_off_pulse[0]),
        .note_i(note_latched), .timbre_i(timbre_latched), .sample_o(v0), .active_o(a0));
    voice_synth #(.VOICE_ID(1)) voice1(
        .clk(clk), .rst_n(rst_n), .sample_tick(sample_tick),
        .note_on(note_on_pulse[1]), .note_off(note_off_pulse[1]),
        .note_i(note_latched), .timbre_i(timbre_latched), .sample_o(v1), .active_o(a1));
    voice_synth #(.VOICE_ID(2)) voice2(
        .clk(clk), .rst_n(rst_n), .sample_tick(sample_tick),
        .note_on(note_on_pulse[2]), .note_off(note_off_pulse[2]),
        .note_i(note_latched), .timbre_i(timbre_latched), .sample_o(v2), .active_o(a2));
    voice_synth #(.VOICE_ID(3)) voice3(
        .clk(clk), .rst_n(rst_n), .sample_tick(sample_tick),
        .note_on(note_on_pulse[3]), .note_off(note_off_pulse[3]),
        .note_i(note_latched), .timbre_i(timbre_latched), .sample_o(v3), .active_o(a3));
endmodule
