//==========================================================================
//  PT8211 stereo audio transmitter for Tang Mega 60K NEO Dock
//
//  The onboard PT8211 does not use Philips I2S. It uses 16-bit LSBJ
//  (Japanese/right-justified) timing:
//    * HP_WS = 0 sends the right channel; HP_WS = 1 sends the left channel.
//    * Each channel is 16 bits, MSB first, with no padding bit.
//    * DIN and WS change on BCK falling edges.
//    * The DAC samples DIN on BCK rising edges.
//
//  With a 50 MHz system clock and BCK_HALF_DIV=16:
//    HP_BCK = 50 MHz / (2 * 16) = 1.5625 MHz
//    sample rate = HP_BCK / (16 * 2) = 48.828125 kHz
//==========================================================================

module I2S_1_communication #(
    parameter integer CLK_FREQ_HZ      = 50_000_000,
    parameter integer BCK_HALF_DIV     = 16,
    parameter integer AMP_START_CYCLES = CLK_FREQ_HZ / 20
) (
    input  wire               sys_clk,
    input  wire               sys_rst_n,

    // Signed two's-complement PCM. Keep these inputs stable when sample_tick
    // is high; they are copied into private registers once per stereo frame.
    input  wire signed [15:0] pcm_left,
    input  wire signed [15:0] pcm_right,
    output reg                sample_tick,

    output reg                HP_BCK,
    output reg                HP_WS,
    output reg                HP_DIN,
    output wire               PA_EN
);

    //--------------------------------------------------------------------
    // The NEO Dock amplifier enable is active-low. Keep it disabled while
    // clocks and zero audio settle, which reduces power-up clicks.
    //--------------------------------------------------------------------
    reg [31:0] amp_start_cnt;
    reg        amp_ready;

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            amp_start_cnt <= 32'd0;
            amp_ready     <= 1'b0;
        end else if (!amp_ready) begin
            if (amp_start_cnt == AMP_START_CYCLES - 1)
                amp_ready <= 1'b1;
            else
                amp_start_cnt <= amp_start_cnt + 32'd1;
        end
    end

    assign PA_EN = (sys_rst_n && amp_ready) ? 1'b0 : 1'b1;

    //--------------------------------------------------------------------
    // Clock divider and 32-bit stereo-frame serializer.
    //
    // bit_index  0..15 : right sample, bits 15..0
    // bit_index 16..31 : left  sample, bits 15..0
    //
    // Every output transition is made only while creating a falling BCK
    // edge. Consequently DIN and WS have half a BCK period of setup time
    // before the PT8211 samples them at the next rising BCK edge.
    //--------------------------------------------------------------------
    reg [15:0] bck_div_cnt;
    reg [4:0]  bit_index;
    reg [15:0] left_sample;
    reg [15:0] right_sample;

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            bck_div_cnt <= 16'd0;
            bit_index   <= 5'd31;
            left_sample <= 16'd0;
            right_sample<= 16'd0;
            sample_tick <= 1'b0;
            HP_BCK      <= 1'b0;
            HP_WS       <= 1'b0;
            HP_DIN      <= 1'b0;
        end else begin
            sample_tick <= 1'b0;

            if (bck_div_cnt == BCK_HALF_DIV - 1) begin
                bck_div_cnt <= 16'd0;
                HP_BCK      <= ~HP_BCK;

                // HP_BCK is currently high, so the assignment above creates
                // a falling edge. Update data only on this half-cycle.
                if (HP_BCK) begin
                    if (bit_index == 5'd31) begin
                        // Begin a new frame with the right-channel MSB.
                        // Using pcm_right directly here avoids a stale first
                        // bit while the frame registers are being loaded.
                        right_sample <= pcm_right;
                        left_sample  <= pcm_left;
                        bit_index    <= 5'd0;
                        HP_WS        <= 1'b0;
                        HP_DIN       <= pcm_right[15];
                        sample_tick  <= 1'b1;
                    end else begin
                        bit_index <= bit_index + 5'd1;

                        if (bit_index < 5'd15) begin
                            // Right bits 14 down to 0.
                            HP_DIN <= right_sample[14 - bit_index];
                        end else if (bit_index == 5'd15) begin
                            // Right LSB has completed; start left MSB.
                            HP_WS  <= 1'b1;
                            HP_DIN <= left_sample[15];
                        end else begin
                            // Left bits 14 down to 0.
                            HP_DIN <= left_sample[30 - bit_index];
                        end
                    end
                end
            end else begin
                bck_div_cnt <= bck_div_cnt + 16'd1;
            end
        end
    end

endmodule
