`timescale 1ns/1ps
// Core-only accelerated render: sample values represent 48 kHz. The idle
// clocks between completed frames are omitted; tb_demo checks real cadence.
module tb_bass;
    reg clk=0; always #3.255208333 clk=~clk;
    reg reset_n=0, stop_all=0, tick=0, valid=0, on_value=0;
    reg [6:0] note=0;
    wire ready_new,ready_old,new_valid,old_valid;
    wire signed [15:0] new_pcm,old_pcm;
    wire deadline_new,deadline_old,saturated_new,saturated_old;
    reg passed=0;
    integer fd,n,k,cycles,total=0,max_cycles=0;
    integer saved_new,saved_old;
    bit got_new,got_old;
    piano_synth #(.PARTIAL_DECAY(0),.UNISON_BEAT(0),.HAMMER_NOISE(0))
    current_voice (
        .clk(clk),.reset_n(reset_n),.sample_tick(tick),.stop_all(stop_all),
        .event_valid(valid),.event_on(on_value),.event_note(note),
        .event_dynamics(8'd192),.pitch_ratio(18'd65536),.event_ready(ready_new),
        .pcm(new_pcm),.pcm_valid(new_valid),.saturated(saturated_new),
        .deadline_error(deadline_new),.mix_sample(),.mix_valid(),.limiting(),
        .active_voices(),.debug_voice(),.debug_env_state(),.debug_envelope(),.debug_phase());
    piano_synth #(.BASS_VOICING(0),.HAMMER_TRANSIENT(0),
        .PARTIAL_DECAY(0),.UNISON_BEAT(0),.HAMMER_NOISE(0)) original_voice (
        .clk(clk),.reset_n(reset_n),.sample_tick(tick),.stop_all(stop_all),
        .event_valid(valid),.event_on(on_value),.event_note(note),
        .event_dynamics(8'd192),.pitch_ratio(18'd65536),.event_ready(ready_old),
        .pcm(old_pcm),.pcm_valid(old_valid),.saturated(saturated_old),
        .deadline_error(deadline_old),.mix_sample(),.mix_valid(),.limiting(),
        .active_voices(),.debug_voice(),.debug_env_state(),.debug_envelope(),.debug_phase());
    task event_send(input bit on_flag,input integer index);
        begin
            @(negedge clk);
            while(!(ready_new && ready_old)) @(negedge clk);
            valid=1; on_value=on_flag; note=index;
            @(negedge clk); valid=0;
        end
    endtask
    task frame(input integer position);
        begin
            @(negedge clk); tick=1;
            @(negedge clk); tick=0; cycles=1;
            got_new=0; got_old=0;
            while(!(got_new && got_old) && cycles<3200) begin
                @(negedge clk); cycles=cycles+1;
                if(new_valid) begin got_new=1; saved_new=new_pcm; end
                if(old_valid) begin got_old=1; saved_old=old_pcm; end
            end
            if(!(got_new && got_old) || deadline_new || deadline_old ||
               saturated_new || saturated_old ||
               ^new_pcm===1'bx || ^old_pcm===1'bx)
                $fatal(1,"Bad bass frame %0d",total);
            if(cycles>max_cycles) max_cycles=cycles;
            $fdisplay(fd,"%0d %0d %0d %0d",note,position,saved_old,saved_new);
            total=total+1;
            repeat(4) @(negedge clk);
        end
    endtask
    initial begin
        fd=$fopen("sim/bass_pcm.txt","w");
        repeat(5) @(negedge clk); reset_n=1;
        // A0, A1, A2, A4: all receive the same gate/dynamics, no normalization.
        for(n=0;n<4;n=n+1) begin
            event_send(1,n==3 ? 48 : n*12);
            for(k=0;k<36000;k=k+1) frame(k);
            event_send(0,n==3 ? 48 : n*12);
            for(k=36000;k<54000;k=k+1) frame(k);
            if(current_voice.voice_ram[n==3 ? 48 : n*12][2:0]!=0)
                $fatal(1,"Bass note-off did not reach OFF");
            @(negedge clk); stop_all=1;
            @(negedge clk); stop_all=0;
        end
        $fclose(fd); passed=1;
        $display("PASS tb_bass: %0d A/B frames; max %0d cycles",total,max_cycles);
        $finish;
    end
    initial begin #(64'd5000000000); $fatal(1,"Bass render timeout"); end
endmodule
