// Tang Mega 60K: autonomous 16-pixel demonstration, 50 MHz, no PLL/IP needed.
module ws2812_16 #(
    parameter integer FRAME_PERIOD_CYCLES = 1000000, // 20 ms / 50 fps
    parameter integer STEP_FRAMES = 10,             // 200 ms per chase step
    parameter integer POR_CYCLES = 65536,
    parameter [7:0] BRIGHTNESS = 8'd32
) (
    input  wire sys_clk,
    output wire led_data
);
    // Gowin synthesizes this initial value into the configuration power-up state.
    reg [31:0] por_count = 32'd0;
    wire rst_n = (por_count == POR_CYCLES - 1);
    always @(posedge sys_clk)
        if (!rst_n)
            por_count <= por_count + 1'b1;

    reg [31:0] refresh_count;
    reg [31:0] step_frames;
    reg [3:0] step;
    reg [2:0] mode;
    wire busy, done;
    wire start = rst_n && !busy && (refresh_count == 0);
    wire [383:0] frame_grb;

    always @(posedge sys_clk) begin
        if (!rst_n) begin
            refresh_count <= 32'd0;
            step_frames <= 32'd0;
            step <= 4'd0;
            mode <= 3'd0;
        end else begin
            if (refresh_count == FRAME_PERIOD_CYCLES - 1)
                refresh_count <= 32'd0;
            else
                refresh_count <= refresh_count + 1'b1;
            // Change animation only after an entire frame has been latched.
            if (done) begin
                if (step_frames == STEP_FRAMES - 1) begin
                    step_frames <= 32'd0;
                    if (step == 4'd15) begin
                        step <= 4'd0;
                        mode <= (mode == 3'd4) ? 3'd0 : mode + 1'b1;
                    end else
                        step <= step + 1'b1;
                end else
                    step_frames <= step_frames + 1'b1;
            end
        end
    end

    genvar pixel;
    generate
        for (pixel = 0; pixel < 16; pixel = pixel + 1) begin : pixels
            reg [23:0] color_grb;
            always @* begin
                case (mode)
                    3'd0: color_grb = {8'd0, BRIGHTNESS, 8'd0}; // red
                    3'd1: color_grb = {BRIGHTNESS, 8'd0, 8'd0}; // green
                    3'd2: color_grb = {8'd0, 8'd0, BRIGHTNESS}; // blue
                    3'd3: color_grb = {BRIGHTNESS, BRIGHTNESS, BRIGHTNESS};
                    3'd4: color_grb = (step == pixel) ? {8'd0, BRIGHTNESS, 8'd0} : 24'd0;
                    default: color_grb = 24'd0;
                endcase
            end
            assign frame_grb[383 - pixel*24 -: 24] = color_grb;
        end
    endgenerate

    ws2812_tx #(.LED_COUNT(16)) transmitter (
        .clk(sys_clk), .rst_n(rst_n), .start(start), .frame_grb(frame_grb),
        .data_o(led_data), .busy(busy), .done(done)
    );
endmodule
