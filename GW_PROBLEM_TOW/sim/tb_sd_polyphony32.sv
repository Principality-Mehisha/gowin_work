`timescale 1ns/1ps
module tb_sd_polyphony32;
    localparam UART_TICKS=8;
    reg clk=0,k2=0,rx=1,passed=0;
    always #10 clk=~clk;
    wire cs,sck,mosi,miso,bck,ws,din;
    integer slots=32,ons=0,offs=0,audio_ons=0,audio_offs=0;
    integer max_active=0,heard=0,frames=0,i,n,modal_count;
    reg check_events=0,heard_full=0,saw_full_gates=0,saw_all_off=0;
    reg [87:0] on_mask=0,off_mask=0;
    piano_score_player #(.POWER_ON_CYCLES(8),.AUDIO_START_CYCLES(32),
        .UART_CLK_HZ(76800),.UART_BAUD(9600),.UART_TIMEOUT_CYCLES(4000),
        .SD_POWER_WAIT_CYCLES(4),.SD_INIT_HALF_DIV(1),.SD_READ_HALF_DIV(1),
        .CLOCKS_PER_MS(5000)) dut(
        .sys_clk(clk),.KEY2(k2),.pitch_group(7'd0),.pressure_sample_valid(1'b0),
        .pressure_sample_key(4'd0),.pressure_sample_data(12'd0),
        .uart_rx(rx),.uart_tx(),.upload_complete(1'b0),.upload_invalidated(1'b0),
        .uploaded_track(8'd0),.HP_BCK(bck),.HP_WS(ws),.HP_DIN(din),.PA_EN(),
        .sd_cs_n(cs),.sd_sck(sck),.sd_mosi(mosi),.sd_miso(miso),.LEDs(),
        .player_reset_n(),.video_active(),.video_clear(),.video_elapsed_ms(),
        .display_mode(),.audio_analysis_active(),.analysis_clear(),.analysis_sample_tick(),
        .analysis_pcm(),.video_keys(),.guide_active(),.guide_keys());
    sd_card_model #(.IMAGE_FILE("output/polyphony32/card.hex"),.IMAGE_BYTES(33554432)) card(
        .rst_n(dut.rst_n),.cs_n(cs),.sck(sck),.mosi(mosi),.miso(miso),
        .profile(2'd2),.fault(4'd0),.last_argument(),.read_commands(),.cmd16_seen());
    `include "uart_test_tasks.vh"
    function integer expected_note(input integer position,input bit marimba);
        integer first;
        begin
            first=marimba ? 36 : 0;
            expected_note=position<slots/2 ? first+position :
                (marimba ? 84 : 88)-slots+position;
        end
    endfunction
    always @(posedge clk)if(dut.rst_n && check_events)begin
        if(dut.last_error || dut.sequence_error)$fatal(1,"SD32 playback error %h",dut.last_error);
        if(dut.dds_event_valid && dut.dds_event_ready)begin
            n=(ons+offs)%(2*slots);
            if(dut.dds_event_on)begin
                if(n>=slots || dut.dds_event_note!=expected_note(n,dut.system.marimba_mode))
                    $fatal(1,"SD32 note-on order/value mismatch");
                ons=ons+1;
            end else begin
                if(n<slots || dut.dds_event_note!=expected_note(n-slots,dut.system.marimba_mode))
                    $fatal(1,"SD32 note-off order/value mismatch");
                offs=offs+1;
            end
            if(dut.dds_event_dynamics!= (dut.dds_event_on ? 8'd178 : 8'd0))
                $fatal(1,"SD32 velocity mismatch");
        end
        if(dut.gates== (slots==32 ? 32'hffffffff : 32'hff))saw_full_gates=1;
        if(offs>=slots && dut.gates==0)saw_all_off=1;
    end
    always @(posedge dut.audio_clk)if(dut.system.engine_reset_n && check_events)begin
        if(dut.system.audio_deadline_error || dut.system.audio_effect_fault || dut.system.bridge_fault)
            $fatal(1,"SD32 native audio deadline/CDC failure");
        if(dut.system.audio_event_valid && dut.system.audio_event_ready)begin
            if(dut.system.audio_event_on)begin
                audio_ons=audio_ons+1;on_mask[dut.system.audio_event_note]=1;
            end else begin
                audio_offs=audio_offs+1;off_mask[dut.system.audio_event_note]=1;
            end
        end
        if(dut.sample_tick)begin
            frames=frames+1;
            modal_count=0;
            if(dut.system.marimba_mode)begin
                for(integer m=0;m<48;m=m+1)
                    if(dut.system.voices.marimba.active_modes[m*4])modal_count=modal_count+1;
            end else modal_count=dut.system.voices.piano.active_voices;
            if(modal_count>max_active)max_active=modal_count;
            if((^dut.dac_sample_pcm)===1'bx)$fatal(1,"Unknown SD32 DAC sample");
            if(dut.dac_sample_pcm!=0)begin
                heard=heard+1;
                if(modal_count==slots)heard_full=1;
            end
        end
    end
    reg [31:0] dac_word;
    reg [15:0] dac_expected;
    initial forever begin
        @(posedge dut.sample_tick);#0.001;dac_expected=dut.dac_sample_pcm;dac_word=0;
        for(integer bit_index=0;bit_index<32;bit_index=bit_index+1)begin
            @(posedge bck);dac_word={dac_word[30:0],din};
            if(ws!==(bit_index>=16))$fatal(1,"SD32 DAC word select");
        end
        if(dac_word!=={dac_expected,dac_expected})$fatal(1,"SD32 DAC serial mismatch");
    end
    task play_case(input integer kind,number,polyphony);
        reg [87:0] expected_mask;
        begin
            slots=polyphony;ons=0;offs=0;audio_ons=0;audio_offs=0;
            max_active=0;heard=0;heard_full=0;saw_full_gates=0;saw_all_off=0;
            on_mask=0;off_mask=0;check_events=1;expected_mask=0;
            for(i=0;i<slots;i=i+1)expected_mask[expected_note(i,kind==2)]=1;
            send_frame(0,'h12,kind,number,0);
            wait(dut.playing);wait(!dut.system.ringtone_active);
            repeat(20)@(negedge clk);check_events=0;
            if(ons!=2*slots || offs!=2*slots || audio_ons!=2*slots || audio_offs!=2*slots ||
               max_active!=slots || !heard || !heard_full || !saw_full_gates || !saw_all_off ||
               on_mask!==expected_mask || off_mask!==expected_mask || dut.last_error)
                $fatal(1,"SD32 incomplete kind=%0d slots=%0d events=%0d/%0d audio=%0d/%0d max=%0d",
                       kind,slots,ons,offs,audio_ons,audio_offs,max_active);
            $display("PASS SD playback kind=%0d slots=%0d: repeated full chord, exact on/off, all gates, native PCM/DAC, EOF",kind,slots);
        end
    endtask
    initial begin
        repeat(8)@(negedge clk);k2=1;wait(dut.rst_n);
        play_case(1,1,32);play_case(2,1,32);
        play_case(1,2,8);play_case(2,2,8);
        if(frames<100)$fatal(1,"Insufficient native audio coverage");
        passed=1;$display("PASS SD32 integration: SPI/CRC/reader/sequencer/official PLL/FIFO/piano+marimba/DAC and legacy8");$finish;
    end
    initial begin #500000000;$fatal(1,"SD32 integration timeout");end
endmodule
