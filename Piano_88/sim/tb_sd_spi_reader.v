`timescale 1ns / 1ps
module tb_sd_spi_reader;
    reg passed = 0;
    reg clk = 0;
    reg rst_n = 0;
    reg read_start = 0;
    reg [31:0] read_lba = 0;
    reg [1:0] profile = 0;
    reg [3:0] fault = 0;
    reg stall = 0;
    reg [7:0] throttle = 0;
    wire data_ready = !stall && throttle[2:0] != 0;
    wire ready, busy, initialized, high_capacity;
    wire [7:0] data;
    wire [8:0] data_index;
    wire data_valid, done, error_pulse;
    wire [3:0] error_code;
    wire cs_n, sck, mosi, miso;
    wire [31:0] last_argument, read_commands;
    wire cmd16_seen;
    sd_spi_reader #(
        .POWER_WAIT_CYCLES(16), .INIT_HALF_DIV(3), .READ_HALF_DIV(2),
        .INIT_TIMEOUT_CYCLES(100000), .READ_TIMEOUT_CYCLES(1000),
        .RESPONSE_BYTES(16), .BUSY_BYTES(8)
    ) dut (
        .clk(clk), .rst_n(rst_n), .read_start(read_start), .read_lba(read_lba),
        .read_ready(ready), .busy(busy), .initialized(initialized),
        .high_capacity(high_capacity),
        .data(data), .data_index(data_index), .data_valid(data_valid),
        .data_ready(data_ready), .read_done(done),
        .error_pulse(error_pulse), .error_code(error_code),
        .sd_cs_n(cs_n), .sd_sck(sck), .sd_mosi(mosi), .sd_miso(miso)
    );
    sd_card_model card (
        .rst_n(rst_n), .cs_n(cs_n), .sck(sck), .mosi(mosi), .miso(miso),
        .profile(profile), .fault(fault),
        .last_argument(last_argument), .read_commands(read_commands),
        .cmd16_seen(cmd16_seen)
    );
    always #10 clk = ~clk;
    always @(negedge clk)
        throttle <= throttle + 1'b1;

    integer received = 0;
    reg capture = 0;
    reg [31:0] expected_lba;
    reg held = 0;
    reg [7:0] held_data;
    reg [8:0] held_index;
    reg last_done = 0, last_error = 0;
    time rising_at;
    function [7:0] expected_payload;
        input integer offset;
        input [31:0] lba;
        begin
            expected_payload = (offset * 37) ^ (lba * 13) ^ (offset >> 1);
        end
    endfunction
    always @(posedge sck)
        rising_at = $time;
    always @(negedge sck) begin
        if (rst_n && !cs_n && !dut.abort_transfer) begin
            if ($time - rising_at != (dut.fast_clock ? 40 : 60))
                $fatal(1, "Incorrect SPI clock high width");
        end
    end
    always @(negedge cs_n) begin
        if (rst_n && sck !== 0)
            $fatal(1, "CS asserted while SCK high");
    end
    always @(mosi) begin
        if (rst_n && !cs_n && sck === 1)
            $fatal(1, "MOSI changed while SCK high");
    end
    always @(posedge clk) begin
        if (!rst_n) begin
            held = 0;
            last_done = 0;
            last_error = 0;
        end else begin
            if (held && (!data_valid || data !== held_data || data_index !== held_index))
                $fatal(1, "Data/index did not hold under backpressure");
            held = data_valid && !data_ready;
            held_data = data;
            held_index = data_index;
            if (held && sck !== 0)
                $fatal(1, "SCK must stop low under backpressure");
            if (done && (last_done || error_pulse))
                $fatal(1, "Invalid read_done pulse");
            if (error_pulse && last_error)
                $fatal(1, "error_pulse must last one cycle");
            last_done = done;
            last_error = error_pulse;
            if (capture && data_valid && data_ready) begin
                if (data_index !== received || data !== expected_payload(received, expected_lba))
                    $fatal(1, "Data mismatch index=%0d expected=%0d got=%h",
                           data_index, received, data);
                received = received + 1;
            end
        end
    end

    task reset_card;
        input [1:0] new_profile;
        input [3:0] new_fault;
        begin
            @(negedge clk);
            rst_n = 0;
            capture = 0;
            read_start = 0;
            stall = 0;
            profile = new_profile;
            fault = new_fault;
            repeat (4) @(negedge clk);
            rst_n = 1;
        end
    endtask

    task initialize;
        input [1:0] new_profile;
        begin
            reset_card(new_profile, 0);
            wait (ready || error_pulse);
            @(negedge clk);
            if (!ready || !initialized || error_code != 0
                || high_capacity !== (new_profile == 2)
                || cmd16_seen !== (new_profile != 2))
                $fatal(1, "Initialization failed for profile %0d code=%0d",
                       new_profile, error_code);
        end
    endtask

    task read_sector;
        input [31:0] lba;
        input [3:0] expected_error;
        input integer expected_bytes;
        begin
            @(negedge clk);
            if (!ready)
                $fatal(1, "Reader was not ready");
            expected_lba = lba;
            received = 0;
            capture = 1;
            stall = (expected_bytes == 512);
            read_lba = lba;
            read_start = 1;
            @(negedge clk);
            read_start = 0;
            if (stall) begin
                wait (data_valid || error_pulse);
                if (error_pulse)
                    $fatal(1, "Unexpected error before first byte %0d", error_code);
                repeat (50) @(negedge clk);
                if (data_index != 0 || received != 0)
                    $fatal(1, "Initial consumer stall lost data");
                stall = 0;
            end
            wait (done || error_pulse);
            @(negedge clk);
            if (error_code !== expected_error || received != expected_bytes
                || done !== (expected_error == 0))
                $fatal(1, "Read failed fault=%0d error=%0d expected=%0d bytes=%0d",
                       fault, error_code, expected_error, received);
            wait (ready);
            @(negedge clk);
            capture = 0;
        end
    endtask

    task init_error;
        input [3:0] new_fault;
        input [3:0] expected_error;
        begin
            reset_card(2, new_fault);
            wait (error_pulse);
            @(negedge clk);
            if (error_code !== expected_error || initialized)
                $fatal(1, "Wrong init error fault=%0d got=%0d expected=%0d",
                       new_fault, error_code, expected_error);
            wait (!busy);
            repeat (20) @(negedge clk);
            if (ready || !cs_n || sck || data_valid)
                $fatal(1, "Failed initialization did not stop safely");
        end
    endtask

    integer kind, f;
    reg [31:0] saved_commands;
    initial begin
        for (kind = 0; kind < 3; kind = kind + 1) begin
            initialize(kind);
            read_sector(0, 0, 512);
            read_sector(32'd2049, 0, 512);
            if (last_argument !== ((kind == 2) ? 32'd2049 : 32'd1049088))
                $fatal(1, "SDSC/SDHC address translation incorrect");
            $display("PASS: card profile %0d, CMD8/CMD16, retries, two sectors and backpressure", kind);
        end

        // Address conversion must never silently truncate.
        initialize(0);
        saved_commands = read_commands;
        read_sector(32'h00800000, 7, 0);
        if (read_commands != saved_commands)
            $fatal(1, "Out-of-range SDSC request reached the card");
        read_sector(3, 0, 512);
        initialize(2);
        read_sector(32'h81234567, 0, 512);
        if (last_argument !== 32'h81234567)
            $fatal(1, "High SDHC LBA bits were lost");

        // Read errors leave initialization valid and permit a clean retry.
        for (f = 1; f <= 5; f = f + 1) begin
            fault = f;
            case (f)
                1: read_sector(3, 10, 512);
                2: read_sector(3, 8, 0);
                3: read_sector(3, 9, 0);
                4: read_sector(3, 4, 0);
                5: read_sector(3, 3, 0);
            endcase
            fault = 0;
            read_sector(7, 0, 512);
        end
        $display("PASS: CRC, token timeout/error, R1, response timeout, overflow and recovery");

        init_error(6, 5);
        init_error(7, 6);
        init_error(8, 1);
        init_error(9, 2);
        init_error(10, 3);
        $display("PASS: bad CMD8/OCR, initialization timeout, stuck bus and absent card");

        // Reset aborts an incomplete sector; no stale valid/data_done survives.
        initialize(0);
        stall = 1;
        @(negedge clk);
        read_start = 1;
        read_lba = 1;
        @(negedge clk);
        read_start = 0;
        wait (data_valid);
        initialize(2);
        read_sector(4, 0, 512);
        $display("PASS: reset during stalled read, reinitialization and subsequent sector");
        passed = 1;
        $finish;
    end
    initial begin
        #30_000_000;
        $fatal(1, "SD reader simulation timeout error=%0d", error_code);
    end
endmodule
