// Single-clock 8N1 receiver. Validate both start and stop bits; wait for idle
// after a framing error/break. rx_sync is the only asynchronous input boundary.
module uart_rx #(
    parameter integer CLK_HZ = 50000000,
    parameter integer BAUD = 9600
) (
    input wire clk, rst_n, rx,
    output reg [7:0] data,
    output reg valid, framing_error
);
    localparam integer TICKS = (CLK_HZ + BAUD/2) / BAUD;
    localparam integer CW = $clog2(TICKS + 1);
    reg rx_meta, rx_sync;
    reg [CW-1:0] count;
    reg [2:0] state, bit_index;
    reg [7:0] shift;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin rx_meta<=1; rx_sync<=1; end
        else begin rx_meta<=rx; rx_sync<=rx_meta; end
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state<=0; count<=0; bit_index<=0; shift<=0;
            data<=0; valid<=0; framing_error<=0;
        end else begin
            valid<=0; framing_error<=0;
            case (state)
                0: if (!rx_sync) begin state<=1; count<=TICKS/2-1; end
                1: if (count!=0) count<=count-1'b1;
                   else if (!rx_sync) begin state<=2; count<=TICKS-1; bit_index<=0; end
                   else state<=0;
                2: if (count!=0) count<=count-1'b1;
                   else begin
                       shift[bit_index]<=rx_sync; count<=TICKS-1;
                       if (bit_index==7) state<=3;
                       else bit_index<=bit_index+1'b1;
                   end
                3: if (count!=0) count<=count-1'b1;
                   else if (rx_sync) begin data<=shift; valid<=1; state<=0; end
                   else begin framing_error<=1; state<=4; count<=TICKS-1; end
                4: if (!rx_sync) count<=TICKS-1;
                   else if (count!=0) count<=count-1'b1;
                   else state<=0;
                default: state<=0;
            endcase
        end
    end
endmodule
