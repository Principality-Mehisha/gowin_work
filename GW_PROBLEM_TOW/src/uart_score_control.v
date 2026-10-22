// Fixed 10-byte control frames: A5 5A 01 SEQ CMD P0 P1 P2 SUM 0D.
// SUM = low byte of bytes 2..7. Unsupported/invalid commands never alter audio.
// Feedback is native TJC ASCII, rather than requiring recmod=1 screen parsing.
module uart_score_control #(
    parameter integer CLK_HZ = 50000000,
    parameter integer BAUD = 115200,
    parameter integer TIMEOUT_CYCLES = CLK_HZ/50
) (
    input wire clk, rst_n, rx,
    output wire tx,
    input wire [7:0] player_state, player_track, player_error,
    output wire play_request, stop_request,
    output wire [7:0] requested_track,
    output reg overflow
);
    wire [7:0] rx_data;
    wire rx_valid, rx_error;
    uart_rx #(.CLK_HZ(CLK_HZ),.BAUD(BAUD)) receiver (
        .clk(clk),.rst_n(rst_n),.rx(rx),.data(rx_data),.valid(rx_valid),.framing_error(rx_error));
    reg [79:0] window;
    wire [79:0] candidate={window[71:0],rx_data};
    wire [7:0] sum=candidate[63:56]+candidate[55:48]+candidate[47:40]+
                   candidate[39:32]+candidate[31:24]+candidate[23:16];
    reg [3:0] received;
    reg [$clog2(TIMEOUT_CYCLES+1)-1:0] timeout_count;
    reg request;
    reg [7:0] seq, cmd, p0, p1, p2;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            window<=0; received<=0; timeout_count<=0; request<=0;
            seq<=0; cmd<=0; p0<=0; p1<=0; p2<=0;
        end else begin
            request<=0;
            if (rx_error || (received!=0 && timeout_count==TIMEOUT_CYCLES-1)) begin
                received<=0; timeout_count<=0; window<=0;
            end else if (rx_valid) begin
                timeout_count<=0; window<=candidate;
                if (received<9) received<=received+1'b1;
                if (received>=9 && candidate[79:64]==16'ha55a &&
                    candidate[63:56]==1 && candidate[15:8]==sum && candidate[7:0]==8'h0d) begin
                    request<=1; seq<=candidate[55:48]; cmd<=candidate[47:40];
                    p0<=candidate[39:32]; p1<=candidate[31:24]; p2<=candidate[23:16];
                    received<=0; window<=0;
                end
            end else if (received!=0) timeout_count<=timeout_count+1'b1;
        end
    end
    wire known=(cmd==8'h01 || cmd==8'h10 || cmd==8'h11);
    wire args_ok=(p1==0 && p2==0 && ((cmd==8'h10) ? (p0>=1 && p0<=3) : p0==0));
    // A FIFO slot is reserved while the accepted command changes player state.
    reg [47:0] replies[0:15];
    reg [3:0] wr, rd;
    reg [4:0] count;
    reg pending;
    reg [7:0] ack_seq, ack_cmd, ack_result;
    wire room=count<15;
    assign play_request=request && known && args_ok && room && cmd==8'h10;
    // Stop remains effective even if a misbehaving host saturates feedback.
    assign stop_request=request && known && args_ok && cmd==8'h11;
    assign requested_track=p0;
    reg [23:0] observed;
    reg dirty;
    wire [7:0] reported_error=player_error!=0 ? player_error : (overflow ? 8'h60 : 8'h00);
    wire [23:0] current={player_state,player_track,reported_error};
    wire push=pending || (dirty && room && !request);
    wire response_ready;
    wire pop=count!=0 && response_ready;
    wire [47:0] push_data=pending ? {current,ack_result,ack_seq,ack_cmd} :
                                                  {current,(overflow ? 8'd3 : 8'd0),8'd0,8'h81};
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr<=0; rd<=0; count<=0; pending<=0; observed<=0; dirty<=1;
            ack_seq<=0; ack_cmd<=0; ack_result<=0; overflow<=0;
        end else begin
            pending<=0;
            if (current!=observed) begin observed<=current; dirty<=1; end
            if (request) begin
                if (room) begin
                    pending<=1; ack_seq<=seq; ack_cmd<=cmd;
                    ack_result<=!known ? 8'd2 : (!args_ok ? 8'd1 : 8'd0);
                end else begin overflow<=1; dirty<=1; end
            end
            if (push) begin
                replies[wr]<=push_data; wr<=wr+1'b1;
                if (current==observed) dirty<=0;
            end
            if (pop) rd<=rd+1'b1;
            case ({push,pop})
                2'b10: count<=count+1'b1;
                2'b01: count<=count-1'b1;
                default: count<=count;
            endcase
        end
    end
    wire [7:0] tx_data;
    wire tx_valid, tx_ready;
    tjc_status_tx formatter (.clk(clk),.rst_n(rst_n),.snapshot(replies[rd]),
        .valid(count!=0),.ready(response_ready),.byte_data(tx_data),
        .byte_valid(tx_valid),.byte_ready(tx_ready));
    uart_tx #(.CLK_HZ(CLK_HZ),.BAUD(BAUD)) transmitter (
        .clk(clk),.rst_n(rst_n),.data(tx_data),.valid(tx_valid),.ready(tx_ready),.tx(tx));
endmodule
