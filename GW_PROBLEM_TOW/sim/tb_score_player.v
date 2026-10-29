`timescale 1ns / 1ps
module GSR(input GSRI);
endmodule
module score_player_case #(
    parameter IMAGE_FILE = "../output/score_test/fat16.hex",
    parameter integer PROFILE = 0,
    parameter integer CONTROLS = 0,
    parameter integer SD_ENABLE = 1,
    parameter integer EXPECT_ERROR = 0
) (output reg passed = 0);
    reg clk = 0, key2 = 1;
    reg [3:0] fault = 0;
    wire cs, sck, mosi, miso, bck, ws, din, amp;
    wire [3:0] leds;
    piano_score_player #(
        .SD_SCORE_ENABLE(SD_ENABLE),
        .POWER_ON_CYCLES(8), .AUDIO_START_CYCLES(64),
        .SD_POWER_WAIT_CYCLES(16), .SD_INIT_HALF_DIV(3), .SD_READ_HALF_DIV(63),
        .SINE_FILE("../src/rom/sine256.hex"),
        .FREQ_FILE("../src/rom/frequency88.hex"),
        .VOICING_FILE("../src/rom/voicing88.hex"),
        .MARIMBA_MODE_FILE("../src/rom/marimba48.hex"),
        .MARIMBA_ATTACK_FILE("../src/rom/marimba_attack48.hex")

    ) dut (
        .sys_clk(clk), .KEY2(key2),
        .uart_rx(1'b1), .uart_tx(),
        .HP_BCK(bck), .HP_WS(ws), .HP_DIN(din), .PA_EN(amp),
        .sd_cs_n(cs), .sd_sck(sck), .sd_mosi(mosi), .sd_miso(miso), .LEDs(leds)
    );
    sd_card_model #(.IMAGE_FILE(IMAGE_FILE), .IMAGE_BYTES(600000)) card (
        .rst_n(dut.system.play_rst_n), .cs_n(cs), .sck(sck), .mosi(mosi), .miso(miso),
        .profile(PROFILE[1:0]), .fault(fault), .last_argument(), .read_commands(), .cmd16_seen()
    );
    always #10 if (!passed) clk = ~clk;
    integer bit_number, nonzero = 0, first_ons = 0, repeated = 0;
    integer manual_on_count = 0;
    reg [31:0] frame;
    reg [31:0] expected;
    // A board reset may interrupt a DAC frame; resume at the next frame tick.
    always @(negedge dut.rst_n) disable capture_dac_frame;
    initial forever begin : capture_dac_frame
        @(posedge dut.sample_tick);
        expected = {dut.pcm_right, dut.pcm};
        frame = 0;
        for (bit_number = 0; bit_number < 32; bit_number = bit_number + 1) begin
            @(posedge bck);
            if (ws !== (bit_number >= 16)) $fatal(1, "Score DAC WS mismatch");
            frame = {frame[30:0], din};
        end
        if (frame !== expected) $fatal(1, "Score DAC stereo frame mismatch");
        if (frame != 0) nonzero = nonzero + 1;
    end
    always @(posedge clk) if (dut.triggers != 0) begin
        if (dut.elapsed_ms == 0) first_ons = first_ons + 1;
        if (dut.elapsed_ms == 50) repeated = repeated + 1;
    end
    always @(posedge clk) if (dut.system.manual_mode && dut.system.synth_event_valid &&
                              dut.system.synth_event_ready && dut.system.synth_event_on) begin
        manual_on_count = manual_on_count + 1;
    end
    task reset_key;
        begin
            @(negedge clk); key2 = 0;
            repeat (4) @(negedge clk); key2 = 1;
            wait (dut.rst_n);
            repeat (8) @(negedge clk);
        end
    endtask
    initial begin
        if (!SD_ENABLE) begin
            wait (dut.rst_n);
            repeat (20) @(posedge clk);
            if (!dut.system.manual_mode || dut.initialized || dut.file_found || cs !== 1'b1)
                $fatal(1, "Idle player did not remain isolated from the card");
            repeat (4) @(posedge dut.sample_tick);
            if (manual_on_count || dut.pcm != 0) $fatal(1,"Idle emitted a note");
            reset_key();
            if (!dut.system.manual_mode || dut.initialized || dut.system.ringtone_active || manual_on_count)
                $fatal(1,"KEY2 did not reset the idle player");
            $display("PASS: idle silence, SD isolation, KEY2 reset");
        end else if (EXPECT_ERROR) begin
            wait (dut.system.failed);
            repeat (4) @(posedge dut.sample_tick);
            if (leds[3] !== 0 || dut.pcm !== 0) $fatal(1, "Score failure not silent");
            if (EXPECT_ERROR == 1 && dut.fat_error != 4) $fatal(1, "Missing score not detected");
            if (EXPECT_ERROR == 2 && dut.score_error != 1) $fatal(1, "PCM/WAV accepted as a score");
            $display("PASS: score failure case %0d rejected and silent", EXPECT_ERROR);
        end else begin
            wait (dut.playing);
            wait (dut.finished);
            repeat (5) @(posedge dut.sample_tick);
            if (dut.system.failed || dut.gates != 0 || dut.pcm !== 0 || nonzero < 500 ||
                first_ons != 3 || repeated != 1 || amp !== 0 ||
                dut.system.deadline_error)
                $fatal(1, "Score chord/retrigger/EOF failure profile=%0d", PROFILE);
            if (CONTROLS) begin
                first_ons = 0; repeated = 0;
                reset_key();
                wait (dut.finished);
                if (dut.system.failed || first_ons != 3 || repeated != 1) $fatal(1, "Score replay failed");
                fault = 1;
                reset_key();
                wait (dut.system.failed);
                if (dut.sd_error_code != 10 || dut.file_found) $fatal(1, "Bad CRC leaked as score");
            end
            $display("PASS: SPI divider 63, FAT profile %0d, chord, repeated note, DAC audio, controls/EOF", PROFILE);
        end
        passed = 1;
    end
endmodule
module tb_score_player;
    reg passed = 0;
    wire p16, p32, pmissing, pformat;
    score_player_case #(.CONTROLS(1)) c16 (.passed(p16));
    score_player_case #(.IMAGE_FILE("../output/score_test/fat32.hex"), .PROFILE(2))
        c32 (.passed(p32));
    score_player_case #(.IMAGE_FILE("../output/score_test/missing.hex"), .EXPECT_ERROR(1))
        cmissing (.passed(pmissing));
    score_player_case #(.IMAGE_FILE("../output/score_test/wrong_format.hex"), .EXPECT_ERROR(2))
        cformat (.passed(pformat));
    wire pmanual;
    score_player_case #(.SD_ENABLE(0)) cmanual (.passed(pmanual));
    initial begin wait (p16 && p32 && pmissing && pformat && pmanual); passed = 1; $finish; end
    initial begin #600_000_000; $fatal(1, "Score player timeout"); end
endmodule
