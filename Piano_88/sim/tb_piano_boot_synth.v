`timescale 1ns / 1ps
// Feed the real card's boot bytes through the entire generated FPGA netlist.
module tb_piano_boot_synth;
    reg clk = 0, key2 = 0;
    wire cs_n, sck, mosi, miso;
    wire [3:0] leds;
    wire [31:0] reads, argument;
    reg passed = 0;
    piano_88 dut (
        .sys_clk(clk), .KEY0(1'b1), .KEY1(1'b1), .KEY2(key2),
        .HP_BCK(), .HP_WS(), .HP_DIN(), .PA_EN(),
        .sd_cs_n(cs_n), .sd_sck(sck), .sd_mosi(mosi),
        .sd_miso(miso), .LEDs(leds)
    );
    sd_card_model #(
        .IMAGE_FILE("../output/sd_music_test/card_readback/boot.hex"),
        .IMAGE_BYTES(4220000)
    ) card (
        .rst_n(key2), .cs_n(cs_n), .sck(sck), .mosi(mosi), .miso(miso),
        .profile(2'd0), .fault(4'd0),
        .last_argument(argument), .read_commands(reads), .cmd16_seen()
    );
    always #10 clk = ~clk;
    initial begin
        repeat (8) @(negedge clk);
        key2 = 1;
        wait (reads == 1);
        if (argument !== 32'h4000)
            $fatal(1, "Generated FPGA sent unexpected boot address %h", argument);
        wait (reads == 2 || !leds[3]);
        if (reads != 2)
            $fatal(1, "Generated FPGA rejected real boot, LEDs=%b", leds);
        if (argument !== 32'd4210688)
            $fatal(1, "Unexpected root-directory address %h", argument);
        $display("PASS: full synthesized FPGA, real LBA32 boot, SPI CRC and FAT geometry");
        passed = 1;
        $finish;
    end
    initial begin
        #60_000_000;
        $fatal(1, "Generated FPGA boot timeout, reads=%0d LEDs=%b", reads, leds);
    end
endmodule
