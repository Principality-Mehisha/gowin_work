`timescale 1ns / 1ps
module GSR(input GSRI);
endmodule

module tb_sd_card_probe;
    reg passed = 0;
    reg clk = 0;
    reg key2 = 0;
    reg [1:0] profile = 0;
    wire cs_n, sck, mosi, miso;
    wire [3:0] leds;
    wire [31:0] read_commands;
    sd_card_probe dut (
        .sys_clk(clk), .KEY2(key2), .sd_cs_n(cs_n), .sd_sck(sck),
        .sd_mosi(mosi), .sd_miso(miso), .LEDs(leds)
    );
    sd_card_model card (
        .rst_n(dut.rst_n), .cs_n(cs_n), .sck(sck),
        .mosi(mosi), .miso(miso), .profile(profile), .fault(4'd0),
        .last_argument(), .read_commands(read_commands), .cmd16_seen()
    );
    always #10 clk = ~clk;
    time rising_at;
    always @(posedge sck)
        rising_at = $time;
    always @(negedge sck) begin
        if (dut.rst_n && !cs_n
            && $time - rising_at != (dut.u_reader.initialized ? 40 : 1260))
            $fatal(1, "Probe default SPI timing is incorrect");
    end
    initial begin
        repeat (8) @(negedge clk);
        key2 = 1;
        wait (!leds[2] || !leds[3]);
        repeat (4) @(negedge clk);
        if (leds !== 4'b1010 || read_commands != 1)
            $fatal(1, "Probe SDSC status is incorrect: %b", leds);
        repeat (5000) @(negedge clk);
        if (read_commands != 1)
            $fatal(1, "Probe should only read sector zero once");
        key2 = 0;
        repeat (8) @(negedge clk);
        if (leds !== 4'b1111 || !cs_n || sck)
            $fatal(1, "Probe reset did not clear status");
        profile = 2;
        key2 = 1;
        wait (!leds[2] || !leds[3]);
        repeat (4) @(negedge clk);
        if (leds !== 4'b1000 || read_commands != 1)
            $fatal(1, "Probe SDHC status is incorrect: %b", leds);
        $display("PASS: board probe at default clocks, POR, LEDs, sector-zero CRC and KEY2 reset");
        passed = 1;
        $finish;
    end
    initial begin
        #100_000_000;
        $fatal(1, "Board probe simulation timeout");
    end
endmodule
