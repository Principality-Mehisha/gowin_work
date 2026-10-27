`timescale 1ns/1ps
// Fault reporting stays alive even when the DDR user clock stops.
module ddr3_status #(
    parameter integer INIT_TIMEOUT=150000000,
    parameter integer CLOCK_TIMEOUT=5000000,
    parameter integer LED_TICK_CYCLES=10000000 // 200 ms at 50 MHz
)(
    input wire clk, input wire reset,
    input wire calibrated, input wire passed, input wire failed,
    input wire [3:0] error_code,
    input wire controller_reset, input wire pll_locked,
    input wire ui_heartbeat,
    output wire led_run, output wire led_result,
    output wire fault, output reg [3:0] fault_code
);
    (* ASYNC_REG="TRUE" *) reg [5:0] sync1, sync2;
    (* ASYNC_REG="TRUE" *) reg [3:0] code_sync1, code_sync2;
    reg last_heartbeat, seen_calibration;
    reg [1:0] failure_settle;
    reg [31:0] init_timer, clock_timer;
    reg [25:0] blink;
    reg fault_latched, pass_latched;
    localparam integer TICK_BITS=$clog2(LED_TICK_CYCLES+1);
    reg [TICK_BITS-1:0] led_tick;
    reg [5:0] led_slot;
    // Each pulse is 200 ms on + 200 ms off, followed by 1.2 seconds off.
    wire [5:0] pulse_slots={1'b0,fault_code,1'b0};
    wire [5:0] last_slot=pulse_slots+6'd5;
    assign fault=fault_latched;
    assign led_run=!fault_latched && (sync2[0] ? blink[22] : blink[24]);
    assign led_result=fault_latched ? (led_slot<pulse_slots && !led_slot[0]) : pass_latched;
    always @(posedge clk) begin
        if(reset) begin
            sync1<=0; sync2<=0; code_sync1<=0; code_sync2<=0;
            last_heartbeat<=0; seen_calibration<=0; failure_settle<=0;
            init_timer<=0; clock_timer<=0; blink<=0;
            fault_latched<=0; pass_latched<=0; fault_code<=0;
            led_tick<=0; led_slot<=0;
        end else begin
            sync1<={pll_locked,controller_reset,ui_heartbeat,failed,passed,calibrated};
            sync2<=sync1;
            code_sync1<=error_code; code_sync2<=code_sync1;
            blink<=blink+1'b1;
            last_heartbeat<=sync2[3];
            if(sync2[0]) seen_calibration<=1;
            if(sync2[1]) pass_latched<=1;
            // Wait two extra board-clock cycles after synchronized failure
            // before capturing the sticky UI-domain error code.
            if(!sync2[2]) failure_settle<=0;
            else if(failure_settle!=3) failure_settle<=failure_settle+1'b1;
            if(!sync2[0] && !seen_calibration && init_timer<INIT_TIMEOUT-1)
                init_timer<=init_timer+1'b1;
            if(!seen_calibration || sync2[3]!=last_heartbeat) clock_timer<=0;
            else if(clock_timer<CLOCK_TIMEOUT-1) clock_timer<=clock_timer+1'b1;
            if(!fault_latched) begin
                led_slot<=0; led_tick<=0;
                if(sync2[2] && failure_settle==3) begin
                    fault_latched<=1;
                    fault_code<=code_sync2==0 ? 4'd11 : code_sync2;
                end else if(seen_calibration && !sync2[5]) begin
                    fault_latched<=1; fault_code<=10;
                end else if(seen_calibration && sync2[4]) begin
                    fault_latched<=1; fault_code<=9;
                end else if(seen_calibration && !sync2[0]) begin
                    fault_latched<=1; fault_code<=5;
                end else if(seen_calibration && clock_timer==CLOCK_TIMEOUT-1) begin
                    fault_latched<=1; fault_code<=8;
                end else if(!seen_calibration && !sync2[0] && init_timer==INIT_TIMEOUT-1) begin
                    fault_latched<=1; fault_code<=7;
                end
            end else if(led_tick==LED_TICK_CYCLES-1) begin
                led_tick<=0;
                if(led_slot==last_slot) led_slot<=0;
                else led_slot<=led_slot+1'b1;
            end else led_tick<=led_tick+1'b1;
        end
    end
endmodule
