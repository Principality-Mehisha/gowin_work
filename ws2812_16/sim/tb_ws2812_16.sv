`timescale 1ns/1ps
module tb_ws2812_16;
    reg sys_clk = 0;
    always #10 sys_clk = ~sys_clk;
    wire led_data;
    reg passed = 0;
    // Accelerate animation only; all physical pulse/reset timings remain unchanged.
    ws2812_16 #(.FRAME_PERIOD_CYCLES(40000), .STEP_FRAMES(1), .POR_CYCLES(8)) dut (.*);
    integer frame_number, pixel, bit_number, expected_mode, expected_step;
    reg [23:0] pixel_value, expected_color;
    time rise_time, last_rise, last_fall = 0, frame_start, previous_start;
    time high_time;

    initial begin
        // 80 frames cover every mode/position; frame 81 checks full wrap to red.
        for (frame_number = 0; frame_number < 81; frame_number = frame_number + 1) begin
            expected_mode = (frame_number / 16) % 5;
            expected_step = frame_number % 16;
            for (pixel = 0; pixel < 16; pixel = pixel + 1) begin
                for (bit_number = 23; bit_number >= 0; bit_number = bit_number - 1) begin
                    @(posedge led_data);
                    rise_time = $time;
                    if (pixel == 0 && bit_number == 23) begin
                        frame_start = rise_time;
                        if (rise_time - last_fall < 300000)
                            $fatal(1, "Missing 300 us reset/latch interval");
                        if (frame_number > 0 && frame_start - previous_start != 800000)
                            $fatal(1, "Frame scheduler period incorrect");
                        previous_start = frame_start;
                    end else if (rise_time - last_rise != 1240)
                        $fatal(1, "Bit gap or unexpected reset inside 384-bit frame");
                    last_rise = rise_time;
                    @(negedge led_data);
                    last_fall = $time;
                    high_time = $time - rise_time;
                    if (high_time != 300 && high_time != 900)
                        $fatal(1, "Invalid pulse width %0t", high_time);
                    pixel_value[bit_number] = (high_time == 900);
                end
                case (expected_mode)
                    0: expected_color = 24'h002000;
                    1: expected_color = 24'h200000;
                    2: expected_color = 24'h000020;
                    3: expected_color = 24'h202020;
                    4: expected_color = (pixel == expected_step) ? 24'h002000 : 24'h000000;
                endcase
                if (pixel_value !== expected_color)
                    $fatal(1, "Frame %0d pixel %0d: GRB %h != %h", frame_number, pixel, pixel_value, expected_color);
            end
        end
        repeat (15000) begin
            @(negedge sys_clk);
            if (led_data !== 0) $fatal(1, "Last frame latch was interrupted");
        end
        passed = 1;
        $display("PASS tb_ws2812_16: 81 frames, all 16 LEDs, GRB colors, chase, mode wrap, wire timing");
        $finish;
    end
    initial begin
        #100000000;
        $fatal(1, "Demo test timeout");
    end
endmodule
