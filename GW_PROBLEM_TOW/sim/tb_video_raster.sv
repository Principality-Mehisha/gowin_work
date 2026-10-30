`timescale 1ns/1ps
module tb_video_raster;
    reg clk=0;
    always #4.629630 clk=~clk;
    reg reset_n=0;
    wire [7:0] r,g,b;
    wire hs,vs,de;
    reg passed=0;
    video_source dut(.display_mode(2'd0),.analysis_valid(1'b0),.analysis_data(32'd0),.analysis_address(),.pixel_clk(clk),.reset_n(reset_n),.test_pattern(1'b1),.update(1'b0),.active(1'b0),.elapsed_ms(32'd0),.lit_keys(88'd0),.frame_tick(),
        .red(r),.green(g),.blue(b),.hsync(hs),.vsync(vs),.de(de));
    integer cycle,n,x,y,active_count=0,hs_count=0,vs_count=0;
    reg [23:0] expected;
    initial begin
        repeat(3) @(negedge clk);
        reset_n=1;
        for(cycle=0;cycle<1800004;cycle=cycle+1) begin
            @(posedge clk); #1;
            n=cycle-4;
            if(n>=0) begin
                x=n%1800; y=n/1800;
                if(de !== (x<1600 && y<900) || hs !== (x>=1624 && x<1704)
                   || vs !== (y>=901 && y<904))
                    $fatal(1,"Timing mismatch at x=%0d y=%0d",x,y);
                if(de) active_count=active_count+1;
                if(hs) hs_count=hs_count+1;
                if(vs) vs_count=vs_count+1;
                expected=0;
                if(x<1600 && y<900) begin
                    case(x/200)
                        0:expected=24'hffffff;
                        1:expected=24'hffff00;
                        2:expected=24'h00ffff;
                        3:expected=24'h00ff00;
                        4:expected=24'hff00ff;
                        5:expected=24'hff0000;
                        6:expected=24'h0000ff;
                        7:expected=24'h000000;
                    endcase
                end
                if({r,g,b} !== expected)
                    $fatal(1,"Color/blanking mismatch x=%0d y=%0d got=%h",x,y,{r,g,b});
            end
            @(negedge clk);
        end
        if(active_count!=1440000 || hs_count!=80000 || vs_count!=5400)
            $fatal(1,"Frame/sync pulse size mismatch");
        if(dut.scene.overflow || dut.scene.line_overflow || dut.scene.engine_busy) $fatal(1,"Scheduler overran real vertical blanking");
        $display("PASS: 1800x1000 raster, 1600x900 active, +HS/+VS, 108MHz, RGB/control alignment");
        passed=1;
        $finish;
    end
endmodule
