`timescale 1ns/1ps
module tb_hc05_commands;
    reg clk=0, rst_n=0, rx_valid=0, framing_error=0, reply_ready=1;
    reg tx_accepted=0;
    reg [7:0] rx_data=0;
    reg [8:0] tx_used=0;
    wire [7:0] reply_data;
    wire reply_valid, led_on;
    wire [31:0] rx_count, tx_count, frame_count, overflow_count, long_count;
    reg passed=0;
    always #5 clk=~clk;
    hc05_commands dut(.*);
    task byte_in(input [7:0] data);
        begin
            @(negedge clk); rx_data=data; rx_valid=1;
            @(negedge clk); rx_valid=0;
        end
    endtask
    task text_in(input string message);
        integer i;
        begin for(i=0;i<message.len();i=i+1) byte_in(message[i]); end
    endtask
    initial begin
        repeat(3) @(negedge clk); rst_n=1;
        // No side effects when there is no capacity for a full reply.
        tx_used=161;
        text_in("LED 1\n");
        if(led_on || reply_valid || overflow_count!=1) $fatal(1,"Atomic overload reject");
        // Exactly the reservation boundary remains usable.
        tx_used=160; reply_ready=0;
        text_in("LED 1\n");
        if(!led_on || !reply_valid || reply_data!="O") $fatal(1,"Reservation boundary");
        repeat(5) @(negedge clk);
        if(reply_data!="O") $fatal(1,"Backpressure changed reply");
        // Mid-response reset clears pending TX, line parser, LED, all counters.
        rst_n=0; @(negedge clk); rst_n=1; tx_used=0; reply_ready=1;
        if(reply_valid || led_on || rx_count || overflow_count) $fatal(1,"Reset state");
        text_in("LE"); rst_n=0; @(negedge clk); rst_n=1;
        text_in("D 1\n");
        if(led_on) $fatal(1,"Partial command survived reset");
        passed=1; $display("PASS tb_hc05_commands: reservation/backpressure/reset"); $finish;
    end
    initial begin #100000; $fatal(1,"Command watchdog"); end
endmodule
