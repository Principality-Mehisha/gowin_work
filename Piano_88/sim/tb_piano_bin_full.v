`timescale 1ns / 1ps
`include "../output/piano_music_test/params.vh"
module tb_piano_bin_full;
    reg passed = 0, clk = 0, rst_n = 0;
    reg sd_ready = 0, sd_valid = 0, sd_done = 0;
    reg [7:0] sd_data = 0;
    reg [8:0] sd_index = 0;
    wire sd_start, valid, ready, found, done, pcm_valid, format_ok, audio_end;
    wire [31:0] sd_lba, file_size;
    wire [7:0] data;
    wire [15:0] pcm;
    wire [3:0] fat_error, pcm_error;
    reg [7:0] throttle = 0;
    wire pcm_ready = throttle[3:0] != 0;
    fat_file_reader #(.FILE_NAME("PIANO   BIN")) fat (
        .clk(clk), .rst_n(rst_n), .sd_ready(sd_ready),
        .sd_start(sd_start), .sd_lba(sd_lba), .sd_data(sd_data),
        .sd_index(sd_index), .sd_valid(sd_valid), .sd_done(sd_done), .sd_error(1'b0),
        .data(data), .valid(valid), .ready(ready), .mounted(),
        .file_found(found), .file_size(file_size), .file_done(done), .error_code(fat_error)
    );
    raw_pcm_reader decoder (
        .clk(clk), .rst_n(rst_n), .data(data), .valid(valid), .ready(ready),
        .file_found(found), .file_size(file_size), .file_done(done),
        .pcm(pcm), .pcm_valid(pcm_valid), .pcm_ready(pcm_ready),
        .format_ok(format_ok), .audio_end(audio_end), .error_code(pcm_error)
    );
    always #10 clk = ~clk;
    always @(negedge clk) throttle <= throttle + 1'b1;
    integer disk, expected, result, frames = 0, sectors = 0, index;
    integer low, high;
    reg [7:0] block [0:511];
    reg [31:0] lba;
    initial begin
        disk = $fopen("../output/piano_music_test/full_fat32.img", "rb");
        expected = $fopen("../sd_card/piano_music/PIANO.BIN", "rb");
        if (!disk || !expected) $fatal(1, "Cannot open BIN fixtures");
        repeat (5) @(negedge clk);
        rst_n = 1;
        sd_ready = 1;
        forever begin
            @(posedge clk);
            if (sd_start && sd_ready) begin
                lba = sd_lba;
                @(negedge clk); sd_ready = 0;
                result = $fseek(disk, lba * 512, 0);
                if (result != 0) $fatal(1, "Seek failed");
                result = $fread(block, disk);
                if (result != 512) $fatal(1, "Read failed");
                for (index = 0; index < 512; index = index + 1) begin
                    sd_data = block[index]; sd_index = index; sd_valid = 1;
                    @(negedge clk);
                end
                sd_valid = 0;
                repeat (5) @(negedge clk);
                sd_done = 1;
                @(negedge clk); sd_done = 0; sd_ready = 1;
                sectors = sectors + 1;
            end
        end
    end
    always @(posedge clk) if (rst_n) begin
        if (fat_error || pcm_error) $fatal(1, "Full BIN error FAT=%0d PCM=%0d", fat_error, pcm_error);
        if (pcm_valid && pcm_ready) begin
            low = $fgetc(expected); high = $fgetc(expected);
            if (low < 0 || high < 0 || pcm !== {high[7:0], low[7:0]})
                $fatal(1, "Full BIN mismatch sample %0d", frames);
            frames = frames + 1;
        end
        if (audio_end) begin
            if (frames != `PIANO_FRAMES || file_size != `PIANO_BYTES || !format_ok
                || $fgetc(expected) != -1)
                $fatal(1, "Full BIN length/status mismatch");
            $display("PASS: complete PIANO.BIN, %0d exact PCM samples through fragmented FAT32, %0d sectors",
                     frames, sectors);
            passed = 1;
            $finish;
        end
    end
    initial begin
        #(`PIANO_BYTES * 220 + 1_000_000);
        $fatal(1, "Full BIN timeout");
    end
endmodule
