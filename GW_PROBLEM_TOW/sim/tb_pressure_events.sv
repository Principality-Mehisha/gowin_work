`timescale 1ns/1ps
module tb_pressure_events;
    reg clk=0;
    always #5 clk=~clk;
    reg reset_n=0, edge_valid=0, edge_on=0, ready=0;
    reg [3:0] key=0;
    reg [7:0] gain=0;
    wire valid,on_value,update_value,overflow;
    wire [6:0] note;
    wire [7:0] dynamics;
    pressure_events dut(.clk(clk), .reset_n(reset_n), .base_note(7'd39),
        .edge_valid(edge_valid), .edge_on(edge_on), .edge_key(key), .edge_gain(gain),
        .pressed(16'd0), .gains(128'd0), .event_ready(ready),
        .event_valid(valid), .event_on(on_value), .event_update(update_value),
        .event_note(note), .event_key(), .event_dynamics(dynamics), .overflow(overflow));
    integer i, seen=0;
    reg passed=0;
    always @(posedge clk) if(valid && ready) begin
        if(update_value || note != 39+(seen%16) || on_value!=(seen<16))
            $fatal(1,"FIFO edge ordering failed at event %0d",seen);
        seen=seen+1;
    end
    task send(input integer n,input bit down);
        begin
            @(negedge clk); edge_valid=1; key=n; edge_on=down; gain=80;
            @(negedge clk); edge_valid=0;
        end
    endtask
    initial begin
        repeat(3) @(negedge clk); reset_n=1;
        for(i=0;i<16;i=i+1) send(i,1);
        for(i=0;i<16;i=i+1) send(i,0);
        if(overflow) $fatal(1,"32 edges overflowed before dispatch");
        ready=1;
        repeat(80) @(negedge clk);
        if(seen!=32) $fatal(1,"Gate edge lost while receiver was stalled");
        ready=0;
        for(i=0;i<40;i=i+1) send(i%16,1);
        if(!overflow) $fatal(1,"Overflow was not reported");
        repeat(8) @(negedge clk);
        if(!overflow) $fatal(1,"Overflow must be sticky");
        $display("PASS tb_pressure_events: ordered 16 ons/offs under stall; sticky overflow");
        passed=1; $finish;
    end
endmodule
