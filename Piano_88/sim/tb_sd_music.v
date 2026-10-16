`timescale 1ns / 1ps
module GSR(input GSRI);
endmodule

module sd_music_case #(
    parameter IMAGE_FILE = "../output/sd_music_test/fat16.hex",
    parameter integer PROFILE = 0,
    parameter integer EXPECT_FAT_ERROR = 0,
    parameter integer TEST_CONTROLS = 0
) (output reg passed = 0);
    reg clk = 0;
    reg key0 = 1, key1 = 1, key2 = 0;
    reg [3:0] fault = 0;
    wire cs_n, sck, mosi, miso, bck, ws, din, amp;
    wire [3:0] leds;
    sd_music_player #(
        .DEBOUNCE_CYCLES(8), .POWER_ON_CYCLES(8),
        .SD_POWER_WAIT_CYCLES(16), .SD_INIT_HALF_DIV(3),
        .FIFO_ADDRESS_BITS(7), .PREFILL_SAMPLES(64), .AMP_START_CYCLES(64)
    ) dut (
        .sys_clk(clk), .KEY0(key0), .KEY1(key1), .KEY2(key2),
        .sd_cs_n(cs_n), .sd_sck(sck), .sd_mosi(mosi), .sd_miso(miso),
        .HP_BCK(bck), .HP_WS(ws), .HP_DIN(din), .PA_EN(amp), .LEDs(leds)
    );
    sd_card_model #(.IMAGE_FILE(IMAGE_FILE), .IMAGE_BYTES(600000)) card (
        .rst_n(dut.stream_rst_n), .cs_n(cs_n), .sck(sck), .mosi(mosi), .miso(miso),
        .profile(PROFILE[1:0]), .fault(fault),
        .last_argument(), .read_commands(), .cmd16_seen()
    );
    always #10 clk = ~clk;
    reg [15:0] expected [0:1024];
    reg [31:0] frame;
    integer bit_number, received = 0;
    reg started = 0, pause_window = 0, monitor = 1;
    initial begin
        $readmemh("../output/sd_music_test/expected.hex", expected);
        forever begin
            @(posedge dut.sample_tick);
            frame = 0;
            for (bit_number = 0; bit_number < 32; bit_number = bit_number + 1) begin
                @(posedge bck);
                if (ws !== (bit_number >= 16))
                    $fatal(1, "Music WS/channel mismatch");
                frame = {frame[30:0], din};
            end
            if (monitor && EXPECT_FAT_ERROR == 0) begin
                if (!started && frame != 0)
                    started = 1;
                if (started && received < 1025) begin
                    if (!(pause_window && frame == 0)) begin
                        if (frame !== {expected[received], expected[received]})
                            $fatal(1, "Music profile=%0d sample=%0d got=%h expected=%h",
                                   PROFILE, received, frame, expected[received]);
                        received = received + 1;
                    end
                end else if (started && frame != 0)
                    $fatal(1, "Music output was not silent after EOF");
            end
        end
    end

    task press_pause;
        begin
            @(negedge clk); key0 = 0;
            repeat (32) @(negedge clk);
            key0 = 1;
            repeat (32) @(negedge clk);
        end
    endtask
    task press_replay;
        begin
            @(negedge clk); key1 = 0;
            repeat (32) @(negedge clk);
            key1 = 1;
            repeat (32) @(negedge clk);
        end
    endtask
    reg [6:0] saved_read_ptr;
    initial begin
        repeat (8) @(negedge clk);
        key2 = 1;
        if (EXPECT_FAT_ERROR != 0) begin
            monitor = 0;
            wait (dut.fat_error != 0);
            repeat (3) @(negedge clk);
            if (dut.fat_error != EXPECT_FAT_ERROR || leds[3] !== 0)
                $fatal(1, "Wrong FAT failure");
            repeat (4) @(posedge dut.sample_tick);
            if (dut.pcm !== 0)
                $fatal(1, "FAT error did not silence the audio");
            $display("PASS: filesystem error %0d reported and silenced", EXPECT_FAT_ERROR);
        end else begin
            if (TEST_CONTROLS) begin
                wait (received == 100);
                pause_window = 1;
                press_pause();
                if (!dut.paused)
                    $fatal(1, "Music pause button failed");
                saved_read_ptr = dut.read_ptr;
                repeat (5) @(posedge dut.sample_tick);
                @(negedge clk);
                if (dut.read_ptr != saved_read_ptr || dut.pcm !== 0)
                    $fatal(1, "Paused music advanced or was not silent");
                press_pause();
                if (dut.paused)
                    $fatal(1, "Music resume button failed");
                repeat (3) @(posedge dut.sample_tick);
                @(negedge clk); pause_window = 0;
            end
            wait (received == 1025);
            wait (dut.finished);
            repeat (4) @(posedge dut.sample_tick);
            if (leds[3] !== 1 || !dut.file_found || !dut.audio_end || dut.pcm !== 0 || amp !== 0)
                $fatal(1, "EOF status/error incorrect");
            $display("PASS: fragmented profile %0d, RIFF chunks, 1025 exact stereo PCM frames and EOF", PROFILE);
            if (TEST_CONTROLS) begin
                @(negedge clk);
                received = 0;
                started = 0;
                press_replay();
                wait (received == 1025);
                wait (dut.finished);
                repeat (4) @(posedge dut.sample_tick);
                if (leds[3] !== 1)
                    $fatal(1, "Replay reported an error");
                $display("PASS: KEY0 pause/resume and KEY1 full replay");
                monitor = 0;
                fault = 1;
                press_replay();
                wait (!leds[3]);
                repeat (4) @(posedge dut.sample_tick);
                if (dut.file_found || dut.pcm !== 0 || dut.sd_error_code != 10)
                    $fatal(1, "Bad-CRC sector leaked into file/audio pipeline");
                $display("PASS: bad-CRC filesystem sector rejected before audio");
            end
        end
        passed = 1;
    end
endmodule

module tb_sd_music;
    reg passed = 0;
    wire p16, p32, pmissing, pbroken;
    sd_music_case #(.TEST_CONTROLS(1)) fat16_case (.passed(p16));
    sd_music_case #(
        .IMAGE_FILE("../output/sd_music_test/fat32.hex"), .PROFILE(2)
    ) fat32_case (.passed(p32));
    sd_music_case #(
        .IMAGE_FILE("../output/sd_music_test/missing.hex"), .EXPECT_FAT_ERROR(4)
    ) missing_case (.passed(pmissing));
    sd_music_case #(
        .IMAGE_FILE("../output/sd_music_test/broken.hex"), .EXPECT_FAT_ERROR(5)
    ) broken_case (.passed(pbroken));
    initial begin
        wait (p16 && p32 && pmissing && pbroken);
        passed = 1;
        $finish;
    end
    initial begin
        #300_000_000;
        $fatal(1, "SD music end-to-end simulation timeout");
    end
endmodule
