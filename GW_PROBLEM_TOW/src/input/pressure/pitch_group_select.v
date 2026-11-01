// Synchronize external group switches, then qualify the whole mask before
// decoding its lowest asserted bit. An empty mask selects group zero.
module pitch_group_select #(
    parameter integer STABLE_CYCLES=50000
) (
    input wire clk, reset_n,
    input wire [6:0] pitch_group,
    output reg [2:0] selected_group,
    output wire [6:0] base_note
);
    localparam integer COUNT_BITS=STABLE_CYCLES<2 ? 1 : $clog2(STABLE_CYCLES);
    reg [6:0] group_meta, group_sync, candidate;
    reg [COUNT_BITS-1:0] stable_count;
    function [2:0] lowest_group;
        input [6:0] mask;
        begin
            if(mask[0]) lowest_group=0;
            else if(mask[1]) lowest_group=1;
            else if(mask[2]) lowest_group=2;
            else if(mask[3]) lowest_group=3;
            else if(mask[4]) lowest_group=4;
            else if(mask[5]) lowest_group=5;
            else if(mask[6]) lowest_group=6;
            else lowest_group=0;
        end
    endfunction
    assign base_note={selected_group,4'b0000};
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            group_meta<=0; group_sync<=0; candidate<=0;
            stable_count<=0; selected_group<=0;
        end else begin
            group_meta<=pitch_group;
            group_sync<=group_meta;
            if(group_sync!=candidate) begin
                candidate<=group_sync; stable_count<=0;
            end else if(stable_count==STABLE_CYCLES-1) begin
                selected_group<=lowest_group(candidate);
            end else stable_count<=stable_count+1'b1;
        end
    end
endmodule
