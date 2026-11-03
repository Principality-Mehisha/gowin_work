`timescale 1ns/1ps
module tb_piano88_uart;
    localparam UART_TICKS=8;
    reg clk=0,k2=0,rx=1,passed=0;
    always #10 clk=~clk;
    integer ons=0,offs=0,heard=0,i,prior_ons;
    piano_score_player #(.POWER_ON_CYCLES(8),.AUDIO_START_CYCLES(32),
        .PRESSURE_ENABLE(1),.PRESSURE_CALIBRATION_LOG2(1),
        .UART_CLK_HZ(76800),.UART_BAUD(9600),.UART_TIMEOUT_CYCLES(4000),
        .NOTE_GATE_CYCLES(80000),.NOTE_TAIL_CYCLES(40000)) dut(
        .sys_clk(clk),.KEY2(k2),.uart_rx(rx),.uart_tx(),
        .pitch_group(7'd1),.pressure_sample_valid(1'b0),
        .pressure_sample_key(4'd0),.pressure_sample_data(12'd3510),
        .upload_complete(1'b0),.upload_invalidated(1'b0),.uploaded_track(8'd0),
        .HP_BCK(),.HP_WS(),.HP_DIN(),.PA_EN(),
        .sd_cs_n(),.sd_sck(),.sd_mosi(),.sd_miso(1'b1),.LEDs(),
        .player_reset_n(),.video_active(),.video_clear(),.video_elapsed_ms(),
        .display_mode(),.audio_analysis_active(),.analysis_clear(),.analysis_sample_tick(),
        .analysis_pcm(),.video_keys(),.guide_active(),.guide_keys());
    `include "uart_test_tasks.vh"
    audio_gate_cdc_monitor monitor(
        .sys_clk(clk),.audio_clk(dut.audio_clk),.reset_n(dut.system.clock_bridge.link_reset_n),
        .enable(dut.system.audio_link_ready),.sys_clear(dut.system.synth_stop || dut.system.marimba_mode),
        .source_fire(dut.system.audio_event_valid && dut.system.audio_event_ready),
        .source_marimba(dut.system.audio_config[9]),.source_update(dut.system.audio_event_update),
        .source_on(dut.system.audio_event_on),.source_note(dut.system.audio_event_note),
        .ack_valid(dut.system.ack_valid),.ack_clear(dut.system.ack_clear),
        .ack_marimba(dut.system.ack_marimba),.ack_update(dut.system.ack_update),
        .ack_on(dut.system.ack_on),.ack_note(dut.system.ack_note),.keys(dut.video_keys));
    always @(posedge dut.audio_clk)if(dut.system.engine_reset_n)begin
        if(dut.system.audio_deadline_error || dut.system.audio_effect_fault)
            $fatal(1,"88-note native audio deadline");
        if(dut.system.audio_event_valid && dut.system.audio_event_ready &&
           dut.system.audio_event_note==127)begin
            if(dut.system.audio_config[9] || dut.system.audio_event_update)
                $fatal(1,"Broadcast routed to wrong instrument/type");
            if(dut.system.audio_event_on)ons=ons+1;else offs=offs+1;
        end
    end
    always @(posedge clk)if(dut.rst_n)begin
        if(dut.system.bridge_fault)$fatal(1,"88-note CDC fault");
        if(dut.pcm!=0)heard=heard+1;
        if(dut.system.note_busy && dut.system.pressure_enable)
            $fatal(1,"Pressure input remained enabled during audition");
    end
    task settle;
        begin wait(dut.uart_control.link.count==0 && dut.uart_control.link.formatter.ready);
            repeat(100)@(negedge clk);end
    endtask
    task start_all;
        begin
            prior_ons=ons;send_frame(0,'h46,0,0,0);wait(ons==prior_ons+1);
            wait(dut.video_keys=={88{1'b1}});
            wait(dut.system.voices.piano.active_voices==88);
            if(dut.selected_marimba || dut.sd_active || dut.player_state!=4)
                $fatal(1,"88-note ownership/status/piano selection");
        end
    endtask
    task check_silent;
        begin settle();repeat(4)@(posedge dut.sample_tick);@(negedge clk);
            if(dut.system.note_busy || dut.video_keys || dut.pcm || dut.last_error)
                $fatal(1,"Stopped 88-note session retained audio/state");end
    endtask
    initial begin
        repeat(8)@(negedge clk);k2=1;wait(dut.rst_n);settle();
        send_frame(0,'h41,0,0,0);settle();
        send_frame(0,'h44,0,0,0);settle();
        start_all();
        if(dut.selected_note!=1)$fatal(1,"Broadcast destroyed remembered piano selection");
        wait(offs==1);wait(dut.video_keys==0);wait(!dut.system.note_busy);check_silent();
        if(!heard || ons!=1 || offs!=1)$fatal(1,"Missing 88-note audio or timed release");
        // Invalid arguments and bad checksums must not trigger a broadcast.
        send_frame(0,'h46,1,0,0);settle();
        send_frame(0,'h46,0,1,0);settle();
        send_frame(0,'h46,0,0,1);settle();
        send_byte('ha5);send_byte('h5a);send_byte(1);send_byte(0);send_byte('h46);
        send_byte(0);send_byte(0);send_byte(0);send_byte('h48);send_byte('h0d);
        if(ons!=1 || dut.system.note_busy)$fatal(1,"Invalid 88-note frame changed audio");
        start_all();start_all();
        send_frame(0,'h11,0,0,0);check_silent();
        start_all();send_frame(0,'h44,0,0,0);check_silent();
        if(!dut.selected_marimba)$fatal(1,"Instrument switch failed");
        start_all();send_frame(0,'h42,0,0,0);
        repeat(4)@(posedge dut.sample_tick);
        if(dut.system.voices.piano.gates!==(88'd1<<1))
            $fatal(1,"Single audition did not preempt all-note session");
        send_frame(0,'h11,0,0,0);check_silent();
        start_all();send_frame(0,'h12,1,1,0);wait(dut.sd_active);
        if(dut.system.note_busy)$fatal(1,"SD did not preempt 88-note audition");
        // Broadcast also takes over a loading SD score without a card.
        start_all();send_frame(0,'h11,0,0,0);check_silent();
        start_all();
        @(negedge clk);k2=0;repeat(8)@(negedge clk);k2=1;
        wait(dut.rst_n);check_silent();
        if(dut.selected_note || dut.selected_marimba)$fatal(1,"KEY2 selection reset failed");
        passed=1;
        $display("PASS piano88 UART: physical RX, official 150 MHz PLL/CDC, 88 sounding voices/ACK/video keys, auto release/tail, invalid frames, repeat, STOP, instrument/single/SD takeover, reset");
        $finish;
    end
    initial begin #100000000;$fatal(1,"Piano88 UART timeout");end
endmodule
