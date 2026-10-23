`timescale 1ns/1ps
// The original implementation is supplied as an external, ignored test input.
// Check both the sound and its exact delivery cycle after the storage rewrite.
module tb_marimba_storage;
    reg clk=0;
    always #10 clk=~clk;
    reg reset_n=0, stop_all=0, tick=0, valid=0, on_value=0;
    reg [6:0] note=0;
    reg [7:0] dynamics=192;
    wire ready, ref_ready, mix_valid, ref_mix_valid, pcm_valid, ref_pcm_valid;
    wire limiting, ref_limiting, saturated, ref_saturated, deadline, ref_deadline;
    wire signed [31:0] mix_sample, ref_mix_sample;
    wire signed [15:0] pcm, ref_pcm;
    reg passed=0;
    reg [31:0] random_state=32'h19a5c73d;
    integer frame_index=0, samples=0, max_cycles=0, cycles, n, velocity;

    marimba_synth dut (
        .clk(clk),.reset_n(reset_n),.sample_tick(tick),.stop_all(stop_all),
        .event_valid(valid),.event_on(on_value),.event_note(note),
        .event_dynamics(dynamics),.event_ready(ready),
        .mix_sample(mix_sample),.mix_valid(mix_valid),.pcm(pcm),.pcm_valid(pcm_valid),
        .limiting(limiting),.saturated(saturated),.deadline_error(deadline)
    );
    marimba_synth_reference reference (
        .clk(clk),.reset_n(reset_n),.sample_tick(tick),.stop_all(stop_all),
        .event_valid(valid),.event_on(on_value),.event_note(note),
        .event_dynamics(dynamics),.event_ready(ref_ready),
        .mix_sample(ref_mix_sample),.mix_valid(ref_mix_valid),.pcm(ref_pcm),.pcm_valid(ref_pcm_valid),
        .limiting(ref_limiting),.saturated(ref_saturated),.deadline_error(ref_deadline)
    );
    always @(negedge clk) begin
        #1;
        if ({ready,mix_valid,pcm_valid,limiting,saturated,deadline} !==
            {ref_ready,ref_mix_valid,ref_pcm_valid,ref_limiting,ref_saturated,ref_deadline})
            $fatal(1,"Interface timing mismatch frame=%0d state=%0d",frame_index,dut.state);
        if (mix_sample !== ref_mix_sample || pcm !== ref_pcm)
            $fatal(1,"Sample mismatch frame=%0d mix=%0d/%0d pcm=%0d/%0d",
                   frame_index,mix_sample,ref_mix_sample,pcm,ref_pcm);
        if (pcm_valid) samples=samples+1;
    end

    task send(input integer pitch, input integer strength, input bit on_bit);
        begin
            @(negedge clk);
            while(!ready) @(negedge clk);
            note=pitch; dynamics=strength; on_value=on_bit; valid=1;
            @(negedge clk); valid=0;
        end
    endtask
    task render(input bit actual_period);
        begin
            @(negedge clk);tick=1;
            @(negedge clk);tick=0;cycles=0;
            while(!pcm_valid && cycles<3072) begin @(negedge clk);cycles=cycles+1;end
            if (!pcm_valid || deadline) $fatal(1,"Real-time frame budget failed: %0d",cycles);
            if(cycles>max_cycles) max_cycles=cycles;
            if(actual_period) repeat(3072-cycles-1) @(negedge clk);
            else repeat(2) @(negedge clk);
            frame_index=frame_index+1;
        end
    endtask
    task clear;
        begin @(negedge clk);stop_all=1;repeat(2)@(negedge clk);stop_all=0;end
    endtask

    initial begin
        repeat(4)@(negedge clk);reset_n=1;
        render(1); // Unwritten RAM must never leak into the output.
        for(velocity=1;velocity<=255;velocity=velocity+127) begin
            for(n=36;n<=83;n=n+1) begin
                clear();send(n,velocity,1);render(0);
                send(n,velocity,0);render(0);render(0);
                send(n,255-velocity,1);render(0);
            end
        end
        clear();
        for(n=36;n<=83;n=n+1) send(n,192,1);
        repeat(12)render(1); // All 192 modes and all transients.
        for(n=0;n<1200;n=n+1) begin
            random_state=random_state ^ (random_state<<13);
            random_state=random_state ^ (random_state>>17);
            random_state=random_state ^ (random_state<<5);
            send(random_state[6:0],random_state[15:8],random_state[19]);
            render(n%9==0);
            if(n%113==0) clear();
        end
        // An accepted event on the sample boundary must affect the same frame.
        clear();@(negedge clk);note=36;dynamics=203;on_value=1;valid=1;tick=1;
        @(negedge clk);valid=0;tick=0;
        wait(pcm_valid);repeat(2)@(negedge clk);render(0);
        // Stop/reset during every FSM phase, including RAM writeback cycles.
        for(n=0;n<=19;n=n+1) begin
            clear();send(48,192,1);
            @(negedge clk);tick=1;@(negedge clk);tick=0;
            wait(dut.state==n);@(negedge clk);stop_all=1;
            repeat(2)@(negedge clk);stop_all=0;render(0);
            send(60,192,1);@(negedge clk);tick=1;@(negedge clk);tick=0;
            wait(dut.state==n);@(negedge clk);reset_n=0;
            repeat(2)@(negedge clk);reset_n=1;render(0);
        end
        // Busy events are ignored and an early tick sets the same fault flag.
        send(83,255,1);@(negedge clk);tick=1;@(negedge clk);tick=0;
        wait(dut.state==6);@(negedge clk);valid=1;note=37;tick=1;
        @(negedge clk);valid=0;tick=0;wait(pcm_valid);
        if(!deadline || !ref_deadline) $fatal(1,"Early tick did not flag deadline");
        @(negedge clk);reset_n=0;repeat(3)@(negedge clk);reset_n=1;render(1);
        $display("PASS storage equivalence: %0d exact PCM samples, max %0d clocks; all pitches, velocities, overlap, retrigger, reset/stop phases and handshake timing",samples,max_cycles);
        passed=1;$finish;
    end
    initial begin #(64'd3000000000);$fatal(1,"Storage equivalence timeout");end
endmodule
