// P88S v1: validate the fixed header and ordered 8-byte records before publish.
// event_valid/event_data remain stable until the consumer asserts event_ready.
module piano_score_reader #(parameter integer DYNAMIC_FORMAT = 0) (
    input wire marimba_format,
    input wire clk, rst_n,
    input wire [7:0] data,
    input wire valid,
    output wire ready,
    input wire file_found,
    input wire [31:0] file_size,
    input wire file_done,
    output reg [63:0] event_data,
    output reg event_valid,
    input wire event_ready,
    output reg format_ok,
    output reg complete,
    output reg [3:0] error_code
);
    localparam [2:0] HEADER = 0, CHECK_HEADER = 1, RECORD = 2,
        CHECK_RECORD = 3, HOLD = 4, EOF_WAIT = 5, DONE = 6, FAILED = 7;
    reg [2:0] state;
    reg [3:0] index;
    reg [127:0] header;
    reg [63:0] record;
    reg [7:0] score_slots;
    reg [31:0] events_left, last_time;
    reg eof_seen;
    wire take = valid && ready;
    wire [31:0] timestamp = record[31:0];
    wire [7:0] slot = record[39:32], note = record[47:40], velocity = record[55:48];
    wire end_record = slot == 255 && note == 255 && velocity == 0;
    wire use_marimba = DYNAMIC_FORMAT && marimba_format;
    wire [31:0] expected_magic = use_marimba ? 32'h5332344d : 32'h53383850;
    wire invalid_note = use_marimba ? (note < 36 || note > 83) : note >= 88;
    assign ready = (state == HEADER || state == RECORD) && file_found;
    task fail;
        input [3:0] code;
        begin error_code <= code; event_valid <= 0; state <= FAILED; end
    endtask
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= HEADER; index <= 0; header <= 0; record <= 0;
            events_left <= 0; last_time <= 0; eof_seen <= 0;
            score_slots <= 8;
            event_data <= 0; event_valid <= 0; format_ok <= 0;
            complete <= 0; error_code <= 0;
        end else begin
            if (file_done) eof_seen <= 1;
            if (file_found && file_size < 24 && error_code == 0)
                fail(1);
            else if (file_done && state != DONE && state != FAILED &&
                !(events_left == 1 && (state == CHECK_RECORD || state == HOLD)) &&
                !(events_left == 1 && state == RECORD && index == 7 && take) &&
                state != EOF_WAIT) fail(4);
            else case (state)
                HEADER: if (take) begin
                    header[index*8 +: 8] <= data;
                    if (index == 15) begin index <= 0; state <= CHECK_HEADER; end
                    else index <= index + 1'b1;
                end
                CHECK_HEADER: begin
                    if (header[31:0] != expected_magic || header[39:32] != 1 ||
                        header[47:40] != 8 ||
                        (header[55:48] != 8 && header[55:48] != 32) ||
                        header[63:56] != 0 ||
                        header[95:64] != 1000 || header[127:96] == 0 ||
                        header[127:96] > 20000 ||
                        ({3'd0, header[127:96]} << 3) + 35'd16 != {3'd0, file_size})
                        fail(1);
                    else begin
                        score_slots <= header[55:48];
                        events_left <= header[127:96]; format_ok <= 1; state <= RECORD;
                    end
                end
                RECORD: if (take) begin
                    record[index*8 +: 8] <= data;
                    if (index == 7) begin index <= 0; state <= CHECK_RECORD; end
                    else index <= index + 1'b1;
                end
                CHECK_RECORD: begin
                    if (timestamp < last_time || record[63:56] != 0 ||
                        (events_left == 1 && !end_record) ||
                        (events_left != 1 && (slot >= score_slots || invalid_note || velocity >= 128)))
                        fail(2);
                    else begin
                        event_data <= record; event_valid <= 1;
                        last_time <= timestamp; state <= HOLD;
                    end
                end
                HOLD: if (event_ready) begin
                    event_valid <= 0; events_left <= events_left - 1'b1;
                    state <= events_left == 1 ? EOF_WAIT : RECORD;
                end
                EOF_WAIT: if (eof_seen || file_done) begin complete <= 1; state <= DONE; end
                default: state <= state;
            endcase
        end
    end
endmodule
