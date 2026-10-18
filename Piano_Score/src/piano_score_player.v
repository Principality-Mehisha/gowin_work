module piano_score_player #(
    parameter integer POWER_ON_CYCLES = 65536,
    parameter integer DEBOUNCE_CYCLES = 1000000,
    parameter integer AUDIO_START_CYCLES = 2500000,
    parameter integer SD_POWER_WAIT_CYCLES = 500000,
    parameter integer SD_INIT_HALF_DIV = 63,
    parameter integer SD_READ_HALF_DIV = 63,
    parameter ROM_FILE = "src/piano_bank.hex"
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
    wire reset_request_n = KEY2 && power_count == POWER_ON_CYCLES;
    reg [1:0] reset_sync;
    always @(posedge sys_clk or negedge reset_request_n)
        if (!reset_request_n) reset_sync <= 0;
        else reset_sync <= {reset_sync[0], 1'b1};
    wire rst_n = reset_sync[1];
    wire pause_press, replay_press;
    button_debounce #(.STABLE_CYCLES(DEBOUNCE_CYCLES)) pause_button (
        .clk(sys_clk), .rst_n(rst_n), .key_n(KEY0), .press(pause_press)
    );
    button_debounce #(.STABLE_CYCLES(DEBOUNCE_CYCLES)) replay_button (
        .clk(sys_clk), .rst_n(rst_n), .key_n(KEY1), .press(replay_press)
    );
    wire play_rst_n = rst_n && !replay_press;
    reg paused;
    always @(posedge sys_clk or negedge play_rst_n)
        if (!play_rst_n) paused <= 0;
        else if (pause_press) paused <= ~paused;
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
    wire playing, finished, sequence_error;
    wire stream_error = sd_error_code != 0 || fat_error != 0 || score_error != 0;
    wire failed = stream_error || sequence_error;
    piano_score_sequencer sequencer (
        .clk(sys_clk), .rst_n(play_rst_n), .paused(paused),
        .format_ok(format_ok), .stream_complete(complete), .stream_error(stream_error),
        .event_data(event_data), .event_valid(event_valid), .event_ready(event_ready),
        .notes(notes), .velocities(velocities), .gates(gates), .triggers(triggers),
        .playing(playing), .finished(finished), .error(sequence_error), .elapsed_ms()
    );
    wire sample_tick;
    wire signed [15:0] pcm;
    piano_polyphony #(.ROM_FILE(ROM_FILE)) synth (
        .clk(sys_clk), .rst_n(play_rst_n), .sample_tick(sample_tick),
        .audio_ready(1'b1), .paused(paused), .mute(failed || !playing),
        .notes(notes), .velocities(velocities), .gates(gates), .triggers(triggers), .pcm(pcm)
    );
    pt8211_tx #(.BCK_HALF_DIV(48), .AMP_START_CYCLES(AUDIO_START_CYCLES)) audio (
        .sys_clk(sys_clk), .sys_rst_n(rst_n),
        .pcm_left(failed || paused ? 16'sd0 : pcm),
        .pcm_right(failed || paused ? 16'sd0 : pcm), .sample_tick(sample_tick),
        .HP_BCK(HP_BCK), .HP_WS(HP_WS), .HP_DIN(HP_DIN), .PA_EN(PA_EN)
    );
    assign LEDs = ~{failed, (playing && !paused), file_found, initialized};
endmodule
