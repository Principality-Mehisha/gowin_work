module piano_score_player #(
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
    reg [1:0] reset_sync;
    always @(posedge sys_clk or negedge reset_request_n)
        if (!reset_request_n) reset_sync <= 0;
        else reset_sync <= {reset_sync[0], 1'b1};
    wire rst_n = reset_sync[1];
    wire instrument_press, replay_press, mode_press;
    button_debounce #(.STABLE_CYCLES(DEBOUNCE_CYCLES)) instrument_button (
        .clk(sys_clk), .rst_n(rst_n), .key_n(KEY0), .press(instrument_press)
    );
    button_debounce #(.STABLE_CYCLES(DEBOUNCE_CYCLES)) replay_button (
        .clk(sys_clk), .rst_n(rst_n), .key_n(KEY1), .press(replay_press)
    );
    button_debounce #(.STABLE_CYCLES(DEBOUNCE_CYCLES)) mode_button (
        .clk(sys_clk), .rst_n(rst_n), .key_n(KEY2), .press(mode_press)
    );
    reg manual_mode;
    always @(posedge sys_clk or negedge rst_n)
        if (!rst_n) manual_mode <= 1'b0;
        else if (mode_press) manual_mode <= !manual_mode;
    wire play_rst_n = rst_n && !mode_press && !(replay_press && !manual_mode);
    reg [1:0] instrument_mode;
    reg instrument_change;
    always @(posedge sys_clk or negedge rst_n)
        if (!rst_n) begin
            instrument_mode <= 2'd0;
            instrument_change <= 1'b0;
        end else begin
            instrument_change <= instrument_press;
            if (instrument_press)
                instrument_mode <= instrument_mode==2'd2 ? 2'd0 :
                                   instrument_mode+1'b1;
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
        .clk(sys_clk), .rst_n(play_rst_n), .read_start(sd_start), .read_lba(sd_lba),
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
    fat_file_reader #(.FILE_NAME("PIANO   BIN")) file_reader (
        .clk(sys_clk), .rst_n(play_rst_n), .sd_ready(sd_ready),
        .sd_start(sd_start), .sd_lba(sd_lba), .sd_data(sd_data), .sd_index(sd_index),
        .sd_valid(sd_valid), .sd_done(sd_done), .sd_error(sd_error),
        .data(file_data), .valid(file_valid), .ready(file_ready), .mounted(),
        .file_found(file_found), .file_size(file_size), .file_done(file_done),
        .error_code(fat_error)
    );
    wire [63:0] event_data;
    wire event_valid, event_ready, format_ok, complete;
    piano_score_reader decoder (
        .clk(sys_clk), .rst_n(play_rst_n), .data(file_data), .valid(file_valid),
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
    wire synth_event_ready;
    wire audition_event_valid, audition_event_on;
    wire [6:0] audition_event_note;
    wire [7:0] audition_event_dynamics;
    wire synth_event_valid = manual_mode ? audition_event_valid : dds_event_valid;
    wire synth_event_on = manual_mode ? audition_event_on : dds_event_on;
    wire [6:0] synth_event_note = manual_mode ? audition_event_note : dds_event_note;
    wire [7:0] synth_event_dynamics = manual_mode ? audition_event_dynamics : dds_event_dynamics;
    wire playing, finished, sequence_error;
    wire deadline_error;
    wire stream_error = sd_error_code != 0 || fat_error != 0 || score_error != 0;
    wire failed = stream_error || sequence_error || deadline_error;
    wire synth_stop = manual_mode ? deadline_error : (failed || finished);
    wire audio_silence = manual_mode ? deadline_error :
                         (failed || finished || !playing);
    wire mode_active = manual_mode || (playing && !finished);
    key_audition #(.DEBOUNCE_CYCLES(DEBOUNCE_CYCLES)) audition (
        .clk(sys_clk), .reset_n(play_rst_n && manual_mode),
        .key_play_n(KEY1), .key_stop_n(1'b1),
        .event_ready(manual_mode && synth_event_ready),
        .event_valid(audition_event_valid), .event_on(audition_event_on),
        .event_note(audition_event_note), .event_dynamics(audition_event_dynamics),
        .stop_all()
    );
    piano_score_sequencer #(.CLOCKS_PER_MS(CLOCKS_PER_MS)) sequencer (
        .clk(sys_clk), .rst_n(play_rst_n), .paused(manual_mode),
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
    wire signed [15:0] pcm;
    wire pcm_valid, limiting, saturated;
    wire signed [31:0] mix_sample;
    wire dds_sample_tick = sample_tick &&
                           (manual_mode || (!failed && !finished));
    piano_synth #(
        .SINE_FILE(SINE_FILE), .FREQ_FILE(FREQ_FILE), .VOICING_FILE(VOICING_FILE)
    ) synth (
        .clk(sys_clk), .reset_n(play_rst_n),
        .sample_tick(dds_sample_tick), .stop_all(synth_stop),
        .instrument_change(instrument_change), .instrument_mode(instrument_mode),
        .event_valid(synth_event_valid), .event_on(synth_event_on),
        .event_note(synth_event_note), .event_dynamics(synth_event_dynamics),
        .pitch_ratio(DDS_PITCH_RATIO), .event_ready(synth_event_ready),
        .mix_sample(mix_sample), .mix_valid(), .pcm(pcm),
        .pcm_valid(pcm_valid), .limiting(limiting), .saturated(saturated),
        .deadline_error(deadline_error), .active_voices(),
        .debug_voice(), .debug_env_state(), .debug_envelope(), .debug_phase()
    );
    pt8211_score_tx #(.BCK_HALF_DIV(BCK_HALF_DIV),
                      .AMP_START_CYCLES(AUDIO_START_CYCLES)) audio (
        .sys_clk(sys_clk), .sys_rst_n(rst_n),
        .pcm_left(audio_silence ? 16'sd0 : pcm),
        .pcm_right(audio_silence ? 16'sd0 : pcm),
        .sample_tick(sample_tick),
        .HP_BCK(HP_BCK), .HP_WS(HP_WS), .HP_DIN(HP_DIN), .PA_EN(PA_EN)
    );
    assign LEDs = ~{(manual_mode ? deadline_error : failed), mode_active,
                    file_found, initialized};
endmodule
