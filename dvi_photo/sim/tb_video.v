`timescale 1ns/1ps
module tb_video;
    reg clk = 0;
    always #20 clk = ~clk;
    reg reset_n = 0;
    reg test_pattern = 0;
    wire [7:0] r, g, b;
    wire hs, vs, de;
    video_source dut(.pixel_clk(clk), .reset_n(reset_n),
        .test_pattern(test_pattern), .red(r), .green(g), .blue(b),
        .hsync(hs), .vsync(vs), .de(de));
    reg [15:0] pixels [0:49919];
    integer x, y, pass, address, count, f;
    reg [15:0] pixel;
    reg [23:0] expected;
    initial begin
        $readmemh("src/photo_rgb565.hex", pixels);
        f = $fopen("sim/frame.ppm", "w");
        $fwrite(f, "P3\n640 480\n255\n");
        repeat (3) @(negedge clk);
        reset_n = 1;
        count = 0;
        for (pass = 0; pass < 2; pass = pass + 1) begin
            for (y = 0; y < 525; y = y + 1) begin
                for (x = 0; x < 800; x = x + 1) begin
                    @(posedge clk);
                    #1;
                    if (de !== ((x < 640) && (y < 480)) ||
                        hs !== !((x >= 656) && (x < 752)) ||
                        vs !== !((y >= 490) && (y < 492)))
                        $fatal(1, "Timing mismatch x=%0d y=%0d", x, y);
                    expected = 0;
                    if ((x < 640) && (y < 480)) begin
                        if (pass == 0 && x >= 112 && x < 528) begin
                            address = (y / 2) * 208 + (x - 112) / 2;
                            pixel = pixels[address];
                            expected = {pixel[15:11], pixel[15:13],
                                pixel[10:5], pixel[10:9], pixel[4:0], pixel[4:2]};
                        end else if (pass == 1) begin
                            case (x / 80)
                                0: expected = 24'hffffff;
                                1: expected = 24'hffff00;
                                2: expected = 24'h00ffff;
                                3: expected = 24'h00ff00;
                                4: expected = 24'hff00ff;
                                5: expected = 24'hff0000;
                                6: expected = 24'h0000ff;
                                7: expected = 24'h000000;
                            endcase
                        end
                        if (pass == 0) begin
                            $fwrite(f, "%0d %0d %0d\n", r, g, b);
                            count = count + 1;
                        end
                    end
                    if ({r,g,b} !== expected)
                        $fatal(1, "Pixel mismatch pass=%0d x=%0d y=%0d", pass,x,y);
                end
            end
            @(negedge clk);
            test_pattern = 1;
        end
        $fclose(f);
        if (count != 307200) $fatal(1, "Incorrect frame size");
        $display("PASS: photo pixels, 2x scaling, black bars, color bars, two 800x525 frames");
        $finish;
    end
endmodule
