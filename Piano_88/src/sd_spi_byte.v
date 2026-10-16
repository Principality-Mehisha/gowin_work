// SPI mode 0, MSB first. All logic uses clk; sck is only an output.
module sd_spi_byte (
    input  wire clk,
    input  wire rst_n,
    input  wire start,
    input  wire [15:0] half_div,
    input  wire [7:0] tx_data,
    output reg  [7:0] rx_data,
    output reg  busy,
    output reg  done,
    output reg  sck,
    output reg  mosi,
    input  wire miso
);
    reg [15:0] divider;
    reg [15:0] active_div;
    reg [2:0] bit_index;
    reg [7:0] tx_shift;
    reg [7:0] rx_shift;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            divider <= 0;
            active_div <= 1;
            bit_index <= 0;
            tx_shift <= 8'hff;
            rx_shift <= 0;
            rx_data <= 0;
            busy <= 0;
            done <= 0;
            sck <= 0;
            mosi <= 1;
        end else begin
            done <= 0;
            if (!busy) begin
                sck <= 0;
                mosi <= 1;
                if (start) begin
                    active_div <= (half_div == 0) ? 16'd1 : half_div;
                    divider <= 0;
                    bit_index <= 7;
                    tx_shift <= tx_data;
                    rx_shift <= 0;
                    mosi <= tx_data[7];
                    busy <= 1;
                end
            end else if (divider == active_div - 1'b1) begin
                divider <= 0;
                sck <= ~sck;
                if (!sck) begin
                    rx_shift <= {rx_shift[6:0], miso};
                end else if (bit_index == 0) begin
                    rx_data <= rx_shift;
                    busy <= 0;
                    done <= 1;
                    mosi <= 1;
                end else begin
                    bit_index <= bit_index - 1'b1;
                    tx_shift <= {tx_shift[6:0], 1'b1};
                    mosi <= tx_shift[6];
                end
            end else begin
                divider <= divider + 1'b1;
            end
        end
    end
endmodule
