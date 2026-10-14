`timescale 1ns/1ps
module tb_tmds;
    reg clk = 0;
    always #20 clk = ~clk;
    reg reset_n = 0;
    reg [7:0] data;
    reg de = 0, c0 = 0, c1 = 0;
    wire [9:0] symbol;
    tmds_encoder dut(.pixel_clk(clk), .reset_n(reset_n),
        .data(data), .de(de), .c0(c0), .c1(c1), .symbol(symbol));
    integer i, j, k, n, transitions, q, rd, disparity;
    reg [7:0] recovered, qm;
    reg [9:0] expected_control;
    initial begin
        data = 0;
        repeat (3) @(negedge clk);
        reset_n = 1;
        for (i = 0; i < 4; i = i + 1) begin
            {c1,c0} = i;
            @(posedge clk); #1;
            case (i)
                0: expected_control = 10'b1101010100;
                1: expected_control = 10'b0010101011;
                2: expected_control = 10'b0101010100;
                3: expected_control = 10'b1010101011;
            endcase
            if (symbol !== expected_control || dut.disparity !== 0)
                $fatal(1, "Control symbol mismatch");
            @(negedge clk);
        end
        // Every possible byte, repeated in both orders and pseudo-random runs.
        rd = 0;
        de = 1;
        for (i = 0; i < 8192; i = i + 1) begin
            if (i < 2048) data = i;
            else if (i < 4096) data = 255 - i;
            else data = $random;
            @(posedge clk); #1;
            qm = symbol[9] ? ~symbol[7:0] : symbol[7:0];
            recovered[0] = qm[0];
            for (j = 1; j < 8; j = j + 1)
                recovered[j] = symbol[8] ? (qm[j] ^ qm[j-1]) :
                                                  ~(qm[j] ^ qm[j-1]);
            if (recovered !== data)
                $fatal(1, "TMDS decoded byte mismatch data=%h symbol=%b recovered=%h qm=%h",
                    data, symbol, recovered, qm);
            transitions = 0;
            for (j = 1; j < 8; j = j + 1)
                transitions = transitions + (qm[j] != qm[j-1]);
            if (transitions > 4) $fatal(1, "Transition minimization failed");
            n = 0;
            for (j = 0; j < 10; j = j + 1) n = n + symbol[j];
            rd = rd + 2*n - 10;
            if (rd != $signed(dut.disparity) || rd < -8 || rd > 8)
                $fatal(1, "Invalid running disparity %0d", rd);
            @(negedge clk);
        end
        de = 0;
        @(posedge clk); #1;
        if (dut.disparity !== 0) $fatal(1, "Blanking must reset disparity");
        $display("PASS: four controls, 8192 lossless TMDS samples, disparity and transitions");
        $finish;
    end
endmodule
