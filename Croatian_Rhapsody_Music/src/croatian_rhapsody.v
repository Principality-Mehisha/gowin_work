//==========================================================================
//  File     : croatian_rhapsody.v
//  Module   : croatian_rhapsody (top)
//  Device   : GW5AT-60B (GW5AT-LV60PG484AC1/I0)
//  Board    : Sipeed Tang Mega 60K + NEO Dock
//  Function : Piano-style Croatian Rhapsody theme excerpt
//
//  Audio path, updated once per stereo frame (~48.828 kHz):
//    piano-like DDS -> hammer/decay envelope -> low-pass -> DC blocker -> gate
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

module croatian_rhapsody (
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

    // Croatian Rhapsody theme excerpt, arranged as a compact monophonic
    // piano line. Timing is expressed in sixteenth-note units at about
    // 120 BPM; the phrase loops continuously after the final cadence.
    localparam [31:0] SIXTEENTH_FRAMES = 32'd6_104;
    localparam [31:0] RELEASE_FRAMES    = 32'd2_930;     // about 60 ms
    localparam [31:0] ATTACK_FRAMES     = 32'd260;       // about 5.3 ms
    localparam [31:0] BRIGHT_FRAMES     = 32'd1_953;     // about 40 ms
    localparam [5:0]  DECAY_LAST        = 6'd31;         // update every 32 frames
    localparam [15:0] ATTACK_STEP       = 16'd512;
    localparam [15:0] RELEASE_STEP      = 16'd48;
    localparam [15:0] SUSTAIN_LEVEL     = 16'd4_096;
    localparam [7:0]  SONG_LAST         = 8'd63;

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
    // Theme note table. Phase increments use Fs=48.828125 kHz. The score
    // spans D4 through D5 and uses the existing compact piano voice.
    //--------------------------------------------------------------------
    function [31:0] phase_increment;
        input [3:0] note_code;
        begin
            case (note_code)
                4'd1:  phase_increment = 32'd21_721_217; // B3
                4'd2:  phase_increment = 32'd23_012_828; // C4
                4'd3:  phase_increment = 32'd24_381_242; // C#4
                4'd4:  phase_increment = 32'd25_831_026; // D4
                4'd5:  phase_increment = 32'd27_367_019; // D#4
                4'd6:  phase_increment = 32'd28_994_347; // E4
                4'd7:  phase_increment = 32'd32_545_054; // F#4
                4'd8:  phase_increment = 32'd34_480_283; // G4
                4'd9:  phase_increment = 32'd38_702_809; // A4
                4'd10: phase_increment = 32'd43_442_435; // B4
                4'd11: phase_increment = 32'd46_025_656; // C5
                4'd12: phase_increment = 32'd51_662_052; // D5
                default: phase_increment = 32'd0;
            endcase
        end
    endfunction

    function [3:0] song_note;
        input [7:0] song_pos;
        begin
            case (song_pos)
                8'd0, 8'd4, 8'd7, 8'd15, 8'd16, 8'd20, 8'd23, 8'd31,
                8'd32, 8'd37, 8'd39, 8'd44, 8'd46, 8'd48, 8'd52, 8'd55,
                8'd56, 8'd60, 8'd63: song_note = 4'd9;  // A4
                8'd1, 8'd3, 8'd8, 8'd10, 8'd17, 8'd19, 8'd24, 8'd26,
                8'd33, 8'd35, 8'd38, 8'd41, 8'd47, 8'd50, 8'd57, 8'd59:
                    song_note = 4'd8;  // G4
                8'd2, 8'd9, 8'd18, 8'd25, 8'd34, 8'd40, 8'd49, 8'd58:
                    song_note = 4'd6;  // E4
                8'd36, 8'd42: song_note = 4'd7; // F#4 color tone
                8'd53: song_note = 4'd4; // D4 passing tone
                8'd6, 8'd12, 8'd22, 8'd28, 8'd45, 8'd54, 8'd62:
                    song_note = 4'd10; // B4
                8'd5, 8'd11, 8'd14, 8'd21, 8'd27, 8'd30, 8'd43, 8'd51,
                8'd61: song_note = 4'd11; // C5
                8'd13, 8'd29: song_note = 4'd12; // D5
                default: song_note = 4'd0;
            endcase
        end
    endfunction

    // Duration in sixteenth-note units: 1=sixteenth, 2=eighth, 3=dotted
    // eighth, 4=quarter, 6=dotted quarter and 8=half note.
    function [3:0] song_units;
        input [7:0] song_pos;
        begin
            case (song_pos)
                8'd0, 8'd4, 8'd7, 8'd11, 8'd15, 8'd16, 8'd20, 8'd23,
                8'd27, 8'd31, 8'd32, 8'd37, 8'd40, 8'd44, 8'd47, 8'd48,
                8'd52, 8'd55, 8'd56, 8'd60: song_units = 4'd4;
                8'd63: song_units = 4'd6;
                default: song_units = 4'd2;
            endcase
        end
    endfunction

    //--------------------------------------------------------------------
    // Compact sine wavetable oscillator. A sine fundamental avoids the
    // buzzy character of the old triangle-only voice; weighted upper
    // partials and the short hammer partial restore piano-like brightness.
    //--------------------------------------------------------------------
    function signed [15:0] sine_wave;
        input [31:0] phase;
        reg [4:0] sine_index;
        begin
            sine_index = phase[31:27];
            case (sine_index)
                 5'd0: sine_wave = 16'sd0;
                 5'd1: sine_wave = 16'sd6393;
                 5'd2: sine_wave = 16'sd12539;
                 5'd3: sine_wave = 16'sd18204;
                 5'd4: sine_wave = 16'sd23170;
                 5'd5: sine_wave = 16'sd27245;
                 5'd6: sine_wave = 16'sd30273;
                 5'd7: sine_wave = 16'sd32138;
                 5'd8: sine_wave = 16'sd32767;
                 5'd9: sine_wave = 16'sd32138;
                5'd10: sine_wave = 16'sd30273;
                5'd11: sine_wave = 16'sd27245;
                5'd12: sine_wave = 16'sd23170;
                5'd13: sine_wave = 16'sd18204;
                5'd14: sine_wave = 16'sd12539;
                5'd15: sine_wave = 16'sd6393;
                5'd16: sine_wave = 16'sd0;
                5'd17: sine_wave = -16'sd6393;
                5'd18: sine_wave = -16'sd12539;
                5'd19: sine_wave = -16'sd18204;
                5'd20: sine_wave = -16'sd23170;
                5'd21: sine_wave = -16'sd27245;
                5'd22: sine_wave = -16'sd30273;
                5'd23: sine_wave = -16'sd32138;
                5'd24: sine_wave = -16'sd32768;
                5'd25: sine_wave = -16'sd32138;
                5'd26: sine_wave = -16'sd30273;
                5'd27: sine_wave = -16'sd27245;
                5'd28: sine_wave = -16'sd23170;
                5'd29: sine_wave = -16'sd18204;
                5'd30: sine_wave = -16'sd12539;
                5'd31: sine_wave = -16'sd6393;
                default: sine_wave = 16'sd0;
            endcase
        end
    endfunction

    reg [7:0]  melody_pos;
    reg [31:0] note_frame_cnt;
    reg [31:0] phase_acc;
    reg [31:0] phase_step;
    reg [15:0] envelope;
    reg [5:0]  decay_tick;

    wire [3:0] current_note = song_note(melody_pos);
    wire [31:0] target_phase_step = phase_increment(current_note);
    wire [3:0] current_units = song_units(melody_pos);
    wire [31:0] current_note_frames = SIXTEENTH_FRAMES * current_units;

    wire signed [15:0] sine_fund = sine_wave(phase_acc);
    wire signed [15:0] sine_2nd  = sine_wave(phase_acc << 1);
    wire signed [15:0] sine_3rd  = sine_wave(phase_acc + (phase_acc << 1));
    wire signed [15:0] sine_4th  = sine_wave(phase_acc << 2);

    wire signed [19:0] fund_ext = {{4{sine_fund[15]}}, sine_fund};
    wire signed [19:0] second_ext = {{4{sine_2nd[15]}}, sine_2nd};
    wire signed [19:0] third_ext = {{4{sine_3rd[15]}}, sine_3rd};
    wire signed [19:0] fourth_ext = {{4{sine_4th[15]}}, sine_4th};

    // Piano-like spectrum: fundamental dominates, with restrained upper
    // partials. The short fourth partial below supplies the hammer attack.
    wire signed [19:0] harmonic_mix = fund_ext
                                     + (second_ext >>> 2)
                                     + (third_ext >>> 3);
    wire signed [20:0] hammer_partial = ((current_note != 4'd0) &&
                                         (note_frame_cnt < 32'd180))
                                       ? (fourth_ext >>> 1) : 21'sd0;

    wire signed [16:0] envelope_signed = $signed({1'b0, envelope});
    wire signed [36:0] envelope_product = harmonic_mix * envelope_signed;
    wire signed [20:0] enveloped_mix = envelope_product >>> 16;
    wire signed [20:0] shaped_sample = enveloped_mix + hammer_partial;

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

    // DC blocker: y[n] = x[n] - x[n-1] + 0.999*y[n-1]. This removes offsets
    // that otherwise become clicks when the envelope opens or closes.
    reg signed [21:0] dc_prev_in;
    reg signed [21:0] dc_state;
    // Each cleanup stage consumes the previous stage's registered output.
    // This audio-rate pipeline keeps the 50 MHz FPGA path short.
    wire signed [22:0] lp_state_ext = $signed({lp_state[21], lp_state});
    wire signed [22:0] dc_prev_ext = $signed({dc_prev_in[21], dc_prev_in});
    wire signed [22:0] dc_state_ext = $signed({dc_state[21], dc_state});
    wire signed [22:0] dc_next_wide = lp_state_ext - dc_prev_ext + dc_state_ext
                                     - (dc_state_ext >>> 10);
    wire signed [21:0] dc_next = dc_next_wide[21:0];

    // A second gentle one-pole stage suppresses quantization and transition
    // noise without dulling the melody.
    reg signed [21:0] smooth_state;
    wire signed [22:0] smooth_state_ext =
        $signed({smooth_state[21], smooth_state});
    wire signed [22:0] smooth_diff = dc_state_ext - smooth_state_ext;
    wire signed [22:0] smooth_next_wide = smooth_state_ext
                                         + (smooth_diff >>> 2);
    wire signed [21:0] smooth_next = smooth_next_wide[21:0];
    wire signed [21:0] pcm_scaled = smooth_state >>> 2;

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

    wire signed [15:0] pcm_raw = saturate16(pcm_scaled);
    wire [15:0] pcm_abs = pcm_raw[15] ? (~pcm_raw + 16'd1) : pcm_raw;
    wire signed [15:0] next_pcm = (pcm_abs < 16'd20) ? 16'sd0 : pcm_raw;

    // Slew the DDS increment over several milliseconds at pitch changes.
    // Keeping phase continuous removes clicks while retaining clear notes.
    wire [31:0] phase_gap_up = target_phase_step - phase_step;
    wire [31:0] phase_gap_down = phase_step - target_phase_step;
    wire [31:0] phase_slew_up = (phase_gap_up >> 9) + 32'd1;
    wire [31:0] phase_slew_down = (phase_gap_down >> 9) + 32'd1;

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
    wire [2:0] led_index = (melody_pos < 8'd16)  ? 3'd0 :
                           (melody_pos < 8'd32)  ? 3'd1 :
                           (melody_pos < 8'd48)  ? 3'd2 :
                           (melody_pos < 8'd64)  ? 3'd3 :
                           (melody_pos < 8'd80)  ? 3'd4 :
                           (melody_pos < 8'd96)  ? 3'd5 :
                           (melody_pos < 8'd112) ? 3'd6 : 3'd7;
    wire [7:0] led_on = 8'b0000_0001 << led_index;
    assign LEDs = tone_ready ? ~led_on : 8'hFF;

    //--------------------------------------------------------------------
    // PT8211 16-bit LSBJ serializer.
    // Data and WS change only on BCK falling edges, leaving half a BCK period
    // of setup time before the PT8211 samples DIN on the next rising edge.
    //--------------------------------------------------------------------
    reg [5:0]  bck_div_cnt;
    reg [4:0]  bit_index;
    reg [15:0] left_sample;
    reg [15:0] right_sample;

    always @(posedge sys_clk) begin
        if (!rst_n) begin
            bck_div_cnt    <= 6'd0;
            bit_index      <= 5'd31;
            HP_BCK         <= 1'b0;
            HP_WS          <= 1'b0;
            HP_DIN         <= 1'b0;
            left_sample    <= 16'd0;
            right_sample   <= 16'd0;
            melody_pos     <= 8'd0;
            note_frame_cnt <= 32'd0;
            phase_acc      <= 32'd0;
            phase_step     <= 32'd25_831_026;
            envelope       <= 16'd0;
            decay_tick     <= 6'd0;
            lp_state       <= 22'sd0;
            dc_prev_in     <= 22'sd0;
            dc_state       <= 22'sd0;
            smooth_state   <= 22'sd0;
        end else begin
            // Hold all synthesis state quiet until the startup delay expires.
            if (!tone_ready) begin
                left_sample    <= 16'd0;
                right_sample   <= 16'd0;
                melody_pos     <= 8'd0;
                note_frame_cnt <= 32'd0;
                phase_acc      <= 32'd0;
                phase_step     <= 32'd25_831_026;
                envelope       <= 16'd0;
                decay_tick     <= 6'd0;
                lp_state       <= 22'sd0;
                dc_prev_in     <= 22'sd0;
                dc_state       <= 22'sd0;
                smooth_state   <= 22'sd0;
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
                            // Explicitly load both PT8211 channels. Sending the
                            // same mono mix to L and R drives both speakers.
                            left_sample  <= next_pcm;
                            right_sample <= next_pcm;

                            // Advance all musical state exactly once per frame.
                            lp_state <= lp_next;
                            dc_prev_in <= lp_state;
                            dc_state <= dc_next;
                            smooth_state <= smooth_next;

                            if (note_frame_cnt == (current_note_frames - 1)) begin
                                // End of event: re-trigger the envelope but keep
                                // oscillator phase continuous to avoid clicks.
                                note_frame_cnt <= 32'd0;
                                if (melody_pos == SONG_LAST)
                                    melody_pos <= 8'd0;
                                else
                                    melody_pos <= melody_pos + 8'd1;
                                envelope   <= 16'd0;
                                decay_tick <= 6'd0;
                            end else begin
                                note_frame_cnt <= note_frame_cnt + 32'd1;
                                phase_acc <= phase_acc + phase_step;
                                if ((current_note != 4'd0) &&
                                    (phase_step < target_phase_step))
                                    phase_step <= phase_step + phase_slew_up;
                                else if ((current_note != 4'd0) &&
                                         (phase_step > target_phase_step))
                                    phase_step <= phase_step - phase_slew_down;

                                if (current_note == 4'd0) begin
                                    envelope   <= 16'd0;
                                    decay_tick <= 6'd0;
                                end else if (note_frame_cnt < ATTACK_FRAMES) begin
                                    if (envelope >= (16'hffff - ATTACK_STEP))
                                        envelope <= 16'hffff;
                                    else
                                        envelope <= envelope + ATTACK_STEP;
                                    decay_tick <= 6'd0;
                                end else if (note_frame_cnt >=
                                             (current_note_frames - RELEASE_FRAMES)) begin
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
                            left_sample  <= 16'd0;
                            right_sample <= 16'd0;
                            HP_DIN       <= 1'b0;
                        end
                    end else begin
                        bit_index <= bit_index + 5'd1;

                        if (bit_index < 5'd15) begin
                            // Continue right channel: bit14 down to bit0.
                            HP_DIN <= right_sample[14 - bit_index];
                        end else if (bit_index == 5'd15) begin
                            // Right LSB is complete; start left-channel MSB.
                            HP_WS  <= 1'b1;
                            HP_DIN <= left_sample[15];
                        end else begin
                            // Continue left channel: bit14 down to bit0.
                            HP_DIN <= left_sample[30 - bit_index];
                        end
                    end
                end
            end else begin
                bck_div_cnt <= bck_div_cnt + 6'd1;
            end
        end
    end

endmodule
