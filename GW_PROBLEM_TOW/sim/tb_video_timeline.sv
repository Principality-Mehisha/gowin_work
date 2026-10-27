`timescale 1ns/1ps
module tb_video_timeline;
    reg passed=0,clk=0,rst=0,update=0,active=1;
    always #5 clk=~clk;
    reg [31:0] ms=0;
    wire [63:0] valid;
    wire [447:0] pitch;
    wire [1023:0] top_y,bottom_y;
    wire busy,overflow;
    waterfall_engine dut(.clk(clk),.reset_n(rst),.update(update),.active(active),
        .elapsed_ms(ms),.valid(valid),.pitch_bus(pitch),.top_bus(top_y),
        .bottom_bus(bottom_y),.busy(busy),.overflow(overflow));
    reg [31:0] count[0:0],times[0:8191];
    reg [39:0] expected[0:524287];
    integer i,j,cycles,max_cycles=0;
    task rebuild;
        begin
            @(negedge clk);update=1;@(negedge clk);update=0;cycles=0;
            while(busy) begin @(negedge clk);cycles=cycles+1;end
            if(cycles>max_cycles)max_cycles=cycles;
            if(cycles>10000 || overflow)$fatal(1,"Vertical blank update overflow");
        end
    endtask
    initial begin
        $readmemh("output/video_integration/case_count.hex",count);
        $readmemh("output/video_integration/times.hex",times,0,count[0]-1);
        $readmemh("output/video_integration/geometry.hex",expected,0,count[0]*64-1);
        repeat(3)@(negedge clk);rst=1;
        for(i=0;i<count[0];i=i+1) begin
            ms=times[i];rebuild();
            for(j=0;j<64;j=j+1) begin
                if(valid[j]!==expected[i*64+j][39]) $fatal(1,"Validity ms=%0d slot=%0d",ms,j);
                if(valid[j] && {top_y[j*16+:16],bottom_y[j*16+:16],pitch[j*7+:7]}!==expected[i*64+j][38:0])
                    $fatal(1,"Geometry ms=%0d slot=%0d",ms,j);
            end
        end
        active=0;rebuild();if(valid)$fatal(1,"Stop did not clear scene");
        active=1;ms=0;rebuild();if(!valid)$fatal(1,"Restart failed");
        $display("PASS: %0d note-boundary snapshots, absolute audio time, stop/restart; max %0d clocks",count[0],max_cycles);
        passed=1;$finish;
    end
    initial begin #500000000;$fatal(1,"Timeline timeout");end
endmodule
