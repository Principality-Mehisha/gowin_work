`timescale 1ns/1ps
// A two-bit vertical mask per pitch, rather than 64 rectangle comparators
// in every pixel path. Rebuild only during the 180,000-clock vertical blank.
module piano_roll_bitmap (
    input wire clk, reset_n, frame_tick, engine_busy,
    input wire [63:0] valid,
    input wire [447:0] pitch_bus,
    input wire [1023:0] top_bus, bottom_bus,
    input wire [16:0] read_address,
    output reg [1:0] pixel,
    output wire busy,
    output reg ready, overflow
);
    reg [1:0] rows [0:131071];
    reg [1:0] previous;
    reg [2:0] state;
    localparam IDLE=0, WAIT_ENGINE=1, CLEAR=2, LOAD=3, LIMIT=4, READ_ROW=5, WRITE_ROW=6;
    reg [16:0] clear_address;
    reg [5:0] slot;
    reg selected_valid;
    reg [6:0] pitch;
    reg signed [15:0] top_y, bottom_y;
    reg signed [15:0] inner_top, inner_bottom;
    reg [9:0] row, end_row;
    reg row_inside;
    wire [16:0] write_address = state == CLEAR ? clear_address : {row,pitch};
    wire write_enable = state == CLEAR || state == WRITE_ROW;
    wire [1:0] write_data = state == CLEAR ? 2'b00 :
        previous | (row_inside ? 2'b10 : 2'b01);
    // Same-address read/write port for the builder, independent display port.
    // OR keeps an interior pixel when two repeated notes overlap in a lane.
    always @(posedge clk) begin
        if (write_enable) rows[write_address] <= write_data;
        // GW5A DPB supports no-change/write-through, not read-before-write.
        // The READ_ROW phase captures data; hold it during WRITE_ROW.
        if (!write_enable) previous <= rows[write_address];
        pixel <= rows[read_address];
    end
    assign busy = state != IDLE;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= CLEAR; clear_address <= 0; slot <= 0;
            selected_valid <= 0; pitch <= 0; top_y <= 0; bottom_y <= 0;
            inner_top <= 0; inner_bottom <= 0; row <= 0; end_row <= 0;
            row_inside <= 0; ready <= 0; overflow <= 0;
        end else begin
            if (frame_tick && busy) overflow <= 1;
            case (state)
                IDLE: if (frame_tick) state <= WAIT_ENGINE;
                WAIT_ENGINE: if (!engine_busy) begin
                    clear_address <= 0; slot <= 0; state <= CLEAR;
                end
                CLEAR: begin
                    if (clear_address == 92159) begin
                        if (!ready) begin ready <= 1; state <= IDLE; end
                        else state <= LOAD;
                    end else clear_address <= clear_address + 1'b1;
                end
                LOAD: begin
                    selected_valid <= valid[slot];
                    pitch <= pitch_bus[slot*7+:7];
                    top_y <= $signed(top_bus[slot*16+:16]);
                    bottom_y <= $signed(bottom_bus[slot*16+:16]);
                    state <= LIMIT;
                end
                LIMIT: begin
                    row <= top_y < 0 ? 10'd0 : top_y[9:0];
                    end_row <= bottom_y > 720 ? 10'd720 : bottom_y[9:0];
                    inner_top <= top_y + 16'sd2;
                    inner_bottom <= bottom_y - 16'sd2;
                    if (selected_valid && bottom_y > 0 && top_y < 720) state <= READ_ROW;
                    else if (slot == 63) state <= IDLE;
                    else begin slot <= slot+1'b1; state <= LOAD; end
                end
                READ_ROW: begin
                    row_inside <= $signed({6'd0,row}) >= inner_top &&
                                  $signed({6'd0,row}) < inner_bottom;
                    state <= WRITE_ROW;
                end
                WRITE_ROW: begin
                    if (row+10'd1 == end_row) begin
                        if (slot == 63) state <= IDLE;
                        else begin slot <= slot+1'b1; state <= LOAD; end
                    end else begin row <= row+1'b1; state <= READ_ROW; end
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
