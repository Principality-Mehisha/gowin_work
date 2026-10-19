// PT8211 LSBJ: WS=0 right, WS=1 left; MSB first, change on BCK falling.
// 153.6 MHz / (2 * 50 * 32) = 48000 stereo frames/s.
module pt8211_tx #(
    parameter integer BCK_HALF_DIV = 50,
    parameter integer AMP_START_CYCLES = 7_680_000
) (
    input wire clk, reset_n, mute,
    input wire signed [15:0] pcm,
    output reg sample_tick,
    output reg HP_BCK, HP_WS, HP_DIN,
    output wire PA_EN
);
    reg [23:0] startup_count;
    reg amp_ready;
    reg [7:0] divider;
    reg [4:0] bit_index;
    reg [15:0] latched_pcm;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            startup_count <= 0;
            amp_ready <= 0;
        end else if (!amp_ready) begin
            if (startup_count == AMP_START_CYCLES - 1)
                amp_ready <= 1;
            else
                startup_count <= startup_count + 1'b1;
        end
    end
    assign PA_EN = ~(reset_n & amp_ready);

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            divider <= 0;
            bit_index <= 31;
            latched_pcm <= 0;
            HP_BCK <= 0;
            HP_WS <= 0;
            HP_DIN <= 0;
            sample_tick <= 0;
        end else begin
            sample_tick <= 0;
            if (divider == BCK_HALF_DIV - 1) begin
                divider <= 0;
                HP_BCK <= ~HP_BCK;
                if (HP_BCK) begin
                    if (bit_index == 31) begin
                        latched_pcm <= mute ? 16'd0 : pcm;
                        HP_DIN <= mute ? 1'b0 : pcm[15];
                        HP_WS <= 0;
                        bit_index <= 0;
                        sample_tick <= 1;
                    end else begin
                        bit_index <= bit_index + 1'b1;
                        if (bit_index == 15) begin
                            HP_WS <= 1;
                            HP_DIN <= latched_pcm[15];
                        end else if (bit_index < 15)
                            HP_DIN <= latched_pcm[14-bit_index];
                        else
                            HP_DIN <= latched_pcm[30-bit_index];
                    end
                end
            end else
                divider <= divider + 1'b1;
        end
    end
endmodule
