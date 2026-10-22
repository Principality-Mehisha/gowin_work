`timescale 1ns/1ps
module GSR(input GSRI);
endmodule

module tb_marimba_controls;
    reg clk=0;
    always #10 clk=~clk;
    reg key1=1, key2=1;
    reg passed=0;
    wire cs;
    integer ons=0, offs=0, expected=36, i;
    reg heard=0;
    piano_score_player #(.POWER_ON_CYCLES(8), .DEBOUNCE_CYCLES(8),
                         .AUDIO_START_CYCLES(64)) dut (
        .sys_clk(clk), .KEY0(1'b1), .KEY1(key1), .KEY2(key2),
        .HP_BCK(), .HP_WS(), .HP_DIN(), .PA_EN(),
        .sd_cs_n(cs), .sd_sck(), .sd_mosi(), .sd_miso(1'b1), .LEDs()
    );
    always @(posedge clk) if (dut.rst_n) begin
        if (dut.deadline_error || dut.initialized || dut.file_found || cs !== 1'b1)
            $fatal(1,"Unexpected compute error or SD access");
        if (dut.selected_pcm != 0) heard=1;
        if (dut.synth_event_valid && dut.synth_event_ready) begin
            if (dut.synth_event_on) begin
                if (dut.synth_event_note != expected)
                    $fatal(1,"Manual order: %0d != %0d",dut.synth_event_note,expected);
                expected=(expected==77)?36:expected+1;
                ons=ons+1;
            end else offs=offs+1;
        end
    end
    task strike;
        input integer count;
        begin
            @(negedge clk); key1=0;
            wait(ons==count);
            repeat(32) @(negedge clk); key1=1;
            wait(offs==count);
            repeat(32) @(negedge clk);
        end
    endtask
    initial begin
        wait(dut.rst_n);
        for(i=1;i<=43;i=i+1) strike(i);
        if (!heard) $fatal(1,"No synthesized audio");
        @(negedge clk); key2=0;
        repeat(4) @(negedge clk);
        expected=36;
        key2=1;
        wait(dut.rst_n);
        strike(44);
        passed=1;
        $display("PASS: C2-F5 42-key wrap, reset to C2, audio, SD isolation");
        $finish;
    end
    initial begin #100000000; $fatal(1,"Manual controls timeout"); end
endmodule
