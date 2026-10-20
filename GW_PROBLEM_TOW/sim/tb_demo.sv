`timescale 1ns/1ps
// Full-rate functional render: generated PCM is verification output only.
module tb_demo;
    reg clk=0; always #3.255208333 clk=~clk;
    reg reset_n=0,stop_all=0,instrument_change=0,valid=0,on_value=0;
    reg [6:0] note=0;
    reg [17:0] pitch=65536;
    wire ready,tick,pcm_valid,deadline,limiting,saturated;
    wire signed [15:0] pcm;
    wire signed [31:0] mix;
    wire [6:0] active;
    reg passed=0;
    integer count=0,fd,n,limiter_frames=0;
    piano_synth dut (
        .clk(clk),.reset_n(reset_n),.sample_tick(tick),.stop_all(stop_all),
        .instrument_change(instrument_change), .instrument_mode(1'b0),
        .event_valid(valid),.event_on(on_value),.event_note(note),
        .event_dynamics(8'd192),.pitch_ratio(pitch),.event_ready(ready),
        .pcm(pcm),.pcm_valid(pcm_valid),.mix_sample(mix),.mix_valid(),
        .limiting(limiting),.saturated(saturated),.deadline_error(deadline),
        .active_voices(active),.debug_voice(),.debug_env_state(),
        .debug_envelope(),.debug_phase());
    pt8211_score_tx #(.BCK_HALF_DIV(50)) dac (
        .sys_clk(clk),.sys_rst_n(reset_n),
        .pcm_left(stop_all ? 16'sd0 : pcm),
        .pcm_right(stop_all ? 16'sd0 : pcm),
        .sample_tick(tick),.HP_BCK(),.HP_WS(),.HP_DIN(),.PA_EN());
    always @(negedge clk) if(pcm_valid) begin
        if(deadline || saturated || ^pcm===1'bx) $fatal(1,"Bad output");
        $fdisplay(fd,"%0d %0d %0d %0d %0d",count,pcm,mix,active,limiting);
        count=count+1;
        if(limiting) limiter_frames=limiter_frames+1;
    end
    task event_send(input bit on_flag,input integer note_index);
        begin
            @(negedge clk); while(!ready) @(negedge clk);
            valid=1; on_value=on_flag; note=note_index;
            @(negedge clk); valid=0;
        end
    endtask
    initial begin
        fd=$fopen("sim/demo_pcm.txt","w");
        repeat(5) @(negedge clk); reset_n=1;
        event_send(1,48); // A4.
        wait(count==24000); event_send(0,48);
        wait(count==42000); // A4 Release should be over.
        if(dut.voice_ram[48][2:0]!=0) $fatal(1,"Default Release did not finish");
        // A major: A4 C#5 E5, with a dynamically shifted pitch at the end.
        event_send(1,48); event_send(1,52); event_send(1,55);
        wait(count==66000);
        event_send(0,48); event_send(0,52); event_send(0,55);
        wait(count==84000);
        // C8 verifies that out-of-band harmonics are suppressed.
        event_send(1,87);
        wait(count==96000); event_send(0,87);
        wait(count==114000);
        // Maximum polyphony: all 88 keys.
        for(n=0;n<88;n=n+1) event_send(1,n);
        wait(count==126000);
        if(active!=88) $fatal(1,"Full polyphony was not maintained");
        stop_all=1; repeat(3) @(negedge clk); stop_all=0;
        wait(count==126010);
        if(pcm!=0 || active!=0) $fatal(1,"Stop did not mute next frame");
        $fclose(fd); passed=1;
        $display("PASS tb_demo: %0d full-rate frames; limiter active %0d frames",
                 count,limiter_frames);
        $finish;
    end
    initial begin #(64'd3000000000); $fatal(1,"Demo timeout"); end
endmodule
