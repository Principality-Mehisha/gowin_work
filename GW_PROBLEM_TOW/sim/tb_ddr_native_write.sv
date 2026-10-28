`timescale 1ns/1ps
// Real Gowin MC write FIFO regression. PHY/read returns are bypassed here;
// full readback and audio are tested separately with ddr_native_model.
module tb_ddr_native_write;
    reg passed=0,clk=0,ui_clk=0,reset_n=0;
    always #10 clk=~clk;
    always #5 ui_clk=~ui_clk;
    wire [2:0] cmd;
    wire cmd_en,cmd_ready,wr_ready,wr_en,wr_end,send_wr,fault;
    wire [28:0] addr;
    wire [127:0] data;
    wire [15:0] mask;
    integer commands=0,beats=0,writes=0;
    ddr_asset_service service(.sys_clk(clk),.reset_n(reset_n),.cancel(1'b0),
        .request(1'b0),.address(11'd0),.request_ready(),.response_valid(),.response_data(),
        .ready(),.fault(fault),.ui_clk(ui_clk),.ui_reset(!reset_n),.calibrated(reset_n),
        .cmd(cmd),.cmd_en(cmd_en),.addr(addr),.cmd_ready(cmd_ready),.wr_data(data),
        .wr_data_en(wr_en),.wr_data_end(wr_end),.wr_data_mask(mask),.wr_data_rdy(wr_ready),
        .rd_data(128'd0),.rd_data_valid(1'b0),.rd_data_end(1'b0),.ui_fault());
    native_mc_probe mc(.clk(ui_clk),.reset(!reset_n),.cmd(cmd),.cmd_en(cmd_en),.addr(addr),
        .wr_data(data),.wr_data_en(wr_en),.wr_data_end(wr_end),.wr_data_mask(mask),
        .cmd_ready(cmd_ready),.wr_data_rdy(wr_ready),.send_wr(send_wr));
    always @(posedge ui_clk)if(reset_n)begin
        if(cmd_en && cmd_ready && cmd==0)commands<=commands+1;
        if(wr_en && wr_ready)beats<=beats+1;
        if(send_wr)writes<=writes+1;
    end
    initial begin
        repeat(10)@(negedge clk);reset_n=1;
        wait(service.verifying && service.state==service.READ_WAIT);
        repeat(200)@(negedge ui_clk);
        if(fault || commands!=1575 || beats!=1575 || writes!=1575)
            $fatal(1,"Native MC boot writes disagree commands=%d data=%d writes=%d",commands,beats,writes);
        passed=1;$display("PASS: actual Gowin MC, 1575 boot commands/data/write requests match, no duplicate FIFO entry");$finish;
    end
    initial begin #2000000;$fatal(1,"Native DDR boot timeout");end
endmodule
