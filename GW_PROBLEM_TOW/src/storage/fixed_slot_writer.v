// Destructive overwrite of one preallocated 100 KiB file. Only data and one
// private metadata sector are written; the FAT and directory are read-only.
module fixed_slot_writer #(
    parameter integer FIFO_BITS=15,
    parameter integer SD_POWER_WAIT_CYCLES=500000,
    parameter integer SD_HALF_DIV=63
) (
    input wire clk, rst_n,
    input wire [7:0] slot_index,
    input wire [87:0] file_name,
    input wire [31:0] file_size, file_crc,
    input wire [FIFO_BITS:0] fifo_used,
    output reg [FIFO_BITS:0] fifo_read_pointer,
    output wire [FIFO_BITS-1:0] fifo_address,
    input wire [7:0] fifo_data,
    input wire finish, cancel,
    output reg prepared, finished, committed, invalidated,
    output reg [7:0] error,
    output wire sd_cs_n, sd_sck, sd_mosi,
    input wire sd_miso
);
    localparam QUERY=0, INVALIDATE=1, WAIT_INVALIDATE=2, CLEAR=3, WAIT_CLEAR=4,
        RECEIVE=5, WAIT_DATA=6, DRAINED=7, META_CRC=8, COMMIT=9, WAIT_COMMIT=10, DONE=11;
    reg [3:0] state;
    reg [1:0] source;
    reg [7:0] clear_sector;
    reg [31:0] written_bytes, write_lba, metadata_crc, crc_work;
    reg [4:0] crc_index;
    reg [9:0] block_bytes;
    reg write_start, cancel_pending, commit_pending;
    wire host_ready, host_error, host_read_done, host_write_done, host_valid;
    wire [3:0] host_error_code;
    wire [7:0] host_data;
    wire [8:0] host_index, write_index;
    wire query_start, query_done;
    wire [31:0] query_lba, file_lba, metadata_lba;
    wire [7:0] query_error;
    wire [31:0] remaining=file_size-written_bytes;
    wire [9:0] next_bytes=remaining>=512 ? 10'd512 : remaining[9:0];
    assign fifo_address=fifo_read_pointer[FIFO_BITS-1:0]+write_index;
    function [7:0] metadata_byte;
        input [4:0] index;
        reg [31:0] value;
        begin
            case(index[4:2])
                0:value=32'h4c535747;
                1:value=32'h3230544f;
                2:value=2;
                3:value={24'd0,slot_index};
                4:value=file_size;
                5:value=file_crc;
                6:value=32'ha55aa55a;
                default:value=metadata_crc;
            endcase
            metadata_byte=value[index[1:0]*8+:8];
        end
    endfunction
    function [31:0] crc32_byte;
        input [31:0] previous;
        input [7:0] value;
        reg [31:0] work;
        integer i;
        begin
            work=previous^{24'd0,value};
            for(i=0;i<8;i=i+1) work=work[0] ? (work>>1)^32'hedb88320 : work>>1;
            crc32_byte=work;
        end
    endfunction
    wire [7:0] write_data=source==1 ? (write_index<block_bytes ? fifo_data : 8'd0) :
        (source==2 && write_index<32 ? metadata_byte(write_index[4:0]) : 8'd0);
    slot_card_query query(
        .clk(clk),.rst_n(rst_n),.for_write(1'b1),.scan_catalog(1'b0),
        .slot_index(slot_index),.file_name(file_name),
        .sd_ready(host_ready && state==QUERY),.sd_start(query_start),.sd_lba(query_lba),
        .sd_data(host_data),.sd_index(host_index),.sd_valid(host_valid),
        .sd_done(host_read_done),.sd_error(host_error),
        .done(query_done),.error(query_error),.catalog_mask(),.catalog_done(),
        .file_lba(file_lba),.metadata_lba(metadata_lba),.file_size(),.file_crc());
    sd_spi_reader #(.POWER_WAIT_CYCLES(SD_POWER_WAIT_CYCLES),
        .INIT_HALF_DIV(SD_HALF_DIV),.READ_HALF_DIV(SD_HALF_DIV)) host(
        .clk(clk),.rst_n(rst_n),.read_start(state==QUERY && query_start),.read_lba(query_lba),
        .read_ready(host_ready),.busy(),.initialized(),.high_capacity(),
        .data(host_data),.data_index(host_index),.data_valid(host_valid),.data_ready(1'b1),
        .read_done(host_read_done),.error_pulse(host_error),.error_code(host_error_code),
        .debug_failure(),.sd_cs_n(sd_cs_n),.sd_sck(sd_sck),.sd_mosi(sd_mosi),.sd_miso(sd_miso),
        .write_start(write_start),.write_lba(write_lba),.write_index(write_index),
        .write_data(write_data),.write_done(host_write_done));
    task fail;
        input [7:0] code;
        begin error<=code; prepared<=0; finished<=1; state<=DONE; end
    endtask
    task cancelled;
        begin prepared<=0; finished<=1; state<=DONE; end
    endtask
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state<=QUERY; source<=0; clear_sector<=0; written_bytes<=0; write_lba<=0;
            metadata_crc<=0; crc_work<=32'hffffffff; crc_index<=0; block_bytes<=0;
            write_start<=0; cancel_pending<=0; commit_pending<=0; fifo_read_pointer<=0;
            prepared<=0; finished<=0; committed<=0; invalidated<=0; error<=0;
        end else begin
            write_start<=0; invalidated<=0;
            if(cancel)cancel_pending<=1;
            if(finish)commit_pending<=1;
            if(host_error && state!=DONE)fail({4'h1,host_error_code});
            else case(state)
                QUERY: if(query_done) begin
                    if(query_error!=0)fail(query_error);
                    else if(file_size<24 || file_size>102400 || file_size[2:0]!=0)fail(8'h26);
                    else if(cancel || cancel_pending)cancelled();
                    else state<=INVALIDATE;
                end
                INVALIDATE: if(host_ready) begin
                    if(cancel || cancel_pending)cancelled();
                    else begin
                        source<=0; write_lba<=metadata_lba; write_start<=1; state<=WAIT_INVALIDATE;
                    end
                end
                WAIT_INVALIDATE: if(host_write_done) begin
                    invalidated<=1; clear_sector<=0; state<=CLEAR;
                end
                CLEAR: if(host_ready) begin
                    if(cancel || cancel_pending)cancelled();
                    else begin
                        source<=0; write_lba<=file_lba+{24'd0,clear_sector};
                        write_start<=1; state<=WAIT_CLEAR;
                    end
                end
                WAIT_CLEAR: if(host_write_done) begin
                    if(clear_sector==199) begin prepared<=1; state<=RECEIVE; end
                    else begin clear_sector<=clear_sector+1'b1; state<=CLEAR; end
                end
                RECEIVE: begin
                    if(cancel || cancel_pending)cancelled();
                    else if(written_bytes==file_size) begin prepared<=0; state<=DRAINED; end
                    else if(host_ready && fifo_used>=next_bytes) begin
                        block_bytes<=next_bytes; source<=1;
                        write_lba<=file_lba+(written_bytes>>9); write_start<=1; state<=WAIT_DATA;
                    end
                end
                WAIT_DATA: if(host_write_done) begin
                    fifo_read_pointer<=fifo_read_pointer+block_bytes;
                    written_bytes<=written_bytes+{22'd0,block_bytes}; state<=RECEIVE;
                end
                DRAINED: begin
                    if(cancel || cancel_pending)cancelled();
                    else if(finish || commit_pending) begin
                        crc_work<=32'hffffffff; crc_index<=0; state<=META_CRC;
                    end
                end
                META_CRC: begin
                    crc_work<=crc32_byte(crc_work,metadata_byte(crc_index));
                    if(crc_index==27) begin
                        metadata_crc<=~crc32_byte(crc_work,metadata_byte(crc_index)); state<=COMMIT;
                    end else crc_index<=crc_index+1'b1;
                end
                COMMIT: if(host_ready) begin
                    if(cancel || cancel_pending)cancelled();
                    else begin source<=2; write_lba<=metadata_lba; write_start<=1; state<=WAIT_COMMIT; end
                end
                WAIT_COMMIT: if(host_write_done) begin
                    committed<=1; finished<=1; state<=DONE;
                end
                DONE: state<=DONE;
                default:fail(8'h2f);
            endcase
        end
    end
endmodule
