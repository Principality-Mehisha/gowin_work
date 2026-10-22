// Native TJC commands, recmod=0. Each snapshot updates page0.n0..n5:
// state, track, error, result, sequence, command. n5 is written last.
// payload layout: {state,track,error,result,sequence,command}.
module tjc_status_tx (
    input wire clk, rst_n,
    input wire [47:0] snapshot,
    input wire valid,
    output wire ready,
    output reg [7:0] byte_data,
    output wire byte_valid,
    input wire byte_ready
);
    reg busy;
    reg [47:0] saved;
    reg [2:0] field;
    reg [4:0] pos;
    reg [7:0] value;
    reg [3:0] hundreds, tens, ones;
    reg [4:0] digits;
    assign ready = !busy;
    assign byte_valid = busy;
    always @* begin
        case(field)
            0: value=saved[47:40]; 1: value=saved[39:32];
            2: value=saved[31:24]; 3: value=saved[23:16];
            4: value=saved[15:8]; default: value=saved[7:0];
        endcase
        hundreds=value/100; tens=(value%100)/10; ones=value%10;
        digits=(value>=100) ? 3 : ((value>=10) ? 2 : 1);
        case(pos)
            0: byte_data="p"; 1: byte_data="a"; 2: byte_data="g";
            3: byte_data="e"; 4: byte_data="0"; 5: byte_data=".";
            6: byte_data="n"; 7: byte_data="0"+field; 8: byte_data=".";
            9: byte_data="v"; 10: byte_data="a"; 11: byte_data="l";
            12: byte_data="=";
            default: begin
                byte_data=8'hff;
                if (pos==13) byte_data="0"+((digits==3)?hundreds:((digits==2)?tens:ones));
                else if (pos==14 && digits>=2) byte_data="0"+((digits==3)?tens:ones);
                else if (pos==15 && digits==3) byte_data="0"+ones;
            end
        endcase
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin busy<=0; saved<=0; field<=0; pos<=0; end
        else if (!busy) begin
            if (valid) begin saved<=snapshot; field<=0; pos<=0; busy<=1; end
        end else if (byte_ready) begin
            if (pos==15+digits) begin
                pos<=0;
                if (field==5) busy<=0;
                else field<=field+1'b1;
            end else pos<=pos+1'b1;
        end
    end
endmodule
