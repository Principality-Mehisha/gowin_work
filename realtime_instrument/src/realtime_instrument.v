`timescale 1ns/1ps

// Top-level foundation for the FPGA real-time multi-timbre instrument.
module realtime_instrument #(
    parameter integer POWER_ON_CYCLES = 65_536
) (
    input  wire               sys_clk,
    input  wire               reset_n,
    input  wire [3:0]         keypad_cols_n,
    output wire [3:0]         keypad_rows_n,
    input  wire               uart_rx_i,
    output wire               uart_tx_o,
    input  wire signed [15:0] mic_pcm_i,
    input  wire               mic_valid_i,
    output wire               HP_BCK,
    output wire               HP_WS,
    output wire               HP_DIN,
    output wire               PA_EN,
    output wire [2:0]         tmds_data_p,
    output wire [2:0]         tmds_data_n,
    output wire               tmds_clk_p,
    output wire               tmds_clk_n
);
    reg [31:0] por_count;
    reg [1:0] rst_pipe;
    wire core_rst_n = rst_pipe[1];
    wire key_event_valid, key_event_down;
    wire [6:0] key_event_note;
    wire uart_event_valid, uart_event_down_w;
    wire [6:0] uart_event_note;
    wire uart_timbre_valid;
    wire [1:0] uart_timbre;
    reg [1:0] timbre_select;
    wire mic_activity;
    wire [15:0] mic_envelope;
    wire event_valid = key_event_valid | uart_event_valid;
    wire event_down = uart_event_valid ? uart_event_down_w : key_event_down;
    wire [6:0] event_note = uart_event_valid ? uart_event_note : key_event_note;
    wire sample_tick;
    wire signed [15:0] pcm;
    wire [3:0] active_mask;
    wire pixel_clk, serial_clk, video_locked;
    wire video_reset_n = core_rst_n & video_locked;
    wire [7:0] red, green, blue;
    wire hsync, vsync, de;

    assign uart_tx_o = 1'b1;

    always @(posedge sys_clk or negedge reset_n) begin
        if (!reset_n) begin por_count <= 0; rst_pipe <= 0; end
        else begin
            if (por_count < POWER_ON_CYCLES) por_count <= por_count + 1;
            if (por_count >= POWER_ON_CYCLES) rst_pipe <= {rst_pipe[0], 1'b1};
        end
    end

    matrix_keypad_4x4 keypad(
        .clk(sys_clk), .rst_n(core_rst_n), .rows_n(keypad_rows_n),
        .cols_n(keypad_cols_n), .event_valid(key_event_valid),
        .event_down(key_event_down), .event_note(key_event_note));
    uart_command_rx uart(
        .clk(sys_clk), .rst_n(core_rst_n), .rx_i(uart_rx_i),
        .event_valid(uart_event_valid), .event_down(uart_event_down_w),
        .event_note(uart_event_note), .timbre_valid(uart_timbre_valid),
        .timbre_select(uart_timbre));
    mic_pcm_adapter mic(
        .clk(sys_clk), .rst_n(core_rst_n), .pcm_i(mic_pcm_i),
        .valid_i(mic_valid_i), .envelope_o(mic_envelope),
        .activity_o(mic_activity));

    always @(posedge sys_clk or negedge core_rst_n) begin
        if (!core_rst_n) timbre_select <= 0;
        else if (uart_timbre_valid) timbre_select <= uart_timbre;
    end

    poly_synth4 synth(
        .clk(sys_clk), .rst_n(core_rst_n), .sample_tick(sample_tick),
        .event_valid(event_valid), .event_down(event_down),
        .event_note(event_note), .timbre_select(timbre_select),
        .pcm_o(pcm), .active_mask_o(active_mask));
    pt8211_tx #(.BCK_HALF_DIV(16), .AMP_START_CYCLES(2_500_000)) audio(
        .sys_clk(sys_clk), .sys_rst_n(core_rst_n), .pcm_left(pcm),
        .pcm_right(pcm), .sample_tick(sample_tick), .HP_BCK(HP_BCK),
        .HP_WS(HP_WS), .HP_DIN(HP_DIN), .PA_EN(PA_EN));

    video_clock clocks(
        .sys_clk(sys_clk), .reset(!core_rst_n),
        .serial_clk(serial_clk), .pixel_clk(pixel_clk), .locked(video_locked));
    instrument_video_source video(
        .pixel_clk(pixel_clk), .reset_n(video_reset_n),
        .active_mask(active_mask), .mic_activity(mic_activity),
        .timbre_select(timbre_select), .red(red), .green(green), .blue(blue),
        .hsync(hsync), .vsync(vsync), .de(de));
    dvi_tx tx(
        .pixel_clk(pixel_clk), .serial_clk(serial_clk), .reset_n(video_reset_n),
        .red(red), .green(green), .blue(blue), .hsync(hsync), .vsync(vsync),
        .de(de), .tmds_data_p(tmds_data_p), .tmds_data_n(tmds_data_n),
        .tmds_clk_p(tmds_clk_p), .tmds_clk_n(tmds_clk_n));
endmodule
