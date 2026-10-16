`timescale 1ns / 1ps
`include "../output/sd_music_test/music_test_params.vh"
// Check the entire real file through FAT with an abstract CRC-validated sector host.
// The independent SPI/PT8211 bench covers the physical wire protocol.
module tb_fat_full_music;
    reg passed = 0;
    reg clk = 0, rst_n = 0;
    reg sd_ready = 0, sd_valid = 0, sd_done = 0;
    reg [7:0] sd_data = 0;
    reg [8:0] sd_index = 0;
    wire sd_start;
    wire [31:0] sd_lba, file_size;
    wire [7:0] data;
    wire valid, mounted, found, done;
    wire [3:0] error_code;
    reg [7:0] throttle = 0;
    wire ready = throttle[2:0] != 0;
    fat_file_reader dut (
        .clk(clk), .rst_n(rst_n), .sd_ready(sd_ready),
        .sd_start(sd_start), .sd_lba(sd_lba),
        .sd_data(sd_data), .sd_index(sd_index), .sd_valid(sd_valid),
        .sd_done(sd_done), .sd_error(1'b0),
        .data(data), .valid(valid), .ready(ready), .mounted(mounted),
        .file_found(found), .file_size(file_size), .file_done(done), .error_code(error_code)
    );
    always #10 clk = ~clk;
    always @(negedge clk) throttle <= throttle + 1'b1;
    integer disk, expected, result, count = 0, sectors = 0, index;
    reg [7:0] block [0:511];
    reg [31:0] requested_lba;
    initial begin
        disk = $fopen("../output/sd_music_test/full_fat32.img", "rb");
        expected = $fopen("../sd_card/music/MUSIC.WAV", "rb");
        if (!disk || !expected) $fatal(1, "Cannot open full music fixtures");
        repeat (5) @(negedge clk);
        rst_n = 1;
        sd_ready = 1;
        forever begin
            @(posedge clk);
            if (sd_start && sd_ready) begin
                requested_lba = sd_lba;
                @(negedge clk);
                sd_ready = 0;
                result = $fseek(disk, requested_lba * 512, 0);
                if (result != 0) $fatal(1, "Fixture seek failed");
                result = $fread(block, disk);
                if (result != 512) $fatal(1, "Fixture sector read failed");
                for (index = 0; index < 512; index = index + 1) begin
                    sd_data = block[index];
                    sd_index = index;
                    sd_valid = 1;
                    @(negedge clk);
                end
                sd_valid = 0;
                // CRC is complete before committing a sector to FAT.
                repeat (5) @(negedge clk);
                sd_done = 1;
                @(negedge clk);
                sd_done = 0;
                sd_ready = 1;
                sectors = sectors + 1;
            end
        end
    end
    integer expected_byte;
    always @(posedge clk) begin
        if (rst_n) begin
            if (error_code != 0) $fatal(1, "FAT long-file read failed");
            if (valid && ready) begin
                expected_byte = $fgetc(expected);
                if (expected_byte < 0 || data !== expected_byte[7:0])
                    $fatal(1, "Full music FAT mismatch at byte %0d", count);
                count = count + 1;
            end
            if (done) begin
                if (count != `MUSIC_BYTES || file_size != `MUSIC_BYTES
                    || !mounted || !found || $fgetc(expected) != -1)
                    $fatal(1, "FAT long file did not reach exact EOF");
                $display("PASS: full MUSIC.WAV, %0d exact bytes, %0d sector reads, fragmented multi-sector clusters",
                         count, sectors);
                $fclose(expected);
                $fclose(disk);
                passed = 1;
                $finish;
            end
        end
    end
    initial begin
        #(`MUSIC_BYTES * 200 + 1_000_000);
        $fatal(1, "Full FAT simulation timeout");
    end
endmodule
