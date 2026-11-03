`timescale 1ns/1ps
module tb_pressure;
    reg clk=0;
    always #10 clk=~clk;
    reg reset_n=0, allow_events=1;
    wire [3:0] select;
    wire select_n, adc_clk, valid, on_value, update_value, ready, overflow;
    wire [6:0] note;
    wire [7:0] dynamics;
    wire [15:0] pressed, long_held, calibrated;
    reg [11:0] voltages [0:15];
    reg [11:0] adc_data=0, pipeline0=0, pipeline1=0;
    `include "pressure_scan_mapping.vh"
    // A coherent ADC word arrives after two conversion periods and tCO.
    always @(posedge adc_clk) begin
        pipeline0<=voltages[pressure_key_for_select(select)];
        pipeline1<=pipeline0;
        adc_data<=#120 pipeline1;
    end
    wire sample_valid;
    wire [3:0] sample_key;
    wire [11:0] sample_data;
    pressure_adc_scan scan (
        .clk(clk), .reset_n(reset_n), .adc_data(adc_data),
        .select(select), .select_n(select_n), .adc_clk(adc_clk),
        .sample_valid(sample_valid), .sample_key(sample_key), .sample_data(sample_data));
    pressure_keyboard #(.CALIBRATION_LOG2(1), .LONG_HOLD_FRAMES(12)) keyboard (
        .clk(clk), .reset_n(reset_n), .enable(1'b1), .marimba_mode(1'b0),
        .guide_mode(1'b0),
        .sample_valid(sample_valid), .base_note(7'd39),
        .sample_key(sample_key), .sample_data(sample_data),
        .event_ready(ready && allow_events),
        .event_valid(valid), .event_on(on_value), .event_update(update_value),
        .event_note(note), .event_dynamics(dynamics),
        .pressed(pressed), .long_held(long_held), .calibrated(calibrated),
        .overflow(overflow));
    reg [11:0] audio_count=0;
    wire tick=audio_count==3071;
    always @(posedge clk)
        if(!reset_n) audio_count<=0;
        else audio_count<=tick ? 12'd0 : audio_count+1'b1;
    wire signed [15:0] pcm;
    wire pcm_valid, deadline, saturated;
    wire [6:0] active;
    instrument_synth #(.LIVE_DYNAMICS(1),
        .ATTACK_STEP(24'd4194304), .DECAY_STEP(24'd1048576),
        .SUSTAIN_LEVEL(24'd4194304), .RELEASE_SHIFT(8)) synth (
        .clk(clk), .reset_n(reset_n), .sample_tick(tick),
        .stop_all(1'b0), .instrument_id(2'd0), .unsupported_instrument(),
        .event_valid(valid && allow_events), .event_on(on_value),
        .event_update(update_value), .event_note(note), .event_dynamics(dynamics),
        .pitch_ratio(18'd193274), .event_ready(ready),
        .pcm(pcm), .pcm_valid(pcm_valid), .deadline_error(deadline),
        .saturated(saturated), .active_voices(active),
        .mix_sample(), .mix_valid(), .limiting(),
        .debug_voice(), .debug_env_state(), .debug_envelope(), .debug_phase());
    integer ons[0:15], offs[0:15], updates=0, nonzero=0;
    integer i;
    reg passed=0;
    reg [16:0] stalled_packet;
    reg was_stalled=0;
    always @(posedge clk) if(reset_n) begin
        if(deadline || saturated || overflow)
            $fatal(1,"Audio deadline, saturation or pressure queue overflow");
        if(was_stalled && {valid,update_value,on_value,note,dynamics} !==
                          {1'b1,stalled_packet})
            $fatal(1,"Event payload changed under backpressure");
        was_stalled=valid && !(ready && allow_events);
        stalled_packet={update_value,on_value,note,dynamics};
        if(valid && ready && allow_events) begin
            if(note<39 || note>54) $fatal(1,"Wrong key-to-note mapping");
            if(update_value) updates=updates+1;
            else if(on_value) ons[note-39]=ons[note-39]+1;
            else offs[note-39]=offs[note-39]+1;
        end
        if(pcm_valid && pcm!=0) nonzero=nonzero+1;
    end
    task scans(input integer frames);
        repeat(frames*16*1500) @(negedge clk);
    endtask
    task audio_frames(input integer frames);
        repeat(frames) @(posedge pcm_valid);
    endtask
    reg [31:0] saved_phase;
    reg [15:0] saved_strike;
    reg [7:0] release_gain;
    initial begin
        for(i=0;i<16;i=i+1) begin
            voltages[i]=3500+i*3; ons[i]=0; offs[i]=0;
        end
        repeat(5) @(negedge clk); reset_n=1;
        scans(3);
        if(calibrated!=16'hffff || pressed!=0 || select_n!=0)
            $fatal(1,"Startup calibration or mux enable failed");
        for(i=0;i<16;i=i+1)
            if(keyboard.keys.baseline[i] != 3500+i*3)
                $fatal(1,"ADC channel/latency mismatch on key %0d",i);
        // A short excursion must not cause a note; upward noise cannot underflow.
        voltages[0]=3340; scans(1);
        voltages[0]=3510; scans(10);
        if(ons[0]!=0 || pressed!=0) $fatal(1,"Transient generated a key press");
        voltages[0]=3340; scans(24);
        if(ons[0]!=1 || !pressed[0] || !long_held[0] ||
           synth.piano.voice_ram[39][2:0]!=3)
            $fatal(1,"Held key did not sustain independently");
        if(synth.piano.voice_ram[39][90:83]<70 || synth.piano.voice_ram[39][90:83]>74)
            $fatal(1,"Soft held key did not reach its boosted gain");
        saved_phase=synth.piano.voice_ram[39][82:51];
        saved_strike=synth.piano.partial_ram[39][287:272];
        voltages[0]=1900; scans(40);
        if(ons[0]!=1 || offs[0]!=0 || updates==0 ||
           synth.piano.voice_ram[39][2:0]!=3 ||
           synth.piano.voice_ram[39][50:27]!=4194304 ||
           synth.piano.voice_ram[39][90:83]!=200 ||
           synth.piano.voice_ram[39][82:51]==saved_phase ||
           synth.piano.partial_ram[39][287:272]>saved_strike)
            $fatal(1,"Pressure update: ons=%0d offs=%0d updates=%0d state=%0d env=%0d gain=%0d strike=%0d",
                ons[0],offs[0],updates,synth.piano.voice_ram[39][2:0],
                synth.piano.voice_ram[39][50:27],synth.piano.voice_ram[39][90:83],
                synth.piano.partial_ram[39][287:272]);
        // Decrease and increase again below the previous maximum.
        voltages[0]=2700; scans(35);
        if(synth.piano.voice_ram[39][90:83]<145 || synth.piano.voice_ram[39][90:83]>147)
            $fatal(1,"Pressure decrease ignored");
        voltages[0]=2300; scans(20);
        if(synth.piano.voice_ram[39][90:83]<170 || synth.piano.voice_ram[39][90:83]>172 ||
           ons[0]!=1)
            $fatal(1,"Second pressure increase lost");
        // Queue the other fifteen note-ons while the receiver is unavailable.
        @(negedge clk); allow_events=0;
        for(i=1;i<16;i=i+1) voltages[i]=2700+i*3;
        scans(16);
        if(pressed!=16'hffff || long_held!=16'hffff)
            $fatal(1,"16 independent held keys failed under backpressure");
        allow_events=1; scans(3);
        for(i=0;i<16;i=i+1)
            if(ons[i]!=1) $fatal(1,"Missing/duplicate note-on for key %0d",i);
        if(active!=16) $fatal(1,"Expected sixteen active voices");
        for(i=0;i<16;i=i+1) voltages[i]=3500+i*3;
        scans(18);
        if(pressed!=0) $fatal(1,"Release hysteresis failed");
        for(i=0;i<16;i=i+1)
            if(offs[i]!=1) $fatal(1,"Missing/duplicate note-off for key %0d",i);
        release_gain=synth.piano.voice_ram[39][90:83];
        if(synth.piano.voice_ram[39][2:0]!=4 || release_gain==0 || active==0)
            $fatal(1,"Note-off erased the release tail");
        audio_frames(12);
        if(synth.piano.voice_ram[39][90:83]!=release_gain)
            $fatal(1,"Gain changed during release");
        audio_frames(270);
        if(active!=0 || nonzero<100 || pcm!==0)
            $fatal(1,"Release did not finish or PCM remained silent");
        voltages[0]=1900; scans(20);
        if(ons[0]!=2 || !pressed[0]) $fatal(1,"Repress failed");
        $display("PASS tb_pressure: ADC pipeline/channel identity, calibration, noise, hold, 16-note chord, pressure ramp, backpressure, release tail");
        passed=1; $finish;
    end
    initial begin #200000000; $fatal(1,"Pressure test timeout"); end
endmodule
