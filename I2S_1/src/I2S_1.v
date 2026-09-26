//==========================================================================
// Tang Mega 60K + NEO Dock 32-note piano tone generator
//
// KEY2: active-low reset
// KEY1: select the next chromatic note, C3 through G5
// KEY0: toggle playback on/off
//
// KEY0 and KEY1 use 20 ms debounce and trigger once on a stable press.
// The reset is asserted asynchronously and released synchronously.
//==========================================================================

module I2S_1 #(
    parameter integer CLK_FREQ_HZ        = 50_000_000,
    parameter integer DEBOUNCE_CYCLES    = 1_000_000,
    parameter integer AUDIO_START_CYCLES = 2_500_000
) (
    input  wire sys_clk,

    input  wire KEY0,
    input  wire KEY1,
    input  wire KEY2,

    output wire HP_BCK,
    output wire HP_WS,
    output wire HP_DIN,
    output wire PA_EN
);

    localparam [15:0] ATTACK_STEP   = 16'd256;
    localparam [15:0] RELEASE_STEP  = 16'd128;
    localparam [15:0] SUSTAIN_LEVEL = 16'd12_000;

    //--------------------------------------------------------------------------
    // Reset synchronizer: asynchronous assertion, synchronous release.
    //--------------------------------------------------------------------------

    reg [1:0] reset_sync;

    always @(posedge sys_clk or negedge KEY2) begin
        if (!KEY2)
            reset_sync <= 2'b00;
        else
            reset_sync <= {reset_sync[0], 1'b1};
    end

    wire rst_n = reset_sync[1];

    //--------------------------------------------------------------------------
    // Synchronize and debounce the two control buttons.
    //--------------------------------------------------------------------------

    reg [1:0] key0_sync;
    reg [1:0] key1_sync;

    always @(posedge sys_clk) begin
        if (!rst_n) begin
            key0_sync <= 2'b11;
            key1_sync <= 2'b11;
        end else begin
            key0_sync <= {key0_sync[0], KEY0};
            key1_sync <= {key1_sync[0], KEY1};
        end
    end

    reg [19:0] key0_count;
    reg [19:0] key1_count;
    reg        key0_debounced;
    reg        key1_debounced;
    reg        key0_press_pulse;
    reg        key1_press_pulse;

    always @(posedge sys_clk) begin
        if (!rst_n) begin
            key0_count       <= 20'd0;
            key0_debounced   <= 1'b1;
            key0_press_pulse <= 1'b0;
        end else begin
            key0_press_pulse <= 1'b0;

            if (key0_sync[1] == key0_debounced) begin
                key0_count <= 20'd0;
            end else if (key0_count == DEBOUNCE_CYCLES - 1) begin
                key0_count     <= 20'd0;
                key0_debounced <= key0_sync[1];

                if (!key0_sync[1])
                    key0_press_pulse <= 1'b1;
            end else begin
                key0_count <= key0_count + 20'd1;
            end
        end
    end

    always @(posedge sys_clk) begin
        if (!rst_n) begin
            key1_count       <= 20'd0;
            key1_debounced   <= 1'b1;
            key1_press_pulse <= 1'b0;
        end else begin
            key1_press_pulse <= 1'b0;

            if (key1_sync[1] == key1_debounced) begin
                key1_count <= 20'd0;
            end else if (key1_count == DEBOUNCE_CYCLES - 1) begin
                key1_count     <= 20'd0;
                key1_debounced <= key1_sync[1];

                if (!key1_sync[1])
                    key1_press_pulse <= 1'b1;
            end else begin
                key1_count <= key1_count + 20'd1;
            end
        end
    end

    //--------------------------------------------------------------------------
    // Playback control and 32-note selector.
    // Note 0 is C3 and note 31 is G5. KEY1 advances one semitone.
    //--------------------------------------------------------------------------

    reg       play_enabled;
    reg [4:0] note_select;

    always @(posedge sys_clk) begin
        if (!rst_n) begin
            play_enabled <= 1'b1;
            note_select  <= 5'd0;
        end else begin
            if (key0_press_pulse)
                play_enabled <= ~play_enabled;

            if (key1_press_pulse)
                note_select <= note_select + 5'd1;
        end
    end

    //--------------------------------------------------------------------------
    // Let the DAC clocks settle before opening the audio envelope. The power
    // amplifier is enabled by the communication module after the same delay.
    //--------------------------------------------------------------------------

    reg [21:0] audio_start_count;
    reg        audio_ready;

    always @(posedge sys_clk) begin
        if (!rst_n) begin
            audio_start_count <= 22'd0;
            audio_ready       <= 1'b0;
        end else if (!audio_ready) begin
            if (audio_start_count == AUDIO_START_CYCLES - 1)
                audio_ready <= 1'b1;
            else
                audio_start_count <= audio_start_count + 22'd1;
        end
    end

    //--------------------------------------------------------------------------
    // Equal-tempered chromatic notes for Fs = 48.828125 kHz.
    //--------------------------------------------------------------------------

    function [31:0] note_phase_step;
        input [4:0] note_index;
        begin
            case (note_index)
                5'd0:  note_phase_step = 32'd11_506_414; // C3   130.813 Hz
                5'd1:  note_phase_step = 32'd12_190_621; // C#3  138.591 Hz
                5'd2:  note_phase_step = 32'd12_915_513; // D3   146.832 Hz
                5'd3:  note_phase_step = 32'd13_683_509; // D#3  155.563 Hz
                5'd4:  note_phase_step = 32'd14_497_173; // E3   164.814 Hz
                5'd5:  note_phase_step = 32'd15_359_220; // F3   174.614 Hz
                5'd6:  note_phase_step = 32'd16_272_527; // F#3  184.997 Hz
                5'd7:  note_phase_step = 32'd17_240_142; // G3   195.998 Hz
                5'd8:  note_phase_step = 32'd18_265_294; // G#3  207.652 Hz
                5'd9:  note_phase_step = 32'd19_351_405; // A3   220.000 Hz
                5'd10: note_phase_step = 32'd20_502_099; // A#3  233.082 Hz
                5'd11: note_phase_step = 32'd21_721_217; // B3   246.942 Hz
                5'd12: note_phase_step = 32'd23_012_828; // C4   261.626 Hz
                5'd13: note_phase_step = 32'd24_381_242; // C#4  277.183 Hz
                5'd14: note_phase_step = 32'd25_831_026; // D4   293.665 Hz
                5'd15: note_phase_step = 32'd27_367_019; // D#4  311.127 Hz
                5'd16: note_phase_step = 32'd28_994_347; // E4   329.628 Hz
                5'd17: note_phase_step = 32'd30_718_440; // F4   349.228 Hz
                5'd18: note_phase_step = 32'd32_545_054; // F#4  369.994 Hz
                5'd19: note_phase_step = 32'd34_480_283; // G4   391.995 Hz
                5'd20: note_phase_step = 32'd36_530_588; // G#4  415.305 Hz
                5'd21: note_phase_step = 32'd38_702_809; // A4   440.000 Hz
                5'd22: note_phase_step = 32'd41_004_198; // A#4  466.164 Hz
                5'd23: note_phase_step = 32'd43_442_435; // B4   493.883 Hz
                5'd24: note_phase_step = 32'd46_025_656; // C5   523.251 Hz
                5'd25: note_phase_step = 32'd48_762_484; // C#5  554.365 Hz
                5'd26: note_phase_step = 32'd51_662_052; // D5   587.330 Hz
                5'd27: note_phase_step = 32'd54_734_038; // D#5  622.254 Hz
                5'd28: note_phase_step = 32'd57_988_693; // E5   659.255 Hz
                5'd29: note_phase_step = 32'd61_436_880; // F5   698.456 Hz
                5'd30: note_phase_step = 32'd65_090_107; // F#5  739.989 Hz
                5'd31: note_phase_step = 32'd68_960_566; // G5   783.991 Hz
                default: note_phase_step = 32'd11_506_414;
            endcase
        end
    endfunction

    //--------------------------------------------------------------------------
    // Compact piano-like synthesizer. A triangle fundamental plus restrained
    // harmonics is shaped by an attack/decay/sustain/release envelope.
    //--------------------------------------------------------------------------

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

    wire sample_tick;

    reg [31:0] phase_accumulator;
    reg [15:0] envelope;
    reg [15:0] note_age;
    reg        retrigger_pending;
    reg        play_state_at_last_sample;
    reg [4:0]  active_note;

    wire [31:0] selected_phase_step = note_phase_step(active_note);

    always @(posedge sys_clk) begin
        if (!rst_n) begin
            phase_accumulator <= 32'd0;
            envelope          <= 16'd0;
            note_age          <= 16'd0;
            retrigger_pending <= 1'b1;
            play_state_at_last_sample <= 1'b1;
            active_note       <= 5'd0;
        end else begin
            if (sample_tick) begin
                play_state_at_last_sample <= play_enabled;

                if (!audio_ready) begin
                    phase_accumulator <= 32'd0;
                    envelope          <= 16'd0;
                    note_age          <= 16'd0;
                    active_note       <= note_select;
                end else if (retrigger_pending
                             || (note_select != active_note)
                             || (play_enabled && !play_state_at_last_sample)) begin
                    phase_accumulator <= 32'd0;
                    envelope          <= 16'd0;
                    note_age          <= 16'd0;
                    retrigger_pending <= 1'b0;
                    active_note       <= note_select;
                end else begin
                    phase_accumulator <= phase_accumulator + selected_phase_step;

                    if (play_enabled) begin
                        if (note_age != 16'hffff)
                            note_age <= note_age + 16'd1;

                        if (note_age < 16'd256) begin
                            if (envelope >= (16'hffff - ATTACK_STEP))
                                envelope <= 16'hffff;
                            else
                                envelope <= envelope + ATTACK_STEP;
                        end else if (envelope > SUSTAIN_LEVEL) begin
                            envelope <= envelope
                                      - ((envelope - SUSTAIN_LEVEL) >> 9)
                                      - 16'd1;
                        end else begin
                            envelope <= SUSTAIN_LEVEL;
                        end
                    end else begin
                        if (envelope > RELEASE_STEP)
                            envelope <= envelope - RELEASE_STEP;
                        else
                            envelope <= 16'd0;
                    end
                end
            end
        end
    end

    wire signed [15:0] fundamental = triangle_wave(phase_accumulator);
    wire signed [15:0] harmonic_2  = triangle_wave(phase_accumulator << 1);
    wire signed [15:0] harmonic_3  = triangle_wave(
        phase_accumulator + (phase_accumulator << 1)
    );
    wire signed [15:0] harmonic_4  = triangle_wave(phase_accumulator << 2);

    wire signed [20:0] fundamental_ext = {{5{fundamental[15]}}, fundamental};
    wire signed [20:0] harmonic_2_ext  = {{5{harmonic_2[15]}}, harmonic_2};
    wire signed [20:0] harmonic_3_ext  = {{5{harmonic_3[15]}}, harmonic_3};
    wire signed [20:0] harmonic_4_ext  = {{5{harmonic_4[15]}}, harmonic_4};

    wire signed [20:0] piano_mix = fundamental_ext
                                  + (harmonic_2_ext >>> 3)
                                  + (harmonic_3_ext >>> 4)
                                  + ((note_age < 16'd192)
                                     ? (harmonic_4_ext >>> 3)
                                     : 21'sd0);

    wire signed [16:0] envelope_signed = $signed({1'b0, envelope});
    wire signed [37:0] envelope_product = piano_mix * envelope_signed;
    wire signed [21:0] shaped_sample = envelope_product >>> 16;

    //--------------------------------------------------------------------------
    // Low-pass smoothing and DC blocking reduce switching and envelope clicks.
    //--------------------------------------------------------------------------

    reg signed [21:0] lowpass_state;
    reg signed [21:0] dc_previous_input;
    reg signed [21:0] dc_state;
    reg signed [21:0] smooth_state;

    wire [2:0] filter_shift = (note_age < 16'd1_953) ? 3'd2 : 3'd3;
    wire signed [22:0] lowpass_difference = shaped_sample
                                             - $signed({lowpass_state[21], lowpass_state});
    wire signed [22:0] lowpass_next_wide =
        $signed({lowpass_state[21], lowpass_state})
        + (lowpass_difference >>> filter_shift);
    wire signed [21:0] lowpass_next = lowpass_next_wide[21:0];

    wire signed [22:0] lowpass_state_ext =
        $signed({lowpass_state[21], lowpass_state});
    wire signed [22:0] dc_previous_ext =
        $signed({dc_previous_input[21], dc_previous_input});
    wire signed [22:0] dc_state_ext = $signed({dc_state[21], dc_state});
    wire signed [22:0] dc_next_wide = lowpass_state_ext
                                      - dc_previous_ext
                                      + dc_state_ext
                                      - (dc_state_ext >>> 10);
    wire signed [21:0] dc_next = dc_next_wide[21:0];

    wire signed [22:0] smooth_state_ext =
        $signed({smooth_state[21], smooth_state});
    wire signed [22:0] smooth_difference = dc_state_ext - smooth_state_ext;
    wire signed [22:0] smooth_next_wide = smooth_state_ext
                                          + (smooth_difference >>> 2);
    wire signed [21:0] smooth_next = smooth_next_wide[21:0];

    always @(posedge sys_clk) begin
        if (!rst_n) begin
            lowpass_state     <= 22'sd0;
            dc_previous_input <= 22'sd0;
            dc_state          <= 22'sd0;
            smooth_state      <= 22'sd0;
        end else if (sample_tick) begin
            lowpass_state     <= lowpass_next;
            dc_previous_input <= lowpass_state;
            dc_state          <= dc_next;
            smooth_state      <= smooth_next;
        end
    end

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

    wire signed [15:0] pcm_unmuted = saturate16(smooth_state >>> 1);
    wire [15:0] pcm_absolute = pcm_unmuted[15]
                             ? (~pcm_unmuted + 16'd1)
                             : pcm_unmuted;
    wire signed [15:0] pcm_output = (!audio_ready || (pcm_absolute < 16'd16))
                                  ? 16'sd0
                                  : pcm_unmuted;

    //--------------------------------------------------------------------------
    // PT8211 stereo transmitter. Both channels receive the same piano sample.
    //--------------------------------------------------------------------------

    I2S_1_communication #(
        .CLK_FREQ_HZ      (CLK_FREQ_HZ),
        .BCK_HALF_DIV     (16),
        .AMP_START_CYCLES (AUDIO_START_CYCLES)
    ) u_I2S_1_communication (
        .sys_clk     (sys_clk),
        .sys_rst_n   (rst_n),

        .pcm_left    (pcm_output),
        .pcm_right   (pcm_output),
        .sample_tick (sample_tick),

        .HP_BCK      (HP_BCK),
        .HP_WS       (HP_WS),
        .HP_DIN      (HP_DIN),
        .PA_EN       (PA_EN)
    );

endmodule
