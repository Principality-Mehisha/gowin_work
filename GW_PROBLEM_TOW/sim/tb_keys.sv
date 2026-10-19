`timescale 1ns/1ps
module tb_keys;
    reg clk=0; always #5 clk=~clk;
    reg reset_n=0, play_n=1, stop_n=1, ready=1;
    wire valid,on_value,stop_all;
    wire [6:0] note;
    wire [7:0] dynamics;
    reg passed=0;
    integer on_count=0, off_count=0, expected=0, i;
    key_audition #(.DEBOUNCE_CYCLES(4)) dut (
        .clk(clk),.reset_n(reset_n),.key_play_n(play_n),.key_stop_n(stop_n),
        .event_ready(ready),.event_valid(valid),.event_on(on_value),
        .event_note(note),.event_dynamics(dynamics),.stop_all(stop_all));
    always @(posedge clk) if(reset_n && valid && ready && !stop_all) begin
        if(dynamics!=192) $fatal(1,"Dynamics not fixed");
        if(on_value) begin
            if(note!=expected) $fatal(1,"88-note order: %d != %d",note,expected);
            expected=(expected==87)?0:expected+1;
            on_count=on_count+1;
        end else off_count=off_count+1;
    end
    task wait_key; begin repeat(12) @(negedge clk); end endtask
    initial begin
        repeat(3) @(negedge clk); reset_n=1;
        // Short bounce must not make an event.
        play_n=0; @(negedge clk); play_n=1; wait_key();
        if(on_count!=0) $fatal(1,"Bounce generated note");
        for(i=0;i<89;i=i+1) begin
            play_n=0; wait_key();
            repeat(8) @(negedge clk);
            play_n=1; wait_key();
        end
        if(on_count!=89 || off_count!=89) $fatal(1,"Missing edge events");
        play_n=0; wait_key(); stop_n=0; wait_key();
        stop_n=1; wait_key();
        if(valid) $fatal(1,"Stop re-triggered a held key");
        play_n=1; wait_key();
        if(off_count!=89) $fatal(1,"Stopped held key emitted stray note-off");
        passed=1; $display("PASS tb_keys: debounce, 88-note wrap, hold/release, stop lockout");
        $finish;
    end
endmodule
