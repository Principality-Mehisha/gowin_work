`timescale 1ns / 1ps
`include "../output/score_test/params.vh"
module tb_score_full;
    reg passed = 0, clk = 0, rst_n = 0;
    reg sd_ready = 0, sd_valid = 0, sd_done = 0;
    reg [7:0] sd_data = 0;
    reg [8:0] sd_index = 0;
    wire sd_start, valid, ready, found, done, event_valid, event_ready, format_ok, complete;
    wire dispatch_ready = 1'b1;
    wire [31:0] sd_lba, file_size, elapsed_ms;
    wire [7:0] data;
    wire [63:0] event_data;
    wire [3:0] fat_error, score_error;
    wire playing, finished, error;
    wire [55:0] notes, velocities;
    wire [7:0] gates, triggers;
    fat_file_reader #(.FILE_NAME("PIANO   BIN")) fat (
        .clk(clk), .rst_n(rst_n), .sd_ready(sd_ready), .sd_start(sd_start),
        .sd_lba(sd_lba), .sd_data(sd_data), .sd_index(sd_index), .sd_valid(sd_valid),
        .sd_done(sd_done), .sd_error(1'b0), .data(data), .valid(valid), .ready(ready),
        .mounted(), .file_found(found), .file_size(file_size), .file_done(done),
        .error_code(fat_error)
    );
    piano_score_reader decoder (
        .clk(clk), .rst_n(rst_n), .data(data), .valid(valid), .ready(ready),
        .file_found(found), .file_size(file_size), .file_done(done),
        .event_data(event_data), .event_valid(event_valid), .event_ready(event_ready),
        .format_ok(format_ok), .complete(complete), .error_code(score_error)
    );
    piano_score_sequencer #(.CLOCKS_PER_MS(100)) sequencer (
        .clk(clk), .rst_n(rst_n), .paused(1'b0), .format_ok(format_ok),
        .stream_complete(complete), .stream_error(fat_error != 0 || score_error != 0),
        .event_data(event_data), .event_valid(event_valid), .event_ready(event_ready),
        .dispatch_ready(dispatch_ready), .dispatch_valid(), .dispatch_on(),
        .dispatch_note(), .dispatch_dynamics(),
        .notes(notes), .velocities(velocities), .gates(gates), .triggers(triggers),
        .playing(playing), .finished(finished), .error(error), .elapsed_ms(elapsed_ms)
    );
    always #10 clk = ~clk;
    integer disk, result, index, parsed = 0, dispatched = 0;
    reg [7:0] block [0:511];
    reg [31:0] lba;
    reg [63:0] expected [0:`SCORE_EVENTS-1];
    reg [63:0] dispatched_event;
    initial begin
        $readmemh("../output/score_test/events.hex", expected);
        disk = $fopen("../output/score_test/full.img", "rb");
        if (!disk) $fatal(1, "Cannot open score fixture");
        repeat (5) @(negedge clk);
        rst_n = 1; sd_ready = 1;
        forever begin
            @(posedge clk);
            if (sd_start && sd_ready) begin
                lba = sd_lba;
                @(negedge clk); sd_ready = 0;
                result = $fseek(disk, lba * 512, 0);
                result = $fread(block, disk);
                if (result != 512) $fatal(1, "Score sector read failed");
                for (index = 0; index < 512; index = index + 1) begin
                    sd_data = block[index]; sd_index = index; sd_valid = 1;
                    @(negedge clk);
                end
                sd_valid = 0;
                repeat (5) @(negedge clk);
                sd_done = 1;
                @(negedge clk); sd_done = 0; sd_ready = 1;
            end
        end
    end
    always @(posedge clk) if (rst_n) begin
        if (fat_error || score_error || error) $fatal(1, "Full score failed");
        if (event_valid && event_ready) begin
            if (parsed >= `SCORE_EVENTS || event_data !== expected[parsed])
                $fatal(1, "Parsed score event mismatch %0d", parsed);
            parsed = parsed + 1;
        end
        if (sequencer.pop) begin
            dispatched_event = sequencer.head;
            if (dispatched >= `SCORE_EVENTS || dispatched_event !== expected[dispatched]
                || elapsed_ms != dispatched_event[31:0])
                $fatal(1, "Score FIFO/order/time mismatch %0d at %0d", dispatched, elapsed_ms);
            dispatched = dispatched + 1;
        end
        if (finished) begin
            if (parsed != `SCORE_EVENTS || dispatched != `SCORE_EVENTS ||
                !complete || file_size != `SCORE_BYTES || gates != 0)
                $fatal(1, "Full score EOF mismatch");
            $display("PASS: complete Croatian Rhapsody, %0d exact events through fragmented FAT32 and timed sequencer", dispatched);
            passed = 1;
            $finish;
        end
    end
    initial begin #500_000_000; $fatal(1, "Full score timeout"); end
endmodule
