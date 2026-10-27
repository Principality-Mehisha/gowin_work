`timescale 1ns/1ps
module ddr3_test #(
    parameter integer TEST_BURSTS=33554432
)(
    input wire sys_clk,
    input wire reset_button, // F4 core button: HIGH while pressed
    output wire led_run, output wire led_result,
    output wire [14:0] ddr_addr, output wire [2:0] ddr_bank,
    output wire ddr_cs, ddr_ras, ddr_cas, ddr_we,
    output wire ddr_ck, ddr_ck_n, ddr_cke, ddr_odt, ddr_reset_n,
    output wire [1:0] ddr_dm,
    inout wire [15:0] ddr_dq,
    inout wire [1:0] ddr_dqs, ddr_dqs_n
);
    // Power-on delay and button debounce. Asynchronous assertion, sync release.
    reg [23:0] power_on=0;
    reg [1:0] reset_release=0;
    wire reset= !reset_release[1];
    always @(posedge sys_clk or posedge reset_button) begin
        if(reset_button) begin power_on<=0; reset_release<=0; end
        else if(power_on!=24'd10000000) begin
            power_on<=power_on+1'b1; reset_release<=0;
        end else reset_release<={reset_release[0],1'b1};
    end
    wire memory_clk, pll_lock, pll_stop;
    wire [1:0] md_op;
    wire md_inc;
    wire [7:0] md_write, md_read;
    reg pll_user_control=0;
    reg [1:0] lock_sync=0;
    reg previous_stop=0;
    reg stop_write=0;
    always @(posedge sys_clk) begin
        if(reset) begin
            pll_user_control<=0; lock_sync<=0; previous_stop<=0; stop_write<=0;
        end else begin
            lock_sync<={lock_sync[0],pll_lock};
            // Latch ownership after PLL_INIT; never feed LOCK directly to bypass.
            if(lock_sync[1]) pll_user_control<=1;
            previous_stop<=pll_stop;
            stop_write<=pll_user_control && lock_sync[1] &&
                        (pll_stop!=previous_stop);
        end
    end
    DDR3_PLL u_clock(
        .clkin(sys_clk), .clkout0(), .clkout2(memory_clk), .lock(pll_lock),
        .reset(reset), .mdclk(sys_clk), .mdopc(md_op), .mdainc(md_inc),
        .mdwdi(md_write), .mdrdo(md_read), .pll_init_bypass(pll_user_control));
    pll_mDRP_intf u_pll_stop(
        .clk(sys_clk), .rst_n(!reset && pll_user_control),
        .pll_lock(lock_sync[1]), .wr(stop_write),
        .mdrp_inc(md_inc), .mdrp_op(md_op),
        .mdrp_wdata(md_write), .mdrp_rdata(md_read));

    wire ui_clk, ddr_rst, calibrated;
    reg [1:0] ui_release=0;
    always @(posedge ui_clk or posedge reset or posedge ddr_rst) begin
        if(reset || ddr_rst) ui_release<=0;
        else ui_release<={ui_release[0],1'b1};
    end
    wire ui_reset=!ui_release[1];
    reg [19:0] ui_ticks=0;
    always @(posedge ui_clk) begin
        if(ui_reset) ui_ticks<=0;
        else ui_ticks<=ui_ticks+1'b1;
    end
    wire [2:0] cmd;
    wire cmd_en, cmd_ready, wr_data_rdy, wr_data_en, wr_data_end;
    wire [28:0] addr;
    wire [127:0] wr_data, rd_data;
    wire [15:0] wr_data_mask;
    wire rd_data_valid, rd_data_end, passed, failed;
    // Named debug outputs can be connected to Gowin Analyzer Oscilloscope.
    wire [31:0] pass_count /* synthesis syn_keep=1 */;
    wire [3:0] error_code /* synthesis syn_keep=1 */;
    wire [28:0] first_error_addr /* synthesis syn_keep=1 */;
    wire [127:0] first_expected /* synthesis syn_keep=1 */;
    wire [127:0] first_actual /* synthesis syn_keep=1 */;
    wire [2:0] pattern /* synthesis syn_keep=1 */;
    wire [2:0] test_state /* synthesis syn_keep=1 */;
    ddr3_bist #(.TEST_BURSTS(TEST_BURSTS)) u_bist(
        .clk(ui_clk), .reset(ui_reset), .init_calib_complete(calibrated),
        .cmd(cmd), .cmd_en(cmd_en), .addr(addr), .cmd_ready(cmd_ready),
        .wr_data(wr_data), .wr_data_en(wr_data_en), .wr_data_end(wr_data_end),
        .wr_data_mask(wr_data_mask), .wr_data_rdy(wr_data_rdy),
        .rd_data(rd_data), .rd_data_valid(rd_data_valid), .rd_data_end(rd_data_end),
        .passed(passed), .failed(failed), .pass_count(pass_count),
        .error_code(error_code), .first_error_addr(first_error_addr),
        .first_expected(first_expected), .first_actual(first_actual),
        .pattern(pattern), .state(test_state));
    ddr3_status u_status(
        .clk(sys_clk), .reset(reset), .calibrated(calibrated),
        .passed(passed), .failed(failed), .error_code(error_code),
        .controller_reset(ddr_rst), .pll_locked(pll_lock),
        .ui_heartbeat(ui_ticks[19]),
        .led_run(led_run), .led_result(led_result), .fault(), .fault_code());
    DDR3_Memory_Interface_Top u_ddr3(
        .clk(sys_clk), .memory_clk(memory_clk), .pll_stop(pll_stop),
        .pll_lock(pll_lock), .rst_n(!reset && pll_user_control), .clk_out(ui_clk),
        .ddr_rst(ddr_rst), .init_calib_complete(calibrated),
        .cmd_ready(cmd_ready), .cmd(cmd), .cmd_en(cmd_en), .addr(addr),
        .wr_data_rdy(wr_data_rdy), .wr_data(wr_data), .wr_data_en(wr_data_en),
        .wr_data_end(wr_data_end), .wr_data_mask(wr_data_mask),
        .rd_data(rd_data), .rd_data_valid(rd_data_valid), .rd_data_end(rd_data_end),
        .sr_req(1'b0), .ref_req(1'b0), .sr_ack(), .ref_ack(), .burst(1'b1),
        .O_ddr_addr(ddr_addr), .O_ddr_ba(ddr_bank), .O_ddr_cs_n(ddr_cs),
        .O_ddr_ras_n(ddr_ras), .O_ddr_cas_n(ddr_cas), .O_ddr_we_n(ddr_we),
        .O_ddr_clk(ddr_ck), .O_ddr_clk_n(ddr_ck_n), .O_ddr_cke(ddr_cke),
        .O_ddr_odt(ddr_odt), .O_ddr_reset_n(ddr_reset_n), .O_ddr_dqm(ddr_dm),
        .IO_ddr_dq(ddr_dq), .IO_ddr_dqs(ddr_dqs), .IO_ddr_dqs_n(ddr_dqs_n));
endmodule
