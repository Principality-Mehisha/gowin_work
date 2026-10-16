// Read sector zero once after initialization. KEY2 retries via reset.
module sd_card_probe (
    input  wire sys_clk,
    input  wire KEY2,
    output wire sd_cs_n,
    output wire sd_sck,
    output wire sd_mosi,
    input  wire sd_miso,
    output wire [3:0] LEDs
);
    GSR GSR_INST (.GSRI(1'b1));
    reg [16:0] power_count = 0;
    always @(posedge sys_clk) begin
        if (!power_count[16])
            power_count <= power_count + 1'b1;
    end
    wire reset_request_n = KEY2 && power_count[16];
    reg [1:0] reset_sync;
    always @(posedge sys_clk or negedge reset_request_n) begin
        if (!reset_request_n)
            reset_sync <= 0;
        else
            reset_sync <= {reset_sync[0], 1'b1};
    end
    wire rst_n = reset_sync[1];
    wire initialized, high_capacity, read_ready, read_done;
    wire [3:0] error_code;
    reg requested, read_start, complete;

    sd_spi_reader u_reader (
        .clk(sys_clk), .rst_n(rst_n),
        .read_start(read_start), .read_lba(32'd0),
        .read_ready(read_ready), .busy(),
        .initialized(initialized), .high_capacity(high_capacity),
        .data(), .data_index(),
        .data_valid(), .data_ready(1'b1),
        .read_done(read_done), .error_pulse(), .error_code(error_code),
        .sd_cs_n(sd_cs_n), .sd_sck(sd_sck),
        .sd_mosi(sd_mosi), .sd_miso(sd_miso)
    );

    always @(posedge sys_clk or negedge rst_n) begin
        if (!rst_n) begin
            requested <= 0;
            read_start <= 0;
            complete <= 0;
        end else begin
            read_start <= 0;
            if (read_ready && !requested) begin
                requested <= 1;
                read_start <= 1;
            end
            if (read_done)
                complete <= 1;
        end
    end
    // Only the first four Dock LED pins are available with default CPU options.
    assign LEDs = ~{(error_code != 0), complete, high_capacity, initialized};
endmodule
