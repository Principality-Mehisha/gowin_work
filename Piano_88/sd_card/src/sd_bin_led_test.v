// Read SDTEST.BIN from the card root, verify 00..FF repeating, then run LEDs.
module sd_bin_led_test #(
    parameter integer POWER_ON_CYCLES = 65_536,
    parameter integer SD_POWER_WAIT_CYCLES = 500_000,
    parameter integer SD_HALF_DIV = 63,
    parameter integer LED_STEP_CYCLES = 5_000_000
) (
    input wire sys_clk,
    input wire KEY2,
    output wire sd_cs_n,
    output wire sd_sck,
    output wire sd_mosi,
    input wire sd_miso,
    output wire [3:0] LEDs
);
    GSR GSR_INST (.GSRI(1'b1));

    reg [31:0] power_count = 0;
    always @(posedge sys_clk) begin
        if (power_count < POWER_ON_CYCLES)
            power_count <= power_count + 1'b1;
    end

    wire reset_request_n = KEY2 && (power_count == POWER_ON_CYCLES);
    reg [1:0] reset_sync;
    always @(posedge sys_clk or negedge reset_request_n) begin
        if (!reset_request_n)
            reset_sync <= 0;
        else
            reset_sync <= {reset_sync[0], 1'b1};
    end
    wire rst_n = reset_sync[1];

    wire sd_ready, sd_start, sd_done, sd_error;
    wire sd_initialized;
    wire [31:0] sd_lba;
    wire [7:0] sd_data;
    wire [8:0] sd_index;
    wire sd_valid;
    wire [3:0] sd_error_code;

    sd_spi_reader #(
        .POWER_WAIT_CYCLES(SD_POWER_WAIT_CYCLES),
        .INIT_HALF_DIV(SD_HALF_DIV),
        .READ_HALF_DIV(SD_HALF_DIV)
    ) u_sd (
        .clk(sys_clk), .rst_n(rst_n),
        .read_start(sd_start), .read_lba(sd_lba),
        .read_ready(sd_ready), .busy(),
        .initialized(sd_initialized), .high_capacity(),
        .data(sd_data), .data_index(sd_index),
        .data_valid(sd_valid), .data_ready(1'b1),
        .read_done(sd_done), .error_pulse(sd_error),
        .error_code(sd_error_code), .debug_failure(),
        .sd_cs_n(sd_cs_n), .sd_sck(sd_sck),
        .sd_mosi(sd_mosi), .sd_miso(sd_miso)
    );

    wire [7:0] file_data;
    wire file_valid, file_done;
    wire [31:0] file_size;
    wire file_found;
    wire [3:0] fat_error;

    fat_file_reader #(
        .FILE_NAME("SDTEST  BIN"),
        .VOLUME_START_LBA(0)
    ) u_file (
        .clk(sys_clk), .rst_n(rst_n),
        .sd_ready(sd_ready), .sd_start(sd_start),
        .sd_lba(sd_lba), .sd_data(sd_data),
        .sd_index(sd_index), .sd_valid(sd_valid),
        .sd_done(sd_done), .sd_error(sd_error),
        .data(file_data), .valid(file_valid),
        .ready(1'b1), .mounted(), .file_found(file_found),
        .file_size(file_size), .file_done(file_done),
        .error_code(fat_error)
    );

    reg [31:0] byte_count;
    reg mismatch;
    reg verified;
    reg [22:0] led_count;
    reg [3:0] led_pattern;

    always @(posedge sys_clk or negedge rst_n) begin
        if (!rst_n) begin
            byte_count <= 0;
            mismatch <= 0;
            verified <= 0;
            led_count <= 0;
            led_pattern <= 4'b0001;
        end else begin
            if (file_valid) begin
                if (file_data != byte_count[7:0])
                    mismatch <= 1;
                byte_count <= byte_count + 1'b1;
            end
            if (sd_error || sd_error_code != 0 || fat_error != 0)
                mismatch <= 1;
            if (file_done) begin
                if (!mismatch && byte_count == 1024 && file_size == 1024)
                    verified <= 1;
                else
                    mismatch <= 1;
            end
            if (verified) begin
                if (led_count == LED_STEP_CYCLES - 1) begin
                    led_count <= 0;
                    led_pattern <= {led_pattern[2:0], led_pattern[3]};
                end else
                    led_count <= led_count + 1'b1;
            end
        end
    end

    // LEDs are active-low on the board. Error is all four on.
    assign LEDs = mismatch ? 4'b0000
                 : verified ? ~led_pattern
                 : ~{1'b0, file_found, sd_initialized, 1'b0};
endmodule
