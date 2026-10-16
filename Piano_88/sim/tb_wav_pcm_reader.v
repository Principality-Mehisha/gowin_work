`timescale 1ns / 1ps
`include "../output/sd_music_test/music_test_params.vh"
module tb_wav_pcm_reader;
    reg passed = 0;
    reg clk = 0, rst_n = 0;
    reg [7:0] data = 0;
    reg valid = 0, file_done = 0;
    wire ready;
    wire signed [15:0] pcm;
    wire pcm_valid, format_ok, audio_end;
    wire [3:0] error_code;
    reg [7:0] throttle = 0;
    wire pcm_ready = throttle[3:0] != 0;
    reg [7:0] bytes [0:`MUSIC_BYTES-1];
    reg [15:0] expected [0:`MUSIC_FRAMES-1];
    reg compare_pcm = 1;
    integer received = 0;
    wav_pcm_reader dut (
        .clk(clk), .rst_n(rst_n), .data(data), .valid(valid), .ready(ready),
        .file_size(32'd`MUSIC_BYTES), .file_done(file_done),
        .pcm(pcm), .pcm_valid(pcm_valid), .pcm_ready(pcm_ready),
        .format_ok(format_ok), .audio_end(audio_end), .error_code(error_code)
    );
    always #10 clk = ~clk;
    always @(negedge clk) throttle <= throttle + 1'b1;
    always @(posedge clk) begin
        if (rst_n && pcm_valid && pcm_ready && compare_pcm) begin
            if (received >= `MUSIC_FRAMES || pcm !== expected[received])
                $fatal(1, "Actual MUSIC.WAV PCM mismatch at sample %0d", received);
            received = received + 1;
        end
    end
    task reset_parser;
        begin
            @(negedge clk);
            rst_n = 0;
            valid = 0;
            file_done = 0;
            repeat (4) @(negedge clk);
            rst_n = 1;
        end
    endtask
    task feed;
        input integer length;
        integer position;
        begin
            position = 0;
            while (position < length && error_code == 0) begin
                @(negedge clk);
                data = bytes[position];
                valid = 1;
                @(posedge clk);
                if (ready)
                    position = position + 1;
            end
            @(negedge clk);
            valid = 0;
            file_done = 1;
            @(negedge clk);
            file_done = 0;
        end
    endtask
    initial begin
        $readmemh("../output/sd_music_test/music_bytes.hex", bytes);
        $readmemh("../output/sd_music_test/music_expected.hex", expected);
        reset_parser();
        feed(`MUSIC_BYTES);
        wait (audio_end || error_code != 0);
        @(negedge clk);
        if (error_code != 0 || !format_ok || received != `MUSIC_FRAMES)
            $fatal(1, "Actual MUSIC.WAV did not parse completely");
        $display("PASS: all %0d samples of the actual MUSIC.WAV match, with PCM backpressure", received);
        compare_pcm = 0;
        reset_parser();
        bytes[0] = "X";
        feed(64);
        if (error_code != 1)
            $fatal(1, "Malformed RIFF was accepted");
        bytes[0] = "R";
        reset_parser();
        bytes[22] = 2;
        feed(64);
        if (error_code != 2)
            $fatal(1, "Stereo PCM was accepted without conversion");
        bytes[22] = 1;
        reset_parser();
        bytes[24] = bytes[24] ^ 1;
        feed(64);
        if (error_code != 2)
            $fatal(1, "Wrong sample rate was accepted");
        bytes[24] = bytes[24] ^ 1;
        reset_parser();
        feed(100);
        if (error_code != 4)
            $fatal(1, "Premature file EOF was accepted");
        $display("PASS: malformed RIFF, unsupported channels/rate and premature EOF rejected");
        passed = 1;
        $finish;
    end
    initial begin
        #(`MUSIC_BYTES * 100 + 1_000_000);
        $fatal(1, "WAV parser simulation timeout");
    end
endmodule
