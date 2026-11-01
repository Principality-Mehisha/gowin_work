// Live falling history: 180 video frames, four pixels per frame (3 s at 60 Hz).
// Rows hold all 88 keys, so dense chords never compete for rectangle slots.
// One synchronous history read plus the pitch lookup matches piano_scene's
// existing column/palette pipeline. No history RAM reset or audio backpressure.
module piano_live_roll (
    input wire clk,reset_n,update,active,clear,
    input wire [87:0] activity,
    input wire [9:0] y,
    input wire [6:0] read_pitch,
    output reg [1:0] pixel
);
    reg [87:0] history[0:179];
    reg [7:0] newest,filled;
    wire [7:0] next_row=newest==179 ? 8'd0 : newest+1'b1;
    wire [7:0] age=y[9:2];
    wire [8:0] wrapped={1'b0,newest}+9'd180-{1'b0,age};
    wire [7:0] address=newest>=age ? newest-age : wrapped[7:0];
    reg [87:0] row;
    reg row_valid;
    always @(posedge clk)begin
        if(update && active)history[clear ? 8'd0 : next_row]<=activity;
        row<=history[address];
    end
    always @(posedge clk or negedge reset_n)begin
        if(!reset_n)begin newest<=179;filled<=0;row_valid<=0;pixel<=0;end
        else begin
            row_valid<=y<720 && age<filled;
            pixel<=row_valid && read_pitch<88 && row[read_pitch] ? 2'b11 : 2'b00;
            if(update)begin
                if(!active)begin newest<=179;filled<=0;end
                else if(clear)begin newest<=0;filled<=1;end
                else begin newest<=next_row;if(filled<180)filled<=filled+1'b1;end
            end
        end
    end
endmodule
