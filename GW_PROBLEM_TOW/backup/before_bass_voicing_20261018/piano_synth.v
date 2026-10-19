// 88 independent note states, one shared time-multiplexed 8-partial datapath.
// event_note=0..87 means A0..C8; note-off addresses the original note.
module piano_synth #(
    parameter SINE_FILE="src/rom/sine256.hex",
    parameter FREQ_FILE="src/rom/frequency88.hex",
    parameter [23:0] ATTACK_STEP=24'd69906,
    parameter [23:0] DECAY_STEP=24'd711,
    parameter [23:0] SUSTAIN_LEVEL=24'd3145728,
    parameter integer RELEASE_SHIFT=14
) (
    input wire clk, reset_n, sample_tick, stop_all,
    input wire event_valid, event_on,
    input wire [6:0] event_note,
    input wire [7:0] event_dynamics,
    // Unsigned Q2.16 global pitch multiplier; 65536 is concert pitch.
    input wire [17:0] pitch_ratio,
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
    localparam IDLE=0, LOAD=1, H0=2, H1=3, H2=4, ENV_GAIN=5,
               DYN_GAIN=6, ADD=7, FINISH=8, FETCH=9, COMMIT=10, DRAIN=11, DECODE=12;
    reg [3:0] state;
    reg [6:0] voice;
    reg [3:0] harmonic;
    reg [87:0] gates, pending;
    reg [7:0] dynamics [0:87];
    // One synchronous state RAM; clearing validity avoids resetting RAM cells.
    // Packed state: {phase[31:0], envelope[23:0], release_step[23:0], state[2:0]}.
    reg [82:0] voice_ram [0:127];
    reg [82:0] voice_data;
    reg [87:0] valid_states;
    reg [31:0] frequency_word;
    reg [23:0] release_step_reg;
    reg [2:0] env_state_reg;
    reg voice_valid, gate_reg, trigger_reg;
    reg ready_reg;
    reg [31:0] frequency_rom [0:87];
    reg signed [15:0] sine_rom [0:255];
    initial begin
        $readmemh(SINE_FILE, sine_rom);
        $readmemh(FREQ_FILE, frequency_rom);
    end
    reg [31:0] base_phase, phase_h, voice_step;
    reg [35:0] freq_h;
    reg [23:0] voice_env;
    reg [7:0] voice_dynamics;
    reg signed [15:0] first_sine;
    reg signed [16:0] interpolated;
    reg signed [31:0] harmonic_sum;
    reg signed [32:0] envelope_product;
    reg signed [24:0] dynamics_product;
    reg signed [31:0] mix_accum;
    reg [6:0] active_count;
    reg [17:0] frame_pitch;
    wire [49:0] pitch_product = frequency_word * frame_pitch;
    wire [31:0] pitched_step = pitch_product[47:16];
    wire [2:0] next_env_state;
    wire [23:0] next_env, next_release_step;
    adsr_pipeline #(.ATTACK_STEP(ATTACK_STEP), .DECAY_STEP(DECAY_STEP),
        .SUSTAIN_LEVEL(SUSTAIN_LEVEL), .RELEASE_SHIFT(RELEASE_SHIFT)) envelope_unit (
        .clk(clk), .capture(state==DECODE), .gate(gate_reg), .trigger(trigger_reg),
        .valid_in(voice_valid),
        .state_in(voice_data[2:0]),
        .level_in(voice_data[50:27]),
        .release_step_in(voice_data[26:3]),
        .state_out(next_env_state), .level_out(next_env),
        .release_step_out(next_release_step));
    function [10:0] partial_weight;
        input [3:0] number;
        begin
            case (number)
                1: partial_weight=420; 2: partial_weight=220;
                3: partial_weight=140; 4: partial_weight=90;
                5: partial_weight=60; 6: partial_weight=42;
                7: partial_weight=30; 8: partial_weight=22;
                default: partial_weight=0;
            endcase
        end
    endfunction
    reg [10:0] coefficient_reg;
    reg [8:0] brightness_reg;
    wire [19:0] bright_weight = coefficient_reg * brightness_reg;
    wire [8:0] fade_weight = 9'd0 - freq_h[28:20] - (|freq_h[19:0]);
    wire [8:0] alias_gain = freq_h >= 36'h080000000 ? 9'd0 :
                           freq_h <= 36'h070000000 ? 9'd256 :
                           fade_weight;
    reg [19:0] bright_weight_reg;
    reg [8:0] alias_gain_reg;
    wire [19:0] safe_weight = (bright_weight_reg >> 8) * alias_gain_reg;
    wire [7:0] sine_address = state==H1 ? phase_h[31:24]+8'd1 : phase_h[31:24];
    reg signed [15:0] sine_value;
    wire signed [16:0] sine_difference =
        $signed({sine_value[15],sine_value}) - $signed({first_sine[15],first_sine});
    reg signed [16:0] difference_reg, base1, base2;
    reg [7:0] fraction_reg;
    reg signed [25:0] interpolation_product;
    reg [10:0] weight1, weight2, weight3;
    reg signed [27:0] weighted_partial;
    reg [3:0] partial_valid, partial_last;
    wire signed [15:0] harmonic_sample = harmonic_sum >>> 10;
    wire signed [15:0] enveloped_sample = envelope_product >>> 16;
    wire signed [31:0] voice_sample = dynamics_product >>> 8;
    // FETCH snapshots gates and consumes trigger flags atomically.
    assign event_ready = ready_reg && !stop_all && reset_n;
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
        end
        sine_value<=sine_rom[sine_address];
        if (state==COMMIT && reset_n && !stop_all)
            voice_ram[voice]<={base_phase+voice_step, voice_env,
                              release_step_reg, env_state_reg};
    end
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state<=IDLE; voice<=0; harmonic<=1; gates<=0; pending<=0;
            mix_sample<=0; mix_valid<=0; mix_accum<=0; active_count<=0;
            active_voices<=0; deadline_error<=0; frame_pitch<=65536;
            base_phase<=0; phase_h<=0; voice_step<=0; freq_h<=0;
            voice_env<=0; voice_dynamics<=0; first_sine<=0;
            interpolated<=0; harmonic_sum<=0; envelope_product<=0; dynamics_product<=0;
            valid_states<=0; release_step_reg<=0; env_state_reg<=0;
            voice_valid<=0; gate_reg<=0; trigger_reg<=0;
            ready_reg<=1; coefficient_reg<=0; brightness_reg<=0;
            bright_weight_reg<=0; alias_gain_reg<=0;
            difference_reg<=0; fraction_reg<=0; base1<=0; base2<=0;
            interpolation_product<=0; weight1<=0; weight2<=0; weight3<=0;
            weighted_partial<=0; partial_valid<=0; partial_last<=0;
        end else if (stop_all) begin
            state<=IDLE; gates<=0; pending<=0; mix_accum<=0;
            mix_sample<=0; mix_valid<=0; active_count<=0; active_voices<=0;
            valid_states<=0; voice_env<=0; env_state_reg<=0; base_phase<=0;
            partial_valid<=0; partial_last<=0;
            ready_reg<=1;
        end else begin
            mix_valid<=0;
            ready_reg<=!((state==IDLE && sample_tick) || (state==ADD && voice!=87));
            // Two reads per partial, with multiplication and summing pipelined.
            partial_valid<={partial_valid[2:0], state==H2};
            partial_last<={partial_last[2:0], state==H2 && harmonic==8};
            interpolation_product<=difference_reg * $signed({1'b0,fraction_reg});
            base2<=base1;
            weight2<=weight1;
            interpolated<=$signed(base2)+(interpolation_product >>> 8);
            weight3<=weight2;
            weighted_partial<=interpolated * $signed({1'b0,weight3});
            if (partial_valid[3]) harmonic_sum<=harmonic_sum+weighted_partial;
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
                    gate_reg<=gates[voice];
                    trigger_reg<=pending[voice];
                    pending[voice]<=0;
                    state<=DECODE;
                end
                DECODE: state<=LOAD;
                LOAD: begin
                    voice_env<=next_env;
                    env_state_reg<=next_env_state;
                    release_step_reg<=next_release_step;
                    voice_dynamics<=dynamics[voice];
                    voice_step<=pitched_step;
                    base_phase<=(trigger_reg || !voice_valid) ?
                                32'd0 : voice_data[82:51];
                    state<=COMMIT;
                end
                COMMIT: begin
                    valid_states[voice]<=1;
                    phase_h<=base_phase;
                    freq_h<={4'd0,voice_step};
                    harmonic<=1; harmonic_sum<=0;
                    coefficient_reg<=420; brightness_reg<=256;
                    if (env_state_reg!=0) begin
                        active_count<=active_count+1'b1; state<=H0;
                    end else state<=ADD;
                end
                H0: begin
                    bright_weight_reg<=bright_weight;
                    alias_gain_reg<=alias_gain;
                    state<=H1;
                end
                H1: begin
                    first_sine<=sine_value;
                    state<=H2;
                end
                H2: begin
                    difference_reg<=sine_difference;
                    fraction_reg<=phase_h[23:16];
                    base1<=$signed({first_sine[15],first_sine});
                    weight1<=safe_weight >> 8;
                    if (harmonic==8) state<=DRAIN;
                    else begin
                        harmonic<=harmonic+1'b1;
                        coefficient_reg<=partial_weight(harmonic+1'b1);
                        brightness_reg<=9'd128+{1'b0,voice_env[23:17]};
                        phase_h<=phase_h+base_phase;
                        freq_h<=freq_h+{4'd0,voice_step};
                        state<=H0;
                    end
                end
                DRAIN: if (partial_valid[3] && partial_last[3]) state<=ENV_GAIN;
                ENV_GAIN: begin
                    envelope_product <= harmonic_sample *
                                        $signed({1'b0,voice_env[23:8]});
                    state<=DYN_GAIN;
                end
                DYN_GAIN: begin
                    dynamics_product <= enveloped_sample *
                                        $signed({1'b0,voice_dynamics});
                    state<=ADD;
                end
                ADD: begin
                    if (voice_env!=0) mix_accum<=mix_accum+voice_sample;
                    if (voice==87) state<=FINISH;
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
