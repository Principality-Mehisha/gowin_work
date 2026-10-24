`timescale 1ns/1ps
`include "score_config.vh"
module tb_waterfall;
    reg clk = 0;
    always #5 clk = ~clk;
    reg reset_n = 0, tick = 0;
    wire [63:0] valid, hand;
    wire [703:0] left_bus, right_bus;
    wire [1023:0] top_bus, bottom_bus;
    wire [87:0] lit;
    wire [15:0] frame_number;
    wire busy, overflow;
    reg passed = 0;
    waterfall_engine dut(.clk(clk), .reset_n(reset_n), .frame_tick(tick),
        .valid(valid), .hand(hand), .left_bus(left_bus), .right_bus(right_bus), .pitch_bus(),
        .top_bus(top_bus), .bottom_bus(bottom_bus), .lit_keys(lit),
        .frame_number(frame_number), .busy(busy), .overflow(overflow));
    reg [87:0] expected_keys [0:`SCORE_LOOP_FRAMES-1];
    reg [7:0] expected_count [0:`SCORE_LOOP_FRAMES-1];
    reg [87:0] seen = 0, expected_seen = 0;
    integer frame, slot, count, cycles, max_cycles;
    initial begin
        $readmemh("sim/expected_keys.hex", expected_keys);
        $readmemh("sim/expected_count.hex", expected_count);
        repeat (3) @(negedge clk);
        reset_n = 1;
        max_cycles = 0;
        for (frame=0; frame<`SCORE_LOOP_FRAMES; frame=frame+1)
            expected_seen = expected_seen | expected_keys[frame];
        // Continue across loop wrap to catch reset/address/slot reuse errors.
        for (frame=1; frame<`SCORE_LOOP_FRAMES+250; frame=frame+1) begin
            tick = 1;
            @(negedge clk); tick = 0;
            cycles = 0;
            while (busy) begin
                @(negedge clk);
                cycles = cycles + 1;
                if (cycles > 10000) $fatal(1,"Scheduler missed blanking budget");
            end
            if (cycles > max_cycles) max_cycles = cycles;
            if (overflow) $fatal(1,"Slot overflow");
            if (frame_number !== frame % `SCORE_LOOP_FRAMES) $fatal(1,"Loop time mismatch");
            if (lit !== expected_keys[frame_number])
                $fatal(1,"Key timing mismatch frame=%0d actual=%h expected=%h",frame_number,lit,expected_keys[frame_number]);
            count = 0;
            for (slot=0; slot<64; slot=slot+1) begin
                if (valid[slot]) begin
                    count = count + 1;
                    if (dut.pitch[slot] > 87 || dut.note_left[slot] >= dut.note_right[slot])
                        $fatal(1,"Invalid pitch/geometry");
                    if (dut.note_top[slot] >= 720) $fatal(1,"Expired slot retained");
                end
            end
            if (count != expected_count[frame_number])
                $fatal(1,"Slot count mismatch frame=%0d got=%0d expected=%0d",frame_number,count,expected_count[frame_number]);
            seen = seen | lit;
            @(negedge clk);
        end
        if (seen !== expected_seen) $fatal(1,"Not all score pitches exercised");
        $display("PASS: full score pitches, chords, exact arrival/release, slot reuse, loop; max update %0d clocks",max_cycles);
        passed = 1;
        $finish;
    end
endmodule
