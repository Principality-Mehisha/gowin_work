`timescale 1ns/1ps
module video_clock (
    input wire sys_clk,
    input wire reset,
    output wire serial_clk,
    output wire pixel_clk,
    output wire locked
);
    wire pll_reset;
    wire raw_lock;
    wire [7:0] md_read;
    wire [7:0] md_write;
    wire [1:0] md_op;
    wire md_inc;

    // Gowin's mandatory GW5AT-60B PLL startup/calibration sequence.
    PLL_INIT #(.CLK_PERIOD(20), .MULTI_FAC(20)) init(
        .I_RST(reset), .I_MD_CLK(sys_clk), .O_RST(pll_reset),
        .O_MD_INC(md_inc), .O_MD_OPC(md_op), .O_MD_WR_DATA(md_write),
        .I_MD_RD_DATA(md_read), .I_LOCK(raw_lock), .O_LOCK(locked),
        .PLL_INIT_BYPASS(1'b0), .MDRDO(), .MDOPC(2'b00),
        .MDAINC(1'b0), .MDWDI(8'd0));

    // 50/2 * (40 + 2/8) = 1006.25 MHz VCO; PFD = 25 MHz.
    // /8 = 125.78125 MHz FCLK; CLKDIV /5 = 25.15625 MHz pixels.
    PLLA #(.FCLKIN("50"), .IDIV_SEL(2), .FBDIV_SEL(1),
        .MDIV_SEL(40), .MDIV_FRAC_SEL(2), .ODIV0_SEL(8),
        .CLKFB_SEL("INTERNAL")) pll(
        .CLKIN(sys_clk), .CLKFB(1'b0), .RESET(pll_reset),
        .PLLPWD(1'b0), .RESET_I(1'b0), .RESET_O(1'b0),
        .CLKOUT0(serial_clk), .CLKOUT1(), .CLKOUT2(), .CLKOUT3(),
        .CLKOUT4(), .CLKOUT5(), .CLKOUT6(), .CLKFBOUT(),
        .LOCK(raw_lock), .PSSEL(3'd0), .PSDIR(1'b0), .PSPULSE(1'b0),
        .SSCPOL(1'b0), .SSCON(1'b0), .SSCMDSEL(7'd0),
        .SSCMDSEL_FRAC(3'd0), .MDCLK(sys_clk), .MDOPC(md_op),
        .MDAINC(md_inc), .MDWDI(md_write), .MDRDO(md_read));

    CLKDIV #(.DIV_MODE("5")) pixel_divider(
        .HCLKIN(serial_clk), .RESETN(locked), .CALIB(1'b0), .CLKOUT(pixel_clk));
endmodule
