`timescale 1ns/1ps
module key_guide_case #(parameter integer FAST=1)(output reg passed=0);
    localparam BITS=FAST ? 8 : 63,H0=FAST ? 2 : 15,H1=FAST ? 5 : 45;
    localparam RESET=FAST ? 40 : 15000,REFRESH=FAST ? 3600 : 100000;
    reg clk=0,rst=0,active=0;
    reg [87:0] keys=0;
    always #10 if(!passed)clk=~clk;
    wire data,static_data;
    wire [143:0] palette;
    wire [383:0] frame;
    wire [167:0] static_frame;
    wire frame_valid,static_valid;
    wire signed [31:0] frames,static_frames;
    reg [383:0] expected=0,held_frame;
    reg [167:0] static_expected;
    reg [23:0] rgb;
    integer i,j,target,checks=0,seed=816,cycles=0,last_snapshot=-1;
    ws2812_static #(.BIT_CYCLES(BITS),.T0H_CYCLES(H0),.T1H_CYCLES(H1),
        .RESET_CYCLES(RESET),.REFRESH_CYCLES(REFRESH),.LED6_RGB(24'h123456)) colors(
        .clk(clk),.reset_n(rst),.data_out(static_data),.group_palette(palette));
    ws2812_key_guide #(.BIT_CYCLES(BITS),.T0H_CYCLES(H0),.T1H_CYCLES(H1),
        .RESET_CYCLES(RESET),.REFRESH_CYCLES(REFRESH)) dut(
        .clk(clk),.reset_n(rst),.active(active),.keys(keys),.palette_rgb(palette),.data_out(data));
    ws2812_monitor #(.BIT_CYCLES(BITS),.T0H_CYCLES(H0),.T1H_CYCLES(H1),
        .RESET_CYCLES(RESET)) monitor(
        .clk(clk),.reset_n(rst),.data_in(data),.frame(frame),.frame_valid(frame_valid),.frames(frames));
    ws2812_monitor #(.PIXELS(7),.BIT_CYCLES(BITS),.T0H_CYCLES(H0),.T1H_CYCLES(H1),
        .RESET_CYCLES(RESET)) static_monitor(
        .clk(clk),.reset_n(rst),.data_in(static_data),.frame(static_frame),
        .frame_valid(static_valid),.frames(static_frames));
    `include "key_guide_reference.vh"
    always @(posedge clk) begin
        cycles=cycles+1;
        if(!rst)last_snapshot=-1;
        if(rst && dut.state==0 && dut.wait_count==dut.wait_last)begin
            if(last_snapshot>=0 && cycles-last_snapshot!=REFRESH)
                $fatal(1,"Guide refresh period %0d",cycles-last_snapshot);
            last_snapshot=cycles;
            expected<=reference_frame(keys,active,palette);
        end
        if(rst && frame_valid)begin
            if(frame!==expected)$fatal(1,"Guide color/key/group/atomic-frame mismatch");
            checks=checks+1;
        end
        if(rst && static_valid && static_frame!==static_expected)
            $fatal(1,"Original seven static LED colors changed");
    end
    task show(input [87:0] next_keys,input enabled);
        begin
            @(negedge clk);keys=next_keys;active=enabled;target=frames+2;
            wait(frames>=target);@(posedge clk);
            if(frame!==reference_frame(next_keys,enabled,palette))$fatal(1,"Guide did not settle");
        end
    endtask
    initial begin
        #1;
        if(palette!==144'h00402c_400040_404000_000040_004000_400000)
            $fatal(1,"First six guide colors differ from the existing static palette");
        static_expected=0;
        for(i=0;i<7;i=i+1)begin
            rgb=i==6 ? 24'h123456 : palette[i*24 +: 24];
            static_expected[(6-i)*24 +: 24]={rgb[15:8],rgb[23:16],rgb[7:0]};
        end
        repeat(4)@(negedge clk);rst=1;
        show(0,0);
        if(FAST)for(i=0;i<88;i=i+1)show(88'b1<<i,1);
        else begin show(88'b1<<22,1);show(88'b1<<87,1);end
        show((88'b1<<22)|(88'b1<<25),1);
        show((88'b1<<22)|(88'b1<<25)|(88'b1<<54),1);
        show((88'b1<<22)|(88'b1<<25),1);
        show({88{1'b1}},1);
        show({88{1'b1}},0);
        show(0,1);
        if(FAST)begin
            for(j=0;j<32;j=j+1)begin
                @(negedge clk);keys={$random(seed),$random(seed),$random(seed)};
                active=1;target=frames+2;
                wait(frames>=target);@(posedge clk);
            end
            // Input changes within an emitted frame must not tear its colors.
            wait(dut.state==3 && dut.pixel==4);
            @(negedge clk);held_frame=expected;keys=88'b1<<22;
            target=frames+1;wait(frames>=target);@(posedge clk);
            if(frame!==held_frame)$fatal(1,"Input update tore a guide packet");
            wait(dut.state==3 && dut.bit_count==1);
            @(negedge clk);rst=0;active=0;keys=0;
            repeat(5)@(negedge clk);
            if(data!==0)$fatal(1,"Guide reset data not low");
            rst=1;show(0,0);
        end
        if(!checks || !static_frames)$fatal(1,"Missing guide/static serial coverage");
        passed=1;
        $display("PASS guide case FAST=%0d: 88-note mapping, six colors, group priority, chords, fallback, silence, atomic frames, reset and original static LEDs; %0d checked frames",FAST,checks);
    end
    initial begin #200000000;$fatal(1,"Guide unit timeout");end
endmodule
module tb_key_guide;
    wire fast_done,default_done;
    reg passed=0;
    key_guide_case fast(fast_done);
    key_guide_case #(.FAST(0)) defaults(default_done);
    initial begin wait(fast_done && default_done);passed=1;$display("PASS key guide: accelerated exhaustive mapping and production 50 MHz serial timings");$finish;end
endmodule
