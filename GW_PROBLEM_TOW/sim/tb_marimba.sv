`timescale 1ns/1ps
module tb_marimba;
    reg clk=0;
    always #10 clk=~clk;
    reg reset_n=0, stop_all=0, sample_tick=0;
    reg event_valid=0, event_on=0;
    reg [6:0] event_note=0;
    reg [7:0] event_dynamics=192;
    wire event_ready, mix_valid, pcm_valid, limiting, saturated, deadline;
    wire signed [31:0] mix_sample;
    wire signed [15:0] pcm;
    reg passed=0;
    integer note, mode, cycles, i;
    reg [15:0] level_after_one, level_after_two;

    marimba_synth dut (
        .clk(clk), .reset_n(reset_n), .sample_tick(sample_tick),
        .stop_all(stop_all), .event_valid(event_valid), .event_on(event_on),
        .event_note(event_note), .event_dynamics(event_dynamics),
        .event_ready(event_ready), .mix_sample(mix_sample), .mix_valid(mix_valid),
        .pcm(pcm), .pcm_valid(pcm_valid), .limiting(limiting),
        .saturated(saturated), .deadline_error(deadline)
    );

    task send_event(input bit on_value, input integer note_value);
        begin
            @(negedge clk);
            while (!event_ready) @(negedge clk);
            event_valid=1;
            event_on=on_value;
            event_note=note_value;
            @(negedge clk);
            event_valid=0;
        end
    endtask

    task render_frame;
        begin
            @(negedge clk); sample_tick=1;
            @(negedge clk); sample_tick=0;
            cycles=0;
            while (!mix_valid && cycles<3072) begin
                @(negedge clk);
                cycles=cycles+1;
            end
            if (!mix_valid) $fatal(1,"Marimba missed its sample deadline");
            if (cycles>3072) $fatal(1,"Marimba exceeded the 3072-clock budget");
            if (deadline || saturated) $fatal(1,"Marimba deadline or saturation");
            if (^mix_sample === 1'bx || ^pcm === 1'bx)
                $fatal(1,"Unknown marimba audio output");
            while (!pcm_valid) @(negedge clk);
        end
    endtask

    initial begin
        repeat(4) @(negedge clk);
        reset_n=1;
        for (note=0; note<48; note=note+1)
            for (mode=0; mode<4; mode=mode+1)
                if (dut.mode_rom[note][mode*64+32 +: 32] >= 32'h80000000)
                    $fatal(1,"Mode above Nyquist: note=%0d mode=%0d",note,mode);

        send_event(1,35);
        if (dut.pending != 0) $fatal(1,"Out-of-range note was accepted");
        send_event(1,84);
        if (dut.pending != 0) $fatal(1,"High out-of-range note was accepted");
        send_event(1,36);
        render_frame();
        if (!dut.active_modes[0] || !dut.active_modes[1])
            $fatal(1,"C2 strike did not activate its measured modes");
        if (dut.active_noise[0] !== 1'b1)
            $fatal(1,"C2 strike did not activate its mallet transient");
        if (cycles >= 3072) $fatal(1,"Single note used the full frame budget");

        send_event(0,36);
        render_frame();
        if (mix_sample == 0) $fatal(1,"Marimba modes produced no audible sample");
        level_after_one=dut.mode_state_ram[0][15:0];
        render_frame();
        level_after_two=dut.mode_state_ram[0][15:0];
        if (level_after_two >= level_after_one || level_after_one == 0)
            $fatal(1,"Note-off cut the strike or modal decay stalled");

        send_event(1,36);
        render_frame();
        if (dut.mode_state_ram[0][15:0] <= level_after_one)
            $fatal(1,"Repeated strike did not retrigger the modal envelope");

        for (note=37; note<=83; note=note+1)
            send_event(1,note);
        render_frame();
        for (note=0; note<48; note=note+1)
            if (!dut.active_modes[note*4])
                $fatal(1,"Missing fitted fundamental for note slot %0d",note);
        if (cycles >= 3072) $fatal(1,"48-note render exceeded the frame budget");

        $display("PASS tb_marimba: 48 notes, 4 modes, transient, body filter, %0d clocks",
                 cycles);
        passed=1;
        $finish;
    end
    initial begin #200000000; $fatal(1,"Marimba timeout"); end
endmodule
