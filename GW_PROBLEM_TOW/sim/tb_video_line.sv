`timescale 1ns/1ps
module tb_video_line;
    reg passed=0,clk=0,rst=0;
    always #5 clk=~clk;
    reg [10:0] x=1800;
    reg [9:0] y=999;
    reg [63:0] valid=0;
    reg [447:0] pitch=0;
    reg [1023:0] top_y=0,bottom_y=0;
    reg [6:0] read_pitch=0;
    wire [1:0] pixel;
    wire overflow;
    piano_roll_line dut(.clk(clk),.reset_n(rst),.x(x),.y(y),.valid(valid),
        .pitch_bus(pitch),.top_bus(top_y),.bottom_bus(bottom_y),
        .read_pitch(read_pitch),.pixel(pixel),.overflow(overflow));
    integer pass,row,n,s,lo,hi,p;
    reg [1:0] expected;
    initial begin
        repeat(3)@(negedge clk);rst=1;
        for(pass=0;pass<2;pass=pass+1) begin
            for(s=0;s<64;s=s+1) begin
                valid[s]=1;pitch[s*7+:7]=(s%44)+44*pass;
                top_y[s*16+:16]=(s*37)%1000-200;
                bottom_y[s*16+:16]=(s*37)%1000-200+40+(s%8)*40;
            end
            for(row=0;row<720;row=row+1) begin
                @(negedge clk);x=1600;y=row==0 ? 999 : row-1;
                @(negedge clk);x=1601;
                repeat(130)@(negedge clk);
                if(dut.state!=0 || overflow)$fatal(1,"Line missed horizontal blank");
                for(n=0;n<88;n=n+1) begin
                    expected=0;
                    for(s=0;s<64;s=s+1) begin
                        lo=$signed(top_y[s*16+:16]);hi=$signed(bottom_y[s*16+:16]);p=pitch[s*7+:7];
                        if(n==p && row>=lo && row<hi)
                            expected=expected | ((row>=lo+2 && row<hi-2) ? 2'b10 : 2'b01);
                    end
                    read_pitch=n;@(negedge clk);
                    if(pixel!==expected)$fatal(1,"Line union/clipping pitch=%0d y=%0d",n,row);
                end
            end
        end
        valid=0;x=1600;y=999;@(negedge clk);x=1601;
        repeat(130)@(negedge clk);
        for(n=0;n<88;n=n+1)begin read_pitch=n;@(negedge clk);if(pixel)$fatal(1,"Stale line after clear");end
        passed=1;$display("PASS: 126720 pitch/row cells, 64 slots, repeated-note union, clipping, horizontal blank budget and clear");$finish;
    end
endmodule
