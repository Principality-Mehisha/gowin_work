// Gate edges are queued in order. Continuous pressure is coalesced to the
// latest per-key target, and never occupies the edge FIFO.
module pressure_events #(
    parameter integer FIFO_BITS = 5
) (
    input wire clk, reset_n,
    input wire [6:0] base_note,
    input wire edge_valid, edge_on,
    input wire [3:0] edge_key,
    input wire [7:0] edge_gain,
    input wire [15:0] pressed,
    input wire [127:0] gains,
    input wire event_ready,
    output reg event_valid, event_on, event_update,
    output reg [6:0] event_note,
    output reg [3:0] event_key,
    output reg [7:0] event_dynamics,
    output reg overflow
);
    localparam integer DEPTH=1<<FIFO_BITS;
    reg [19:0] fifo [0:DEPTH-1];
    reg [FIFO_BITS-1:0] wr_ptr, rd_ptr;
    reg [FIFO_BITS:0] count;
    reg [3:0] cursor;
    reg [15:0] sounding;
    reg [7:0] sent_gain [0:15];
    reg [6:0] captured_note [0:15];
    reg [6:0] sounding_note [0:15];
    wire stage_free=!event_valid || event_ready;
    wire pop=stage_free && count!=0;
    wire push=edge_valid && (count<DEPTH || pop);
    wire [7:0] cursor_gain=gains[cursor*8 +: 8];
    wire [7:0] requested_note={1'b0,base_note}+{4'd0,edge_key};
    wire [6:0] mapped_note=requested_note>87 ? 7'd87 : requested_note[6:0];
    integer i;
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            wr_ptr<=0; rd_ptr<=0; count<=0; cursor<=0; sounding<=0;
            event_valid<=0; event_on<=0; event_update<=0;
            event_key<=0; event_note<=0; event_dynamics<=0; overflow<=0;
            for(i=0;i<16;i=i+1) begin
                sent_gain[i]<=0; captured_note[i]<=0; sounding_note[i]<=0;
            end
        end else begin
            if(edge_valid && !push) overflow<=1;
            if(push) begin
                // Snapshot on the physical press, not on later FIFO dispatch.
                // Matching release/update must retain that pitch across group changes.
                fifo[wr_ptr]<={edge_on,edge_key,
                    (edge_on ? mapped_note : captured_note[edge_key]),edge_gain};
                if(edge_on) captured_note[edge_key]<=mapped_note;
                wr_ptr<=wr_ptr+1'b1;
            end
            if(pop) rd_ptr<=rd_ptr+1'b1;
            case({push,pop})
                2'b10: count<=count+1'b1;
                2'b01: count<=count-1'b1;
            endcase
            if(event_valid && event_ready) begin
                if(!event_update) sounding[event_key]<=event_on;
                if(event_on && !event_update) sounding_note[event_key]<=event_note;
                if(event_on || event_update) sent_gain[event_key]<=event_dynamics;
            end
            if(stage_free) begin
                event_valid<=0;
                if(count!=0) begin
                    {event_on,event_key,event_note,event_dynamics}<=fifo[rd_ptr];
                    event_update<=0; event_valid<=1;
                end else begin
                    cursor<=cursor+1'b1;
                    if(sounding[cursor] && pressed[cursor] &&
                       cursor_gain!=sent_gain[cursor]) begin
                        event_valid<=1; event_update<=1; event_on<=0;
                        event_key<=cursor; event_dynamics<=cursor_gain;
                        event_note<=sounding_note[cursor];
                    end
                end
            end
        end
    end
endmodule
