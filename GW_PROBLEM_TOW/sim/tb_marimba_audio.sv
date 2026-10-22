`timescale 1ns/1ps
module tb_marimba_audio;
    reg clk=0;
    always #10 clk=~clk;
    reg reset_n=0, sample_tick=0, event_valid=0, event_on=0;
    reg [6:0] event_note=26;
    reg [7:0] event_dynamics=192;
    wire event_ready, mix_valid, pcm_valid, limiting, saturated, deadline;
    wire signed [31:0] mix_sample;
    wire signed [15:0] pcm;
    integer fd, frame, cycles;

    marimba_synth dut (
        .clk(clk), .reset_n(reset_n), .sample_tick(sample_tick),
        .stop_all(1'b0), .event_valid(event_valid), .event_on(event_on),
        .event_note(event_note), .event_dynamics(event_dynamics),
        .event_ready(event_ready), .mix_sample(mix_sample), .mix_valid(mix_valid),
        .pcm(pcm), .pcm_valid(pcm_valid), .limiting(limiting),
        .saturated(saturated), .deadline_error(deadline)
    );

    initial begin
        fd=$fopen("sim/marimba_pcm.txt","w");
        repeat(4) @(negedge clk);
        reset_n=1;
        while (!event_ready) @(negedge clk);
        event_valid=1; event_on=1;
        @(negedge clk); event_valid=0;
        for(frame=0;frame<2400;frame=frame+1) begin
            @(negedge clk); sample_tick=1;
            @(negedge clk); sample_tick=0;
            cycles=0;
            while(!mix_valid && cycles<3072) begin
                @(negedge clk); cycles=cycles+1;
            end
            if(!mix_valid || deadline) $fatal(1,"Marimba sample deadline");
            while(!pcm_valid) @(negedge clk);
            $fdisplay(fd,"%0d",pcm);
            repeat(3072-cycles-16) @(negedge clk);
        end
        $fclose(fd);
        $display("PASS: exported 2400 samples at 16276 Hz");
        $finish;
    end
    initial begin #2_000_000_000; $fatal(1,"Audio export timeout"); end
endmodule
