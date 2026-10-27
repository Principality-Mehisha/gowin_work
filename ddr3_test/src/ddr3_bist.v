`timescale 1ns/1ps
// Gowin native interface: x16, BL8, 1:4, one 128-bit beat per command.
module ddr3_bist #(
    parameter integer TEST_BURSTS = 33554432, // 512 MiB / 16 bytes
    parameter integer TIMEOUT_CYCLES = 33554432
)(
    input wire clk, input wire reset,
    input wire init_calib_complete,
    output wire [2:0] cmd, output wire cmd_en,
    output wire [28:0] addr, input wire cmd_ready,
    output wire [127:0] wr_data, output wire wr_data_en,
    output wire wr_data_end, output wire [15:0] wr_data_mask,
    input wire wr_data_rdy,
    input wire [127:0] rd_data, input wire rd_data_valid,
    input wire rd_data_end,
    output reg passed, output reg failed,
    output reg [31:0] pass_count,
    output reg [3:0] error_code,
    output reg [28:0] first_error_addr,
    output reg [127:0] first_expected, output reg [127:0] first_actual,
    output reg [2:0] pattern, output reg [2:0] state
);
    localparam WAIT_INIT=0, WRITE=1, READ_CMD=2, READ_WAIT=3, READ_CHECK=4, STOP=5;
    localparam integer WATCHDOG_BITS = $clog2(TIMEOUT_CYCLES+1);
    reg [24:0] index;
    reg [1:0] write_gap;
    reg data_was_ready;
    reg [WATCHDOG_BITS-1:0] watchdog;
    reg compare_bad, frame_bad;
    reg [127:0] read_buffer;
    wire active = (state==WRITE || state==READ_CMD || state==READ_WAIT || state==READ_CHECK);
    // The generated MC registers enables before its FIFO. Submit a write only
    // when BOTH FIFOs are ready, with two idle clocks for this input pipeline.
    // Never hold an enable high across a deasserted ready signal.
    wire write_submit = state==WRITE && write_gap==0 &&
                        cmd_ready && wr_data_rdy && init_calib_complete && !reset;
    assign cmd = state==WRITE ? 3'b000 : 3'b001;
    assign cmd_en = init_calib_complete && !reset &&
                    (write_submit || (state==READ_CMD && cmd_ready));
    // Address unit is a 16-bit DDR word, NOT a byte; rank bit 28 is zero.
    assign addr = {1'b0, index, 3'b000};
    assign wr_data_en = write_submit;
    assign wr_data_end = wr_data_en;
    assign wr_data_mask = 16'b0;

    function [127:0] test_pattern;
        input [28:0] word_addr;
        input [2:0] phase;
        reg [31:0] a;
        reg [127:0] mixed;
        begin
            a = {3'b0,word_addr};
            // Four distinct words exercise every beat and both byte lanes.
            mixed = {a ^ 32'hc3a59678, a ^ 32'h5a693c87,
                     a ^ 32'h96c35aa5, a ^ 32'h3c87a569};
            case(phase)
                0: test_pattern=128'b0;
                1: test_pattern={128{1'b1}};
                2: test_pattern={8{16'haaaa}};
                3: test_pattern={8{16'h5555}};
                4: test_pattern=mixed;
                default: test_pattern=~mixed;
            endcase
        end
    endfunction
    wire [127:0] expected = test_pattern(addr,pattern);
    assign wr_data = expected;
    wire read_response = rd_data_valid &&
        (state==READ_WAIT || (state==READ_CMD && cmd_ready && cmd_en));
    wire progress = (cmd_en && cmd_ready) ||
                    (wr_data_en && wr_data_rdy) || read_response;

    always @(posedge clk) begin
        if(reset) begin
            state<=WAIT_INIT; index<=0; pattern<=0;
            write_gap<=0; data_was_ready<=0; watchdog<=0;
            passed<=0; failed<=0; pass_count<=0; error_code<=0;
            first_error_addr<=0; first_expected<=0; first_actual<=0;
            compare_bad<=0; frame_bad<=0; read_buffer<=0;
        end else if(!failed) begin
            if(write_gap!=0) write_gap<=write_gap-1'b1;
            if(!active || progress || write_gap!=0) watchdog<=0;
            else watchdog<=watchdog+1'b1;
            case(state)
                WAIT_INIT: if(init_calib_complete) begin
                    index<=0; write_gap<=0; data_was_ready<=0; state<=WRITE;
                end
                WRITE: begin
                    if(wr_data_rdy) data_was_ready<=1;
                    if(write_submit) begin
                        write_gap<=2; data_was_ready<=0;
                        if(index==TEST_BURSTS-1) begin index<=0; state<=READ_CMD; end
                        else index<=index+1'b1;
                    end
                end
                READ_CMD: if(cmd_en && cmd_ready) state<=READ_WAIT;
                default: begin end
            endcase
            if(read_response) begin
                // Register the wide comparison before changing address/state.
                compare_bad<=rd_data!=expected;
                frame_bad<=!rd_data_end;
                read_buffer<=rd_data;
                state<=READ_CHECK;
            end
            if(state==READ_CHECK) begin
                if(compare_bad || frame_bad) begin
                    failed<=1; state<=STOP;
                    error_code<=frame_bad ? 4'd6 : 4'd1;
                    first_error_addr<=addr; first_expected<=expected;
                    first_actual<=read_buffer;
                end else if(index==TEST_BURSTS-1) begin
                    index<=0; state<=WRITE;
                    if(pattern==5) begin
                        pattern<=0; passed<=1;
                        if(pass_count!=32'hffffffff) pass_count<=pass_count+1'b1;
                    end else pattern<=pattern+1'b1;
                end else begin index<=index+1'b1; state<=READ_CMD; end
            end
            if(active && !init_calib_complete) begin
                failed<=1; state<=STOP; error_code<=4'd5;
                first_error_addr<=addr;
            end else if(active && !progress && watchdog==TIMEOUT_CYCLES-1) begin
                failed<=1; state<=STOP;
                if(state==READ_WAIT) error_code<=4'd4;
                else if(state==WRITE && !data_was_ready && !wr_data_rdy)
                    error_code<=4'd3;
                else error_code<=4'd2;
                first_error_addr<=addr;
            end
        end
    end
endmodule
