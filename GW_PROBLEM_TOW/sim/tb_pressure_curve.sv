`timescale 1ns/1ps
module tb_pressure_curve;
    reg clk=0;
    always #5 clk=~clk;
    reg reset_n=0, valid=0;
    reg [11:0] data=4095;
    wire [127:0] boosted, original;
    wire [15:0] down_boosted, down_original;
    wire edge_boosted, edge_original;
    pressure_keys #(.CALIBRATION_LOG2(0), .FILTER_SHIFT(0),
        .CONFIRM_FRAMES(1), .SOFT_TOUCH_BOOST(1)) boosted_keys (
        .clk(clk), .reset_n(reset_n), .sample_valid(valid),
        .sample_key(4'd0), .sample_data(data), .gains(boosted),
        .pressed(down_boosted), .edge_valid(edge_boosted),
        .calibrated(), .long_held(), .forces(),
        .edge_on(), .edge_key(), .edge_gain());
    pressure_keys #(.CALIBRATION_LOG2(0), .FILTER_SHIFT(0),
        .CONFIRM_FRAMES(1), .SOFT_TOUCH_BOOST(0)) linear (
        .clk(clk), .reset_n(reset_n), .sample_valid(valid),
        .sample_key(4'd0), .sample_data(data), .gains(original),
        .pressed(down_original), .edge_valid(edge_original),
        .calibrated(), .long_held(), .forces(),
        .edge_on(), .edge_key(), .edge_gain());
    task sample(input integer pressure);
        begin
            @(negedge clk); valid=1; data=4095-pressure;
            @(negedge clk); valid=0;
        end
    endtask
    integer p, previous=0;
    reg passed=0;
    initial begin
        repeat(3) @(negedge clk); reset_n=1;
        sample(0);
        for(p=0;p<=4095;p=p+1) begin
            sample(p);
            if(down_boosted!==down_original || edge_boosted!==edge_original)
                $fatal(1,"Gain curve changed key detection at pressure %0d",p);
            if(p<64 && down_boosted!=0)
                $fatal(1,"Soft boost caused a false press");
            if(p>=64) begin
                if(boosted[7:0]<previous)
                    $fatal(1,"Gain curve decreased as force increased at %0d",p);
                if(boosted[7:0]<original[7:0])
                    $fatal(1,"Boost reduced output at pressure %0d",p);
                previous=boosted[7:0];
            end
            if(p>=1536 && boosted[7:0]!==original[7:0])
                $fatal(1,"Heavy-touch gain changed at pressure %0d",p);
            if(p==64 && boosted[7:0]!=48) $fatal(1,"Audible press gain");
            if(p==134 && (boosted[7:0]!=64 || original[7:0]!=16))
                $fatal(1,"Light-touch anchor");
            if(p==355 && (boosted[7:0]!=108 || original[7:0]!=44))
                $fatal(1,"Normal-touch anchor");
            if(p==1775 && (boosted[7:0]!=221 || original[7:0]!=221))
                $fatal(1,"Heavy-touch anchor");
            if(p==4095 && boosted[7:0]!=255) $fatal(1,"Gain did not saturate");
        end
        sample(0);
        if(down_boosted!=0 || down_original!=0)
            $fatal(1,"Release changed by boost");
        $display("PASS tb_pressure_curve: full 12-bit sweep, monotonic boost, light 16->64, normal 44->108, heavy 221 unchanged, gate thresholds unchanged");
        passed=1; $finish;
    end
    initial begin #200000; $fatal(1,"Curve test timeout"); end
endmodule
