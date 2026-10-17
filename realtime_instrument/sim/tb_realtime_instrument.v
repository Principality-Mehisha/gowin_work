`timescale 1ns/1ps

module tb_realtime_instrument;
    reg clk = 0;
    reg reset_n = 0;
    reg [3:0] cols_n = 4'b1111;
    reg uart_rx_i = 1'b1;
    reg signed [15:0] mic_pcm_i = 0;
    reg mic_valid_i = 0;
    wire [3:0] rows_n;
    wire uart_tx_o, HP_BCK, HP_WS, HP_DIN, PA_EN;
    wire [2:0] tmds_data_p, tmds_data_n;
    wire tmds_clk_p, tmds_clk_n;

    always #10 clk = ~clk;

    realtime_instrument #(.POWER_ON_CYCLES(8)) dut(
        .sys_clk(clk), .reset_n(reset_n),
        .keypad_cols_n(cols_n), .keypad_rows_n(rows_n),
        .uart_rx_i(uart_rx_i), .uart_tx_o(uart_tx_o),
        .mic_pcm_i(mic_pcm_i), .mic_valid_i(mic_valid_i),
        .HP_BCK(HP_BCK), .HP_WS(HP_WS), .HP_DIN(HP_DIN), .PA_EN(PA_EN),
        .tmds_data_p(tmds_data_p), .tmds_data_n(tmds_data_n),
        .tmds_clk_p(tmds_clk_p), .tmds_clk_n(tmds_clk_n));

    initial begin
        #100 reset_n = 1'b1;
        #100000;
        $display("realtime_instrument smoke test complete");
        $finish;
    end
endmodule
