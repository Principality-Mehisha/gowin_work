`timescale 1ns/1ps

// Lightweight behavioral models for RTL smoke tests. The Gowin project uses
// the vendor primitives from the FPGA library during synthesis.
module PLLA #(
    parameter FCLKIN = "50",
    parameter integer IDIV_SEL = 2,
    parameter integer FBDIV_SEL = 1,
    parameter integer MDIV_SEL = 40,
    parameter integer MDIV_FRAC_SEL = 2,
    parameter integer ODIV0_SEL = 8,
    parameter CLKFB_SEL = "INTERNAL"
) (
    input CLKIN, input CLKFB, input RESET, input PLLPWD, input RESET_I,
    input RESET_O, output reg CLKOUT0, output CLKOUT1, output CLKOUT2,
    output CLKOUT3, output CLKOUT4, output CLKOUT5, output CLKOUT6,
    output CLKFBOUT, output reg LOCK, input [2:0] PSSEL, input PSDIR,
    input PSPULSE, input SSCPOL, input SSCON, input [6:0] SSCMDSEL,
    input [2:0] SSCMDSEL_FRAC, input MDCLK, input [1:0] MDOPC,
    input MDAINC, input [7:0] MDWDI, output [7:0] MDRDO
);
    assign CLKOUT1 = 1'b0; assign CLKOUT2 = 1'b0; assign CLKOUT3 = 1'b0;
    assign CLKOUT4 = 1'b0; assign CLKOUT5 = 1'b0; assign CLKOUT6 = 1'b0;
    assign CLKFBOUT = 1'b0; assign MDRDO = 8'd0;
    always @(posedge CLKIN or posedge RESET) begin
        if (RESET) begin CLKOUT0 <= 1'b0; LOCK <= 1'b0; end
        else begin CLKOUT0 <= ~CLKOUT0; LOCK <= 1'b1; end
    end
endmodule

module CLKDIV #(parameter DIV_MODE = "5") (
    input HCLKIN, input RESETN, input CALIB, output reg CLKOUT
);
    reg [2:0] count;
    always @(posedge HCLKIN or negedge RESETN) begin
        if (!RESETN) begin count <= 0; CLKOUT <= 0; end
        else if (count == 3'd4) begin count <= 0; CLKOUT <= ~CLKOUT; end
        else count <= count + 1'b1;
    end
endmodule

module OSER10 (
    output reg Q,
    input D0, input D1, input D2, input D3, input D4,
    input D5, input D6, input D7, input D8, input D9,
    input PCLK, input FCLK, input RESET
);
    always @(posedge PCLK or posedge RESET)
        if (RESET) Q <= 1'b0;
        else Q <= D0;
endmodule

module TLVDS_OBUF(input I, output O, output OB);
    assign O = I;
    assign OB = ~I;
endmodule
