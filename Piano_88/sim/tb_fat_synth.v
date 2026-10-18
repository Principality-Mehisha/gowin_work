`timescale 1ns / 1ps
// Exercise the generated FAT netlist and its actual Gowin RAM primitive.
module tb_fat_synth;
    reg clk = 0;
    reg reset = 1;
    reg host_idle = 0;
    reg sd_valid = 0, sd_done = 0;
    reg [7:0] sd_data = 0;
    reg [8:0] sd_index = 0;
    wire sd_start;
    wire [31:0] lba;
    wire [3:0] error_code;
    reg passed = 0;
    reg [7:0] image [0:599999];
    integer i, requests = 0;
    reg [31:0] requested_lba;

    GSR GSR (.GSRI(1'b1));
    fat_file_reader dut (
        .sys_clk_d(clk), .n54_5(reset),
        .sd_valid(sd_valid), .sd_error_pulse(1'b0), .sd_done(sd_done),
        .n1687_7(host_idle), .fast_clock(1'b1),
        .n2213_13(&sd_index[5:4]), .n2213_14(&sd_index[3:0]),
        .sd_error(1'b0), .bank_ready_Z(1'b0),
        .sd_index(sd_index), .sd_data(sd_data), .sd_start_Z(sd_start),
        .file_valid(), .sd_file_found(), .file_done_Z(),
        .received_signature_15_9(), .received_signature_7_10(),
        .sd_lba_Z(lba), .bank_write_data(), .fat_error(error_code)
    );
    always #10 clk = ~clk;
    initial begin
        for (i = 0; i < 600000; i = i + 1) image[i] = 0;
        $readmemh("../output/sd_music_test/fat32.hex", image);
        repeat (5) @(negedge clk);
        reset = 0;
        host_idle = 1;
        forever begin
            @(posedge clk);
            if (sd_start && host_idle) begin
                requested_lba = lba;
                requests = requests + 1;
                $display("Synthesized FAT request %0d: LBA %0d",
                         requests, lba);
                if (requests == 3) begin
                    passed = 1;
                    $display("PASS: synthesized RAM, MBR and FAT32 boot parsing");
                    $finish;
                end
                @(negedge clk);
                host_idle = 0;
                for (i = 0; i < 512; i = i + 1) begin
                    sd_data = image[requested_lba * 512 + i];
                    sd_index = i;
                    sd_valid = 1;
                    @(negedge clk);
                end
                sd_valid = 0;
                repeat (5) @(negedge clk);
                sd_done = 1;
                @(negedge clk);
                sd_done = 0;
                host_idle = 1;
            end
        end
    end
    always @(posedge clk) begin
        if (!reset && error_code != 0)
            $fatal(1, "Synthesized FAT error %0d", error_code);
    end
    initial begin
        #1_000_000;
        $fatal(1, "Synthesized FAT timeout");
    end
endmodule
