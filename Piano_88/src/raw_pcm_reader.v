// Headerless signed PCM16 little-endian mono. The player fixes the sample rate.
module raw_pcm_reader (
    input wire clk,
    input wire rst_n,
    input wire [7:0] data,
    input wire valid,
    output wire ready,
    input wire file_found,
    input wire [31:0] file_size,
    input wire file_done,
    output reg signed [15:0] pcm,
    output reg pcm_valid,
    input wire pcm_ready,
    output reg format_ok,
    output reg audio_end,
    output reg [3:0] error_code
);
    localparam [2:0] WAIT_FILE = 0, LOW_BYTE = 1, HIGH_BYTE = 2,
        HOLD_SAMPLE = 3, WAIT_EOF = 4, FINISHED = 5, FAILED = 6;
    reg [2:0] state;
    reg [7:0] low_byte;
    reg [31:0] remaining;
    reg eof_seen;
    wire take = valid && ready;
    assign ready = state == LOW_BYTE || state == HIGH_BYTE;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= WAIT_FILE;
            low_byte <= 0;
            remaining <= 0;
            eof_seen <= 0;
            pcm <= 0;
            pcm_valid <= 0;
            format_ok <= 0;
            audio_end <= 0;
            error_code <= 0;
        end else begin
            if (file_done)
                eof_seen <= 1;
            // EOF may coincide with accepting the final high byte or holding
            // the final sample while the playback FIFO applies backpressure.
            if (file_done && error_code == 0 && state != FINISHED
                && !(remaining == 0 && (state == HOLD_SAMPLE || state == WAIT_EOF))
                && !(take && remaining == 1 && state == HIGH_BYTE)) begin
                error_code <= 4;
                pcm_valid <= 0;
                state <= FAILED;
            end else case (state)
                WAIT_FILE: if (file_found) begin
                    if (file_size == 0 || file_size[0]) begin
                        error_code <= 3;
                        state <= FAILED;
                    end else begin
                        remaining <= file_size;
                        format_ok <= 1;
                        state <= LOW_BYTE;
                    end
                end
                LOW_BYTE: if (take) begin
                    low_byte <= data;
                    remaining <= remaining - 1'b1;
                    state <= HIGH_BYTE;
                end
                HIGH_BYTE: if (take) begin
                    pcm <= {data, low_byte};
                    pcm_valid <= 1;
                    remaining <= remaining - 1'b1;
                    state <= HOLD_SAMPLE;
                end
                HOLD_SAMPLE: if (pcm_ready) begin
                    pcm_valid <= 0;
                    state <= remaining == 0 ? WAIT_EOF : LOW_BYTE;
                end
                WAIT_EOF: if (eof_seen || file_done) begin
                    audio_end <= 1;
                    state <= FINISHED;
                end
                default: state <= state;
            endcase
        end
    end
endmodule
