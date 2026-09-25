//======================================================================
//  Unit test for the 14-bit ADC result to active-low binary LED mapping.
//  The vendor ADC hard macro is intentionally outside this behavioural test.
//======================================================================
`timescale 1ns / 1ps

module tb_adc_led;

    reg         clk = 0;
    reg         rstn = 0;
    reg  [13:0] adc_data = 0;
    reg         adc_dv = 0;
    wire [7:0]  led_o;

    integer errors = 0;
    integer i;

    always #10 clk = ~clk;

    adc_led #(
        .ADC_BITS   (14),
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
        input [13:0] raw;
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
        input [13:0] raw;
        begin
            expected_led = ~{5'b00000, raw[13:11]};
        end
    endfunction

    task check;
        input [13:0] raw;
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
        $display("=== tb_adc_led: 14-bit on-chip ADC mapping ===");
        repeat (5) @(posedge clk);
        rstn = 1'b1;
        repeat (2) @(posedge clk);

        if (led_o !== 8'hff) begin
            $display("FAIL reset led_o=%02h expected=ff", led_o);
            errors = errors + 1;
        end

        // Check both sides of all seven range boundaries.
        check(14'd0);
        check(14'd2047);
        check(14'd2048);
        check(14'd4095);
        check(14'd4096);
        check(14'd6143);
        check(14'd6144);
        check(14'd8191);
        check(14'd8192);
        check(14'd10239);
        check(14'd10240);
        check(14'd12287);
        check(14'd12288);
        check(14'd14335);
        check(14'd14336);
        check(14'd16383);

        // Exhaustively verify every possible 14-bit conversion result.
        for (i = 0; i < 16384; i = i + 1) begin
            sample(i[13:0]);
            if (led_o !== expected_led(i[13:0])) begin
                $display("FAIL adc=%0d led_o=%02h expected=%02h",
                         i, led_o, expected_led(i[13:0]));
                errors = errors + 1;
            end
        end

        if (errors == 0)
            $display("=== ALL 16384 ADC VALUES PASSED ===");
        else
            $display("=== %0d CHECKS FAILED ===", errors);
        $finish;
    end

endmodule
