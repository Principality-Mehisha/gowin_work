// Integration layer for SD score playback, manual audition, synthesis and DAC.
// All modules run directly from the board's 50 MHz sys_clk.
module piano_score_player #(
    parameter integer SD_SCORE_ENABLE = 0,
    parameter integer DEFAULT_MARIMBA = 1,
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
    output wire HP_BCK, HP_WS, HP_DIN, PA_EN,
    output wire sd_cs_n, sd_sck, sd_mosi,
    input wire sd_miso,
    output wire [3:0] LEDs
);
    GSR GSR_INST (.GSRI(1'b1));
    reg [31:0] power_count = 0;
    always @(posedge sys_clk)
        if (power_count < POWER_ON_CYCLES) power_count <= power_count + 1'b1;
    wire reset_request_n = power_count == POWER_ON_CYCLES;
    wire reset_async_n = reset_request_n && KEY2;
    reg [1:0] reset_sync;
    always @(posedge sys_clk or negedge reset_async_n)
        if (!reset_async_n) reset_sync <= 0;
        else reset_sync <= {reset_sync[0], 1'b1};
    wire rst_n = reset_sync[1];
    wire replay_press, ringtone_press;
    button_debounce #(.STABLE_CYCLES(DEBOUNCE_CYCLES)) replay_button (
        .clk(sys_clk), .rst_n(rst_n), .key_n(KEY1), .press(replay_press)
    );
    button_debounce #(.STABLE_CYCLES(DEBOUNCE_CYCLES)) ringtone_button (
        .clk(sys_clk), .rst_n(rst_n), .key_n(KEY0), .press(ringtone_press)
    );
    // KEY2 is the active-low board reset; KEY1 remains the audition trigger.
    reg ringtone_active;
    wire playing, finished, sequence_error;
    wire failed;
    wire manual_mode = !SD_SCORE_ENABLE && !ringtone_active;
    wire play_rst_n = rst_n && !ringtone_press && !(replay_press && SD_SCORE_ENABLE && !ringtone_active);
    wire marimba_mode = ringtone_active || (manual_mode && (DEFAULT_MARIMBA != 0));
    reg ringtone_error;
    reg storage_restart;
    wire storage_enable = SD_SCORE_ENABLE || ringtone_active;
    wire storage_rst_n = play_rst_n && storage_enable && !storage_restart;
    always @(posedge sys_clk or negedge rst_n) begin
        if (!rst_n) begin
            ringtone_active <= 0; ringtone_error <= 0; storage_restart <= 0;
        end else begin
            storage_restart <= ringtone_active && (finished || failed);
            if (ringtone_press) begin
                ringtone_active <= !ringtone_active;
                ringtone_error <= 0;
            end else if (ringtone_active && (finished || failed)) begin
                ringtone_active <= 0;
                if (failed) ringtone_error <= 1;
            end
        end
    end
    wire sd_ready, sd_start, sd_valid, sd_done, sd_error, initialized;
    wire [31:0] sd_lba;
    wire [7:0] sd_data;
    wire [8:0] sd_index;
    wire [3:0] sd_error_code;
    sd_spi_reader #(
        .POWER_WAIT_CYCLES(SD_POWER_WAIT_CYCLES),
        .INIT_HALF_DIV(SD_INIT_HALF_DIV), .READ_HALF_DIV(SD_READ_HALF_DIV)
    ) sd (
        .clk(sys_clk), .rst_n(storage_rst_n),
        .read_start(sd_start), .read_lba(sd_lba),
        .read_ready(sd_ready), .busy(), .initialized(initialized), .high_capacity(),
        .data(sd_data), .data_index(sd_index), .data_valid(sd_valid), .data_ready(1'b1),
        .read_done(sd_done), .error_pulse(sd_error), .error_code(sd_error_code),
        .debug_failure(), .sd_cs_n(sd_cs_n), .sd_sck(sd_sck),
        .sd_mosi(sd_mosi), .sd_miso(sd_miso)
    );
    wire [7:0] file_data;
    wire file_valid, file_ready, file_found, file_done;
    wire [31:0] file_size;
    wire [3:0] fat_error, score_error;
    fat_file_reader #(.DYNAMIC_FILE_NAME(1)) file_reader (
        .requested_file_name(ringtone_active ? "RINGTONEBIN" : "PIANO   BIN"),
        .clk(sys_clk), .rst_n(storage_rst_n), .sd_ready(sd_ready),
        .sd_start(sd_start), .sd_lba(sd_lba), .sd_data(sd_data), .sd_index(sd_index),
        .sd_valid(sd_valid), .sd_done(sd_done), .sd_error(sd_error),
        .data(file_data), .valid(file_valid), .ready(file_ready), .mounted(),
        .file_found(file_found), .file_size(file_size), .file_done(file_done),
        .error_code(fat_error)
    );
    wire [63:0] event_data;
    wire event_valid, event_ready, format_ok, complete;
    piano_score_reader #(.DYNAMIC_FORMAT(1)) decoder (
        .marimba_format(ringtone_active),
        .clk(sys_clk), .rst_n(storage_rst_n),
        .data(file_data), .valid(file_valid),
        .ready(file_ready), .file_found(file_found), .file_size(file_size),
        .file_done(file_done), .event_data(event_data), .event_valid(event_valid),
        .event_ready(event_ready), .format_ok(format_ok), .complete(complete),
        .error_code(score_error)
    );
    wire [55:0] notes, velocities;
    wire [7:0] gates, triggers;
    wire dds_event_valid, dds_event_on, dds_event_ready;
    wire [6:0] dds_event_note;
    wire [7:0] dds_event_dynamics;
    wire piano_event_ready, marimba_event_ready;
    wire synth_event_ready = !ringtone_press &&
                            (marimba_mode ? marimba_event_ready : piano_event_ready);
    wire audition_event_valid, audition_event_on;
    wire [6:0] audition_event_note;
    wire [7:0] audition_event_dynamics;
    // Select exactly one event source; the audition source is gated by mode.
    wire synth_event_valid = !ringtone_press &&
                            (manual_mode ? audition_event_valid : dds_event_valid);
    wire synth_event_on = manual_mode ? audition_event_on : dds_event_on;
    wire [6:0] synth_event_note = manual_mode ? audition_event_note : dds_event_note;
    wire [7:0] synth_event_dynamics = manual_mode ? audition_event_dynamics : dds_event_dynamics;
    wire piano_deadline_error, marimba_deadline_error;
    wire deadline_error = marimba_mode ? marimba_deadline_error : piano_deadline_error;
    // Stop and mute on any failed storage, format, sequence or compute check.
    wire stream_error = storage_enable &&
                        (sd_error_code != 0 || fat_error != 0 || score_error != 0);
    assign failed = stream_error || sequence_error || deadline_error;
    wire synth_stop = ringtone_press ||
                      (manual_mode ? deadline_error : (failed || finished));
    wire audio_silence = manual_mode ? deadline_error :
                         (failed || finished || !playing);
    wire mode_active = manual_mode || (playing && !finished);
    key_audition #(.DEBOUNCE_CYCLES(DEBOUNCE_CYCLES)) audition (
        .clk(sys_clk), .reset_n(play_rst_n && manual_mode && !ringtone_active),
        .key_play_n(KEY1), .key_stop_n(1'b1),
        .note_first(marimba_mode ? 7'd36 : 7'd0),
        .note_last(marimba_mode ? 7'd77 : 7'd87),
        .event_ready(manual_mode && synth_event_ready),
        .event_valid(audition_event_valid), .event_on(audition_event_on),
        .event_note(audition_event_note), .event_dynamics(audition_event_dynamics),
        .stop_all()
    );
    piano_score_sequencer #(.CLOCKS_PER_MS(CLOCKS_PER_MS)) sequencer (
        .clk(sys_clk), .rst_n(storage_rst_n),
        .paused(manual_mode || ringtone_press),
        .format_ok(format_ok), .stream_complete(complete), .stream_error(stream_error),
        .event_data(event_data), .event_valid(event_valid), .event_ready(event_ready),
        .dispatch_ready(dds_event_ready), .dispatch_valid(dds_event_valid),
        .dispatch_on(dds_event_on), .dispatch_note(dds_event_note),
        .dispatch_dynamics(dds_event_dynamics),
        .notes(notes), .velocities(velocities), .gates(gates), .triggers(triggers),
        .playing(playing), .finished(finished), .error(sequence_error), .elapsed_ms()
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
    generate if (DEFAULT_MARIMBA == 0 || SD_SCORE_ENABLE != 0) begin: piano_path
    piano_synth #(
        .SINE_FILE(SINE_FILE), .FREQ_FILE(FREQ_FILE), .VOICING_FILE(VOICING_FILE)
    ) synth (
        .clk(sys_clk), .reset_n(play_rst_n),
        .sample_tick(dds_sample_tick), .stop_all(synth_stop),
        .event_valid(synth_event_valid), .event_on(synth_event_on),
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
        .event_valid(synth_event_valid), .event_on(synth_event_on),
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
