`include "ringtone_config.vh"
// Experimental recorded reference: stereo IMA ADPCM ROM -> signed 16-bit PCM.
// Samples are generated after sample_tick for the following complete DAC frame.
module ringtone_pcm_player #(
    parameter ROM_PREFIX = "src/rom/ringtone_bank",
    parameter HEADER_FILE = "src/rom/ringtone_headers.hex",
    parameter STEP_FILE = "src/rom/ima_steps.hex",
    parameter integer FRAME_COUNT = `RINGTONE_FRAMES,
    parameter integer BLOCK_FRAMES = `RINGTONE_BLOCK_FRAMES,
    parameter integer HEADER_COUNT = `RINGTONE_HEADER_COUNT,
    parameter integer BANK_COUNT = `RINGTONE_BANK_COUNT
) (
    input wire clk, reset_n, sample_tick, toggle,
    output reg active,
    output reg signed [15:0] pcm_left, pcm_right,
    output reg pcm_valid
);
    localparam integer ADDRESS_BITS = $clog2(FRAME_COUNT + 1);
    localparam integer BLOCK_BITS = $clog2(HEADER_COUNT + 1);
    reg [ADDRESS_BITS-1:0] frame_position;
    reg [BLOCK_BITS-1:0] block_index;
    reg [10:0] block_position;
    reg [1:0] state;
    reg last_pending;
    reg [47:0] headers [0:HEADER_COUNT-1];
    reg [47:0] header_data;
    reg [15:0] step_table [0:88];
    wire [7:0] bank_sample [0:BANK_COUNT-1];
    wire [7:0] codes = bank_sample[frame_position >> 15];
    reg [7:0] code_reg;
    reg signed [15:0] predictor_left, predictor_right;
    reg [6:0] index_left, index_right;
    reg [15:0] step_left, step_right;

    genvar bank;
    generate for (bank=0; bank<BANK_COUNT; bank=bank+1) begin: pcm_banks
        reg [7:0] data [0:32767];
        reg [7:0] value;
        // Each file is one complete 32 KiB bank, including padded final data.
        initial $readmemh({ROM_PREFIX, 8'd48 + bank[7:0], ".hex"}, data);
        always @(posedge clk) value <= data[frame_position[14:0]];
        assign bank_sample[bank] = value;
    end endgenerate

    initial begin
        $readmemh(HEADER_FILE, headers);
        $readmemh(STEP_FILE, step_table);
    end
    always @(posedge clk) begin
        header_data <= headers[block_index];
        step_left <= step_table[index_left];
        step_right <= step_table[index_right];
        if (state == 1) code_reg <= codes;
    end

    function [6:0] update_index;
        input [6:0] old_index;
        input [3:0] code;
        integer value;
        begin
            case (code[2:0])
                4: value = old_index + 2;
                5: value = old_index + 4;
                6: value = old_index + 6;
                7: value = old_index + 8;
                default: value = old_index - 1;
            endcase
            if (value < 0) update_index = 0;
            else if (value > 88) update_index = 88;
            else update_index = value[6:0];
        end
    endfunction

    function signed [15:0] decode;
        input signed [15:0] predictor;
        input [15:0] step;
        input [3:0] code;
        reg [19:0] magnitude;
        reg signed [19:0] next_predictor;
        begin
            // IMA WAV uses one rounded product, matching FFmpeg's decoder.
            magnitude = {4'd0, step} * {16'd0, code[2:0], 1'b1};
            next_predictor = $signed(predictor);
            if (code[3]) next_predictor = next_predictor - $signed(magnitude >> 3);
            else next_predictor = next_predictor + $signed(magnitude >> 3);
            if (next_predictor > 32767) decode = 32767;
            else if (next_predictor < -32768) decode = -32768;
            else decode = next_predictor[15:0];
        end
    endfunction
    wire signed [15:0] decoded_left = decode(predictor_left, step_left, code_reg[3:0]);
    wire signed [15:0] decoded_right = decode(predictor_right, step_right, code_reg[7:4]);

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            active <= 0; pcm_left <= 0; pcm_right <= 0; pcm_valid <= 0;
            frame_position <= 0; block_index <= 0; block_position <= 0;
            predictor_left <= 0; predictor_right <= 0;
            index_left <= 0; index_right <= 0; state <= 0; last_pending <= 0;
        end else begin
            pcm_valid <= 0;
            if (toggle) begin
                active <= !active;
                frame_position <= 0; block_index <= 0; block_position <= 0;
                pcm_left <= 0; pcm_right <= 0; state <= 0; last_pending <= 0;
                index_left <= 0; index_right <= 0;
                predictor_left <= 0; predictor_right <= 0;
            end else case (state)
                0: if (sample_tick && active) begin
                    if (last_pending) begin
                        active <= 0; pcm_left <= 0; pcm_right <= 0;
                        last_pending <= 0;
                    end else state <= 1;
                end
                1: state <= 2;
                2: begin
                    if (block_position == 0) begin
                        predictor_left <= header_data[15:0];
                        predictor_right <= header_data[39:24];
                        index_left <= header_data[22:16];
                        index_right <= header_data[46:40];
                        pcm_left <= frame_position == 0 ? 16'sd0 : header_data[15:0];
                        pcm_right <= frame_position == 0 ? 16'sd0 : header_data[39:24];
                    end else begin
                        predictor_left <= decoded_left;
                        predictor_right <= decoded_right;
                        index_left <= update_index(index_left, code_reg[3:0]);
                        index_right <= update_index(index_right, code_reg[7:4]);
                        pcm_left <= decoded_left; pcm_right <= decoded_right;
                    end
                    if (frame_position == FRAME_COUNT-1) begin
                        pcm_left <= 0; pcm_right <= 0;
                        last_pending <= 1;
                    end else begin
                        frame_position <= frame_position + 1'b1;
                        if (block_position == BLOCK_FRAMES-1) begin
                            block_position <= 0;
                            block_index <= block_index + 1'b1;
                        end else block_position <= block_position + 1'b1;
                    end
                    pcm_valid <= 1; state <= 0;
                end
                default: state <= 0;
            endcase
        end
    end
endmodule
