`timescale 1ns/1ps
module tb_video_clock;
    reg sys_clk=0, reset=1;
    always #10 sys_clk=~sys_clk;
    wire serial_clk,pixel_clk,locked;
    reg passed=0;
    GSR GSR(.GSRI(1'b1));
    video_clock dut(.sys_clk(sys_clk),.reset(reset),.serial_clk(serial_clk),
        .pixel_clk(pixel_clk),.locked(locked));
    realtime t0,period_pixel,period_serial;
    initial begin
        #100; reset=0;
        wait(locked === 1'b1);
        repeat(10) @(posedge pixel_clk);
        t0=$realtime;
        repeat(100) @(posedge pixel_clk);
        period_pixel=($realtime-t0)/100.0;
        @(posedge serial_clk); t0=$realtime;
        repeat(500) @(posedge serial_clk);
        period_serial=($realtime-t0)/500.0;
        if(period_pixel<9.24 || period_pixel>9.28 || period_serial<1.84 || period_serial>1.86)
            $fatal(1,"Unexpected pixel/serial periods: %f %f",period_pixel,period_serial);
        if(period_pixel/period_serial<4.99 || period_pixel/period_serial>5.01)
            $fatal(1,"Incorrect serializer ratio");
        $display("PASS: PLL startup/lock, pixel period=%f ns, serial period=%f ns",period_pixel,period_serial);
        passed=1;
        $finish;
    end
    initial begin
        #20000000;
        $fatal(1,"PLL failed to lock");
    end
endmodule
