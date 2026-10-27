// Rebuild visible notes from the AUDIO timeline, once during vertical blank.
// Three seconds of look-ahead, no independent animation clock or start delay.
module waterfall_engine (
    input wire clk, reset_n, update, active,
    input wire [31:0] elapsed_ms,
    output reg [63:0] valid,
    output wire [447:0] pitch_bus,
    output wire [1023:0] top_bus, bottom_bus,
    output wire busy,
    output reg overflow
);
    reg [6:0] pitch [0:63];
    reg signed [15:0] top_y [0:63], bottom_y [0:63];
    reg [11:0] address;
    wire [11:0] count;
    wire [31:0] data;
    piano_score_rom score(.clk(clk),.address(address),.data(data),.count(count));
    reg [31:0] time_product;
    reg [5:0] remainder;
    reg [5:0] divide_bit;
    wire [6:0] trial={remainder,time_product[31]};
    wire quotient_bit=trial>=50;
    wire [31:0] quotient_next={time_product[30:0],quotient_bit};
    reg [15:0] now_frame;
    reg [6:0] used;
    reg [2:0] state;
    localparam IDLE=0, TIME=1, WAIT_ROM=2, LATCH=3, EVAL=4, GEOMETRY=5, STORE=6;
    reg [31:0] event_data;
    reg visible,done;
    reg signed [17:0] bottom_work,top_work;
    wire [16:0] end_frame={3'b0,event_data[31:18]}+{6'b0,event_data[17:7]};
    wire signed [17:0] delta=$signed({2'b0,now_frame})-$signed({4'b0,event_data[31:18]});
    wire signed [17:0] bottom=18'sd720+(delta<<<2);
    assign busy=state!=IDLE;
    genvar g;
    generate for(g=0;g<64;g=g+1) begin:slots
        assign pitch_bus[g*7+:7]=pitch[g];
        assign top_bus[g*16+:16]=top_y[g];
        assign bottom_bus[g*16+:16]=bottom_y[g];
        reg write_slot;
        always @(posedge clk or negedge reset_n) begin
            if(!reset_n) write_slot<=0;
            else write_slot<=!update && state==STORE && visible && used==g && !done;
        end
        always @(posedge clk) if(write_slot) begin
            pitch[g]<=event_data[6:0];top_y[g]<=top_work[15:0];bottom_y[g]<=bottom_work[15:0];
        end
        always @(posedge clk or negedge reset_n) begin
            if(!reset_n) valid[g]<=0;
            else if(update) valid[g]<=0;
            else if(write_slot) valid[g]<=1;
        end
    end endgenerate
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            state<=IDLE; overflow<=0; address<=0; used<=0;
            time_product<=0; now_frame<=0; remainder<=0; divide_bit<=0;
            event_data<=0;visible<=0;done<=0;top_work<=0;bottom_work<=0;
        end else if(update) begin
            if(busy) overflow<=1;
            address<=0; used<=0;
            // floor(ms*60/1000) = floor(ms*3/50), iterative division
            // keeps a wide constant divider off the 108 MHz pixel path.
            time_product<=elapsed_ms*32'd3; remainder<=0; divide_bit<=0;
            state<=active ? TIME : IDLE;
        end else case(state)
            TIME: begin
                time_product<=quotient_next;
                remainder<=quotient_bit ? trial-7'd50 : trial;
                divide_bit<=divide_bit+1'b1;
                if(divide_bit==31) begin now_frame<=quotient_next[15:0]; state<=WAIT_ROM; end
            end
            WAIT_ROM: state<=LATCH;
            LATCH: begin event_data<=data; state<=EVAL; end
            EVAL: begin
                done<=address>=count || {3'b0,event_data[31:18]}>{1'b0,now_frame}+17'd180;
                visible<=end_frame>{1'b0,now_frame};
                bottom_work<=bottom;
                state<=GEOMETRY;
            end
            GEOMETRY: begin
                top_work<=bottom_work-($signed({7'b0,event_data[17:7]})<<<2);
                state<=STORE;
            end
            STORE: begin
                if(done) state<=IDLE;
                else if(visible && used==64) begin overflow<=1;state<=IDLE;end
                else begin
                    if(visible) used<=used+1'b1;
                    address<=address+1'b1;state<=WAIT_ROM;
                end
            end
            default: state<=IDLE;
        endcase
    end
endmodule
