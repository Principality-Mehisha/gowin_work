// Active-low button: synchronize both edges, then emit one pulse per press.
module button_debounce #(
    parameter integer STABLE_CYCLES = 1_000_000
) (
    input  wire clk,
    input  wire rst_n,
    input  wire key_n,
    output reg  press
);
    reg [1:0] sync;
    reg [31:0] count;
    reg stable;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync   <= 2'b11;
            count  <= 32'd0;
            stable <= 1'b1;
            press  <= 1'b0;
        end else begin
            sync  <= {sync[0], key_n};
            press <= 1'b0;
            if (sync[1] == stable)
                count <= 32'd0;
            else if (count == STABLE_CYCLES - 1) begin
                count  <= 32'd0;
                stable <= sync[1];
                press  <= !sync[1];
            end else
                count <= count + 32'd1;
        end
    end
endmodule
