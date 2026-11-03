// Fast attack, exponential release peak limiter. The current sample is delayed
// until its safe gain is known; a 36-cycle restoring divider avoids a huge / unit.
module output_limiter #(
    parameter integer MASTER_SHIFT=2,
    parameter integer SAMPLE_RATE_RATIO=1,
    parameter integer CEILING=30000
) (
    input wire clk, reset_n, clear,
    input wire in_valid,
    input wire signed [31:0] in_sample,
    output reg out_valid,
    output reg signed [15:0] out_sample,
    output reg limiting,
    output reg saturated
);
    reg [21:0] peak;
    localparam RATE_BITS=SAMPLE_RATE_RATIO<2 ? 1 : $clog2(SAMPLE_RATE_RATIO);
    reg [RATE_BITS-1:0] rate_phase;
    reg release_step;
    // Worst-case bound even if every voice used the maximum 4x compensation:
    // 88 * 30000 * 4 * (255/256) / 4 < 2^22.
    reg signed [31:0] sample_reg;
    reg signed [31:0] scaled;
    reg [21:0] magnitude, decayed;
    reg [21:0] magnitude_reg, decay_reg, required_peak_reg;
    reg [35:0] dividend, quotient;
    reg [22:0] remainder;
    reg [21:0] denominator;
    reg [5:0] count;
    reg [2:0] state;
    reg [20:0] gain;
    reg signed [53:0] product;
    wire signed [53:0] biased_product =
        product + (product[53] ? 54'sd524287 : 54'sd524288);
    wire signed [33:0] rounded = biased_product[53:20];
    reg signed [33:0] rounded_reg;
    wire [23:0] shifted_rem = {remainder, dividend[35]};
    always @* begin
        // Round to nearest, ties away from zero, including negative samples.
            scaled = (in_sample + (in_sample < 0 ?
                     (1 << (MASTER_SHIFT-1))-1 : (1 << (MASTER_SHIFT-1)))) >>> MASTER_SHIFT;
        magnitude = sample_reg < 0 ? -sample_reg : sample_reg;
        decayed = !release_step ? peak : (peak > 0 ? peak - (peak[21:12] == 0 ?
                           22'd1 : {12'd0,peak[21:12]}) : 22'd0);
    end
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state<=0; peak<=0; out_sample<=0; out_valid<=0;
            rate_phase<=0;release_step<=1;
            limiting<=0; saturated<=0; sample_reg<=0;
            dividend<=0; quotient<=0; remainder<=0; denominator<=1;
            count<=0; gain<=0; product<=0;
            magnitude_reg<=0; decay_reg<=0; required_peak_reg<=0; rounded_reg<=0;
        end else if (clear) begin
            state<=0; peak<=0; out_sample<=0; out_valid<=0;
            rate_phase<=0;release_step<=1;
            limiting<=0; saturated<=0;
        end else begin
            out_valid<=0;
            case (state)
                0: if (in_valid) begin
                    release_step<=rate_phase==0;
                    rate_phase<=rate_phase==SAMPLE_RATE_RATIO-1 ? 0 : rate_phase+1'b1;
                    sample_reg<=scaled;
                    state<=4;
                end
                4: begin
                    magnitude_reg<=magnitude;
                    decay_reg<=decayed;
                    state<=5;
                end
                5: begin
                    required_peak_reg<=magnitude_reg > decay_reg ? magnitude_reg : decay_reg;
                    state<=6;
                end
                6: begin
                    peak<=required_peak_reg;
                    limiting <= required_peak_reg > CEILING;
                    saturated<=0;
                    if (required_peak_reg > CEILING) begin
                        dividend<=CEILING * 36'd1048576;
                        quotient<=0; remainder<=0;
                        denominator<=required_peak_reg;
                        count<=0; state<=1;
                    end else begin gain<=21'd1048576; state<=2; end
                end
                1: begin
                    dividend<={dividend[34:0],1'b0};
                    if (shifted_rem >= {2'b0,denominator}) begin
                        remainder<=shifted_rem - denominator;
                        quotient<={quotient[34:0],1'b1};
                    end else begin
                        remainder<=shifted_rem[22:0];
                        quotient<={quotient[34:0],1'b0};
                    end
                    if (count == 35) begin
                        gain <= {quotient[19:0], (shifted_rem >= {2'b0,denominator})};
                        state<=2;
                    end else count<=count+1'b1;
                end
                2: begin product <= sample_reg * $signed({1'b0,gain}); state<=3; end
                3: begin rounded_reg<=rounded; state<=7; end
                7: begin
                    if (rounded_reg > 32767) begin out_sample<=32767; saturated<=1; end
                    else if (rounded_reg < -32768) begin out_sample<=-32768; saturated<=1; end
                    else out_sample<=rounded_reg[15:0];
                    out_valid<=1; state<=0;
                end
                default: state<=0;
            endcase
        end
    end
endmodule
