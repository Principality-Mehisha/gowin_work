// Three virtual keys address piano, marimba or clarinet. Selection is
// separate from the held note, so changing selection never changes its pitch.
// A play emits one note-on, a timed note-off, then clears after the tail window.
module uart_note_audition #(
    parameter integer GATE_CYCLES = 25000000,
    parameter integer TAIL_CYCLES = 50000000
) (
    input wire clk, rst_n, previous_request, next_request, play_request, cancel,
    input wire select_piano_request, select_marimba_request, select_clarinet_request,
    input wire event_ready,
    // Shared display index: 0=A0. Marimba events use MIDI (index + 21).
    output wire [6:0] selected_note,
    output reg selected_marimba,
    output reg selected_clarinet,
    output wire event_valid, event_on,
    output reg [6:0] event_note,
    output wire [7:0] event_dynamics,
    output wire busy,
    output reg clear
);
    localparam IDLE=0, ON_PENDING=1, HOLD=2, OFF_PENDING=3, TAIL=4;
    reg [2:0] state;
    reg [31:0] count;
    reg [6:0] piano_note, marimba_note, clarinet_note;
    wire instrument_request=select_piano_request || select_marimba_request || select_clarinet_request;
    assign selected_note=selected_clarinet ? clarinet_note : (selected_marimba ? marimba_note : piano_note);
    assign busy=state!=IDLE;
    assign event_valid=(state==ON_PENDING || state==OFF_PENDING) &&
                       !cancel && !play_request && !instrument_request;
    assign event_on=state==ON_PENDING;
    assign event_dynamics=8'd192;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            selected_marimba<=0; selected_clarinet<=0;
            piano_note<=0; marimba_note<=15; clarinet_note<=29;
        end
        else if (select_piano_request) begin selected_marimba<=0; selected_clarinet<=0; end
        else if (select_marimba_request) begin selected_marimba<=1; selected_clarinet<=0; end
        else if (select_clarinet_request) begin selected_marimba<=0; selected_clarinet<=1; end
        else if (selected_clarinet) begin
            if (previous_request) clarinet_note<=(clarinet_note==29) ? 7'd73 : clarinet_note-1'b1;
            else if (next_request) clarinet_note<=(clarinet_note==73) ? 7'd29 : clarinet_note+1'b1;
        end
        else if (selected_marimba) begin
            if (previous_request) marimba_note<=(marimba_note==15) ? 7'd62 : marimba_note-1'b1;
            else if (next_request) marimba_note<=(marimba_note==62) ? 7'd15 : marimba_note+1'b1;
        end else begin
            if (previous_request) piano_note<=(piano_note==0) ? 7'd87 : piano_note-1'b1;
            else if (next_request) piano_note<=(piano_note==87) ? 7'd0 : piano_note+1'b1;
        end
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin state<=IDLE; count<=0; event_note<=0; clear<=0; end
        else begin
            clear<=0;
            if (cancel || instrument_request) begin state<=IDLE; count<=0; end
            else if (play_request) begin
                state<=ON_PENDING;
                event_note<=(selected_marimba || selected_clarinet) ? selected_note+7'd21 : selected_note;
                count<=0;
            end
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
