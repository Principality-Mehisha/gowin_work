`timescale 1ns / 1ps
module tb_pt8211_tx;
    reg passed = 0;
    reg clk = 0;
    reg rst_n = 0;
    reg signed [15:0] left = 16'h81a5;
    reg signed [15:0] right = 16'h5a3c;
    wire bck, ws, din, tick, amp;
    pt8211_tx #(.BCK_HALF_DIV(48), .AMP_START_CYCLES(64)) dut (
        .sys_clk(clk), .sys_rst_n(rst_n), .pcm_left(left), .pcm_right(right),
        .sample_tick(tick), .HP_BCK(bck), .HP_WS(ws), .HP_DIN(din), .PA_EN(amp)
    );
    always #10 clk = ~clk;
    reg [31:0] received, expected;
    integer frame, bit_number;
    time last_edge;
    initial begin
        repeat (4) @(negedge clk);
        if (amp !== 1)
            $fatal(1, "Amplifier was enabled during reset");
        rst_n = 1;
        // Initial rising edge precedes the first frame; synchronize on falling.
        for (frame = 0; frame < 20; frame = frame + 1) begin
            @(negedge bck);
            #1;
            if (!tick || ws !== 0)
                $fatal(1, "Frame did not start with right MSB");
            expected = {right, left};
            received = 0;
            for (bit_number = 0; bit_number < 32; bit_number = bit_number + 1) begin
                @(posedge bck);
                if (bit_number > 0 && $time - last_edge != 1920)
                    $fatal(1, "Incorrect BCK period");
                last_edge = $time;
                if (ws !== (bit_number >= 16))
                    $fatal(1, "Incorrect channel boundary at bit %0d", bit_number);
                received = {received[30:0], din};
                if (bit_number == 4) begin
                    // Mid-frame PCM changes must wait until the next frame.
                    left = left + 16'h1357;
                    right = right ^ 16'hffff;
                end
            end
            if (received !== expected)
                $fatal(1, "Stereo frame mismatch got=%h expected=%h", received, expected);
        end
        if (amp !== 0)
            $fatal(1, "Amplifier failed to enable after startup");
        $display("PASS: PT8211 stereo word order, bit order, BCK and frame latching");
        passed = 1;
        $finish;
    end
    initial begin
        #2_000_000;
        $fatal(1, "Serializer simulation timeout");
    end
endmodule
