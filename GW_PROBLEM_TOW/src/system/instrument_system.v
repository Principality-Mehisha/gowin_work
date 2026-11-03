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
    parameter integer AUDIO_FRAME_CYCLES = 3072,
    parameter integer AUDIO_CLOCK_HZ = 150000000,
    parameter integer AUDIO_SAMPLE_RATE_RATIO = 3,
    parameter SINE_FILE = "src/rom/sine256.hex",
    parameter FREQ_FILE = "src/rom/frequency88.hex",
    parameter VOICING_FILE = "src/rom/voicing88.hex",
    parameter MARIMBA_MODE_FILE = "src/rom/marimba48.hex",
    parameter MARIMBA_ATTACK_FILE = "src/rom/marimba_attack48.hex",
    // Frequency ROM is normalized for 48 kHz; compensate for this player's
    // actual DAC sample rate (configured by the board shell).
    parameter [17:0] DDS_PITCH_RATIO = 18'd64425
) (
    input wire sys_clk,
    input wire rst_n,
    input wire audio_clk,audio_pll_locked,
    input wire sample_tick,
    input wire signed [15:0] dac_sample_pcm,
    input wire [1:0] effect_mode,
    input wire [6:0] effect_amount,
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
    output wire video_active, video_clear,
    output wire [31:0] video_elapsed_ms,
    output wire [87:0] video_keys,
    output wire audio_analysis_active,analysis_clear,
    output wire analysis_sample_tick,
    output wire signed [15:0] analysis_sample_pcm,
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
    wire pressure_overflow,piano_busy,audio_busy,pressure_busy;
    reg pressure_fault;
    wire effect_fault,effect_tail,bridge_fault,audio_link_ready;
    assign pressure_enable=PRESSURE_ENABLE && audio_link_ready && manual_mode &&
                           !note_busy && !control_restart && !pressure_fault;
    assign pressure_busy=pressure_enable && ((|pressure_enabled_pressed) || audio_busy);
    assign last_error=bridge_fault ? 8'h63 : effect_fault ? 8'h62 : pressure_fault ? 8'h61 : control_error;
    assign player_state=pressure_fault || effect_fault || bridge_fault ? 8'd3 : control_state;
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
            .clk(sys_clk),.reset_n(rst_n),.enable(pressure_enable),.marimba_mode(selected_marimba),
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
    wire source_error=deadline_error || bridge_fault || pressure_fault || (pressure_enable && pressure_overflow) ||
                      (storage_enable && stream_error) || sequence_error;
    wire manual_error=source_error || effect_fault;
    assign failed = source_error || effect_fault;
    wire synth_stop = control_restart || note_clear ||
                      (manual_mode ? manual_error : (failed || finished));
    wire audio_silence = (manual_mode ? manual_error :
                         (failed || finished || !playing));
    assign dds_event_ready = !manual_mode && synth_event_ready;
    wire signed [15:0] selected_pcm;
    wire engine_reset_n,audio_config_valid;
    wire [15:0] audio_config;
    wire audio_event_valid,audio_event_on,audio_event_update,audio_event_ready;
    wire [6:0] audio_event_note;
    wire [7:0] audio_event_dynamics;
    wire audio_deadline_error,audio_effect_fault,audio_bank_busy,audio_piano_busy;
    wire returned_active,ack_valid,ack_on,ack_update,ack_marimba,ack_clear;
    wire [6:0] ack_note;
    wire [15:0] control_config={control_restart || source_error,synth_stop,
        (|pressure_enabled_pressed),note_busy,manual_mode,!audio_silence && !synth_stop,
        marimba_mode,effect_mode,effect_amount};
    wire source_active=audio_config_valid && audio_config[10] && !audio_config[14] &&
        !audio_deadline_error && !audio_effect_fault &&
        (!audio_config[11] || (audio_config[9] ? audio_bank_busy :
         (audio_config[12] || audio_config[13] || audio_bank_busy)));
    wire effect_clear=!audio_config_valid || audio_config[15] || audio_deadline_error;
    wire audio_output_active=!effect_clear && !audio_effect_fault && (source_active || effect_tail);
    audio_domain_bridge clock_bridge(
        .sys_clk(sys_clk),.audio_clk(audio_clk),.reset_n(rst_n),
        .pll_locked(audio_pll_locked),.restart(control_restart),.config_in(control_config),
        .event_valid(synth_event_valid),.event_on(synth_event_on),.event_update(synth_event_update),
        .event_note(synth_event_note),.event_dynamics(synth_event_dynamics),.event_ready(bank_event_ready),
        .link_ready_sys(audio_link_ready),
        .engine_reset_n(engine_reset_n),.audio_config(audio_config),.audio_config_valid(audio_config_valid),
        .audio_event_valid(audio_event_valid),.audio_event_on(audio_event_on),
        .audio_event_update(audio_event_update),.audio_event_note(audio_event_note),
        .audio_event_dynamics(audio_event_dynamics),.audio_event_ready(audio_event_ready),
        .dac_tick(sample_tick),.dac_pcm(dac_sample_pcm),.source_active(audio_output_active),
        .piano_busy(audio_piano_busy),.audio_busy(audio_bank_busy),
        .synth_fault(audio_deadline_error),.effect_fault(audio_effect_fault),
        .sample_valid(analysis_sample_tick),.sample_pcm(analysis_sample_pcm),.sample_active(returned_active),
        .piano_busy_sys(piano_busy),.audio_busy_sys(audio_busy),
        .synth_fault_sys(deadline_error),.effect_fault_sys(effect_fault),
        .ack_valid(ack_valid),.ack_on(ack_on),.ack_update(ack_update),
        .ack_marimba(ack_marimba),.ack_clear(ack_clear),.ack_note(ack_note),.bridge_fault(bridge_fault));
    instrument_voice_bank #(.LIVE_DYNAMICS(PRESSURE_ENABLE),
        .SAMPLE_RATE_RATIO(AUDIO_SAMPLE_RATE_RATIO),
        .SINE_FILE(SINE_FILE),.FREQ_FILE(FREQ_FILE),.VOICING_FILE(VOICING_FILE),
        .MARIMBA_MODE_FILE(MARIMBA_MODE_FILE),.MARIMBA_ATTACK_FILE(MARIMBA_ATTACK_FILE)) voices (
        .clk(audio_clk),.reset_n(engine_reset_n),.sample_tick(sample_tick),
        .stop_all(!audio_config_valid || audio_config[14] || audio_deadline_error || audio_effect_fault),
        .marimba_mode(audio_config[9]),
        .event_valid(audio_event_valid),.event_on(audio_event_on),.event_update(audio_event_update),
        .event_note(audio_event_note),
        .event_dynamics(audio_event_dynamics),.pitch_ratio(DDS_PITCH_RATIO),
        .event_ready(audio_event_ready),.deadline_error(audio_deadline_error),.pcm(selected_pcm),
        .piano_busy(audio_piano_busy),.audio_busy(audio_bank_busy));
    wire signed [15:0] effect_pcm;
    audio_effects #(.FRAME_CYCLES(AUDIO_FRAME_CYCLES),.CLOCK_HZ(AUDIO_CLOCK_HZ),
        .CONTROL_RATE_RATIO(AUDIO_SAMPLE_RATE_RATIO)) effects(
        .clk(audio_clk),.reset_n(engine_reset_n),.clear(effect_clear),.in_valid(sample_tick),
        .in_sample(source_active ? selected_pcm : 16'sd0),
        .mode(audio_config[8:7]),.amount(audio_config[6:0]),
        .out_sample(effect_pcm),.out_valid(),.busy(),.tail_active(effect_tail),
        .applied_mode(),.deadline_error(audio_effect_fault));
    // Break the UART/restart -> source gating -> DAC input timing path.
    // Effects complete well before the next audio frame; this adds one
    // system clock to gating without changing the DAC sample cadence.
    reg signed [15:0] pcm_registered;
    always @(posedge audio_clk or negedge engine_reset_n) begin
        if(!engine_reset_n)pcm_registered<=0;
        else pcm_registered<=effect_clear || audio_effect_fault || !(source_active || effect_tail) ?
                             16'sd0 : effect_pcm;
    end
    assign pcm=pcm_registered;
    // Natural release/score EOF stops the source, not an effect's tail.
    // Explicit transport/instrument commands still clear the entire chain.
    assign audio_analysis_active=!control_restart && !failed && returned_active;
    assign analysis_clear=control_restart || failed || !audio_analysis_active;
    assign storage_paused=manual_mode || control_restart || !audio_link_ready;
    // Observe only events actually accepted by the piano synthesizer. Updates
    // change pressure dynamics without making another note or ending its bar.
    reg [87:0] held_piano_keys;
    always @(posedge sys_clk or negedge play_rst_n) begin
        if(!play_rst_n) held_piano_keys<=0;
        else if(synth_stop || marimba_mode || (ack_valid && ack_clear)) held_piano_keys<=0;
        else if(ack_valid && !ack_update && !ack_marimba && ack_note<88)
            held_piano_keys[ack_note]<=ack_on;
    end
    // Release/tail expiry leaves the recent history scrolling. Explicit stop,
    // a new SD score, leaving SD for audition, instrument changes and errors
    // invalidate history, even if the command lasts less than one video frame.
    assign video_clear = uart_start || uart_stop || instrument_request ||
                         (uart_note_play && !manual_mode) || marimba_mode || failed;
    assign video_active = !marimba_mode && !failed;
    assign video_elapsed_ms = elapsed_ms;
    assign video_keys = held_piano_keys;
    // Active-low GPIO LEDs now show only pressure hold duration.
    assign LEDs = ~pressure_hold_progress;
endmodule
