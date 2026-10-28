// Hardware wiring follows the board-proven ddr3_test V3 (400 MHz, x16, BL8).
// PLL_INIT is shared with video; its MULTI_FAC is set by each PLL wrapper.
module audio_ddr3(
    input wire sys_clk, reset_n, cancel, request,
    input wire [10:0] address,
    output wire request_ready, response_valid,
    output wire [127:0] response_data,
    output wire ready, fault,
    output wire [3:0] fault_code,
    output wire [14:0] ddr_addr, output wire [2:0] ddr_bank,
    output wire ddr_cs,ddr_ras,ddr_cas,ddr_we,
    output wire ddr_ck,ddr_ck_n,ddr_cke,ddr_odt,ddr_reset_n,
    output wire [1:0] ddr_dm,
    inout wire [15:0] ddr_dq,
    inout wire [1:0] ddr_dqs,ddr_dqs_n
);
    // Reuse the successful project's 200 ms power/physical reset guard.
    reg [23:0] power_on;
    reg [1:0] reset_release;
    wire reset=!reset_release[1];
    always @(posedge sys_clk or negedge reset_n) begin
        if(!reset_n) begin power_on<=0; reset_release<=0; end
        else if(power_on!=24'd10000000) begin power_on<=power_on+1'b1; reset_release<=0; end
        else reset_release<={reset_release[0],1'b1};
    end
    wire memory_clk,pll_lock,pll_stop;
    wire [1:0] md_op;
    wire md_inc;
    wire [7:0] md_write,md_read;
    reg pll_user_control;
    (* ASYNC_REG="TRUE" *) reg [1:0] lock_sync;
    reg previous_stop,stop_write;
    always @(posedge sys_clk) begin
        if(reset) begin pll_user_control<=0; lock_sync<=0; previous_stop<=0; stop_write<=0; end
        else begin
            lock_sync<={lock_sync[0],pll_lock};
            if(lock_sync[1]) pll_user_control<=1;
            previous_stop<=pll_stop;
            stop_write<=pll_user_control && lock_sync[1] && (pll_stop!=previous_stop);
        end
    end
    DDR3_PLL u_clock(.clkin(sys_clk),.clkout0(),.clkout2(memory_clk),.lock(pll_lock),
        .reset(reset),.mdclk(sys_clk),.mdopc(md_op),.mdainc(md_inc),.mdwdi(md_write),
        .mdrdo(md_read),.pll_init_bypass(pll_user_control));
    pll_mDRP_intf u_pll_stop(.clk(sys_clk),.rst_n(!reset && pll_user_control),
        .pll_lock(lock_sync[1]),.wr(stop_write),.mdrp_inc(md_inc),.mdrp_op(md_op),
        .mdrp_wdata(md_write),.mdrp_rdata(md_read));
    wire ui_clk,ddr_rst,calibrated;
    reg [1:0] ui_release;
    always @(posedge ui_clk or posedge reset or posedge ddr_rst) begin
        if(reset || ddr_rst) ui_release<=0;
        else ui_release<={ui_release[0],1'b1};
    end
    wire ui_reset=!ui_release[1];
    reg [19:0] ui_ticks;
    always @(posedge ui_clk) if(ui_reset) ui_ticks<=0; else ui_ticks<=ui_ticks+1'b1;
    wire [2:0] cmd;
    wire cmd_en,cmd_ready,wr_data_rdy,wr_data_en,wr_data_end;
    wire [28:0] addr;
    wire [127:0] wr_data,rd_data;
    wire [15:0] wr_data_mask;
    wire rd_data_valid,rd_data_end,service_ready,service_fault,ui_fault,health_fault;
    wire service_request_ready;
    ddr_asset_service service(.sys_clk(sys_clk),.reset_n(!reset),.cancel(cancel || health_fault),
        .request(request && !health_fault),.address(address),.request_ready(service_request_ready),
        .response_valid(response_valid),.response_data(response_data),.ready(service_ready),.fault(service_fault),
        .ui_clk(ui_clk),.ui_reset(ui_reset),.calibrated(calibrated),.cmd(cmd),.cmd_en(cmd_en),
        .addr(addr),.cmd_ready(cmd_ready),.wr_data(wr_data),.wr_data_en(wr_data_en),
        .wr_data_end(wr_data_end),.wr_data_mask(wr_data_mask),.wr_data_rdy(wr_data_rdy),
        .rd_data(rd_data),.rd_data_valid(rd_data_valid),.rd_data_end(rd_data_end),.ui_fault(ui_fault));
    ddr3_status health(.clk(sys_clk),.reset(reset),.calibrated(calibrated),.passed(service_ready),
        .failed(ui_fault),.error_code(4'd1),.controller_reset(ddr_rst),.pll_locked(pll_lock),
        .ui_heartbeat(ui_ticks[19]),.led_run(),.led_result(),.fault(health_fault),.fault_code(fault_code));
    assign fault=health_fault || service_fault;
    assign ready=service_ready && !fault;
    assign request_ready=service_request_ready && !health_fault;
    DDR3_Memory_Interface_Top u_ddr3(.clk(sys_clk),.memory_clk(memory_clk),.pll_stop(pll_stop),
        .pll_lock(pll_lock),.rst_n(!reset && pll_user_control),.clk_out(ui_clk),.ddr_rst(ddr_rst),
        .init_calib_complete(calibrated),.cmd_ready(cmd_ready),.cmd(cmd),.cmd_en(cmd_en),.addr(addr),
        .wr_data_rdy(wr_data_rdy),.wr_data(wr_data),.wr_data_en(wr_data_en),.wr_data_end(wr_data_end),
        .wr_data_mask(wr_data_mask),.rd_data(rd_data),.rd_data_valid(rd_data_valid),.rd_data_end(rd_data_end),
        .sr_req(1'b0),.ref_req(1'b0),.sr_ack(),.ref_ack(),.burst(1'b1),
        .O_ddr_addr(ddr_addr),.O_ddr_ba(ddr_bank),.O_ddr_cs_n(ddr_cs),.O_ddr_ras_n(ddr_ras),
        .O_ddr_cas_n(ddr_cas),.O_ddr_we_n(ddr_we),.O_ddr_clk(ddr_ck),.O_ddr_clk_n(ddr_ck_n),
        .O_ddr_cke(ddr_cke),.O_ddr_odt(ddr_odt),.O_ddr_reset_n(ddr_reset_n),.O_ddr_dqm(ddr_dm),
        .IO_ddr_dq(ddr_dq),.IO_ddr_dqs(ddr_dqs),.IO_ddr_dqs_n(ddr_dqs_n));
endmodule
