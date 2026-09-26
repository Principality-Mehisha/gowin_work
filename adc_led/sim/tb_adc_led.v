//======================================================================
//  Unit test for the ADC's useful 11-bit 0..1 V result range.
//  The vendor ADC hard macro is intentionally outside this behavioural test.
//======================================================================
`timescale 1ns / 1ps

module tb_adc_led;

    reg         clk = 0;
    reg         rstn = 0;
    reg  [10:0] adc_data = 0;
    reg         adc_dv = 0;
    wire [7:0]  led_o;

    integer errors = 0;
    integer i;

    always #10 clk = ~clk;

    adc_led #(
        .ADC_BITS   (11),
        .HYST       (0),
        .ACTIVE_LOW (1)
    ) dut (
        .clk      (clk),
        .rstn     (rstn),
        .adc_data (adc_data),
        .adc_dv   (adc_dv),
        .led_o    (led_o)
    );

    task sample;
        input [10:0] raw;
        begin
            @(negedge clk);
            adc_data = raw;
            adc_dv = 1'b1;
            @(posedge clk);
            @(negedge clk);
            adc_dv = 1'b0;
            @(posedge clk);
            @(negedge clk);
        end
    endtask

    function [7:0] expected_led;
        input [10:0] raw;
        begin
            expected_led = ~{5'b00000, raw[10:8]};
        end
    endfunction

    task check;
        input [10:0] raw;
        begin
            sample(raw);
            if (led_o !== expected_led(raw)) begin
                $display("FAIL adc=%0d led_o=%02h expected=%02h",
                         raw, led_o, expected_led(raw));
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        $display("=== tb_adc_led: 0..1 V / 2048 mapping ===");
        repeat (5) @(posedge clk);
        rstn = 1'b1;
        repeat (2) @(posedge clk);

        if (led_o !== 8'hff) begin
            $display("FAIL reset led_o=%02h expected=ff", led_o);
            errors = errors + 1;
        end

        // Check both sides of all seven range boundaries.
        check(11'd0);
        check(11'd255);
        check(11'd256);
        check(11'd511);
        check(11'd512);
        check(11'd767);
        check(11'd768);
        check(11'd1023);
        check(11'd1024);
        check(11'd1279);
        check(11'd1280);
        check(11'd1535);
        check(11'd1536);
        check(11'd1791);
        check(11'd1792);
        check(11'd2047);

        // Exhaustively verify the useful voltage range.
        for (i = 0; i < 2048; i = i + 1) begin
            sample(i[10:0]);
            if (led_o !== expected_led(i[10:0])) begin
                $display("FAIL adc=%0d led_o=%02h expected=%02h",
                         i, led_o, expected_led(i[10:0]));
                errors = errors + 1;
            end
        end

        if (errors == 0)
            $display("=== ALL 2048 ADC VALUES PASSED ===");
        else
            $display("=== %0d CHECKS FAILED ===", errors);
        $finish;
    end

endmodule
