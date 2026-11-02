`timescale 1ns/1ps
// Independent wire decoder, including pulse widths, bit periods and latch gap.
module ws2812_monitor #(
    parameter integer PIXELS=16,BIT_CYCLES=63,T0H_CYCLES=15,T1H_CYCLES=45,
    parameter integer RESET_CYCLES=15000
) (
    input wire clk,reset_n,data_in,
    output reg [PIXELS*24-1:0] frame=0,
    output reg frame_valid=0,
    output integer frames=0
);
    reg previous=0,pending=0;
    reg [PIXELS*24-1:0] shift=0;
    integer ticks=0,last_rise=0,high_ticks=0,low_ticks=0,bits=0;
    always @(negedge clk) begin
        if(reset_n!==1'b1) begin
            previous=0;pending=0;frame=0;frame_valid=0;shift=0;frames=0;
            ticks=0;last_rise=0;high_ticks=0;bits=0;
            low_ticks=data_in===1'b0 ? low_ticks+1 : 0;
        end else begin
            ticks=ticks+1;frame_valid=0;
            if(data_in===1'bx)$fatal(1,"Unknown LED data");
            if(data_in && !previous) begin
                if(bits==0) begin
                    if(low_ticks<RESET_CYCLES)$fatal(1,"LED reset gap too short: %0d",low_ticks);
                    shift=0;
                end else if(ticks-last_rise!=BIT_CYCLES)
                    $fatal(1,"LED bit period %0d",ticks-last_rise);
                last_rise=ticks;high_ticks=1;low_ticks=0;
            end else if(data_in)high_ticks=high_ticks+1;
            else begin
                low_ticks=low_ticks+1;
                if(previous) begin
                    if(high_ticks!=T0H_CYCLES && high_ticks!=T1H_CYCLES)
                        $fatal(1,"LED high width %0d",high_ticks);
                    shift={shift[PIXELS*24-2:0],high_ticks==T1H_CYCLES};
                    bits=bits+1;
                    if(bits==PIXELS*24)begin bits=0;pending=1;end
                end
                if(pending && low_ticks==RESET_CYCLES)begin
                    frame=shift;frame_valid=1;frames=frames+1;pending=0;
                end
            end
            previous=data_in;
        end
    end
endmodule
