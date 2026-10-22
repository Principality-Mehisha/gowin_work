// Ready/valid 8N1 transmitter; data is captured only on a handshake.
module uart_tx #(
    parameter integer CLK_HZ = 50000000,
    parameter integer BAUD = 9600
) (
    input wire clk, rst_n,
    input wire [7:0] data,
    input wire valid,
    output wire ready,
    output wire tx
);
    localparam integer TICKS = (CLK_HZ + BAUD/2) / BAUD;
    localparam integer CW = $clog2(TICKS + 1);
    reg [9:0] shift;
    reg [CW-1:0] count;
    reg [3:0] remaining;
    assign ready = remaining==0;
    assign tx = remaining==0 ? 1'b1 : shift[0];
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin shift<=10'h3ff; count<=0; remaining<=0; end
        else if (remaining==0) begin
            if (valid) begin shift<={1'b1,data,1'b0}; count<=TICKS-1; remaining<=10; end
        end else if (count!=0) count<=count-1'b1;
        else begin shift<={1'b1,shift[9:1]}; count<=TICKS-1; remaining<=remaining-1'b1; end
    end
endmodule
