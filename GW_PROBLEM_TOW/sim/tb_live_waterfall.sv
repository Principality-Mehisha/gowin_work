`timescale 1ns/1ps
// Independent history model; asynchronous clocks and taps shorter than a frame.
module tb_live_waterfall;
    reg passed=0,clk=0,pclk=0,rst=0,tick=0,active=1,clear=0;
    always #10 clk=~clk;
    always #4.62963 pclk=~pclk;
    reg [87:0] keys=0;
    reg [1:0] mode=0;
    wire update,va,vc;
    wire [87:0] vk,activity;
    wire [1:0] vm;
    playback_video_cdc #(.REALTIME(1)) cdc(.sys_clk(clk),.sys_reset_n(rst),
        .pixel_clk(pclk),.pixel_reset_n(rst),.frame_tick(tick),.active(active),.clear(clear),
        .display_mode(mode),.elapsed_ms(32'd0),.keys(keys),.video_mode(vm),
        .update(update),.video_active(va),.video_ms(),.video_keys(vk),
        .video_clear(vc),.video_activity(activity));
    reg [9:0] y=0;
    reg [6:0] pitch=0;
    wire [1:0] pixel;
    piano_live_roll roll(.clk(pclk),.reset_n(rst),.update(update),.active(va),
        .clear(vc),.activity(activity),.y(y),.read_pitch(pitch),.pixel(pixel));
    reg [87:0] reference[0:179];
    integer i,j,age,frames=0,checks=0;
    reg expected;
    task check_pixel(input integer row,input integer note);
        begin
            @(negedge pclk);y=row;pitch=note;
            repeat(3)@(negedge pclk);
            expected=row<720 && note<88 ? reference[row/4][note] : 0;
            if(pixel!==(expected ? 2'b11 : 2'b00))
                $fatal(1,"Live pixel frame=%0d y=%0d note=%0d got=%b expected=%b",frames,row,note,pixel,expected);
            checks=checks+1;
        end
    endtask
    task snapshot(input [87:0] expected_activity,input [87:0] expected_keys,input bit expected_clear);
        begin
            @(negedge pclk);tick=1;@(negedge pclk);tick=0;
            wait(update);@(negedge pclk);
            if(activity!==expected_activity || vk!==expected_keys || vc!==expected_clear || vm!==mode)
                $fatal(1,"CDC snapshot activity=%h keys=%h clear=%b",activity,vk,vc);
            if(expected_clear || !active)for(j=0;j<180;j=j+1)reference[j]=0;
            for(j=179;j>0;j=j-1)reference[j]=reference[j-1];
            reference[0]=active ? expected_activity : 0;
            repeat(3)@(negedge pclk);frames=frames+1;
        end
    endtask
    initial begin
        for(i=0;i<180;i=i+1)reference[i]=0;
        repeat(4)@(negedge clk);rst=1;
        snapshot(0,0,1);
        // A tap completely between two frame requests must survive once in
        // history, while its released key is already dark.
        @(negedge clk);keys=88'd1<<39;@(negedge clk);keys=0;
        repeat(4)@(negedge clk);snapshot(88'd1<<39,0,0);
        check_pixel(0,39);check_pixel(3,39);check_pixel(4,39);
        snapshot(0,0,0);check_pixel(0,39);check_pixel(4,39);
        // Hold a chord, then release: the contiguous bar moves downwards.
        @(negedge clk);keys=(88'd1<<39)|(88'd1<<43)|(88'd1<<46);
        repeat(4)@(negedge clk);
        for(i=0;i<12;i=i+1)snapshot(keys,keys,0);
        @(negedge clk);keys=0;repeat(4)@(negedge clk);
        snapshot(reference[0],0,0);snapshot(0,0,0);
        for(i=0;i<88;i=i+1)begin check_pixel(0,i);check_pixel(4,i);check_pixel(48,i);end
        // Clear is one sys-clock command between frame requests. New notes
        // after it survive; pre-clear notes cannot reappear after ring wrap.
        @(negedge clk);clear=1;@(negedge clk);clear=0;keys=88'd1<<87;
        repeat(4)@(negedge clk);snapshot(keys,keys,1);
        check_pixel(0,87);check_pixel(4,39);
        // More than two complete wraps; independently compare random ages,
        // boundaries, the entire pitch range and invalid pitch indices.
        for(i=0;i<380;i=i+1)begin
            @(negedge clk);keys=88'd1<<(i%88);mode=i%3;
            repeat(4)@(negedge clk);
            snapshot(keys | (i==0 ? (88'd1<<87) : (88'd1<<((i-1)%88))),keys,0);
            check_pixel(0,i%88);check_pixel(719,(i+3)%88);
            check_pixel((i*37)%720,(i*17)%88);check_pixel(720,39);check_pixel(0,127);
        end
        active=0;clear=1;repeat(4)@(negedge clk);snapshot(0,0,1);
        check_pixel(0,87);check_pixel(719,39);
        // Both handshake sides reset together, including an outstanding request.
        @(negedge pclk);tick=1;@(negedge pclk);tick=0;rst=0;
        repeat(4)@(negedge clk);rst=1;keys=0;clear=0;active=1;
        repeat(4)@(negedge clk);snapshot(0,0,1);check_pixel(0,39);
        passed=1;$display("PASS live waterfall: %0d frames, %0d pixel checks, short taps, chord length, downward scroll, clear, mode changes, ring wrap and reset",frames,checks);$finish;
    end
    initial begin #10000000;$fatal(1,"Live waterfall timeout");end
endmodule
