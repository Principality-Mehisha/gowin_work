`timescale 1ns/1ps
module tb_piano88_core #(parameter integer LIVE_DYNAMICS=1);
    reg clk=0,reset_n=0,stop_all=0,valid=0,on=0,update=0,passed=0;
    always #3.333333 clk=~clk;
    reg [6:0] note=127;
    reg [7:0] dynamics=192;
    reg [11:0] divider=0;
    wire tick=divider==3071;
    always @(posedge clk)if(!reset_n)divider<=0;else divider<=tick ? 0 : divider+1'b1;
    wire ready,deadline,mix_valid,pcm_valid,saturated;
    wire signed [15:0] pcm;
    wire [6:0] active;
    integer n,cycles,max_cycles=0,heard=0;
    reg [23:0] first_level;
    piano_synth #(.LIVE_DYNAMICS(LIVE_DYNAMICS),.SAMPLE_RATE_RATIO(3)) dut(
        .clk(clk),.reset_n(reset_n),.sample_tick(tick),.stop_all(stop_all),
        .event_valid(valid),.event_on(on),.event_update(update),.event_note(note),
        .event_dynamics(dynamics),.pitch_ratio(18'd64425),.event_ready(ready),
        .mix_sample(),.mix_valid(mix_valid),.pcm(pcm),.pcm_valid(pcm_valid),
        .limiting(),.saturated(saturated),.deadline_error(deadline),.active_voices(active),
        .debug_voice(),.debug_env_state(),.debug_envelope(),.debug_phase(),
        .sine_read_address(),.sine_read_enable(),
        .external_sine_value(16'sd0),.external_sine_next(16'sd0));
    function [7:0] applied_gain(input integer index);
        applied_gain=dut.voice_ram[index] >> 83;
    endfunction
    task send_event(input integer pitch,input gate,input change);
        begin
            @(negedge clk);note=pitch;on=gate;update=change;valid=1;
            do @(posedge clk);while(!ready);
            @(negedge clk);valid=0;
        end
    endtask
    task render;
        begin
            @(posedge tick);@(negedge clk);cycles=0;
            while(!pcm_valid && cycles<3072)begin @(negedge clk);cycles=cycles+1;end
            if(cycles>=3072 || deadline || saturated || (^pcm===1'bx))
                $fatal(1,"88-note frame deadline/data/saturation");
            if(cycles>max_cycles)max_cycles=cycles;
            if(pcm!=0)heard=heard+1;
        end
    endtask
    initial begin
        repeat(8)@(negedge clk);reset_n=1;
        // Present the broadcast in the middle of a voice sweep.
        @(posedge tick);repeat(60)@(negedge clk);
        fork
            send_event(127,1,0);
            begin
                wait(valid);#0.001;
                if(ready)$fatal(1,"Broadcast accepted mid-frame");
                wait(dut.state==dut.IDLE);
            end
        join
        if(dut.gates!=={88{1'b1}} || dut.pending!=={88{1'b1}})
            $fatal(1,"Broadcast did not atomically arm all voices");
        render();
        first_level=dut.voice_ram[0][50:27];
        for(n=0;n<88;n=n+1)begin
            if(dut.voice_ram[n][2:0]!=1 || dut.voice_ram[n][50:27]!==first_level ||
               dut.voice_ram[n][82:51]!==((64'(dut.frequency_rom[n])*64425)>>16))
                $fatal(1,"Voice %0d did not start in the same frame",n);
            if(LIVE_DYNAMICS && applied_gain(n)!=192)
                $fatal(1,"Broadcast gain missing for voice %0d",n);
        end
        repeat(128)render();
        if(active!=88 || !heard)$fatal(1,"88 voices did not produce audio");
        // Individual events must still override the broadcast velocity.
        dynamics=64;send_event(48,1,0);render();
        if(dut.broadcast_gain[48] || dut.dynamics[48]!=64 ||
           (LIVE_DYNAMICS && applied_gain(48)!=64))
            $fatal(1,"Individual note failed to override broadcast gain");
        if(LIVE_DYNAMICS)begin
            dynamics=32;send_event(49,1,1);repeat(6)render();
            if(dut.broadcast_gain[49] || applied_gain(49)>=192)
                $fatal(1,"Pressure update failed after broadcast");
        end
        send_event(127,0,0);render();
        if(dut.gates!==0)$fatal(1,"Broadcast release left gates held");
        for(n=0;n<88;n=n+1)
            if(dut.voice_ram[n][2:0]!=4)$fatal(1,"Voice %0d missed common release frame",n);
        send_event(127,1,0);render();
        if(active!=88)$fatal(1,"Broadcast retrigger lost voices");
        @(negedge clk);stop_all=1;@(negedge clk);
        if(active || dut.gates || dut.pending || dut.broadcast_gain || pcm)
            $fatal(1,"Hard stop retained broadcast state");
        stop_all=0;send_event(48,1,0);repeat(2)render();
        if(active!=1)$fatal(1,"Single-note playback after broadcast stop");
        passed=1;
        $display("PASS piano88 core LIVE_DYNAMICS=%0d: atomic onset/release, 88 voices, individual gain/update, retrigger/stop; max %0d/3072 cycles",LIVE_DYNAMICS,max_cycles);
        $finish;
    end
    initial begin #20000000;$fatal(1,"Piano88 core timeout");end
endmodule
