`timescale 1ns/1ps
module tb_tone_realism;
    reg clk=0; always #3.255208333 clk=~clk;
    reg reset_n=0,stop_all=0,tick=0,valid=0,on_value=0;
    reg [6:0] note=48;
    wire ready,pcm_valid,deadline,limiting,saturated;
    wire signed [15:0] pcm;
    integer fd,frame_index=0,k,cycles;
    reg [31:0] output_count=0;
    piano_synth #(.PARTIAL_DECAY(1),.UNISON_BEAT(1),.HAMMER_NOISE(1)) dut (
        .clk(clk),.reset_n(reset_n),.sample_tick(tick),.stop_all(stop_all),
        .instrument_change(1'b0), .instrument_mode(1'b0),
        .event_valid(valid),.event_on(on_value),.event_note(note),
        .event_dynamics(8'd192),.pitch_ratio(18'd65536),.event_ready(ready),
        .pcm(pcm),.pcm_valid(pcm_valid),.mix_sample(),.mix_valid(),
        .limiting(limiting),.saturated(saturated),.deadline_error(deadline),
        .active_voices(),.debug_voice(),.debug_env_state(),.debug_envelope(),
        .debug_phase());
    task send_event(input bit enabled);
        begin
            @(negedge clk); while(!ready) @(negedge clk);
            valid=1; on_value=enabled;
            @(negedge clk); valid=0;
        end
    endtask
    task next_frame;
        begin
            @(negedge clk); tick=1;
            @(negedge clk); tick=0;
            cycles=0;
            while(!pcm_valid && cycles<3200) begin
                @(negedge clk); cycles=cycles+1;
            end
            if(!pcm_valid || deadline || saturated || ^pcm===1'bx)
                $fatal(1,"Invalid realism frame %0d",frame_index);
            $fdisplay(fd,"%0d %0d",frame_index,pcm);
            frame_index=frame_index+1;
            repeat(4) @(negedge clk);
        end
    endtask
    initial begin
        fd=$fopen("sim/tone_realism_pcm.txt","w");
        repeat(5) @(negedge clk); reset_n=1;
        send_event(1);
        for(k=0;k<24000;k=k+1) next_frame();
        if(dut.partial_levels[7*24 +: 24]>=dut.partial_levels[0 +: 24])
            $fatal(1,"Upper partial did not decay faster");
        send_event(0);
        for(k=24000;k<42000;k=k+1) next_frame();
        if(dut.voice_ram[48][2:0]!=0)
            $fatal(1,"Note did not release");
        $fclose(fd);
        $display("PASS tb_tone_realism: %0d A4 frames, independent partial decay",
                 frame_index);
        $finish;
    end
    initial begin #(64'd3000000000); $fatal(1,"Realism render timeout"); end
endmodule
