//==========================================================================
//  File     : test.v
//  Module   : test (top)
//  Device   : GW5AT-60B (GW5AT-LV60PG484AC1/I0)
//  Board    : Sipeed Tang Mega 60K + NEO Dock
//  Function : Smooth stereo rendition of The Internationale
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

    // The Internationale in C major at about 108 BPM. Timing is expressed in
    // eighth notes; articulation is deliberately soft to avoid clicks.
    localparam [31:0] EIGHTH_FRAMES     = 32'd13_563;
    localparam [31:0] RELEASE_FRAMES    = 32'd2_930;     // about 60 ms
    localparam [31:0] ATTACK_FRAMES     = 32'd260;       // about 5.3 ms
    localparam [31:0] BRIGHT_FRAMES     = 32'd1_953;     // about 40 ms
    localparam [5:0]  DECAY_LAST        = 6'd31;         // update every 32 frames
    localparam [15:0] ATTACK_STEP       = 16'd512;
    localparam [15:0] RELEASE_STEP      = 16'd48;
    localparam [15:0] SUSTAIN_LEVEL     = 16'd4_096;

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
    // Public-domain melody of The Internationale. Phase increments use
    // Fs=48.828125 kHz. Note codes 1..8 are C4..C5.
    //--------------------------------------------------------------------
    function [31:0] phase_increment;
        input [3:0] note_code;
        begin
            case (note_code)
                4'd1: phase_increment = 32'd23_012_828; // C4
                4'd2: phase_increment = 32'd25_831_026; // D4
                4'd3: phase_increment = 32'd28_994_347; // E4
                4'd4: phase_increment = 32'd30_718_440; // F4
                4'd5: phase_increment = 32'd34_480_283; // G4
                4'd6: phase_increment = 32'd38_702_809; // A4
                4'd7: phase_increment = 32'd43_442_435; // B4
                4'd8: phase_increment = 32'd46_025_656; // C5
                default: phase_increment = 32'd0;
            endcase
        end
    endfunction

    function [3:0] song_note;
        input [5:0] song_pos;
        begin
            case (song_pos)
                // Pickup and first two statements: G G C B A G A B C C B A G.
                6'd0, 6'd14, 6'd28, 6'd44, 6'd60, 6'd61, 6'd62, 6'd63: song_note = 4'd0;
                6'd1, 6'd2, 6'd6, 6'd13, 6'd15, 6'd16, 6'd20, 6'd27: song_note = 4'd5; // G4
                6'd3, 6'd9, 6'd10, 6'd17, 6'd23, 6'd24: song_note = 4'd8; // C5
                6'd4, 6'd11, 6'd18, 6'd25: song_note = 4'd7; // B4
                6'd5, 6'd12, 6'd19, 6'd26: song_note = 4'd6; // A4
                6'd7, 6'd21: song_note = 4'd6; // A4
                6'd8, 6'd22: song_note = 4'd7; // B4

                // Refrain: E E F G G F E D C C D E E D D.
                6'd29, 6'd30, 6'd35, 6'd40, 6'd41, 6'd46, 6'd51, 6'd56: song_note = 4'd3; // E4
                6'd31, 6'd34, 6'd48, 6'd49: song_note = 4'd4; // F4
                6'd32, 6'd33, 6'd47: song_note = 4'd5; // G4
                6'd36, 6'd39, 6'd42, 6'd43, 6'd51, 6'd54, 6'd57, 6'd58: song_note = 4'd2; // D4
                6'd37, 6'd38, 6'd52, 6'd53: song_note = 4'd1; // C4
                default: song_note = 4'd0;
            endcase
        end
    endfunction

    // Duration in eighth-note units: 1=eighth, 2=quarter,
    // 3=dotted quarter and 4=half note.
    function [3:0] song_units;
        input [5:0] song_pos;
        begin
            case (song_pos)
                // Eighth-note pickup/figures; phrase endings are held.
                6'd0, 6'd14, 6'd28, 6'd44, 6'd60, 6'd61, 6'd62, 6'd63: song_units = 4'd1;
                6'd13, 6'd27, 6'd43, 6'd59: song_units = 4'd4;
                6'd12, 6'd26, 6'd42, 6'd58: song_units = 4'd3;
                default: song_units = 4'd2;
            endcase
        end
    endfunction

    //--------------------------------------------------------------------
    // Triangle-derived oscillator. Weighted partials and the short hammer
    // partial approximate a soft piano attack while keeping the core small.
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

    reg [5:0]  melody_pos;
    reg [31:0] note_frame_cnt;
    reg [31:0] phase_acc;
    reg [31:0] phase_step;
    reg [15:0] envelope;
    reg [5:0]  decay_tick;

    wire [3:0] current_note = song_note(melody_pos);
    wire [31:0] target_phase_step = phase_increment(current_note);
    wire [3:0] current_units = song_units(melody_pos);
    wire [31:0] current_note_frames = EIGHTH_FRAMES * current_units;

    wire signed [15:0] tri_fund = triangle_wave(phase_acc);
    wire signed [15:0] tri_2nd  = triangle_wave(phase_acc << 1);
    wire signed [15:0] tri_3rd  = triangle_wave(phase_acc + (phase_acc << 1));
    wire signed [15:0] tri_4th  = triangle_wave(phase_acc << 2);

    wire signed [19:0] fund_ext = {{4{tri_fund[15]}}, tri_fund};
    wire signed [19:0] second_ext = {{4{tri_2nd[15]}}, tri_2nd};
    wire signed [19:0] third_ext = {{4{tri_3rd[15]}}, tri_3rd};
    wire signed [19:0] fourth_ext = {{4{tri_4th[15]}}, tri_4th};

    // Piano-like spectrum: fundamental dominates, with restrained upper
    // partials. The short fourth partial below supplies the hammer attack.
    wire signed [19:0] harmonic_mix = fund_ext
                                     + (second_ext >>> 3)
                                     + (third_ext >>> 4);
    wire signed [20:0] hammer_partial = (note_frame_cnt < 32'd180)
                                       ? (fourth_ext >>> 2) : 21'sd0;

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
    wire [2:0] led_index = melody_pos[5:3];
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
            melody_pos     <= 6'd0;
            note_frame_cnt <= 32'd0;
            phase_acc      <= 32'd0;
            phase_step     <= 32'd34_480_283;
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
                melody_pos     <= 6'd0;
                note_frame_cnt <= 32'd0;
                phase_acc      <= 32'd0;
                phase_step     <= 32'd34_480_283;
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
                                if (melody_pos == 6'd63)
                                    melody_pos <= 6'd0;
                                else
                                    melody_pos <= melody_pos + 6'd1;
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
