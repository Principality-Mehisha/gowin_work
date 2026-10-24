`timescale 1ns/1ps
module tb_ws2812_tx;
    reg clk = 0;
    always #10 clk = ~clk;
    reg rst_n = 0, start = 0;
    reg [383:0] frame_grb = 0;
    wire data_o, busy, done;
    reg passed = 0;
    reg [383:0] expected;
    reg [383:0] decoded;
    time rise_time, last_rise, last_fall;
    integer i;

    ws2812_tx dut (.*);

    task receive_frame(input reg [383:0] wanted);
        integer bit_number;
        time high_time;
        begin
            for (bit_number = 383; bit_number >= 0; bit_number = bit_number - 1) begin
                @(posedge data_o);
                rise_time = $time;
                if (bit_number != 383 && rise_time - last_rise != 1240)
                    $fatal(1, "Bit period is not 1.24 us");
                last_rise = rise_time;
                @(negedge data_o);
                last_fall = $time;
                high_time = $time - rise_time;
                if (high_time != 300 && high_time != 900)
                    $fatal(1, "Invalid high pulse: %0t", high_time);
                decoded[bit_number] = (high_time == 900);
            end
            if (decoded !== wanted)
                $fatal(1, "Snapshot, GRB bit order, or frame length incorrect");
        end
    endtask

    task launch;
        begin
            @(negedge clk); start = 1;
            @(negedge clk); start = 0;
        end
    endtask

    initial begin
        repeat (4) @(negedge clk);
        rst_n = 1;
        wait (!busy);
        if ($time < 300000 || done !== 0 || data_o !== 0)
            $fatal(1, "Missing initial reset-low interval");
        for (i = 0; i < 16; i = i + 1)
            expected[383-i*24 -: 24] = 24'h123456 ^ (i * 24'h090703);
        frame_grb = expected;
        fork
            receive_frame(expected);
            begin
                launch();
                frame_grb = ~expected;
                repeat (100) @(negedge clk);
                launch(); // Must be ignored while busy.
            end
        join
        wait (done);
        if ($time - last_fall < 300000 || busy !== 0 || data_o !== 0)
            $fatal(1, "done asserted before reset/latch completed");
        @(negedge clk);
        @(negedge clk);
        if (done !== 0) $fatal(1, "done is not a one-clock pulse");

        // Reset an active transmission; recover with a fresh 300 us reset interval.
        launch();
        repeat (100) @(negedge clk);
        rst_n = 0;
        @(negedge clk);
        last_fall = $time;
        repeat (3) @(negedge clk);
        if (data_o !== 0 || done !== 0) $fatal(1, "Reset failed to abort frame");
        rst_n = 1;
        wait (!busy);
        if ($time - last_fall < 300000) $fatal(1, "Short reset after abort");
        expected = {16{24'h00ff00}};
        frame_grb = expected;
        fork
            receive_frame(expected);
            launch();
        join
        wait (done);
        if ($time - last_fall < 300000) $fatal(1, "Short latch after recovery");
        passed = 1;
        $display("PASS tb_ws2812_tx: 384 bits, timing, snapshot, busy rejection, reset recovery");
        $finish;
    end
    initial begin
        #5000000;
        $fatal(1, "Transmitter test timeout");
    end
endmodule
