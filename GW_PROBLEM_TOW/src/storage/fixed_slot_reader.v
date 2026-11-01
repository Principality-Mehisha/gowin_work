// Query/verify a fixed file, then expose only its actual score bytes.
module fixed_slot_reader (
    input wire clk, rst_n, scan_catalog,
    input wire [7:0] slot_index,
    input wire [87:0] file_name,
    input wire sd_ready,
    output wire sd_start,
    output wire [31:0] sd_lba,
    input wire [7:0] sd_data,
    input wire [8:0] sd_index,
    input wire sd_valid, sd_done, sd_error,
    output wire [7:0] data,
    output wire valid,
    input wire ready,
    output reg file_found, file_done, probe_done,
    output wire [31:0] file_size,
    output reg [3:0] error_code,
    output wire [199:0] catalog_mask,
    output wire catalog_done
);
    localparam QUERY=0, VERIFY_REQ=1, VERIFY_WAIT=2, VERIFY_CHECK=3,
        DATA_REQ=4, DATA_WAIT=5, RAM_WAIT=6, SEND=7, DONE=8;
    reg [3:0] state;
    wire q_start,q_done;
    wire [31:0] q_lba,file_lba,file_crc;
    wire [7:0] q_error;
    reg read_start;
    reg [31:0] read_lba, remaining, position, crc_work;
    reg [8:0] address;
    reg [7:0] sector[0:511];
    reg [7:0] memory_data;
    assign sd_start=state==QUERY ? q_start : read_start;
    assign sd_lba=state==QUERY ? q_lba : read_lba;
    assign data=memory_data;
    assign valid=state==SEND;
    always @(posedge clk) begin
        if(sd_valid && state!=QUERY)sector[sd_index]<=sd_data;
        memory_data<=sector[address];
    end
    function [31:0] crc32_byte;
        input [31:0] previous;
        input [7:0] value;
        reg [31:0] work;
        integer i;
        begin
            work=previous^{24'd0,value};
            for(i=0;i<8;i=i+1)work=work[0] ? (work>>1)^32'hedb88320 : work>>1;
            crc32_byte=work;
        end
    endfunction
    slot_card_query query(
        .clk(clk),.rst_n(rst_n),.for_write(1'b0),.scan_catalog(scan_catalog),
        .slot_index(slot_index),.file_name(file_name),
        .sd_ready(sd_ready && state==QUERY),.sd_start(q_start),.sd_lba(q_lba),
        .sd_data(sd_data),.sd_index(sd_index),.sd_valid(sd_valid),.sd_done(sd_done),.sd_error(sd_error),
        .done(q_done),.error(q_error),.catalog_mask(catalog_mask),.catalog_done(catalog_done),
        .file_lba(file_lba),.metadata_lba(),.file_size(file_size),.file_crc(file_crc));
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            state<=QUERY; read_start<=0; read_lba<=0; remaining<=0; position<=0;
            crc_work<=32'hffffffff; address<=0; file_found<=0; file_done<=0;
            probe_done<=0; error_code<=0;
        end else begin
            read_start<=0;file_done<=0;
            if(sd_valid && state==VERIFY_WAIT && {23'd0,sd_index}<remaining)
                crc_work<=crc32_byte(crc_work,sd_data);
            if(sd_error)begin error_code<=1;probe_done<=1;state<=DONE;end
            else case(state)
                QUERY: if(q_done)begin
                    if(q_error!=0)begin
                        error_code<=q_error==4 ? 4'd4 : 4'he;probe_done<=1;state<=DONE;
                    end else begin
                        remaining<=file_size;read_lba<=file_lba;crc_work<=32'hffffffff;state<=VERIFY_REQ;
                    end
                end
                VERIFY_REQ:if(sd_ready)begin read_start<=1;state<=VERIFY_WAIT;end
                VERIFY_WAIT:if(sd_done)state<=VERIFY_CHECK;
                VERIFY_CHECK:begin
                    if(remaining>512)begin remaining<=remaining-512;read_lba<=read_lba+1;state<=VERIFY_REQ;end
                    else if((~crc_work)!=file_crc)begin error_code<=6;probe_done<=1;state<=DONE;end
                    else begin
                        file_found<=1;remaining<=file_size;position<=0;read_lba<=file_lba;state<=DATA_REQ;
                    end
                end
                DATA_REQ:if(sd_ready)begin read_start<=1;state<=DATA_WAIT;end
                DATA_WAIT:if(sd_done)begin address<=0;state<=RAM_WAIT;end
                RAM_WAIT:state<=SEND;
                SEND:if(ready)begin
                    position<=position+1;remaining<=remaining-1;
                    if(remaining==1)begin file_done<=1;probe_done<=1;state<=DONE;end
                    else if(address==511)begin read_lba<=read_lba+1;state<=DATA_REQ;end
                    else begin address<=address+1'b1;state<=RAM_WAIT;end
                end
                DONE:state<=DONE;
                default:begin error_code<=15;probe_done<=1;state<=DONE;end
            endcase
        end
    end
endmodule
