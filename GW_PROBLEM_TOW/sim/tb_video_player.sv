`timescale 1ns/1ps
module tb_video_player;
    reg passed=0;
    wire done;
    uart_player_case normal(done);
    integer numbered_cycles=0,piano_cycles=0,marimba_cycles=0;
    always @(posedge normal.clk)if(normal.dut.rst_n)begin
        if(normal.dut.video_active || normal.dut.video_keys!=0)$fatal(1,"Old song waterfall bound to numbered score");
        if(normal.dut.video_elapsed_ms!==normal.dut.elapsed_ms)$fatal(1,"Playback timeline mismatch");
        if(normal.dut.system.ringtone_active)numbered_cycles=numbered_cycles+1;
        if(normal.dut.piano_audio_active)piano_cycles=piano_cycles+1;
        if(normal.dut.system.marimba_mode && normal.dut.playing)begin
            marimba_cycles=marimba_cycles+1;
            if(normal.dut.piano_audio_active)$fatal(1,"Marimba entered piano analysis");
        end
    end
    initial begin
        wait(done);#2;
        if(!numbered_cycles || !piano_cycles || !marimba_cycles)$fatal(1,"Missing numbered display/audio coverage");
        passed=1;$display("PASS numbered display ownership: no old fixed score, piano PCM analysis and marimba isolation");$finish;
    end
endmodule
