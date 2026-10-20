`timescale 1ns/1ps
module tb_dac;
    reg clk=0; always #3.255208333 clk=~clk;
    reg reset_n=0,mute=0;
    reg signed [15:0] pcm=16'h81a5;
    wire bck,ws,din,tick,pa;
    reg passed=0;
    integer edges=0,cycle=0,last_tick=0,frame_count=0;
    reg [15:0] received=0,right_word=0;
    integer bitcount=0;
    reg started=0;
    pt8211_score_tx #(.BCK_HALF_DIV(50),.AMP_START_CYCLES(10)) dut (
        .sys_clk(clk),.sys_rst_n(reset_n),.pcm_left(mute ? 16'sd0 : pcm),
        .pcm_right(mute ? 16'sd0 : pcm),.sample_tick(tick),
        .HP_BCK(bck),.HP_WS(ws),.HP_DIN(din),.PA_EN(pa));
    always @(negedge clk) if(reset_n) begin
        cycle=cycle+1;
        if(tick) begin
            if(last_tick!=0 && cycle-last_tick!=3200)
                $fatal(1,"Fs is not exactly clock/3200");
            last_tick=cycle; frame_count=frame_count+1; started=1;
        end
    end
    always @(posedge bck) if(started) begin
        received={received[14:0],din};
        if(bitcount==15) begin
            right_word=received;
            if(ws!==0) $fatal(1,"Right WS");
        end
        if(bitcount==31) begin
            if(ws!==1 || received!==right_word) $fatal(1,"Stereo mismatch");
            if(frame_count<3 && received!==16'h81a5) $fatal(1,"Bit alignment");
            if(frame_count>=4 && received!==0) $fatal(1,"Mute not on frame boundary");
            edges=edges+1;
        end
        bitcount=(bitcount+1)%32;
    end
    initial begin
        repeat(5) @(negedge clk); reset_n=1;
        wait(frame_count==3); @(negedge clk); mute=1;
        wait(edges==5);
        if(pa!==0) $fatal(1,"Amplifier polarity");
        passed=1; $display("PASS tb_dac: 3200 clocks/frame, LSBJ, identical stereo, mute");
        $finish;
    end
    initial begin #1000000; $fatal(1,"Timeout tb_dac"); end
endmodule
