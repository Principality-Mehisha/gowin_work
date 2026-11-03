`timescale 1ns/1ps
module tb_audio150_effects;
    reg clk=0,rst=0,clear=0,valid=0,passed=0;
    always #3.333333 clk=~clk;
    reg [1:0] mode=0;
    reg [6:0] amount=100;
    reg signed [15:0] sample=0;
    wire signed [15:0] result;
    wire out_valid,busy,tail,error;
    wire [1:0] applied;
    integer i,cycles,minimum=32767,maximum=-32768,expected,folded,triangle,q8;
    integer p,r0,r1,a,b,x,wet,checked=0;
    reg [31:0] phase;
    integer memory[0:511];
    localparam [31:0] STEP=439805;
    audio_effects #(.CLOCK_HZ(150000000),.CONTROL_RATE_RATIO(3)) dut(
        .clk(clk),.reset_n(rst),.clear(clear),.in_valid(valid),.in_sample(sample),
        .mode(mode),.amount(amount),.out_sample(result),.out_valid(out_valid),
        .busy(busy),.tail_active(tail),.deadline_error(error),.applied_mode(applied));
    task produce(input integer value);
        begin
            @(negedge clk);sample=value;valid=1;
            @(negedge clk);valid=0;cycles=0;
            while(!out_valid && cycles<24)begin @(negedge clk);cycles=cycles+1;end
            if(cycles==24 || error || (^result===1'bx))$fatal(1,"Native effect deadline/unknown");
            checked=checked+1;
        end
    endtask
    task select_mode(input integer value);
        begin
            @(negedge clk);mode=value;clear=1;
            @(negedge clk);clear=0;
            repeat(1000)produce(0);
            if(applied!=value || (value!=0 && dut.wet_gain!=125))
                $fatal(1,"Native effect mode/depth fade");
        end
    endtask
    initial begin
        repeat(5)@(negedge clk);rst=1;
        if(dut.DELAY_SAMPLES!=14648 || dut.DELAY_TAIL!=195312 ||
           dut.VIBRATO_BASE!=240 || dut.VIBRATO_DEPTH!=96 || dut.LFO_STEP!=STEP)
            $fatal(1,"Native effect time/rate constants");
        for(i=0;i<128;i=i+1)begin produce(i*513-32768);
            if(result!==sample)$fatal(1,"Native original mode changed sample");end
        select_mode(1);
        for(i=0;i<=195313;i=i+1)begin
            produce(i==0 ? 16000 : 0);
            if(i==14648 && result!=7812)$fatal(1,"300ms native delay tap");
            if(i==29296 && result!=3906)$fatal(1,"Native delay feedback");
        end
        if(tail || result!=0)$fatal(1,"Native 18-bit four-second tail did not expire");
        select_mode(1);
        for(i=0;i<=14648;i=i+1)begin
            produce(i==0 ? -16000 : 0);
            if(i==14648 && result!= -7813)$fatal(1,"Stale RAM/negative native delay");
        end
        select_mode(2);phase=STEP*1000;
        for(i=0;i<20000;i=i+1)begin
            folded=(phase>>15)&65535;if(phase[31])folded=folded^65535;
            wet=16000-((16000*(folded>>8))>>>7);
            expected=16000+(((wet-16000)*125)>>>8);
            produce(16000);
            if(result!=expected)$fatal(1,"Native tremolo sample mismatch");
            phase=phase+STEP;
            if(dut.lfo_phase!==phase)$fatal(1,"Native tremolo LFO not 5 Hz");
            if(result<minimum)minimum=result;
            if(result>maximum)maximum=result;
        end
        if(minimum>500 || maximum!=16000)$fatal(1,"Native tremolo lost depth");
        select_mode(3);phase=STEP*1000;p=1000&511;
        if(dut.vibrato_mix!=256)$fatal(1,"Native vibrato did not become fully wet");
        for(i=0;i<512;i=i+1)memory[i]=0;
        for(i=0;i<10400;i=i+1)begin
            x=i<10000 ? $rtoi(16000*$sin(6.283185307179586*440*i/48828.125)) : 0;
            folded=(phase>>15)&65535;if(phase[31])folded=folded^65535;
            triangle=folded-32768;q8=240*256+((triangle*96*125)>>>14);
            r0=(p-(q8>>8))&511;r1=(r0-1)&511;a=memory[r0];b=memory[r1];
            expected=a+(((b-a)*(q8&255))>>>8);
            memory[p]=x;p=(p+1)&511;phase=phase+STEP;
            produce(x);
            if(result!=expected || dut.lfo_phase!==phase)
                $fatal(1,"Native interpolated vibrato sample/5Hz phase");
        end
        if(tail || result!=0)$fatal(1,"Native vibrato tail did not clear");
        passed=1;
        $display("PASS native effects: %0d samples, 14648-sample 300ms delay/feedback, 195312-sample four-second tail, stale RAM, 5Hz tremolo depth and full-wet vibrato/phase, original bypass",checked);
        $finish;
    end
    initial begin #50000000;$fatal(1,"Native effects timeout");end
endmodule
