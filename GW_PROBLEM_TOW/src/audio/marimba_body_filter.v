// Two fixed damped resonators for body/tube coloration. Their complete
// response is included in per-note loudness calibration. Signed Q2.14.
module marimba_body_filter (
    input wire clk, reset_n, clear,
    input wire in_valid,
    input wire signed [31:0] in_sample,
    output reg out_valid,
    output reg signed [31:0] out_sample
);
    localparam signed [15:0] R1_A1 = 16'sd30138; // 385 Hz, r=0.93
    localparam signed [15:0] R1_A2 = 16'sd14171;
    localparam signed [15:0] R2_A1 = 16'sd27708; // 727 Hz, r=0.88
    localparam signed [15:0] R2_A2 = 16'sd12688;
    reg [2:0] state;
    reg signed [39:0] input_reg, r1_y1, r1_y2, r2_y1, r2_y2;
    reg signed [39:0] r1_next, r2_next;
    reg signed [39:0] mult_a;
    reg signed [15:0] mult_b;
    reg signed [55:0] product_1;
    wire signed [55:0] product = mult_a * mult_b;
    wire signed [39:0] body_mix =
        input_reg + (r1_next >>> 2) + (r2_next >>> 3);

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= 0; input_reg <= 0;
            r1_y1 <= 0; r1_y2 <= 0; r2_y1 <= 0; r2_y2 <= 0;
            r1_next <= 0; r2_next <= 0;
            mult_a <= 0; mult_b <= 0; product_1 <= 0;
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
                    r1_next <= (input_reg >>> 4) +
                               (product_1 >>> 14) - (product >>> 14);
                    mult_a <= r2_y1; mult_b <= R2_A1; state <= 3;
                end
                3: begin
                    product_1 <= product;
                    mult_a <= r2_y2; mult_b <= R2_A2; state <= 4;
                end
                4: begin
                    r2_next <= (input_reg >>> 5) +
                               (product_1 >>> 14) - (product >>> 14);
                    state <= 5;
                end
                5: begin
                    r1_y2 <= r1_y1; r1_y1 <= r1_next;
                    r2_y2 <= r2_y1; r2_y1 <= r2_next;
                    if (body_mix > 40'sh007fffffff)
                        out_sample <= 32'sh7fffffff;
                    else if (body_mix < -40'sh0080000000)
                        out_sample <= -32'sh80000000;
                    else
                        out_sample <= body_mix[31:0];
                    out_valid <= 1; state <= 0;
                end
                default: state <= 0;
            endcase
        end
    end
endmodule
