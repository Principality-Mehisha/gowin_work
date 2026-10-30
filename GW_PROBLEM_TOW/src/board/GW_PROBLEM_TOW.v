// Board-level shell: keep logic in named submodules for isolated verification.
module GW_PROBLEM_TOW #(
    parameter integer SD_SCORE_ENABLE = 0,
    parameter integer VIDEO_ENABLE = 1
) (
    input wire sys_clk, KEY0, KEY1, KEY2,
    input wire uart_rx,
    output wire uart_tx,
    output wire HP_BCK, HP_WS, HP_DIN, PA_EN,
    output wire sd_cs_n, sd_sck, sd_mosi,
    input wire sd_miso,
    output wire [3:0] LEDs,
    output wire [2:0] tmds_data_p, tmds_data_n,
    output wire tmds_clk_p, tmds_clk_n
);
    wire player_reset_n, video_active;
    wire [31:0] video_elapsed_ms;
    wire [87:0] video_keys;
    wire [1:0] display_mode;
    wire piano_audio_active,analysis_clear,analysis_sample_tick;
    wire signed [15:0] analysis_pcm;
    piano_score_player #(.SD_SCORE_ENABLE(SD_SCORE_ENABLE)) score_player (
        .sys_clk(sys_clk), .KEY2(KEY2), .uart_rx(uart_rx), .uart_tx(uart_tx),
        .HP_BCK(HP_BCK), .HP_WS(HP_WS), .HP_DIN(HP_DIN), .PA_EN(PA_EN),
        .sd_cs_n(sd_cs_n), .sd_sck(sd_sck), .sd_mosi(sd_mosi), .sd_miso(sd_miso),
        .LEDs(LEDs), .player_reset_n(player_reset_n), .video_active(video_active),
        .video_elapsed_ms(video_elapsed_ms), .video_keys(video_keys),
        .display_mode(display_mode),.piano_audio_active(piano_audio_active),.analysis_clear(analysis_clear),
        .analysis_sample_tick(analysis_sample_tick),.analysis_pcm(analysis_pcm)
    );
    generate if (VIDEO_ENABLE != 0) begin: display_enabled
        piano_video video(.sys_clk(sys_clk), .reset_n(player_reset_n),
            .active(video_active), .elapsed_ms(video_elapsed_ms), .keys(video_keys),
            .display_mode(display_mode),.audio_active(piano_audio_active),.analysis_clear(analysis_clear),
            .sample_tick(analysis_sample_tick),.sample_pcm(analysis_pcm),
            .tmds_data_p(tmds_data_p), .tmds_data_n(tmds_data_n),
            .tmds_clk_p(tmds_clk_p), .tmds_clk_n(tmds_clk_n));
    end else begin: display_disabled
        assign tmds_data_p=0; assign tmds_data_n=0;
        assign tmds_clk_p=0; assign tmds_clk_n=0;
    end endgenerate
endmodule
