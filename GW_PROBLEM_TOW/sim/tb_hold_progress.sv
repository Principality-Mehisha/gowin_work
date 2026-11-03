`timescale 1ns/1ps
module hold_progress_case #(parameter integer FRAMES=4)(output reg passed=0);
    reg clk=0,reset_n=0,enable=1,valid=0;
    reg [3:0] key=0;
    reg [11:0] data=4000;
    always #5 if(!passed)clk=~clk;
    wire [7:0] progress;
    wire [15:0] pressed,calibrated,long_held;
    wire overflow;
    pressure_keyboard #(.CALIBRATION_LOG2(0),.FILTER_SHIFT(0),.CONFIRM_FRAMES(1),
        .LONG_HOLD_FRAMES(FRAMES)) dut(
        .clk(clk),.reset_n(reset_n),.enable(enable),.marimba_mode(1'b0),.sample_valid(valid),
        .guide_mode(1'b0),
        .sample_key(key),.sample_data(data),.base_note(7'd0),.event_ready(1'b1),
        .event_valid(),.event_on(),.event_update(),.event_note(),.event_dynamics(),
        .pressed(pressed),.enabled_pressed(),.calibrated(calibrated),.long_held(long_held),
        .hold_progress(progress),.overflow(overflow));
    task sample(input integer k,input integer value);
        begin
            @(negedge clk);key=k;data=value;valid=1;
            @(negedge clk);valid=0;
            repeat(2)@(negedge clk);
        end
    endtask
    task expect_progress(input integer mask);
        begin
            if(progress!==mask[7:0])
                $fatal(1,"Hold progress FRAMES=%0d: got=%h expected=%h",FRAMES,progress,mask[7:0]);
        end
    endtask
    integer i,k;
    initial begin
        repeat(3)@(negedge clk);reset_n=1;expect_progress(0);
        for(k=0;k<15;k=k+1)sample(k,4000);
        sample(0,3000);
        for(i=0;i<FRAMES*8;i=i+1)sample(0,3000);
        if(calibrated==16'hffff)$fatal(1,"Partial calibration setup");
        expect_progress(0);
        sample(15,4000);
        if(calibrated!=16'hffff)$fatal(1,"Full calibration setup");
        sample(0,4000);expect_progress(0);
        sample(0,3000);expect_progress(0);
        // Before/on/after every threshold, including all eight GPIO bits.
        for(i=1;i<=FRAMES*8+4;i=i+1)begin
            sample(0,3000);
            expect_progress(i>=FRAMES*8 ? 255 : (1<<(i/FRAMES))-1);
            if(long_held[0] !== (i>=FRAMES))$fatal(1,"Original long-hold flag changed");
        end
        if(dut.keys.held_frames[0]!=FRAMES*8)$fatal(1,"Hold counter did not saturate");
        sample(1,3000);
        for(i=0;i<FRAMES*2;i=i+1)sample(1,3000);
        expect_progress(255);
        sample(0,4000);expect_progress(3);
        sample(1,4000);expect_progress(0);
        // Alternating shorter presses cannot accumulate into a long press.
        for(k=0;k<2;k=k+1)begin
            sample(k,3000);
            for(i=0;i<FRAMES-1;i=i+1)sample(k,3000);
            expect_progress(0);
            sample(k,4000);expect_progress(0);
        end
        sample(0,3000);
        for(i=0;i<FRAMES*3;i=i+1)sample(0,3000);
        expect_progress(7);
        @(negedge clk);enable=0;
        repeat(2)@(negedge clk);expect_progress(0);
        for(i=0;i<FRAMES*8;i=i+1)sample(0,3000);
        expect_progress(0);
        @(negedge clk);enable=1;
        repeat(2)@(negedge clk);expect_progress(0);
        for(i=0;i<FRAMES;i=i+1)sample(0,3000);
        expect_progress(0);
        sample(0,4000);sample(0,3000);
        for(i=0;i<FRAMES-1;i=i+1)sample(0,3000);
        expect_progress(0);sample(0,3000);expect_progress(1);
        sample(0,4000);
        for(k=0;k<16;k=k+1)sample(k,3000);
        for(i=0;i<FRAMES*2;i=i+1)
            for(k=0;k<16;k=k+1)sample(k,3000);
        expect_progress(3);
        for(k=0;k<16;k=k+1)sample(k,4000);
        expect_progress(0);
        repeat(2000)@(negedge clk);
        if(overflow)$fatal(1,"LED observation affected the event queue");
        @(negedge clk);reset_n=0;repeat(3)@(negedge clk);
        expect_progress(0);
        if(calibrated || pressed)$fatal(1,"Reset retained hold state");
        passed=1;
        $display("PASS hold progress FRAMES=%0d: calibration, eight exact thresholds, saturation, per-key maximum, release, no accumulation, mode rearm, 16 keys and reset",FRAMES);
    end
endmodule
module tb_hold_progress;
    wire fast,normal;
    reg passed=0;
    hold_progress_case #(.FRAMES(4)) short_case(fast);
    hold_progress_case #(.FRAMES(1042)) default_case(normal);
    initial begin wait(fast&&normal);#1;passed=1;$display("PASS all hold-progress cases");$finish;end
    initial begin #10000000;$fatal(1,"Hold-progress timeout");end
endmodule
