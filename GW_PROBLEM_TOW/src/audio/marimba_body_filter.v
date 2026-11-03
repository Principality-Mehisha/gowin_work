// Two fixed damped resonators for body/tube coloration. Their complete
// response is included in per-note loudness calibration. Signed Q2.14.
module marimba_body_filter #(parameter integer SAMPLE_RATE_RATIO=1) (
    input wire clk, reset_n, clear,
    input wire in_valid,
    input wire signed [31:0] in_sample,
    output reg out_valid,
    output reg signed [31:0] out_sample
);
    // 3x-rate poles retain the old frequencies and decay times in seconds.
    localparam signed [15:0] R1_A1 = SAMPLE_RATE_RATIO==3 ? 16'sd31946 : 16'sd30138;
    localparam signed [15:0] R1_A2 = SAMPLE_RATE_RATIO==3 ? 16'sd15610 : 16'sd14171;
    localparam signed [15:0] R2_A1 = SAMPLE_RATE_RATIO==3 ? 16'sd31264 : 16'sd27708;
    localparam signed [15:0] R2_A2 = SAMPLE_RATE_RATIO==3 ? 16'sd15046 : 16'sd12688;
    localparam signed [15:0] R1_B = SAMPLE_RATE_RATIO==3 ? 16'sd118 : 16'sd1024;
    localparam signed [15:0] R2_B = SAMPLE_RATE_RATIO==3 ? 16'sd62 : 16'sd512;
    reg [3:0] state;
    reg signed [39:0] input_reg, r1_y1, r1_y2, r2_y1, r2_y2;
    reg signed [39:0] r1_next, r2_next;
    reg signed [39:0] mult_a;
    reg signed [15:0] mult_b;
    reg signed [55:0] product_1,product_2;
    reg signed [39:0] input_1,input_2,feedback_1,feedback_2,body_partial,body_output;
    wire signed [55:0] product = mult_a * mult_b;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= 0; input_reg <= 0;
            r1_y1 <= 0; r1_y2 <= 0; r2_y1 <= 0; r2_y2 <= 0;
            r1_next <= 0; r2_next <= 0;
            mult_a <= 0; mult_b <= 0; product_1 <= 0;product_2<=0;
            input_1<=0;input_2<=0;feedback_1<=0;feedback_2<=0;body_partial<=0;body_output<=0;
            out_valid <= 0; out_sample <= 0;
        end else if (clear) begin
            state <= 0; r1_y1 <= 0; r1_y2 <= 0; r2_y1 <= 0; r2_y2 <= 0;
            out_valid <= 0; out_sample <= 0;
        end else begin
            out_valid <= 0;
            case (state)
                0: if (in_valid) begin
                    input_reg <= {{8{in_sample[31]}}, in_sample};
                    mult_a <= r1_y1; mult_b <= R1_A1; state <= 1;
                end
                1: begin
                    product_1 <= product;
                    mult_a <= r1_y2; mult_b <= R1_A2; state <= 2;
                end
                2: begin
                    product_2<=product;
                    mult_a<=input_reg;mult_b<=R1_B;state<=3;
                end
                3: begin
                    input_1<=product>>>14;
                    feedback_1<=(product_1>>>14)-(product_2>>>14);
                    mult_a<=r2_y1;mult_b<=R2_A1;state<=4;
                end
                4: begin
                    product_1<=product;
                    mult_a<=r2_y2;mult_b<=R2_A2;state<=5;
                end
                5: begin
                    product_2<=product;r1_next<=input_1+feedback_1;
                    mult_a<=input_reg;mult_b<=R2_B;state<=6;
                end
                6:begin
                    input_2<=product>>>14;
                    feedback_2<=(product_1>>>14)-(product_2>>>14);state<=7;
                end
                7:begin r2_next<=input_2+feedback_2;state<=8;end
                8:begin
                    r1_y2 <= r1_y1; r1_y1 <= r1_next;
                    r2_y2 <= r2_y1; r2_y1 <= r2_next;
                    body_partial<=input_reg+(r1_next>>>2);state<=9;
                end
                9:begin body_output<=body_partial+(r2_next>>>3);state<=10;end
                10:begin
                    if (body_output > 40'sh007fffffff)
                        out_sample <= 32'sh7fffffff;
                    else if (body_output < -40'sh0080000000)
                        out_sample <= -32'sh80000000;
                    else
                        out_sample <= body_output[31:0];
                    out_valid <= 1; state <= 0;
                end
                default: state <= 0;
            endcase
        end
    end
endmodule
