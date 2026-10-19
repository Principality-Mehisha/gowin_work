`timescale 1ns/1ps
module tb_limiter;
    reg clk=0; always #5 clk=~clk;
    reg reset_n=0,clear=0,valid=0;
    reg signed [31:0] sample=0;
    wire out_valid,limiting,saturated;
    wire signed [15:0] pcm;
    reg passed=0;
    integer i,expected,error;
    output_limiter dut (.clk(clk),.reset_n(reset_n),.clear(clear),
        .in_valid(valid),.in_sample(sample),.out_valid(out_valid),
        .out_sample(pcm),.limiting(limiting),.saturated(saturated));
    task check(input integer x);
        begin
            @(negedge clk); clear=1;
            @(negedge clk); clear=0; sample=x; valid=1;
            @(negedge clk); valid=0;
            wait(out_valid); @(negedge clk);
            expected=(x>=0)?(x+2)/4:-((-x+2)/4);
            if(expected>30000) expected=30000;
            if(expected< -30000) expected=-30000;
            error=pcm-expected;
            if(error< -8 || error>8 || saturated)
                $fatal(1,"Limiter %d -> %d expected %d",x,pcm,expected);
        end
    endtask
    initial begin
        repeat(3) @(negedge clk); reset_n=1;
        check(0); check(40000); check(-40000);
        check(120000); check(-120000); check(495000*4); check(-495000*4);
        check(123456); check(-123456);
        check(10518750); check(-10518750);
        passed=1; $display("PASS tb_limiter: signed rounding, peak gain, final bounds");
        $finish;
    end
endmodule
