`timescale 1ns/1ps
module rom_sharing_case #(
    parameter integer RATE=3,
    parameter MODE_FILE="src/rom/marimba48_48828.hex"
)(output reg passed=0);
    reg clk=0,reset_n=0,stop_all=0,valid=0,on=0,update=0,marimba=0;
    always #(RATE==3 ? 3.333333 : 10) clk=~clk;
    reg [6:0] note=0;
    reg [7:0] dynamics=192;
    reg [11:0] divider=0;
    wire tick=divider==3071;
    always @(posedge clk)if(!reset_n)divider<=0;else divider<=tick ? 0 : divider+1'b1;
    wire ready,ref_ready,deadline,ref_deadline,pcm_valid,ref_valid;
    wire piano_busy,ref_piano_busy,audio_busy,ref_audio_busy;
    wire limiting,ref_limiting,saturated,ref_saturated;
    wire signed [15:0] pcm,ref_pcm;
    localparam [17:0] PITCH=RATE==3 ? 18'd64425 : 18'd193274;
    instrument_voice_bank #(.LIVE_DYNAMICS(1),.SAMPLE_RATE_RATIO(RATE),
        .MARIMBA_MODE_FILE(MODE_FILE)) dut(
        .clk(clk),.reset_n(reset_n),.sample_tick(tick),.stop_all(stop_all),.marimba_mode(marimba),
        .event_valid(valid),.event_on(on),.event_update(update),.event_note(note),
        .event_dynamics(dynamics),.pitch_ratio(PITCH),.event_ready(ready),.deadline_error(deadline),
        .pcm(pcm),.pcm_valid(pcm_valid),.piano_busy(piano_busy),.audio_busy(audio_busy),
        .limiting(limiting),.saturated(saturated));
    instrument_voice_bank_before #(.LIVE_DYNAMICS(1),.SAMPLE_RATE_RATIO(RATE),
        .MARIMBA_MODE_FILE(MODE_FILE)) reference(
        .clk(clk),.reset_n(reset_n),.sample_tick(tick),.stop_all(stop_all),.marimba_mode(marimba),
        .event_valid(valid),.event_on(on),.event_update(update),.event_note(note),
        .event_dynamics(dynamics),.pitch_ratio(PITCH),.event_ready(ref_ready),.deadline_error(ref_deadline),
        .pcm(ref_pcm),.pcm_valid(ref_valid),.piano_busy(ref_piano_busy),.audio_busy(ref_audio_busy),
        .limiting(ref_limiting),.saturated(ref_saturated));
    integer frames=0,cycles,max_piano=0,max_marimba=0,n,m,i;
    integer parameter_checks=0,mix_checks=0;
    always @(negedge clk)if(reset_n)begin
        if({ready,deadline,pcm_valid,pcm,piano_busy,audio_busy,limiting,saturated} !==
           {ref_ready,ref_deadline,ref_valid,ref_pcm,ref_piano_busy,ref_audio_busy,ref_limiting,ref_saturated})
            $fatal(1,"ROM sharing changed outputs/latency RATE=%0d frame=%0d mode=%0d",RATE,frames,marimba);
        if(deadline)$fatal(1,"ROM sharing exceeded a fixed 3072-clock frame");
        if(dut.piano.mix_valid!==reference.piano.mix_valid ||
           dut.marimba.mix_valid!==reference.marimba.mix_valid ||
           dut.marimba.output_mix_valid!==reference.marimba.output_mix_valid)
            $fatal(1,"ROM sharing changed a synthesis pipeline valid");
        if(dut.piano.mix_valid && dut.piano.mix_sample!==reference.piano.mix_sample)
            $fatal(1,"Piano pre-limiter samples differ");
        if(dut.marimba.mix_valid && dut.marimba.mix_sample!==reference.marimba.mix_sample)
            $fatal(1,"Marimba pre-filter samples differ");
        if(dut.marimba.output_mix_valid && dut.marimba.output_mix!==reference.marimba.output_mix)
            $fatal(1,"Marimba filtered samples differ");
        if(pcm_valid)begin
            if((^pcm)===1'bx)$fatal(1,"Unknown shared-ROM PCM");
            mix_checks=mix_checks+1;
        end
    end
    task event_send(input integer pitch,input gate,input change,input integer gain);
        begin
            @(negedge clk);while(!ready)@(negedge clk);
            note=pitch;on=gate;update=change;dynamics=gain;valid=1;
            @(negedge clk);valid=0;
        end
    endtask
    task render;
        begin
            @(posedge tick);@(negedge clk);cycles=0;
            while(!pcm_valid && cycles<3072)begin @(negedge clk);cycles=cycles+1;end
            if(cycles>=3072)$fatal(1,"No PCM within native sample budget");
            if(marimba && cycles>max_marimba)max_marimba=cycles;
            if(!marimba && cycles>max_piano)max_piano=cycles;
            frames=frames+1;
        end
    endtask
    task clear_bank(input mode);
        begin
            @(negedge clk);valid=0;stop_all=1;marimba=mode;
            @(negedge tick);repeat(4)@(negedge clk);stop_all=0;
        end
    endtask
    initial begin
        repeat(8)@(negedge clk);
        for(n=0;n<48;n=n+1)begin
            for(m=0;m<4;m=m+1)begin
                if(dut.marimba.mode_rom[n*4+m]!==reference.marimba.mode_rom[n][m*64 +:64])
                    $fatal(1,"Packed mode initialization lost precision");
                parameter_checks=parameter_checks+1;
            end
            if(dut.marimba.mode_rom[192+n]!=={32'd0,reference.marimba.attack_rom[n]})
                $fatal(1,"Packed attack initialization differs");
            parameter_checks=parameter_checks+1;
        end
        reset_n=1;
        for(n=0;n<88;n=n+1)event_send(n,1,0,255);
        repeat(1024)render();
        if(dut.piano.active_voices!=88)$fatal(1,"Missing 88-note pressure stress");
        for(n=0;n<88;n=n+1)event_send(n,1,1,(n*29)%256);
        repeat(32)render();
        for(n=0;n<88;n=n+1)event_send(n,0,0,0);
        repeat(64)render();
        clear_bank(1);
        for(n=36;n<=83;n=n+1)event_send(n,1,0,255);
        repeat(128)render();
        for(n=0;n<48;n=n+1)
            if(!dut.marimba.active_modes[n*4])$fatal(1,"Missing 48-note stress");
        for(n=36;n<=83;n=n+1)event_send(n,1,1,16);
        repeat(32)render();
        for(n=36;n<=83;n=n+1)event_send(n,0,0,0);
        repeat(64)render();
        for(n=36;n<=83;n=n+1)begin
            clear_bank(1);
            event_send(n,1,0,32+(n*17)%224);
            repeat(8)render();
            event_send(n,1,0,192);
            repeat(4)render();
        end
        for(n=0;n<88;n=n+1)begin
            clear_bank(0);
            event_send(n,1,0,32+(n*11)%224);
            repeat(4)render();
            event_send(n,1,1,240);
            repeat(4)render();
        end
        // Cancel a live calculation while changing the shared ROM owner.
        for(i=0;i<16;i=i+1)begin
            clear_bank(i[0]);
            event_send(i[0] ? 36+i : i*5,1,0,192);
            @(posedge tick);repeat(20+i)@(negedge clk);
            clear_bank(!i[0]);
            event_send(i[0] ? 48 : 69,1,0,128);
            repeat(4)render();
        end
        @(negedge clk);reset_n=0;repeat(8)@(negedge clk);reset_n=1;
        clear_bank(1);event_send(83,1,0,192);repeat(16)render();
        if(mix_checks<frames)$fatal(1,"Missing exact sample checks");
        passed=1;
        $display("PASS ROM sharing RATE=%0d: %0d exact samples, %0d packed parameters; 88 piano/48 marimba, pressure/restrike/release/owner switches/reset; max piano=%0d marimba=%0d clocks",
                 RATE,mix_checks,parameter_checks,max_piano,max_marimba);
    end
endmodule

module tb_rom_sharing;
    wire native_passed,legacy_passed;
    rom_sharing_case native_case(.passed(native_passed));
    rom_sharing_case #(.RATE(1),.MODE_FILE("src/rom/marimba48.hex")) legacy_case(.passed(legacy_passed));
    reg passed=0;
    initial begin
        wait(native_passed && legacy_passed);
        passed=1;$display("PASS ROM sharing: both rates cycle/sample exact against frozen pre-change RTL");$finish;
    end
    initial begin #800000000;$fatal(1,"ROM sharing comparison timeout");end
endmodule

module tb_sine_pair_rom;
    reg clk=0,enable=0,passed=0;
    always #10 clk=~clk;
    reg [7:0] address=0;
    wire signed [15:0] value,next_value;
    reg [15:0] golden[0:255];
    integer i,checks=0;
    sine_pair_rom dut(.clk(clk),.enable(enable),.address(address),.value(value),.next_value(next_value));
    initial begin
        $readmemh("src/rom/sine256.hex",golden);
        for(i=0;i<1024;i=i+1)begin
            @(negedge clk);enable=1;address=(i*73)%256;
            @(negedge clk);
            if({value,next_value}!=={golden[address],golden[(address+1)%256]})
                $fatal(1,"Synchronous sine pair/wrap differs");
            enable=0;address=address+1'b1;
            repeat(3)begin
                @(negedge clk);
                if({value,next_value}!=={golden[(i*73)%256],golden[(i*73+1)%256]})
                    $fatal(1,"Disabled sine pair did not hold");
            end
            checks=checks+4;
        end
        passed=1;$display("PASS sine pair: %0d exact neighboring/wrap/enable checks",checks);$finish;
    end
endmodule
