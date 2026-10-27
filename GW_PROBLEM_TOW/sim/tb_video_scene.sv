`timescale 1ns/1ps
module tb_video_scene;
    reg clk = 0;
    always #5 clk = ~clk;
    reg reset_n = 0, tick = 0, update=0, active=1;
    reg [87:0] lit_keys=0;
    reg [10:0] x = 1800;
    reg [9:0] y = 1000;
    wire [23:0] rgb;
    reg passed = 0;
    piano_scene dut(.clk(clk), .reset_n(reset_n), .frame_tick(tick),
        .x(x), .y(y), .test_pattern(1'b0), .rgb(rgb),
        .update(update),.active(active),.elapsed_ms(32'd3334),.lit_keys(lit_keys));
    reg [23:0] expected [0:1439999];
    reg [87:0] expected_keys [0:0];

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
        $readmemh("output/video_integration/expected_frame.hex",expected);
        $readmemh("output/video_integration/scene_keys.hex",expected_keys);
        lit_keys=expected_keys[0];
        file_handle = $fopen("output/video_integration/waterfall_rtl.ppm","wb");
        $fwrite(file_handle,"P6\n1600 900\n255\n");
        repeat (3) @(negedge clk);
        reset_n = 1;
        @(negedge clk);update=1;@(negedge clk);update=0;
        while (dut.engine_busy) @(negedge clk);
        // Prepare line zero in the preceding line's horizontal blank.
        x=1600;y=999;@(negedge clk);x=1601;
        repeat(198)@(negedge clk);
        for (j=0; j<900; j=j+1) begin
            for (i=0; i<1600; i=i+1) begin
                x=i; y=j; input_valid=1;
                @(negedge clk);
            end
            input_valid=0;
            for(i=1600;i<1800;i=i+1)begin x=i;@(negedge clk);end
        end
        input_valid=0; x=1800; y=1000;
        repeat (4) @(negedge clk);
        $fclose(file_handle);
        if (checked != 1440000) $fatal(1,"Incomplete image");
        $display("PASS: 1600x900 waterfall image, every RGB pixel, pipeline alignment");
        if(dut.overflow || dut.line_overflow)$fatal(1,"Scene overflow");
        passed=1;$finish;
    end
    initial begin #30000000;$fatal(1,"Scene timeout");end
endmodule
