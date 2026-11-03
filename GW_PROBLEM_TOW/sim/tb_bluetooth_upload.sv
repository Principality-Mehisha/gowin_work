`timescale 1ns/1ps
module GSR(input wire GSRI); wire GSRO=GSRI; endmodule

module fixed_slot_case #(parameter integer SMALL_FIFO=0, RESET_ONLY=0)(output reg passed=0);
    `include "../output/fixed_slots/layout.vh"
    localparam TICKS=8, BIT_NS=20*TICKS;
    reg clk=0, key=0, bt_rx=1, screen_rx=1, card_reset=0;
    always #10 clk=~clk;
    wire bt_tx, cs, sck, mosi, miso;
    reg [3:0] fault=0;
    GW_PROBLEM_TOW #(.VIDEO_ENABLE(0)) dut(
        .sys_clk(clk),.KEY0(1'b1),.KEY1(1'b1),.KEY2(key),
        .uart_rx(screen_rx),.uart_tx(),.bt_rx(bt_rx),.bt_tx(bt_tx),
        .HP_BCK(),.HP_WS(),.HP_DIN(),.PA_EN(),.sd_cs_n(cs),.sd_sck(sck),
        .sd_mosi(mosi),.sd_miso(miso),.LEDs(),.tmds_data_p(),.tmds_data_n(),
        .tmds_clk_p(),.tmds_clk_n());
    defparam dut.score_player.POWER_ON_CYCLES=8;
    defparam dut.score_player.UART_CLK_HZ=800000;
    defparam dut.score_player.UART_BAUD=100000;
    defparam dut.score_player.UART_TIMEOUT_CYCLES=10000;
    defparam dut.score_player.SD_POWER_WAIT_CYCLES=4;
    defparam dut.score_player.SD_INIT_HALF_DIV=1;
    defparam dut.score_player.SD_READ_HALF_DIV=1;
    defparam dut.score_player.CLOCKS_PER_MS=500;
    defparam dut.bluetooth_upload.CLK_HZ=800000;
    defparam dut.bluetooth_upload.BAUD=100000;
    defparam dut.bluetooth_upload.FIFO_BITS=SMALL_FIFO ? 9 : 15;
    defparam dut.bluetooth_upload.SD_POWER_WAIT_CYCLES=4;
    defparam dut.bluetooth_upload.SD_HALF_DIV=1;
    defparam dut.bluetooth_upload.PACKET_TIMEOUT_CYCLES=5000;
    defparam dut.bluetooth_upload.SESSION_TIMEOUT_CYCLES=30000;
    defparam dut.bluetooth_upload.writer.host.WRITE_TIMEOUT_CYCLES=100000;
    sd_card_model #(.IMAGE_FILE("output/fixed_slots/card.hex"),.IMAGE_BYTES(33554432),.WRITABLE(1)) card(
        .rst_n(card_reset),.cs_n(cs),.sck(sck),.mosi(mosi),.miso(miso),
        .profile(2'd2),.fault(fault),.last_argument(),.read_commands(),.cmd16_seen());
    reg [7:0] content[0:102399], packet_data[0:9], replies[0:4095];
    integer reply_count=0, checked=0, size, target=0, i, j, saved, events=0;
    integer seen_writes=0, invalidations=0;
    reg [31:0] checksum;
    reg [7:0] detail, saved_byte;
    always @(posedge clk)begin
        if(dut.score_player.system.synth_event_valid && dut.score_player.system.synth_event_ready)events=events+1;
        if(dut.upload_invalidated)invalidations=invalidations+1;
    end
    // No upload is permitted to write FAT, root directory, descriptor or neighbours.
    always @(negedge sck)if(card.write_commands!=seen_writes)begin
        seen_writes=card.write_commands;
        if(card.write_lba!=8+target &&
            !(card.write_lba>=FIX_SLOT_BASE+target*256 && card.write_lba<FIX_SLOT_BASE+target*256+200))
            $fatal(1,"Write escaped selected slot: LBA %0d target %0d",card.write_lba,target);
    end
    initial forever begin : decode
        reg [7:0] value;
        @(negedge bt_tx); #(BIT_NS/2);
        if(bt_tx!==0)$fatal(1,"Reply start bit");
        for(integer bit_index=0;bit_index<8;bit_index=bit_index+1)begin
            #(BIT_NS);value[bit_index]=bt_tx;
        end
        #(BIT_NS);
        if(bt_tx!==1)$fatal(1,"Reply stop bit");
        replies[reply_count]=value;reply_count=reply_count+1;
    end
    function [15:0] crc16(input [15:0] previous,input [7:0] value);
        reg [15:0] result;
        begin
            result=previous;
            for(integer b=7;b>=0;b=b-1)result=(result<<1)^((result[15]^value[b]) ? 16'h1021 : 0);
            crc16=result;
        end
    endfunction
    function [31:0] crc32(input [31:0] previous,input [7:0] value);
        reg [31:0] result;
        begin
            result=previous;
            for(integer b=0;b<8;b=b+1)result=(result>>1)^((result[0]^value[b]) ? 32'hedb88320 : 0);
            crc32=result;
        end
    endfunction
    function [31:0] word32(input integer address);
        word32={card.image[address+3],card.image[address+2],card.image[address+1],card.image[address]};
    endfunction
    task send_byte(input [7:0] value,input bit screen=0,input bit bad_stop=0);
        begin
            if(screen)screen_rx=0;else bt_rx=0;#(BIT_NS);
            for(integer b=0;b<8;b=b+1)begin
                if(screen)screen_rx=value[b];else bt_rx=value[b];#(BIT_NS);
            end
            if(screen)screen_rx=1;else bt_rx=!bad_stop;#(BIT_NS);
            if(bad_stop)begin bt_rx=1;#(BIT_NS);end
        end
    endtask
    task send_packet(input integer op,input integer count,input bit corrupt=0,input integer version=2);
        reg [15:0] crc;
        reg [7:0] value;
        begin
            crc=0;
            for(integer p=0;p<8+count;p=p+1)begin
                case(p)
                    0:value=8'ha5;1:value=8'h5a;2:value=version;3:value=op;
                    4,5:value=0;6:value=count;7:value=0;
                    default:value=packet_data[p-8];
                endcase
                crc=crc16(crc,value);send_byte(value);
            end
            send_byte(crc[7:0]^(corrupt ? 1 : 0));send_byte(crc[15:8]);
        end
    endtask
    task expect_reply(input integer op,input integer status);
        reg [15:0] crc;
        integer timeout;
        begin
            timeout=0;
            while(reply_count<checked+12 && timeout<10000000)begin @(posedge clk);timeout=timeout+1;end
            if(reply_count<checked+12)$fatal(1,"Reply timeout op=%0d rx=%0d writer=%0d query=%0d host=%0d lba=%0d",
                op,dut.bluetooth_upload.state,dut.bluetooth_upload.writer.state,
                dut.bluetooth_upload.writer.query.state,dut.bluetooth_upload.writer.host.state,
                dut.bluetooth_upload.writer.query.sd_lba);
            crc=0;
            for(integer p=0;p<10;p=p+1)crc=crc16(crc,replies[checked+p]);
            if(replies[checked]!=8'h5a || replies[checked+1]!=8'ha5 || replies[checked+2]!=2 ||
                replies[checked+3]!=op || {replies[checked+5],replies[checked+4]}!=0 ||
                {replies[checked+9],replies[checked+8]}!=0 ||
                {replies[checked+11],replies[checked+10]}!=crc)$fatal(1,"Malformed response");
            detail=replies[checked+7];
            if(replies[checked+6]!=status)$fatal(1,"Status=%0d expected=%0d detail=%h op=%0d rx=%0d",
                replies[checked+6],status,detail,op,dut.bluetooth_upload.state);
            checked=checked+12;
        end
    endtask
    task make_score(input integer bytes,input bit marimba=0);
        integer count;
        reg [31:0] timestamp;
        begin
            size=bytes;count=(bytes-16)/8;
            for(integer p=0;p<bytes;p=p+1)content[p]=0;
            content[0]=marimba ? "M" : "P";content[1]=marimba ? "4" : "8";
            content[2]=marimba ? "2" : "8";content[3]="S";
            content[4]=1;content[5]=8;content[6]=8;content[8]=8'he8;content[9]=3;
            for(integer b=0;b<4;b=b+1)content[12+b]=count>>(b*8);
            for(integer r=0;r<count;r=r+1)begin
                timestamp=r<2 ? r*100 : 32'h00005aa5+(r-2)*100;
                for(integer b=0;b<4;b=b+1)content[16+r*8+b]=timestamp>>(b*8);
                content[16+r*8+5]=marimba ? 60 : 39;content[16+r*8+6]=r%2==0 ? 100 : 0;
            end
            content[bytes-4]=255;content[bytes-3]=255;content[bytes-2]=0;
            checksum=32'hffffffff;
            for(integer p=0;p<bytes;p=p+1)checksum=crc32(checksum,content[p]);
            checksum=~checksum;
        end
    endtask
    task set_begin(input integer kind,input integer number,input bit bad_crc=0);
        begin
            target=number-1+(kind==2 ? 100 : 0);
            packet_data[0]=kind;packet_data[1]=number;
            for(integer b=0;b<4;b=b+1)begin
                packet_data[2+b]=size>>(b*8);packet_data[6+b]=checksum>>(b*8);
            end
            if(bad_crc)packet_data[6]=packet_data[6]^1;
        end
    endtask
    task begin_upload(input integer kind,input integer number,input bit bad_crc=0);
        integer writes;
        begin
            set_begin(kind,number,bad_crc);writes=card.write_commands;
            send_packet(1,10);expect_reply(1,0);
            if(card.write_commands!=writes+201)$fatal(1,"READY before metadata invalidation + 200 clear writes");
            for(integer p=0;p<102400;p=p+1)
                if(card.image[(FIX_SLOT_BASE+target*256)*512+p]!==0)$fatal(1,"Not zero before READY offset=%0d",p);
            for(integer p=0;p<512;p=p+1)
                if(card.image[(8+target)*512+p]!==0)$fatal(1,"Old metadata survived READY");
        end
    endtask
    task send_content;
        integer replies_before;
        begin
            if(size>=40 && {content[33],content[32]}!=16'h5aa5)$fatal(1,"Fixture lacks embedded raw sync bytes");
            replies_before=reply_count;
            for(integer p=0;p<size;p=p+1)send_byte(content[p]);
            if(reply_count!=replies_before)$fatal(1,"Unexpected ACK during raw DATA");
        end
    endtask
    task check_file(input integer index);
        integer cluster_number,address,position;
        begin
            address=FIX_DATA_BASE*512+index*32;
            if(word32(address+28)!=102400)$fatal(1,"Normal FAT file must retain 100 KiB size");
            cluster_number={card.image[address+21],card.image[address+20],card.image[address+27],card.image[address+26]};
            position=0;
            // Independent FAT traversal, not the receiver's fixed-address formula.
            repeat(4)begin
                for(integer p=0;p<32768 && position<102400;p=p+1)begin
                    if(card.image[(FIX_DATA_BASE+(cluster_number-2)*64)*512+p]!==
                        (position<size ? content[position] : 8'd0))$fatal(1,"FAT file data mismatch offset=%0d",position);
                    position=position+1;
                end
                if(word32(2080*512+cluster_number*4)!=word32((2080+FIX_FAT_SECTORS)*512+cluster_number*4))
                    $fatal(1,"FAT copies differ");
                cluster_number=word32(2080*512+cluster_number*4)&32'h0fffffff;
            end
            if(cluster_number<32'h0ffffff8)$fatal(1,"No FAT EOC");
            if(word32((8+index)*512+16)!=size || word32((8+index)*512+20)!=checksum ||
                word32((8+index)*512+24)!=32'ha55aa55a)$fatal(1,"Actual length/CRC/valid metadata");
        end
    endtask
    task screen_command(input integer command,input integer p0,input integer p1);
        begin
            send_byte('ha5,1);send_byte('h5a,1);send_byte(1,1);send_byte(0,1);
            send_byte(command,1);send_byte(p0,1);send_byte(p1,1);send_byte(0,1);
            send_byte((1+command+p0+p1)&255,1);send_byte('h0d,1);
        end
    endtask
    task play(input integer kind,input integer number);
        integer timeout;
        begin
            saved=events;screen_command('h12,kind,number);timeout=0;
            while(events==saved && timeout<10000000)begin @(posedge clk);timeout=timeout+1;end
            if(events==saved || dut.score_player.selected_track!=number+(kind==1 ? 3 : 103))
                $fatal(1,"Numbered playback failed kind=%0d number=%0d err=%h fat=%h score=%h",
                    kind,number,dut.score_player.last_error,dut.score_player.fat_error,dut.score_player.score_error);
            screen_command('h11,0,0);repeat(200)@(posedge clk);
        end
    endtask
    initial begin : run_cases
        repeat(8)@(posedge clk);key=1;card_reset=1;repeat(32)@(posedge clk);
        if(RESET_ONLY)begin
            make_score(1032);begin_upload(1,1);
            for(i=0;i<520;i=i+1)send_byte(content[i]);
            key=0;repeat(16)@(posedge clk);key=1;repeat(32)@(posedge clk);
            if(word32(8*512+24)!=0)$fatal(1,"Reset committed partial file");
            make_score(1032);begin_upload(1,1);send_content;send_packet(3,0);expect_reply(3,0);check_file(0);
            // Reboot catalog from SD metadata, not the upload-complete cache.
            key=0;repeat(16)@(posedge clk);key=1;repeat(32)@(posedge clk);play(1,1);
            saved=events;screen_command('h10,3,0);i=0;
            repeat(10000)@(posedge clk);
            if(events!=saved || dut.score_player.selected_track!=0 || dut.score_player.system.ringtone_active)
                $fatal(1,"Removed legacy command started playback");
            passed=1;$display("PASS reset in raw DATA, destructive invalidation, reboot metadata, reupload and legacy command rejection");
            disable run_cases;
        end
        if(SMALL_FIFO)begin
            make_score(8192);begin_upload(1,1);send_content;send_packet(3,0);expect_reply(3,11);
            if(word32(8*512+24)!=0)$fatal(1,"FIFO overflow became valid");
            passed=1;$display("PASS raw stream FIFO overflow is explicit; no DATA ACK and no valid partial slot");disable run_cases;
        end
        make_score(16384);set_begin(1,1);
        send_packet(1,10,1);expect_reply(1,1);
        send_packet(1,10,0,1);expect_reply(1,2);
        saved=card.write_commands;
        packet_data[4]=2;send_packet(1,10);expect_reply(1,2);
        if(card.write_commands!=saved || dut.upload_active)$fatal(1,"Invalid BEGIN performed writes");
        begin_upload(1,1);
        saved=card.write_commands;
        send_packet(1,10);expect_reply(1,0);
        if(card.write_commands!=saved)$fatal(1,"Duplicate BEGIN cleared slot twice");
        card.extra_write_busy_bytes=2500;
        send_content;send_packet(3,0);expect_reply(3,0);card.extra_write_busy_bytes=0;check_file(0);
        saved=card.write_commands;send_packet(3,0);expect_reply(3,0);
        if(card.write_commands!=saved)$fatal(1,"Duplicate END wrote again");
        play(1,1);
        // A missing preset does not replace a running valid tune.
        screen_command('h12,1,1);repeat(300000)@(posedge clk);
        screen_command('h12,1,100);repeat(10000)@(posedge clk);
        if(dut.score_player.selected_track!=4)$fatal(1,"Empty preset interrupted current tune");
        screen_command('h11,0,0);repeat(200)@(posedge clk);
        make_score(1032);begin_upload(1,1,1);send_content;send_packet(3,0);expect_reply(3,6);
        if(word32(8*512+24)!=0 || dut.score_player.catalog[0])$fatal(1,"Bad CRC or stale valid cache");
        // Both a short last block and a full-capacity stream must preserve zero padding.
        make_score(1032);begin_upload(1,1);send_content;send_packet(3,0);expect_reply(3,0);check_file(0);
        make_score(102400,1);begin_upload(2,100);send_content;send_packet(3,0);expect_reply(3,0);check_file(199);play(2,100);
        // Header/directory/FAT corruption must be rejected before invalidation.
        make_score(1032);set_begin(1,100);saved=card.write_commands;
        card.image[512]=card.image[512]^1;send_packet(1,10);expect_reply(1,8);
        if(detail!=8'h21 || card.write_commands!=saved)$fatal(1,"Bad descriptor was destructive");
        card.image[512]=card.image[512]^1;
        saved_byte=card.image[FIX_DATA_BASE*512+99*32+26];
        card.image[FIX_DATA_BASE*512+99*32+26]=saved_byte+1;
        send_packet(1,10);expect_reply(1,8);
        if(detail!=8'h23 || card.write_commands!=saved)$fatal(1,"Moved file was destructive");
        card.image[FIX_DATA_BASE*512+99*32+26]=saved_byte;
        saved_byte=card.image[2080*512+(3+99*4)*4];
        card.image[2080*512+(3+99*4)*4]=0;send_packet(1,10);expect_reply(1,8);
        if(detail!=8'h24 || card.write_commands!=saved)$fatal(1,"Changed FAT was destructive");
        card.image[2080*512+(3+99*4)*4]=saved_byte;
        begin_upload(1,100);send_packet(4,0);expect_reply(4,9);
        begin_upload(1,100);for(i=0;i<20;i=i+1)send_byte(content[i]);
        expect_reply(4,10);
        begin_upload(1,100);
        send_byte(content[0],0,1);for(i=1;i<size;i=i+1)send_byte(content[i]);
        expect_reply(4,12);
        make_score(1032,1);begin_upload(1,100);send_content;send_packet(3,0);expect_reply(3,7);
        for(j=12;j<=14;j=j+1)begin
            make_score(1032);begin_upload(1,100);fault=j;
            send_content;send_packet(3,0);expect_reply(3,8);fault=0;
            if(word32((8+99)*512+24)!=0)$fatal(1,"SD write error committed partial file");
        end
        play(1,1);play(2,100);
        if(invalidations<10)$fatal(1,"Missing cache invalidation pulses");
        passed=1;$display("PASS fixed FAT32: clear-before-READY, raw 16/100 KiB, SD stalls, CRC, guards, faults, FAT traversal, playback");
    end
    initial begin #(64'd10000000000);$fatal(1,"Fixed-slot upload watchdog");end
endmodule
module tb_bluetooth_upload;
    wire passed;
    fixed_slot_case test(passed);
    initial begin wait(passed);$finish;end
endmodule
module tb_bluetooth_overflow;
    wire passed;
    fixed_slot_case #(.SMALL_FIFO(1)) test(passed);
    initial begin wait(passed);$finish;end
endmodule
module tb_bluetooth_reset;
    wire passed;
    fixed_slot_case #(.RESET_ONLY(1)) test(passed);
    initial begin wait(passed);$finish;end
endmodule
