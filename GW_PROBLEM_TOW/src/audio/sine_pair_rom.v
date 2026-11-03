// Two synchronous neighboring reads, shared by the mutually exclusive timbres.
module sine_pair_rom #(
    parameter SINE_FILE="src/rom/sine256.hex"
) (
    input wire clk,enable,
    input wire [7:0] address,
    output reg signed [15:0] value,next_value
);
    reg signed [15:0] memory[0:255];
    wire [7:0] next_address=address+8'd1;
    initial $readmemh(SINE_FILE,memory);
    always @(posedge clk)if(enable)begin
        value<=memory[address];
        next_value<=memory[next_address];
    end
endmodule
