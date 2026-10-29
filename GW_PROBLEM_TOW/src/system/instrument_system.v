// Performance control and synthesis. Peripheral protocols live in the board shell.
module instrument_system #(
    parameter integer SD_SCORE_ENABLE = 0,
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
    output wire storage_rst_n,
    output wire storage_paused,
    output wire dds_event_ready,
    output wire signed [15:0] pcm,
    output wire video_active,
    output wire [31:0] video_elapsed_ms,
    output reg [87:0] video_keys,
    output wire [3:0] LEDs
);
    // ringtone_active now means any selected SD score (including piano).
    wire ringtone_active;
    wire instrument_request=uart_select_piano || uart_select_marimba;
    wire note_busy, note_clear;
    wire failed;
    wire manual_mode, uart_start, control_restart, play_rst_n;
    wire marimba_mode, ringtone_error, storage_enable;
    playback_control #(.SD_SCORE_ENABLE(SD_SCORE_ENABLE)) control (
        .clk(sys_clk), .rst_n(rst_n),
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
                            (manual_mode ? (note_busy && note_event_valid) : dds_event_valid);
    wire synth_event_on = manual_mode ? note_event_on : dds_event_on;
    wire [6:0] synth_event_note = manual_mode ? note_event_note : dds_event_note;
    wire [7:0] synth_event_dynamics = manual_mode ? note_event_dynamics : dds_event_dynamics;
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
    assign failed = (storage_enable && stream_error) || sequence_error || deadline_error;
    wire synth_stop = control_restart || note_clear ||
                      (manual_mode ? deadline_error : (failed || finished));
    wire audio_silence = (manual_mode ? deadline_error :
                         (failed || finished || !playing));
    wire mode_active = manual_mode || (playing && !finished);
    assign dds_event_ready = !manual_mode && synth_event_ready;
    wire signed [15:0] selected_pcm;
    assign pcm = audio_silence ? 16'sd0 : selected_pcm;
    instrument_voice_bank #(.SINE_FILE(SINE_FILE),.FREQ_FILE(FREQ_FILE),.VOICING_FILE(VOICING_FILE),
        .MARIMBA_MODE_FILE(MARIMBA_MODE_FILE),.MARIMBA_ATTACK_FILE(MARIMBA_ATTACK_FILE)) voices (
        .clk(sys_clk),.reset_n(play_rst_n),.sample_tick(sample_tick),.stop_all(synth_stop),
        .marimba_mode(marimba_mode),
        .event_valid(synth_event_valid),.event_on(synth_event_on),.event_note(synth_event_note),
        .event_dynamics(synth_event_dynamics),.pitch_ratio(DDS_PITCH_RATIO),
        .event_ready(bank_event_ready),.deadline_error(deadline_error),.pcm(selected_pcm));
    assign storage_paused=manual_mode || control_restart;
    // Display observes the same accepted events/time used by the piano synth.
    assign video_active = storage_enable && selected_track==3 && playing &&
                          !finished && !failed && !control_restart;
    assign video_elapsed_ms = elapsed_ms;
    always @(posedge sys_clk or negedge rst_n) begin
        if (!rst_n) video_keys <= 0;
        else if (!video_active || synth_stop) video_keys <= 0;
        else if (synth_event_valid && synth_event_ready && synth_event_note<88)
            video_keys[synth_event_note] <= synth_event_on;
    end
    assign LEDs = ~{(ringtone_error || (manual_mode ? deadline_error : failed)), (mode_active || ringtone_active),
                    file_found, initialized};
endmodule
