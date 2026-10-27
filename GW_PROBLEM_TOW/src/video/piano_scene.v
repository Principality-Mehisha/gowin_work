`timescale 1ns/1ps
module piano_scene (
    input wire clk, input wire reset_n, input wire frame_tick,
    input wire update, active,
    input wire [31:0] elapsed_ms,
    input wire [87:0] lit_keys,
    input wire [10:0] x, input wire [9:0] y,
    input wire test_pattern,
    output reg [23:0] rgb
);
    wire [63:0] valid;
    wire [447:0] pitch_bus;
    wire [1023:0] top_bus, bottom_bus;
    wire engine_busy, overflow, line_overflow;
    waterfall_engine engine(.clk(clk), .reset_n(reset_n), .update(update),
        .active(active), .elapsed_ms(elapsed_ms), .valid(valid), .pitch_bus(pitch_bus),
        .top_bus(top_bus), .bottom_bus(bottom_bus), .busy(engine_busy), .overflow(overflow));
    wire [23:0] column;
    piano_keymap keymap(.clk(clk), .x(x), .column(column));
    reg [10:0] x1,x2;
    reg [9:0] y1,y2;
    reg [23:0] column2;
    reg pattern1,pattern2,active1,active2;
    reg white_lit2,black_lit2;
    wire [6:0] white_note=column[6:0],black_note=column[13:7];
    wire [1:0] roll_pixel;
    piano_roll_line line_builder(.clk(clk),.reset_n(reset_n),.x(x),.y(y),
        .valid(valid),.pitch_bus(pitch_bus),.top_bus(top_bus),.bottom_bus(bottom_bus),
        .read_pitch(column[22:16]),.pixel(roll_pixel),.overflow(line_overflow));
    reg [23:0] color;
    always @* begin
        color = 24'h0b1020;
        if (pattern2) begin
            if      (x2 < 200)  color = 24'hffffff;
            else if (x2 < 400)  color = 24'hffff00;
            else if (x2 < 600)  color = 24'h00ffff;
            else if (x2 < 800)  color = 24'h00ff00;
            else if (x2 < 1000) color = 24'hff00ff;
            else if (x2 < 1200) color = 24'hff0000;
            else if (x2 < 1400) color = 24'h0000ff;
            else               color = 24'h000000;
        end else if (y2 >= 720) begin
            if (column2[6:0] < 88) begin
                color = white_lit2 ? (column2[6:0] < 39 ? 24'h56dfff : 24'hbb91ff) :
                    (y2 >= 888 ? 24'hb7bfce : 24'heef2fa);
                if (column2[14]) color = 24'h343d51;
                if (column2[15] && y2 >= 865 && y2 < 872) color = 24'h687893;
                if (column2[13:7] < 88 && y2 < 826)
                    color = black_lit2 ? (column2[13:7] < 39 ? 24'h22bbef : 24'h9663e8) :
                        (y2 >= 816 ? 24'h30394b : 24'h121725);
            end
        end else if (y2 >= 716) color = 24'h73d8ff;
        else if (column2[6:0] < 88 && column2[14]) color = 24'h172137;
        else if (y2[6:0] == 0) color = 24'h152039;
        if (!pattern2 && y2 < 720 && column2[22:16] < 88 && roll_pixel != 0) begin
            if (column2[22:16] >= 39)
                color = roll_pixel[1] && column2[23] ? 24'h9964ed : 24'hd8bcff;
            else color = roll_pixel[1] && column2[23] ? 24'h25b9e8 : 24'h9aeaff;
        end
        if (!pattern2 && (overflow || line_overflow) && x2 < 12 && y2 < 12) color = 24'hff2020;
    end
    reg [23:0] rgb3,rgb4;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            x1<=0; x2<=0; y1<=0; y2<=0; column2<=0;
            pattern1<=0; pattern2<=0; active1<=0; active2<=0;
            white_lit2<=0; black_lit2<=0; rgb3<=0; rgb4<=0; rgb<=0;
        end else begin
            // ROM column lookup, bitmap/highlight lookup, palette, two output
            // registers: five clocks, matching the delayed DE/HS/VS signals.
            x1<=x; y1<=y; pattern1<=test_pattern; active1<=x<1600 && y<900;
            x2<=x1; y2<=y1; column2<=column; pattern2<=pattern1; active2<=active1;
            white_lit2<=white_note<88 ? lit_keys[white_note] : 1'b0;
            black_lit2<=black_note<88 ? lit_keys[black_note] : 1'b0;
            rgb3<=active2 ? color : 24'd0;
            rgb4<=rgb3; rgb<=rgb4;
        end
    end
endmodule
