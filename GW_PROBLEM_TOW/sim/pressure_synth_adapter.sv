// Test-only adapter for the imported piano-pressure regression benches.
module instrument_synth #(
    parameter integer LIVE_DYNAMICS=0,
    parameter [23:0] ATTACK_STEP=24'd69906,
    parameter [23:0] DECAY_STEP=24'd711,
    parameter [23:0] SUSTAIN_LEVEL=24'd3145728,
    parameter integer RELEASE_SHIFT=14
) (
    input wire clk,reset_n,sample_tick,stop_all,
    input wire [1:0] instrument_id,
    input wire event_valid,event_on,event_update,
    input wire [6:0] event_note,
    input wire [7:0] event_dynamics,
    input wire [17:0] pitch_ratio,
    output wire event_ready,pcm_valid,deadline_error,saturated,limiting,unsupported_instrument,
    output wire signed [15:0] pcm,
    output wire signed [31:0] mix_sample,
    output wire mix_valid,
    output wire [6:0] active_voices,debug_voice,
    output wire [2:0] debug_env_state,
    output wire [23:0] debug_envelope,
    output wire [31:0] debug_phase
);
    assign unsupported_instrument=instrument_id!=0;
    piano_synth #(.LIVE_DYNAMICS(LIVE_DYNAMICS),.ATTACK_STEP(ATTACK_STEP),
        .DECAY_STEP(DECAY_STEP),.SUSTAIN_LEVEL(SUSTAIN_LEVEL),.RELEASE_SHIFT(RELEASE_SHIFT)) piano(
        .clk(clk),.reset_n(reset_n),.sample_tick(sample_tick),.stop_all(stop_all),
        .event_valid(event_valid),.event_on(event_on),.event_update(event_update),
        .event_note(event_note),.event_dynamics(event_dynamics),.pitch_ratio(pitch_ratio),
        .event_ready(event_ready),.pcm(pcm),.pcm_valid(pcm_valid),.deadline_error(deadline_error),
        .saturated(saturated),.limiting(limiting),.mix_sample(mix_sample),.mix_valid(mix_valid),
        .active_voices(active_voices),.debug_voice(debug_voice),.debug_env_state(debug_env_state),
        .debug_envelope(debug_envelope),.debug_phase(debug_phase));
endmodule
