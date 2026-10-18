`timescale 1ns / 1ps
module GSR(input GSRI);
endmodule

module tb_piano_88;
    reg passed = 0;
    reg clk = 0;
    reg KEY0 = 1;
    reg KEY1 = 1;
    reg KEY2 = 1;
    wire bck, ws, din, amp;
    piano_88 #(
        .DEBOUNCE_CYCLES(8), .AUDIO_START_CYCLES(64), .POWER_ON_CYCLES(8),
        .ROM_FILE("../src/piano_bank.hex"), .USE_SD(0)
    ) dut (
        .sys_clk(clk), .KEY0(KEY0), .KEY1(KEY1), .KEY2(KEY2),
        .HP_BCK(bck), .HP_WS(ws), .HP_DIN(din), .PA_EN(amp)
    );
    always #10 clk = ~clk;

    task next_note;
        begin
            @(negedge clk) KEY1 = 0;
            repeat (32) @(negedge clk);
            KEY1 = 1;
            repeat (32) @(negedge clk);
        end
    endtask
    task toggle;
        begin
            @(negedge clk) KEY0 = 0;
            repeat (32) @(negedge clk);
            KEY0 = 1;
            repeat (32) @(negedge clk);
        end
    endtask
    task samples;
        input integer count;
        integer seen;
        begin
            seen = 0;
            while (seen < count) begin
                @(negedge clk);
                if (dut.sample_tick)
                    seen = seen + 1;
            end
        end
    endtask

    integer i;

    initial begin
        // KEY2 stays high: verify configuration-time POR without a user reset.
        repeat (100) @(negedge clk);
        samples(4);
        if (!dut.rst_n || !dut.audio_ready || amp !== 0
            || dut.has_selected || dut.play_enabled || dut.pcm !== 0)
            $fatal(1, "Power-on did not enter silent ready state");
        toggle();
        if (dut.play_enabled)
            $fatal(1, "Pause before first selection must stay silent");

        // Sub-threshold press bounce must not select a note.
        repeat (4) begin
            KEY1 = 0; repeat (2) @(negedge clk);
            KEY1 = 1; repeat (2) @(negedge clk);
        end
        repeat (32) @(negedge clk);
        if (dut.has_selected)
            $fatal(1, "Press bounce produced an action");

        next_note();
        samples(300);
        if (dut.note_select != 0 || !dut.play_enabled || dut.u_voice.envelope == 0)
            $fatal(1, "First press did not start A0");

        // A held second press advances once; release bounce does not re-arm.
        KEY1 = 0;
        repeat (200) @(negedge clk);
        if (dut.note_select != 1)
            $fatal(1, "Held press must advance exactly once");
        repeat (4) begin
            KEY1 = 1; repeat (2) @(negedge clk);
            KEY1 = 0; repeat (2) @(negedge clk);
        end
        repeat (32) @(negedge clk);
        if (dut.note_select != 1)
            $fatal(1, "Release bounce produced another action");
        KEY1 = 1;
        repeat (32) @(negedge clk);

        for (i = 2; i < 88; i = i + 1) begin
            next_note();
            if (dut.note_select != i)
                $fatal(1, "Selection mismatch at note %0d", i);
        end
        samples(300);
        if (dut.u_voice.active_note != 87 || dut.u_voice.envelope == 0)
            $fatal(1, "C8 did not reach the audio voice");
        next_note();
        samples(300);
        if (dut.note_select != 0 || dut.u_voice.active_note != 0)
            $fatal(1, "89th press did not wrap to A0");

        toggle();
        samples(140);
        if (dut.play_enabled || dut.pcm !== 0)
            $fatal(1, "Pause did not release to silence");
        toggle();
        samples(300);
        if (!dut.play_enabled || dut.u_voice.envelope == 0)
            $fatal(1, "Resume did not retrigger the selected note");
        toggle();
        samples(140);
        next_note();
        samples(300);
        if (!dut.play_enabled || dut.note_select != 1)
            $fatal(1, "Next press while paused did not start the next note");

        KEY2 = 0;
        repeat (8) @(negedge clk);
        if (amp !== 1 || dut.play_enabled || dut.has_selected || dut.pcm !== 0)
            $fatal(1, "User reset did not silence and clear selection");
        KEY2 = 1;
        repeat (100) @(negedge clk);
        next_note();
        samples(300);
        if (dut.note_select != 0)
            $fatal(1, "First press after reset did not restart A0");
        $display("PASS: power-on, debounce, hold, all 88 selections, wrap, pause and reset");

        passed = 1;
        $finish;
    end
    initial begin
        #200_000_000;
        $fatal(1, "Simulation timeout");
    end
endmodule
