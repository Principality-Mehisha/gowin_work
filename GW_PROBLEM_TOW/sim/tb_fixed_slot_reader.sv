`timescale 1ns/1ps
module tb_fixed_slot_reader;
    `include "../output/fixed_slots/layout.vh"
    reg passed=0,clk=0,rst_n=0,scan=0,ready=0;
    always #10 clk=~clk;
    reg [7:0] slot=0,sd_data=0;
    reg [8:0] sd_index=0;
    reg sd_ready=0,sd_valid=0,sd_done=0;
    wire sd_start,valid,found,done,probe,catalog_done;
    wire [31:0] sd_lba,size;
    wire [7:0] data;
    wire [3:0] error;
    wire [199:0] catalog;
    wire [87:0] name;
    score_file_name names(.track(slot+8'd4),.file_name(name),.marimba(),.numbered());
    fixed_slot_reader dut(
        .clk(clk),.rst_n(rst_n),.catalog_only(1'b0),.scan_catalog(scan),
        .slot_index(slot),.file_name(name),.sd_ready(sd_ready),.sd_start(sd_start),.sd_lba(sd_lba),
        .sd_data(sd_data),.sd_index(sd_index),.sd_valid(sd_valid),.sd_done(sd_done),.sd_error(1'b0),
        .data(data),.valid(valid),.ready(ready),.file_found(found),.file_done(done),.probe_done(probe),
        .file_size(size),.error_code(error),.catalog_mask(catalog),.catalog_done(catalog_done));
    reg [7:0] image[0:33554431];
    integer observed=0,eof_count=0,catalog_pulses=0,limit=0;
    reg [15:0] random_bits=16'h1234;
    always @(negedge clk)begin
        random_bits={random_bits[14:0],random_bits[15]^random_bits[13]^random_bits[12]^random_bits[10]};
        ready=random_bits[0] || random_bits[3];
    end
    always @(posedge clk)if(rst_n)begin
        if(catalog_done)catalog_pulses=catalog_pulses+1;
        if(done)eof_count=eof_count+1;
        if(valid && ready)begin
            if(observed>=limit || data!==image[(FIX_SLOT_BASE+slot*256)*512+observed])
                $fatal(1,"Reader byte mismatch/extra padding at %0d",observed);
            observed=observed+1;
        end
    end
    initial forever begin : sector_source
        integer lba;
        @(posedge clk);
        if(sd_start && sd_ready)begin
            lba=sd_lba;
            @(negedge clk);sd_ready=0;
            for(integer p=0;p<512;p=p+1)begin
                sd_data=image[lba*512+p];sd_index=p;sd_valid=1;@(negedge clk);
            end
            sd_valid=0;repeat(3)@(negedge clk);sd_done=1;
            @(negedge clk);sd_done=0;sd_ready=1;
        end
    end
    function [31:0] crc32(input [31:0] previous,input [7:0] value);
        reg [31:0] result;
        begin
            result=previous;
            for(integer b=0;b<8;b=b+1)result=(result>>1)^((result[0]^value[b]) ? 32'hedb88320 : 0);
            crc32=result;
        end
    endfunction
    task run_case(input integer index,input integer bytes,input integer expected_error,input bit full_scan=0);
        integer timeout;
        begin
            rst_n=0;repeat(5)@(negedge clk);
            slot=index;scan=full_scan;limit=bytes;observed=0;eof_count=0;catalog_pulses=0;
            sd_ready=1;rst_n=1;timeout=0;
            while(!probe && timeout<1000000)begin @(negedge clk);timeout=timeout+1;end
            repeat(5)@(negedge clk);
            if(!probe || error!=expected_error || observed!=bytes || eof_count!=(bytes!=0))
                $fatal(1,"Read case slot=%0d err=%0d bytes=%0d EOF=%0d",index,error,observed,eof_count);
            if(full_scan && (catalog!=200'd3 || catalog_pulses!=1))$fatal(1,"Catalog validity/pulse mismatch");
        end
    endtask
    integer i,base,meta;
    reg [31:0] checksum,record_crc;
    initial begin
        for(i=0;i<33554432;i=i+1)image[i]=0;
        $readmemh("output/fixed_slots/card.hex",image);
        run_case(0,32,0,1);
        run_case(1,32,0);
        run_case(199,0,4);
        image[FIX_SLOT_BASE*512+21]=image[FIX_SLOT_BASE*512+21]^1;
        run_case(0,0,6);
        image[FIX_SLOT_BASE*512+21]=image[FIX_SLOT_BASE*512+21]^1;
        image[8*512+28]=image[8*512+28]^1;run_case(0,0,4);
        image[8*512+28]=image[8*512+28]^1;
        image[2080*512+12]=5;run_case(0,0,14);image[2080*512+12]=4;
        image[FIX_DATA_BASE*512+11]=8'h21;run_case(0,32,0);
        base=(FIX_SLOT_BASE+199*256)*512;meta=(8+199)*512;checksum=32'hffffffff;
        for(i=0;i<102400;i=i+1)begin
            image[base+i]=(i*37)^(i>>8);checksum=crc32(checksum,image[base+i]);
        end
        checksum=~checksum;
        for(i=0;i<512;i=i+1)image[meta+i]=image[8*512+i];
        for(i=0;i<4;i=i+1)begin
            image[meta+12+i]=199>>(i*8);image[meta+16+i]=102400>>(i*8);image[meta+20+i]=checksum>>(i*8);
        end
        record_crc=32'hffffffff;
        for(i=0;i<28;i=i+1)record_crc=crc32(record_crc,image[meta+i]);
        record_crc=~record_crc;
        for(i=0;i<4;i=i+1)image[meta+28+i]=record_crc>>(i*8);
        run_case(199,102400,0);
        passed=1;$display("PASS fixed reader: exact 32/102400 bytes, randomized backpressure, EOF, CRC-before-output and catalog pulse");
        $finish;
    end
    initial begin #50000000;$fatal(1,"Fixed reader watchdog");end
endmodule
