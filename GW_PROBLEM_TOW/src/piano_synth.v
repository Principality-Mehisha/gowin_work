// 88 independent note states, one shared time-multiplexed 8-partial datapath.
// event_note=0..87 means A0..C8; note-off addresses the original note.
module piano_synth #(
    parameter SINE_FILE="src/rom/sine256.hex",
    parameter FREQ_FILE="src/rom/frequency88.hex",
    parameter VOICING_FILE="src/rom/voicing88.hex",
    parameter integer BASS_VOICING=1,
    parameter integer HAMMER_TRANSIENT=1,
    parameter integer HAMMER_NOISE=0,
    parameter integer UNISON_BEAT=0,
    parameter integer PARTIAL_DECAY=0,
    parameter [23:0] ATTACK_STEP=24'd69906,
    parameter [23:0] DECAY_STEP=24'd711,
    parameter [23:0] SUSTAIN_LEVEL=24'd3145728,
    parameter integer RELEASE_SHIFT=14
) (
    input wire clk, reset_n, sample_tick, stop_all, instrument_change,
    input wire event_valid, event_on,
    input wire [6:0] event_note,
    input wire [7:0] event_dynamics,
    // Unsigned Q2.16 global pitch multiplier; 65536 is concert pitch.
    input wire [17:0] pitch_ratio,
    input wire [1:0] instrument_mode,
    output wire event_ready,
    output reg signed [31:0] mix_sample,
    output reg mix_valid,
    output wire signed [15:0] pcm,
    output wire pcm_valid, limiting, saturated,
    output reg deadline_error,
    output reg [6:0] active_voices,
    output wire [6:0] debug_voice,
    output wire [2:0] debug_env_state,
    output wire [23:0] debug_envelope,
    output wire [31:0] debug_phase
);
    localparam IDLE=0, LOAD=1, H0=2, H1=3, ENV_PREP=4, ENV_GAIN=5,
               DYN_GAIN=6, ADD=7, FINISH=8, FETCH=9, COMMIT=10, DRAIN=11,
               DECODE=12, NOTE_GAIN=13, PREPARE=14, DYN_MERGE=15;
    reg [3:0] state;
    reg [6:0] voice;
    reg [3:0] harmonic;
    reg [87:0] gates, pending;
    reg [7:0] dynamics [0:87];
    // One synchronous state RAM; clearing validity avoids resetting RAM cells.
    // Packed state: {phase[31:0], envelope[23:0], release_step[23:0], state[2:0]}.
    reg [82:0] voice_ram [0:127];
    reg [82:0] voice_data;
    reg [82:0] state_snapshot /* synthesis syn_preserve=1 */;
    reg [7:0] dynamics_data;
    // Eight phases per voice allow true stiff-string partials without phase
    // discontinuities when the fundamental accumulator wraps.
    // Packed partial state: {partial_levels[191:0], noise[15:0],
    // unison_phase[31:0], strike[15:0], tone[15:0], phases[255:0]}.
    reg [527:0] partial_ram [0:127];
    reg [527:0] partial_data;
    reg [255:0] voice_phases;
    reg [191:0] partial_levels;
    reg [15:0] tone_level, strike_level;
    reg [15:0] previous_tone, tone_loss, previous_strike;
    reg [31:0] unison_phase, previous_unison;
    reg [15:0] noise_lfsr, previous_noise;
    reg bass_voice;
    reg [8:0] bass_brightness_low, bass_brightness_high, normal_brightness;
    reg [87:0] weights /* synthesis syn_preserve=1 */;
    reg [87:0] voice_select;
    reg [10:0] note_gain /* synthesis syn_preserve=1 */;
    reg voice_last;
    reg [139:0] voicing_rom [0:87];
    reg [139:0] profile;
    reg [87:0] valid_states;
    reg [31:0] frequency_word;
    reg [23:0] release_step_reg;
    reg [2:0] env_state_reg;
    reg voice_valid, gate_reg, trigger_reg;
    reg ready_reg;
    reg [31:0] frequency_rom [0:87];
    reg [47:0] decay_rom [0:87];
    reg [47:0] decay_data;
    reg signed [15:0] sine_rom [0:255];
    function [23:0] decay_for_note;
        input integer note_number;
        integer scale;
        reg [32:0] value;
        begin
            // Rounded interpolation, matching the generated voicing metadata.
            scale=note_number>=36 ? 256 : 64+(note_number*192+18)/36;
            value=DECAY_STEP*(BASS_VOICING ? scale : 256);
            decay_for_note=value>>8;
            if(decay_for_note==0) decay_for_note=1;
        end
    endfunction
    integer init_note;
    initial begin
        $readmemh(SINE_FILE, sine_rom);
        $readmemh(FREQ_FILE, frequency_rom);
        $readmemh(VOICING_FILE, voicing_rom);
        // Elaborated constants: these / and * operations create no runtime
        // divider/multiplier, and remain valid for parameterized ADSR tests.
        for(init_note=0;init_note<88;init_note=init_note+1)
            decay_rom[init_note]={
                (SUSTAIN_LEVEL+decay_for_note(init_note)),
                decay_for_note(init_note)};
    end
    reg [31:0] base_phase, phase_h, voice_step;
    reg [35:0] freq_h;
    reg [23:0] voice_env /* synthesis syn_preserve=1 */;
    reg [23:0] voice_decay_step /* synthesis syn_preserve=1 */;
    reg [23:0] voice_decay_threshold /* synthesis syn_preserve=1 */;
    reg [7:0] voice_dynamics /* synthesis syn_preserve=1 */;
    reg signed [16:0] interpolated;
    reg signed [31:0] harmonic_sum /* synthesis syn_preserve=1 */;
    reg signed [32:0] envelope_product;
    reg signed [15:0] harmonic_latched;
    reg [15:0] envelope_latched;
    reg [15:0] sum_high_left,sum_high_right;
    reg sum_carry,sum_high_valid,sum_finish;
    reg signed [24:0] dynamics_product /* synthesis syn_preserve=1 */;
    reg signed [20:0] dynamics_low_product /* synthesis syn_preserve=1 */;
    reg signed [20:0] dynamics_high_product /* synthesis syn_preserve=1 */;
    reg signed [43:0] note_product;
    reg [31:0] stiffness_step;
    reg [31:0] next_partial_phase;
    reg [35:0] next_frequency_base, next_frequency_stretch;
    reg signed [31:0] mix_accum;
    reg [6:0] active_count;
    reg [17:0] frame_pitch;
    wire [49:0] pitch_product = frequency_word * frame_pitch;
    wire [31:0] pitched_step = pitch_product[47:16];
    wire [49:0] stiffness_product = profile[139:108] * frame_pitch;
    wire [139:0] standard_profile = {
        32'd0,9'd256,11'd256,11'd22,11'd30,11'd42,11'd60,
        11'd90,11'd140,11'd220,11'd420};
    // Shared DDS datapath; this profile provides a violin-like spectrum.
    localparam [139:0] VIOLIN_PROFILE = {
        32'd0, 9'd256, 11'd224, 11'd3, 11'd8, 11'd18, 11'd35,
        11'd70, 11'd130, 11'd260, 11'd500};
    localparam [1:0] PIANO_MODE=2'd0, VIOLIN_MODE=2'd1, DRUM_MODE=2'd2;
    localparam [23:0] DRUM_DECAY_STEP=24'd16384;
    // Low notes are kick-like, middle notes snare-like, and high notes hat-like.
    function [139:0] drum_profile;
        input [6:0] note_number;
        begin
            if (note_number < 24)
                drum_profile = {
                    32'd0, 9'd256, 11'd256, 11'd0, 11'd0, 11'd0,
                    11'd0, 11'd24, 11'd120, 11'd160, 11'd720};
            else if (note_number < 48)
                drum_profile = {
                    32'd0, 9'd256, 11'd256, 11'd4, 11'd8, 11'd16,
                    11'd28, 11'd50, 11'd90, 11'd220, 11'd608};
            else
                drum_profile = {
                    32'd0, 9'd256, 11'd256, 11'd120, 11'd110, 11'd100,
                    11'd90, 11'd80, 11'd70, 11'd60, 11'd394};
        end
    endfunction
    wire [2:0] next_env_state;
    wire [23:0] next_env, next_release_step;
    adsr_pipeline #(.ATTACK_STEP(ATTACK_STEP), .DECAY_STEP(DECAY_STEP),
        .SUSTAIN_LEVEL(SUSTAIN_LEVEL), .RELEASE_SHIFT(RELEASE_SHIFT)) envelope_unit (
        .clk(clk), .capture(state==DECODE), .gate(gate_reg), .trigger(trigger_reg),
        .valid_in(voice_valid),
        .state_in(state_snapshot[2:0]),
        .level_in(state_snapshot[50:27]),
        .release_step_in(state_snapshot[26:3]),
        .decay_amount(voice_decay_step),
        .decay_threshold(voice_decay_threshold),
        .state_out(next_env_state), .level_out(next_env),
        .release_step_out(next_release_step));
    // Difference of h*(h*h-1) for successive h.  All constant products are
    // explicit shift/add/subtract expressions, with 36-bit headroom.
    function [35:0] stretch_increment;
        input [3:0] next_h;
        input [31:0] step;
        reg [35:0] s;
        begin
            s={4'd0,step};
            case(next_h)
                2: stretch_increment=(s<<2)+(s<<1);
                3: stretch_increment=(s<<4)+(s<<1);
                4: stretch_increment=(s<<5)+(s<<2);
                5: stretch_increment=(s<<6)-(s<<2);
                6: stretch_increment=(s<<6)+(s<<4)+(s<<3)+(s<<1);
                7: stretch_increment=(s<<7)-(s<<1);
                8: stretch_increment=(s<<7)+(s<<5)+(s<<3);
                default: stretch_increment=0;
            endcase
        end
    endfunction
    function [15:0] next_noise;
        input [15:0] current;
        reg feedback;
        begin
            feedback=current[15]^current[13]^current[12]^current[10];
            next_noise={current[14:0],feedback};
            if(next_noise==0) next_noise=16'h1ace;
        end
    endfunction
    function [8:0] partial_brightness;
        input [3:0] partial_number;
        input [23:0] envelope;
        input [15:0] tone;
        input [23:0] partial_level;
        input bass;
        reg [8:0] base;
        reg [17:0] scaled;
        begin
            if(partial_number==1) base=9'd256;
            else if(bass && partial_number<4)
                base=9'd192+{3'd0,tone[15:10]};
            else if(bass)
                base=9'd64+{2'd0,tone[15:9]}+{3'd0,tone[15:10]};
            else base=9'd128+{1'b0,envelope[23:17]};
            if(PARTIAL_DECAY) begin
                scaled=base*partial_level[23:16];
                partial_brightness=scaled>>8;
            end else partial_brightness=base;
        end
    endfunction
    function [4:0] partial_decay_shift;
        input [3:0] partial_number;
        begin
            case(partial_number)
                1: partial_decay_shift=22;
                2: partial_decay_shift=21;
                3: partial_decay_shift=20;
                4: partial_decay_shift=19;
                5: partial_decay_shift=18;
                6: partial_decay_shift=17;
                7: partial_decay_shift=16;
                default: partial_decay_shift=15;
            endcase
        end
    endfunction
    function [8:0] apply_unison;
        input [8:0] base;
        input [7:0] phase;
        reg [6:0] folded;
        reg signed [8:0] centered;
        reg signed [10:0] result;
        begin
            folded=phase[7] ? ~phase[6:0] : phase[6:0];
            centered=$signed({1'b0,folded})-9'sd64;
            result=$signed({2'b0,base})+(centered >>> 3);
            if(result<1) apply_unison=9'd1;
            else if(result>511) apply_unison=9'd511;
            else apply_unison=result[8:0];
        end
    endfunction
    function signed [15:0] hammer_noise;
        input [15:0] lfsr;
        input [15:0] strike;
        reg signed [8:0] centered;
        begin
            centered=$signed({1'b0,lfsr[7:0]})-9'sd128;
            hammer_noise=strike[15:12]==0 ? 16'sd0 : centered >>> 3;
        end
    endfunction
    function signed [15:0] drum_noise;
        input [15:0] lfsr;
        input [15:0] strike;
        reg signed [8:0] centered;
        begin
            centered=$signed({1'b0,lfsr[7:0]})-9'sd128;
            drum_noise=strike[15:12]==0 ? 16'sd0 : centered <<< 7;
        end
    endfunction
    reg [10:0] coefficient_reg;
    reg [8:0] brightness_reg;
    wire [19:0] bright_weight /* synthesis syn_dspstyle="dsp" */;
    assign bright_weight=coefficient_reg*brightness_reg;
    wire [8:0] fade_weight = 9'd0 - freq_h[28:20] - (|freq_h[19:0]);
    wire [8:0] alias_gain = freq_h >= 36'h080000000 ? 9'd0 :
                           freq_h <= 36'h070000000 ? 9'd256 :
                           fade_weight;
    reg [19:0] bright_weight_reg;
    reg [8:0] alias_gain_reg;
    wire [19:0] safe_weight = (bright_weight_reg >> 8) * alias_gain_reg;
    wire [7:0] sine_address = phase_h[31:24];
    reg signed [15:0] sine_value, sine_next;
    wire signed [16:0] sine_difference =
        $signed({sine_next[15],sine_next}) - $signed({sine_value[15],sine_value});
    reg signed [16:0] difference_reg, base1, base2;
    reg [7:0] fraction_reg;
    reg signed [25:0] interpolation_product;
    reg [10:0] weight1, weight2, weight3;
    reg signed [27:0] weighted_partial;
    wire signed [31:0] extended_partial={{4{weighted_partial[27]}},weighted_partial};
    wire [16:0] low_sum={1'b0,harmonic_sum[15:0]}+
                       {1'b0,extended_partial[15:0]};
    reg [3:0] partial_valid, partial_last;
    wire signed [15:0] harmonic_sample = harmonic_sum >>> 10;
    wire signed [15:0] enveloped_sample = envelope_product >>> 16;
    wire signed [31:0] voice_sample = note_product >>> 16;
    // FETCH snapshots gates and consumes trigger flags atomically.
    assign event_ready = ready_reg && !stop_all && !instrument_change && reset_n;
    assign debug_voice=voice;
    assign debug_env_state=env_state_reg;
    assign debug_envelope=voice_env;
    assign debug_phase=base_phase;
    output_limiter limiter (
        .clk(clk), .reset_n(reset_n), .clear(stop_all),
        .in_valid(mix_valid), .in_sample(mix_sample),
        .out_valid(pcm_valid), .out_sample(pcm),
        .limiting(limiting), .saturated(saturated));
    always @(posedge clk) begin
        if (state==FETCH) begin
            voice_data<=voice_ram[voice];
            frequency_word<=frequency_rom[voice];
            partial_data<=partial_ram[voice];
            dynamics_data<=dynamics[voice];
            profile<=instrument_mode==VIOLIN_MODE ? VIOLIN_PROFILE :
                     instrument_mode==DRUM_MODE ? drum_profile(voice) :
                     (BASS_VOICING ? voicing_rom[voice] : standard_profile);
            decay_data<=decay_rom[voice];
        end
        sine_value<=sine_rom[sine_address];
        sine_next<=sine_rom[sine_address+8'd1];
        if (state==ADD && env_state_reg!=0)
            partial_ram[voice]<={partial_levels,noise_lfsr,unison_phase,
                                strike_level,tone_level,voice_phases};
        if (state==COMMIT)
            voice_ram[voice]<={base_phase+voice_step, voice_env,
                              release_step_reg, env_state_reg};
        // Data pipelines need no reset or stop fanout. Valid bits/FSM flush
        // them; every operand is replaced before its next valid use.
        interpolation_product<=difference_reg * $signed({1'b0,fraction_reg});
        base2<=base1;
        weight2<=weight1;
        interpolated<=$signed(base2)+(interpolation_product >>> 8);
        weight3<=weight2;
        weighted_partial<=interpolated * $signed({1'b0,weight3});
        if(state==PREPARE) note_gain<=profile[98:88];
        if(state==ENV_PREP) begin
            harmonic_latched<=harmonic_sample +
                (instrument_mode==DRUM_MODE && voice>=24 ?
                 drum_noise(noise_lfsr,strike_level) :
                 (HAMMER_NOISE ? hammer_noise(noise_lfsr,strike_level) :
                  16'sd0));
            envelope_latched<=voice_env[23:8];
        end
        if(state==ENV_GAIN)
            envelope_product<=harmonic_latched*$signed({1'b0,envelope_latched});
        if(state==DYN_GAIN) begin
            dynamics_low_product<=enveloped_sample*
                                  $signed({1'b0,voice_dynamics[3:0]});
            dynamics_high_product<=enveloped_sample*
                                   $signed({1'b0,voice_dynamics[7:4]});
        end
        if(state==DYN_MERGE)
            dynamics_product<=
                $signed({{4{dynamics_low_product[20]}},dynamics_low_product})+
                ($signed({{4{dynamics_high_product[20]}},dynamics_high_product})<<<4);
        if(state==NOTE_GAIN)
            note_product<=dynamics_product*$signed({1'b0,note_gain});
    end
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state<=IDLE; voice<=0; harmonic<=1; gates<=0; pending<=0;
            mix_sample<=0; mix_valid<=0; mix_accum<=0; active_count<=0;
            active_voices<=0; deadline_error<=0; frame_pitch<=65536;
            base_phase<=0; phase_h<=0; voice_step<=0; freq_h<=0;
            voice_env<=0; voice_dynamics<=0;
            harmonic_sum<=0;
            valid_states<=0; release_step_reg<=0; env_state_reg<=0;
            voice_valid<=0; gate_reg<=0; trigger_reg<=0;
            ready_reg<=1; coefficient_reg<=0; brightness_reg<=0;
            bright_weight_reg<=0; alias_gain_reg<=0;
            difference_reg<=0; fraction_reg<=0; base1<=0;
            weight1<=0;
            partial_valid<=0; partial_last<=0;
            voice_phases<=0; partial_levels<=0; stiffness_step<=0;
            tone_level<=0; next_partial_phase<=0;
            strike_level<=0; previous_strike<=0;
            unison_phase<=0; previous_unison<=0;
            noise_lfsr<=16'h1ace; previous_noise<=16'h1ace;
            next_frequency_base<=0; next_frequency_stretch<=0;
            previous_tone<=0; tone_loss<=0; bass_voice<=0;
            bass_brightness_low<=0; bass_brightness_high<=0;
            normal_brightness<=0; weights<=0;
            state_snapshot<=0;
            voice_last<=0;
            voice_select<=0;
            voice_decay_step<=0; voice_decay_threshold<=0;
            sum_high_left<=0; sum_high_right<=0; sum_carry<=0;
            sum_high_valid<=0; sum_finish<=0;
        end else if (stop_all) begin
            state<=IDLE; gates<=0; pending<=0; mix_accum<=0;
            mix_sample<=0; mix_valid<=0; active_count<=0; active_voices<=0;
            valid_states<=0; voice_env<=0; env_state_reg<=0; base_phase<=0;
            partial_valid<=0; partial_last<=0;
            sum_high_valid<=0; sum_finish<=0;
            ready_reg<=1;
        end else if (instrument_change) begin
            // Preserve held gates, clear old voice state, and retrigger them.
            state<=IDLE; pending<=gates;
            mix_accum<=0; mix_sample<=0; mix_valid<=0; active_count<=0;
            active_voices<=0; valid_states<=0; voice_env<=0; env_state_reg<=0;
            base_phase<=0; partial_valid<=0; partial_last<=0;
            sum_high_valid<=0; sum_finish<=0; ready_reg<=1;
        end else begin
            mix_valid<=0;
            ready_reg<=!((state==IDLE && sample_tick) || (state==ADD && !voice_last));
            // Two ports of the same sine ROM read neighboring entries in one
            // cycle. A partial launches every two clocks; DSP stages overlap.
            partial_valid<={partial_valid[2:0], state==H1};
            partial_last<={partial_last[2:0], state==H1 && harmonic==8};
            // A partial arrives every two clocks. Split the 32-bit carry
            // chain across these two clocks without changing sample values.
            sum_high_valid<=partial_valid[3];
            sum_finish<=partial_valid[3] && partial_last[3];
            if(partial_valid[3]) begin
                harmonic_sum[15:0]<=low_sum[15:0];
                sum_high_left<=harmonic_sum[31:16];
                sum_high_right<=extended_partial[31:16];
                sum_carry<=low_sum[16];
            end
            if(sum_high_valid)
                harmonic_sum[31:16]<=sum_high_left+sum_high_right+sum_carry;
            if (event_valid && event_ready && event_note<88) begin
                gates[event_note]<=event_on;
                if (event_on) begin
                    pending[event_note]<=1;
                    dynamics[event_note]<=event_dynamics;
                end
            end
            if (sample_tick && state!=IDLE) deadline_error<=1;
            case (state)
                IDLE: if (sample_tick) begin
                    voice<=0; mix_accum<=0; active_count<=0;
                    frame_pitch<=pitch_ratio; state<=FETCH;
                end
                FETCH: begin
                    voice_valid<=valid_states[voice];
                    gate_reg<=instrument_mode==DRUM_MODE ? 1'b0 : gates[voice];
                    trigger_reg<=pending[voice];
                    pending[voice]<=0;
                    state<=PREPARE;
                end
                PREPARE: begin
                    state_snapshot<=voice_data;
                    voice_dynamics<=dynamics_data;
                    voice_decay_step<=decay_data[23:0];
                    voice_decay_threshold<=decay_data[47:24];
                    previous_tone<=partial_data[271:256];
                    previous_strike<=partial_data[287:272];
                    if(UNISON_BEAT) previous_unison<=partial_data[319:288];
                    previous_noise<=partial_data[335:320];
                    tone_loss<=partial_data[271:256]==0 ? 16'd0 :
                               partial_data[271:268]==0 ? 16'd1 :
                               {12'd0,partial_data[271:268]};
                    bass_voice<=BASS_VOICING && instrument_mode==PIANO_MODE && voice<36;
                    weights<=profile[87:0];
                    voice_select<=88'd1<<voice;
                    voice_last<=voice==87;
                    state<=DECODE;
                end
                DECODE: state<=LOAD;
                LOAD: begin
                    if (instrument_mode==DRUM_MODE) begin
                        // Drum notes are one-shots: a note-on starts at full
                        // level and each rendered frame drops by 1/16.
                        voice_env<=trigger_reg ? 24'hffffff :
                            (!voice_valid ||
                             state_snapshot[50:27]<=DRUM_DECAY_STEP) ?
                            24'd0 : state_snapshot[50:27]-DRUM_DECAY_STEP;
                        env_state_reg<=trigger_reg ? 3'd4 :
                            (!voice_valid ||
                             state_snapshot[50:27]<=DRUM_DECAY_STEP) ?
                            3'd0 : 3'd4;
                        release_step_reg<=DRUM_DECAY_STEP;
                    end else begin
                        voice_env<=next_env;
                        env_state_reg<=next_env_state;
                        release_step_reg<=next_release_step;
                    end
                    voice_step<=pitched_step;
                    stiffness_step<=stiffness_product[47:16];
                    voice_phases<=(trigger_reg || !voice_valid) ? 256'd0 :
                                  partial_data[255:0];
                    partial_levels<=(trigger_reg || !voice_valid) ?
                                    {192{1'b1}} : partial_data[527:336];
                    tone_level<=(trigger_reg || !voice_valid) ? 16'hffff :
                                previous_tone-tone_loss;
                    if (instrument_mode==DRUM_MODE)
                        strike_level<=(trigger_reg || !voice_valid) ? 16'hffff :
                                     (previous_strike>16'd256 ?
                                      previous_strike-16'd256 : 16'd0);
                    else
                        strike_level<=HAMMER_TRANSIENT &&
                                      instrument_mode==PIANO_MODE ?
                            ((trigger_reg || !voice_valid) ? 16'hffff :
                             (previous_strike>16'd128 ?
                              previous_strike-16'd128 : 16'd0)) : 16'd0;
                    if(UNISON_BEAT)
                        unison_phase<=(trigger_reg || !voice_valid) ?
                                      (32'h40000000+{9'd0,voice,16'd0}) :
                                      previous_unison+32'd44739+(pitched_step>>10);
                    noise_lfsr<=(trigger_reg || !voice_valid) ?
                                (16'h1ace+{9'd0,voice}) :
                                next_noise(previous_noise);
                    base_phase<=(trigger_reg || !voice_valid) ?
                                32'd0 : state_snapshot[82:51];
                    state<=COMMIT;
                end
                COMMIT: begin
                    valid_states<=valid_states|voice_select;
                    phase_h<=base_phase;
                    freq_h<={4'd0,voice_step};
                    harmonic<=1; harmonic_sum<=0;
                    coefficient_reg<=weights[10:0];
                    brightness_reg<=UNISON_BEAT ?
                        apply_unison(9'd256,unison_phase[31:24]) : 9'd256;
                    bass_brightness_low<=9'd192+{3'd0,tone_level[15:10]};
                    bass_brightness_high<=9'd64+{2'd0,tone_level[15:9]}+
                                               {3'd0,tone_level[15:10]};
                    normal_brightness<=9'd128+{1'b0,voice_env[23:17]};
                    if (env_state_reg!=0) begin
                        active_count<=active_count+1'b1; state<=H0;
                    end else state<=ADD;
                end
                H0: begin
                    bright_weight_reg<=bright_weight;
                    alias_gain_reg<=alias_gain;
                    next_partial_phase<=voice_phases[harmonic*32 +: 32];
                    next_frequency_base<=freq_h+{4'd0,voice_step};
                    next_frequency_stretch<=stretch_increment(harmonic+1'b1,
                                                              stiffness_step);
                    state<=H1;
                end
                H1: begin
                    difference_reg<=sine_difference;
                    fraction_reg<=phase_h[23:16];
                    base1<=$signed({sine_value[15],sine_value});
                    weight1<=safe_weight >> 8;
                    voice_phases[(harmonic-1)*32 +: 32]<=phase_h+freq_h[31:0];
                    if(PARTIAL_DECAY)
                        if(partial_levels[(harmonic-1)*24 +: 24] <=
                           (24'd1 << partial_decay_shift(harmonic)))
                            partial_levels[(harmonic-1)*24 +: 24]<=0;
                        else partial_levels[(harmonic-1)*24 +: 24]<=
                            partial_levels[(harmonic-1)*24 +: 24] -
                            (partial_levels[(harmonic-1)*24 +: 24] >>
                             partial_decay_shift(harmonic));
                    if (harmonic==8) state<=DRAIN;
                    else begin
                        harmonic<=harmonic+1'b1;
                        coefficient_reg<=weights[21:11];
                        weights<={11'd0,weights[87:11]};
                        if(PARTIAL_DECAY || UNISON_BEAT)
                            brightness_reg<=UNISON_BEAT ?
                                apply_unison(
                                    partial_brightness(harmonic+1'b1,
                                        voice_env,tone_level,
                                        partial_levels[harmonic*24 +: 24],
                                        bass_voice) +
                                    ((HAMMER_TRANSIENT && harmonic>=3) ?
                                     {2'd0,strike_level[15:9]} : 9'd0),
                                    unison_phase[31:24]) :
                                partial_brightness(harmonic+1'b1,
                                    voice_env,tone_level,
                                    partial_levels[harmonic*24 +: 24],
                                    bass_voice) +
                                ((HAMMER_TRANSIENT && harmonic>=3) ?
                                 {2'd0,strike_level[15:9]} : 9'd0);
                        else brightness_reg<=(bass_voice ? (harmonic<3 ?
                            bass_brightness_low : bass_brightness_high) :
                            normal_brightness) +
                            ((HAMMER_TRANSIENT && harmonic>=3) ?
                             {2'd0,strike_level[15:9]} : 9'd0);
                        phase_h<=next_partial_phase;
                        freq_h<=next_frequency_base+next_frequency_stretch;
                        state<=H0;
                    end
                end
                DRAIN: if (sum_finish) state<=ENV_PREP;
                ENV_PREP: state<=ENV_GAIN;
                ENV_GAIN: begin
                    state<=DYN_GAIN;
                end
                DYN_GAIN: begin
                    state<=DYN_MERGE;
                end
                DYN_MERGE: begin
                    state<=NOTE_GAIN;
                end
                NOTE_GAIN: begin
                    state<=ADD;
                end
                ADD: begin
                    if (env_state_reg!=0) mix_accum<=mix_accum+voice_sample;
                    if (voice_last) state<=FINISH;
                    else begin voice<=voice+1'b1; state<=FETCH; end
                end
                FINISH: begin
                    mix_sample<=mix_accum; mix_valid<=1;
                    active_voices<=active_count; state<=IDLE;
                end
                default: state<=IDLE;
            endcase
        end
    end
endmodule
