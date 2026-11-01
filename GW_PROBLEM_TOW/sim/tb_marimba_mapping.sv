`timescale 1ns/1ps
module tb_marimba_mapping;
    reg clk=0,rst=0,enable=1,valid=0,passed=0;
    reg [6:0] base=0;
    reg [3:0] key=0;
    reg [11:0] data=3510;
    always #5 clk=~clk;
    wire ev,on,update;
    wire [6:0] note;
    wire [7:0] gain,progress;
    wire [15:0] pressed,eligible;
    wire overflow;
    integer ons[0:83],offs[0:83],total=0,i,j,before_on,before_off;
    pressure_keyboard #(.CALIBRATION_LOG2(0),.FILTER_SHIFT(0),.CONFIRM_FRAMES(1),
        .LONG_HOLD_FRAMES(2)) dut(
        .clk(clk),.reset_n(rst),.enable(enable),.marimba_mode(1'b1),
        .sample_valid(valid),.sample_key(key),.sample_data(data),.base_note(base),
        .event_ready(1'b1),.event_valid(ev),.event_on(on),.event_update(update),
        .event_note(note),.event_dynamics(gain),.pressed(pressed),.enabled_pressed(eligible),
        .long_held(),.calibrated(),.hold_progress(progress),.overflow(overflow));
    always @(posedge clk)if(rst)begin
        if(overflow)$fatal(1,"Marimba mapping queue overflow");
        if(ev)begin
            if(note<36 || note>83)$fatal(1,"Marimba mapping outside C2..B5");
            if(!update)begin
                if(on)begin ons[note]=ons[note]+1;total=total+1;end
                else offs[note]=offs[note]+1;
            end
        end
    end
    task sample(input integer k,input integer value);
        begin
            @(negedge clk);key=k;data=value;valid=1;
            @(negedge clk);valid=0;repeat(100)@(negedge clk);
        end
    endtask
    initial begin
        for(i=0;i<84;i=i+1)begin ons[i]=0;offs[i]=0;end
        repeat(4)@(negedge clk);rst=1;
        for(i=0;i<16;i=i+1)sample(i,3510);
        for(i=0;i<3;i=i+1)begin
            base=i*16;
            for(j=0;j<16;j=j+1)begin
                sample(j,1900);
                if(ons[36+i*16+j]!=1)$fatal(1,"Missing marimba group/key %0d/%0d",i,j);
                sample(j,3510);
                if(offs[36+i*16+j]!=1)$fatal(1,"Wrong marimba release");
            end
        end
        for(i=3;i<7;i=i+1)begin
            base=i*16;before_on=total;
            for(j=0;j<16;j=j+1)begin
                sample(j,1900);
                repeat(20)sample(j,1900);
                if(total!=before_on || eligible || progress)$fatal(1,"Invalid group sounded/lit LED");
                sample(j,3510);
            end
        end
        base=0;sample(0,1900);before_off=offs[36];
        base=32;sample(1,1900);
        base=96;before_on=total;sample(2,1900);
        sample(0,3510);
        if(offs[36]!=before_off+1)$fatal(1,"Group change lost old marimba release");
        base=0;repeat(20)sample(2,1900);
        if(total!=before_on)$fatal(1,"Invalid held key replayed after valid group selected");
        sample(1,3510);sample(2,3510);
        sample(2,1900);
        if(ons[38]!=2)$fatal(1,"Release/repress did not rearm marimba key");
        sample(2,3510);
        passed=1;$display("PASS marimba mapping: all 48 pitches, four invalid groups, LED eligibility, captured release and fresh-press rearm");$finish;
    end
    initial begin #10000000;$fatal(1,"Marimba mapping timeout");end
endmodule
