`timescale 1ns/1ps
module tmds_encoder (
    input wire pixel_clk,
    input wire reset_n,
    input wire [7:0] data,
    input wire de,
    input wire c0,
    input wire c1,
    output reg [9:0] symbol
);
    integer i;
    reg [3:0] ones;
    reg [3:0] q_ones;
    reg use_xnor;
    reg [8:0] q_m;
    reg signed [5:0] balance;
    reg signed [5:0] disparity;

    always @* begin
        ones = 0;
        for (i = 0; i < 8; i = i + 1)
            ones = ones + data[i];
        use_xnor = (ones > 4) || ((ones == 4) && !data[0]);
        q_m[0] = data[0];
        for (i = 1; i < 8; i = i + 1)
            q_m[i] = use_xnor ? ~(q_m[i-1] ^ data[i]) :
                                          q_m[i-1] ^ data[i];
        q_m[8] = !use_xnor;
        q_ones = 0;
        for (i = 0; i < 8; i = i + 1)
            q_ones = q_ones + q_m[i];
        balance = $signed({1'b0, q_ones, 1'b0}) - 6'sd8;
    end

    always @(posedge pixel_clk or negedge reset_n) begin
        if (!reset_n) begin
            disparity <= 0;
            symbol <= 10'b1101010100;
        end else if (!de) begin
            disparity <= 0;
            case ({c1, c0})
                2'b00: symbol <= 10'b1101010100;
                2'b01: symbol <= 10'b0010101011;
                2'b10: symbol <= 10'b0101010100;
                2'b11: symbol <= 10'b1010101011;
            endcase
        end else if ((disparity == 0) || (balance == 0)) begin
            symbol <= {~q_m[8], q_m[8], q_m[8] ? q_m[7:0] : ~q_m[7:0]};
            disparity <= disparity + (q_m[8] ? balance : -balance);
        end else if (((disparity > 0) && (balance > 0)) ||
                     ((disparity < 0) && (balance < 0))) begin
            symbol <= {1'b1, q_m[8], ~q_m[7:0]};
            disparity <= disparity - balance + (q_m[8] ? 6'sd2 : 6'sd0);
        end else begin
            symbol <= {1'b0, q_m[8], q_m[7:0]};
            disparity <= disparity + balance - (q_m[8] ? 6'sd0 : 6'sd2);
        end
    end
endmodule
