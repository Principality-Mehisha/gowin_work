module hc05_test #(
    parameter integer CLK_HZ = 50000000,
    parameter integer BAUD = 115200,
    parameter integer POWER_ON_CYCLES = 65536
) (
    input wire sys_clk,
    input wire uart_rx,
    output wire uart_tx,
    output wire led_n
);
    wire rst_n;
    board_reset #(.POWER_ON_CYCLES(POWER_ON_CYCLES)) reset_gen (
        .clk(sys_clk), .key_reset_n(1'b1), .rst_n(rst_n));
    wire [7:0] rx_data, reply_data, fifo_data;
    wire rx_valid, framing_error, reply_valid, reply_ready;
    wire fifo_valid, tx_ready, led_on;
    wire [8:0] fifo_used;
    wire [31:0] rx_count, tx_count, frame_count, overflow_count, long_count;
    uart_rx #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) receiver (
        .clk(sys_clk), .rst_n(rst_n), .rx(uart_rx), .data(rx_data),
        .valid(rx_valid), .framing_error(framing_error));
    hc05_commands commands (
        .clk(sys_clk), .rst_n(rst_n), .rx_data(rx_data), .rx_valid(rx_valid),
        .framing_error(framing_error), .tx_accepted(fifo_valid && tx_ready),
        .tx_used(fifo_used), .reply_data(reply_data), .reply_valid(reply_valid),
        .reply_ready(reply_ready), .led_on(led_on), .rx_count(rx_count),
        .tx_count(tx_count), .frame_count(frame_count),
        .overflow_count(overflow_count), .long_count(long_count));
    byte_fifo queue (
        .clk(sys_clk), .rst_n(rst_n), .in_data(reply_data), .in_valid(reply_valid),
        .in_ready(reply_ready), .out_data(fifo_data), .out_valid(fifo_valid),
        .out_ready(tx_ready), .used(fifo_used));
    uart_tx #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) transmitter (
        .clk(sys_clk), .rst_n(rst_n), .data(fifo_data), .valid(fifo_valid),
        .ready(tx_ready), .tx(uart_tx));
    assign led_n=~led_on;
endmodule
