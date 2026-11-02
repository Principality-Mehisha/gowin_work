// Read-only validation of the prepared FAT32 layout and one fixed file.
// No FAT allocator, mutable sector cache, or full-file buffer is required.
module slot_card_query (
    input wire clk, rst_n, for_write, scan_catalog,
    input wire [7:0] slot_index,
    input wire [87:0] file_name,
    input wire sd_ready,
    output reg sd_start,
    output reg [31:0] sd_lba,
    input wire [7:0] sd_data,
    input wire [8:0] sd_index,
    input wire sd_valid, sd_done, sd_error,
    output reg done,
    output reg [7:0] error,
    output reg [199:0] catalog_mask,
    output reg catalog_done,
    output wire [31:0] file_lba, metadata_lba,
    output reg [31:0] file_size, file_crc
);
    localparam START=0, REQUEST=1, WAIT_IO=2, DESCRIPTOR=3, MBR=4, BOOT=5,
        META=6, AFTER_META=7, DIRECTORY=8, FAT=9, FINISHED=10;
    reg [3:0] state, io_return;
    reg [31:0] crc_work, expected_crc, partition_sectors, data_base, slots_base, fat_sectors;
    reg bad, scan_all, selected_valid;
    reg [7:0] meta_index;
    reg [31:0] mbr_base, mbr_size, boot_size, entry_size, entry_cluster, fat_word;
    reg [15:0] signature;
    reg [7:0] mbr_type;
    reg [223:0] meta_record;
    reg [1:0] fat_index;
    reg fat_copy;
    reg [4:0] geometry_ok;
    wire [31:0] first_cluster=32'd3+({24'd0,slot_index}<<2);
    wire [31:0] tested_cluster=first_cluster+{30'd0,fat_index};
    wire [8:0] fat_offset={tested_cluster[6:0],2'b00};
    wire [32:0] volume_end={1'b0,partition_sectors}+33'd2048;
    wire [32:0] last_slot_end={1'b0,slots_base}+33'd51144;
    assign file_lba=slots_base+({24'd0,slot_index}<<8);
    assign metadata_lba=32'd8+{24'd0,slot_index};
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
    function [7:0] descriptor_byte;
        input [5:0] index;
        reg [31:0] word_value;
        begin
            case(index[5:2])
                0:word_value=32'h30315747;
                1:word_value=32'h32304b30;
                2:word_value=2;
                3:word_value=512;
                4:word_value=200;
                5:word_value=102400;
                6:word_value=256;
                7:word_value=2048;
                11:word_value=8;
                12:word_value=2;
                13:word_value=64;
                default:word_value=0;
            endcase
            descriptor_byte=word_value[index[1:0]*8+:8];
        end
    endfunction
    task read_sector;
        input [31:0] lba;
        input [3:0] resume;
        begin
            sd_lba<=lba; io_return<=resume; state<=REQUEST;
            crc_work<=32'hffffffff; expected_crc<=0; bad<=0; signature<=0;
            meta_record<=0; fat_word<=0; entry_cluster<=0; entry_size<=0;
        end
    endtask
    task fail;
        input [7:0] code;
        begin error<=code; done<=1; state<=FINISHED; end
    endtask
    task read_fat;
        input copy_number;
        input [1:0] link_index;
        reg [31:0] cluster_number;
        begin
            cluster_number=first_cluster+{30'd0,link_index};
            fat_copy<=copy_number; fat_index<=link_index;
            read_sector(32'd2080+(copy_number ? fat_sectors : 32'd0)+(cluster_number>>7),FAT);
        end
    endtask
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state<=START; io_return<=START; sd_start<=0; sd_lba<=0;
            crc_work<=32'hffffffff; expected_crc<=0; partition_sectors<=0;
            data_base<=0; slots_base<=0; fat_sectors<=0; bad<=0; scan_all<=0;
            selected_valid<=0; meta_index<=0; mbr_base<=0; mbr_size<=0; boot_size<=0;
            entry_size<=0; entry_cluster<=0; fat_word<=0; signature<=0; mbr_type<=0;
            meta_record<=0; fat_index<=0; fat_copy<=0;
            geometry_ok<=0;
            done<=0; error<=0; catalog_mask<=0; catalog_done<=0; file_size<=0; file_crc<=0;
        end else begin
            // Descriptor values and FAT size are received long before the
            // boot sector's final signature/CRC. Register the independent
            // geometry checks before their result fans out to sector setup.
            geometry_ok[0]<=fat_sectors!=0 && fat_sectors<=32'h00100000;
            geometry_ok[1]<=data_base==32'd2080+(fat_sectors<<1) && slots_base==data_base+64;
            geometry_ok[2]<=!volume_end[32] && last_slot_end<volume_end;
            geometry_ok[3]<=volume_end>=({1'b0,data_base}+33'd4193600);
            geometry_ok[4]<=((partition_sectors-32-(fat_sectors<<1))>>6)+2<=(fat_sectors<<7);
            sd_start<=0; catalog_done<=0;
            if(sd_valid && state==WAIT_IO) begin
                case(io_return)
                    DESCRIPTOR: begin
                        if(sd_index<60) begin
                            crc_work<=crc32_byte(crc_work,sd_data);
                            if(sd_index>=32 && sd_index<36)
                                partition_sectors[(sd_index-32)*8+:8]<=sd_data;
                            else if(sd_index>=36 && sd_index<40)
                                data_base[(sd_index-36)*8+:8]<=sd_data;
                            else if(sd_index>=40 && sd_index<44)
                                slots_base[(sd_index-40)*8+:8]<=sd_data;
                            else if(sd_data!=descriptor_byte(sd_index[5:0])) bad<=1;
                        end else if(sd_index<64) expected_crc[(sd_index-60)*8+:8]<=sd_data;
                    end
                    MBR: case(sd_index)
                        450:mbr_type<=sd_data;
                        454,455,456,457:mbr_base[(sd_index-454)*8+:8]<=sd_data;
                        458,459,460,461:mbr_size[(sd_index-458)*8+:8]<=sd_data;
                        510:signature[7:0]<=sd_data;
                        511:signature[15:8]<=sd_data;
                        default:begin end
                    endcase
                    BOOT: case(sd_index)
                        11:if(sd_data!=0)bad<=1;
                        12:if(sd_data!=2)bad<=1;
                        13:if(sd_data!=64)bad<=1;
                        14:if(sd_data!=32)bad<=1;
                        15,17,18,19,20,22,23,40,41,42,43,45,46,47:if(sd_data!=0)bad<=1;
                        16:if(sd_data!=2)bad<=1;
                        32,33,34,35:boot_size[(sd_index-32)*8+:8]<=sd_data;
                        36,37,38,39:fat_sectors[(sd_index-36)*8+:8]<=sd_data;
                        44:if(sd_data!=2)bad<=1;
                        510:signature[7:0]<=sd_data;
                        511:signature[15:8]<=sd_data;
                        default:begin end
                    endcase
                    META: begin
                        if(sd_index<28) begin
                            meta_record[sd_index*8+:8]<=sd_data;
                            crc_work<=crc32_byte(crc_work,sd_data);
                        end else if(sd_index<32) expected_crc[(sd_index-28)*8+:8]<=sd_data;
                    end
                    DIRECTORY: if(sd_index[8:5]==slot_index[3:0]) begin
                        if(sd_index[4:0]<11 &&
                            sd_data!=((file_name>>((10-sd_index[4:0])*8))&8'hff)) bad<=1;
                        case(sd_index[4:0])
                            11:if((sd_data&8'h18)!=0 || (for_write && sd_data[0]))bad<=1;
                            20:entry_cluster[23:16]<=sd_data;
                            21:entry_cluster[31:24]<=sd_data;
                            26:entry_cluster[7:0]<=sd_data;
                            27:entry_cluster[15:8]<=sd_data;
                            28,29,30,31:entry_size[(sd_index[4:0]-28)*8+:8]<=sd_data;
                            default:begin end
                        endcase
                    end
                    FAT: if(sd_index>=fat_offset && sd_index<fat_offset+10'd4)
                        fat_word[(sd_index-fat_offset)*8+:8]<=sd_data;
                    default:begin end
                endcase
            end
            if(sd_error && state!=FINISHED) fail(8'h10);
            else case(state)
                START: begin scan_all<=scan_catalog && !for_write; read_sector(1,DESCRIPTOR); end
                REQUEST: if(sd_ready) begin sd_start<=1; state<=WAIT_IO; end
                WAIT_IO: if(sd_done) state<=io_return;
                DESCRIPTOR: begin
                    if(bad || (~crc_work)!=expected_crc || slot_index>=200) fail(8'h21);
                    else read_sector(0,MBR);
                end
                MBR: begin
                    if(signature!=16'haa55 || mbr_type!=8'h0c || mbr_base!=2048 ||
                        mbr_size!=partition_sectors) fail(8'h21);
                    else read_sector(2048,BOOT);
                end
                BOOT: begin
                    if(bad || signature!=16'haa55 || boot_size!=partition_sectors ||
                        !(&geometry_ok))
                        fail(8'h21);
                    else if(for_write) read_sector(data_base+({24'd0,slot_index}>>4),DIRECTORY);
                    else begin
                        meta_index<=scan_all ? 8'd0 : slot_index;
                        read_sector(32'd8+(scan_all ? 32'd0 : {24'd0,slot_index}),META);
                    end
                end
                META: begin
                    if(meta_record[63:0]==64'h3230544f4c535747 && meta_record[95:64]==2 &&
                        meta_record[127:96]=={24'd0,meta_index} &&
                        meta_record[223:192]==32'ha55aa55a &&
                        meta_record[159:128]>=24 && meta_record[159:128]<=102400 &&
                        meta_record[130:128]==0 && (~crc_work)==expected_crc) begin
                        catalog_mask[meta_index]<=1;
                        if(meta_index==slot_index) begin
                            selected_valid<=1; file_size<=meta_record[159:128]; file_crc<=meta_record[191:160];
                        end
                    end
                    if(scan_all && meta_index<199) begin
                        meta_index<=meta_index+1'b1; read_sector(32'd9+{24'd0,meta_index},META);
                    end else begin
                        if(scan_all)catalog_done<=1;
                        state<=AFTER_META;
                    end
                end
                AFTER_META: begin
                    if(!selected_valid) fail(8'h04);
                    else read_sector(data_base+({24'd0,slot_index}>>4),DIRECTORY);
                end
                DIRECTORY: begin
                    if(bad || entry_cluster!=first_cluster || entry_size!=102400) fail(8'h23);
                    else read_fat(0,0);
                end
                FAT: begin
                    if(fat_index==3 ? ((fat_word&32'h0fffffff)<32'h0ffffff8) :
                        ((fat_word&32'h0fffffff)!=tested_cluster+1)) fail(8'h24);
                    else if(fat_index!=3)read_fat(fat_copy,fat_index+1'b1);
                    else if(!fat_copy)read_fat(1,0);
                    else begin done<=1; state<=FINISHED; end
                end
                FINISHED: state<=FINISHED;
                default:fail(8'h2f);
            endcase
        end
    end
endmodule
