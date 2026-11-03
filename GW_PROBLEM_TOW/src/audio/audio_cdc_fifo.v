// Handshake adapter for the generated Gowin 32x16 dual-clock FIFO.
// Both domains reset together, assert asynchronously and release locally.
module audio_cdc_fifo (
    input wire reset_n,wr_clk,rd_clk,
    input wire [31:0] wr_data,
    input wire wr_valid,
    output wire wr_ready,
    output wire wr_almost_full,
    output wire wr_domain_ready,
    output reg [31:0] rd_data,
    output reg rd_valid,
    input wire rd_ready
);
    reg [3:0] wr_release,rd_release;
    always @(posedge wr_clk or negedge reset_n)
        if(!reset_n)wr_release<=0;
        else wr_release<={wr_release[2:0],1'b1};
    always @(posedge rd_clk or negedge reset_n)
        if(!reset_n)rd_release<=0;
        else rd_release<={rd_release[2:0],1'b1};
    wire full,empty;
    wire [31:0] q;
    reg [2:0] state;
    assign wr_ready=wr_release[3] && !full;
    assign wr_domain_ready=wr_release[3];
    wire read_enable=rd_release[3] && state==0 && !empty;
    Gowin_Audio_FIFO32 fifo(
        .Data(wr_data),.WrClk(wr_clk),.RdClk(rd_clk),
        .WrReset(!wr_release[3]),.RdReset(!rd_release[3]),
        .WrEn(wr_valid && wr_ready),.RdEn(read_enable),
        .Q(q),.Empty(empty),.Full(full),.Almost_Full(wr_almost_full));
    always @(posedge rd_clk or negedge reset_n) begin
        if(!reset_n)begin state<=0;rd_data<=0;rd_valid<=0;end
        else if(!rd_release[3])begin state<=0;rd_valid<=0;end
        else case(state)
            0:if(read_enable)state<=1;
            1:state<=2;
            2:state<=3;
            3:begin rd_data<=q;rd_valid<=1;state<=4;end
            4:if(rd_ready)begin rd_valid<=0;state<=0;end
            default:begin state<=0;rd_valid<=0;end
        endcase
    end
endmodule
