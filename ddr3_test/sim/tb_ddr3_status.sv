`timescale 1ns/1ps
module tb_ddr3_status;
    reg clk=0;
    always #10 clk=~clk;
    reg reset=1, calibrated=0, passed=0, failed=0, heartbeat=0;
    reg controller_reset=0, pll_locked=1;
    reg [3:0] error_code=0;
    wire run_led,result_led,fault;
    wire [3:0] fault_code;
    reg simulation_passed=0;
    ddr3_status #(.INIT_TIMEOUT(24),.CLOCK_TIMEOUT(16),.LED_TICK_CYCLES(2)) dut(
        .clk(clk),.reset(reset),.calibrated(calibrated),.passed(passed),
        .failed(failed),.error_code(error_code),.controller_reset(controller_reset),
        .pll_locked(pll_locked),.ui_heartbeat(heartbeat),.led_run(run_led),
        .led_result(result_led),.fault(fault),.fault_code(fault_code));
    task ticks(input integer n);
        repeat(n) @(negedge clk);
    endtask
    task restart;
        begin reset=1; calibrated=0; passed=0; failed=0; heartbeat=0;
        error_code=0; controller_reset=0; pll_locked=1;
        ticks(3); reset=0; end
    endtask
    task check_code(input integer code);
        if(!fault || fault_code!=code) $fatal(1,"Expected %0d, got %0d fault %b",code,fault_code,fault);
    endtask
    task check_pulses(input integer count);
        integer i,edges;
        reg prev;
        begin
            while(dut.led_slot!=0 || dut.led_tick!=0) ticks(1);
            prev=0; edges=0;
            for(i=0;i<(2*count+6)*2;i=i+1) begin
                if(result_led && !prev) edges=edges+1;
                prev=result_led; ticks(1);
            end
            if(edges!=count) $fatal(1,"Expected %0d LED pulses, got %0d",count,edges);
            if(run_led) $fatal(1,"READY should be off on fault");
        end
    endtask
    integer code;
    initial begin
        restart(); ticks(30); check_code(7); check_pulses(7);
        restart(); calibrated=1;
        repeat(8) begin heartbeat=~heartbeat; ticks(4); end
        if(fault) $fatal(1,"False clock timeout");
        passed=1; ticks(4);
        if(!result_led) $fatal(1,"Pass LED");
        ticks(20); check_code(8); check_pulses(8);
        restart(); calibrated=1; ticks(5); calibrated=0; ticks(4);
        check_code(5);
        restart(); calibrated=1; ticks(5); controller_reset=1; ticks(4);
        check_code(9); check_pulses(9);
        restart(); calibrated=1; ticks(5); pll_locked=0; ticks(4);
        check_code(10); check_pulses(10);
        for(code=1;code<=6;code=code+1) begin
            restart(); error_code=code; failed=1;
            ticks(10); check_code(code);
            failed=0; error_code=0; ticks(4);
            check_code(code); check_pulses(code);
        end
        restart(); error_code=0; failed=1; ticks(10); check_code(11);
        check_pulses(11);
        simulation_passed=1; $display("ALL STATUS TESTS PASSED (codes and LED pulse counts)"); $finish;
    end
    initial begin #100000; $fatal(1,"Status test timeout"); end
endmodule
