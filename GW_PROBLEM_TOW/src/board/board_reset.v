// Power-on reset, asynchronous assertion and two-cycle synchronous release.
module board_reset #(parameter integer POWER_ON_CYCLES = 65536) (
    input wire clk, key_reset_n,
    output wire rst_n
);
    reg [31:0] power_count = 0;
    always @(posedge clk)
        if (power_count < POWER_ON_CYCLES) power_count <= power_count + 1'b1;
    wire reset_request_n = power_count == POWER_ON_CYCLES;
    wire reset_async_n = reset_request_n && key_reset_n;
    reg [1:0] reset_sync;
    always @(posedge clk or negedge reset_async_n)
        if (!reset_async_n) reset_sync <= 0;
        else reset_sync <= {reset_sync[0], 1'b1};
    assign rst_n = reset_sync[1];
endmodule
