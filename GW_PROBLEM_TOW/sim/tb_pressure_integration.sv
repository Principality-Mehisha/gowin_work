`timescale 1ns/1ps
module GSR(input GSRI); endmodule
module tb_pressure_integration;
    localparam UART_TICKS=8;
    reg clk=0,k2=0,rx=1;
    always #10 clk=~clk;
    reg [6:0] group_mask=7'b0000100;
    reg [11:0] voltages[0:15];
    reg [11:0] adc_data=0,pipeline0=0,pipeline1=0;
    wire [3:0] select;
    wire [7:0] leds;
    wire adc_clk,cs,sck,mosi,miso,bck,ws,din;
    reg passed=0;
    integer i,ons=0,offs=0,updates=0,heard=0,pressure_ons=0,saved,cycles=0,last_adc=0;
    integer per_note[0:87];
    GW_PROBLEM_TOW #(.VIDEO_ENABLE(0),.POWER_ON_CYCLES(8),.AUDIO_START_CYCLES(32),
        .PITCH_GROUP_STABLE_CYCLES(3),.PRESSURE_CALIBRATION_LOG2(1),
        .PRESSURE_LONG_HOLD_FRAMES(4)) dut(
        .sys_clk(clk),.KEY0(1'b1),.KEY1(1'b1),.KEY2(k2),.uart_rx(rx),.uart_tx(),
        .bt_rx(1'b1),.bt_tx(),.ADC_DATA(adc_data),.pitch_group(group_mask),
        .S(select),.S_EN(),.CLK_500kHz(adc_clk),
        .HP_BCK(bck),.HP_WS(ws),.HP_DIN(din),.PA_EN(),
        .sd_cs_n(cs),.sd_sck(sck),.sd_mosi(mosi),.sd_miso(miso),.LEDs(leds),
        .tmds_data_p(),.tmds_data_n(),.tmds_clk_p(),.tmds_clk_n(),.LED_indicator_static());
    defparam dut.score_player.UART_CLK_HZ=76800;
    defparam dut.score_player.UART_BAUD=9600;
    defparam dut.score_player.UART_TIMEOUT_CYCLES=4000;
    defparam dut.score_player.NOTE_GATE_CYCLES=10000;
    defparam dut.score_player.NOTE_TAIL_CYCLES=20000;
    defparam dut.score_player.SD_POWER_WAIT_CYCLES=4;
    defparam dut.score_player.SD_INIT_HALF_DIV=1;
    defparam dut.score_player.SD_READ_HALF_DIV=1;
    defparam dut.score_player.CLOCKS_PER_MS=128;
    defparam dut.score_player.system.voices.piano.ATTACK_STEP=24'd4194304;
    defparam dut.score_player.system.voices.piano.DECAY_STEP=24'd1048576;
    defparam dut.score_player.system.voices.piano.SUSTAIN_LEVEL=24'd4194304;
    defparam dut.score_player.system.voices.piano.RELEASE_SHIFT=8;
    sd_card_model #(.IMAGE_FILE("output/fixed_slots/player.hex"),.IMAGE_BYTES(33554432)) card(
        .rst_n(dut.player_reset_n),.cs_n(cs),.sck(sck),.mosi(mosi),.miso(miso),
        .profile(2'd2),.fault(4'd0),.last_argument(),.read_commands(),.cmd16_seen());
    always @(posedge adc_clk) begin
        pipeline0<=voltages[select];pipeline1<=pipeline0;adc_data<=#120 pipeline1;
        if(last_adc!=0 && cycles-last_adc!=100)$fatal(1,"ADC clock changed");
        last_adc=cycles;
    end
    `include "uart_test_tasks.vh"
    always @(negedge clk)begin
        #1;
        if(dut.player_reset_n && !dut.score_player.system.marimba_mode &&
           dut.video_keys!==dut.score_player.system.voices.piano.gates)
            $fatal(1,"Pressure/audition waterfall keys differ from sounding piano gates");
        if((!dut.player_reset_n || !dut.score_player.system.pressure_enable ||
            dut.score_player.system.pressure_calibrated!=16'hffff) && leds!==8'hff)
            $fatal(1,"LEDs retained old status/mode/reset indication");
    end
    task scans(input integer count);
        repeat(count*16*1500)@(negedge clk);
    endtask
    always @(posedge clk)begin
        cycles=cycles+1;
        if(!dut.player_reset_n)last_adc=0;
        if(dut.player_reset_n)begin
            if(dut.score_player.system.deadline_error)$fatal(1,"Pressure compute deadline");
            if(dut.score_player.pcm!=0)heard=heard+1;
            if(dut.score_player.system.synth_event_valid && dut.score_player.system.synth_event_ready)begin
                if(dut.score_player.system.synth_event_update)updates=updates+1;
                else if(dut.score_player.system.synth_event_on)begin
                    ons=ons+1;per_note[dut.score_player.system.synth_event_note]=
                        per_note[dut.score_player.system.synth_event_note]+1;
                    if(dut.score_player.system.manual_mode && !dut.score_player.system.note_busy)
                        pressure_ons=pressure_ons+1;
                end else offs=offs+1;
            end
            if(dut.score_player.system.storage_enable && dut.score_player.system.pressure_enable)
                $fatal(1,"Pressure and SD both own the synth");
            if(dut.score_player.system.marimba_mode && (dut.video_keys || dut.video_active))
                $fatal(1,"Marimba reached piano waterfall");
        end
    end
    reg [31:0] dac_frame;
    reg [15:0] expected_pcm;
    integer bit_number;
    initial forever begin
        @(posedge dut.score_player.sample_tick);
        fork: capture_frame
            begin
                expected_pcm=dut.score_player.pcm;dac_frame=0;
                for(bit_number=0;bit_number<32;bit_number=bit_number+1)begin
                    @(posedge bck);dac_frame={dac_frame[30:0],din};
                    if(ws!==(bit_number>=16))$fatal(1,"DAC word select");
                end
                if(dac_frame!=={expected_pcm,expected_pcm})$fatal(1,"Pressure stereo DAC mismatch");
            end
            begin @(negedge dut.player_reset_n); end
        join_any
        disable capture_frame;
    end
    initial begin
        for(i=0;i<88;i=i+1)per_note[i]=0;
        for(i=0;i<16;i=i+1)voltages[i]=3510+i*3;
        repeat(20)@(negedge clk);k2=1;
        wait(dut.player_reset_n);scans(4);
        if(dut.score_player.system.pressure_calibrated!=16'hffff)$fatal(1,"ADC calibration");
        for(i=0;i<16;i=i+1)voltages[i]=1900+i*3;
        scans(20);
        if(pressure_ons!=16 || dut.score_player.system.voices.piano.active_voices!=16 || !heard ||
           !dut.audio_analysis_active || dut.score_player.player_state!=4 || leds==8'hff)
            $fatal(1,"Integrated pressure chord/status/analysis");
        for(i=0;i<16;i=i+1)voltages[i]=2700+i*3;
        scans(35);
        if(pressure_ons!=16 || !updates ||
           leds!==8'h00 ||
           dut.score_player.system.voices.piano.voice_ram[32][90:83]<140 ||
           dut.score_player.system.voices.piano.voice_ram[32][90:83]>150)
            $fatal(1,"Continuous gain decrease retriggered or failed");
        group_mask=7'b0001000;scans(6);
        for(i=0;i<16;i=i+1)voltages[i]=3510+i*3;
        scans(18);
        if(offs!=16 || dut.score_player.system.voices.piano.gates!=0 ||
           !dut.score_player.system.voices.piano_busy || !dut.audio_analysis_active || leds!==8'hff)
            $fatal(1,"Mapped release/tail ownership");
        repeat(300)@(posedge dut.score_player.sample_tick);
        if(dut.score_player.system.voices.piano_busy)$fatal(1,"Pressure tail did not finish");
        voltages[0]=1900;scans(12);saved=pressure_ons;
        send_frame(0,'h42,0,0,0);wait(dut.score_player.system.note_busy);
        if(dut.score_player.system.pressure_enable)$fatal(1,"Audition did not suspend pressure");
        wait(!dut.score_player.system.note_busy);scans(8);
        if(pressure_ons!=saved || leds!==8'hff)$fatal(1,"Held key replayed/lit LEDs after audition");
        voltages[0]=3510;scans(20);voltages[0]=1900;scans(12);
        if(pressure_ons!=saved+1 || per_note[48]!=2)
            $fatal(1,"Fresh key failed after audition/group: ons=%0d saved=%0d note48=%0d pressed=%h",
                pressure_ons,saved,per_note[48],dut.score_player.system.pressure_pressed);
        send_frame(0,'h44,0,0,0);saved=pressure_ons;
        voltages[1]=1903;scans(8);
        if(pressure_ons!=saved || dut.score_player.pcm!=0)$fatal(1,"Invalid fourth marimba group sounded");
        send_frame(0,'h43,0,0,0);scans(8);
        if(pressure_ons!=saved || leds!==8'hff)$fatal(1,"Held key replayed/lit LEDs after instrument switch");
        // First SD selection must also work while pressure is actively
        // sounding and no catalog has ever been scanned.
        voltages[0]=3510;voltages[1]=3513;scans(20);
        voltages[0]=1900;scans(12);saved=pressure_ons;
        if(!dut.score_player.system.pressure_busy || dut.score_player.player_state!=4 ||
           dut.score_player.catalog_valid || dut.score_player.sd_active)
            $fatal(1,"Cold-pressure selection setup failed");
        send_frame(0,'h12,1,1,0);wait(dut.score_player.system.ringtone_active);
        if(!dut.score_player.sd_active || dut.score_player.system.pressure_enable)
            $fatal(1,"Cold selection did not transfer pressure ownership to SD");
        voltages[2]=1906;
        wait(dut.score_player.playing);wait(!dut.score_player.system.ringtone_active);scans(6);
        if(pressure_ons!=saved || dut.score_player.last_error)$fatal(1,"SD/pressure stale event or error");
        send_frame(0,'h12,2,1,0);wait(dut.score_player.playing);
        if(!dut.audio_analysis_active)$fatal(1,"MB missing from shared analysis");
        wait(!dut.score_player.system.ringtone_active);scans(4);
        for(i=0;i<16;i=i+1)voltages[i]=3510+i*3;
        scans(20);voltages[0]=1900;scans(12);
        force dut.score_player.system.pressure_input.keyboard.events.overflow=1;
        repeat(4)@(negedge clk);
        release dut.score_player.system.pressure_input.keyboard.events.overflow;
        repeat(100)@(negedge clk);
        if(!dut.score_player.system.pressure_fault || dut.score_player.last_error!='h61 ||
           dut.score_player.pcm!=0 || dut.score_player.player_state!=3)
            $fatal(1,"Overflow did not latch and mute");
        send_frame(0,'h11,0,0,0);scans(4);
        if(dut.score_player.system.pressure_fault || dut.score_player.last_error ||
           dut.score_player.system.pressure_calibrated!=16'hffff)
            $fatal(1,"Stop fault recovery lost calibration");
        @(negedge clk);k2=0;repeat(8)@(negedge clk);
        if(dut.score_player.pcm!=0 || dut.score_player.system.pressure_calibrated!=0 ||
           dut.score_player.system.voices.piano.gates!=0)$fatal(1,"KEY2 pressure reset");
        for(i=0;i<16;i=i+1)voltages[i]=3510+i*3;
        k2=1;wait(dut.player_reset_n);scans(4);
        if(dut.score_player.system.pressure_calibrated!=16'hffff)$fatal(1,"KEY2 recalibration");
        passed=1;$display("PASS pressure top: coherent ADC, 16 voices, continuous gain, DAC, group latch, tails, cold SD takeover during pressure, UART/SD/MB ownership, held-key suppression, overflow/recovery and KEY2");$finish;
    end
    initial begin #300000000;$fatal(1,"Pressure integration timeout");end
endmodule
