`timescale 1ns/1ps

// 640x480 status view: four voice bars and a microphone activity bar.
module instrument_video_source (
    input  wire       pixel_clk,
    input  wire       reset_n,
    input  wire [3:0] active_mask,
    input  wire       mic_activity,
    input  wire [1:0] timbre_select,
    output reg  [7:0] red,
    output reg  [7:0] green,
    output reg  [7:0] blue,
    output reg        hsync,
    output reg        vsync,
    output reg        de
);
    reg [9:0] x;
    reg [9:0] y;
    reg [3:0] active_d;
    reg mic_d;
    reg [1:0] timbre_d;
    wire active = (x < 640) && (y < 480);
    integer bar;
    reg [23:0] rgb;

    always @* begin
        rgb = 24'h07111f;
        if (active && y >= 80 && y < 360) begin
            for (bar = 0; bar < 4; bar = bar + 1)
                if ((x >= (80 + bar * 120)) && (x < (150 + bar * 120)) &&
                    (y >= (360 - (active_d[bar] ? 220 : 24))) && (y < 360))
                    rgb = (bar[0]) ? 24'h27b6a6 : 24'hffb347;
        end
        if (active && x >= 580 && x < 620 && y >= 80 && y < 360 &&
            y >= (360 - (mic_d ? 220 : 10)))
            rgb = 24'he86a92;
        if (active && x < (160 + {8'd0, timbre_d} * 80) && y >= 400 && y < 425)
            rgb = 24'h8bc6ff;
        if (!active) rgb = 24'h000000;
        {red, green, blue} = rgb;
    end

    always @(posedge pixel_clk or negedge reset_n) begin
        if (!reset_n) begin
            x <= 0; y <= 0; hsync <= 1; vsync <= 1; de <= 0;
            active_d <= 0; mic_d <= 0; timbre_d <= 0;
        end else begin
            if (x == 799) begin x <= 0; y <= (y == 524) ? 0 : y + 1; end
            else x <= x + 1;
            de <= active;
            hsync <= !((x >= 656) && (x < 752));
            vsync <= !((y >= 490) && (y < 492));
            active_d <= active_mask;
            mic_d <= mic_activity;
            timbre_d <= timbre_select;
        end
    end
endmodule
