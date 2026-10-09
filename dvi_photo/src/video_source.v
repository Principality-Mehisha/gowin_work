`timescale 1ns/1ps
module video_source (
    input wire pixel_clk,
    input wire reset_n,
    input wire test_pattern,
    output wire [7:0] red,
    output wire [7:0] green,
    output wire [7:0] blue,
    output reg hsync,
    output reg vsync,
    output reg de
);
    // 640x480: 16/96/48 horizontal and 10/2/33 vertical blanking.
    reg [9:0] x;
    reg [9:0] y;
    wire active = (x < 640) && (y < 480);
    wire photo_area = active && (x >= 112) && (x < 528);
    wire [9:0] photo_x = x - 10'd112;
    wire [15:0] row = {8'd0, y[8:1]};
    wire [15:0] address = (row << 7) + (row << 6) + (row << 4)
                        + {7'd0, photo_x[9:1]};
    wire [15:0] rom_pixel;
    photo_rom image_rom(.clk(pixel_clk), .address(address), .pixel(rom_pixel));

    reg photo_valid;
    reg pattern_valid;
    reg [23:0] bars;
    reg [23:0] bars_d;
    always @* begin
        if      (x < 80)  bars = 24'hffffff;
        else if (x < 160) bars = 24'hffff00;
        else if (x < 240) bars = 24'h00ffff;
        else if (x < 320) bars = 24'h00ff00;
        else if (x < 400) bars = 24'hff00ff;
        else if (x < 480) bars = 24'hff0000;
        else if (x < 560) bars = 24'h0000ff;
        else             bars = 24'h000000;
    end

    // Delay all sideband signals by exactly the ROM's one clock latency.
    always @(posedge pixel_clk or negedge reset_n) begin
        if (!reset_n) begin
            x <= 0;
            y <= 0;
            de <= 0;
            hsync <= 1;
            vsync <= 1;
            photo_valid <= 0;
            pattern_valid <= 0;
            bars_d <= 0;
        end else begin
            if (x == 799) begin
                x <= 0;
                y <= (y == 524) ? 10'd0 : y + 10'd1;
            end else
                x <= x + 10'd1;
            de <= active;
            hsync <= !((x >= 656) && (x < 752));
            vsync <= !((y >= 490) && (y < 492));
            photo_valid <= photo_area;
            pattern_valid <= test_pattern;
            bars_d <= bars;
        end
    end

    wire [23:0] photo_rgb = {
        rom_pixel[15:11], rom_pixel[15:13],
        rom_pixel[10:5], rom_pixel[10:9],
        rom_pixel[4:0], rom_pixel[4:2]
    };
    wire [23:0] rgb = !de ? 24'h000000 :
                       pattern_valid ? bars_d :
                       photo_valid ? photo_rgb : 24'h000000;
    assign {red, green, blue} = rgb;
endmodule
