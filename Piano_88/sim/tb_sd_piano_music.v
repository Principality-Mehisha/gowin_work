`timescale 1ns / 1ps
module tb_sd_piano_music;
    reg passed = 0;
    wire p16, p32, pmissing, pbroken, pslow;
    sd_music_case #(
        .RAW_PCM(1), .FILE_NAME("PIANO   BIN"), .TEST_CONTROLS(1),
        .IMAGE_FILE("../output/piano_music_test/fat16.hex"),
        .EXPECTED_FILE("../output/piano_music_test/expected.hex")
    ) fat16_case (.passed(p16));
    sd_music_case #(
        .RAW_PCM(1), .FILE_NAME("PIANO   BIN"), .PROFILE(2),
        .IMAGE_FILE("../output/piano_music_test/fat32.hex"),
        .EXPECTED_FILE("../output/piano_music_test/expected.hex")
    ) fat32_case (.passed(p32));
    sd_music_case #(
        .RAW_PCM(1), .FILE_NAME("PIANO   BIN"), .EXPECT_FAT_ERROR(4),
        .IMAGE_FILE("../output/piano_music_test/missing.hex"),
        .EXPECTED_FILE("../output/piano_music_test/expected.hex")
    ) missing_case (.passed(pmissing));
    sd_music_case #(
        .RAW_PCM(1), .FILE_NAME("PIANO   BIN"), .EXPECT_FAT_ERROR(5),
        .IMAGE_FILE("../output/piano_music_test/broken.hex"),
        .EXPECTED_FILE("../output/piano_music_test/expected.hex")
    ) broken_case (.passed(pbroken));
    sd_music_case #(
        .RAW_PCM(1), .FILE_NAME("PIANO   BIN"), .PROFILE(2),
        .SD_READ_HALF_DIV(63), .THROUGHPUT(1), .FRAMES(4097),
        .IMAGE_FILE("../output/piano_music_test/throughput.hex")
    ) slow_case (.passed(pslow));
    initial begin
        wait (p16 && p32 && pmissing && pbroken && pslow);
        passed = 1;
        $finish;
    end
    initial begin
        #2_000_000_000;
        $fatal(1, "BIN player end-to-end timeout");
    end
endmodule
