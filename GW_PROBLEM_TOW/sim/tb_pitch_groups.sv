`timescale 1ns/1ps
module tb_pitch_groups;
    reg clk=0;
    always #5 clk=~clk;
    reg reset_n=0, edge_valid=0, edge_on=0, allow_events=1;
    reg [6:0] mask=0;
    wire [2:0] selected;
    wire [6:0] base_note;
    pitch_group_select #(.STABLE_CYCLES(3)) groups (
        .clk(clk), .reset_n(reset_n), .pitch_group(mask),
        .selected_group(selected), .base_note(base_note));
    reg [3:0] key=0;
    reg [7:0] gain=0;
    reg [15:0] pressed=0;
    reg [127:0] gains=0;
    wire rv,ro,ru,rr;
    wire [3:0] rk;
    wire [6:0] rn;
    wire [7:0] rd;
    wire overflow;
    pressure_events events (.clk(clk), .reset_n(reset_n), .base_note(base_note),
        .edge_valid(edge_valid), .edge_on(edge_on), .edge_key(key), .edge_gain(gain),
        .pressed(pressed), .gains(gains), .event_ready(rr),
        .event_valid(rv), .event_on(ro), .event_update(ru), .event_key(rk),
        .event_note(rn), .event_dynamics(rd), .overflow(overflow));
    wire valid,on_value,update_value,synth_ready;
    wire ready=allow_events && synth_ready;
    wire [6:0] note;
    wire [7:0] dynamics;
    pressure_note_merge merge (.clk(clk), .reset_n(reset_n),
        .input_valid(rv), .input_on(ro), .input_update(ru),
        .input_key(rk), .input_note(rn), .input_dynamics(rd), .input_ready(rr),
        .event_valid(valid), .event_on(on_value), .event_update(update_value),
        .event_note(note), .event_dynamics(dynamics), .event_ready(ready));
    reg [11:0] frame_count=0;
    wire tick=frame_count==4095;
    always @(posedge clk)
        if(!reset_n) frame_count<=0;
        else frame_count<=frame_count+1'b1;
    wire deadline,saturated;
    wire signed [15:0] pcm;
    instrument_synth #(.LIVE_DYNAMICS(1)) synth (
        .clk(clk), .reset_n(reset_n), .sample_tick(tick), .stop_all(1'b0),
        .instrument_id(2'd0), .event_valid(valid && allow_events),
        .event_on(on_value), .event_update(update_value), .event_note(note),
        .event_dynamics(dynamics), .pitch_ratio(18'd193274),
        .event_ready(synth_ready), .pcm(pcm), .pcm_valid(),
        .deadline_error(deadline), .saturated(saturated),
        .unsupported_instrument(), .mix_sample(), .mix_valid(), .limiting(),
        .active_voices(), .debug_voice(), .debug_env_state(),
        .debug_envelope(), .debug_phase());
    integer ons[0:87],offs[0:87],last_gain[0:87];
    integer i,j,n,before_on,before_off,old87,old16,oldoff16;
    reg passed=0,stalled=0;
    reg [16:0] packet;
    always @(posedge clk) if(reset_n) begin
        if(overflow || deadline || saturated) $fatal(1,"Pitch/audio error flag");
        if(stalled && {update_value,on_value,note,dynamics}!==packet)
            $fatal(1,"Pitch payload changed while stalled");
        stalled=valid && !ready;
        packet={update_value,on_value,note,dynamics};
        if(valid && ready) begin
            if(note>87) $fatal(1,"Out-of-range pitch");
            if(!update_value) begin
                if(on_value) ons[note]=ons[note]+1;
                else offs[note]=offs[note]+1;
            end
            last_gain[note]=dynamics;
        end
    end
    task group_set(input integer value);
        begin @(negedge clk); mask=value; repeat(12) @(negedge clk); end
    endtask
    task send(input integer k,input bit down,input integer value);
        begin
            @(negedge clk); key=k; edge_on=down; gain=value; edge_valid=1;
            pressed[k]=down; gains[k*8 +: 8]=value;
            @(negedge clk); edge_valid=0;
        end
    endtask
    task drain;
        integer cycles;
        begin
            cycles=0;
            while((events.count!=0 || rv || valid || !rr) && cycles<2000) begin
                @(negedge clk); cycles=cycles+1;
            end
            if(cycles==2000) $fatal(1,"Pitch event drain stalled");
            repeat(4) @(negedge clk);
        end
    endtask
    function integer lowest;
        input integer value;
        integer bit_index;
        begin
            lowest=0;
            for(bit_index=6;bit_index>=0;bit_index=bit_index-1)
                if(value & (1<<bit_index)) lowest=bit_index;
        end
    endfunction
    initial begin
        for(i=0;i<88;i=i+1) begin ons[i]=0; offs[i]=0; last_gain[i]=0; end
        repeat(5) @(negedge clk); reset_n=1;
        // All masks cover lowest-bit priority; all keys cover 112 mappings.
        for(i=0;i<128;i=i+1) begin
            group_set(i);
            if(selected!=lowest(i)) $fatal(1,"Group priority failed mask=%0d",i);
            for(j=0;j<16;j=j+1) begin
                n=lowest(i)*16+j; if(n>87) n=87;
                before_on=ons[n]; before_off=offs[n];
                send(j,1,80); drain();
                if(ons[n]!=before_on+1 || !synth.piano.gates[n])
                    $fatal(1,"Press mapping failed mask=%0d key=%0d note=%0d",i,j,n);
                send(j,0,80); drain();
                if(offs[n]!=before_off+1 || synth.piano.gates[n])
                    $fatal(1,"Release mapping failed");
            end
        end
        group_set(0);
        @(negedge clk); mask=64;
        @(negedge clk); mask=0;
        repeat(12) @(negedge clk);
        if(selected!=0) $fatal(1,"Short switch glitch changed group");
        // Held notes retain pitch while new keys use the new group.
        group_set(1); send(3,1,80); drain();
        group_set(2); send(5,1,120); drain();
        if(!synth.piano.gates[3] || !synth.piano.gates[21])
            $fatal(1,"Group change retuned a held key");
        gains[3*8 +: 8]=150; repeat(1000) @(negedge clk); drain();
        if(last_gain[3]!=150) $fatal(1,"Held pressure update used new group");
        group_set(64);
        send(3,0,150); send(5,0,120); drain();
        if(synth.piano.gates[3] || synth.piano.gates[21])
            $fatal(1,"Group change lost a release");
        // Natural C8 plus two clamped keys share one gate and maximum gain.
        group_set(32); old87=ons[87]; before_off=offs[87];
        send(7,1,80); send(8,1,160); send(15,1,120); drain();
        if(ons[87]!=old87+1 || last_gain[87]!=160 || !synth.piano.gates[87])
            $fatal(1,"Duplicate C8 retriggered or aggregated wrong gain");
        gains[7*8 +: 8]=220; repeat(1000) @(negedge clk); drain();
        if(last_gain[87]!=220) $fatal(1,"Shared C8 pressure maximum failed");
        send(7,0,220); drain();
        if(offs[87]!=before_off || last_gain[87]!=160 || !synth.piano.gates[87])
            $fatal(1,"Releasing strongest key cut remaining C8");
        send(8,0,160); drain();
        if(offs[87]!=before_off || last_gain[87]!=120 || !synth.piano.gates[87])
            $fatal(1,"Shared C8 did not retain last owner");
        send(15,0,120); drain();
        if(offs[87]!=before_off+1 || synth.piano.gates[87])
            $fatal(1,"Last C8 owner did not release");
        // Captured note must survive FIFO stall, group changes and rapid repress.
        old16=ons[16]; oldoff16=offs[16]; old87=ons[87];
        allow_events=0;
        group_set(2); send(0,1,64);
        group_set(16); send(0,0,64);
        group_set(64); send(0,1,100);
        repeat(40) @(negedge clk); allow_events=1; drain();
        if(ons[16]!=old16+1 || offs[16]!=oldoff16+1 ||
           ons[87]!=old87+1 || !synth.piano.gates[87])
            $fatal(1,"Queued pitch was not captured on original press");
        send(0,0,100); drain();
        if(synth.piano.gates!=0) $fatal(1,"Stuck note after pitch tests");
        // Sixteen keys in group 7 must still generate just one C8 gate.
        old87=ons[87]; before_off=offs[87];
        for(j=0;j<16;j=j+1) send(j,1,60+j);
        drain();
        if(ons[87]!=old87+1 || last_gain[87]!=75) $fatal(1,"Group 7 chord failed");
        for(j=0;j<15;j=j+1) send(j,0,60+j);
        drain();
        if(offs[87]!=before_off || !synth.piano.gates[87])
            $fatal(1,"Group 7 released before final owner");
        send(15,0,75); drain();
        if(offs[87]!=before_off+1 || synth.piano.gates!=0)
            $fatal(1,"Group 7 final release failed");
        $display("PASS tb_pitch_groups: 128 masks x 16 keys, clamp, stable input, held pitches, FIFO stalls, shared-C8 max gain and final-owner release");
        passed=1; $finish;
    end
    initial begin #10000000; $fatal(1,"Pitch-group timeout"); end
endmodule
