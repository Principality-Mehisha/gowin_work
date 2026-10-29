// One globally selected timbre, independent algorithm state, one output limiter.
module instrument_voice_bank #(
    parameter SINE_FILE="src/rom/sine256.hex",
    parameter FREQ_FILE="src/rom/frequency88.hex",
    parameter VOICING_FILE="src/rom/voicing88.hex",
    parameter MARIMBA_MODE_FILE="src/rom/marimba48.hex",
    parameter MARIMBA_ATTACK_FILE="src/rom/marimba_attack48.hex"
) (
    input wire clk,reset_n,sample_tick,stop_all,
    input wire marimba_mode,
    input wire event_valid,event_on,
    input wire [6:0] event_note,
    input wire [7:0] event_dynamics,
    input wire [17:0] pitch_ratio,
    output wire event_ready,deadline_error,
    output wire signed [15:0] pcm,
    output wire pcm_valid,limiting,saturated
);
    wire piano_selected=!marimba_mode;
    wire marimba_selected=marimba_mode;
    wire piano_ready,marimba_ready;
    wire piano_deadline,marimba_deadline;
    wire signed [31:0] piano_mix,marimba_mix;
    wire piano_valid,marimba_valid;
    piano_synth #(.EXTERNAL_LIMITER(1),.SINE_FILE(SINE_FILE),
        .FREQ_FILE(FREQ_FILE),.VOICING_FILE(VOICING_FILE)) piano (
        .clk(clk),.reset_n(reset_n),.sample_tick(sample_tick && piano_selected),.stop_all(stop_all),
        .event_valid(event_valid && piano_selected),.event_on(event_on),.event_note(event_note),
        .event_dynamics(event_dynamics),.pitch_ratio(pitch_ratio),.event_ready(piano_ready),
        .mix_sample(piano_mix),.mix_valid(piano_valid),.deadline_error(piano_deadline));
    marimba_synth #(.EXTERNAL_LIMITER(1),.SINE_FILE(SINE_FILE),
        .MODE_FILE(MARIMBA_MODE_FILE),.ATTACK_FILE(MARIMBA_ATTACK_FILE)) marimba (
        .clk(clk),.reset_n(reset_n),.sample_tick(sample_tick && marimba_selected),.stop_all(stop_all),
        .event_valid(event_valid && marimba_selected),.event_on(event_on),.event_note(event_note),
        .event_dynamics(event_dynamics),.event_ready(marimba_ready),
        .output_mix(marimba_mix),.output_mix_valid(marimba_valid),.deadline_error(marimba_deadline));
    assign event_ready=marimba_mode ? marimba_ready : piano_ready;
    assign deadline_error=marimba_mode ? marimba_deadline : piano_deadline;
    wire signed [31:0] selected_mix=marimba_mode ? marimba_mix : piano_mix;
    wire selected_valid=marimba_mode ? marimba_valid : piano_valid;
    output_limiter limiter (
        .clk(clk),.reset_n(reset_n),.clear(stop_all),
        .in_valid(selected_valid),.in_sample(selected_mix),.out_valid(pcm_valid),
        .out_sample(pcm),.limiting(limiting),.saturated(saturated));
endmodule
