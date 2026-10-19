`timescale 1ns/1ps
// Uses the installed official Gowin primitive model, never a hand-made PLL clock.
module tb_clock;
    reg clk=0; always #10 clk=~clk;
    reg reset=1;
    wire audio_clk,locked;
    reg passed=0;
    realtime first,last,period_ns;
    integer i;
    audio_clock dut(.sys_clk(clk),.reset_n(~reset),.audio_clk(audio_clk),.locked(locked));
    initial begin
        #100; reset=0;
        wait(locked);
        @(posedge audio_clk); first=$realtime;
        repeat(3200) @(posedge audio_clk);
        last=$realtime;
        period_ns=(last-first)/3200.0;
        if(period_ns<6.509 || period_ns>6.512)
            $fatal(1,"PLL audio frequency mismatch: period %f ns",period_ns);
        $display("PASS tb_clock: official PLL model, audio period=%f ns, frame=%f ns",
            period_ns,last-first);
        passed=1; $finish;
    end
    initial begin #20000000; $fatal(1,"PLL lock timeout"); end
endmodule
