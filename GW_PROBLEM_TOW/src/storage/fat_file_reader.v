// Read one root-directory 8.3 file from a FAT16/FAT32 volume.
// A sector is exposed only after the SD host has validated its CRC.
module fat_file_reader #(
    parameter [87:0] FILE_NAME = "MUSIC   WAV",
    parameter integer DYNAMIC_FILE_NAME = 0,
    // Zero selects automatic MBR/superfloppy discovery.
    parameter [31:0] VOLUME_START_LBA = 0
) (
    input wire [87:0] requested_file_name,
    input wire clk,
    input wire rst_n,
    input wire sd_ready,
    output reg sd_start,
    output reg [31:0] sd_lba,
    input wire [7:0] sd_data,
    input wire [8:0] sd_index,
    input wire sd_valid,
    input wire sd_done,
    input wire sd_error,
    output reg [7:0] data,
    output reg valid,
    input wire ready,
    output reg mounted,
    output reg file_found,
    output reg [31:0] file_size,
    output reg file_done,
    output reg [3:0] error_code
);
    localparam [5:0]
        START = 0, REQUEST = 1, WAIT_SECTOR = 2,
        MEM_WAIT = 3, MEM_RETURN = 4,
        BOOT_BEGIN = 5, BOOT_BYTE = 6, BOOT_CHECK = 7,
        PARTITION = 8, GEOMETRY = 9, GEOMETRY_CHECK = 10,
        DIR_BEGIN = 11, DIR_BYTE = 12, DIR_CHECK = 13,
        DIR_NEXT = 14, FAT_START = 15, FAT_BYTE = 16,
        FAT_CHECK = 17, FILE_BEGIN = 18, FILE_BYTE = 19,
        FILE_HOLD = 20, FINISHED = 21, FAILED = 22, FAT_NEXT = 23,
        LAYOUT_CALC = 24, CLUSTER_CALC = 25;
    reg [5:0] state, sector_return, memory_return;
    reg [7:0] sector [0:511];
    reg [8:0] memory_address;
    reg [7:0] memory_data;
    always @(posedge clk) begin
        if (sd_valid)
            sector[sd_index] <= sd_data;
        memory_data <= sector[memory_address];
    end

    reg [8:0] scan_index;
    reg [7:0] jump_byte, sectors_per_cluster, fat_count;
    reg [15:0] sector_size, reserved_sectors, root_entries;
    reg [15:0] total16, fat16_size, signature, flags32, version32;
    reg [15:0] received_signature;
    reg [9:0] received_bytes;
    reg [31:0] total32, fat32_size, root_cluster;
    reg [7:0] partition_type [0:3];
    reg [31:0] partition_lba [0:3];
    reg [1:0] partition_index;
    reg partition_loaded;
    reg [31:0] volume_base, fat_base, root_base, data_base;
    reg [31:0] cluster_count, fat_sectors, root_sectors_left;
    reg [2:0] cluster_shift;
    reg is_fat32, directory_walk;
    reg [31:0] cluster, cluster_steps;
    reg [7:0] sector_in_cluster;
    reg [8:0] entry_base;
    reg [4:0] entry_index;
    reg name_matches;
    reg [7:0] attributes;
    reg [15:0] entry_cluster_high, entry_cluster_low;
    reg [31:0] entry_size, remaining;
    reg [8:0] fat_offset;
    reg [2:0] fat_byte_index;
    reg [31:0] next_cluster;
    reg [32:0] layout_end, layout_data_offset, checked_volume_end;
    reg [31:0] checked_total, checked_fat_length, checked_root_sectors;
    reg [31:0] calculated_clusters;

    wire [31:0] root_sector_count = ({16'd0, root_entries} + 32'd15) >> 4;
    wire [31:0] fat_length = fat16_size != 0 ? {16'd0, fat16_size} : fat32_size;
    wire [31:0] total_sectors = total16 != 0 ? {16'd0, total16} : total32;
    wire [32:0] fat_area_end = {17'd0, reserved_sectors}
                            + ((fat_count == 2) ? ({1'b0, fat_length} << 1)
                                               : {1'b0, fat_length});
    wire [32:0] volume_end = {1'b0, volume_base} + {1'b0, total_sectors};
    wire [8:0] partition_offset = scan_index - 9'd446;
    wire [8:0] fat_byte_address = fat_offset + {6'd0, fat_byte_index};
    wire [31:0] entry_cluster = is_fat32
        ? {4'd0, entry_cluster_high[11:0], entry_cluster_low}
        : {16'd0, entry_cluster_low};
    wire [31:0] decoded_next = is_fat32 ? (next_cluster & 32'h0fffffff)
                                                      : (next_cluster & 32'h0000ffff);
    wire end_of_chain = is_fat32 ? decoded_next >= 32'h0ffffff8
                                : decoded_next >= 32'h0000fff8;
    wire [31:0] fat_sector_offset = is_fat32 ? (cluster >> 7) : (cluster >> 8);

    function [31:0] cluster_lba;
        input [31:0] value;
        begin
            cluster_lba = data_base + ((value - 2) << cluster_shift);
        end
    endfunction
    function supported_partition;
        input [7:0] kind;
        begin
            supported_partition = kind == 8'h04 || kind == 8'h06
                               || kind == 8'h0e || kind == 8'h0b || kind == 8'h0c;
        end
    endfunction
    task fetch;
        input [31:0] lba;
        input [5:0] resume;
        begin
            sd_lba <= lba;
            sector_return <= resume;
            state <= REQUEST;
        end
    endtask
    task get_byte;
        input [8:0] address;
        input [5:0] resume;
        begin
            memory_address <= address;
            memory_return <= resume;
            state <= MEM_WAIT;
        end
    endtask
    task fail;
        input [3:0] code;
        begin
            error_code <= code;
            valid <= 0;
            state <= FAILED;
        end
    endtask

    integer p;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= START;
            sector_return <= START;
            memory_return <= START;
            memory_address <= 0;
            sd_start <= 0;
            sd_lba <= 0;
            scan_index <= 0;
            jump_byte <= 0;
            sectors_per_cluster <= 0;
            fat_count <= 0;
            sector_size <= 0;
            reserved_sectors <= 0;
            root_entries <= 0;
            total16 <= 0;
            fat16_size <= 0;
            signature <= 0;
            received_signature <= 0;
            received_bytes <= 0;
            flags32 <= 0;
            version32 <= 0;
            total32 <= 0;
            fat32_size <= 0;
            root_cluster <= 0;
            for (p = 0; p < 4; p = p + 1) begin
                partition_type[p] <= 0;
                partition_lba[p] <= 0;
            end
            partition_index <= 0;
            partition_loaded <= VOLUME_START_LBA != 0;
            volume_base <= VOLUME_START_LBA;
            fat_base <= 0;
            root_base <= 0;
            data_base <= 0;
            cluster_count <= 0;
            fat_sectors <= 0;
            root_sectors_left <= 0;
            cluster_shift <= 0;
            is_fat32 <= 0;
            directory_walk <= 1;
            cluster <= 0;
            cluster_steps <= 0;
            sector_in_cluster <= 0;
            entry_base <= 0;
            entry_index <= 0;
            name_matches <= 0;
            attributes <= 0;
            entry_cluster_high <= 0;
            entry_cluster_low <= 0;
            entry_size <= 0;
            remaining <= 0;
            fat_offset <= 0;
            fat_byte_index <= 0;
            next_cluster <= 0;
            layout_end <= 0;
            layout_data_offset <= 0;
            checked_volume_end <= 0;
            checked_total <= 0;
            checked_fat_length <= 0;
            checked_root_sectors <= 0;
            calculated_clusters <= 0;
            data <= 0;
            valid <= 0;
            mounted <= 0;
            file_found <= 0;
            file_size <= 0;
            file_done <= 0;
            error_code <= 0;
        end else begin
            sd_start <= 0;
            file_done <= 0;
            if (sd_valid) begin
                if (received_bytes < 10'd513)
                    received_bytes <= received_bytes + 1'b1;
                if (sd_index == 510)
                    received_signature[7:0] <= sd_data;
                if (sd_index == 511)
                    received_signature[15:8] <= sd_data;
            end
            if (sd_error) begin
                fail(1);
            end else begin
                case (state)
                    START: if (sd_ready) fetch(VOLUME_START_LBA, BOOT_BEGIN);
                    REQUEST: if (sd_ready) begin
                        sd_start <= 1;
                        received_signature <= 0;
                        received_bytes <= 0;
                        state <= WAIT_SECTOR;
                    end
                    WAIT_SECTOR: if (sd_done) state <= sector_return;
                    MEM_WAIT: state <= MEM_RETURN;
                    MEM_RETURN: state <= memory_return;
                    BOOT_BEGIN: begin
                        scan_index <= 0;
                        get_byte(0, BOOT_BYTE);
                    end
                    BOOT_BYTE: begin
                        case (scan_index)
                            0: jump_byte <= memory_data;
                            11: sector_size[7:0] <= memory_data;
                            12: sector_size[15:8] <= memory_data;
                            13: sectors_per_cluster <= memory_data;
                            14: reserved_sectors[7:0] <= memory_data;
                            15: reserved_sectors[15:8] <= memory_data;
                            16: fat_count <= memory_data;
                            17: root_entries[7:0] <= memory_data;
                            18: root_entries[15:8] <= memory_data;
                            19: total16[7:0] <= memory_data;
                            20: total16[15:8] <= memory_data;
                            22: fat16_size[7:0] <= memory_data;
                            23: fat16_size[15:8] <= memory_data;
                            32,33,34,35: total32[(scan_index-32)*8 +: 8] <= memory_data;
                            36,37,38,39: fat32_size[(scan_index-36)*8 +: 8] <= memory_data;
                            40: flags32[7:0] <= memory_data;
                            41: flags32[15:8] <= memory_data;
                            42: version32[7:0] <= memory_data;
                            43: version32[15:8] <= memory_data;
                            44,45,46,47: root_cluster[(scan_index-44)*8 +: 8] <= memory_data;
                            510: signature[7:0] <= memory_data;
                            511: signature[15:8] <= memory_data;
                        endcase
                        if (scan_index >= 446 && scan_index < 510) begin
                            case (partition_offset[3:0])
                                4: partition_type[partition_offset[5:4]] <= memory_data;
                                8,9,10,11:
                                    partition_lba[partition_offset[5:4]]
                                        [(partition_offset[3:0]-8)*8 +: 8] <= memory_data;
                            endcase
                        end
                        if (scan_index == 511)
                            state <= BOOT_CHECK;
                        else begin
                            scan_index <= scan_index + 1'b1;
                            get_byte(scan_index + 1'b1, BOOT_BYTE);
                        end
                    end
                    BOOT_CHECK: begin
                        if (received_bytes != 512)
                            fail(14);
                        else if (signature != received_signature)
                            // Separate RAM/readback errors from card contents.
                            fail(13);
                        else if (signature != 16'haa55)
                            fail(partition_loaded ? 4'd12 : 4'd10);
                        else if ((jump_byte == 8'heb || jump_byte == 8'he9)
                                 && sector_size == 512)
                            state <= GEOMETRY;
                        else if (!partition_loaded) begin
                            partition_index <= 0;
                            state <= PARTITION;
                        end else
                            // A selected partition did not contain a valid
                            // FAT boot sector.
                            fail(12);
                    end
                    PARTITION: begin
                        if (supported_partition(partition_type[partition_index])
                            && partition_lba[partition_index] != 0) begin
                            volume_base <= partition_lba[partition_index];
                            partition_loaded <= 1;
                            fetch(partition_lba[partition_index], BOOT_BEGIN);
                        end else if (partition_index == 3)
                            // The MBR is valid, but no FAT16/FAT32 primary
                            // partition was found.
                            fail(11);
                        else
                            partition_index <= partition_index + 1'b1;
                    end
                    GEOMETRY: begin
                        layout_end <= fat_area_end;
                        checked_volume_end <= volume_end;
                        checked_total <= total_sectors;
                        checked_fat_length <= fat_length;
                        checked_root_sectors <= root_sector_count;
                        case (sectors_per_cluster)
                            1: cluster_shift <= 0;
                            2: cluster_shift <= 1;
                            4: cluster_shift <= 2;
                            8: cluster_shift <= 3;
                            16: cluster_shift <= 4;
                            32: cluster_shift <= 5;
                            64: cluster_shift <= 6;
                            128: cluster_shift <= 7;
                            default: cluster_shift <= 0;
                        endcase
                        state <= LAYOUT_CALC;
                    end
                    LAYOUT_CALC: begin
                        layout_data_offset <= layout_end + {1'b0, checked_root_sectors};
                        state <= CLUSTER_CALC;
                    end
                    CLUSTER_CALC: begin
                        calculated_clusters <= (checked_total - layout_data_offset[31:0]) >> cluster_shift;
                        state <= GEOMETRY_CHECK;
                    end
                    GEOMETRY_CHECK: begin
                        if (sectors_per_cluster == 0 || sectors_per_cluster > 128
                            || (sectors_per_cluster & (sectors_per_cluster - 1'b1)) != 0
                            || reserved_sectors == 0 || fat_length == 0
                            || (fat_count != 1 && fat_count != 2)) begin
                            fail(6);
                        end else if (checked_volume_end[32]
                            || layout_data_offset >= {1'b0, checked_total}
                            || calculated_clusters < 4085
                            || calculated_clusters >= 32'h0ffffff5) begin
                            fail(7);
                        end else if (calculated_clusters < 65525
                            && (fat16_size == 0 || root_entries == 0
                                || calculated_clusters + 2 > (checked_fat_length << 8))) begin
                            fail(8);
                        end else if (calculated_clusters >= 65525
                            && (fat16_size != 0 || root_entries != 0
                                || version32 != 0
                                || root_cluster < 2 || root_cluster >= calculated_clusters + 2
                                || calculated_clusters > (checked_fat_length << 7)
                                || (flags32[7] && flags32[3:0] >= fat_count))) begin
                            fail(9);
                        end else begin
                            mounted <= 1;
                            is_fat32 <= calculated_clusters >= 65525;
                            cluster_count <= calculated_clusters;
                            fat_sectors <= checked_fat_length;
                            fat_base <= volume_base + reserved_sectors
                                + ((calculated_clusters >= 65525 && flags32[7]
                                    && flags32[3:0] == 1) ? checked_fat_length : 32'd0);
                            root_base <= volume_base + layout_end[31:0];
                            data_base <= volume_base + layout_data_offset[31:0];
                            root_sectors_left <= checked_root_sectors;
                            cluster <= root_cluster;
                            sector_in_cluster <= 0;
                            state <= DIR_NEXT;
                        end
                    end
                    DIR_NEXT: begin
                        // Geometry registers have settled before address calculation.
                        if (is_fat32)
                            fetch(cluster_lba(cluster), DIR_BEGIN);
                        else
                            fetch(root_base, DIR_BEGIN);
                    end
                    DIR_BEGIN: begin
                        entry_base <= 0;
                        entry_index <= 0;
                        name_matches <= 1;
                        get_byte(0, DIR_BYTE);
                    end
                    DIR_BYTE: begin
                        if (entry_index == 0 && memory_data == 0) begin
                            fail(4);
                        end else begin
                            if (entry_index < 11
                                && memory_data != (((DYNAMIC_FILE_NAME ? requested_file_name : FILE_NAME) >> ((10-entry_index)*8)) & 8'hff))
                                name_matches <= 0;
                            case (entry_index)
                                11: attributes <= memory_data;
                                20: entry_cluster_high[7:0] <= memory_data;
                                21: entry_cluster_high[15:8] <= memory_data;
                                26: entry_cluster_low[7:0] <= memory_data;
                                27: entry_cluster_low[15:8] <= memory_data;
                                28,29,30,31: entry_size[(entry_index-28)*8 +: 8] <= memory_data;
                            endcase
                            if (entry_index == 31)
                                state <= DIR_CHECK;
                            else begin
                                entry_index <= entry_index + 1'b1;
                                get_byte(entry_base + entry_index + 1'b1, DIR_BYTE);
                            end
                        end
                    end
                    DIR_CHECK: begin
                        if (name_matches && (attributes & 8'h18) == 0) begin
                            if (entry_size != 0 && (entry_cluster < 2
                                || entry_cluster >= cluster_count + 2)) begin
                                fail(5);
                            end else begin
                                file_found <= 1;
                                file_size <= entry_size;
                                remaining <= entry_size;
                                cluster <= entry_cluster;
                                cluster_steps <= 0;
                                sector_in_cluster <= 0;
                                directory_walk <= 0;
                                if (entry_size == 0) begin
                                    file_done <= 1;
                                    state <= FINISHED;
                                end else
                                    fetch(cluster_lba(entry_cluster), FILE_BEGIN);
                            end
                        end else if (entry_base != 480) begin
                            entry_base <= entry_base + 9'd32;
                            entry_index <= 0;
                            name_matches <= 1;
                            get_byte(entry_base + 9'd32, DIR_BYTE);
                        end else if (!is_fat32) begin
                            if (root_sectors_left <= 1)
                                fail(4);
                            else begin
                                root_sectors_left <= root_sectors_left - 1'b1;
                                fetch(sd_lba + 1'b1, DIR_BEGIN);
                            end
                        end else if (sector_in_cluster + 1 < sectors_per_cluster) begin
                            sector_in_cluster <= sector_in_cluster + 1'b1;
                            fetch(sd_lba + 1'b1, DIR_BEGIN);
                        end else
                            state <= FAT_START;
                    end
                    FAT_START: begin
                        if (fat_sector_offset >= fat_sectors || cluster_steps >= cluster_count)
                            fail(5);
                        else begin
                            fat_offset <= is_fat32 ? {cluster[6:0],2'b00}
                                                  : {cluster[7:0],1'b0};
                            fat_byte_index <= 0;
                            next_cluster <= 0;
                            fetch(fat_base + fat_sector_offset, FAT_BYTE);
                        end
                    end
                    FAT_BYTE: begin
                        get_byte(fat_byte_address, FAT_CHECK);
                    end
                    FAT_CHECK: begin
                        next_cluster[fat_byte_index*8 +: 8] <= memory_data;
                        if (fat_byte_index == (is_fat32 ? 3 : 1)) begin
                            // Reuse a state after the last byte has reached the register.
                            state <= FAT_NEXT;
                        end else begin
                            fat_byte_index <= fat_byte_index + 1'b1;
                            state <= FAT_BYTE;
                        end
                    end
                    FAT_NEXT: begin
                        if (end_of_chain) begin
                            fail(directory_walk ? 4 : 5);
                        end else if (decoded_next < 2 || decoded_next >= cluster_count + 2
                                     || (is_fat32 ? decoded_next >= 32'h0ffffff0
                                                  : decoded_next >= 32'h0000fff0)) begin
                            fail(5);
                        end else begin
                            cluster <= decoded_next;
                            cluster_steps <= cluster_steps + 1'b1;
                            sector_in_cluster <= 0;
                            fetch(cluster_lba(decoded_next), directory_walk ? DIR_BEGIN : FILE_BEGIN);
                        end
                    end
                    FILE_BEGIN: begin
                        scan_index <= 0;
                        get_byte(0, FILE_BYTE);
                    end
                    FILE_BYTE: begin
                        data <= memory_data;
                        valid <= 1;
                        state <= FILE_HOLD;
                    end
                    FILE_HOLD: if (ready) begin
                        valid <= 0;
                        remaining <= remaining - 1'b1;
                        if (remaining == 1) begin
                            file_done <= 1;
                            state <= FINISHED;
                        end else if (scan_index != 511) begin
                            scan_index <= scan_index + 1'b1;
                            get_byte(scan_index + 1'b1, FILE_BYTE);
                        end else if (sector_in_cluster + 1 < sectors_per_cluster) begin
                            sector_in_cluster <= sector_in_cluster + 1'b1;
                            fetch(sd_lba + 1'b1, FILE_BEGIN);
                        end else
                            state <= FAT_START;
                    end
                    FINISHED: state <= FINISHED;
                    FAILED: state <= FAILED;
                    default: fail(5);
                endcase
            end
        end
    end
endmodule
