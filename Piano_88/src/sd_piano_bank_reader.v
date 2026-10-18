// Load one 15360-byte mu-law sample zone from PIANO.BIN on the SD card.
// The file is read through the existing FAT stream. A zone change restarts
// the stream, skips the preceding zones, and fills the external sample RAM.
module sd_piano_bank_reader #(
    // Match the independently verified SD probe timing.
    parameter integer SD_POWER_WAIT_CYCLES = 500_000,
    parameter integer SD_READ_HALF_DIV = 63,
    parameter [31:0] VOLUME_START_LBA = 0,
    parameter integer BANK_BYTES = 15360,
    parameter [87:0] FILE_NAME = "PIANO   BIN"
) (
    input wire clk,
    input wire rst_n,
    input wire [17:0] desired_base,
    output reg bank_ready,
    output reg [17:0] loaded_base,
    output wire bank_write_en,
    output wire [13:0] bank_write_addr,
    output wire [7:0] bank_write_data,
    output wire loading,
    output wire sd_initialized,
    output wire file_found,
    output wire error,
    output wire [3:0] error_code,
    output reg [23:0] debug_boot_bytes,
    output wire [23:0] debug_failure,
    output wire sd_cs_n,
    output wire sd_sck,
    output wire sd_mosi,
    input wire sd_miso
);
    reg [17:0] target_base;
    reg [31:0] discard_remaining;
    reg [15:0] write_count;
    reg [2:0] restart_count;
    reg error_latched;

    wire stream_rst_n = rst_n && (restart_count == 0);
    wire sd_ready;
    wire sd_start;
    wire sd_done;
    wire sd_error_pulse;
    wire [31:0] sd_lba;
    wire [7:0] sd_data;
    wire [8:0] sd_index;
    wire sd_valid;
    wire [3:0] sd_error_code;

    sd_spi_reader #(
        .POWER_WAIT_CYCLES(SD_POWER_WAIT_CYCLES),
        .READ_HALF_DIV(SD_READ_HALF_DIV),
        // Keep command CRC checking disabled for broad SD SPI compatibility.
        // CMD0/CMD8 still use their mandatory fixed CRC values.
        .ENABLE_COMMAND_CRC(0)
    ) u_sd (
        .clk(clk), .rst_n(stream_rst_n),
        .read_start(sd_start), .read_lba(sd_lba), .read_ready(sd_ready),
        .busy(), .initialized(sd_initialized), .high_capacity(),
        .data(sd_data), .data_index(sd_index), .data_valid(sd_valid),
        .data_ready(1'b1), .read_done(sd_done),
        .error_pulse(sd_error_pulse), .error_code(sd_error_code),
        .debug_failure(debug_failure),
        .sd_cs_n(sd_cs_n), .sd_sck(sd_sck), .sd_mosi(sd_mosi),
        .sd_miso(sd_miso)
    );

    wire [7:0] file_data;
    wire file_valid;
    wire file_ready;
    wire file_done;
    wire [31:0] file_size;
    wire [3:0] fat_error;
    fat_file_reader #(
        .FILE_NAME(FILE_NAME), .VOLUME_START_LBA(VOLUME_START_LBA)
    ) u_file (
        .clk(clk), .rst_n(stream_rst_n), .sd_ready(sd_ready),
        .sd_start(sd_start), .sd_lba(sd_lba), .sd_data(sd_data),
        .sd_index(sd_index), .sd_valid(sd_valid), .sd_done(sd_done),
        .sd_error(sd_error_pulse), .data(file_data), .valid(file_valid),
        .ready(file_ready), .mounted(), .file_found(file_found),
        .file_size(file_size), .file_done(file_done),
        .error_code(fat_error)
    );

    assign loading = !bank_ready && !error_latched;
    assign error = error_latched;
    // Boot diagnostics occupy 11..15, above the native SD codes 1..10.
    assign error_code = sd_error_code != 0 ? sd_error_code
                      : fat_error == 10 ? 4'd11
                      : fat_error == 11 ? 4'd12
                      : fat_error == 12 ? 4'd13
                      : fat_error == 13 ? 4'd14
                      : fat_error == 14 ? 4'd15
                      : fat_error != 0 ? (4'h8 | fat_error)
                      : 4'd0;
    assign file_ready = stream_rst_n && !bank_ready && !error_latched;
    assign bank_write_en = file_valid && file_ready
                         && discard_remaining == 0
                         && write_count < BANK_BYTES;
    assign bank_write_addr = write_count[13:0];
    assign bank_write_data = file_data;

    // Retain the first boot read even if later reads fail.
    reg debug_captured;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            debug_boot_bytes <= 0;
            debug_captured <= 0;
        end else if (!debug_captured) begin
            if (sd_valid) begin
                case (sd_index)
                    0: debug_boot_bytes[23:16] <= sd_data;
                    510: debug_boot_bytes[7:0] <= sd_data;
                    511: debug_boot_bytes[15:8] <= sd_data;
                endcase
            end
            if (sd_done)
                debug_captured <= 1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            target_base <= 0;
            discard_remaining <= 0;
            write_count <= 0;
            restart_count <= 0;
            bank_ready <= 0;
            loaded_base <= 0;
            error_latched <= 0;
        end else begin
            if (restart_count != 0)
                restart_count <= restart_count - 1'b1;

            // FAT is a forward-only stream, so a new zone restarts the reader.
            if (desired_base != target_base) begin
                target_base <= desired_base;
                discard_remaining <= desired_base;
                write_count <= 0;
                restart_count <= 3'd4;
                bank_ready <= 0;
                error_latched <= 0;
            end else if (stream_rst_n && !bank_ready && !error_latched) begin
                if (sd_error_pulse || sd_error_code != 0 || fat_error != 0) begin
                    error_latched <= 1;
                end else if (file_done && write_count != BANK_BYTES) begin
                    error_latched <= 1;
                end else if (file_valid && file_ready) begin
                    if (discard_remaining != 0)
                        discard_remaining <= discard_remaining - 1'b1;
                    else if (write_count < BANK_BYTES) begin
                        if (write_count == BANK_BYTES - 1) begin
                            write_count <= BANK_BYTES;
                            bank_ready <= 1;
                            loaded_base <= target_base;
                        end else
                            write_count <= write_count + 1'b1;
                    end
                end
            end
        end
    end
endmodule
