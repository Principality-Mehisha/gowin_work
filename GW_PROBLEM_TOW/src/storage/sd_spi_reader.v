// Read-only SD SPI host: SD v1/v2 SDSC and SDHC/SDXC, 512-byte sectors.
// No filesystem or MP3 decoder. Reset to initialize; pulse read_start when
// read_ready. Bytes are provisional until read_done validates the block CRC.
module sd_spi_reader #(
    parameter integer POWER_WAIT_CYCLES = 500_000,
    parameter integer INIT_HALF_DIV = 63,
    parameter integer READ_HALF_DIV = 2,
    parameter integer INIT_TIMEOUT_CYCLES = 100_000_000,
    parameter integer READ_TIMEOUT_CYCLES = 12_500_000,
    parameter integer RESPONSE_BYTES = 16,
    parameter integer BUSY_BYTES = 1024,
    parameter integer ENABLE_COMMAND_CRC = 0
) (
    input  wire clk,
    input  wire rst_n,
    input  wire read_start,
    input  wire [31:0] read_lba,
    output wire read_ready,
    output wire busy,
    output reg  initialized,
    output reg  high_capacity,
    output reg  [7:0] data,
    output reg  [8:0] data_index,
    output reg  data_valid,
    input  wire data_ready,
    output reg  read_done,
    output reg  error_pulse,
    output reg  [3:0] error_code,
    output reg  [23:0] debug_failure,
    output reg  sd_cs_n,
    output wire sd_sck,
    output wire sd_mosi,
    input  wire sd_miso
);
    localparam [5:0]
        POWER_WAIT = 0, POWER_CLOCKS = 1,
        CMD0_START = 2, CMD0_RESULT = 3,
        CMD8_START = 4, CMD8_RESULT = 5,
        CMD55_START = 6, CMD55_RESULT = 7,
        ACMD41_START = 8, ACMD41_RESULT = 9,
        CMD58_START = 10, CMD58_RESULT = 11,
        CMD16_START = 12, CMD16_RESULT = 13,
        INIT_DONE = 14, IDLE = 15,
        CMD17_RESULT = 16, TOKEN_RESULT = 17,
        DATA_RESULT = 18, DATA_HOLD = 19,
        CRC_HIGH = 20, CRC_LOW = 21, READ_COMPLETE = 22,
        COMMAND_READY = 23, COMMAND_SENT = 24,
        COMMAND_RESPONSE = 25, COMMAND_EXTRA = 26,
        BYTE_START = 27, BYTE_WAIT = 28,
        ERROR_RECOVER = 29, ERROR_DONE = 30, FAILED = 31,
        INIT_CRC = 32, CMD59_RESULT = 33;
    localparam [3:0]
        ERR_INIT_TIMEOUT = 1, ERR_CARD_BUSY = 2,
        ERR_RESPONSE_TIMEOUT = 3, ERR_R1 = 4,
        ERR_CMD8 = 5, ERR_OCR = 6, ERR_ADDRESS = 7,
        ERR_TOKEN_TIMEOUT = 8, ERR_DATA_TOKEN = 9, ERR_CRC = 10;

    reg [5:0] state;
    reg [5:0] byte_return;
    reg [5:0] command_return;
    reg spi_start;
    reg abort_transfer;
    reg [7:0] spi_tx;
    wire [7:0] spi_rx;
    wire spi_busy, spi_done;
    // Do not switch frequency before the final slow deselect clocks.
    reg fast_clock;
    wire [15:0] half_div = fast_clock ? READ_HALF_DIV : INIT_HALF_DIV;
    sd_spi_byte u_spi (
        .clk(clk), .rst_n(rst_n && !abort_transfer),
        .start(spi_start), .half_div(half_div),
        .tx_data(spi_tx), .rx_data(spi_rx),
        .busy(spi_busy), .done(spi_done),
        .sck(sd_sck), .mosi(sd_mosi), .miso(sd_miso)
    );

    reg [31:0] power_count, init_count, token_count;
    reg init_timing, token_timing;
    reg [3:0] power_bytes;
    reg card_v2;
    reg [5:0] command;
    reg [47:0] packet;
    reg [2:0] command_index;
    reg [31:0] poll_count;
    reg [7:0] r1;
    reg [31:0] extra;
    reg [1:0] extra_index;
    reg [15:0] crc;
    reg [7:0] received_crc_high;

    assign read_ready = initialized && state == IDLE;
    assign busy = state != IDLE && state != FAILED;

    function [15:0] crc16_byte;
        input [15:0] previous;
        input [7:0] value;
        reg [15:0] work;
        integer bit_number;
        begin
            work = previous ^ {value, 8'd0};
            for (bit_number = 0; bit_number < 8; bit_number = bit_number + 1)
                work = work[15] ? (work << 1) ^ 16'h1021 : (work << 1);
            crc16_byte = work;
        end
    endfunction

    function [7:0] crc7_command;
        input [39:0] message;
        reg [6:0] work;
        reg feedback;
        integer bit_number;
        begin
            work = 0;
            for (bit_number = 39; bit_number >= 0; bit_number = bit_number - 1) begin
                feedback = work[6] ^ message[bit_number];
                work = {work[5:0], 1'b0};
                if (feedback)
                    work = work ^ 7'h09;
            end
            crc7_command = {work, 1'b1};
        end
    endfunction

    task transfer_byte;
        input [7:0] value;
        input [5:0] resume_state;
        begin
            spi_tx <= value;
            byte_return <= resume_state;
            state <= BYTE_START;
        end
    endtask

    task send_command;
        input [5:0] number;
        input [31:0] argument;
        input [7:0] command_crc;
        input [5:0] resume_state;
        begin
            command <= number;
            packet <= {2'b01, number, argument,
                       ENABLE_COMMAND_CRC
                       ? crc7_command({2'b01, number, argument}) : command_crc};
            command_return <= resume_state;
            command_index <= 0;
            poll_count <= 0;
            sd_cs_n <= 0;
            transfer_byte(8'hff, COMMAND_READY);
        end
    endtask

    task deselect_card;
        input [5:0] resume_state;
        begin
            sd_cs_n <= 1;
            transfer_byte(8'hff, resume_state);
        end
    endtask

    task fail;
        input [3:0] code;
        begin
            error_code <= code;
            debug_failure <= {2'b0, state, r1, 2'b0, command};
            error_pulse <= 1;
            data_valid <= 0;
            init_timing <= 0;
            token_timing <= 0;
            sd_cs_n <= 1;
            abort_transfer <= 1;
            state <= ERROR_RECOVER;
        end
    endtask

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= POWER_WAIT;
            byte_return <= POWER_WAIT;
            command_return <= POWER_WAIT;
            spi_start <= 0;
            abort_transfer <= 0;
            spi_tx <= 8'hff;
            fast_clock <= 0;
            power_count <= 0;
            init_count <= 0;
            token_count <= 0;
            init_timing <= 0;
            token_timing <= 0;
            power_bytes <= 0;
            card_v2 <= 0;
            command <= 0;
            packet <= 0;
            command_index <= 0;
            poll_count <= 0;
            r1 <= 0;
            extra <= 0;
            extra_index <= 0;
            crc <= 0;
            received_crc_high <= 0;
            initialized <= 0;
            high_capacity <= 0;
            data <= 0;
            data_index <= 0;
            data_valid <= 0;
            read_done <= 0;
            error_pulse <= 0;
            error_code <= 0;
            debug_failure <= 0;
            sd_cs_n <= 1;
        end else begin
            spi_start <= 0;
            read_done <= 0;
            error_pulse <= 0;
            if (init_timing)
                init_count <= init_count + 1'b1;
            if (token_timing)
                token_count <= token_count + 1'b1;

            if (init_timing && init_count >= INIT_TIMEOUT_CYCLES - 1) begin
                fail(ERR_INIT_TIMEOUT);
            end else if (token_timing && token_count >= READ_TIMEOUT_CYCLES - 1) begin
                fail(ERR_TOKEN_TIMEOUT);
            end else begin
                case (state)
                    POWER_WAIT: begin
                        if (power_count >= POWER_WAIT_CYCLES - 1) begin
                            init_timing <= 1;
                            transfer_byte(8'hff, POWER_CLOCKS);
                        end else
                            power_count <= power_count + 1'b1;
                    end
                    POWER_CLOCKS: begin
                        if (power_bytes == 9)
                            state <= CMD0_START;
                        else begin
                            power_bytes <= power_bytes + 1'b1;
                            transfer_byte(8'hff, POWER_CLOCKS);
                        end
                    end
                    CMD0_START: send_command(0, 0, 8'h95, CMD0_RESULT);
                    CMD0_RESULT: begin
                        if (r1 != 8'h01)
                            fail(ERR_R1);
                        else
                            deselect_card(CMD8_START);
                    end
                    CMD8_START: send_command(8, 32'h000001aa, 8'h87, CMD8_RESULT);
                    CMD8_RESULT: begin
                        if (r1 == 8'h05) begin
                            card_v2 <= 0;
                            deselect_card(CMD55_START);
                        end else if (r1 == 8'h01 && extra == 32'h000001aa) begin
                            card_v2 <= 1;
                            deselect_card(CMD55_START);
                        end else
                            fail(ERR_CMD8);
                    end
                    CMD55_START: send_command(55, 0, 8'h01, CMD55_RESULT);
                    CMD55_RESULT: begin
                        if (r1 == 0 || r1 == 1)
                            deselect_card(ACMD41_START);
                        else
                            fail(ERR_R1);
                    end
                    ACMD41_START:
                        send_command(41, card_v2 ? 32'h40000000 : 32'd0,
                                     8'h01, ACMD41_RESULT);
                    ACMD41_RESULT: begin
                        if (r1 == 1)
                            deselect_card(CMD55_START);
                        else if (r1 == 0)
                            deselect_card(CMD58_START);
                        else
                            fail(ERR_R1);
                    end
                    CMD58_START: send_command(58, 0, 8'h01, CMD58_RESULT);
                    CMD58_RESULT: begin
                        // OCR power-up complete and the 3.3V supply window.
                        if (r1 != 0 || !extra[31] || !extra[21]) begin
                            fail(ERR_OCR);
                        end else begin
                            high_capacity <= card_v2 && extra[30];
                            deselect_card((card_v2 && extra[30])
                                          ? INIT_CRC : CMD16_START);
                        end
                    end
                    CMD16_START: send_command(16, 32'd512, 8'h01, CMD16_RESULT);
                    CMD16_RESULT: begin
                        if (r1 == 0)
                            deselect_card(INIT_CRC);
                        else
                            fail(ERR_R1);
                    end
                    INIT_CRC: begin
                        if (ENABLE_COMMAND_CRC)
                            send_command(59, 32'd1, 8'h01, CMD59_RESULT);
                        else
                            state <= INIT_DONE;
                    end
                    CMD59_RESULT: begin
                        if (r1 != 0)
                            fail(ERR_R1);
                        else
                            deselect_card(INIT_DONE);
                    end
                    INIT_DONE: begin
                        initialized <= 1;
                        init_timing <= 0;
                        fast_clock <= 1;
                        state <= IDLE;
                    end
                    IDLE: begin
                        if (read_start) begin
                            error_code <= 0;
                            data_index <= 0;
                            crc <= 0;
                            if (!high_capacity && |read_lba[31:23])
                                fail(ERR_ADDRESS);
                            else
                                send_command(17, high_capacity ? read_lba
                                             : {read_lba[22:0], 9'd0},
                                             8'h01, CMD17_RESULT);
                        end
                    end
                    CMD17_RESULT: begin
                        if (r1 != 0)
                            fail(ERR_R1);
                        else begin
                            token_count <= 0;
                            token_timing <= 1;
                            transfer_byte(8'hff, TOKEN_RESULT);
                        end
                    end
                    TOKEN_RESULT: begin
                        if (spi_rx == 8'hfe) begin
                            token_timing <= 0;
                            transfer_byte(8'hff, DATA_RESULT);
                        end else if (spi_rx == 8'hff)
                            transfer_byte(8'hff, TOKEN_RESULT);
                        else
                            fail(ERR_DATA_TOKEN);
                    end
                    DATA_RESULT: begin
                        data <= spi_rx;
                        crc <= crc16_byte(crc, spi_rx);
                        data_valid <= 1;
                        state <= DATA_HOLD;
                    end
                    DATA_HOLD: begin
                        // Clock stops low while the consumer is stalled.
                        if (data_ready) begin
                            data_valid <= 0;
                            if (data_index == 511)
                                transfer_byte(8'hff, CRC_HIGH);
                            else begin
                                data_index <= data_index + 1'b1;
                                transfer_byte(8'hff, DATA_RESULT);
                            end
                        end
                    end
                    CRC_HIGH: begin
                        received_crc_high <= spi_rx;
                        transfer_byte(8'hff, CRC_LOW);
                    end
                    CRC_LOW: begin
                        if ({received_crc_high, spi_rx} != crc)
                            fail(ERR_CRC);
                        else
                            deselect_card(READ_COMPLETE);
                    end
                    READ_COMPLETE: begin
                        read_done <= 1;
                        state <= IDLE;
                    end
                    COMMAND_READY: begin
                        if (spi_rx == 8'hff) begin
                            poll_count <= 0;
                            transfer_byte(packet[47:40], COMMAND_SENT);
                        end else if (poll_count >= BUSY_BYTES - 1)
                            fail(ERR_CARD_BUSY);
                        else begin
                            poll_count <= poll_count + 1'b1;
                            transfer_byte(8'hff, COMMAND_READY);
                        end
                    end
                    COMMAND_SENT: begin
                        packet <= {packet[39:0], 8'hff};
                        if (command_index == 5) begin
                            poll_count <= 0;
                            transfer_byte(8'hff, COMMAND_RESPONSE);
                        end else begin
                            command_index <= command_index + 1'b1;
                            transfer_byte(packet[39:32], COMMAND_SENT);
                        end
                    end
                    COMMAND_RESPONSE: begin
                        if (!spi_rx[7]) begin
                            r1 <= spi_rx;
                            if ((command == 8 || command == 58)
                                && (spi_rx == 0 || spi_rx == 1)) begin
                                extra <= 0;
                                extra_index <= 0;
                                transfer_byte(8'hff, COMMAND_EXTRA);
                            end else
                                state <= command_return;
                        end else if (poll_count >= RESPONSE_BYTES - 1)
                            fail(ERR_RESPONSE_TIMEOUT);
                        else begin
                            poll_count <= poll_count + 1'b1;
                            transfer_byte(8'hff, COMMAND_RESPONSE);
                        end
                    end
                    COMMAND_EXTRA: begin
                        extra <= {extra[23:0], spi_rx};
                        if (extra_index == 3)
                            state <= command_return;
                        else begin
                            extra_index <= extra_index + 1'b1;
                            transfer_byte(8'hff, COMMAND_EXTRA);
                        end
                    end
                    BYTE_START: begin
                        if (!spi_busy) begin
                            spi_start <= 1;
                            state <= BYTE_WAIT;
                        end
                    end
                    BYTE_WAIT: begin
                        if (spi_done)
                            state <= byte_return;
                    end
                    ERROR_RECOVER: begin
                        abort_transfer <= 0;
                        transfer_byte(8'hff, ERROR_DONE);
                    end
                    ERROR_DONE: state <= initialized ? IDLE : FAILED;
                    FAILED: state <= FAILED;
                    default: fail(ERR_R1);
                endcase
            end
        end
    end
endmodule
