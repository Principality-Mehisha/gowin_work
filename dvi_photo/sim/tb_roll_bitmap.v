`timescale 1ns/1ps
module tb_roll_bitmap;
    reg clk=0,reset_n=0,tick=0;
    always #5 clk=~clk;
    reg [63:0] valid=0;
    reg [447:0] pitches=0;
    reg [1023:0] tops=0,bottoms=0;
    reg [16:0] address=0;
    wire [1:0] pixel;
    wire busy,ready,overflow;
    reg passed=0;
    piano_roll_bitmap dut(.clk(clk),.reset_n(reset_n),.frame_tick(tick),
        .engine_busy(1'b0),.valid(valid),.pitch_bus(pitches),.top_bus(tops),
        .bottom_bus(bottoms),.read_address(address),.pixel(pixel),
        .busy(busy),.ready(ready),.overflow(overflow));
    integer row,pitch,cycles;
    reg [1:0] expected;
    initial begin
        repeat(3) @(negedge clk);
        reset_n=1;
        while(busy) @(negedge clk);
        valid=5'b11111;
        pitches[0*7+:7]=0; tops[0*16+:16]=-8; bottoms[0*16+:16]=12;
        pitches[1*7+:7]=0; tops[1*16+:16]=8; bottoms[1*16+:16]=20;
        pitches[2*7+:7]=1; tops[2*16+:16]=716; bottoms[2*16+:16]=740;
        pitches[3*7+:7]=87; tops[3*16+:16]=-3000; bottoms[3*16+:16]=900;
        pitches[4*7+:7]=40; tops[4*16+:16]=0; bottoms[4*16+:16]=2;
        tick=1;
        @(negedge clk);tick=0;
        cycles=0;
        while(busy) begin
            @(negedge clk);cycles=cycles+1;
            if(cycles>=175000) $fatal(1,"Bitmap missed blanking budget");
        end
        for(row=0;row<720;row=row+1) begin
            for(pitch=0;pitch<88;pitch=pitch+1) begin
                address={row[9:0],pitch[6:0]};
                @(posedge clk); #1;
                expected=0;
                if(pitch==0) begin
                    if(row<12) expected=expected | (row<10 ? 2'b10 : 2'b01);
                    if(row>=8 && row<20) expected=expected | (row>=10 && row<18 ? 2'b10 : 2'b01);
                end
                if(pitch==1 && row>=716) expected=row>=718 ? 2'b10 : 2'b01;
                if(pitch==87) expected=2'b10;
                if(pitch==40 && row<2) expected=2'b01;
                if(pixel !== expected) $fatal(1,"Bitmap mismatch row=%0d note=%0d got=%b expected=%b",row,pitch,pixel,expected);
                @(negedge clk);
            end
        end
        if(!ready || overflow) $fatal(1,"Bitmap status error");
        $display("PASS: all 63360 pitch/row cells, repeated-note union, clipping, no-change RAM; rebuild=%0d clocks",cycles);
        passed=1;
        $finish;
    end
endmodule
