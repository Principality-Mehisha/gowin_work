`timescale 1ns/1ps
module GSR(input GSRI); endmodule
module tb_effects_integration;
    localparam UART_TICKS=8;
    reg clk=0,k2=1,rx=1,passed=0;
    always #10 clk=~clk;
    reg [11:0] voltages[0:15];
    reg [4:0] divider=0;
    reg [3:0] cursor=0,key=0;
    reg sv=0;
    reg [11:0] sd=3510;
    wire cs,sck,mosi,miso,bck,ws,din;
    integer i,ons=0,starts=0,saved_ons,saved_starts,echo_samples=0;
    piano_score_player #(.PRESSURE_ENABLE(1),.POWER_ON_CYCLES(8),.AUDIO_START_CYCLES(32),
        .PRESSURE_CALIBRATION_LOG2(0),.PRESSURE_LONG_HOLD_FRAMES(4),
        .PITCH_GROUP_STABLE_CYCLES(3),.UART_CLK_HZ(76800),.UART_BAUD(9600),
        .SD_POWER_WAIT_CYCLES(4),.SD_INIT_HALF_DIV(1),.SD_READ_HALF_DIV(1),
        .CLOCKS_PER_MS(1024)) dut(
        .sys_clk(clk),.KEY2(k2),.uart_rx(rx),.uart_tx(),.pitch_group(7'b0000100),
        .pressure_sample_valid(sv),.pressure_sample_key(key),.pressure_sample_data(sd),
        .upload_complete(1'b0),.upload_invalidated(1'b0),.uploaded_track(8'd0),
        .sd_cs_n(cs),.sd_sck(sck),.sd_mosi(mosi),.sd_miso(miso),
        .HP_BCK(bck),.HP_WS(ws),.HP_DIN(din),.PA_EN(),.LEDs());
    defparam dut.system.effects.DELAY_SAMPLES=31;
    defparam dut.system.effects.DELAY_TAIL=512;
    sd_card_model #(.IMAGE_FILE("output/fixed_slots/player.hex"),.IMAGE_BYTES(33554432)) card(
        .rst_n(dut.rst_n),.cs_n(cs),.sck(sck),.mosi(mosi),.miso(miso),
        .profile(2'd2),.fault(4'd0),.last_argument(),.read_commands(),.cmd16_seen());
    always @(posedge clk)begin
        sv<=0;
        if(!dut.rst_n)begin divider<=0;cursor<=0;end
        else if(divider==31)begin
            divider<=0;sv<=1;key<=cursor;sd<=voltages[cursor];cursor<=cursor+1'b1;
        end else divider<=divider+1'b1;
        if(dut.rst_n)begin
            if(dut.system.deadline_error || dut.system.effect_fault || dut.system.pressure_overflow)
                $fatal(1,"FX integration deadline/FIFO");
            if(dut.system.synth_event_valid && dut.system.synth_event_ready &&
               dut.system.synth_event_on && !dut.system.synth_event_update)ons=ons+1;
            if(dut.system.uart_start)starts=starts+1;
            if(dut.sample_tick && !dut.sd_active && dut.system.effect_tail && dut.pcm!=0)
                echo_samples=echo_samples+1;
        end
    end
    `include "uart_test_tasks.vh"
    task settle;
        begin wait(dut.uart_control.link.count==0 && dut.uart_control.link.formatter.ready);
            repeat(100)@(negedge clk);end
    endtask
    task effect(input integer command,input integer value);
        begin send_frame(0,command,value,0,0);settle();end
    endtask
    reg [31:0] dac_frame;
    reg [15:0] expected;
    integer bit_number;
    initial forever begin
        @(posedge dut.sample_tick);
        fork: capture
            begin
                expected=dut.pcm;dac_frame=0;
                for(bit_number=0;bit_number<32;bit_number=bit_number+1)begin
                    @(posedge bck);dac_frame={dac_frame[30:0],din};
                    if(ws!==(bit_number>=16))$fatal(1,"FX DAC word select");
                end
                if(dac_frame!=={expected,expected})$fatal(1,"FX actual DAC stereo mismatch");
            end
            begin @(negedge dut.rst_n);end
        join_any
        disable capture;
    end
    initial begin
        for(i=0;i<16;i=i+1)voltages[i]=3510;
        wait(dut.rst_n);wait(dut.system.pressure_calibrated==16'hffff);settle();
        if(dut.effect_mode!=0 || dut.effect_amount!=30)$fatal(1,"FX startup not dry/default amount");
        voltages[7]=1900;wait(ons==1);saved_ons=ons;saved_starts=starts;
        effect('h52,100);
        for(i=1;i<=3;i=i+1)begin
            effect('h51,i);
            repeat(600)@(posedge dut.sample_tick);
            if(ons!=saved_ons || starts!=saved_starts || !dut.system.voices.piano.gates[39] ||
               dut.system.effects.applied_mode!=i || dut.system.effects.wet_gain!=125 ||
               !dut.audio_analysis_active || dut.last_error)
                $fatal(1,"FX mode change reset playback or missed smooth application");
            if(i==3 && dut.system.effects.vibrato_mix!=256)
                $fatal(1,"Vibrato retained dry mix after fade");
        end
        effect('h52,0);repeat(300)@(posedge dut.sample_tick);
        if(dut.system.effects.wet_gain || dut.system.effects.vibrato_mix || ons!=saved_ons)
            $fatal(1,"FX zero amount/retrigger");
        effect('h51,1);effect('h52,100);repeat(300)@(posedge dut.sample_tick);
        // Switching timbre keeps the selection but discards the old delay.
        send_frame(0,'h44,0,0,0);settle();
        repeat(64)@(posedge dut.sample_tick);
        if(dut.pcm!=0 || dut.system.effect_tail || ons!=saved_ons ||
           dut.effect_mode!=1 || dut.effect_amount!=100)$fatal(1,"Timbre change retained old effect/audio");
        voltages[7]=3510;wait(dut.system.pressure_pressed==0);
        voltages[7]=1900;wait(ons==saved_ons+1);repeat(64)@(posedge dut.sample_tick);
        if(!dut.system.marimba_mode || !dut.system.effect_tail || !dut.audio_analysis_active)
            $fatal(1,"Marimba pressure missing effects/analysis");
        send_frame(0,'h11,0,0,0);settle();repeat(64)@(posedge dut.sample_tick);
        if(dut.pcm!=0 || dut.system.effect_tail || dut.audio_analysis_active)
            $fatal(1,"STOP retained effects or analysis");
        voltages[7]=3510;wait(dut.system.pressure_pressed==0);
        send_frame(0,'h12,1,1,0);wait(dut.playing);wait(!dut.sd_active);
        echo_samples=0;
        repeat(80)@(posedge dut.sample_tick);
        if(!dut.system.effect_tail || !dut.audio_analysis_active || !echo_samples)
            $fatal(1,"Natural SD EOF truncated echo/analysis");
        wait(!dut.system.effect_tail);repeat(4)@(negedge clk);
        if(dut.pcm!=0 || dut.audio_analysis_active)$fatal(1,"Effect tail did not expire");
        @(negedge clk);k2=0;repeat(8)@(negedge clk);k2=1;wait(dut.rst_n);
        if(dut.effect_mode!=0 || dut.effect_amount!=30 || dut.pcm!=0)
            $fatal(1,"KEY2 did not restore original/clear effects");
        passed=1;$display("PASS effect integration: real UART, held piano mode/amount changes without retrigger, zero amount, marimba, cleared timbre/STOP, natural SD EOF echo/analysis, actual stereo DAC and reset");$finish;
    end
    initial begin #1000000000;$fatal(1,"FX integration timeout");end
endmodule
