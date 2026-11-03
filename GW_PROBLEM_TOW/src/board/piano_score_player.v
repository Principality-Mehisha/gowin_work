// Board interfaces: reset, UART screen, SD stream, DAC, and instrument system.
// Control stays at 50 MHz; the PLL drives synthesis/effects/DAC at 150 MHz.
module piano_score_player #(
    parameter integer SD_SCORE_ENABLE = 0,
    parameter integer PRESSURE_ENABLE = 0,
    parameter integer PITCH_GROUP_STABLE_CYCLES = 50000,
    parameter integer PRESSURE_CALIBRATION_LOG2 = 5,
    parameter integer PRESSURE_SOFT_TOUCH_BOOST = 1,
    parameter integer PRESSURE_LONG_HOLD_FRAMES = 1042,
    parameter integer UART_ENABLE = 1,
    parameter integer UART_CLK_HZ = 50000000,
    parameter integer UART_BAUD = 115200,//
    parameter integer UART_TIMEOUT_CYCLES = UART_CLK_HZ/50,
    parameter integer NOTE_GATE_CYCLES = 25000000,
    parameter integer NOTE_TAIL_CYCLES = 50000000,
    parameter integer POWER_ON_CYCLES = 65536,
    parameter integer AUDIO_START_CYCLES = 2500000,
    parameter integer SD_POWER_WAIT_CYCLES = 500000,
    parameter integer SD_INIT_HALF_DIV = 63,
    parameter integer SD_READ_HALF_DIV = 63,
    parameter integer CLOCKS_PER_MS = 50000,
    parameter integer BCK_HALF_DIV = 48,
    parameter SINE_FILE = "src/rom/sine256.hex",
    parameter FREQ_FILE = "src/rom/frequency88.hex",
    parameter VOICING_FILE = "src/rom/voicing88.hex",
    parameter MARIMBA_MODE_FILE = "src/rom/marimba48_48828.hex",
    parameter MARIMBA_ATTACK_FILE = "src/rom/marimba_attack48.hex",
    // Frequency ROM is normalized for 48 kHz; compensate for this player's
    // 150 MHz / (64 * BCK_HALF_DIV) audio sample rate.
    parameter [17:0] DDS_PITCH_RATIO = 18'd64425
) (
    input wire sys_clk, KEY2,
    input wire [6:0] pitch_group,
    input wire pressure_sample_valid,
    input wire [3:0] pressure_sample_key,
    input wire [11:0] pressure_sample_data,
    input wire uart_rx,
    input wire upload_complete, upload_invalidated,
    input wire [7:0] uploaded_track,
    output wire uart_tx,
    output wire HP_BCK, HP_WS, HP_DIN, PA_EN,
    output wire sd_cs_n, sd_sck, sd_mosi,
    input wire sd_miso,
    output wire [7:0] LEDs,
    output wire player_reset_n, video_active, video_clear,
    output wire [31:0] video_elapsed_ms,
    output wire [1:0] display_mode,
    output wire audio_analysis_active,analysis_clear,analysis_sample_tick,
    output wire signed [15:0] analysis_pcm,
    output wire [87:0] video_keys,
    output wire guide_active
);
    GSR GSR_INST (.GSRI(1'b1));
    wire rst_n;
    wire audio_clk,audio_pll_locked,audio_reset_n;
    audio_clock150 audio_clocks(.sys_clk(sys_clk),.reset_n(rst_n),
        .audio_clk(audio_clk),.locked(audio_pll_locked),.audio_reset_n(audio_reset_n));
    assign player_reset_n = rst_n;
    board_reset #(.POWER_ON_CYCLES(POWER_ON_CYCLES)) reset_controller (
        .clk(sys_clk), .key_reset_n(KEY2), .rst_n(rst_n)
    );
    wire uart_play, raw_uart_play;
    wire uart_stop;
    wire uart_note_previous;
    wire uart_note_next;
    wire uart_note_play;
    wire uart_select_piano;
    wire uart_select_marimba;
    wire [7:0] uart_track;
    wire initialized;
    wire file_found;
    wire playing;
    wire finished;
    wire sequence_error;
    wire [3:0] sd_error_code;
    wire [3:0] fat_error;
    wire [3:0] score_error;
    wire [31:0] elapsed_ms;
    wire dds_event_valid;
    wire dds_event_on;
    wire [6:0] dds_event_note;
    wire [7:0] dds_event_dynamics;
    wire [7:0] selected_track;
    wire [7:0] last_error;
    wire [6:0] selected_note;
    wire selected_marimba;
    wire [7:0] player_state;
    wire sd_active;
    wire [199:0] scanned_catalog;
    wire scanned_catalog_done;
    reg [199:0] catalog;
    reg catalog_valid;
    wire numbered_request=uart_track>=4 && uart_track<=203;
    // Cold probing uses the registered SD owner. player_state includes
    // pressure busy, which depends on this request's restart signal.
    assign uart_play=raw_uart_play && numbered_request && (
        catalog[uart_track-8'd4] || (!catalog_valid && !sd_active));
    always @(posedge sys_clk or negedge rst_n) begin
        if(!rst_n) begin catalog<=0; catalog_valid<=0; end
        else begin
            if(scanned_catalog_done) begin catalog<=scanned_catalog; catalog_valid<=1; end
            if(upload_complete && uploaded_track>=4 && uploaded_track<=203)
                catalog[uploaded_track-8'd4]<=1;
            if(upload_invalidated && uploaded_track>=4 && uploaded_track<=203)
                catalog[uploaded_track-8'd4]<=0;
        end
    end
    wire storage_rst_n;
    wire storage_paused;
    wire dds_event_ready;
    wire [15:0] pcm;
    wire uart_overflow;
    wire sample_tick;
    wire [1:0] effect_mode;
    wire [6:0] effect_amount;
    wire signed [15:0] dac_sample_pcm;
    wire signed [15:0] pcm_right=pcm;
    wire [55:0] notes,velocities;
    wire [7:0] gates,triggers;
    assign guide_active=sd_active && playing && selected_track>=4 && selected_track<=103 &&
                        !storage_paused && last_error==0;
    generate if (UART_ENABLE != 0) begin: uart_control
        uart_score_control #(.CLK_HZ(UART_CLK_HZ),.BAUD(UART_BAUD),
                             .TIMEOUT_CYCLES(UART_TIMEOUT_CYCLES)) link (
            .clk(sys_clk),.rst_n(rst_n),.rx(uart_rx),.tx(uart_tx),
            .player_state(player_state),.player_track(selected_track),
            .selected_note(selected_note),
            .selected_marimba(selected_marimba),
            .player_error(last_error),.play_request(raw_uart_play),.stop_request(uart_stop),
            .note_previous(uart_note_previous),.note_next(uart_note_next),.note_play(uart_note_play),
            .note_select_piano(uart_select_piano),.note_select_marimba(uart_select_marimba),
            .display_mode(display_mode),.effect_mode(effect_mode),.effect_amount(effect_amount),
            .requested_track(uart_track),.overflow(uart_overflow));
    end else begin: no_uart_control
        assign uart_tx=1'b1;assign display_mode=0;
        assign raw_uart_play=1'b0; assign uart_stop=1'b0;
        assign uart_track=0; assign uart_overflow=0;
        assign uart_note_previous=0; assign uart_note_next=0; assign uart_note_play=0;
        assign uart_select_piano=0; assign uart_select_marimba=0;
        assign effect_mode=0;assign effect_amount=30;
    end endgenerate
    sd_score_stream #(
        .SD_POWER_WAIT_CYCLES(SD_POWER_WAIT_CYCLES),
        .SD_INIT_HALF_DIV(SD_INIT_HALF_DIV), .SD_READ_HALF_DIV(SD_READ_HALF_DIV),
        .CLOCKS_PER_MS(CLOCKS_PER_MS)
    ) score_stream (
        .clk(sys_clk), .rst_n(storage_rst_n),.catalog_cached(catalog_valid),
        .paused(storage_paused),
        .selected_track(selected_track),
        .sd_cs_n(sd_cs_n), .sd_sck(sd_sck), .sd_mosi(sd_mosi), .sd_miso(sd_miso),
        .dispatch_ready(dds_event_ready), .dispatch_valid(dds_event_valid),
        .dispatch_on(dds_event_on), .dispatch_note(dds_event_note),
        .dispatch_dynamics(dds_event_dynamics),
        .initialized(initialized), .file_found(file_found),
        .playing(playing), .finished(finished), .sequence_error(sequence_error),
        .sd_error_code(sd_error_code), .fat_error(fat_error), .score_error(score_error),
        .notes(notes), .velocities(velocities), .gates(gates), .triggers(triggers),
        .elapsed_ms(elapsed_ms),.catalog_mask(scanned_catalog),.catalog_done(scanned_catalog_done)
    );
    pt8211_score_tx #(.BCK_HALF_DIV(BCK_HALF_DIV),
                      .AMP_START_CYCLES(AUDIO_START_CYCLES*3)) audio (
        .sys_clk(audio_clk), .sys_rst_n(audio_reset_n),
        .pcm_left(pcm), .pcm_right(pcm_right),
        .sample_tick(sample_tick),.sample_pcm(dac_sample_pcm),
        .HP_BCK(HP_BCK), .HP_WS(HP_WS), .HP_DIN(HP_DIN), .PA_EN(PA_EN)
    );
    instrument_system #(
        .SD_SCORE_ENABLE(SD_SCORE_ENABLE),
        .PRESSURE_ENABLE(PRESSURE_ENABLE),
        .PITCH_GROUP_STABLE_CYCLES(PITCH_GROUP_STABLE_CYCLES),
        .PRESSURE_CALIBRATION_LOG2(PRESSURE_CALIBRATION_LOG2),
        .PRESSURE_SOFT_TOUCH_BOOST(PRESSURE_SOFT_TOUCH_BOOST),
        .PRESSURE_LONG_HOLD_FRAMES(PRESSURE_LONG_HOLD_FRAMES),
        .NOTE_GATE_CYCLES(NOTE_GATE_CYCLES),
        .NOTE_TAIL_CYCLES(NOTE_TAIL_CYCLES),
        .AUDIO_FRAME_CYCLES(64*BCK_HALF_DIV),
        .SINE_FILE(SINE_FILE),
        .FREQ_FILE(FREQ_FILE),
        .VOICING_FILE(VOICING_FILE),
        .MARIMBA_MODE_FILE(MARIMBA_MODE_FILE),
        .MARIMBA_ATTACK_FILE(MARIMBA_ATTACK_FILE),
        .DDS_PITCH_RATIO(DDS_PITCH_RATIO)
    ) system (
        .sys_clk(sys_clk),
        .rst_n(rst_n),
        .audio_clk(audio_clk),.audio_pll_locked(audio_pll_locked),
        .sample_tick(sample_tick),
        .dac_sample_pcm(dac_sample_pcm),
        .effect_mode(effect_mode),.effect_amount(effect_amount),
        .pitch_group(pitch_group),.pressure_sample_valid(pressure_sample_valid),
        .pressure_sample_key(pressure_sample_key),.pressure_sample_data(pressure_sample_data),
        .uart_play(uart_play),
        .uart_stop(uart_stop),
        .uart_note_previous(uart_note_previous),
        .uart_note_next(uart_note_next),
        .uart_note_play(uart_note_play),
        .uart_select_piano(uart_select_piano),
        .uart_select_marimba(uart_select_marimba),
        .uart_track(uart_track),
        .initialized(initialized),
        .file_found(file_found),
        .playing(playing),
        .finished(finished),
        .sequence_error(sequence_error),
        .sd_error_code(sd_error_code),
        .fat_error(fat_error),
        .score_error(score_error),
        .elapsed_ms(elapsed_ms),
        .dds_event_valid(dds_event_valid),
        .dds_event_on(dds_event_on),
        .dds_event_note(dds_event_note),
        .dds_event_dynamics(dds_event_dynamics),
        .selected_track(selected_track),
        .last_error(last_error),
        .selected_note(selected_note),
        .selected_marimba(selected_marimba),
        .player_state(player_state),
        .sd_active(sd_active),
        .storage_rst_n(storage_rst_n),
        .storage_paused(storage_paused),
        .dds_event_ready(dds_event_ready),
        .pcm(pcm),
        .video_active(video_active),
        .video_clear(video_clear),
        .video_elapsed_ms(video_elapsed_ms),
        .video_keys(video_keys),
        .LEDs(LEDs),.audio_analysis_active(audio_analysis_active),.analysis_clear(analysis_clear),
        .analysis_sample_tick(analysis_sample_tick),.analysis_sample_pcm(analysis_pcm)
    );
endmodule
