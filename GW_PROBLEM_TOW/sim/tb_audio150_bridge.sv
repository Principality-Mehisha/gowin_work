`timescale 1ns/1ps
module tb_audio150_bridge;
    reg sys_clk=0,audio_clk=0,reset_n=0,locked=0,restart=0,passed=0;
    always #10 sys_clk=~sys_clk;
    always #3.333333 audio_clk=~audio_clk;
    GSR GSR(.GSRI(1'b1));
    reg [15:0] cfg=16'h1c1e;
    reg valid=0,on=1,update=0,bank_ready=1,force_overflow=0;
    reg [6:0] note=0;
    reg [7:0] dynamics=192;
    wire ready,engine_reset_n,audio_config_valid,aev,aon,aup,link_ready;
    wire [15:0] audio_cfg;
    wire [6:0] anote;
    wire [7:0] adyn;
    wire sample_valid,sample_active,ack_valid,ack_on,ack_update,ack_marimba,ack_clear,fault;
    wire [6:0] ack_note;
    wire signed [15:0] sample_pcm;
    reg [8:0] divider=0;
    reg [15:0] pcm_counter=0;
    wire dac_tick=force_overflow || divider==299;
    always @(posedge audio_clk)begin
        if(!reset_n)begin divider<=0;pcm_counter<=0;end
        else begin divider<=divider==299 ? 0 : divider+1'b1;
            if(dac_tick)pcm_counter<=pcm_counter+1'b1;end
    end
    audio_domain_bridge dut(
        .sys_clk(sys_clk),.audio_clk(audio_clk),.reset_n(reset_n),.pll_locked(locked),.restart(restart),
        .config_in(cfg),.event_valid(valid),.event_on(on),.event_update(update),
        .event_note(note),.event_dynamics(dynamics),.event_ready(ready),.link_ready_sys(link_ready),
        .engine_reset_n(engine_reset_n),.audio_config(audio_cfg),.audio_config_valid(audio_config_valid),
        .audio_event_valid(aev),.audio_event_on(aon),.audio_event_update(aup),
        .audio_event_note(anote),.audio_event_dynamics(adyn),.audio_event_ready(bank_ready),
        .dac_tick(dac_tick),.dac_pcm(pcm_counter),.source_active(1'b1),
        .piano_busy(1'b1),.audio_busy(1'b1),.synth_fault(1'b0),.effect_fault(1'b0),
        .sample_valid(sample_valid),.sample_pcm(sample_pcm),.sample_active(sample_active),
        .piano_busy_sys(),.audio_busy_sys(),.synth_fault_sys(),.effect_fault_sys(),
        .ack_valid(ack_valid),.ack_on(ack_on),.ack_update(ack_update),
        .ack_marimba(ack_marimba),.ack_clear(ack_clear),.ack_note(ack_note),.bridge_fault(fault));
    reg [16:0] expected[0:3][0:127];
    reg [15:0] expected_cfg[0:3][0:127];
    reg [16:0] accepted[0:3][0:127];
    integer written[0:3],received[0:3],acked[0:3];
    integer phase=0,i,n,samples=0,clears=0;
    always @(posedge sys_clk)if(reset_n && !restart && valid && ready)begin
        expected[phase][written[phase]]={update,on,note,dynamics};
        expected_cfg[phase][written[phase]]=cfg;
        written[phase]=written[phase]+1;
    end
    always @(posedge audio_clk)if(engine_reset_n && aev && bank_ready)begin
        if(received[phase]>=written[phase] ||
           {aup,aon,anote,adyn}!==expected[phase][received[phase]] ||
           audio_cfg[13:0]!==expected_cfg[phase][received[phase]][13:0])
            $fatal(1,"Ordered command/config bridge mismatch phase=%0d index=%0d",phase,received[phase]);
        accepted[phase][received[phase]]={aup,aon,anote,adyn};
        received[phase]=received[phase]+1;
    end
    always @(negedge sys_clk)if(reset_n && !restart)begin
        if(ack_valid)begin
            if(ack_clear)clears=clears+1;
            else begin
                if(acked[phase]>=received[phase] ||
                   {ack_update,ack_on,ack_note}!==accepted[phase][acked[phase]][16:8])
                    $fatal(1,"Missing/duplicate/stale event ACK");
                acked[phase]=acked[phase]+1;
            end
        end
        if(sample_valid)samples=samples+1;
    end
    task send(input integer value);
        begin
            @(negedge sys_clk);note=value;update=value%3==0;on=value%4!=0;valid=1;
            @(posedge sys_clk);while(!ready)@(posedge sys_clk);
            @(negedge sys_clk);valid=0;
        end
    endtask
    task transport_restart;
        begin @(negedge sys_clk);valid=0;restart=1;
            @(negedge sys_clk);restart=0;end
    endtask
    initial begin
        for(i=0;i<4;i=i+1)begin written[i]=0;received[i]=0;acked[i]=0;end
        repeat(8)@(negedge sys_clk);reset_n=1;locked=1;
        wait(ready);
        for(n=0;n<64;n=n+1)begin
            if(n==32)cfg=16'h1ec6;
            send(n);
        end
        wait(acked[0]==64);
        if(fault)$fatal(1,"Normal event burst starved the priority PCM stream");
        phase=1;bank_ready=0;
        for(n=0;n<16;n=n+1)send(n);
        transport_restart();phase=2;bank_ready=1;
        for(n=64;n<96;n=n+1)send(n);
        wait(acked[2]==32);
        if(received[1]!=0)$fatal(1,"Paused source accepted events before restart");
        force_overflow=1;repeat(200)@(negedge sys_clk);force_overflow=0;
        wait(fault);transport_restart();phase=3;wait(ready);
        send(77);wait(acked[3]==1);
        repeat(100)@(negedge sys_clk);
        if(fault || samples<5 || clears<3)$fatal(1,"Bridge fault recovery/status coverage");
        locked=0;repeat(8)@(negedge sys_clk);
        if(!fault || link_ready)$fatal(1,"Lost PLL lock was not reported");
        locked=1;wait(link_ready);transport_restart();wait(ready);
        repeat(100)@(negedge sys_clk);
        if(fault)$fatal(1,"Relock/STOP did not recover bridge");
        // A lock drop shorter than a system period must still reinitialize FIFO/config.
        @(negedge sys_clk);#2;locked=0;#1;locked=1;
        repeat(10)@(negedge sys_clk);
        if(!fault)$fatal(1,"Short PLL loss escaped the local reset/ready guard");
        transport_restart();wait(ready);repeat(100)@(negedge sys_clk);
        if(fault || !audio_config_valid)$fatal(1,"Short-lock-drop recovery lost config");
        passed=1;
        $display("PASS audio bridge: ordered configs/events/ACKs, actual sample transport, FIFO backpressure, queued-note restart cancellation, overflow mute fault and PLL-loss recovery");
        $finish;
    end
    initial begin #1000000;$fatal(1,"Audio bridge timeout");end
endmodule
