`timescale 1ns/1ps
module tb_audio150_core;
    reg clk=0,reset_n=0,stop_all=0,valid=0,on=0,update=0,marimba=0,passed=0;
    always #3.333333 clk=~clk;
    reg [6:0] note=0;
    reg [7:0] dynamics=192;
    reg [11:0] divider=0;
    wire tick=divider==3071;
    always @(posedge clk)if(!reset_n)divider<=0;else divider<=tick ? 0 : divider+1'b1;
    wire ready,deadline,pcm_valid,piano_busy,audio_busy;
    wire signed [15:0] pcm;
    integer n,i,cycles,max_cycles=0,fd;
    reg [31:0] previous_phase,phase_difference;
    instrument_voice_bank #(.LIVE_DYNAMICS(1),.SAMPLE_RATE_RATIO(3),
        .MARIMBA_MODE_FILE("src/rom/marimba48_48828.hex")) bank(
        .clk(clk),.reset_n(reset_n),.sample_tick(tick),.stop_all(stop_all),.marimba_mode(marimba),
        .event_valid(valid),.event_on(on),.event_update(update),.event_note(note),
        .event_dynamics(dynamics),.pitch_ratio(18'd64425),.event_ready(ready),.deadline_error(deadline),
        .pcm(pcm),.pcm_valid(pcm_valid),.piano_busy(piano_busy),.audio_busy(audio_busy),
        .limiting(),.saturated());
    task event_send(input integer pitch,input gate,input change);
        begin @(negedge clk);wait(ready);note=pitch;on=gate;update=change;valid=1;
            @(negedge clk);valid=0;end
    endtask
    task render;
        begin
            @(posedge tick);@(negedge clk);cycles=0;
            while(!pcm_valid && cycles<3072)begin @(negedge clk);cycles=cycles+1;end
            if(cycles>=3072 || deadline || (^pcm===1'bx))$fatal(1,"Native-rate sample deadline/data");
            if(cycles>max_cycles)max_cycles=cycles;
        end
    endtask
    task clear_bank(input mode);
        begin @(negedge clk);stop_all=1;marimba=mode;
            @(negedge tick);repeat(4)@(negedge clk);stop_all=0;end
    endtask
    initial begin
        repeat(8)@(negedge clk);reset_n=1;
        for(n=0;n<88;n=n+1)event_send(n,1,0);
        repeat(1024)render();
        if(bank.piano.active_voices!=88)$fatal(1,"Native 88-note piano stress incomplete");
        clear_bank(0);event_send(48,1,0);
        fd=$fopen("output/audio150/piano_a4.hex","w");
        for(i=0;i<4096;i=i+1)begin
            render();$fdisplay(fd,"%04x",pcm);
            phase_difference=bank.piano.voice_ram[48][82:51]-previous_phase;
            if(i>0 && phase_difference!=
                ((64'(bank.piano.frequency_rom[48])*64425)>>16))
                $fatal(1,"Native piano phase increment/pitch mismatch");
            previous_phase=bank.piano.voice_ram[48][82:51];
        end
        $fclose(fd);
        clear_bank(0);event_send(87,1,0);
        fd=$fopen("output/audio150/piano_c8.hex","w");
        for(i=0;i<2048;i=i+1)begin render();$fdisplay(fd,"%04x",pcm);end
        $fclose(fd);
        clear_bank(0);event_send(48,1,0);repeat(12)render();
        dynamics=64;event_send(48,1,1);repeat(12)render();
        if(!bank.piano.gates[48] || bank.piano.voice_ram[48][90:83]>=192)
            $fatal(1,"Native pressure update did not slew without release");
        clear_bank(1);dynamics=192;
        for(n=36;n<=83;n=n+1)event_send(n,1,0);
        repeat(12)render();
        for(n=0;n<48;n=n+1)if(!bank.marimba.active_modes[n*4])
            $fatal(1,"Native 48-note marimba stress incomplete");
        clear_bank(1);event_send(69,1,0);
        fd=$fopen("output/audio150/marimba_a4.hex","w");
        for(i=0;i<4096;i=i+1)begin render();$fdisplay(fd,"%04x",pcm);end
        $fclose(fd);
        clear_bank(0);
        passed=1;
        $display("PASS native 150 MHz core: 88 piano/48 marimba voices in 3072-cycle frames, pressure slew, retuned A4/C8 and 10240 PCM samples; max %0d clocks",max_cycles);
        $finish;
    end
    initial begin #300000000;$fatal(1,"Native core timeout");end
endmodule
