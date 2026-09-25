//==========================================================================
//  File     : test.v
//  Module   : test (top)
//  Device   : GW5AT-60B (GW5AT-LV60PG484AC1/I0)
//  Board    : Sipeed Tang Mega 60K + NEO Dock
//  Function : PT8211 piano-like synthesizer demo
//
//  Audio path, updated once per stereo frame (~48.828 kHz):
//    triangle DDS -> harmonic mix -> hammer transient -> ADSR -> low-pass
//    -> signed 16-bit PCM -> PT8211 LSBJ serializer
//
//  PT8211 is not standard I2S. It uses 16-bit LSBJ/Japanese format:
//    * BCK rising edge samples DIN
//    * WS=0 is right channel, WS=1 is left channel
//    * MSB is sent first
//    * PA_EN is active-low (0=amplifier on)
//
//  Clocking from the 50 MHz board oscillator:
//    BCK = 50 MHz / 32 = 1.5625 MHz
//    Fs  = BCK / (16 bits * 2 channels) = 48.828125 kHz
//==========================================================================
`timescale 1ns / 1ps

module test (
    input  wire       sys_clk,
    input  wire       sys_rst_n,
    output wire [7:0] LEDs,
    output reg        HP_BCK,
    output reg        HP_WS,
    output reg        HP_DIN,
    output wire       PA_EN
);

    localparam integer CLK_FREQ_HZ       = 50_000_000;
    localparam integer BCK_HALF_DIV      = 16;
    localparam integer AMP_START_CYCLES  = CLK_FREQ_HZ / 20; // 50 ms
    localparam integer TONE_START_CYCLES = CLK_FREQ_HZ / 10; // 100 ms

    // One note lasts about 500 ms. The final 21 ms is a short release.
    localparam [31:0] NOTE_FRAMES       = 32'd24_414;
    localparam [31:0] RELEASE_FRAMES    = 32'd1_024;
    localparam [31:0] ATTACK_FRAMES     = 32'd128;       // about 2.6 ms
    localparam [31:0] BRIGHT_FRAMES     = 32'd3_906;     // about 80 ms
    localparam [31:0] HAMMER_FRAMES     = 32'd256;       // about 5.2 ms
    localparam [5:0]  DECAY_LAST        = 6'd63;         // update every 64 frames
    localparam [15:0] ATTACK_STEP       = 16'd512;
    localparam [15:0] RELEASE_STEP      = 16'd64;
    localparam [15:0] SUSTAIN_LEVEL     = 16'd12_288;

    //--------------------------------------------------------------------
    // Reset synchronizer: asynchronous assertion, synchronous release.
    //--------------------------------------------------------------------
    reg [1:0] rst_sync;

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            rst_sync <= 2'b00;
        else
            rst_sync <= {rst_sync[0], 1'b1};
    end

    wire rst_n = rst_sync[1];

    //--------------------------------------------------------------------
    // Startup sequencing. Audio clocks run with zero data before the power
    // amplifier is enabled; the first note starts after the extra delay.
    //--------------------------------------------------------------------
    reg [31:0] startup_cnt;
    reg        amp_ready;
    reg        tone_ready;

    always @(posedge sys_clk) begin
        if (!rst_n) begin
            startup_cnt <= 32'd0;
            amp_ready   <= 1'b0;
            tone_ready  <= 1'b0;
        end else begin
            if (startup_cnt < TONE_START_CYCLES)
                startup_cnt <= startup_cnt + 32'd1;

            if (startup_cnt >= (AMP_START_CYCLES - 1))
                amp_ready <= 1'b1;

            if (startup_cnt >= (TONE_START_CYCLES - 1))
                tone_ready <= 1'b1;
        end
    end

    // Schematic note: PA_EN=1 disables the amplifier, PA_EN=0 enables it.
    assign PA_EN = (rst_n && amp_ready) ? 1'b0 : 1'b1;

    //--------------------------------------------------------------------
    // Melody. Phase increments are for Fs=48.828125 kHz.
    //--------------------------------------------------------------------
    function [31:0] phase_increment;
        input [3:0] melody_pos;
        begin
            case (melody_pos)
                4'd0,  4'd14: phase_increment = 32'd23_012_828; // C4
                4'd1,  4'd13: phase_increment = 32'd25_831_026; // D4
                4'd2,  4'd12: phase_increment = 32'd28_994_347; // E4
                4'd3,  4'd11: phase_increment = 32'd30_718_440; // F4
                4'd4,  4'd10: phase_increment = 32'd34_480_283; // G4
                4'd5,  4'd9 : phase_increment = 32'd38_702_809; // A4
                4'd6,  4'd8 : phase_increment = 32'd43_442_435; // B4
                4'd7         : phase_increment = 32'd46_025_656; // C5
                default      : phase_increment = 32'd23_012_828;
            endcase
        end
    endfunction

    //--------------------------------------------------------------------
    // Triangle oscillator. Four low-cost harmonics make the sound less like
    // a pure test tone. The phase arithmetic naturally wraps at 32 bits.
    //--------------------------------------------------------------------
    function signed [15:0] triangle_wave;
        input [31:0] phase;
        reg [15:0] tri_unsigned;
        reg signed [16:0] tri_centered;
        begin
            tri_unsigned = phase[31] ? ~phase[30:15] : phase[30:15];
            tri_centered = $signed({1'b0, tri_unsigned}) - 17'sd32768;
            triangle_wave = tri_centered[15:0];
        end
    endfunction

    reg [3:0]  melody_pos;
    reg [31:0] note_frame_cnt;
    reg [31:0] phase_acc;
    reg [15:0] envelope;
    reg [5:0]  decay_tick;
    reg [15:0] lfsr;

    wire signed [15:0] tri_fund = triangle_wave(phase_acc);
    wire signed [15:0] tri_2nd  = triangle_wave(phase_acc << 1);
    wire signed [15:0] tri_3rd  = triangle_wave(phase_acc + (phase_acc << 1));
    wire signed [15:0] tri_4th  = triangle_wave(phase_acc << 2);

    wire signed [19:0] fund_ext = {{4{tri_fund[15]}}, tri_fund};
    wire signed [19:0] second_ext = {{4{tri_2nd[15]}}, tri_2nd};
    wire signed [19:0] third_ext = {{4{tri_3rd[15]}}, tri_3rd};
    wire signed [19:0] fourth_ext = {{4{tri_4th[15]}}, tri_4th};

    // Fundamental + 1/2 second + 1/4 third + 1/8 fourth harmonic.
    wire signed [19:0] harmonic_mix = fund_ext
                                     + (second_ext >>> 1)
                                     + (third_ext >>> 2)
                                     + (fourth_ext >>> 3);

    // Small pseudo-random hammer component during the first few milliseconds.
    wire signed [9:0] hammer_noise =
        $signed({1'b0, lfsr[8:0]}) - 10'sd256;
    wire signed [20:0] hammer_component =
        (note_frame_cnt < HAMMER_FRAMES)
        ? ($signed({{11{hammer_noise[9]}}, hammer_noise}) <<< 2)
        : 21'sd0;

    wire signed [16:0] envelope_signed = $signed({1'b0, envelope});
    wire signed [36:0] envelope_product = harmonic_mix * envelope_signed;
    wire signed [20:0] enveloped_mix = envelope_product >>> 16;
    wire signed [20:0] shaped_sample = enveloped_mix + hammer_component;

    //--------------------------------------------------------------------
    // One-pole low-pass filter. The attack stays brighter (shift=2), then
    // the coefficient changes to shift=3 so the tail becomes warmer.
    //--------------------------------------------------------------------
    reg signed [21:0] lp_state;
    wire [2:0] filter_shift = (note_frame_cnt < BRIGHT_FRAMES) ? 3'd2 : 3'd3;
    wire signed [21:0] shaped_ext = {{1{shaped_sample[20]}}, shaped_sample};
    wire signed [22:0] lp_diff = shaped_ext - $signed({lp_state[21], lp_state});
    wire signed [22:0] lp_next_wide = $signed({lp_state[21], lp_state})
                                     + (lp_diff >>> filter_shift);
    wire signed [21:0] lp_next = lp_next_wide[21:0];
    wire signed [21:0] pcm_scaled = lp_next >>> 2;

    function signed [15:0] saturate16;
        input signed [21:0] value;
        begin
            if (value > 22'sd32767)
                saturate16 = 16'sh7fff;
            else if (value < -22'sd32768)
                saturate16 = 16'sh8000;
            else
                saturate16 = value[15:0];
        end
    endfunction

    wire signed [15:0] next_pcm = saturate16(pcm_scaled);

    // Envelope helper values. Decay is an exponential-like glide toward the
    // sustain level, updated once every 64 audio frames to avoid a long divider.
    wire [16:0] decay_gap = (envelope > SUSTAIN_LEVEL)
                          ? ({1'b0, envelope} - SUSTAIN_LEVEL)
                          : 17'd0;
    wire [16:0] decay_delta_wide = (decay_gap + 17'd511) >> 9;
    wire [15:0] decay_delta = (decay_delta_wide == 0)
                            ? 16'd1
                            : decay_delta_wide[15:0];

    //--------------------------------------------------------------------
    // LED indication. The user's verified CST setup is active-low.
    //--------------------------------------------------------------------
    wire [3:0] led_index_wide = (melody_pos <= 4'd7)
                               ? melody_pos
                               : (4'd14 - melody_pos);
    wire [2:0] led_index = led_index_wide[2:0];
    wire [7:0] led_on = 8'b0000_0001 << led_index;
    assign LEDs = tone_ready ? ~led_on : 8'hFF;

    //--------------------------------------------------------------------
    // PT8211 16-bit LSBJ serializer.
    // Data and WS change only on BCK falling edges, leaving half a BCK period
    // of setup time before the PT8211 samples DIN on the next rising edge.
    //--------------------------------------------------------------------
    reg [5:0]  bck_div_cnt;
    reg [4:0]  bit_index;
    reg [15:0] audio_sample;

    always @(posedge sys_clk) begin
        if (!rst_n) begin
            bck_div_cnt    <= 6'd0;
            bit_index      <= 5'd0;
            HP_BCK         <= 1'b0;
            HP_WS          <= 1'b0;
            HP_DIN         <= 1'b0;
            audio_sample   <= 16'd0;
            melody_pos     <= 4'd0;
            note_frame_cnt <= 32'd0;
            phase_acc      <= 32'd0;
            envelope       <= 16'd0;
            decay_tick     <= 6'd0;
            lfsr            <= 16'h1ACE;
            lp_state       <= 22'sd0;
        end else begin
            // Hold all synthesis state quiet until the startup delay expires.
            if (!tone_ready) begin
                audio_sample   <= 16'd0;
                melody_pos     <= 4'd0;
                note_frame_cnt <= 32'd0;
                phase_acc      <= 32'd0;
                envelope       <= 16'd0;
                decay_tick     <= 6'd0;
                lfsr            <= 16'h1ACE;
                lp_state       <= 22'sd0;
            end

            if (bck_div_cnt == (BCK_HALF_DIV - 1)) begin
                bck_div_cnt <= 6'd0;
                HP_BCK      <= ~HP_BCK;

                // HP_BCK is currently high, so this creates a falling edge.
                if (HP_BCK) begin
                    if (bit_index == 5'd31) begin
                        // Start a new stereo frame with the right-channel MSB.
                        bit_index <= 5'd0;
                        HP_WS     <= 1'b0;

                        if (tone_ready) begin
                            // Freeze one complete PCM sample for both channels.
                            audio_sample <= next_pcm;

                            // Advance all musical state exactly once per frame.
                            lfsr <= {lfsr[14:0],
                                     lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};
                            lp_state <= lp_next;

                            if (note_frame_cnt == (NOTE_FRAMES - 1)) begin
                                // End of note: restart phase and attack cleanly.
                                note_frame_cnt <= 32'd0;
                                if (melody_pos == 4'd14)
                                    melody_pos <= 4'd0;
                                else
                                    melody_pos <= melody_pos + 4'd1;
                                phase_acc  <= 32'd0;
                                envelope   <= 16'd0;
                                decay_tick <= 6'd0;
                            end else begin
                                note_frame_cnt <= note_frame_cnt + 32'd1;
                                phase_acc <= phase_acc + phase_increment(melody_pos);

                                if (note_frame_cnt < ATTACK_FRAMES) begin
                                    if (envelope >= (16'hffff - ATTACK_STEP))
                                        envelope <= 16'hffff;
                                    else
                                        envelope <= envelope + ATTACK_STEP;
                                    decay_tick <= 6'd0;
                                end else if (note_frame_cnt >=
                                             (NOTE_FRAMES - RELEASE_FRAMES)) begin
                                    if (envelope > RELEASE_STEP)
                                        envelope <= envelope - RELEASE_STEP;
                                    else
                                        envelope <= 16'd0;
                                    decay_tick <= 6'd0;
                                end else if (envelope > SUSTAIN_LEVEL) begin
                                    if (decay_tick == DECAY_LAST) begin
                                        if (envelope > (SUSTAIN_LEVEL + decay_delta))
                                            envelope <= envelope - decay_delta;
                                        else
                                            envelope <= SUSTAIN_LEVEL;
                                        decay_tick <= 6'd0;
                                    end else begin
                                        decay_tick <= decay_tick + 6'd1;
                                    end
                                end else begin
                                    envelope   <= SUSTAIN_LEVEL;
                                    decay_tick <= 6'd0;
                                end
                            end

                            HP_DIN <= next_pcm[15];
                        end else begin
                            audio_sample <= 16'd0;
                            HP_DIN       <= 1'b0;
                        end
                    end else begin
                        bit_index <= bit_index + 5'd1;

                        if (bit_index < 5'd15) begin
                            // Continue right channel: bit14 down to bit0.
                            HP_DIN <= audio_sample[14 - bit_index];
                        end else if (bit_index == 5'd15) begin
                            // Right LSB is complete; start left-channel MSB.
                            HP_WS  <= 1'b1;
                            HP_DIN <= audio_sample[15];
                        end else begin
                            // Continue left channel: bit14 down to bit0.
                            HP_DIN <= audio_sample[30 - bit_index];
                        end
                    end
                end
            end else begin
                bck_div_cnt <= bck_div_cnt + 6'd1;
            end
        end
    end

endmodule
