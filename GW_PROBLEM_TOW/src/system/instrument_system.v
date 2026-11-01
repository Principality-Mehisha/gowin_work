// Performance control and synthesis. Peripheral protocols live in the board shell.
module instrument_system #(
    parameter integer SD_SCORE_ENABLE = 0,
    parameter integer PRESSURE_ENABLE = 0,
    parameter integer PITCH_GROUP_STABLE_CYCLES = 50000,
    parameter integer PRESSURE_CALIBRATION_LOG2 = 5,
    parameter integer PRESSURE_SOFT_TOUCH_BOOST = 1,
    parameter integer PRESSURE_LONG_HOLD_FRAMES = 1042,
    parameter integer NOTE_GATE_CYCLES = 25000000,
    parameter integer NOTE_TAIL_CYCLES = 50000000,
    parameter SINE_FILE = "src/rom/sine256.hex",
    parameter FREQ_FILE = "src/rom/frequency88.hex",
    parameter VOICING_FILE = "src/rom/voicing88.hex",
    parameter MARIMBA_MODE_FILE = "src/rom/marimba48.hex",
    parameter MARIMBA_ATTACK_FILE = "src/rom/marimba_attack48.hex",
    // Frequency ROM is normalized for 48 kHz; compensate for this player's
    // actual DAC sample rate (configured by the board shell).
    parameter [17:0] DDS_PITCH_RATIO = 18'd193274
) (
    input wire sys_clk,
    input wire rst_n,
    input wire sample_tick,
    input wire [6:0] pitch_group,
    input wire pressure_sample_valid,
    input wire [3:0] pressure_sample_key,
    input wire [11:0] pressure_sample_data,
    input wire uart_play,
    input wire uart_stop,
    input wire uart_note_previous,
    input wire uart_note_next,
    input wire uart_note_play,
    input wire uart_select_piano,
    input wire uart_select_marimba,
    input wire [7:0] uart_track,
    input wire initialized,
    input wire file_found,
    input wire playing,
    input wire finished,
    input wire sequence_error,
    input wire [3:0] sd_error_code,
    input wire [3:0] fat_error,
    input wire [3:0] score_error,
    input wire [31:0] elapsed_ms,
    input wire dds_event_valid,
    input wire dds_event_on,
    input wire [6:0] dds_event_note,
    input wire [7:0] dds_event_dynamics,
    output wire [7:0] selected_track,
    output wire [7:0] last_error,
    output wire [6:0] selected_note,
    output wire selected_marimba,
    output wire [7:0] player_state,
    output wire sd_active,
    output wire storage_rst_n,
    output wire storage_paused,
    output wire dds_event_ready,
    output wire signed [15:0] pcm,
    output wire video_active,
    output wire [31:0] video_elapsed_ms,
    output wire [87:0] video_keys,
    output wire piano_audio_active,analysis_clear,
    output wire [7:0] LEDs
);
    // ringtone_active now means any selected SD score (including piano).
    wire ringtone_active;
    // Export the registered SD owner, never a busy/reset-gated UI status.
    assign sd_active=ringtone_active;
    wire instrument_request=uart_select_piano || uart_select_marimba;
    wire note_busy, note_clear;
    wire failed;
    wire manual_mode, uart_start, control_restart, play_rst_n;
    wire marimba_mode, ringtone_error, storage_enable;
    wire [7:0] control_error,control_state;
    wire pressure_enable,pressure_valid,pressure_on,pressure_update,pressure_ready;
    wire [6:0] pressure_note;
    wire [7:0] pressure_dynamics;
    wire [15:0] pressure_pressed,pressure_enabled_pressed,pressure_calibrated;
    wire [7:0] pressure_hold_progress;
    wire pressure_overflow,piano_busy,pressure_busy;
    reg pressure_fault;
    assign pressure_enable=PRESSURE_ENABLE && manual_mode && !selected_marimba &&
                           !note_busy && !control_restart && !pressure_fault;
    assign pressure_busy=pressure_enable && ((|pressure_enabled_pressed) || piano_busy);
    assign last_error=pressure_fault ? 8'h61 : control_error;
    assign player_state=pressure_fault ? 8'd3 : control_state;
    always @(posedge sys_clk or negedge rst_n) begin
        if(!rst_n) pressure_fault<=0;
        else if(control_restart) pressure_fault<=0;
        else if(pressure_enable && pressure_overflow) pressure_fault<=1;
    end
    generate if(PRESSURE_ENABLE) begin: pressure_input
        wire [6:0] base_note;
        pitch_group_select #(.STABLE_CYCLES(PITCH_GROUP_STABLE_CYCLES)) groups(
            .clk(sys_clk),.reset_n(rst_n),.pitch_group(pitch_group),
            .selected_group(),.base_note(base_note));
        pressure_keyboard #(.CALIBRATION_LOG2(PRESSURE_CALIBRATION_LOG2),
            .SOFT_TOUCH_BOOST(PRESSURE_SOFT_TOUCH_BOOST),
            .LONG_HOLD_FRAMES(PRESSURE_LONG_HOLD_FRAMES)) keyboard(
            .clk(sys_clk),.reset_n(rst_n),.enable(pressure_enable),
            .sample_valid(pressure_sample_valid),.sample_key(pressure_sample_key),
            .sample_data(pressure_sample_data),.base_note(base_note),
            .event_ready(pressure_ready),.event_valid(pressure_valid),.event_on(pressure_on),
            .event_update(pressure_update),.event_note(pressure_note),
            .event_dynamics(pressure_dynamics),.pressed(pressure_pressed),
            .enabled_pressed(pressure_enabled_pressed),.long_held(),
            .hold_progress(pressure_hold_progress),
            .calibrated(pressure_calibrated),.overflow(pressure_overflow));
    end else begin: no_pressure_input
        assign pressure_valid=0;assign pressure_on=0;assign pressure_update=0;
        assign pressure_note=0;assign pressure_dynamics=0;assign pressure_pressed=0;
        assign pressure_enabled_pressed=0;assign pressure_calibrated=0;
        assign pressure_hold_progress=0;
        assign pressure_overflow=0;
    end endgenerate
    playback_control #(.SD_SCORE_ENABLE(SD_SCORE_ENABLE)) control (
        .clk(sys_clk), .rst_n(rst_n),
        .uart_play(uart_play), .uart_stop(uart_stop), .uart_note_play(uart_note_play),
        .instrument_request(instrument_request), .audition_marimba(selected_marimba),
        .note_busy(note_busy || pressure_busy), .playing(playing), .finished(finished),
        .failed(failed), .sequence_error(sequence_error), .uart_track(uart_track),
        .sd_error_code(sd_error_code), .fat_error(fat_error), .score_error(score_error),
        .ringtone_active(ringtone_active), .ringtone_error(ringtone_error),
        .selected_track(selected_track), .last_error(control_error),
        .manual_mode(manual_mode), .uart_start(uart_start),
        .control_restart(control_restart), .play_rst_n(play_rst_n),
        .marimba_mode(marimba_mode), .storage_enable(storage_enable),
        .storage_rst_n(storage_rst_n), .player_state(control_state)
    );
    wire bank_event_ready;
    wire synth_event_ready = !control_restart && bank_event_ready;
    wire note_event_valid, note_event_on;
    wire [6:0] note_event_note;
    wire [7:0] note_event_dynamics;
    uart_note_audition #(.GATE_CYCLES(NOTE_GATE_CYCLES),.TAIL_CYCLES(NOTE_TAIL_CYCLES)) uart_notes (
        .clk(sys_clk),.rst_n(rst_n),.previous_request(uart_note_previous),
        .next_request(uart_note_next),.play_request(uart_note_play),
        .select_piano_request(uart_select_piano),.select_marimba_request(uart_select_marimba),
        .cancel(uart_start || uart_stop),
        .event_ready(manual_mode && note_busy && synth_event_ready),
        .selected_note(selected_note),.selected_marimba(selected_marimba),
        .event_valid(note_event_valid),.event_on(note_event_on),
        .event_note(note_event_note),.event_dynamics(note_event_dynamics),
        .busy(note_busy),.clear(note_clear));
    // Select UART audition or SD score events.
    wire synth_event_valid = !control_restart &&
                            (manual_mode ? (note_busy ? note_event_valid :
                             (pressure_enable && pressure_valid)) : dds_event_valid);
    wire synth_event_on = manual_mode ? (note_busy ? note_event_on : pressure_on) : dds_event_on;
    wire synth_event_update=manual_mode && !note_busy && pressure_enable && pressure_update;
    wire [6:0] synth_event_note = manual_mode ?
                                (note_busy ? note_event_note : pressure_note) : dds_event_note;
    wire [7:0] synth_event_dynamics = manual_mode ?
                                    (note_busy ? note_event_dynamics : pressure_dynamics) : dds_event_dynamics;
    assign pressure_ready=pressure_enable && synth_event_ready;
    wire deadline_error;
    // Stop and mute on any failed storage, format, sequence or compute check.
    // Decode storage errors once before distributing stop to all voices.
    // One 50 MHz cycle of detection latency avoids a decoder/high-fanout
    // combinational path into every synth register. Codes remain latched by
    // playback_control before it resets the storage stream.
    reg stream_error;
    always @(posedge sys_clk or negedge rst_n) begin
        if (!rst_n) stream_error <= 0;
        else if (control_restart || !storage_enable) stream_error <= 0;
        else stream_error <= (sd_error_code != 0 || fat_error != 0 || score_error != 0);
    end
    wire manual_error=deadline_error || pressure_fault || (pressure_enable && pressure_overflow);
    assign failed = (storage_enable && stream_error) || sequence_error || manual_error;
    wire synth_stop = control_restart || note_clear ||
                      (manual_mode ? manual_error : (failed || finished));
    wire audio_silence = (manual_mode ? manual_error :
                         (failed || finished || !playing));
    assign dds_event_ready = !manual_mode && synth_event_ready;
    wire signed [15:0] selected_pcm;
    assign pcm = audio_silence ? 16'sd0 : selected_pcm;
    instrument_voice_bank #(.LIVE_DYNAMICS(PRESSURE_ENABLE),
        .SINE_FILE(SINE_FILE),.FREQ_FILE(FREQ_FILE),.VOICING_FILE(VOICING_FILE),
        .MARIMBA_MODE_FILE(MARIMBA_MODE_FILE),.MARIMBA_ATTACK_FILE(MARIMBA_ATTACK_FILE)) voices (
        .clk(sys_clk),.reset_n(play_rst_n),.sample_tick(sample_tick),.stop_all(synth_stop),
        .marimba_mode(marimba_mode),
        .event_valid(synth_event_valid),.event_on(synth_event_on),.event_update(synth_event_update),
        .event_note(synth_event_note),
        .event_dynamics(synth_event_dynamics),.pitch_ratio(DDS_PITCH_RATIO),
        .event_ready(bank_event_ready),.deadline_error(deadline_error),.pcm(selected_pcm),
        .piano_busy(piano_busy));
    assign piano_audio_active=!marimba_mode && !audio_silence && !synth_stop &&
        (manual_mode ? (note_busy || pressure_busy) : playing);
    assign analysis_clear=synth_stop || !piano_audio_active;
    assign storage_paused=manual_mode || control_restart;
    // Numbered scores have no matching fixed look-ahead ROM. Keep PCM analysis,
    // but never attach the old fixed-song waterfall to an uploaded score.
    assign video_active = 1'b0;
    assign video_elapsed_ms = elapsed_ms;
    assign video_keys = 88'd0;
    // Active-low GPIO LEDs now show only pressure hold duration.
    assign LEDs = ~pressure_hold_progress;
endmodule
