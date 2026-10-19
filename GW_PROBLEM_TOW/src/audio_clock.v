`timescale 1ns/1ps
// Integer PLL cascade: 50 -> 120 -> 153.6 MHz. No fractional audio ticks.
module audio_clock (
    input wire sys_clk, input wire reset_n,
    output wire audio_clk, output wire locked
);
    wire intermediate_clk, lock1, lock2;
    wire reset = ~reset_n;
    audio_pll #(.INPUT_MHZ("50"), .IDIV(2), .MDIV(48), .ODIV(10),
                .INIT_MULT(24)) first_pll (
        .clk_in(sys_clk), .md_clk(sys_clk), .reset(reset),
        .clk_out(intermediate_clk), .locked(lock1));
    audio_pll #(.INPUT_MHZ("120"), .IDIV(5), .MDIV(32), .ODIV(5),
                .INIT_MULT(6)) second_pll (
        .clk_in(intermediate_clk), .md_clk(sys_clk), .reset(reset | ~lock1),
        .clk_out(audio_clk), .locked(lock2));
    assign locked = lock1 & lock2;
endmodule

module audio_pll #(
    parameter INPUT_MHZ = "50",
    parameter integer IDIV=2, MDIV=48, ODIV=10, INIT_MULT=24
) (
    input wire clk_in, md_clk, reset,
    output wire clk_out, locked
);
    wire pll_reset, raw_lock, md_inc;
    wire [1:0] md_op;
    wire [7:0] md_read, md_write;
    PLL_INIT #(.CLK_PERIOD(20), .MULTI_FAC(INIT_MULT)) startup (
        .I_RST(reset), .I_MD_CLK(md_clk), .O_RST(pll_reset),
        .O_MD_INC(md_inc), .O_MD_OPC(md_op), .O_MD_WR_DATA(md_write),
        .I_MD_RD_DATA(md_read), .I_LOCK(raw_lock), .O_LOCK(locked),
        .PLL_INIT_BYPASS(1'b0), .MDRDO(), .MDOPC(2'b00),
        .MDAINC(1'b0), .MDWDI(8'd0));
    PLLA #(.FCLKIN(INPUT_MHZ), .IDIV_SEL(IDIV), .FBDIV_SEL(1),
        .MDIV_SEL(MDIV), .ODIV0_SEL(ODIV), .CLKFB_SEL("INTERNAL")) pll (
        .CLKIN(clk_in), .CLKFB(1'b0), .RESET(pll_reset),
        .PLLPWD(1'b0), .RESET_I(1'b0), .RESET_O(1'b0),
        .CLKOUT0(clk_out), .CLKOUT1(), .CLKOUT2(), .CLKOUT3(),
        .CLKOUT4(), .CLKOUT5(), .CLKOUT6(), .CLKFBOUT(), .LOCK(raw_lock),
        .PSSEL(3'd0), .PSDIR(1'b0), .PSPULSE(1'b0),
        .SSCPOL(1'b0), .SSCON(1'b0), .SSCMDSEL(7'd0), .SSCMDSEL_FRAC(3'd0),
        .MDCLK(md_clk), .MDOPC(md_op), .MDAINC(md_inc),
        .MDWDI(md_write), .MDRDO(md_read));
endmodule

module audio_reset (
    input wire clk, input wire key_reset_n, input wire locked,
    output wire reset_n
);
    reg [3:0] release_sync;
    always @(posedge clk or negedge key_reset_n or negedge locked)
        if (!key_reset_n || !locked) release_sync <= 4'b0;
        else release_sync <= {release_sync[2:0], 1'b1};
    assign reset_n = release_sync[3];
endmodule
