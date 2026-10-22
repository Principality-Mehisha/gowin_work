// Three virtual keys address the complete piano range A0..C8. Selection is
// separate from the held note, so changing selection never changes its pitch.
// A play emits one note-on, a timed note-off, then clears after the tail window.
module uart_note_audition #(
    parameter integer GATE_CYCLES = 25000000,
    parameter integer TAIL_CYCLES = 50000000
) (
    input wire clk, rst_n, previous_request, next_request, play_request, cancel,
    input wire event_ready,
    output reg [6:0] selected_note,
    output wire event_valid, event_on,
    output reg [6:0] event_note,
    output wire [7:0] event_dynamics,
    output wire busy,
    output reg clear
);
    localparam IDLE=0, ON_PENDING=1, HOLD=2, OFF_PENDING=3, TAIL=4;
    reg [2:0] state;
    reg [31:0] count;
    assign busy=state!=IDLE;
    assign event_valid=(state==ON_PENDING || state==OFF_PENDING) && !cancel && !play_request;
    assign event_on=state==ON_PENDING;
    assign event_dynamics=8'd192;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) selected_note<=0;
        else if (previous_request) selected_note<=(selected_note==0) ? 7'd87 : selected_note-1'b1;
        else if (next_request) selected_note<=(selected_note==87) ? 7'd0 : selected_note+1'b1;
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin state<=IDLE; count<=0; event_note<=0; clear<=0; end
        else begin
            clear<=0;
            if (cancel) begin state<=IDLE; count<=0; end
            else if (play_request) begin state<=ON_PENDING; event_note<=selected_note; count<=0; end
            else case(state)
                ON_PENDING: if(event_ready) begin state<=HOLD; count<=0; end
                HOLD: if(count==GATE_CYCLES-1) begin state<=OFF_PENDING; count<=0; end
                      else count<=count+1'b1;
                OFF_PENDING: if(event_ready) begin state<=TAIL; count<=0; end
                TAIL: if(count==TAIL_CYCLES-1) begin state<=IDLE; clear<=1; count<=0; end
                      else count<=count+1'b1;
                default: begin state<=IDLE; count<=0; end
            endcase
        end
    end
endmodule
