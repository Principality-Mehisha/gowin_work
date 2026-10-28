`timescale 1ns/1ps
// Native-interface behavioral memory, not a DDR PHY/electrical model.
// Independent backpressure and refresh-like read stalls exercise the bridge.
module ddr_native_model #(
    parameter integer WORDS=1575
)(
    input wire clk,reset,
    input wire [2:0] cmd,input wire cmd_en,input wire [28:0] addr,
    input wire [127:0] wr_data,input wire wr_data_en,wr_data_end,
    input wire [15:0] wr_data_mask,
    output wire cmd_ready,wr_data_rdy,
    output reg [127:0] rd_data,output reg rd_data_valid,rd_data_end,
    input wire freeze,corrupt,end_fault,
    output reg [31:0] writes,reads
);
    reg [127:0] memory[0:WORDS-1];
    reg [31:0] cycle;
    reg [5:0] read_delay;
    reg [10:0] read_address;
    reg pending;
    integer last_write;
    assign cmd_ready=!freeze && !pending && cycle%13!=0 && cycle%13!=1;
    assign wr_data_rdy=!freeze && cycle%7!=0;
    always @(posedge clk) begin
        if(reset) begin
            cycle<=0;read_delay<=0;read_address<=0;pending<=0;
            rd_data<=0;rd_data_valid<=0;rd_data_end<=0;writes<=0;reads<=0;
            last_write<=-100;
        end else begin
            cycle<=cycle+1;rd_data_valid<=0;rd_data_end<=0;
            if(cmd_en)begin
                if(!cmd_ready || addr[2:0]!=0 || addr[28:14]!=0 || addr[13:3]>=WORDS)
                    $fatal(1,"Invalid/unaccepted native command %h",addr);
                if(cmd==0)begin
                    if(!wr_data_en || !wr_data_rdy || !wr_data_end || wr_data_mask!=0)
                        $fatal(1,"Unpaired DDR write");
                    if(cycle-last_write<3)$fatal(1,"Missing V3 two-cycle write gap");
                    last_write<=cycle;memory[addr[13:3]]<=wr_data;writes<=writes+1;
                end else if(cmd==1)begin
                    pending<=1;read_address<=addr[13:3];
                    read_delay<=cycle%17==0 ? 6'd32 : 6'd4;
                    reads<=reads+1;
                end else $fatal(1,"Unexpected command");
            end
            if(wr_data_en && !(cmd_en && cmd==0))$fatal(1,"Unpaired native data");
            if(pending && !freeze)begin
                if(read_delay!=0)read_delay<=read_delay-1'b1;
                else begin
                    rd_data<=memory[read_address] ^ (corrupt ? 128'd1 : 128'd0);
                    rd_data_valid<=1;rd_data_end<=!end_fault;pending<=0;
                end
            end
        end
    end
endmodule
