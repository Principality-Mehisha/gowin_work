`timescale 1ns/1ps
module tb_pressure_adc_scan #(
    parameter integer SLOT_CYCLES=1500,
    parameter integer ADC_HALF_CYCLES=50,
    parameter integer SAMPLE_CYCLE=SLOT_CYCLES-10
);
    reg clk=0,reset_n=0,passed=0;
    always #10 clk=~clk;
    wire [3:0] select,sample_key;
    wire select_n,adc_clk,sample_valid;
    wire [11:0] sample_data;
    reg [11:0] adc_data=0,pipeline0=0,pipeline1=0;
    reg [3:0] mapping[0:15];
    integer samples=0,expected_key=0,expected_slot=0,adc_phase=0;
    integer expected_adc=0,expected_valid,saved,i;
    pressure_adc_scan #(.SLOT_CYCLES(SLOT_CYCLES),.ADC_HALF_CYCLES(ADC_HALF_CYCLES),
        .SAMPLE_CYCLE(SAMPLE_CYCLE)) dut(
        .clk(clk),.reset_n(reset_n),.adc_data(adc_data),
        .select(select),.select_n(select_n),.adc_clk(adc_clk),
        .sample_valid(sample_valid),.sample_key(sample_key),.sample_data(sample_data));
    function [11:0] voltage(input [3:0] channel);
        voltage=12'd1000+channel*12'd37;
    endfunction
    // Match the existing ADC model: two conversion periods plus 120 ns tCO.
    always @(posedge adc_clk)begin
        pipeline0<=voltage(select);pipeline1<=pipeline0;adc_data<=#120 pipeline1;
    end
    always @(posedge clk)begin
        if(!reset_n)begin
            expected_key=0;expected_slot=0;adc_phase=0;expected_adc=0;
            #1;
            if(select!==mapping[0] || adc_clk!==0 || sample_valid!==0 ||
               sample_key!==0 || sample_data!==0 || select_n!==0)
                $fatal(1,"ADC reset did not restore the first mapped channel");
        end else begin
            if(select!==mapping[expected_key] || dut.slot_count!=expected_slot)
                $fatal(1,"Mux scan order/slot mismatch key=%0d select=%0d",expected_key,select);
            expected_valid=expected_slot==SAMPLE_CYCLE;
            if(adc_phase==ADC_HALF_CYCLES-1)begin
                adc_phase=0;expected_adc=!expected_adc;
            end else adc_phase=adc_phase+1;
            if(expected_slot==SLOT_CYCLES-1)begin
                expected_slot=0;expected_key=(expected_key+1)%16;
            end else expected_slot=expected_slot+1;
            #1;
            if(select!==mapping[expected_key] || select_n!==0 ||
               adc_clk!==expected_adc[0] || sample_valid!==expected_valid[0])
                $fatal(1,"Mux changed early or ADC/sample timing changed");
            if(sample_valid)begin
                if(sample_key!==(samples%16) ||
                   sample_data!==voltage(mapping[samples%16]))
                    $fatal(1,"Logical sample/channel mismatch sample=%0d key=%0d data=%0d",
                           samples,sample_key,sample_data);
                samples=samples+1;
            end
        end
    end
    initial begin
        mapping[0]=12;mapping[1]=8;mapping[2]=7;mapping[3]=3;
        mapping[4]=2;mapping[5]=6;mapping[6]=9;mapping[7]=13;
        mapping[8]=14;mapping[9]=10;mapping[10]=5;mapping[11]=1;
        mapping[12]=0;mapping[13]=4;mapping[14]=11;mapping[15]=15;
        repeat(4)@(negedge clk);reset_n=1;
        wait(samples==48);
        // Reset mid-slot, then check the first two complete scans again.
        repeat(5)@(negedge clk);reset_n=0;
        repeat(4)@(negedge clk);saved=samples;reset_n=1;
        wait(samples==saved+32);
        passed=1;
        $display("PASS ADC scan: Excel column A minus one, all 16 mux addresses/logical sample keys, ADC latency/data, timing, wrap and reset; SLOT=%0d HALF=%0d SAMPLE=%0d, %0d samples",
                 SLOT_CYCLES,ADC_HALF_CYCLES,SAMPLE_CYCLE,samples);
        $finish;
    end
    initial begin #20000000;$fatal(1,"ADC scan test timeout");end
endmodule
