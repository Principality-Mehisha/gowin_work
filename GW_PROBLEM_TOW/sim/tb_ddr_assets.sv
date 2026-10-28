`timescale 1ns/1ps
module tb_ddr_assets;
    reg passed=0,clk=0,ui_clk=0,reset_n=0,ui_reset=1,calibrated=0;
    always #10 clk=~clk;
    always #5 ui_clk=~ui_clk;
    reg cancel=0,request=0,freeze=0,corrupt=0,end_fault=0;
    reg [10:0] address=0;
    wire req_ready,rsp_valid,ready,fault,ui_fault;
    wire [127:0] response;
    wire [2:0] cmd;
    wire cmd_en,cmd_ready,wr_ready,wr_en,wr_end,rd_valid,rd_end;
    wire [28:0] addr;
    wire [127:0] wr_data,rd_data;
    wire [15:0] mask;
    wire [31:0] writes,reads;
    reg [127:0] expected[0:1574];
    integer i,seen;
    ddr_asset_service #(.TIMEOUT_CYCLES(256)) dut(.sys_clk(clk),.reset_n(reset_n),.cancel(cancel),
        .request(request),.address(address),.request_ready(req_ready),.response_valid(rsp_valid),
        .response_data(response),.ready(ready),.fault(fault),.ui_clk(ui_clk),.ui_reset(ui_reset),
        .calibrated(calibrated),.cmd(cmd),.cmd_en(cmd_en),.addr(addr),.cmd_ready(cmd_ready),
        .wr_data(wr_data),.wr_data_en(wr_en),.wr_data_end(wr_end),.wr_data_mask(mask),.wr_data_rdy(wr_ready),
        .rd_data(rd_data),.rd_data_valid(rd_valid),.rd_data_end(rd_end),.ui_fault(ui_fault));
    ddr_native_model memory(.clk(ui_clk),.reset(!reset_n || ui_reset),.cmd(cmd),.cmd_en(cmd_en),.addr(addr),
        .wr_data(wr_data),.wr_data_en(wr_en),.wr_data_end(wr_end),.wr_data_mask(mask),
        .cmd_ready(cmd_ready),.wr_data_rdy(wr_ready),.rd_data(rd_data),.rd_data_valid(rd_valid),
        .rd_data_end(rd_end),.freeze(freeze),.corrupt(corrupt),.end_fault(end_fault),.writes(writes),.reads(reads));
    task boot;
        begin
            @(negedge clk);reset_n=0;ui_reset=1;calibrated=0;request=0;cancel=0;
            freeze=0;corrupt=0;end_fault=0;
            repeat(5)@(negedge clk);reset_n=1;repeat(5)@(negedge clk);ui_reset=0;calibrated=1;
        end
    endtask
    task submit(input integer a);
        begin @(negedge clk);while(!req_ready)@(negedge clk);address=a;request=1;
            @(negedge clk);request=0;end
    endtask
    initial begin
        $readmemh("sim/ddr_assets.hex",expected);
        boot();wait(ready);
        if(writes!=1575 || reads!=1575)$fatal(1,"Incomplete boot verification");
        for(i=0;i<1575;i=i+1)begin
            submit(i);wait(rsp_valid);#1;
            if(response!==expected[i])$fatal(1,"DDR asset mismatch %d",i);
        end
        submit(31);@(negedge clk);cancel=1;@(negedge clk);cancel=0;
        seen=0;repeat(80)begin @(negedge clk);if(rsp_valid)seen=seen+1;end
        if(seen!=0)$fatal(1,"Canceled response leaked");
        submit(1471);wait(rsp_valid);#1;if(response!==expected[1471])$fatal(1,"Stale response");
        end_fault=1;submit(0);wait(fault);if(ready)$fatal(1,"End fault was not fatal");
        boot();wait(ready);freeze=1;submit(1);wait(fault);
        boot();corrupt=1;wait(fault);if(ready)$fatal(1,"Corrupt boot became ready");
        boot();wait(ready);submit(14);boot();wait(ready);
        submit(333);wait(rsp_valid);#1;if(response!==expected[333])$fatal(1,"Reset response mismatch");
        @(negedge clk);calibrated=0;wait(fault);
        passed=1;$display("PASS: all 1575 DDR assets, boot/readback, backpressure, cancellation, reset, timeout, corruption, end/calibration faults");$finish;
    end
    initial begin #10000000;$fatal(1,"DDR service test timeout");end
endmodule
