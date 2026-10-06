`timescale 1ns / 1ps

// Behavioral stub for the Gowin configuration primitive used by the RTL.
module GSR(input GSRI);
endmodule

module tb_I2S_1;

    reg sys_clk;
    reg KEY0;
    reg KEY1;
    reg KEY2;

    wire HP_BCK;
    wire HP_WS;
    wire HP_DIN;
    wire PA_EN;

    I2S_1 #(
        .DEBOUNCE_CYCLES    (4),
        .AUDIO_START_CYCLES (8)
    ) dut (
        .sys_clk (sys_clk),
        .KEY0    (KEY0),
        .KEY1    (KEY1),
        .KEY2    (KEY2),
        .HP_BCK  (HP_BCK),
        .HP_WS   (HP_WS),
        .HP_DIN  (HP_DIN),
        .PA_EN   (PA_EN)
    );

    always #10 sys_clk = ~sys_clk;

    task press_key0;
        begin
            KEY0 = 1'b0;
            repeat (10) @(posedge sys_clk);
            KEY0 = 1'b1;
            repeat (10) @(posedge sys_clk);
        end
    endtask

    task press_key1;
        begin
            KEY1 = 1'b0;
            repeat (10) @(posedge sys_clk);
            KEY1 = 1'b1;
            repeat (10) @(posedge sys_clk);
        end
    endtask

    task wait_sample_ticks;
        input integer count;
        integer seen;
        begin
            seen = 0;
            while (seen < count) begin
                @(posedge sys_clk);
                if (dut.sample_tick)
                    seen = seen + 1;
            end
        end
    endtask

    initial begin
        sys_clk = 1'b0;
        KEY0    = 1'b1;
        KEY1    = 1'b1;
        KEY2    = 1'b0;

        repeat (4) @(posedge sys_clk);
        KEY2 = 1'b1;

        wait (dut.audio_ready);
        wait_sample_ticks(6);

        if (!dut.play_enabled || (dut.envelope == 16'd0)) begin
            $display("FAIL: playback did not start after reset");
            $finish;
        end

        press_key0();

        if (dut.play_enabled) begin
            $display("FAIL: KEY0 did not stop playback");
            $finish;
        end

        wait_sample_ticks(520);

        if (dut.envelope != 16'd0) begin
            $display("FAIL: envelope did not reach zero after stop");
            $finish;
        end

        press_key0();

        if (!dut.play_enabled) begin
            $display("FAIL: KEY0 did not re-enable playback");
            $finish;
        end

        wait_sample_ticks(8);

        if (dut.envelope == 16'd0) begin
            $display("FAIL: envelope did not restart after KEY0");
            $finish;
        end

        press_key1();
        wait_sample_ticks(2);

        if ((dut.note_select != 5'd1) || (dut.active_note != 5'd1)) begin
            $display("FAIL: KEY1 did not advance the note");
            $finish;
        end

        $display("PASS: stop, restart, and note switching work");
        $finish;
    end

endmodule
