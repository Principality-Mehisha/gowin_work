`timescale 1ns / 1ps
// Move the existing FAT32 fixture from LBA 8 to the card's LBA 32.
// Sector zero is inaccessible; all file bytes must still be identical.
module tb_fat_volume_start;
    reg clk = 0, rst_n = 0;
    reg sd_ready = 0, sd_valid = 0, sd_done = 0;
    reg [7:0] sd_data = 0;
    reg [8:0] sd_index = 0;
    wire sd_start, valid, mounted, found, done;
    wire [31:0] lba, file_size;
    wire [7:0] data;
    wire [3:0] error_code;
    reg passed = 0;
    reg [7:0] image [0:599999];
    integer i, count = 0, requests = 0;
    reg [31:0] requested_lba;

    fat_file_reader #(.VOLUME_START_LBA(32)) dut (
        .clk(clk), .rst_n(rst_n), .sd_ready(sd_ready),
        .sd_start(sd_start), .sd_lba(lba), .sd_data(sd_data),
        .sd_index(sd_index), .sd_valid(sd_valid), .sd_done(sd_done),
        .sd_error(1'b0), .data(data), .valid(valid), .ready(1'b1),
        .mounted(mounted), .file_found(found), .file_size(file_size),
        .file_done(done), .error_code(error_code)
    );
    always #10 clk = ~clk;
    initial begin
        for (i = 0; i < 600000; i = i + 1) image[i] = 0;
        $readmemh("../output/sd_music_test/fat32.hex", image);
        repeat (5) @(negedge clk);
        rst_n = 1;
        sd_ready = 1;
        forever begin
            @(posedge clk);
            if (sd_start && sd_ready) begin
                requested_lba = lba;
                if (lba < 32 || lba - 24 >= 1171)
                    $fatal(1, "Unexpected direct-volume LBA %0d", lba);
                if (requests == 0 && lba != 32)
                    $fatal(1, "Did not begin at configured volume");
                requests = requests + 1;
                @(negedge clk);
                sd_ready = 0;
                for (i = 0; i < 512; i = i + 1) begin
                    sd_index = i;
                    sd_data = image[(requested_lba - 24) * 512 + i];
                    sd_valid = 1;
                    @(negedge clk);
                end
                sd_valid = 0;
                repeat (5) @(negedge clk);
                sd_done = 1;
                @(negedge clk);
                sd_done = 0;
                sd_ready = 1;
            end
        end
    end
    // Fixture file clusters: 3, 7, 4, 12, 5, one sector per cluster.
    integer original_lba;
    always @(posedge clk) begin
        if (rst_n) begin
            if (error_code != 0)
                $fatal(1, "Direct-volume FAT error %0d", error_code);
            if (valid) begin
                case (count / 512)
                    0: original_lba = 1067;
                    1: original_lba = 1071;
                    2: original_lba = 1068;
                    3: original_lba = 1076;
                    4: original_lba = 1069;
                    default: $fatal(1, "Unexpected file length");
                endcase
                if (data !== image[original_lba * 512 + count % 512])
                    $fatal(1, "File differs at byte %0d", count);
                count = count + 1;
            end
            if (done) begin
                if (!mounted || !found || count != file_size || count != 2120)
                    $fatal(1, "Direct-volume completion mismatch: %0d", count);
                $display("PASS: configured LBA32, fragmented FAT32, %0d file bytes", count);
                passed = 1;
                $finish;
            end
        end
    end
    initial begin
        #2_000_000;
        $fatal(1, "Direct-volume timeout");
    end
endmodule
