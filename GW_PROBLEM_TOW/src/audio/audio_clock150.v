// Official GW5AT PLL IP. Only the audio domain uses this clock.
module audio_clock150 (
    input wire sys_clk,reset_n,
    output wire audio_clk,locked,
    output wire audio_reset_n
);
    Gowin_Audio_PLL150 pll(
        .clkin(sys_clk),.mdclk(sys_clk),.reset(!reset_n),
        .clkout0(audio_clk),.lock(locked));
    wire ready=reset_n && locked;
    (* syn_async_reg=1 *) reg [3:0] release_pipe /* synthesis syn_preserve=1 */;
    always @(posedge audio_clk or negedge ready) begin
        if(!ready)release_pipe<=0;
        else release_pipe<={release_pipe[2:0],1'b1};
    end
    assign audio_reset_n=release_pipe[3];
endmodule
