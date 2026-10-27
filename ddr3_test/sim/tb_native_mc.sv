`timescale 1ns/1ps
// Exercise the actual generated Gowin MC; PHY calibration is bypassed here.
// This validates controller FIFO flow, not DDR3 electrical operation.
module tb_native_mc;
    localparam integer BURSTS=32768;
    reg clk=0,reset=1;
    always #5 clk=~clk;
    wire [2:0] cmd,state;
    wire [28:0] addr;
    wire cmd_en,cmd_ready,wr_en,wr_end,wr_ready,failed;
    wire [127:0] data;
    wire [15:0] mask;
    wire [3:0] code;
    wire send_wr;
    integer commands=0,beats=0,writes=0,cycles=0;
    reg simulation_passed=0;
    native_mc_probe mc(.clk(clk),.reset(reset),.cmd(cmd),.cmd_en(cmd_en),.addr(addr),
        .wr_data(data),.wr_data_en(wr_en),.wr_data_end(wr_end),.wr_data_mask(mask),
        .cmd_ready(cmd_ready),.wr_data_rdy(wr_ready),.send_wr(send_wr));
    ddr3_bist #(.TEST_BURSTS(BURSTS),.TIMEOUT_CYCLES(4096)) bist(
        .clk(clk),.reset(reset),.init_calib_complete(!reset),.cmd(cmd),.cmd_en(cmd_en),
        .addr(addr),.cmd_ready(cmd_ready),.wr_data(data),.wr_data_en(wr_en),
        .wr_data_end(wr_end),.wr_data_mask(mask),.wr_data_rdy(wr_ready),
        .rd_data(128'd0),.rd_data_valid(1'b0),.rd_data_end(1'b0),
        .failed(failed),.error_code(code),.state(state),.passed(),.pass_count(),
        .first_error_addr(),.first_expected(),.first_actual(),.pattern());
    always @(posedge clk) if(!reset) begin
        cycles<=cycles+1;
        if(cmd_en&&cmd_ready&&cmd==0) commands<=commands+1;
        if(wr_en&&wr_ready) beats<=beats+1;
        if(send_wr) writes<=writes+1;
    end
    initial begin
        repeat(10) @(negedge clk); reset=0;
        wait(state==2||failed); repeat(200) @(negedge clk);
        $display("NATIVE MC: failed=%b code=%d commands=%d beats=%d write_requests=%d cycles=%d addr=%h",
            failed,code,commands,beats,writes,cycles,addr);
        if(failed || commands!=BURSTS || beats!=BURSTS || writes!=BURSTS)
            $fatal(1,"Native controller write path failed");
        simulation_passed=1; $display("ALL NATIVE MC TESTS PASSED"); $finish;
    end
    initial begin #5000000; $fatal(1,"Native MC test timeout"); end
endmodule
