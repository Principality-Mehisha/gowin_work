// Board-level shell: keep logic in named submodules for isolated verification.
module GW_PROBLEM_TOW #(
    parameter integer SD_SCORE_ENABLE = 0,
    parameter integer DEFAULT_MARIMBA = 1
) (
    input wire sys_clk, KEY0, KEY1, KEY2,
    input wire uart_rx,
    output wire uart_tx,
    output wire HP_BCK, HP_WS, HP_DIN, PA_EN,
    output wire sd_cs_n, sd_sck, sd_mosi,
    input wire sd_miso,
    output wire [3:0] LEDs
);
    piano_score_player #(.SD_SCORE_ENABLE(SD_SCORE_ENABLE),
                         .DEFAULT_MARIMBA(DEFAULT_MARIMBA)) score_player (
        .sys_clk(sys_clk), .KEY0(KEY0), .KEY1(KEY1), .KEY2(KEY2),
        .uart_rx(uart_rx), .uart_tx(uart_tx),
        .HP_BCK(HP_BCK), .HP_WS(HP_WS), .HP_DIN(HP_DIN), .PA_EN(PA_EN),
        .sd_cs_n(sd_cs_n), .sd_sck(sd_sck), .sd_mosi(sd_mosi), .sd_miso(sd_miso),
        .LEDs(LEDs)
    );
endmodule
