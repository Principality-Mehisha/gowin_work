//======================================================================
//  tb_adc_led - checks the ADC -> binary LED mapping of adc_led.v
//
//  Sweeps the ADC value across the full 8-bit range and compares the LED
//  output against the intended transfer curve.
//======================================================================
`timescale 1ns / 1ps

module tb_adc_led;

    reg         clk = 0;
    reg         rstn = 0;
    reg  [7:0]  adc_data = 0;
    reg         adc_dv = 0;
    wire [7:0]  led_o;

    always #10 clk = ~clk;              // 20 ns = 50 MHz

    adc_led #(
        .ADC_BITS  (8),
        .HYST      (2),
        .ACTIVE_LOW(1)
    ) dut (
        .clk     (clk),
        .rstn    (rstn),
        .adc_data(adc_data),
        .adc_dv  (adc_dv),
        .led_o   (led_o)
    );

    integer   errors = 0;
    integer   i;

    // Apply one ADC sample.  adc_dv is asserted for exactly one clock; lvl_r
    // then updates on the following clock and led_o on the one after that.
    task sample(input [7:0] raw);
        begin
            @(negedge clk);         // drive away from the active edge
            adc_data = raw;
            adc_dv   = 1'b1;
            @(posedge clk);         // adc_dv sampled -> lvl_r <= level
            @(negedge clk);
            adc_dv   = 1'b0;
            @(posedge clk);         // led_o <= decoded(lvl_r)
            @(posedge clk);         // settle
            @(negedge clk);
        end
    endtask

    // intended segment number (0..7): the top three bits of an 8-bit sample
    function [7:0] disp;
        input [7:0] val;
        begin
            disp = {5'b00000, val[7:5]};
        end
    endfunction

    // one character per LED: '+' = lit, '.' = dark
    function [8*8-1:0] pat;
        input [7:0] l;
        integer k;
        begin
            pat = 0;
            for (k = 0; k < 8; k = k + 1)
                pat[8*k +: 8] = l[k] ? "." : "+";   // active low
        end
    endfunction

    task check(input [7:0] raw);
        reg [7:0] exp;
        begin
            sample(raw);
            exp = ~disp(raw);
            $display("  adc=%3d   level=%1d   led_o=%02h   LEDs=%s   %s",
                     raw, disp(raw), led_o, pat(led_o),
                     (led_o === exp) ? "ok" : "FAIL");
            if (led_o !== exp) errors = errors + 1;
        end
    endtask

    initial begin
        $display("=== tb_adc_led ===");

        rstn = 0;
        repeat (5) @(posedge clk);
        rstn = 1;
        repeat (2) @(posedge clk);

        if (led_o !== 8'hFF) begin
            $display("FAIL reset: led_o=%02h expected FF (all LEDs off)", led_o);
            errors = errors + 1;
        end else
            $display("ok   reset: all LEDs off (led_o=%02h)", led_o);

        $display("");
        $display("-- level boundaries --");
        check(8'd0);
        check(8'd32);
        check(8'd33);
        check(8'd96);
        check(8'd97);
        check(8'd160);
        check(8'd161);
        check(8'd224);
        check(8'd255);

        $display("");
        $display("-- exhaustive sweep 0..255 --");
        for (i = 0; i < 256; i = i + 1) begin
            sample(i[7:0]);
            if (led_o !== ~disp(i[7:0])) begin
                $display("FAIL adc=%0d led_o=%02h expected %02h",
                         i, led_o, ~disp(i[7:0]));
                errors = errors + 1;
            end
        end
        $display("   sweep complete");

        $display("");
        $display("-- requirement wording --");
        sample(8'd0);
        $display("  smallest  (adc=0)    -> segment 0, LEDs=%s  (all off)", pat(led_o));
        sample(8'd40);
        $display("  next      (adc=40)   -> segment 1, LEDs=%s  (LED0)", pat(led_o));
        sample(8'd100);
        $display("  next      (adc=100)  -> segment 3, LEDs=%s  (LED0+LED1)", pat(led_o));
        sample(8'd170);
        $display("  next      (adc=170)  -> segment 5, LEDs=%s  (LED2+LED0)", pat(led_o));

        $display("");
        if (errors == 0) $display("=== ALL CHECKS PASSED ===");
        else             $display("=== %0d CHECK(S) FAILED ===", errors);
        $finish;
    end

endmodule
