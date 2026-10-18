`timescale 1ns / 1ps
module tb_sd_piano_bank;
    reg clk = 0;
    reg rst_n = 0;
    reg [17:0] desired_base = 0;
    wire ready, loading, initialized, found, error;
    wire [17:0] loaded_base;
    wire we;
    wire [13:0] addr;
    wire [7:0] data;
    wire cs_n, sck, mosi, miso;
    wire [3:0] error_code;
    wire [23:0] debug_boot_bytes;
    reg passed = 0;

    sd_piano_bank_reader #(
        .SD_POWER_WAIT_CYCLES(16),
        .SD_READ_HALF_DIV(2),
        .BANK_BYTES(1024),
        .FILE_NAME("MUSIC   WAV")
    ) dut (
        .clk(clk), .rst_n(rst_n), .desired_base(desired_base),
        .bank_ready(ready), .loaded_base(loaded_base),
        .bank_write_en(we), .bank_write_addr(addr), .bank_write_data(data),
        .loading(loading), .sd_initialized(initialized), .file_found(found),
        .error(error), .error_code(error_code),
        .debug_boot_bytes(debug_boot_bytes),
        .debug_failure(),
        .sd_cs_n(cs_n), .sd_sck(sck), .sd_mosi(mosi),
        .sd_miso(miso)
    );
    sd_card_model #(
        .IMAGE_FILE("../output/sd_music_test/fat16.hex"),
        .IMAGE_BYTES(600000)
    ) card (
        .rst_n(dut.stream_rst_n), .cs_n(cs_n), .sck(sck), .mosi(mosi),
        .miso(miso), .profile(2'd0), .fault(4'd0),
        .last_argument(), .read_commands(), .cmd16_seen()
    );
    always #10 clk = ~clk;
    always @(posedge clk)
        if (rst_n && error)
            $fatal(1, "SD bank load failed with error %0d", error_code);

    initial begin
        repeat (8) @(negedge clk);
        rst_n = 1;
        wait (ready);
        if (!initialized || !found || error || loaded_base != 0)
            $fatal(1, "first bank load status invalid");
        if (debug_boot_bytes !== 24'hebaa55)
            $fatal(1, "Raw boot capture differs: %h", debug_boot_bytes);
        desired_base = 1024;
        wait (!ready);
        wait (ready);
        if (error || loaded_base != 1024)
            $fatal(1, "second bank load status invalid");
        $display("PASS: SD file stream, skip, cache fill and bank reload");
        passed = 1;
        $finish;
    end
    initial begin
        #300_000_000;
        $fatal(1, "SD piano bank simulation timeout");
    end
endmodule
