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
    integer j;
    reg [3:0] ones;
    reg [3:0] q_ones;
    reg [8:0] qm1, qm2;
    reg de1, de2;
    reg [1:0] control1, control2;
    reg use_xnor;
    reg [8:0] q_m;
    reg signed [5:0] balance;
    reg signed [5:0] balance2;
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
    end

    always @* begin
        q_ones = 0;
        for (j = 0; j < 8; j = j + 1)
            q_ones = q_ones + qm1[j];
        balance = $signed({1'b0, q_ones, 1'b0}) - 6'sd8;
    end

    // Pipeline transition minimization, balance count, then DC balancing.
    // DE and both control bits travel through the same three stages.
    always @(posedge pixel_clk or negedge reset_n) begin
        if (!reset_n) begin
            qm1 <= 0; qm2 <= 0; balance2 <= 0;
            de1 <= 0; de2 <= 0; control1 <= 0; control2 <= 0;
        end else begin
            qm1 <= q_m; de1 <= de; control1 <= {c1,c0};
            qm2 <= qm1; balance2 <= balance; de2 <= de1; control2 <= control1;
        end
    end

    always @(posedge pixel_clk or negedge reset_n) begin
        if (!reset_n) begin
            disparity <= 0;
            symbol <= 10'b1101010100;
        end else if (!de2) begin
            disparity <= 0;
            case (control2)
                2'b00: symbol <= 10'b1101010100;
                2'b01: symbol <= 10'b0010101011;
                2'b10: symbol <= 10'b0101010100;
                2'b11: symbol <= 10'b1010101011;
            endcase
        end else if ((disparity == 0) || (balance2 == 0)) begin
            symbol <= {~qm2[8], qm2[8], qm2[8] ? qm2[7:0] : ~qm2[7:0]};
            disparity <= disparity + (qm2[8] ? balance2 : -balance2);
        end else if (((disparity > 0) && (balance2 > 0)) ||
                     ((disparity < 0) && (balance2 < 0))) begin
            symbol <= {1'b1, qm2[8], ~qm2[7:0]};
            disparity <= disparity - balance2 + (qm2[8] ? 6'sd2 : 6'sd0);
        end else begin
            symbol <= {1'b0, qm2[8], qm2[7:0]};
            disparity <= disparity + balance2 - (qm2[8] ? 6'sd0 : 6'sd2);
        end
    end
endmodule
