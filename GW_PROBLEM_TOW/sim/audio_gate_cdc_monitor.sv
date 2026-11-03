`timescale 1ns/1ps
// Check each 150 MHz accepted event against its 50 MHz ACK, then the displayed gates.
module audio_gate_cdc_monitor (
    input wire sys_clk,audio_clk,reset_n,enable,sys_clear,
    input wire source_fire,source_marimba,source_update,source_on,
    input wire [6:0] source_note,
    input wire ack_valid,ack_clear,ack_marimba,ack_update,ack_on,
    input wire [6:0] ack_note,
    input wire [87:0] keys
);
    reg [9:0] events[0:4095];
    integer written=0,received=0;
    reg [87:0] expected=0;
    always @(posedge audio_clk or negedge reset_n)begin
        if(!reset_n)written=0;
        else if(source_fire)begin
            if(written-received>=4096)$fatal(1,"Gate monitor capacity");
            events[written&4095]={source_marimba,source_update,source_on,source_note};
            written=written+1;
        end
    end
    always @(posedge sys_clk or negedge reset_n)begin
        if(!reset_n)begin received=0;expected=0;end
        else begin
            if(sys_clear || (ack_valid && ack_clear))expected=0;
            if(ack_valid && !ack_clear)begin
                if(received>=written ||
                   {ack_marimba,ack_update,ack_on,ack_note}!==events[received&4095])
                    $fatal(1,"Displayed note ACK lost, duplicated or changed an accepted audio event");
                received=received+1;
                if(!sys_clear && !ack_marimba && !ack_update)begin
                    if(ack_note==127)expected={88{ack_on}};
                    else if(ack_note<88)expected[ack_note]=ack_on;
                end
            end
        end
    end
    always @(negedge sys_clk)begin
        #1;
        if(reset_n && enable && keys!==expected)
            $fatal(1,"Waterfall/guide gates differ from acknowledged piano events");
    end
endmodule
