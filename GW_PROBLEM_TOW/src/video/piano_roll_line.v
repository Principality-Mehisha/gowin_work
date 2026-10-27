// Build the NEXT scanline during the 200-clock horizontal blank (130 clocks).
// Two 88-bit masks replace the original full-height bitmap RAM.
module piano_roll_line (
    input wire clk, reset_n,
    input wire [10:0] x,
    input wire [9:0] y,
    input wire [63:0] valid,
    input wire [447:0] pitch_bus,
    input wire [1023:0] top_bus,bottom_bus,
    input wire [6:0] read_pitch,
    output reg [1:0] pixel,
    output reg overflow
);
    reg [87:0] edges,interiors,work_edges,work_interiors;
    reg [6:0] slot;
    reg [1:0] state;
    reg [9:0] row;
    reg selected_valid;
    reg [6:0] selected_pitch;
    reg signed [15:0] top_y,bottom_y;
    wire signed [15:0] row_signed=$signed({6'd0,row});
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            edges<=0; interiors<=0; work_edges<=0; work_interiors<=0;
            state<=0; slot<=0; row<=0; pixel<=0; overflow<=0;
            selected_valid<=0; selected_pitch<=0; top_y<=0; bottom_y<=0;
        end else begin
            pixel<=read_pitch<88 ? {interiors[read_pitch],edges[read_pitch]} : 2'b00;
            if(x==1600) begin
                if(state!=0) overflow<=1;
                row<=y==999 ? 10'd0 : y+1'b1;
                slot<=0; work_edges<=0; work_interiors<=0; state<=1;
            end else case(state)
                1: begin
                    selected_valid<=valid[slot[5:0]];
                    selected_pitch<=pitch_bus[slot[5:0]*7+:7];
                    top_y<=$signed(top_bus[slot[5:0]*16+:16]);
                    bottom_y<=$signed(bottom_bus[slot[5:0]*16+:16]);
                    state<=2;
                end
                2: begin
                    if(selected_valid && selected_pitch<88 && row<720 && row_signed>=top_y && row_signed<bottom_y) begin
                        if(row_signed>=top_y+16'sd2 && row_signed<bottom_y-16'sd2)
                            work_interiors[selected_pitch]<=1;
                        else work_edges[selected_pitch]<=1;
                    end
                    slot<=slot+1'b1; state<=slot==63 ? 3 : 1;
                end
                3: begin edges<=work_edges; interiors<=work_interiors; state<=0; end
                default: state<=0;
            endcase
        end
    end
endmodule
