`timescale 1ns/1ps
// Official Gowin PLL/CLKDIV/OSER10 models; verify startup and reset/relock.
module tb_video_hardware;
    reg passed=0,clk=0,rst=0;
    always #10 clk=~clk;
    wire [2:0] dp,dn;
    wire cp,cn;
    GSR GSR(.GSRI(1'b1));
    piano_video dut(.sys_clk(clk),.reset_n(rst),.active(1'b0),.elapsed_ms(32'd0),.keys(88'd0),
        .tmds_data_p(dp),.tmds_data_n(dn),.tmds_clk_p(cp),.tmds_clk_n(cn));
    integer attempt,i;
    realtime last_edge,pixel_period;
    initial begin
        repeat(10)@(negedge clk);rst=1;
        for(attempt=0;attempt<2;attempt=attempt+1)begin
            wait(dut.locked);wait(dut.video_reset_n);
            repeat(20)@(posedge dut.pixel_clk);
            last_edge=$realtime;repeat(100)@(posedge dut.pixel_clk);
            pixel_period=($realtime-last_edge)/100;
            if(pixel_period<9.24 || pixel_period>9.28)$fatal(1,"Pixel clock frequency");
            for(i=0;i<1000;i=i+1)begin
                @(posedge dut.serial_clk);#0.1;
                if((^{dp,dn,cp,cn})===1'bx)$fatal(1,"Unknown serialized output after lock");
                if(dn!==~dp || cn!==~cp)$fatal(1,"Differential output mismatch");
            end
            @(negedge clk);rst=0;repeat(10)@(negedge clk);rst=1;
        end
        passed=1;$display("PASS: official PLL/CLKDIV/OSER10 startup, output clocks, differential lanes and reset/relock");$finish;
    end
    initial begin #20000000;$fatal(1,"Hardware startup timeout");end
endmodule
