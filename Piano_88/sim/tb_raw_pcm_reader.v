`timescale 1ns / 1ps
module tb_raw_pcm_reader;
    reg passed = 0, clk = 0, rst_n = 0;
    reg [7:0] data = 0;
    reg valid = 0, found = 0, done = 0, pcm_ready = 0;
    reg [31:0] size = 0;
    wire ready, pcm_valid, format_ok, audio_end;
    wire [15:0] pcm;
    wire [3:0] error_code;
    raw_pcm_reader dut (
        .clk(clk), .rst_n(rst_n), .data(data), .valid(valid), .ready(ready),
        .file_found(found), .file_size(size), .file_done(done), .pcm(pcm),
        .pcm_valid(pcm_valid), .pcm_ready(pcm_ready),
        .format_ok(format_ok), .audio_end(audio_end), .error_code(error_code)
    );
    always #10 clk = ~clk;
    task reset;
        input [31:0] length;
        begin
            @(negedge clk); rst_n = 0; valid = 0; found = 0; done = 0; pcm_ready = 0;
            repeat (3) @(negedge clk);
            rst_n = 1;
            repeat (3) @(negedge clk);
            if (error_code || ready || format_ok) $fatal(1, "Did not wait for file discovery");
            size = length; found = 1;
            repeat (3) @(negedge clk);
        end
    endtask
    task send;
        input [7:0] value;
        begin
            while (!ready) @(negedge clk);
            data = value; valid = 1;
            @(negedge clk); valid = 0;
        end
    endtask
    initial begin
        reset(2);
        send(8'h01); send(8'h80);
        done = 1;
        @(negedge clk); done = 0;
        repeat (32) @(negedge clk);
        if (!pcm_valid || pcm !== 16'h8001 || error_code || audio_end)
            $fatal(1, "Final-sample backpressure/EOF failure");
        pcm_ready = 1;
        repeat (4) @(negedge clk);
        if (!audio_end || error_code) $fatal(1, "Final sample did not finish");
        reset(0);
        if (error_code != 3) $fatal(1, "Empty BIN accepted");
        reset(3);
        if (error_code != 3) $fatal(1, "Odd BIN accepted");
        reset(4);
        send(8'h01);
        done = 1;
        repeat (2) @(negedge clk);
        if (error_code != 4 || pcm_valid) $fatal(1, "Truncated BIN accepted");
        $display("PASS: discovery, final-sample stall, signed PCM, odd/empty lengths, truncated EOF");
        passed = 1;
        $finish;
    end
    initial begin
        #100_000;
        $fatal(1, "Raw PCM test timeout");
    end
endmodule
