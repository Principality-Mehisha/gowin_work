module sd_piano_music_player (
    input wire sys_clk, KEY0, KEY1, KEY2,
    output wire sd_cs_n, sd_sck, sd_mosi,
    input wire sd_miso,
    output wire HP_BCK, HP_WS, HP_DIN, PA_EN,
    output wire [3:0] LEDs
);
    sd_music_player #(
        .FILE_NAME("PIANO   BIN"), .RAW_PCM(1), .SD_READ_HALF_DIV(63)
    ) u_player (
        .sys_clk(sys_clk), .KEY0(KEY0), .KEY1(KEY1), .KEY2(KEY2),
        .sd_cs_n(sd_cs_n), .sd_sck(sd_sck), .sd_mosi(sd_mosi), .sd_miso(sd_miso),
        .HP_BCK(HP_BCK), .HP_WS(HP_WS), .HP_DIN(HP_DIN), .PA_EN(PA_EN),
        .LEDs(LEDs)
    );
endmodule
