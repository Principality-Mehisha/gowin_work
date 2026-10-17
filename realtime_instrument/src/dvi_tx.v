`timescale 1ns/1ps
module dvi_tx (
    input wire pixel_clk,
    input wire serial_clk,
    input wire reset_n,
    input wire [7:0] red,
    input wire [7:0] green,
    input wire [7:0] blue,
    input wire hsync,
    input wire vsync,
    input wire de,
    output wire [2:0] tmds_data_p,
    output wire [2:0] tmds_data_n,
    output wire tmds_clk_p,
    output wire tmds_clk_n
);
    wire [9:0] symbols [0:3];
    wire [3:0] serial_data;
    tmds_encoder enc_blue(.pixel_clk(pixel_clk), .reset_n(reset_n),
        .data(blue), .de(de), .c0(hsync), .c1(vsync), .symbol(symbols[0]));
    tmds_encoder enc_green(.pixel_clk(pixel_clk), .reset_n(reset_n),
        .data(green), .de(de), .c0(1'b0), .c1(1'b0), .symbol(symbols[1]));
    tmds_encoder enc_red(.pixel_clk(pixel_clk), .reset_n(reset_n),
        .data(red), .de(de), .c0(1'b0), .c1(1'b0), .symbol(symbols[2]));
    // Send the clock through the same serializer path as all data channels.
    assign symbols[3] = 10'b1111100000;
    genvar channel;
    generate
        for (channel = 0; channel < 4; channel = channel + 1) begin: serializers
            OSER10 serializer(
                .Q(serial_data[channel]),
                .D0(symbols[channel][0]), .D1(symbols[channel][1]),
                .D2(symbols[channel][2]), .D3(symbols[channel][3]),
                .D4(symbols[channel][4]), .D5(symbols[channel][5]),
                .D6(symbols[channel][6]), .D7(symbols[channel][7]),
                .D8(symbols[channel][8]), .D9(symbols[channel][9]),
                .PCLK(pixel_clk), .FCLK(serial_clk), .RESET(!reset_n));
        end
        for (channel = 0; channel < 3; channel = channel + 1) begin: buffers
            TLVDS_OBUF buffer(.I(serial_data[channel]),
                .O(tmds_data_p[channel]), .OB(tmds_data_n[channel]));
        end
    endgenerate
    TLVDS_OBUF clock_buffer(.I(serial_data[3]), .O(tmds_clk_p), .OB(tmds_clk_n));
endmodule
