// Adapted from I2S_1/src/I2S_1_communication.v.
// PT8211: 16-bit LSBJ, MSB first, WS=0 right and WS=1 left.
// DIN/WS change on falling BCK; the DAC samples on rising BCK.
// Piano_88 uses half-divisor 48: BCK=520.833 kHz, Fs=16.276041667 kHz.
module pt8211_score_tx #(
    parameter integer BCK_HALF_DIV = 16,
    parameter integer AMP_START_CYCLES = 2_500_000
) (
    input  wire sys_clk,
    input  wire sys_rst_n,
    input  wire signed [15:0] pcm_left,
    input  wire signed [15:0] pcm_right,
    output wire signed [15:0] sample_pcm,
    output reg sample_tick,
    output reg HP_BCK,
    output reg HP_WS,
    output reg HP_DIN,
    output wire PA_EN
);
    reg [31:0] amp_start_cnt;
    reg amp_ready;
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            amp_start_cnt <= 32'd0;
            amp_ready <= 1'b0;
        end else if (!amp_ready) begin
            if (amp_start_cnt == AMP_START_CYCLES - 1)
                amp_ready <= 1'b1;
            else
                amp_start_cnt <= amp_start_cnt + 32'd1;
        end
    end
    assign PA_EN = (sys_rst_n && amp_ready) ? 1'b0 : 1'b1;

    reg [15:0] bck_div_cnt;
    reg [4:0] bit_index;
    reg [15:0] left_sample;
    reg [15:0] right_sample;
    assign sample_pcm=left_sample;
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            bck_div_cnt <= 16'd0;
            bit_index <= 5'd31;
            left_sample <= 16'd0;
            right_sample <= 16'd0;
            sample_tick <= 1'b0;
            HP_BCK <= 1'b0;
            HP_WS <= 1'b0;
            HP_DIN <= 1'b0;
        end else begin
            sample_tick <= 1'b0;
            if (bck_div_cnt == BCK_HALF_DIV - 1) begin
                bck_div_cnt <= 16'd0;
                HP_BCK <= ~HP_BCK;
                if (HP_BCK) begin
                    if (bit_index == 5'd31) begin
                        right_sample <= pcm_right;
                        left_sample <= pcm_left;
                        bit_index <= 5'd0;
                        HP_WS <= 1'b0;
                        HP_DIN <= pcm_right[15];
                        sample_tick <= 1'b1;
                    end else begin
                        bit_index <= bit_index + 5'd1;
                        if (bit_index < 5'd15)
                            HP_DIN <= right_sample[14 - bit_index];
                        else if (bit_index == 5'd15) begin
                            HP_WS <= 1'b1;
                            HP_DIN <= left_sample[15];
                        end else
                            HP_DIN <= left_sample[30 - bit_index];
                    end
                end
            end else
                bck_div_cnt <= bck_div_cnt + 16'd1;
        end
    end
endmodule
