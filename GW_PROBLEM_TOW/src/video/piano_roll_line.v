// Build the NEXT scanline during horizontal blank. Pipeline the 64:1 slot
// selection as 8x8, then register geometry and merge masks. The result is
// published within 70 clocks; the pixel read port retains its one-clock delay.
module piano_roll_line (
    input wire clk, reset_n,
    input wire [10:0] x,
    input wire [9:0] y,
    input wire [63:0] valid,
    input wire [447:0] pitch_bus,
    input wire [1023:0] top_bus,bottom_bus,
    input wire [6:0] read_pitch,
    output reg [1:0] pixel,
    output reg overflow,
    output wire busy
);
    reg [87:0] edges,interiors,work_edges,work_interiors;
    reg [5:0] slot;
    reg running;
    reg [3:0] valid_pipe;
    reg [9:0] row;
    reg [7:0] group_valid;
    reg [55:0] group_pitch;
    reg [127:0] group_top,group_bottom;
    reg [2:0] group_slot;
    reg selected_valid;
    reg [6:0] selected_pitch;
    reg signed [15:0] top_y,bottom_y;
    reg hit,interior_hit;
    reg [87:0] note_mask;
    reg start_line;
    reg [9:0] next_row;
    // Register the blanking comparator before it reaches the geometry enables.
    always @(posedge clk or negedge reset_n)begin
        if(!reset_n)begin start_line<=0;next_row<=0;end
        else begin start_line<=x==1600;next_row<=y==999 ? 10'd0 : y+1'b1;end
    end
    wire signed [15:0] row_signed=$signed({6'd0,row});
    assign busy=running || (valid_pipe!=0);
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            edges<=0; interiors<=0; work_edges<=0; work_interiors<=0;
            running<=0; valid_pipe<=0; slot<=0; row<=0; pixel<=0; overflow<=0;
            group_valid<=0;group_pitch<=0;group_top<=0;group_bottom<=0;group_slot<=0;
            selected_valid<=0; selected_pitch<=0; top_y<=0; bottom_y<=0;
            hit<=0;interior_hit<=0;note_mask<=0;
        end else begin
            pixel<=read_pitch<88 ? {interiors[read_pitch],edges[read_pitch]} : 2'b00;
            if(start_line) begin
                if(busy) overflow<=1;
                row<=next_row;
                slot<=0; work_edges<=0; work_interiors<=0; running<=1;valid_pipe<=0;
            end else begin
                valid_pipe<={valid_pipe[2:0],running};
                if(running)begin
                    group_valid<=valid[slot[5:3]*8+:8];
                    group_pitch<=pitch_bus[slot[5:3]*56+:56];
                    group_top<=top_bus[slot[5:3]*128+:128];
                    group_bottom<=bottom_bus[slot[5:3]*128+:128];
                    group_slot<=slot[2:0];
                    slot<=slot+1'b1;
                    if(slot==63)running<=0;
                end
                if(valid_pipe[0])begin
                    selected_valid<=group_valid[group_slot];
                    selected_pitch<=group_pitch[group_slot*7+:7];
                    top_y<=$signed(group_top[group_slot*16+:16]);
                    bottom_y<=$signed(group_bottom[group_slot*16+:16]);
                end
                if(valid_pipe[1])begin
                    hit<=selected_valid && selected_pitch<88 && row<720 && row_signed>=top_y && row_signed<bottom_y;
                    interior_hit<=row_signed>=top_y+16'sd2 && row_signed<bottom_y-16'sd2;
                    note_mask<=88'd1<<selected_pitch;
                end
                if(valid_pipe[2] && hit)begin
                    if(interior_hit)work_interiors<=work_interiors | note_mask;
                    else work_edges<=work_edges | note_mask;
                end
                if(valid_pipe[3] && !valid_pipe[2])begin edges<=work_edges;interiors<=work_interiors;end
            end
        end
    end
endmodule
