`timescale 1ns/1ps
`include "ringtone_config.vh"
module tb_ringtone;
    reg clk=0;
    always #10 clk=~clk;
    reg reset_n=0, tick=0, toggle=0;
    wire active, valid;
    wire signed [15:0] left, right;
    reg passed=0;
    reg [31:0] expected [0:`RINGTONE_FRAMES-1];
    integer frame, cycles;
    ringtone_pcm_player dut (
        .clk(clk), .reset_n(reset_n), .sample_tick(tick), .toggle(toggle),
        .active(active), .pcm_left(left), .pcm_right(right), .pcm_valid(valid)
    );
    task press;
        @(negedge clk); toggle=1;
        @(negedge clk); toggle=0;
        repeat(4) @(negedge clk);
    endtask
    task render;
        @(negedge clk); tick=1;
        @(negedge clk); tick=0;
        cycles=0;
        while(!valid && cycles<16) begin
            @(negedge clk); cycles=cycles+1;
        end
        if (!valid || !active) $fatal(1,"Missing ringtone sample");
        if ({left,right} !== expected[frame])
            $fatal(1,"PCM mismatch frame=%0d got=%h expected=%h",frame,
                   {left,right},expected[frame]);
        repeat(4) @(negedge clk);
    endtask
    initial begin
        $readmemh("sim/ringtone_expected.hex",expected);
        repeat(4) @(negedge clk); reset_n=1;
        if(active || left || right) $fatal(1,"Unexpected boot playback");
        press();
        for(frame=0;frame<50;frame=frame+1) render();
        press();
        if(active || left || right) $fatal(1,"Toggle did not stop playback");
        press();
        for(frame=0;frame<`RINGTONE_FRAMES;frame=frame+1) render();
        @(negedge clk); tick=1;
        @(negedge clk); tick=0;
        if(active || left || right) $fatal(1,"EOF did not stop playback");
        press();
        for(frame=0;frame<10;frame=frame+1) render();
        @(negedge clk); reset_n=0;
        @(negedge clk);
        if(active || left || right) $fatal(1,"Reset did not stop playback");
        $display("PASS tb_ringtone: %0d stereo frames match FFmpeg; stop/restart/EOF/reset",
                 `RINGTONE_FRAMES);
        passed=1; $finish;
    end
    initial begin #100_000_000; $fatal(1,"Ringtone timeout"); end
endmodule
