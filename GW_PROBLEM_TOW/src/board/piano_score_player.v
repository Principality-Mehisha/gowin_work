// Integration layer for SD score playback, manual audition, synthesis and DAC.
// All modules run directly from the board's 50 MHz sys_clk.
module piano_score_player #(
    parameter integer SD_SCORE_ENABLE = 0,
    parameter integer DEFAULT_MARIMBA = 1,
    parameter integer UART_ENABLE = 1,
    parameter integer UART_CLK_HZ = 50000000,
    parameter integer UART_BAUD = 115200,//
    parameter integer UART_TIMEOUT_CYCLES = UART_CLK_HZ/50,
    parameter integer NOTE_GATE_CYCLES = 25000000,
    parameter integer NOTE_TAIL_CYCLES = 50000000,
    parameter integer POWER_ON_CYCLES = 65536,
    parameter integer DEBOUNCE_CYCLES = 1000000,
    parameter integer AUDIO_START_CYCLES = 2500000,
    parameter integer SD_POWER_WAIT_CYCLES = 500000,
    parameter integer SD_INIT_HALF_DIV = 63,
    parameter integer SD_READ_HALF_DIV = 63,
    parameter integer CLOCKS_PER_MS = 50000,
    parameter integer BCK_HALF_DIV = 48,
    parameter SINE_FILE = "src/rom/sine256.hex",
    parameter FREQ_FILE = "src/rom/frequency88.hex",
    parameter VOICING_FILE = "src/rom/voicing88.hex",
    parameter MARIMBA_MODE_FILE = "src/rom/marimba48.hex",
    parameter MARIMBA_ATTACK_FILE = "src/rom/marimba_attack48.hex",
    // Frequency ROM is normalized for 48 kHz; compensate for this player's
    // 50 MHz / BCK_HALF_DIV audio sample rate.
    parameter [17:0] DDS_PITCH_RATIO = 18'd193274
) (
    input wire sys_clk, KEY0, KEY1, KEY2,
    input wire uart_rx,
    output wire uart_tx,
    output wire HP_BCK, HP_WS, HP_DIN, PA_EN,
    output wire sd_cs_n, sd_sck, sd_mosi,
    input wire sd_miso,
    output wire [3:0] LEDs
);
    GSR GSR_INST (.GSRI(1'b1));
    wire rst_n;
    board_reset #(.POWER_ON_CYCLES(POWER_ON_CYCLES)) reset_controller (
        .clk(sys_clk), .key_reset_n(KEY2), .rst_n(rst_n)
    );
    wire replay_press, ringtone_press;
    button_debounce #(.STABLE_CYCLES(DEBOUNCE_CYCLES)) replay_button (
        .clk(sys_clk), .rst_n(rst_n), .key_n(KEY1), .press(replay_press)
    );
    button_debounce #(.STABLE_CYCLES(DEBOUNCE_CYCLES)) ringtone_button (
        .clk(sys_clk), .rst_n(rst_n), .key_n(KEY0), .press(ringtone_press)
    );
    // KEY2 is the active-low board reset; KEY1 remains the audition trigger.
    // ringtone_active now means any selected SD score (including piano).
    wire ringtone_active;
    wire [7:0] selected_track, last_error;
    wire uart_play, uart_stop;
    wire uart_note_previous, uart_note_next, uart_note_play;
    wire uart_select_piano, uart_select_marimba;
    wire selected_marimba;
    wire instrument_request=uart_select_piano || uart_select_marimba;
    wire note_busy, note_clear;
    wire [6:0] selected_note;
    wire [7:0] uart_track;
    wire uart_overflow;
    wire playing, finished, sequence_error;
    wire failed;
    wire [3:0] sd_error_code, fat_error, score_error;
    wire manual_mode, uart_start, control_restart, play_rst_n;
    wire marimba_mode, ringtone_error, storage_enable, storage_rst_n;
    wire [7:0] player_state;
    playback_control #(.SD_SCORE_ENABLE(SD_SCORE_ENABLE),
                       .DEFAULT_MARIMBA(DEFAULT_MARIMBA)) control (
        .clk(sys_clk), .rst_n(rst_n),
        .ringtone_press(ringtone_press), .replay_press(replay_press),
        .uart_play(uart_play), .uart_stop(uart_stop), .uart_note_play(uart_note_play),
        .instrument_request(instrument_request), .audition_marimba(selected_marimba),
        .note_busy(note_busy), .playing(playing), .finished(finished),
        .failed(failed), .sequence_error(sequence_error), .uart_track(uart_track),
        .sd_error_code(sd_error_code), .fat_error(fat_error), .score_error(score_error),
        .ringtone_active(ringtone_active), .ringtone_error(ringtone_error),
        .selected_track(selected_track), .last_error(last_error),
        .manual_mode(manual_mode), .uart_start(uart_start),
        .control_restart(control_restart), .play_rst_n(play_rst_n),
        .marimba_mode(marimba_mode), .storage_enable(storage_enable),
        .storage_rst_n(storage_rst_n), .player_state(player_state)
    );
    generate if (UART_ENABLE != 0) begin: uart_control
        uart_score_control #(.CLK_HZ(UART_CLK_HZ),.BAUD(UART_BAUD),
                             .TIMEOUT_CYCLES(UART_TIMEOUT_CYCLES)) link (
            .clk(sys_clk),.rst_n(rst_n),.rx(uart_rx),.tx(uart_tx),
            .player_state(player_state),.player_track(selected_track),
            .selected_note(selected_note),
            .selected_marimba(selected_marimba),
            .player_error(last_error),.play_request(uart_play),.stop_request(uart_stop),
            .note_previous(uart_note_previous),.note_next(uart_note_next),.note_play(uart_note_play),
            .note_select_piano(uart_select_piano),.note_select_marimba(uart_select_marimba),
            .requested_track(uart_track),.overflow(uart_overflow));
    end else begin: no_uart_control
        assign uart_tx=1'b1;
        assign uart_play=1'b0; assign uart_stop=1'b0;
        assign uart_track=0; assign uart_overflow=0;
        assign uart_note_previous=0; assign uart_note_next=0; assign uart_note_play=0;
        assign uart_select_piano=0; assign uart_select_marimba=0;
    end endgenerate
    wire initialized, file_found;
    wire [55:0] notes, velocities;
    wire [7:0] gates, triggers;
    wire [31:0] elapsed_ms;
    wire dds_event_valid, dds_event_on, dds_event_ready;
    wire [6:0] dds_event_note;
    wire [7:0] dds_event_dynamics;
    sd_score_stream #(
        .SD_POWER_WAIT_CYCLES(SD_POWER_WAIT_CYCLES),
        .SD_INIT_HALF_DIV(SD_INIT_HALF_DIV), .SD_READ_HALF_DIV(SD_READ_HALF_DIV),
        .CLOCKS_PER_MS(CLOCKS_PER_MS)
    ) score_stream (
        .clk(sys_clk), .rst_n(storage_rst_n), .paused(manual_mode || control_restart),
        .selected_track(selected_track),
        .sd_cs_n(sd_cs_n), .sd_sck(sd_sck), .sd_mosi(sd_mosi), .sd_miso(sd_miso),
        .dispatch_ready(dds_event_ready), .dispatch_valid(dds_event_valid),
        .dispatch_on(dds_event_on), .dispatch_note(dds_event_note),
        .dispatch_dynamics(dds_event_dynamics),
        .initialized(initialized), .file_found(file_found),
        .playing(playing), .finished(finished), .sequence_error(sequence_error),
        .sd_error_code(sd_error_code), .fat_error(fat_error), .score_error(score_error),
        .notes(notes), .velocities(velocities), .gates(gates), .triggers(triggers),
        .elapsed_ms(elapsed_ms)
    );
    wire piano_event_ready, marimba_event_ready;
    wire synth_event_ready = !control_restart &&
                            (marimba_mode ? marimba_event_ready : piano_event_ready);
    wire audition_event_valid, audition_event_on;
    wire [6:0] audition_event_note;
    wire [7:0] audition_event_dynamics;
    wire note_event_valid, note_event_on;
    wire [6:0] note_event_note;
    wire [7:0] note_event_dynamics;
    uart_note_audition #(.GATE_CYCLES(NOTE_GATE_CYCLES),.TAIL_CYCLES(NOTE_TAIL_CYCLES)) uart_notes (
        .clk(sys_clk),.rst_n(rst_n),.previous_request(uart_note_previous),
        .next_request(uart_note_next),.play_request(uart_note_play),
        .select_piano_request(uart_select_piano),.select_marimba_request(uart_select_marimba),
        .cancel(ringtone_press || uart_start || uart_stop || (replay_press && note_busy)),
        .event_ready(manual_mode && note_busy && synth_event_ready),
        .selected_note(selected_note),.selected_marimba(selected_marimba),
        .event_valid(note_event_valid),.event_on(note_event_on),
        .event_note(note_event_note),.event_dynamics(note_event_dynamics),
        .busy(note_busy),.clear(note_clear));
    // Select exactly one event source; the audition source is gated by mode.
    wire synth_event_valid = !control_restart &&
                            (manual_mode ? (note_busy ? note_event_valid : audition_event_valid) : dds_event_valid);
    wire synth_event_on = manual_mode ? (note_busy ? note_event_on : audition_event_on) : dds_event_on;
    wire [6:0] synth_event_note = manual_mode ? (note_busy ? note_event_note : audition_event_note) : dds_event_note;
    wire [7:0] synth_event_dynamics = manual_mode ? (note_busy ? note_event_dynamics : audition_event_dynamics) : dds_event_dynamics;
    wire piano_deadline_error, marimba_deadline_error;
    wire deadline_error = marimba_mode ? marimba_deadline_error : piano_deadline_error;
    // Stop and mute on any failed storage, format, sequence or compute check.
    wire stream_error = storage_enable &&
                        (sd_error_code != 0 || fat_error != 0 || score_error != 0);
    assign failed = stream_error || sequence_error || deadline_error;
    wire synth_stop = control_restart || note_clear ||
                      (manual_mode ? deadline_error : (failed || finished));
    wire audio_silence = manual_mode ? deadline_error :
                         (failed || finished || !playing);
    wire mode_active = manual_mode || (playing && !finished);
    key_audition #(.DEBOUNCE_CYCLES(DEBOUNCE_CYCLES)) audition (
        .clk(sys_clk), .reset_n(play_rst_n && manual_mode && !ringtone_active && !note_busy),
        .key_play_n(KEY1), .key_stop_n(1'b1),
        .note_first(marimba_mode ? 7'd36 : 7'd0),
        .note_last(marimba_mode ? 7'd77 : 7'd87),
        .event_ready(manual_mode && !note_busy && synth_event_ready),
        .event_valid(audition_event_valid), .event_on(audition_event_on),
        .event_note(audition_event_note), .event_dynamics(audition_event_dynamics),
        .stop_all()
    );
    assign dds_event_ready = !manual_mode && synth_event_ready;
    wire sample_tick;
    wire signed [15:0] piano_pcm, marimba_pcm;
    wire piano_pcm_valid, piano_limiting, piano_saturated;
    wire marimba_pcm_valid, marimba_limiting, marimba_saturated;
    wire signed [31:0] piano_mix_sample, marimba_mix_sample;
    wire signed [15:0] selected_pcm = marimba_mode ? marimba_pcm : piano_pcm;
    wire signed [15:0] pcm = audio_silence ? 16'sd0 : selected_pcm;
    wire signed [15:0] pcm_right = pcm;
    wire dds_sample_tick = sample_tick;
    generate if (DEFAULT_MARIMBA == 0 || SD_SCORE_ENABLE != 0 || UART_ENABLE != 0) begin: piano_path
    piano_synth #(
        .SINE_FILE(SINE_FILE), .FREQ_FILE(FREQ_FILE), .VOICING_FILE(VOICING_FILE)
    ) synth (
        .clk(sys_clk), .reset_n(play_rst_n),
        .sample_tick(dds_sample_tick), .stop_all(synth_stop),
        .event_valid(synth_event_valid && !marimba_mode), .event_on(synth_event_on),
        .event_note(synth_event_note), .event_dynamics(synth_event_dynamics),
        .pitch_ratio(DDS_PITCH_RATIO), .event_ready(piano_event_ready),
        .mix_sample(piano_mix_sample), .mix_valid(), .pcm(piano_pcm),
        .pcm_valid(piano_pcm_valid), .limiting(piano_limiting),
        .saturated(piano_saturated),
        .deadline_error(piano_deadline_error), .active_voices(),
        .debug_voice(), .debug_env_state(), .debug_envelope(), .debug_phase()
    );
    end else begin: no_piano_path
        assign piano_event_ready = 1'b1;
        assign piano_deadline_error = 1'b0;
        assign piano_pcm = 16'sd0;
        assign piano_pcm_valid = 1'b0;
        assign piano_limiting = 1'b0;
        assign piano_saturated = 1'b0;
        assign piano_mix_sample = 32'sd0;
    end endgenerate
    marimba_synth #(
        .SINE_FILE(SINE_FILE),
        .MODE_FILE(MARIMBA_MODE_FILE),
        .ATTACK_FILE(MARIMBA_ATTACK_FILE)
    ) marimba (
        .clk(sys_clk), .reset_n(play_rst_n),
        .sample_tick(dds_sample_tick), .stop_all(synth_stop),
        .event_valid(synth_event_valid && marimba_mode), .event_on(synth_event_on),
        .event_note(synth_event_note), .event_dynamics(synth_event_dynamics),
        .event_ready(marimba_event_ready),
        .mix_sample(marimba_mix_sample), .mix_valid(), .pcm(marimba_pcm),
        .pcm_valid(marimba_pcm_valid), .limiting(marimba_limiting),
        .saturated(marimba_saturated), .deadline_error(marimba_deadline_error)
    );
    pt8211_score_tx #(.BCK_HALF_DIV(BCK_HALF_DIV),
                      .AMP_START_CYCLES(AUDIO_START_CYCLES)) audio (
        .sys_clk(sys_clk), .sys_rst_n(rst_n),
        .pcm_left(pcm), .pcm_right(pcm_right),
        .sample_tick(sample_tick),
        .HP_BCK(HP_BCK), .HP_WS(HP_WS), .HP_DIN(HP_DIN), .PA_EN(PA_EN)
    );
    assign LEDs = ~{(ringtone_error || (manual_mode ? deadline_error : failed)), (mode_active || ringtone_active),
                    file_found, initialized};
endmodule
