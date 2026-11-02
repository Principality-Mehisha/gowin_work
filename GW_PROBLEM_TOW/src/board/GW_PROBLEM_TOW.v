// Board-level shell: keep logic in named submodules for isolated verification.
module GW_PROBLEM_TOW #(
    parameter integer SD_SCORE_ENABLE = 0,
    parameter integer VIDEO_ENABLE = 1,
    parameter integer PRESSURE_ENABLE = 1,
    parameter integer PITCH_GROUP_STABLE_CYCLES = 50000,
    parameter integer PRESSURE_SLOT_CYCLES = 1500,
    parameter integer PRESSURE_ADC_HALF_CYCLES = 50,
    parameter integer PRESSURE_SAMPLE_CYCLE = PRESSURE_SLOT_CYCLES-10,
    parameter integer PRESSURE_LONG_HOLD_FRAMES =
        (50000000 + PRESSURE_SLOT_CYCLES*32 - 1) / (PRESSURE_SLOT_CYCLES*32),
    parameter integer PRESSURE_CALIBRATION_LOG2 = 5,
    parameter integer PRESSURE_SOFT_TOUCH_BOOST = 1,
    parameter integer POWER_ON_CYCLES = 65536,
    parameter integer AUDIO_START_CYCLES = 2500000,
    parameter [7:0] LED_STATIC_LEVEL = 8'd64
) (
    input wire sys_clk, KEY0, KEY1, KEY2,
    input wire [11:0] ADC_DATA,
    input wire [6:0] pitch_group,
    output wire [3:0] S,
    output wire S_EN, CLK_500kHz,
    input wire uart_rx,
    output wire uart_tx,
    input wire bt_rx,
    output wire bt_tx,
    output wire HP_BCK, HP_WS, HP_DIN, PA_EN,
    output wire sd_cs_n, sd_sck, sd_mosi,
    input wire sd_miso,
    output wire [7:0] LEDs,
    output wire [2:0] tmds_data_p, tmds_data_n,
    output wire tmds_clk_p, tmds_clk_n,
    output LED_indicator_static,
    output wire LED_indicator_dynamic
);
    wire player_reset_n, video_active, video_clear;
    wire [31:0] video_elapsed_ms;
    wire [87:0] video_keys;
    wire guide_active;
    wire [143:0] guide_palette;
    wire [1:0] display_mode;
    wire audio_analysis_active,analysis_clear,analysis_sample_tick;
    wire signed [15:0] analysis_pcm;
    wire player_sd_cs_n, player_sd_sck, player_sd_mosi;
    wire upload_active, upload_sd_cs_n, upload_sd_sck, upload_sd_mosi;
    wire upload_complete,upload_invalidated;
    wire [7:0] uploaded_track;
    wire pressure_sample_valid;
    wire [3:0] pressure_sample_key;
    wire [11:0] pressure_sample_data;
    generate if(PRESSURE_ENABLE) begin: pressure_adc_enabled
        pressure_adc_scan #(.SLOT_CYCLES(PRESSURE_SLOT_CYCLES),
            .ADC_HALF_CYCLES(PRESSURE_ADC_HALF_CYCLES),
            .SAMPLE_CYCLE(PRESSURE_SAMPLE_CYCLE)) adc_interface(
            .clk(sys_clk),.reset_n(player_reset_n),.adc_data(ADC_DATA),
            .select(S),.select_n(S_EN),.adc_clk(CLK_500kHz),
            .sample_valid(pressure_sample_valid),.sample_key(pressure_sample_key),
            .sample_data(pressure_sample_data));
    end else begin: pressure_adc_disabled
        assign S=0;assign S_EN=1;assign CLK_500kHz=0;
        assign pressure_sample_valid=0;assign pressure_sample_key=0;
        assign pressure_sample_data=0;
    end endgenerate
    bluetooth_file_receiver bluetooth_upload (
        .clk(sys_clk),.reset_n(player_reset_n),.rx(bt_rx),.tx(bt_tx),
        .upload_complete(upload_complete),.upload_invalidated(upload_invalidated),.uploaded_track(uploaded_track),
        .upload_active(upload_active),.sd_cs_n(upload_sd_cs_n),
        .sd_sck(upload_sd_sck),.sd_mosi(upload_sd_mosi),.sd_miso(sd_miso));
    // Mode selection only: the operator must not upload during SD playback.

    ws2812_static #(.COLOR_LEVEL(LED_STATIC_LEVEL)) static_leds (
        .clk(sys_clk), .reset_n(player_reset_n), .data_out(LED_indicator_static),
        .group_palette(guide_palette));
    ws2812_key_guide dynamic_leds (
        .clk(sys_clk),.reset_n(player_reset_n),.active(guide_active && !upload_active),
        .keys(video_keys),.palette_rgb(guide_palette),.data_out(LED_indicator_dynamic));

    assign sd_cs_n=upload_active ? upload_sd_cs_n : player_sd_cs_n;
    assign sd_sck=upload_active ? upload_sd_sck : player_sd_sck;
    assign sd_mosi=upload_active ? upload_sd_mosi : player_sd_mosi;
    piano_score_player #(.SD_SCORE_ENABLE(SD_SCORE_ENABLE),.PRESSURE_ENABLE(PRESSURE_ENABLE),
        .PITCH_GROUP_STABLE_CYCLES(PITCH_GROUP_STABLE_CYCLES),
        .PRESSURE_CALIBRATION_LOG2(PRESSURE_CALIBRATION_LOG2),
        .PRESSURE_SOFT_TOUCH_BOOST(PRESSURE_SOFT_TOUCH_BOOST),
        .PRESSURE_LONG_HOLD_FRAMES(PRESSURE_LONG_HOLD_FRAMES),
        .POWER_ON_CYCLES(POWER_ON_CYCLES),.AUDIO_START_CYCLES(AUDIO_START_CYCLES)) score_player (
        .sys_clk(sys_clk), .KEY2(KEY2), .uart_rx(uart_rx), .uart_tx(uart_tx),
        .pitch_group(pitch_group),.pressure_sample_valid(pressure_sample_valid),
        .pressure_sample_key(pressure_sample_key),.pressure_sample_data(pressure_sample_data),
        .upload_complete(upload_complete),.upload_invalidated(upload_invalidated),.uploaded_track(uploaded_track),
        .HP_BCK(HP_BCK), .HP_WS(HP_WS), .HP_DIN(HP_DIN), .PA_EN(PA_EN),
        .sd_cs_n(player_sd_cs_n), .sd_sck(player_sd_sck), .sd_mosi(player_sd_mosi), .sd_miso(sd_miso),
        .LEDs(LEDs), .player_reset_n(player_reset_n), .video_active(video_active),.video_clear(video_clear),
        .video_elapsed_ms(video_elapsed_ms), .video_keys(video_keys),
        .display_mode(display_mode),.guide_active(guide_active),
        .audio_analysis_active(audio_analysis_active),.analysis_clear(analysis_clear),
        .analysis_sample_tick(analysis_sample_tick),.analysis_pcm(analysis_pcm)
    );
    generate if (VIDEO_ENABLE != 0) begin: display_enabled
        piano_video video(.sys_clk(sys_clk), .reset_n(player_reset_n),
            .active(video_active), .clear(video_clear),.elapsed_ms(video_elapsed_ms), .keys(video_keys),
            .display_mode(display_mode),.audio_active(audio_analysis_active),.analysis_clear(analysis_clear),
            .sample_tick(analysis_sample_tick),.sample_pcm(analysis_pcm),
            .tmds_data_p(tmds_data_p), .tmds_data_n(tmds_data_n),
            .tmds_clk_p(tmds_clk_p), .tmds_clk_n(tmds_clk_n));
    end else begin: display_disabled
        assign tmds_data_p=0; assign tmds_data_n=0;
        assign tmds_clk_p=0; assign tmds_clk_n=0;
    end endgenerate
endmodule
