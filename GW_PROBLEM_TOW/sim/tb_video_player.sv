`timescale 1ns/1ps
module tb_video_player;
    reg passed=0;
    wire done;
    uart_player_case normal(done);
    integer numbered_cycles=0,piano_cycles=0,marimba_cycles=0,marimba_warmup=0,marimba_samples=0;
    always @(posedge normal.clk)if(normal.dut.rst_n)begin
        if(normal.dut.system.marimba_mode && normal.dut.video_keys)
            $fatal(1,"Marimba entered live piano waterfall");
        if(normal.dut.video_elapsed_ms!==normal.dut.elapsed_ms)$fatal(1,"Playback timeline mismatch");
        if(normal.dut.system.ringtone_active)numbered_cycles=numbered_cycles+1;
        if(normal.dut.audio_analysis_active && !normal.dut.system.marimba_mode)piano_cycles=piano_cycles+1;
        if(!normal.dut.system.marimba_mode || !normal.dut.playing)marimba_warmup=0;
        else if(normal.dut.analysis_sample_tick && marimba_warmup<3)marimba_warmup=marimba_warmup+1;
        if(normal.dut.system.marimba_mode && normal.dut.playing)begin
            marimba_cycles=marimba_cycles+1;
            if(marimba_warmup>=3 && !normal.dut.audio_analysis_active)
                $fatal(1,"Marimba missing from shared analysis after sample feedback");
            if(normal.dut.analysis_sample_tick && normal.dut.audio_analysis_active)
                marimba_samples=marimba_samples+1;
        end
    end
    initial begin
        wait(done);#2;
        if(!numbered_cycles || !piano_cycles || !marimba_cycles || !marimba_samples)
            $fatal(1,"Missing numbered display/audio coverage");
        passed=1;$display("PASS numbered display ownership: live piano gates, shared piano/marimba PCM analysis and waterfall isolation");$finish;
    end
endmodule
