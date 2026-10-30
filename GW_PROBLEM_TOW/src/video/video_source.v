`timescale 1ns/1ps
// VESA DMT 0x53: 1600x900 at 60 Hz, 108 MHz pixels, positive HS/VS.
module video_source (
    input wire pixel_clk, input wire reset_n, input wire test_pattern,
    input wire update, active,
    input wire [1:0] display_mode,
    input wire analysis_valid,
    input wire [31:0] analysis_data,
    output wire [8:0] analysis_address,
    input wire [31:0] elapsed_ms,
    input wire [87:0] lit_keys,
    output reg frame_tick,
    output wire [7:0] red, green, blue,
    output wire hsync, vsync, de
);
    reg [10:0] x;
    reg [9:0] y;
    reg [4:0] hs_pipe, vs_pipe, de_pipe;
    wire [23:0] rgb,analysis_rgb;
    piano_analysis_scene analysis_scene(.clk(pixel_clk),.reset_n(reset_n),.display_mode(display_mode),
        .x(x),.y(y),.visible_valid(analysis_valid),.read_data(analysis_data),
        .read_address(analysis_address),.rgb(analysis_rgb));
    piano_scene scene(.clk(pixel_clk), .reset_n(reset_n), .frame_tick(frame_tick),
        .x(x), .y(y), .test_pattern(test_pattern), .rgb(rgb),
        .update(update),.active(active),.elapsed_ms(elapsed_ms),.lit_keys(lit_keys));
    always @(posedge pixel_clk or negedge reset_n) begin
        if (!reset_n) begin
            x <= 0; y <= 0;
            hs_pipe <= 0; vs_pipe <= 0; de_pipe <= 0; frame_tick <= 0;
        end else begin
            frame_tick <= (x == 1799 && y == 899);
            if (x == 1799) begin
                x <= 0;
                y <= y == 999 ? 10'd0 : y + 1'b1;
            end else x <= x + 1'b1;
            hs_pipe <= {hs_pipe[3:0], (x >= 1624 && x < 1704)};
            vs_pipe <= {vs_pipe[3:0], (y >= 901 && y < 904)};
            de_pipe <= {de_pipe[3:0], (x < 1600 && y < 900)};
        end
    end
    assign hsync = hs_pipe[4];
    assign vsync = vs_pipe[4];
    assign de = de_pipe[4];
    reg [23:0] selected_rgb;
    always @*begin
        case(display_mode)
            1,2:selected_rgb=test_pattern ? rgb : analysis_rgb;
            default:selected_rgb=rgb;
        endcase
    end
    assign {red,green,blue} = selected_rgb;
endmodule
