module pressure_keyboard #(
    parameter integer CALIBRATION_LOG2=5,
    parameter integer FILTER_SHIFT=2,
    parameter integer PRESS_THRESHOLD=64,
    parameter integer RELEASE_THRESHOLD=32,
    parameter integer CONFIRM_FRAMES=3,
    parameter integer LONG_HOLD_FRAMES=1042,
    parameter integer DYNAMICS_SHIFT=3,
    parameter integer SOFT_TOUCH_BOOST=1
) (
    input wire clk, reset_n, sample_valid,
    input wire enable,
    input wire guide_mode,
    input wire marimba_mode,
    input wire [6:0] base_note,
    input wire [3:0] sample_key,
    input wire [11:0] sample_data,
    input wire event_ready,
    output wire event_valid, event_on, event_update,
    output wire [6:0] event_note,
    output wire [7:0] event_dynamics,
    output wire [15:0] pressed, long_held, calibrated,
    output wire [15:0] enabled_pressed,
    output wire [7:0] hold_progress,
    output wire overflow
);
    wire edge_valid, edge_on;
    wire [3:0] edge_key;
    wire [7:0] edge_gain;
    wire [127:0] gains;
    wire [191:0] forces;
    wire [127:0] key_hold_progress;
    // The highest piano group has eight keys; do not alias keys 9..16 to C8.
    wire pitch_valid=(!marimba_mode || base_note<48) &&
                     (!guide_mode || {1'b0,base_note}+{4'd0,edge_key}<88);
    wire [6:0] mapped_base=marimba_mode ? (base_note<48 ? 7'd36+base_note : 7'd36) : base_note;
    reg [15:0] armed;
    wire event_reset_n=reset_n && enable;
    assign enabled_pressed=pressed & armed;
    // Calibration stays alive in other modes. Held keys must be released
    // before rearming after an SD song, audition, stop or instrument switch.
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) armed<=0;
        else if(!enable) armed<=0;
        else begin
            armed<=armed | ~pressed;
            // Invalid marimba groups reject only new presses. Earlier held
            // notes retain their captured pitch, including their release.
            if(edge_valid && edge_on && !pitch_valid)armed[edge_key]<=0;
        end
    end
    pressure_keys #(.CALIBRATION_LOG2(CALIBRATION_LOG2),
        .FILTER_SHIFT(FILTER_SHIFT), .PRESS_THRESHOLD(PRESS_THRESHOLD),
        .RELEASE_THRESHOLD(RELEASE_THRESHOLD), .CONFIRM_FRAMES(CONFIRM_FRAMES),
        .LONG_HOLD_FRAMES(LONG_HOLD_FRAMES), .DYNAMICS_SHIFT(DYNAMICS_SHIFT),
        .SOFT_TOUCH_BOOST(SOFT_TOUCH_BOOST)) keys (
        .clk(clk), .reset_n(reset_n), .sample_valid(sample_valid),
        .sample_key(sample_key), .sample_data(sample_data),
        .calibrated(calibrated), .pressed(pressed), .long_held(long_held),
        .gains(gains), .forces(forces), .edge_valid(edge_valid),
        .hold_progress(key_hold_progress),
        .edge_on(edge_on), .edge_key(edge_key), .edge_gain(edge_gain));
    genvar level,key;
    generate for(level=0;level<8;level=level+1) begin: hold_bar
        wire [15:0] held_at_level;
        for(key=0;key<16;key=key+1) begin: eligible_keys
            assign held_at_level[key]=enabled_pressed[key] && key_hold_progress[key*8+level];
        end
        // OR of per-key thresholds equals the longest currently held key,
        // without a cascaded 16-key maximum comparator.
        assign hold_progress[level]=enable && (&calibrated) && (|held_at_level);
    end endgenerate
    wire raw_valid, raw_on, raw_update, raw_ready;
    wire [3:0] raw_key;
    wire [6:0] raw_note;
    wire [7:0] raw_dynamics;
    pressure_events events (
        .clk(clk), .reset_n(event_reset_n), .base_note(mapped_base),
        .edge_valid(edge_valid && armed[edge_key] && (!edge_on || pitch_valid)), .edge_on(edge_on),
        .edge_key(edge_key), .edge_gain(edge_gain), .pressed(enabled_pressed), .gains(gains),
        .event_ready(raw_ready), .event_valid(raw_valid), .event_on(raw_on),
        .event_update(raw_update), .event_key(raw_key), .event_note(raw_note),
        .event_dynamics(raw_dynamics), .overflow(overflow));
    pressure_note_merge notes (
        .clk(clk), .reset_n(event_reset_n), .input_valid(raw_valid), .input_on(raw_on),
        .input_update(raw_update), .input_key(raw_key), .input_note(raw_note),
        .input_dynamics(raw_dynamics), .input_ready(raw_ready),
        .event_valid(event_valid), .event_on(event_on), .event_update(event_update),
        .event_note(event_note), .event_dynamics(event_dynamics), .event_ready(event_ready));
endmodule
