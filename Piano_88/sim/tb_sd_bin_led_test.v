`timescale 1ns / 1ps
module GSR(input GSRI);
endmodule

module sd_bin_led_case #(
    parameter integer FAT32 = 0,
    // 1=data mismatch with valid CRC, 2=missing file, 3=wrong size, 4=bad CRC.
    parameter integer FAILURE = 0
) (output reg passed = 0);
    reg clk = 0;
    reg key2 = 1;
    wire cs_n, sck, mosi, miso;
    wire [3:0] leds;
    wire [31:0] read_commands;
    localparam integer DIRECTORY = FAT32 ? 614 * 512 : 65 * 512;
    localparam integer FIRST_DATA = FAT32 ? 615 * 512 : 66 * 512;

    sd_bin_led_test #(
        .POWER_ON_CYCLES(8), .SD_POWER_WAIT_CYCLES(16),
        .SD_HALF_DIV(3), .LED_STEP_CYCLES(8)
    ) dut (
        .sys_clk(clk), .KEY2(key2), .sd_cs_n(cs_n),
        .sd_sck(sck), .sd_mosi(mosi), .sd_miso(miso), .LEDs(leds)
    );
    sd_card_model #(
        .IMAGE_FILE(FAT32 ? "../output/sd_bin_led_test/fat32_mbr.hex"
                         : "../output/sd_bin_led_test/fat16_volume.hex"),
        .IMAGE_BYTES(400000)
    ) card (
        .rst_n(dut.rst_n), .cs_n(cs_n), .sck(sck), .mosi(mosi),
        .miso(miso), .profile(FAT32 ? 2'd2 : 2'd0),
        .fault(FAILURE == 4 ? 4'd1 : 4'd0),
        .last_argument(), .read_commands(read_commands), .cmd16_seen()
    );
    always #10 clk = ~clk;

    reg [3:0] expected_leds;
    integer step;
    reg [31:0] reads_at_success;
    initial begin
        #1;
        case (FAILURE)
            1: card.image[FIRST_DATA + 511] = 8'h7e;
            2: card.image[DIRECTORY] = 8'h58;
            3: card.image[DIRECTORY + 28] = 8'hff;
        endcase
        wait (dut.verified || dut.mismatch);
        @(negedge clk);
        if (FAILURE != 0) begin
            if (dut.verified || !dut.mismatch || leds !== 4'b0000)
                $fatal(1, "Failure %0d incorrectly reported success", FAILURE);
            repeat (80) @(negedge clk);
            if (dut.verified || leds !== 4'b0000)
                $fatal(1, "Failure %0d entered LED chase", FAILURE);
        end else begin
            if (!dut.verified || dut.mismatch || dut.byte_count != 1024
                || dut.file_size != 1024 || leds !== 4'b1110)
                $fatal(1, "Success did not verify complete file: FAT32=%0d", FAT32);
            reads_at_success = read_commands;
            expected_leds = 4'b1110;
            for (step = 0; step < 8; step = step + 1) begin
                repeat (8) @(negedge clk);
                expected_leds = {expected_leds[2:0], expected_leds[3]};
                if (leds !== expected_leds)
                    $fatal(1, "LED sequence incorrect: got=%b want=%b", leds, expected_leds);
            end
            if (read_commands != reads_at_success)
                $fatal(1, "Reader continued after file completion");
            key2 = 0;
            repeat (4) @(negedge clk);
            if (dut.verified || dut.byte_count != 0 || leds !== 4'b1111)
                $fatal(1, "KEY2 did not clear verified/LED state");
            key2 = 1;
            wait (dut.verified || dut.mismatch);
            if (!dut.verified || dut.mismatch)
                $fatal(1, "KEY2 retry failed");
        end
        $display("PASS: BIN/LED FAT32=%0d failure=%0d", FAT32, FAILURE);
        passed = 1;
    end
endmodule

module tb_sd_bin_led_test;
    reg passed = 0;
    wire p16, p32, pdata, pmissing, psize, pcrc;
    sd_bin_led_case good16(.passed(p16));
    sd_bin_led_case #(.FAT32(1)) good32(.passed(p32));
    sd_bin_led_case #(.FAILURE(1)) bad_data(.passed(pdata));
    sd_bin_led_case #(.FAILURE(2)) missing(.passed(pmissing));
    sd_bin_led_case #(.FAILURE(3)) wrong_size(.passed(psize));
    sd_bin_led_case #(.FAILURE(4)) bad_crc(.passed(pcrc));
    initial begin
        wait (p16 && p32 && pdata && pmissing && psize && pcrc);
        passed = 1;
        $finish;
    end
    initial begin
        #100_000_000;
        $fatal(1, "BIN/LED test timed out");
    end
endmodule
