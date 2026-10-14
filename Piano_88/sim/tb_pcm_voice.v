`timescale 1ns / 1ps
module tb_pcm_voice;
    reg passed = 0;
    reg clk = 0;
    reg rst_n = 0;
    reg tick = 0;
    reg [6:0] note = 0;
    reg play_enabled = 1;
    wire signed [15:0] pcm;
    piano_pcm_voice #(.ROM_FILE("../src/piano_bank.hex")) dut (
        .clk(clk), .rst_n(rst_n), .sample_tick(tick),
        .audio_ready(1'b1), .note_select(note), .play_enabled(play_enabled), .pcm(pcm)
    );
    always #10 clk = ~clk;
    task sample;
        begin
            tick = 1;
            @(negedge clk);
            tick = 0;
            repeat (7) @(negedge clk);
        end
    endtask
    integer vectors, audio_file, result, i, j;
    integer vector_note, vector_offset, vector_pcm, checked;
    integer nonzero, peak, absolute_pcm;
    initial begin
        vectors = $fopen("../output/pcm_vectors.txt", "r");
        audio_file = $fopen("samples.txt", "w");
        if (!vectors || !audio_file)
            $fatal(1, "Cannot open golden vectors or simulation audio output");
        result = $fscanf(vectors, "%d %d %d\n", vector_note, vector_offset, vector_pcm);
        checked = 0;
        for (i = 0; i < 88; i = i + 1) begin
            rst_n = 0;
            note = i;
            repeat (4) @(negedge clk);
            rst_n = 1;
            sample(); // Commit selected note, with zero envelope.
            nonzero = 0;
            peak = 0;
            for (j = 0; j < 32000; j = j + 1) begin
                sample();
                if (result == 3 && vector_note == i && vector_offset == j) begin
                    if ($signed(pcm) !== vector_pcm)
                        $fatal(1, "PCM mismatch note=%0d sample=%0d got=%0d expected=%0d",
                               i, j, $signed(pcm), vector_pcm);
                    checked = checked + 1;
                    result = $fscanf(vectors, "%d %d %d\n", vector_note, vector_offset, vector_pcm);
                end
                if ((^pcm) === 1'bx || dut.position >= 32'd1006632960
                    || dut.rom_addr >= 230400)
                    $fatal(1, "Unknown PCM or invalid sample address at note %0d", i);
                if (pcm != 0)
                    nonzero = nonzero + 1;
                if (j >= 22000 && (pcm !== 16'sd0 || !dut.voice_done))
                    $fatal(1, "Post-note noise: note=%0d sample=%0d pcm=%0d",
                           i, j, $signed(pcm));
                absolute_pcm = $signed(pcm);
                if (absolute_pcm < 0)
                    absolute_pcm = -absolute_pcm;
                if (absolute_pcm > peak)
                    peak = absolute_pcm;
                if (i == 48)
                    $fdisplay(audio_file, "%0d", $signed(pcm));
            end
            // High piano notes naturally decay to mu-law zero much sooner.
            if (nonzero < 1000 || peak < 1000 || peak >= 32767)
                $fatal(1, "Silent or clipped PCM note=%0d peak=%0d count=%0d", i, peak, nonzero);
        end
        if (checked != 880)
            $fatal(1, "Expected 880 golden PCM checks, got %0d", checked);
        // Playback must restart even though the previous note finished itself.
        note = 48;
        sample();
        for (j = 0; j < 300; j = j + 1)
            sample();
        if (dut.voice_done || dut.active_note != 48 || dut.envelope == 0)
            $fatal(1, "Next selection did not restart after completion");
        for (j = 0; j < 22000; j = j + 1)
            sample();
        if (pcm !== 16'sd0 || !dut.voice_done)
            $fatal(1, "Restarted note did not finish in silence");
        play_enabled = 0;
        sample();
        play_enabled = 1;
        sample();
        for (j = 0; j < 300; j = j + 1)
            sample();
        if (dut.voice_done || dut.envelope == 0)
            $fatal(1, "Pause/resume did not retrigger a finished note");
        $fclose(vectors);
        $fclose(audio_file);
        $display("PASS: all 88 PCM notes, 880 golden samples, interpolation, one-shot end and exact silence");
        passed = 1;
        $finish;
    end
    initial begin
        #500_000_000;
        $fatal(1, "PCM voice simulation timeout");
    end
endmodule
