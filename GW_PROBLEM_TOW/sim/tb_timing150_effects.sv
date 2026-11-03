`timescale 1ns/1ps
module timing_effect_case #(parameter RATE=3, parameter CLOCK=150000000)(output reg passed=0);
    reg clk=0,rst=0,clear=0,valid=0;
    always #3.333333 clk=~clk;
    reg [1:0] mode=0;
    reg [6:0] amount=0;
    reg signed [15:0] sample=0;
    wire signed [15:0] actual,expected;
    wire av,ev,ab,eb,at,et,ae,ee;
    wire [1:0] am,em;
    audio_effects #(.CLOCK_HZ(CLOCK),.CONTROL_RATE_RATIO(RATE)) dut(
        .clk(clk),.reset_n(rst),.clear(clear),.in_valid(valid),.in_sample(sample),
        .mode(mode),.amount(amount),.out_sample(actual),.out_valid(av),
        .busy(ab),.tail_active(at),.deadline_error(ae),.applied_mode(am));
    audio_effects_before #(.CLOCK_HZ(CLOCK),.CONTROL_RATE_RATIO(RATE)) reference(
        .clk(clk),.reset_n(rst),.clear(clear),.in_valid(valid),.in_sample(sample),
        .mode(mode),.amount(amount),.out_sample(expected),.out_valid(ev),
        .busy(eb),.tail_active(et),.deadline_error(ee),.applied_mode(em));
    integer i,cycles,max_cycles=0,checked=0;
    reg seen_expected,seen_actual;
    reg signed [15:0] saved_expected,saved_actual;
    reg [31:0] random_bits=32'h51ae1203;
    initial begin
        repeat(5)@(negedge clk);rst=1;
        for(i=0;i<24000;i=i+1)begin
            @(negedge clk);
            random_bits={random_bits[30:0],random_bits[31]^random_bits[21]^random_bits[1]^random_bits[0]};
            mode=(i/1500)%4;amount=i%128;
            sample=i%5==0 ? -32768 : (i%7==0 ? 32767 : random_bits[15:0]);
            if(i%997==0)begin
                clear=1;@(negedge clk);clear=0;
                if(actual || expected || ab || eb || at || et)$fatal(1,"FX clear changed");
            end
            valid=1;seen_actual=0;seen_expected=0;
            @(negedge clk);valid=0;cycles=0;
            // Later control changes must not alter an already accepted sample.
            mode=mode^2'b11;amount=127-amount;
            while(!(seen_actual && seen_expected) && cycles<32)begin
                if(ev)begin seen_expected=1;saved_expected=expected;end
                if(av)begin seen_actual=1;saved_actual=actual;end
                @(negedge clk);cycles=cycles+1;
            end
            if(cycles>max_cycles)max_cycles=cycles;
            if(!seen_actual || !seen_expected || ae || ee || saved_actual!==saved_expected ||
               {at,am,dut.wet_gain,dut.vibrato_mix,dut.position,dut.filled,dut.lfo_phase} !==
               {et,em,reference.wet_gain,reference.vibrato_mix,reference.position,reference.filled,reference.lfo_phase})
                $fatal(1,"Retimed FX changed sample/state RATE=%0d i=%0d actual=%0d expected=%0d",
                       RATE,i,saved_actual,saved_expected);
            checked=checked+1;
        end
        passed=1;
        $display("PASS retimed FX RATE=%0d: %0d exact frozen-reference samples and state, changing controls/clear/full scale; max %0d clocks",
                 RATE,checked,max_cycles);
    end
endmodule

module tb_timing150_effects;
    wire native_passed,legacy_passed;
    timing_effect_case native_case(.passed(native_passed));
    timing_effect_case #(.RATE(1),.CLOCK(50000000)) legacy_case(.passed(legacy_passed));
    reg passed=0;
    initial begin
        wait(native_passed && legacy_passed);passed=1;
        $display("PASS retimed effects: both sample-rate profiles unchanged");$finish;
    end
    initial begin #100000000;$fatal(1,"Retimed effects comparison timeout");end
endmodule
