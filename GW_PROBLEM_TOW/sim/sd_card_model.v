`timescale 1ns / 1ps
// Behavioral, byte-oriented card behind an independent mode-0 wire interface.
// profile: 0=SDv1 SDSC, 1=SDv2 SDSC, 2=SDHC.
module sd_card_model #(
    parameter IMAGE_FILE = "",
    parameter integer IMAGE_BYTES = 1,
    parameter integer WRITABLE = 0
) (
    input wire rst_n,
    input wire cs_n,
    input wire sck,
    input wire mosi,
    output wire miso,
    input wire [1:0] profile,
    input wire [3:0] fault,
    output reg [31:0] last_argument,
    output reg [31:0] read_commands,
    output reg cmd16_seen
);
    reg [7:0] queue [0:1023];
    integer head, tail;
    reg [7:0] tx_shift, rx_shift;
    integer rx_bits, command_bytes;
    reg [47:0] command_frame;
    reg card_ready, app_pending, command_crc_enabled;
    integer attempts, power_clocks;
    reg [7:0] host_byte;
    reg [7:0] image [0:IMAGE_BYTES-1];
    integer image_index;
    integer write_phase, write_offset, write_commands;
    reg [31:0] write_lba;
    reg [7:0] write_block[0:511];
    reg [15:0] write_crc, sent_crc;
    reg stuck_busy;
    integer extra_write_busy_bytes=0;
    integer busy_bytes_left=0;
    initial begin
        if (IMAGE_FILE != "") begin
            for (image_index = 0; image_index < IMAGE_BYTES; image_index = image_index + 1)
                image[image_index] = 0;
            $readmemh(IMAGE_FILE, image);
        end
    end

    assign miso = cs_n ? 1'b1 : ((fault == 9) ? 1'b0 : tx_shift[7]);

    function [7:0] payload;
        input integer offset;
        input [31:0] lba;
        begin
            payload = (offset * 37) ^ (lba * 13) ^ (offset >> 1);
        end
    endfunction

    function [15:0] reference_crc;
        input [15:0] previous;
        input [7:0] value;
        integer i;
        reg [15:0] result;
        reg feedback;
        begin
            result = previous;
            for (i = 7; i >= 0; i = i - 1) begin
                feedback = result[15] ^ value[i];
                result = {result[14:0], 1'b0};
                if (feedback)
                    result = result ^ 16'h1021;
            end
            reference_crc = result;
        end
    endfunction

    reg [15:0] check_crc;
    integer check_character;
    initial begin
        check_crc = 0;
        for (check_character = 0; check_character < 9; check_character = check_character + 1)
            check_crc = reference_crc(check_crc, 8'h31 + check_character);
        if (check_crc !== 16'h31c3)
            $fatal(1, "CRC-16/XMODEM reference check failed");
    end

    task enqueue;
        input [7:0] value;
        begin
            if (tail >= 1024)
                $fatal(1, "Card model response queue overflow");
            queue[tail] = value;
            tail = tail + 1;
        end
    endtask

    task respond;
        input [47:0] frame;
        reg [5:0] number;
        reg [31:0] argument, lba;
        reg [15:0] block_crc;
        reg [7:0] value;
        reg [46:0] crc_dividend;
        integer i;
        begin : command_response
            number = frame[45:40];
            argument = frame[39:8];
            if (frame[47:46] !== 2'b01 || frame[0] !== 1'b1)
                $fatal(1, "Malformed SD command %h", frame);
            // Independent polynomial division checks the host CRC generator.
            crc_dividend = {frame[47:8], 7'd0};
            for (i = 46; i >= 7; i = i - 1)
                if (crc_dividend[i])
                    crc_dividend = crc_dividend ^ (47'h89 << (i - 7));
            if ((command_crc_enabled || number == 59)
                && frame[7:0] !== {crc_dividend[6:0], 1'b1}) begin
                enqueue(8'hff);
                enqueue(8'hff);
                enqueue(8'h08);
                disable command_response;
            end
            if (fault != 10) begin
                // Nonzero Ncr exercises response polling.
                enqueue(8'hff);
                enqueue(8'hff);
                case (number)
                    0: begin
                        if (power_clocks < 74 || frame[7:0] != 8'h95 || argument != 0)
                            $fatal(1, "CMD0 preamble or CRC incorrect");
                        card_ready = 0;
                        app_pending = 0;
                        attempts = 0;
                        command_crc_enabled = 0;
                        enqueue(8'h01);
                    end
                    8: begin
                        if (frame[7:0] != 8'h87 || argument != 32'h1aa)
                            $fatal(1, "CMD8 argument or CRC incorrect");
                        if (profile == 0)
                            enqueue(8'h05);
                        else begin
                            enqueue(8'h01);
                            enqueue(0);
                            enqueue(0);
                            enqueue(1);
                            enqueue((fault == 6) ? 8'hab : 8'haa);
                        end
                    end
                    55: begin
                        app_pending = 1;
                        enqueue(card_ready ? 8'h00 : 8'h01);
                    end
                    41: begin
                        if (!app_pending || argument !== ((profile == 0)
                            ? 32'd0 : 32'h40000000))
                            $fatal(1, "ACMD41 prefix/HCS incorrect");
                        app_pending = 0;
                        attempts = attempts + 1;
                        if (attempts >= 3 && fault != 8)
                            card_ready = 1;
                        enqueue(card_ready ? 8'h00 : 8'h01);
                    end
                    58: begin
                        if (!card_ready)
                            $fatal(1, "OCR requested before card became ready");
                        enqueue(0);
                        enqueue((fault == 7) ? 8'h00
                                : ((profile == 2) ? 8'hc0 : 8'h80));
                        enqueue(8'hff);
                        enqueue(8'h80);
                        enqueue(0);
                    end
                    16: begin
                        if (!card_ready || profile == 2 || argument != 512)
                            $fatal(1, "CMD16 must set 512 bytes only for SDSC");
                        cmd16_seen = 1;
                        enqueue(0);
                    end
                    59: begin
                        if (!card_ready || argument !== 32'd1)
                            $fatal(1, "CMD59 must enable CRC after initialization");
                        if (fault == 11)
                            enqueue(8'h04);
                        else begin
                            command_crc_enabled = 1;
                            enqueue(8'h00);
                        end
                    end
                    17: begin
                        if (!card_ready || (profile != 2 && !cmd16_seen))
                            $fatal(1, "Read before initialization/block length");
                        if (profile != 2 && argument[8:0] != 0)
                            $fatal(1, "SDSC address is not byte aligned");
                        last_argument = argument;
                        read_commands = read_commands + 1;
                        lba = (profile == 2) ? argument : (argument >> 9);
                        if (fault == 5) begin
                            // Leave the response at FF until the host times out.
                        end else if (fault == 4)
                            enqueue(8'h20);
                        else begin
                            enqueue(0);
                            enqueue(8'hff);
                            enqueue(8'hff);
                            if (fault == 3)
                                enqueue(8'h0d);
                            else if (fault != 2) begin
                                enqueue(8'hfe);
                                block_crc = 0;
                                for (i = 0; i < 512; i = i + 1) begin
                                    if (IMAGE_FILE != "" || WRITABLE) begin
                                        if (lba * 512 + i >= IMAGE_BYTES)
                                            $fatal(1, "Fixture read out of range LBA=%0d", lba);
                                        value = image[lba * 512 + i];
                                    end else
                                        value = payload(i, lba);
                                    enqueue(value);
                                    block_crc = reference_crc(block_crc, value);
                                end
                                enqueue(block_crc[15:8]);
                                enqueue(block_crc[7:0] ^ ((fault == 1) ? 8'h01 : 8'h00));
                            end
                        end
                    end
                    24: begin
                        if(!WRITABLE || !card_ready || (profile!=2 && !cmd16_seen))
                            $fatal(1,"Write before initialization or to read-only model");
                        if(profile!=2 && argument[8:0]!=0) $fatal(1,"Unaligned SDSC write");
                        write_lba=(profile==2) ? argument : argument>>9;
                        if(write_lba*512+511>=IMAGE_BYTES) $fatal(1,"Write LBA out of range");
                        write_phase=1; write_offset=0; write_crc=0;
                        write_commands=write_commands+1;
                        enqueue(0);
                    end
                    13: begin enqueue(0); enqueue(fault==14 ? 8'h20 : 8'h00); end
                    default: $fatal(1, "Unexpected SD command %0d", number);
                endcase
            end
        end
    endtask

    always @(posedge sck or posedge cs_n or negedge rst_n) begin
        if (!rst_n) begin
            rx_bits = 0;
            rx_shift = 0;
            command_bytes = 0;
            command_frame = 0;
            tail = 0;
            power_clocks = 0;
            card_ready = 0;
            app_pending = 0;
            command_crc_enabled = 0;
            attempts = 0;
            last_argument = 0;
            read_commands = 0;
            cmd16_seen = 0;
            write_phase=0; write_offset=0; write_commands=0;
            write_lba=0; write_crc=0; sent_crc=0; stuck_busy=0; busy_bytes_left=0;
        end else if (cs_n) begin
            rx_bits = 0;
            command_bytes = 0;
            tail = 0;
            write_phase=0; stuck_busy=0; busy_bytes_left=0;
            if (sck) begin
                if (mosi !== 1)
                    $fatal(1, "MOSI must be high during deselect clocks");
                power_clocks = power_clocks + 1;
            end
        end else begin
            rx_shift = {rx_shift[6:0], mosi};
            if (rx_bits == 7) begin
                rx_bits = 0;
                host_byte = rx_shift;
                if(write_phase!=0) begin
                    case(write_phase)
                        1: if(host_byte==8'hfe) write_phase=2;
                           else if(host_byte!=8'hff) $fatal(1,"Expected write token");
                        2: begin
                            write_block[write_offset]=host_byte;
                            write_crc=reference_crc(write_crc,host_byte);
                            if(write_offset==511) write_phase=3;
                            else write_offset=write_offset+1;
                        end
                        3: begin sent_crc[15:8]=host_byte; write_phase=4; end
                        4: begin
                            sent_crc[7:0]=host_byte;
                            if(sent_crc!==write_crc) $fatal(1,"Host write CRC incorrect");
                            if(fault!=12 && fault!=13)
                                for(image_index=0;image_index<512;image_index=image_index+1)
                                    image[write_lba*512+image_index]=write_block[image_index];
                            enqueue(fault==12 ? 8'h0d : 8'h05);
                            enqueue(0);enqueue(0);enqueue(0);
                            busy_bytes_left=extra_write_busy_bytes;
                            if(fault==13) stuck_busy=1;
                            else if(extra_write_busy_bytes==0) enqueue(8'hff);
                            write_phase=0;
                        end
                    endcase
                end else if (command_bytes == 0) begin
                    if (host_byte[7:6] == 2'b01) begin
                        command_frame = {40'd0, host_byte};
                        command_bytes = 1;
                    end else if (host_byte !== 8'hff)
                        $fatal(1, "MOSI must be FF while receiving");
                end else begin
                    command_frame = {command_frame[39:0], host_byte};
                    if (command_bytes == 5) begin
                        command_bytes = 0;
                        respond(command_frame);
                    end else
                        command_bytes = command_bytes + 1;
                end
            end else
                rx_bits = rx_bits + 1;
        end
    end

    always @(negedge sck or posedge cs_n or negedge rst_n) begin
        if (!rst_n || cs_n) begin
            head = 0;
            tx_shift = 8'hff;
        end else if (rx_bits == 0) begin
            if (head < tail) begin
                tx_shift = queue[head];
                head = head + 1;
            end else if(busy_bytes_left>0)begin
                tx_shift=0;busy_bytes_left=busy_bytes_left-1;
            end else
                tx_shift = stuck_busy ? 8'h00 : 8'hff;
        end else
            tx_shift = {tx_shift[6:0], 1'b1};
    end
endmodule
