`timescale 1ns / 1ps
module tb_piano_polyphony;
    reg passed = 0, clk = 0, rst_n = 0, tick = 0, paused = 0, mute = 0;
    reg [55:0] notes = 0, velocities = 0;
    reg [7:0] gates = 0, triggers = 0;
    wire signed [15:0] pcm;
    wire signed [15:0] reference [0:7];
    piano_polyphony #(.ROM_FILE("../src/piano_bank.hex")) dut (
        .clk(clk), .rst_n(rst_n), .sample_tick(tick), .audio_ready(1'b1),
        .paused(paused), .mute(mute), .notes(notes), .velocities(velocities),
        .gates(gates), .triggers(triggers), .pcm(pcm)
    );
    genvar v;
    generate for (v = 0; v < 8; v = v + 1) begin: refs
        piano_pcm_voice #(.ROM_FILE("../src/piano_bank.hex")) voice (
            .clk(clk), .rst_n(rst_n && !triggers[v]),
            .sample_tick(tick && !paused), .audio_ready(1'b1),
            .note_select(notes[v*7 +: 7]), .play_enabled(gates[v]),
            .sample_addr(), .sample_data(8'd0), .bank_ready(1'b1), .pcm(reference[v])
        );
    end endgenerate
    always #10 clk = ~clk;
    integer n, j, sum, product, expected, nonzero = 0;
    task frame;
        begin
            @(negedge clk); tick = 1;
            @(negedge clk); tick = 0;
            repeat (140) @(negedge clk);
            sum = 0;
            for (j = 0; j < 8; j = j + 1) begin
                product = $signed(reference[j]) * $signed({1'b0, velocities[j*7 +: 7]});
                sum = sum + (product >>> 9);
            end
            expected = sum > 30000 ? 30000 : sum < -30000 ? -30000 : sum;
            if (paused || mute) expected = 0;
            if ($signed(pcm) !== expected)
                $fatal(1, "Shared piano ROM mismatch frame=%0d got=%0d expected=%0d", n, $signed(pcm), expected);
            if (pcm != 0) nonzero = nonzero + 1;
        end
    endtask
    initial begin
        repeat (5) @(negedge clk);
        rst_n = 1;
        for (j = 0; j < 8; j = j + 1) begin
            notes[j*7 +: 7] = 10 + j * 9;
            velocities[j*7 +: 7] = 40 + j * 12;
        end
        gates = 255;
        triggers = 255;
        @(negedge clk); triggers = 0;
        for (n = 0; n < 800; n = n + 1) frame();
        paused = 1;
        repeat (8) frame();
        paused = 0;
        repeat (40) frame();
        // The same pitch on the same slot must restart its attack.
        triggers = 1;
        @(negedge clk); triggers = 0;
        repeat (80) frame();
        gates = 0;
        repeat (160) frame();
        if (pcm !== 0 || nonzero < 700)
            $fatal(1, "Polyphonic release/audio activity failed");
        mute = 1;
        repeat (4) frame();
        $display("PASS: eight shared-ROM voices exactly match original Piano_88 voices, velocity, pause, retrigger and release");
        passed = 1;
        $finish;
    end
    initial begin #10_000_000; $fatal(1, "Polyphony timeout"); end
endmodule
