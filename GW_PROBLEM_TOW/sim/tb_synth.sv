`timescale 1ns/1ps
module tb_synth;
    reg clk=0;
    always #3.255208333 clk=~clk;
    reg reset_n=0, stop_all=0, tick=0, valid=0, note_on=0;
    reg [6:0] note=0;
    reg [7:0] dynamics=192;
    reg [17:0] pitch=65536;
    wire ready, mix_valid, pcm_valid, limiting, saturated, deadline;
    wire signed [31:0] mix;
    wire signed [15:0] pcm;
    wire [6:0] active;
    wire [82:0] a4 = dut.valid_states[48] ? dut.voice_ram[48] : 83'd0;
    wire [82:0] note10 = dut.valid_states[10] ? dut.voice_ram[10] : 83'd0;
    wire [31:0] phase_a4 = a4[82:51];
    wire [23:0] envelope_a4 = a4[50:27];
    wire [2:0] state_a4 = a4[2:0];
    wire [23:0] release_a4 = a4[26:3];
    reg passed=0;
    reg saw_a4_profile=0;
    integer n,h,fd,frames=0,nonzero=0,max_cycles=0;
    reg [31:0] previous_partial [0:87][0:7];
    reg [63:0] expected_step,expected_stiffness,expected_phase;
    piano_synth #(.ATTACK_STEP(24'd4194304), .DECAY_STEP(24'd1048576),
        .SUSTAIN_LEVEL(24'd4194304), .RELEASE_SHIFT(4)) dut (
        .clk(clk), .reset_n(reset_n), .sample_tick(tick), .stop_all(stop_all),
        .event_valid(valid), .event_on(note_on), .event_note(note),
        .event_dynamics(dynamics), .pitch_ratio(pitch), .event_ready(ready),
        .mix_sample(mix), .mix_valid(mix_valid), .pcm(pcm), .pcm_valid(pcm_valid),
        .limiting(limiting), .saturated(saturated), .deadline_error(deadline),
        .active_voices(active), .debug_voice(), .debug_env_state(),
        .debug_envelope(), .debug_phase());
    always @(posedge clk)
        if (dut.state==dut.PREPARE && dut.voice==48 &&
            dut.profile===dut.voicing_rom[48])
            saw_a4_profile<=1;
    task event_send(input bit on_value, input integer note_value);
        begin
            @(negedge clk);
            while (!ready) @(negedge clk);
            valid=1; note_on=on_value; note=note_value;
            @(negedge clk); valid=0;
        end
    endtask
    task frame;
        integer cycles;
        begin
            @(negedge clk); tick=1;
            @(negedge clk); tick=0;
            cycles=1;
            while (!pcm_valid && cycles<3150) begin
                @(negedge clk); cycles=cycles+1;
            end
            if (!pcm_valid) $fatal(1,"Missed frame deadline");
            if(cycles>max_cycles) max_cycles=cycles;
            if (deadline || saturated) $fatal(1,"Overflow/deadline flag");
            if (^pcm === 1'bx) $fatal(1,"Unknown PCM");
            if (pcm!=0) nonzero=nonzero+1;
            $fdisplay(fd,"%0d",pcm);
            repeat (3200-cycles) @(negedge clk);
            frames=frames+1;
        end
    endtask
    task clear_all;
        begin
            @(negedge clk); stop_all=1;
            @(negedge clk);
            if (pcm!==0 || active!==0 || dut.gates!==0)
                $fatal(1,"Hard stop did not clear voices");
            stop_all=0;
        end
    endtask
    initial begin
        fd=$fopen("sim/synth_test_pcm.txt","w");
        repeat(5) @(negedge clk); reset_n=1;
        event_send(1,48);
        frame();
        if (state_a4!=1) $fatal(1,"No attack");
        repeat(20) frame();
        if (state_a4!=3 || envelope_a4!=4194304)
            $fatal(1,"Held gate did not sustain");
        if (dut.partial_levels[7*24 +: 24] >= dut.partial_levels[0 +: 24])
            $fatal(1,"Upper partial did not decay faster than the fundamental");
        event_send(0,48); frame();
        if (state_a4!=4) $fatal(1,"No release on key-up");
        event_send(1,52); frame();
        if (active!=2) $fatal(1,"Release tail did not overlap new note");
        clear_all();
        // Early note-off during Attack must release from the current level.
        event_send(1,10); frame(); event_send(0,10); frame();
        if (note10[2:0]!=4 || note10[50:27]!=4194304)
            $fatal(1,"Early note-off jumped to a different envelope level");
        repeat(17) frame();
        if (active!=0) $fatal(1,"Release did not terminate");
        // Independently address all 88 voices, including maximum polyphony.
        for (n=0;n<88;n=n+1) event_send(1,n);
        repeat(80) frame();
        if (active!=88) $fatal(1,"Expected 88 independent active voices");
        for (n=0;n<88;n=n+1)
            if (dut.voice_ram[n][2:0]!=3) $fatal(1,"Voice %0d lost",n);
        if (dut.frequency_rom[48]!=39370534) $fatal(1,"A4 tuning word");
        // Pitch modulation changes phase increments without replay or restart.
        for(n=0;n<88;n=n+1)
            for(h=0;h<8;h=h+1)
                previous_partial[n][h]=dut.partial_ram[n][h*32 +: 32];
        pitch=98304; frame();
        if (dut.voice_step != ((64'h16534c35*98304)>>16))
            $fatal(1,"Live pitch multiplication failed: %0d",dut.voice_step);
        // All 704 partial phases must remain continuous across accumulator
        // wraps and a live pitch change, including stiff bass strings.
        for(n=0;n<88;n=n+1) begin
            expected_step=(64'd98304*dut.frequency_rom[n])>>16;
            expected_stiffness=(64'd98304*dut.voicing_rom[n][139:108])>>16;
            for(h=1;h<=8;h=h+1) begin
                expected_phase=previous_partial[n][h-1]+h*expected_step+
                               (h*h*h-h)*expected_stiffness;
                if(dut.partial_ram[n][(h-1)*32 +: 32]!==expected_phase[31:0])
                    $fatal(1,"Partial phase discontinuity: note=%0d h=%0d",n,h);
            end
        end
        for (n=0;n<88;n=n+1) event_send(0,n);
        repeat(18) frame();
        if (active!=0) $fatal(1,"Polyphonic note-offs did not finish");
        if (nonzero<20) $fatal(1,"Audio remained silent");
        clear_all();
        event_send(1,48); frame();
        if (!saw_a4_profile || state_a4!=1)
            $fatal(1,"Piano voicing profile did not load for A4");
        repeat(18) frame();
        $fclose(fd);
        passed=1;
        $display("PASS tb_synth: %0d frames, 88 voices, ADSR, pitch, hard stop; max latency %0d clocks",
                 frames,max_cycles);
        $finish;
    end
    initial begin #30000000; $fatal(1,"Timeout tb_synth"); end
endmodule
