`timescale 1ns/1ps
module dvi_photo (
    input wire sys_clk,
    input wire KEY2,
    input wire KEY0,
    output wire [2:0] tmds_data_p,
    output wire [2:0] tmds_data_n,
    output wire tmds_clk_p,
    output wire tmds_clk_n
);
    GSR GSR(.GSRI(KEY2));
    reg [15:0] power_on = 0;
    always @(posedge sys_clk or negedge KEY2) begin
        if (!KEY2)
            power_on <= 0;
        else if (!(&power_on))
            power_on <= power_on + 16'd1;
    end
    wire clock_reset = !KEY2 || !(&power_on);
    wire pixel_clk, serial_clk, locked;
    video_clock clocks(.sys_clk(sys_clk), .reset(clock_reset),
        .serial_clk(serial_clk), .pixel_clk(pixel_clk), .locked(locked));
    reg [3:0] reset_release = 0;
    always @(posedge pixel_clk or negedge locked) begin
        if (!locked)
            reset_release <= 0;
        else
            reset_release <= {reset_release[2:0], 1'b1};
    end
    wire video_reset_n = reset_release[3];
    reg [1:0] key_sync;
    reg pattern;
    wire [7:0] red, green, blue;
    wire hsync, vsync, de;
    always @(posedge pixel_clk or negedge video_reset_n) begin
        if (!video_reset_n) begin
            key_sync <= 2'b11;
            pattern <= 0;
        end else begin
            key_sync <= {key_sync[0], KEY0};
            // Update only during vertical blanking: no mid-frame mode tearing.
            if (vsync)
                pattern <= !key_sync[1];
        end
    end
    video_source video(.pixel_clk(pixel_clk), .reset_n(video_reset_n),
        .test_pattern(pattern), .red(red), .green(green), .blue(blue),
        .hsync(hsync), .vsync(vsync), .de(de));
    dvi_tx tx(.pixel_clk(pixel_clk), .serial_clk(serial_clk),
        .reset_n(video_reset_n), .red(red), .green(green), .blue(blue),
        .hsync(hsync), .vsync(vsync), .de(de),
        .tmds_data_p(tmds_data_p), .tmds_data_n(tmds_data_n),
        .tmds_clk_p(tmds_clk_p), .tmds_clk_n(tmds_clk_n));
endmodule
