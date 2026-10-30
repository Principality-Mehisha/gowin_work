// LF-terminated ASCII commands. CR is ignored for CRLF terminals.
// Reserve a complete response before applying a command: queue overload cannot
// produce a partial response or change the LED without an acknowledgement.
module hc05_commands (
    input wire clk, rst_n,
    input wire [7:0] rx_data,
    input wire rx_valid, framing_error,
    input wire tx_accepted,
    input wire [8:0] tx_used,
    output wire [7:0] reply_data,
    output wire reply_valid,
    input wire reply_ready,
    output reg led_on,
    output reg [31:0] rx_count, tx_count, frame_count, overflow_count, long_count
);
    reg [7:0] line [0:63];
    reg [6:0] length;
    reg discard, too_long;
    // Response kinds: PONG, OK, ECHO, STAT, ERR CMD, ERR LONG.
    localparam [2:0] PONG=0, OK=1, ECHO=2, STAT=3, BAD=4, LONG=5;
    reg [2:0] kind;
    reg active;
    reg [6:0] index, reply_length, echo_length;
    // Copy ECHO payload before reusing the receive line buffer.
    reg [7:0] echo [0:58];
    reg snap_led;
    reg [31:0] snap_rx, snap_tx, snap_frame, snap_overflow, snap_long;
    localparam [68*8-1:0] STATUS_TEMPLATE =
        "LED=0 RX=00000000 TX=00000000 FE=00000000 OV=00000000 LEN=00000000\015\n";
    localparam [47:0] PONG_TEXT="PONG\015\n";
    localparam [31:0] OK_TEXT="OK\015\n";
    localparam [71:0] BAD_TEXT="ERR CMD\015\n";
    localparam [79:0] LONG_TEXT="ERR LONG\015\n";
    function [7:0] hexchar;
        input [3:0] nibble;
        begin hexchar = nibble < 10 ? 8'd48+nibble : 8'd65+nibble-10; end
    endfunction
    reg [7:0] next_byte;
    always @* begin
        next_byte=0;
        case (kind)
            PONG: next_byte = PONG_TEXT[(5-index)*8 +: 8];
            OK: next_byte = OK_TEXT[(3-index)*8 +: 8];
            BAD: next_byte = BAD_TEXT[(8-index)*8 +: 8];
            LONG: next_byte = LONG_TEXT[(9-index)*8 +: 8];
            ECHO: begin
                if (index < echo_length) next_byte=echo[index];
                else if (index==echo_length) next_byte=13;
                else next_byte=10;
            end
            STAT: begin
                next_byte = STATUS_TEMPLATE[(67-index)*8 +: 8];
                if (index==4) next_byte=snap_led ? "1" : "0";
                if (index>=9 && index<=16)
                    next_byte=hexchar(snap_rx[(16-index)*4 +: 4]);
                if (index>=21 && index<=28)
                    next_byte=hexchar(snap_tx[(28-index)*4 +: 4]);
                if (index>=33 && index<=40)
                    next_byte=hexchar(snap_frame[(40-index)*4 +: 4]);
                if (index>=45 && index<=52)
                    next_byte=hexchar(snap_overflow[(52-index)*4 +: 4]);
                if (index>=58 && index<=65)
                    next_byte=hexchar(snap_long[(65-index)*4 +: 4]);
            end
            default: next_byte=0;
        endcase
    end
    assign reply_data=next_byte;
    assign reply_valid=active;
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            length<=0; discard<=0; too_long<=0; led_on<=0;
            rx_count<=0; tx_count<=0; frame_count<=0;
            overflow_count<=0; long_count<=0;
            kind<=PONG; active<=0; index<=0; reply_length<=0; echo_length<=0;
            snap_led<=0; snap_rx<=0; snap_tx<=0; snap_frame<=0;
            snap_overflow<=0; snap_long<=0;
        end else begin
            if (tx_accepted) tx_count<=tx_count+1'b1;
            if (active && reply_ready) begin
                if (index==reply_length-1'b1) begin active<=0; index<=0; end
                else index<=index+1'b1;
            end
            if (framing_error) begin
                frame_count<=frame_count+1'b1;
                discard<=1; length<=0; too_long<=0;
            end else if (rx_valid) begin
                rx_count<=rx_count+1'b1;
                if (rx_data==10) begin
                    length<=0; discard<=0; too_long<=0;
                    if (too_long || (!discard && length!=0)) begin
                        // Maximum response is below 96 bytes; only this block
                        // writes the FIFO. Reservation guarantees no overrun.
                        if (active || tx_used>160) overflow_count<=overflow_count+1'b1;
                        else begin
                            active<=1; index<=0;
                            kind<=BAD; reply_length<=9;
                            if (too_long) begin kind<=LONG; reply_length<=10; end
                            else if (length==4 && {line[0],line[1],line[2],line[3]}=="PING") begin
                                kind<=PONG; reply_length<=6;
                            end else if (length==5 &&
                                {line[0],line[1],line[2],line[3]}=="LED " &&
                                (line[4]=="0" || line[4]=="1")) begin
                                led_on<=line[4]=="1"; kind<=OK; reply_length<=4;
                            end else if (length>=5 &&
                                {line[0],line[1],line[2],line[3],line[4]}=="ECHO ") begin
                                kind<=ECHO; echo_length<=length-7'd5; reply_length<=length-7'd3;
                                for (i=0;i<59;i=i+1) echo[i]<=line[i+5];
                            end else if (length==4 &&
                                {line[0],line[1],line[2],line[3]}=="STAT") begin
                                kind<=STAT; reply_length<=68;
                                snap_led<=led_on; snap_rx<=rx_count+1'b1;
                                snap_tx<=tx_count+(tx_accepted ? 32'd1 : 32'd0);
                                snap_frame<=frame_count; snap_overflow<=overflow_count;
                                snap_long<=long_count;
                            end
                        end
                    end
                end else if (rx_data!=13 && !discard && !too_long) begin
                    if (length==64) begin
                        too_long<=1; length<=0; long_count<=long_count+1'b1;
                    end else begin line[length[5:0]]<=rx_data; length<=length+1'b1; end
                end
            end
        end
    end
endmodule
