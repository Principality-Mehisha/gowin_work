`timescale 1ns / 1ps
`include "rom_params.vh"

module croatian_rhapsody_pcm #(
    parameter integer BCK_HALF_DIV = 48,
    parameter integer AMP_START_CYCLES = 2_500_000,
    parameter integer ROM_DEPTH = `PCM_ROM_DEPTH,
    parameter integer SAMPLE_COUNT = `PCM_SAMPLE_COUNT,
    parameter integer ADDR_BITS = `PCM_ADDR_BITS,
    parameter ROM_FILE = "src/croatian_rhapsody.hex"
) (
    input wire sys_clk,
    input wire sys_rst_n,
    output wire [7:0] LEDs,
    output reg HP_BCK,
    output reg HP_WS,
    output reg HP_DIN,
    output wire PA_EN
);
    GSR gsr_inst (.GSRI(1'b1));

    reg [1:0] rst_sync;
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            rst_sync <= 0;
        else
            rst_sync <= {rst_sync[0], 1'b1};
    end
    wire rst_n = rst_sync[1];

    reg [31:0] startup_count;
    reg ready;
    always @(posedge sys_clk) begin
        if (!rst_n) begin
            startup_count <= 0;
            ready <= 0;
        end else if (!ready) begin
            if (startup_count == AMP_START_CYCLES - 1)
                ready <= 1;
            else
                startup_count <= startup_count + 1'b1;
        end
    end
    assign PA_EN = !(rst_n && ready);

    // Synchronous ROM read: this is the block-RAM inference pattern.
    reg [7:0] pcm_rom [0:ROM_DEPTH-1];
    initial $readmemh(ROM_FILE, pcm_rom);
    reg [ADDR_BITS-1:0] rom_addr;
    reg [7:0] rom_byte;
    always @(posedge sys_clk)
        rom_byte <= pcm_rom[rom_addr];

    function [15:0] decode_ulaw;
        input [7:0] code;
        reg [7:0] bits;
        reg [15:0] magnitude;
        begin
            bits = ~code;
            magnitude = ({12'd0, bits[3:0]} << 3) + 16'd132;
            magnitude = (magnitude << bits[6:4]) - 16'd132;
            decode_ulaw = bits[7] ? (16'd0 - magnitude) : magnitude;
        end
    endfunction

    wire [15:0] pcm_word = ready ? decode_ulaw(rom_byte) : 16'd0;
    wire [2:0] led_index = rom_addr >> ((ADDR_BITS > 3) ? ADDR_BITS - 3 : 0);
    assign LEDs = ready ? ~(8'b1 << led_index) : 8'hff;

    reg [15:0] divider;
    reg [4:0] bit_index;
    reg [15:0] frame_sample;

    // 50 MHz / (2*48*32) = 16.276 kHz. DIN/WS change on BCK falling
    // edges and are sampled by PT8211 on the following rising edge.
    always @(posedge sys_clk) begin
        if (!rst_n) begin
            divider <= 0;
            bit_index <= 31;
            HP_BCK <= 0;
            HP_WS <= 0;
            HP_DIN <= 0;
            frame_sample <= 0;
            rom_addr <= 0;
        end else if (divider == BCK_HALF_DIV - 1) begin
            divider <= 0;
            HP_BCK <= ~HP_BCK;
            if (HP_BCK) begin
                if (bit_index == 31) begin
                    bit_index <= 0;
                    HP_WS <= 0;
                    frame_sample <= pcm_word;
                    HP_DIN <= pcm_word[15];
                    if (ready) begin
                        if (rom_addr == SAMPLE_COUNT - 1)
                            rom_addr <= 0;
                        else
                            rom_addr <= rom_addr + 1'b1;
                    end
                end else begin
                    bit_index <= bit_index + 1'b1;
                    if (bit_index == 15) begin
                        HP_WS <= 1;
                        HP_DIN <= frame_sample[15];
                    end else if (bit_index < 15)
                        HP_DIN <= frame_sample[14 - bit_index];
                    else
                        HP_DIN <= frame_sample[30 - bit_index];
                end
            end
        end else begin
            divider <= divider + 1'b1;
        end
    end
endmodule
