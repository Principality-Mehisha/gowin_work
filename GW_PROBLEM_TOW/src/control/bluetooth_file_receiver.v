// Protocol v2: framed BEGIN -> READY, exactly N raw bytes (no DATA ACKs),
// framed END -> final result. A BSRAM FIFO decouples UART from SD program busy.
module bluetooth_file_receiver #(
    parameter integer CLK_HZ=50000000,
    parameter integer BAUD=115200,
    parameter integer MAX_FILE_BYTES=102400,
    parameter integer FIFO_BITS=15,
    parameter integer PACKET_TIMEOUT_CYCLES=25000000,
    parameter integer SESSION_TIMEOUT_CYCLES=1500000000,
    parameter integer SD_POWER_WAIT_CYCLES=500000,
    parameter integer SD_HALF_DIV=63
) (
    input wire clk, reset_n, rx,
    output wire tx, upload_active,
    output reg upload_complete, upload_invalidated,
    output wire [7:0] uploaded_track,
    output wire sd_cs_n, sd_sck, sd_mosi,
    input wire sd_miso
);
    localparam SYNC_A=0, SYNC_B=1, HEADER=2, PAYLOAD=3, CRC_LOW=4, CRC_HIGH=5,
        DISPATCH=6, PREPARE=7, ARMED=8, RAW=9, WAIT_FINISH=10, WAIT_CANCEL=11,
        RESPONSE_CRC=12, RESPONSE_PACK=13, RESPONSE_SEND=14,
        PING_I=15, PING_N=16, PING_G=17, PING_SEND=18;
    localparam integer FIFO_BYTES=1<<FIFO_BITS;
    reg [4:0] state, after_response;
    wire [7:0] rx_data;
    wire rx_valid, framing_error, tx_ready;
    reg active;
    assign upload_active=active;
    reg [7:0] operation, version, session_kind, session_number, session_track;
    assign uploaded_track=session_track;
    reg [15:0] sequence_number, payload_length, packet_crc, received_crc;
    reg [2:0] header_index;
    reg [3:0] payload_index;
    reg [79:0] begin_fields;
    reg [31:0] session_size, expected_crc, file_crc, received_bytes, wait_count;
    reg [7:0] fault_status, fault_detail;
    reg writer_finish, cancel_request, last_success;
    wire writer_prepared, writer_finished, writer_committed, writer_invalidated;
    wire [7:0] writer_error;
    wire [FIFO_BITS:0] fifo_read_pointer;
    reg [FIFO_BITS:0] fifo_write_pointer;
    wire [FIFO_BITS:0] fifo_used=fifo_write_pointer-fifo_read_pointer;
    wire [FIFO_BITS-1:0] fifo_address;
    reg [7:0] fifo_read_data;
    reg [7:0] fifo[0:FIFO_BYTES-1];
    wire raw_byte=active && rx_valid && (state==RAW || (state==ARMED && rx_data!=8'ha5));
    wire fifo_push=raw_byte && fault_status==0 && fifo_used<FIFO_BYTES;
    always @(posedge clk) begin
        if(fifo_push)fifo[fifo_write_pointer[FIFO_BITS-1:0]]<=rx_data;
        fifo_read_data<=fifo[fifo_address];
    end
    wire [87:0] requested_name;
    wire marimba, score_ready, score_complete;
    wire [3:0] score_error;
    wire last_byte=raw_byte && received_bytes+1==session_size;
    reg [79:0] response_head;
    reg [95:0] response;
    reg [15:0] response_crc;
    reg [3:0] response_index;
    reg [47:0] ping_response;
    reg [2:0] ping_index;
    wire [7:0] tx_data = state==PING_SEND ? ping_response[(5-ping_index)*8+:8] :
        response[response_index*8+:8];
    uart_rx #(.CLK_HZ(CLK_HZ),.BAUD(BAUD)) receiver(
        .clk(clk),.rst_n(reset_n),.rx(rx),.data(rx_data),.valid(rx_valid),.framing_error(framing_error));
    uart_tx #(.CLK_HZ(CLK_HZ),.BAUD(BAUD)) transmitter(
        .clk(clk),.rst_n(reset_n),.data(tx_data),
        .valid(state==RESPONSE_SEND || state==PING_SEND),.ready(tx_ready),.tx(tx));
    score_file_name names(.track(session_track),.file_name(requested_name),.marimba(marimba),.numbered());
    wire [7:0] slot_index=session_track-8'd4;
    fixed_slot_writer #(.FIFO_BITS(FIFO_BITS),.SD_POWER_WAIT_CYCLES(SD_POWER_WAIT_CYCLES),
        .SD_HALF_DIV(SD_HALF_DIV)) writer(
        .clk(clk),.rst_n(reset_n && active),.slot_index(slot_index),.file_name(requested_name),
        .file_size(session_size),.file_crc(expected_crc),.fifo_used(fifo_used),
        .fifo_read_pointer(fifo_read_pointer),.fifo_address(fifo_address),.fifo_data(fifo_read_data),
        .finish(writer_finish),.cancel(cancel_request || fault_status!=0),
        .prepared(writer_prepared),.finished(writer_finished),.committed(writer_committed),
        .invalidated(writer_invalidated),.error(writer_error),
        .sd_cs_n(sd_cs_n),.sd_sck(sd_sck),.sd_mosi(sd_mosi),.sd_miso(sd_miso));
    piano_score_reader #(.DYNAMIC_FORMAT(1)) validator(
        .clk(clk),.rst_n(reset_n && active),.marimba_format(marimba),
        .data(rx_data),.valid(raw_byte),.ready(score_ready),.file_found(1'b1),
        .file_size(session_size),.file_done(last_byte),.event_data(),.event_valid(),
        .event_ready(1'b1),.format_ok(),.complete(score_complete),.error_code(score_error));
    function [15:0] crc16;
        input [15:0] previous;
        input [7:0] value;
        reg [15:0] work;
        integer i;
        begin
            work=previous^{value,8'd0};
            for(i=0;i<8;i=i+1)work=work[15] ? (work<<1)^16'h1021 : work<<1;
            crc16=work;
        end
    endfunction
    function [31:0] crc32;
        input [31:0] previous;
        input [7:0] value;
        reg [31:0] work;
        integer i;
        begin
            work=previous^{24'd0,value};
            for(i=0;i<8;i=i+1)work=work[0] ? (work>>1)^32'hedb88320 : work>>1;
            crc32=work;
        end
    endfunction
    task reply;
        input [7:0] status, detail;
        input [3:0] resume;
        begin
            response_head<={16'd0,detail,status,sequence_number,operation,8'd2,16'ha55a};
            response_crc<=0;response_index<=0;after_response<=resume;state<=RESPONSE_CRC;
        end
    endtask
    task abort_upload;
        input [7:0] status, detail;
        begin
            fault_status<=status;fault_detail<=detail;cancel_request<=1;state<=WAIT_CANCEL;
        end
    endtask
    wire [3:0] control_resume=active && received_bytes==0 ? ARMED : SYNC_A;
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n)begin
            state<=SYNC_A;after_response<=SYNC_A;active<=0;upload_complete<=0;upload_invalidated<=0;
            operation<=0;version<=0;session_kind<=0;session_number<=0;session_track<=0;
            sequence_number<=0;payload_length<=0;packet_crc<=0;received_crc<=0;
            header_index<=0;payload_index<=0;begin_fields<=0;session_size<=0;expected_crc<=0;
            file_crc<=32'hffffffff;received_bytes<=0;wait_count<=0;fault_status<=0;fault_detail<=0;
            writer_finish<=0;cancel_request<=0;last_success<=0;fifo_write_pointer<=0;
            response_head<=0;response<=0;response_crc<=0;response_index<=0;
            ping_response<="PONG\015\012";ping_index<=0;
        end else begin
            writer_finish<=0;cancel_request<=0;upload_complete<=0;upload_invalidated<=writer_invalidated;
            if(rx_valid || state==PREPARE || state==WAIT_FINISH || state==WAIT_CANCEL ||
                state>=RESPONSE_CRC)wait_count<=0;
            else if(active || state!=SYNC_A)wait_count<=wait_count+1'b1;
            if(active && fault_status==0)begin
                if(framing_error && (state==RAW || state==ARMED))begin fault_status<=12;fault_detail<=0;end
                else if(raw_byte && fifo_used>=FIFO_BYTES)begin fault_status<=11;fault_detail<=0;end
                else if(score_error!=0 || (raw_byte && !score_ready))begin fault_status<=7;fault_detail<={4'd0,score_error};end
                else if(writer_finished && writer_error!=0)begin fault_status<=8;fault_detail<=writer_error;end
            end
            if(raw_byte)begin
                received_bytes<=received_bytes+1'b1;file_crc<=crc32(file_crc,rx_data);
                if(fifo_push)fifo_write_pointer<=fifo_write_pointer+1'b1;
            end
            if((state==SYNC_B || state==HEADER || state==PAYLOAD || state==CRC_LOW || state==CRC_HIGH ||
                state==PING_I || state==PING_N || state==PING_G) &&
                (framing_error || wait_count>=PACKET_TIMEOUT_CYCLES-1))begin
                state<=control_resume;wait_count<=0;
            end else if(active && (state==SYNC_A || state==ARMED || state==RAW) &&
                wait_count>=SESSION_TIMEOUT_CYCLES-1)begin
                operation<=4;sequence_number<=0;
                abort_upload(fault_status!=0 ? fault_status : 8'd10,fault_detail);wait_count<=0;
            end else case(state)
                SYNC_A:if(rx_valid)begin
                    if(rx_data==8'ha5)begin packet_crc<=crc16(0,rx_data);state<=SYNC_B;end
                    else if(rx_data=="P")state<=PING_I;
                end
                SYNC_B:if(rx_valid)begin
                    if(rx_data==8'h5a)begin packet_crc<=crc16(packet_crc,rx_data);header_index<=0;state<=HEADER;end
                    else if(rx_data==8'ha5)packet_crc<=crc16(0,rx_data);
                    else state<=control_resume;
                end
                HEADER:if(rx_valid)begin
                    packet_crc<=crc16(packet_crc,rx_data);
                    case(header_index)
                        0:version<=rx_data;
                        1:operation<=rx_data;
                        2:sequence_number[7:0]<=rx_data;
                        3:sequence_number[15:8]<=rx_data;
                        4:payload_length[7:0]<=rx_data;
                        5:payload_length[15:8]<=rx_data;
                    endcase
                    if(header_index==5)begin
                        payload_index<=0;
                        if({rx_data,payload_length[7:0]}>10)reply(2,0,control_resume);
                        else state<={rx_data,payload_length[7:0]}==0 ? CRC_LOW : PAYLOAD;
                    end else header_index<=header_index+1'b1;
                end
                PAYLOAD:if(rx_valid)begin
                    packet_crc<=crc16(packet_crc,rx_data);
                    begin_fields[payload_index*8+:8]<=rx_data;
                    if({12'd0,payload_index}+1==payload_length)state<=CRC_LOW;
                    else payload_index<=payload_index+1'b1;
                end
                CRC_LOW:if(rx_valid)begin received_crc[7:0]<=rx_data;state<=CRC_HIGH;end
                CRC_HIGH:if(rx_valid)begin
                    received_crc[15:8]<=rx_data;
                    if({rx_data,received_crc[7:0]}!=packet_crc)reply(1,0,control_resume);
                    else state<=DISPATCH;
                end
                DISPATCH:begin
                    if(version!=2 || sequence_number!=0)reply(2,0,control_resume);
                    else case(operation)
                        1:begin
                            if(payload_length!=10 || begin_fields[7:0]<1 || begin_fields[7:0]>2 ||
                                begin_fields[15:8]<1 || begin_fields[15:8]>100 ||
                                begin_fields[47:16]<24 || begin_fields[47:16]>MAX_FILE_BYTES ||
                                begin_fields[18:16]!=0)reply(2,0,control_resume);
                            else if(active)begin
                                if(received_bytes==0 && writer_prepared &&
                                    session_kind==begin_fields[7:0] && session_number==begin_fields[15:8] &&
                                    session_size==begin_fields[47:16] && expected_crc==begin_fields[79:48])
                                    reply(0,0,ARMED);
                                else reply(5,0,control_resume);
                            end else begin
                                active<=1;session_kind<=begin_fields[7:0];session_number<=begin_fields[15:8];
                                session_track<=begin_fields[7:0]==1 ? begin_fields[15:8]+8'd3 : begin_fields[15:8]+8'd103;
                                session_size<=begin_fields[47:16];expected_crc<=begin_fields[79:48];
                                file_crc<=32'hffffffff;received_bytes<=0;fifo_write_pointer<=0;
                                fault_status<=0;fault_detail<=0;last_success<=0;state<=PREPARE;
                            end
                        end
                        3:begin
                            if(payload_length!=0)reply(2,0,control_resume);
                            else if(!active)reply(last_success ? 0 : 4,0,SYNC_A);
                            else if(received_bytes!=session_size)reply(3,0,control_resume);
                            else if(fault_status!=0)abort_upload(fault_status,fault_detail);
                            else if((~file_crc)!=expected_crc)abort_upload(6,0);
                            else if(!score_complete || score_error!=0)abort_upload(7,{4'd0,score_error});
                            else begin writer_finish<=1;state<=WAIT_FINISH;end
                        end
                        4:begin
                            if(payload_length!=0)reply(2,0,control_resume);
                            else if(!active)reply(4,0,SYNC_A);
                            else abort_upload(9,0);
                        end
                        default:reply(2,0,control_resume);
                    endcase
                end
                PREPARE:begin
                    if(writer_finished)begin active<=0;reply(8,writer_error,SYNC_A);end
                    else if(writer_prepared)reply(0,0,ARMED);
                end
                ARMED:if(rx_valid)begin
                    if(rx_data==8'ha5)begin packet_crc<=crc16(0,rx_data);state<=SYNC_B;end
                    else state<=session_size==1 ? SYNC_A : RAW;
                end
                RAW:if(raw_byte && received_bytes+1==session_size)state<=SYNC_A;
                WAIT_FINISH:if(writer_finished)begin
                    active<=0;
                    if(writer_error==0 && writer_committed)begin
                        upload_complete<=1;last_success<=1;reply(0,0,SYNC_A);
                    end else reply(8,writer_error,SYNC_A);
                end
                WAIT_CANCEL:if(writer_finished)begin
                    active<=0;last_success<=0;
                    reply(writer_error!=0 ? 8'd8 : fault_status,writer_error!=0 ? writer_error : fault_detail,SYNC_A);
                end
                RESPONSE_CRC:begin
                    response_crc<=crc16(response_crc,response_head[response_index*8+:8]);
                    if(response_index==9)state<=RESPONSE_PACK;
                    else response_index<=response_index+1'b1;
                end
                RESPONSE_PACK:begin response<={response_crc,response_head};response_index<=0;state<=RESPONSE_SEND;end
                RESPONSE_SEND:if(tx_ready)begin
                    if(response_index==11)state<=after_response;
                    else response_index<=response_index+1'b1;
                end
                PING_I:if(rx_valid)begin
                    if(rx_data=="I")state<=PING_N;
                    else state<=SYNC_A;
                end
                PING_N:if(rx_valid)begin
                    if(rx_data=="N")state<=PING_G;
                    else state<=SYNC_A;
                end
                PING_G:if(rx_valid)begin
                    if(rx_data=="G")begin ping_index<=0;state<=PING_SEND;end
                    else state<=SYNC_A;
                end
                PING_SEND:if(tx_ready)begin
                    if(ping_index==5)begin ping_index<=0;state<=SYNC_A;end
                    else ping_index<=ping_index+1'b1;
                end
                default:state<=SYNC_A;
            endcase
        end
    end
endmodule
