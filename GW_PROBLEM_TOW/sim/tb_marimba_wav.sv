`timescale 1ns/1ps
module tb_marimba_wav;
    reg clk=0;
    always #10 clk=~clk;
    reg reset_n=0, sample_tick=0, stop_all=0, event_valid=0;
    reg [6:0] note=36;
    wire ready, valid, deadline, saturated;
    wire signed [15:0] pcm;
    integer fd, frame, note_number, cycles;
    reg passed=0;
    marimba_synth dut (
        .clk(clk), .reset_n(reset_n), .sample_tick(sample_tick),
        .stop_all(stop_all), .event_valid(event_valid), .event_on(1'b1),
        .event_note(note), .event_dynamics(8'd192), .event_ready(ready),
        .mix_sample(), .mix_valid(), .pcm(pcm), .pcm_valid(valid),
        .limiting(), .saturated(saturated), .deadline_error(deadline)
    );
    initial begin
        fd=$fopen("sim/marimba_scale_pcm.txt","w");
        if (!fd) $fatal(1,"Cannot open audio output");
        repeat(4) @(negedge clk);
        reset_n=1;
        for(note_number=36; note_number<=77; note_number=note_number+1) begin
            @(negedge clk); stop_all=1;
            repeat(4) @(negedge clk);
            stop_all=0;
            while(!ready) @(negedge clk);
            note=note_number; event_valid=1;
            @(negedge clk); event_valid=0;
            // Only idle clocks are omitted; all state updates use sample ticks.
            for(frame=0; frame<16276; frame=frame+1) begin
                @(negedge clk); sample_tick=1;
                @(negedge clk); sample_tick=0;
                cycles=0;
                while(!valid && cycles<3072) begin
                    @(negedge clk); cycles=cycles+1;
                end
                if (!valid || deadline || saturated || (^pcm === 1'bx))
                    $fatal(1,"Invalid audio note=%0d frame=%0d",note_number,frame);
                $fdisplay(fd,"%0d %0d %0d",note_number,frame,pcm);
                repeat(2) @(negedge clk);
            end
            $display("Rendered note %0d / 77",note_number);
        end
        $fclose(fd);
        passed=1;
        $display("PASS: 42 notes, 683592 RTL PCM frames");
        $finish;
    end
    initial begin #(64'd20_000_000_000); $fatal(1,"Audio render timeout"); end
endmodule
