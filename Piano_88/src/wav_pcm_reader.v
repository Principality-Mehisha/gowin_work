// RIFF/WAVE parser for PCM16 mono at the existing piano sample rate.
// Skips unknown chunks and their word padding; streams little-endian samples.
module wav_pcm_reader #(
    parameter integer SAMPLE_RATE = 16276
) (
    input wire clk,
    input wire rst_n,
    input wire [7:0] data,
    input wire valid,
    output wire ready,
    input wire [31:0] file_size,
    input wire file_done,
    output reg signed [15:0] pcm,
    output reg pcm_valid,
    input wire pcm_ready,
    output reg format_ok,
    output reg audio_end,
    output reg [3:0] error_code
);
    localparam [3:0] RIFF = 0, CHUNK = 1, CHUNK_CHECK = 2,
        FORMAT = 3, FORMAT_CHECK = 4, SKIP = 5, PAD = 6,
        PCM_LOW = 7, PCM_HIGH = 8, PCM_HOLD = 9, DRAIN = 10, FAILED = 11;
    reg [3:0] state;
    reg [3:0] index;
    reg [31:0] riff_size, chunk_id, chunk_size, left, bytes_seen;
    reg odd_chunk;
    reg [15:0] encoding, channels, alignment, bits;
    reg [31:0] rate, byte_rate;
    reg [7:0] low_byte;
    wire take = valid && ready;
    assign ready = state == RIFF || state == CHUNK || state == FORMAT
                || state == SKIP || state == PAD || state == PCM_LOW
                || state == PCM_HIGH || state == DRAIN;
    task fail;
        input [3:0] code;
        begin
            error_code <= code;
            pcm_valid <= 0;
            state <= FAILED;
        end
    endtask
    task next_header;
        begin
            index <= 0;
            chunk_id <= 0;
            chunk_size <= 0;
            state <= CHUNK;
        end
    endtask
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= RIFF;
            index <= 0;
            riff_size <= 0;
            chunk_id <= 0;
            chunk_size <= 0;
            left <= 0;
            bytes_seen <= 0;
            odd_chunk <= 0;
            encoding <= 0;
            channels <= 0;
            alignment <= 0;
            bits <= 0;
            rate <= 0;
            byte_rate <= 0;
            low_byte <= 0;
            pcm <= 0;
            pcm_valid <= 0;
            format_ok <= 0;
            audio_end <= 0;
            error_code <= 0;
        end else begin
            if (take)
                bytes_seen <= bytes_seen + 1'b1;
            if (file_done && !audio_end && error_code == 0
                && !(state == PCM_HOLD && left == 0)) begin
                fail(4);
            end else begin
                case (state)
                    RIFF: if (take) begin
                        if ((index == 0 && data != "R") || (index == 1 && data != "I")
                            || (index == 2 && data != "F") || (index == 3 && data != "F")
                            || (index == 8 && data != "W") || (index == 9 && data != "A")
                            || (index == 10 && data != "V") || (index == 11 && data != "E"))
                            fail(1);
                        else if (index == 11) begin
                            if ({1'b0, riff_size} + 33'd8 > {1'b0, file_size}
                                || riff_size < 36)
                                fail(1);
                            else
                                next_header();
                        end else begin
                            if (index >= 4 && index <= 7)
                                riff_size[(index-4)*8 +: 8] <= data;
                            index <= index + 1'b1;
                        end
                    end
                    CHUNK: if (take) begin
                        if (index < 4)
                            chunk_id[index*8 +: 8] <= data;
                        else
                            chunk_size[(index-4)*8 +: 8] <= data;
                        if (index == 7)
                            state <= CHUNK_CHECK;
                        else
                            index <= index + 1'b1;
                    end
                    CHUNK_CHECK: begin
                        left <= chunk_size;
                        odd_chunk <= chunk_size[0];
                        index <= 0;
                        if ({1'b0, bytes_seen} + {1'b0, chunk_size} + chunk_size[0]
                            > {1'b0, riff_size} + 33'd8) begin
                            fail(1);
                        end else if (chunk_id == 32'h20746d66) begin
                            if (chunk_size < 16 || format_ok)
                                fail(2);
                            else
                                state <= FORMAT;
                        end else if (chunk_id == 32'h61746164) begin
                            if (!format_ok || chunk_size == 0 || chunk_size[0])
                                fail(3);
                            else
                                state <= PCM_LOW;
                        end else if (chunk_size == 0)
                            next_header();
                        else begin
                            state <= SKIP;
                        end
                    end
                    FORMAT: if (take) begin
                        case (index)
                            0,1: encoding[index*8 +: 8] <= data;
                            2,3: channels[(index-2)*8 +: 8] <= data;
                            4,5,6,7: rate[(index-4)*8 +: 8] <= data;
                            8,9,10,11: byte_rate[(index-8)*8 +: 8] <= data;
                            12,13: alignment[(index-12)*8 +: 8] <= data;
                            14,15: bits[(index-14)*8 +: 8] <= data;
                        endcase
                        left <= left - 1'b1;
                        if (index == 15)
                            state <= FORMAT_CHECK;
                        else
                            index <= index + 1'b1;
                    end
                    FORMAT_CHECK: begin
                        if (encoding != 1 || channels != 1 || bits != 16
                            || alignment != 2 || rate != SAMPLE_RATE || byte_rate != SAMPLE_RATE*2)
                            fail(2);
                        else begin
                            format_ok <= 1;
                            if (left != 0) begin
                                state <= SKIP;
                            end else if (odd_chunk)
                                state <= PAD;
                            else
                                next_header();
                        end
                    end
                    SKIP: if (take) begin
                        left <= left - 1'b1;
                        if (left == 1) begin
                            if (odd_chunk)
                                state <= PAD;
                            else
                                next_header();
                        end
                    end
                    PAD: if (take) next_header();
                    PCM_LOW: if (take) begin
                        low_byte <= data;
                        left <= left - 1'b1;
                        state <= PCM_HIGH;
                    end
                    PCM_HIGH: if (take) begin
                        pcm <= {data, low_byte};
                        pcm_valid <= 1;
                        left <= left - 1'b1;
                        state <= PCM_HOLD;
                    end
                    PCM_HOLD: if (pcm_ready) begin
                        pcm_valid <= 0;
                        if (left == 0) begin
                            audio_end <= 1;
                            state <= DRAIN;
                        end else
                            state <= PCM_LOW;
                    end
                    DRAIN: state <= DRAIN;
                    FAILED: state <= FAILED;
                    default: fail(1);
                endcase
            end
        end
    end
endmodule
