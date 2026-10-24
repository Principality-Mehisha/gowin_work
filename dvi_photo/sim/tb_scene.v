`timescale 1ns/1ps
`include "score_config.vh"
module tb_scene;
    reg clk = 0;
    always #5 clk = ~clk;
    reg reset_n = 0, tick = 0;
    reg [10:0] x = 1800;
    reg [9:0] y = 1000;
    wire [23:0] rgb;
    reg passed = 0;
    piano_scene dut(.clk(clk), .reset_n(reset_n), .frame_tick(tick),
        .x(x), .y(y), .test_pattern(1'b0), .rgb(rgb));
    reg [23:0] expected [0:1439999];
    reg [87:0] expected_keys [0:`SCORE_LOOP_FRAMES-1];
    reg [11:0] key_centers [0:87];
    reg [23:0] key_color;
    reg [87:0] seen = 0;
    reg [87:0] highlight_mask = 0;
    reg [31:0] index_pipe0, index_pipe1, index_pipe2, index_pipe3;
    reg input_valid = 0, valid0 = 0, valid1 = 0, valid2 = 0, valid3 = 0;
    integer frame, i, j, key, file_handle, checked = 0;
    // Observe the fifth pipeline register after NBA updates.
    always @(posedge clk) begin
        #1;
        if (valid3) begin
            if (rgb !== expected[index_pipe3])
                $fatal(1,"Scene pixel mismatch index=%0d got=%h expected=%h",index_pipe3,rgb,expected[index_pipe3]);
            $fwrite(file_handle,"%c%c%c",rgb[23:16],rgb[15:8],rgb[7:0]);
            checked = checked + 1;
        end
        valid3 = valid2;
        valid2 = valid1;
        valid1 = valid0;
        valid0 = input_valid;
        index_pipe3 = index_pipe2;
        index_pipe2 = index_pipe1;
        index_pipe1 = index_pipe0;
        index_pipe0 = y * 1600 + x;
    end
    initial begin
        $readmemh("sim/expected_frame.hex",expected);
        $readmemh("sim/expected_keys.hex",expected_keys);
        $readmemh("sim/key_centers.hex",key_centers);
        file_handle = $fopen("sim/waterfall_rtl.ppm","wb");
        $fwrite(file_handle,"P6\n1600 900\n255\n");
        repeat (3) @(negedge clk);
        reset_n = 1;
        while (dut.busy) @(negedge clk);
        // Seed only when all earlier notes remain visible at frame 198.
        // Full start/loop timing is separately checked by tb_waterfall.
        if (`SCORE_SEED_PREVIEW) begin
            dut.engine.frame_number = 16'd198;
            frame=199;
        end else frame=1;
        for (frame=frame; frame<=200; frame=frame+1) begin
            tick = 1;
            @(negedge clk); tick = 0;
            while (dut.busy) @(negedge clk);
            @(negedge clk);
        end
        for (j=0; j<900; j=j+1) begin
            for (i=0; i<1600; i=i+1) begin
                x=i; y=j; input_valid=1;
                @(negedge clk);
            end
        end
        input_valid=0; x=1800; y=1000;
        repeat (4) @(negedge clk);
        $fclose(file_handle);
        if (checked != 1440000) $fatal(1,"Incomplete image");
        $display("PASS: 1600x900 waterfall image, every RGB pixel, pipeline alignment");
        // Engine timing is checked independently for every frame. Here force
        // one highlight at a time and inspect every key to verify the mapping.
        force dut.lit_keys = highlight_mask;
        for (key=0; key<88; key=key+1) begin
            highlight_mask = 88'd1 << key;
            for (i=0; i<88; i=i+1) begin
                x=key_centers[i][10:0];
                y=key_centers[i][11] ? 760 : 850;
                repeat(5) @(negedge clk);
                if (i == key) begin
                    key_color=key_centers[i][11] ? (i<39 ? 24'h22bbef : 24'h9663e8)
                        : (i<39 ? 24'h56dfff : 24'hbb91ff);
                    seen[i]=1;
                end else key_color=key_centers[i][11] ? 24'h121725 : 24'heef2fa;
                if (rgb !== key_color)
                    $fatal(1,"Keyboard mapping mismatch selected=%0d observed=%0d",key,i);
            end
        end
        release dut.lit_keys;
        if (seen !== {88{1'b1}}) $fatal(1,"Not all 88 rendered highlights tested");
        $display("PASS: all 52 white and 36 black keys, highlight/release and neighbour isolation");
        passed=1;
        $finish;
    end
endmodule
