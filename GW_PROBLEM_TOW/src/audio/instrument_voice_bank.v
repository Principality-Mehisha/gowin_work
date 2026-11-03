// One globally selected timbre, independent algorithm state, one output limiter.
module instrument_voice_bank #(
    parameter integer LIVE_DYNAMICS=0,
    parameter integer SAMPLE_RATE_RATIO=1,
    parameter SINE_FILE="src/rom/sine256.hex",
    parameter FREQ_FILE="src/rom/frequency88.hex",
    parameter VOICING_FILE="src/rom/voicing88.hex",
    parameter MARIMBA_MODE_FILE="src/rom/marimba48.hex",
    parameter MARIMBA_ATTACK_FILE="src/rom/marimba_attack48.hex"
) (
    input wire clk,reset_n,sample_tick,stop_all,
    input wire marimba_mode,
    input wire event_valid,event_on,
    input wire event_update,
    input wire [6:0] event_note,
    input wire [7:0] event_dynamics,
    input wire [17:0] pitch_ratio,
    output wire event_ready,deadline_error,
    output wire signed [15:0] pcm,
    output wire pcm_valid,limiting,saturated,piano_busy,audio_busy
);
    wire piano_selected=!marimba_mode;
    wire marimba_selected=marimba_mode;
    wire piano_ready,marimba_ready;
    wire piano_deadline,marimba_deadline;
    wire signed [31:0] piano_mix,marimba_mix;
    wire piano_valid,marimba_valid;
    wire [6:0] piano_active_voices;
    wire marimba_busy;
    wire [7:0] piano_sine_address,marimba_sine_address;
    wire piano_sine_enable,marimba_sine_enable;
    wire signed [15:0] sine_value,sine_next;
    sine_pair_rom #(.SINE_FILE(SINE_FILE)) shared_wave(
        .clk(clk),.enable(marimba_mode ? marimba_sine_enable : piano_sine_enable),
        .address(marimba_mode ? marimba_sine_address : piano_sine_address),
        .value(sine_value),.next_value(sine_next));
    localparam TAIL_BITS=$clog2(128*SAMPLE_RATE_RATIO+1);
    reg [TAIL_BITS-1:0] marimba_tail;
    assign piano_busy=piano_active_voices!=0;
    // Preserve the final mixed sample and body/filter/limiter decay for 128
    // more audio frames after the last modal/noise state becomes inactive.
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n)marimba_tail<=0;
        else if(stop_all || !marimba_mode)marimba_tail<=0;
        else if(marimba_busy)marimba_tail<=128*SAMPLE_RATE_RATIO;
        else if(sample_tick && marimba_tail!=0)marimba_tail<=marimba_tail-1'b1;
    end
    assign audio_busy=marimba_mode ? (marimba_busy || marimba_tail!=0) : piano_busy;
    piano_synth #(.EXTERNAL_LIMITER(1),.EXTERNAL_SINE(1),.LIVE_DYNAMICS(LIVE_DYNAMICS),
        .SAMPLE_RATE_RATIO(SAMPLE_RATE_RATIO),.SINE_FILE(SINE_FILE),
        .FREQ_FILE(FREQ_FILE),.VOICING_FILE(VOICING_FILE)) piano (
        .clk(clk),.reset_n(reset_n),.sample_tick(sample_tick && piano_selected),.stop_all(stop_all),
        .event_valid(event_valid && piano_selected),.event_on(event_on),.event_update(event_update),
        .event_note(event_note),
        .event_dynamics(event_dynamics),.pitch_ratio(pitch_ratio),.event_ready(piano_ready),
        .mix_sample(piano_mix),.mix_valid(piano_valid),.deadline_error(piano_deadline),
        .active_voices(piano_active_voices),
        .sine_read_address(piano_sine_address),.sine_read_enable(piano_sine_enable),
        .external_sine_value(sine_value),.external_sine_next(sine_next));
    marimba_synth #(.EXTERNAL_LIMITER(1),.EXTERNAL_SINE(1),
        .SAMPLE_RATE_RATIO(SAMPLE_RATE_RATIO),.SINE_FILE(SINE_FILE),
        .MODE_FILE(MARIMBA_MODE_FILE),.ATTACK_FILE(MARIMBA_ATTACK_FILE)) marimba (
        .clk(clk),.reset_n(reset_n),.sample_tick(sample_tick && marimba_selected),.stop_all(stop_all),
        .event_valid(event_valid && marimba_selected && !event_update),
        .event_on(event_on),.event_note(event_note),
        .event_dynamics(event_dynamics),.event_ready(marimba_ready),
        .output_mix(marimba_mix),.output_mix_valid(marimba_valid),.deadline_error(marimba_deadline),
        .voice_busy(marimba_busy),
        .sine_read_address(marimba_sine_address),.sine_read_enable(marimba_sine_enable),
        .external_sine_value(sine_value),.external_sine_next(sine_next));
    assign event_ready=marimba_mode ? marimba_ready : piano_ready;
    assign deadline_error=marimba_mode ? marimba_deadline : piano_deadline;
    wire signed [31:0] selected_mix=marimba_mode ? marimba_mix : piano_mix;
    wire selected_valid=marimba_mode ? marimba_valid : piano_valid;
    output_limiter #(.SAMPLE_RATE_RATIO(SAMPLE_RATE_RATIO)) limiter (
        .clk(clk),.reset_n(reset_n),.clear(stop_all),
        .in_valid(selected_valid),.in_sample(selected_mix),.out_valid(pcm_valid),
        .out_sample(pcm),.limiting(limiting),.saturated(saturated));
endmodule
