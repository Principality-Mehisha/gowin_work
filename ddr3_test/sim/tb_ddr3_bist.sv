`timescale 1ns/1ps
module tb_ddr3_bist;
    reg clk=0;
    always #10 clk=~clk;
    reg reset=1, calibrated=0;
    wire [2:0] cmd, pattern, state;
    wire cmd_en, wr_en, wr_end;
    wire [28:0] addr;
    wire [127:0] wr_data;
    wire [15:0] mask;
    reg [127:0] rd_data=0;
    reg rd_valid=0, rd_end=0;
    wire passed, failed;
    wire [31:0] pass_count;
    wire [3:0] error_code;
    wire [28:0] error_addr;
    wire [127:0] expected, actual;
    integer mode=0, cycle=0, writes=0, reads=0, timer=0;
    reg pending_cmd=0, pending_data=0;
    reg [28:0] write_addr, read_addr;
    reg [127:0] write_data;
    reg [127:0] mem[0:63];
    wire cmd_ready=calibrated && !pending_cmd && !timer &&
                   cycle%7<4 && mode!=2;
    wire wr_ready=calibrated && !pending_data && cycle%11>=5 && mode!=3;
    reg simulation_passed=0;
    ddr3_bist #(.TEST_BURSTS(64),.TIMEOUT_CYCLES(128)) dut(
        .clk(clk),.reset(reset),.init_calib_complete(calibrated),
        .cmd(cmd),.cmd_en(cmd_en),.addr(addr),.cmd_ready(cmd_ready),
        .wr_data(wr_data),.wr_data_en(wr_en),.wr_data_end(wr_end),
        .wr_data_mask(mask),.wr_data_rdy(wr_ready),
        .rd_data(rd_data),.rd_data_valid(rd_valid),.rd_data_end(rd_end),
        .passed(passed),.failed(failed),.pass_count(pass_count),
        .error_code(error_code),.first_error_addr(error_addr),
        .first_expected(expected),.first_actual(actual),.pattern(pattern),.state(state));
    // Native-interface model, NOT a DDR PHY/timing model.
    always @(posedge clk) begin
        cycle<=cycle+1;
        rd_valid<=0; rd_end<=0;
        if(reset) begin
            pending_cmd<=0; pending_data<=0; timer<=0; writes<=0; reads<=0;
        end else begin
            if(cmd_en && cmd_ready) begin
                if(addr[2:0]!=0 || addr[28] || addr>=512) $fatal(1,"Address geometry");
                if(cmd==0) begin pending_cmd<=1; write_addr<=addr; end
                else if(cmd==1) begin
                    if(pending_cmd || pending_data) $fatal(1,"Read overtook write");
                    read_addr<=addr; timer<=5; reads<=reads+1;
                end else $fatal(1,"Command encoding");
            end
            if(wr_en && wr_ready) begin
                if(!wr_end || mask!=0) $fatal(1,"BL8 framing/mask");
                pending_data<=1; write_data<=wr_data;
            end
            if(pending_cmd && pending_data) begin
                mem[mode==7 ? (write_addr>>3)&31 : write_addr>>3]<=write_data;
                pending_cmd<=0; pending_data<=0; writes<=writes+1;
            end
            if(timer>0) begin
                timer<=timer-1;
                if(timer==1 && mode!=4) begin
                    rd_valid<=1; rd_end<=mode!=6;
                    rd_data<=mem[mode==7 ? (read_addr>>3)&31 : read_addr>>3] ^
                        ((mode==1 && read_addr==29'd24) ? (128'b1<<89) : 128'b0);
                end
            end
        end
    end
    reg prev_cmd_stall=0, prev_data_stall=0;
    reg [31:0] saved_cmd;
    reg [127:0] saved_data;
    integer last_write_cycle=-10;
    always @(posedge clk) begin
        if(!reset && !failed && calibrated) begin
            if(wr_en && (!wr_ready || !cmd_ready || !cmd_en || cmd!=0))
                $fatal(1,"Write command/data must submit together only when ready");
            if(cmd_en && !cmd_ready) $fatal(1,"Command enable asserted while not ready");
            if(wr_en) begin
                if(cycle-last_write_cycle<3) $fatal(1,"Missing write pipeline gap");
                last_write_cycle=cycle;
            end
            if(prev_cmd_stall && (!cmd_en || {cmd,addr}!==saved_cmd))
                $fatal(1,"Command changed under backpressure");
            if(prev_data_stall && (!wr_en || wr_data!==saved_data))
                $fatal(1,"Write data changed under backpressure");
        end
        prev_cmd_stall<=!reset && calibrated && cmd_en && !cmd_ready;
        prev_data_stall<=!reset && calibrated && wr_en && !wr_ready;
        saved_cmd<={cmd,addr}; saved_data<=wr_data;
    end
    task restart(input integer scenario);
        begin
            @(negedge clk); reset=1; calibrated=0; mode=scenario;
            repeat(4) @(negedge clk);
            reset=0;
            repeat(4) @(negedge clk);
            if(cmd_en || wr_en) $fatal(1,"Traffic before calibration");
            calibrated=1;
        end
    endtask
    task expect_failure(input integer code);
        integer n;
        begin
            n=0;
            while(!failed && n<50000) begin @(negedge clk); n=n+1; end
            if(!failed || error_code!=code) $fatal(1,"mode %0d: expected error %0d, got %0d",mode,code,error_code);
            repeat(10) @(negedge clk);
            if(cmd_en || wr_en || !failed) $fatal(1,"Failure must latch and stop traffic");
            $display("PASS fault scenario %0d code %0d addr %h",mode,error_code,error_addr);
        end
    endtask
    integer n;
    initial begin
        restart(0);
        n=0;
        while(pass_count<2 && !failed && n<50000) begin @(negedge clk); n=n+1; end
        if(failed || pass_count!=2 || !passed) $fatal(1,"Normal test failed");
        if(writes!=768 || reads!=768) $fatal(1,"Missing/duplicated burst %0d %0d",writes,reads);
        $display("PASS six patterns, two passes, paired writes and backpressure");
        restart(1); expect_failure(1);
        if(error_addr!=24 || expected===actual) $fatal(1,"First error capture");
        restart(2); expect_failure(2);
        restart(3); expect_failure(3);
        restart(4); expect_failure(4);
        restart(5); repeat(25) @(negedge clk); calibrated=0; expect_failure(5);
        restart(6); expect_failure(6);
        restart(7); expect_failure(1);
        if(pattern!=4) $fatal(1,"Address alias was not detected by address pattern");
        restart(0); repeat(30) @(negedge clk); restart(0);
        wait(pass_count==1 || failed);
        if(failed) $fatal(1,"Reset recovery");
        simulation_passed=1;
        $display("ALL BIST TESTS PASSED"); $finish;
    end
    initial begin #5000000; $fatal(1,"Testbench timeout"); end
endmodule
