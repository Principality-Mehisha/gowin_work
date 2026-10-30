// Single-clock byte FIFO, including simultaneous push/pop at full capacity.
module byte_fifo #(
    parameter integer ADDR_BITS = 8
) (
    input wire clk, rst_n,
    input wire [7:0] in_data,
    input wire in_valid,
    output wire in_ready,
    output wire [7:0] out_data,
    output wire out_valid,
    input wire out_ready,
    output reg [ADDR_BITS:0] used
);
    localparam integer DEPTH = 1 << ADDR_BITS;
    reg [7:0] mem [0:DEPTH-1];
    reg [ADDR_BITS-1:0] wr, rd;
    wire pop = out_valid && out_ready;
    wire push = in_valid && in_ready;
    assign out_valid = used != 0;
    assign out_data = mem[rd];
    assign in_ready = (used < DEPTH) || pop;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin wr<=0; rd<=0; used<=0; end
        else begin
            if (push) begin mem[wr]<=in_data; wr<=wr+1'b1; end
            if (pop) rd<=rd+1'b1;
            case ({push,pop})
                2'b10: used<=used+1'b1;
                2'b01: used<=used-1'b1;
                default: ;
            endcase
        end
    end
endmodule
