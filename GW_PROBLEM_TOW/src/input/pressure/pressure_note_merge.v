// Up to 16 physical keys can share one synth note (notably clamped C8).
// Aggregate gain by maximum, and release the note only after its last owner.
// Scan owners over 16 clocks instead of creating a long combinational max chain.
module pressure_note_merge (
    input wire clk, reset_n,
    input wire input_valid, input_on, input_update,
    input wire [3:0] input_key,
    input wire [6:0] input_note,
    input wire [7:0] input_dynamics,
    output wire input_ready,
    output reg event_valid, event_on, event_update,
    output reg [6:0] event_note,
    output reg [7:0] event_dynamics,
    input wire event_ready
);
    localparam IDLE=0, SCAN=1, COMMIT=2, WAIT=3;
    reg [1:0] state;
    reg [15:0] owners;
    reg [6:0] owner_note [0:15];
    reg [7:0] owner_gain [0:15];
    reg [3:0] key_q, scan_key;
    reg [6:0] note_q;
    reg [7:0] gain_q, other_gain;
    reg on_q, update_q, other_held;
    assign input_ready=state==IDLE;
    integer i;
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            state<=IDLE; owners<=0; event_valid<=0;
            event_on<=0; event_update<=0; event_note<=0; event_dynamics<=0;
            key_q<=0; scan_key<=0; note_q<=0; gain_q<=0;
            other_gain<=0; on_q<=0; update_q<=0; other_held<=0;
            for(i=0;i<16;i=i+1) begin owner_note[i]<=0; owner_gain[i]<=0; end
        end else case(state)
            IDLE: if(input_valid) begin
                key_q<=input_key; note_q<=input_note; gain_q<=input_dynamics;
                on_q<=input_on; update_q<=input_update;
                other_gain<=0; other_held<=0; scan_key<=0;
                state<=SCAN;
            end
            SCAN: begin
                if(scan_key!=key_q && owners[scan_key] && owner_note[scan_key]==note_q) begin
                    other_held<=1;
                    if(owner_gain[scan_key]>other_gain) other_gain<=owner_gain[scan_key];
                end
                if(scan_key==15) state<=COMMIT;
                else scan_key<=scan_key+1'b1;
            end
            COMMIT: begin
                event_note<=note_q;
                if(update_q && !owners[key_q]) state<=IDLE;
                else begin
                    if(on_q || update_q) begin
                        owners[key_q]<=1;
                        owner_note[key_q]<=note_q;
                        owner_gain[key_q]<=gain_q;
                        event_on<=on_q && !update_q && !other_held;
                        event_update<=update_q || other_held;
                        event_dynamics<=other_gain>gain_q ? other_gain : gain_q;
                    end else begin
                        owners[key_q]<=0;
                        event_on<=0;
                        event_update<=other_held;
                        event_dynamics<=other_held ? other_gain : gain_q;
                    end
                    event_valid<=1; state<=WAIT;
                end
            end
            WAIT: if(event_ready) begin event_valid<=0; state<=IDLE; end
            default: begin state<=IDLE; event_valid<=0; end
        endcase
    end
endmodule
