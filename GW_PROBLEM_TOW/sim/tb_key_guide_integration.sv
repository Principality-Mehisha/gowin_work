`timescale 1ns/1ps
module tb_key_guide_integration;
    localparam UART_TICKS=8;
    reg clk=0,k2=1,rx=1,passed=0;
    always #10 clk=~clk;
    wire cs,sck,mosi,miso,ref_cs,ref_sck,ref_mosi,ref_miso,ref_reset;
    wire bck,ws,din,amp,tx,ref_bck,ref_ws,ref_din,ref_amp,ref_tx;
    wire led,frame_valid;
    wire [383:0] frame;
    wire signed [31:0] frames;
    reg [383:0] expected=0;
    reg green7=0,green_chord=0,yellow7=0,cyan8=0,fallback=0,red7=0,red_edges=0;
    integer checked=0,heard=0,target;
    GW_PROBLEM_TOW #(.VIDEO_ENABLE(0),.PRESSURE_ENABLE(0),
        .POWER_ON_CYCLES(8),.AUDIO_START_CYCLES(32)) dut(
        .sys_clk(clk),.KEY0(1'b1),.KEY1(1'b1),.KEY2(k2),
        .ADC_DATA(12'd3510),.pitch_group(7'd0),.S(),.S_EN(),.CLK_500kHz(),
        .uart_rx(rx),.uart_tx(tx),.bt_rx(1'b1),.bt_tx(),
        .HP_BCK(bck),.HP_WS(ws),.HP_DIN(din),.PA_EN(amp),
        .sd_cs_n(cs),.sd_sck(sck),.sd_mosi(mosi),.sd_miso(miso),.LEDs(),
        .tmds_data_p(),.tmds_data_n(),.tmds_clk_p(),.tmds_clk_n(),
        .LED_indicator_static(),.LED_indicator_dynamic(led));
    defparam dut.score_player.UART_CLK_HZ=76800;
    defparam dut.score_player.UART_BAUD=9600;
    defparam dut.score_player.UART_TIMEOUT_CYCLES=4000;
    defparam dut.score_player.NOTE_GATE_CYCLES=50000;
    defparam dut.score_player.NOTE_TAIL_CYCLES=100000;
    defparam dut.score_player.SD_POWER_WAIT_CYCLES=4;
    defparam dut.score_player.SD_INIT_HALF_DIV=1;
    defparam dut.score_player.SD_READ_HALF_DIV=1;
    defparam dut.score_player.CLOCKS_PER_MS=10000;
    // Identical player with no LED driver attached: audio and SD must not move.
    piano_score_player #(.PRESSURE_ENABLE(0),.POWER_ON_CYCLES(8),.AUDIO_START_CYCLES(32),
        .UART_CLK_HZ(76800),.UART_BAUD(9600),.UART_TIMEOUT_CYCLES(4000),
        .NOTE_GATE_CYCLES(50000),.NOTE_TAIL_CYCLES(100000),
        .SD_POWER_WAIT_CYCLES(4),.SD_INIT_HALF_DIV(1),.SD_READ_HALF_DIV(1),
        .CLOCKS_PER_MS(10000)) reference_player(
        .sys_clk(clk),.KEY2(k2),.pitch_group(7'd0),
        .pressure_sample_valid(1'b0),.pressure_sample_key(4'd0),.pressure_sample_data(12'd0),
        .uart_rx(rx),.upload_complete(1'b0),.upload_invalidated(1'b0),.uploaded_track(8'd0),
        .uart_tx(ref_tx),.HP_BCK(ref_bck),.HP_WS(ref_ws),.HP_DIN(ref_din),.PA_EN(ref_amp),
        .sd_cs_n(ref_cs),.sd_sck(ref_sck),.sd_mosi(ref_mosi),.sd_miso(ref_miso),.LEDs(),
        .player_reset_n(ref_reset),.video_active(),.video_clear(),.video_elapsed_ms(),
        .display_mode(),.audio_analysis_active(),.analysis_clear(),.analysis_sample_tick(),
        .analysis_pcm(),.video_keys(),.guide_active());
    sd_card_model #(.IMAGE_FILE("output/key_guide/card.hex"),.IMAGE_BYTES(33554432)) card(
        .rst_n(dut.player_reset_n),.cs_n(cs),.sck(sck),.mosi(mosi),.miso(miso),
        .profile(2'd2),.fault(4'd0),.last_argument(),.read_commands(),.cmd16_seen());
    sd_card_model #(.IMAGE_FILE("output/key_guide/card.hex"),.IMAGE_BYTES(33554432)) ref_card(
        .rst_n(ref_reset),.cs_n(ref_cs),.sck(ref_sck),.mosi(ref_mosi),.miso(ref_miso),
        .profile(2'd2),.fault(4'd0),.last_argument(),.read_commands(),.cmd16_seen());
    ws2812_monitor monitor(.clk(clk),.reset_n(dut.player_reset_n),.data_in(led),
        .frame(frame),.frame_valid(frame_valid),.frames(frames));
    `include "uart_test_tasks.vh"
    `include "key_guide_reference.vh"
    always @(posedge clk) begin
        if(dut.player_reset_n && dut.dynamic_leds.state==0 &&
           dut.dynamic_leds.wait_count==dut.dynamic_leds.wait_last)
            expected<=reference_frame(dut.video_keys,dut.guide_active && !dut.upload_active,
                                      dut.guide_palette);
        if(dut.player_reset_n && frame_valid)begin
            if(frame!==expected)$fatal(1,"Board guide serial frame not coherent with SD piano keys");
            checked=checked+1;
            if(frame[216 +:24]==24'h400000)begin
                green7=1;
                if(yellow7)fallback=1;
                if(frame[144 +:24]==24'h400000)green_chord=1;
            end
            if(frame[216 +:24]==24'h404000)yellow7=1;
            if(frame[192 +:24]==24'h40002c)cyan8=1;
            if(frame[216 +:24]==24'h004000)red7=1;
            if(frame[360 +:24]==24'h004000 && frame[0 +:24]==24'h004000)red_edges=1;
        end
    end
    always @(negedge clk)if(dut.player_reset_n)begin
        if(dut.score_player.pcm!==reference_player.pcm ||
           {bck,ws,din,amp,tx,cs,sck,mosi}!=={ref_bck,ref_ws,ref_din,ref_amp,ref_tx,ref_cs,ref_sck,ref_mosi})
            $fatal(1,"LED guide changed PCM, actual DAC pins, UART feedback or SD timing");
        if(dut.score_player.system.deadline_error || dut.score_player.system.effect_fault)
            $fatal(1,"Guide caused audio deadline fault");
        if(dut.score_player.pcm!=0)heard=heard+1;
        if(dut.guide_active &&
           (!dut.score_player.playing || !dut.score_player.sd_active ||
            dut.score_player.selected_track<4 || dut.score_player.selected_track>103))
            $fatal(1,"Guide enabled outside SD piano playback");
    end
    task expect_dark;
        begin target=frames+2;wait(frames>=target);@(posedge clk);
            if(frame!==0)$fatal(1,"Guide did not clear after EOF/STOP/switch/error/reset");end
    endtask
    initial begin
        wait(dut.player_reset_n);expect_dark();
        send_frame(0,'h42,0,0,0);wait(dut.score_player.system.note_busy);
        if(dut.guide_active)$fatal(1,"UART audition enabled SD guide");
        wait(!dut.score_player.system.note_busy);expect_dark();
        send_frame(0,'h12,1,1,0);wait(dut.score_player.playing);
        wait(!dut.score_player.sd_active);expect_dark();
        if(!green7 || !green_chord || !yellow7 || !cyan8 || !fallback || !red7 || !red_edges || !heard)
            $fatal(1,"Missing real-score guide/color/chord/conflict/fallback/C8/audio coverage");
        send_frame(0,'h12,1,1,0);wait(dut.guide_active && frame!=0);
        send_frame(0,'h12,2,1,0);wait(dut.score_player.selected_track==104);
        expect_dark();wait(dut.score_player.playing);
        if(dut.guide_active)$fatal(1,"Marimba SD enabled piano guide");
        wait(!dut.score_player.sd_active);expect_dark();
        send_frame(0,'h12,1,1,0);wait(dut.guide_active && frame!=0);
        send_frame(0,'h11,0,0,0);expect_dark();
        send_frame(0,'h12,1,2,0);wait(dut.score_player.last_error=='h31);expect_dark();
        send_frame(0,'h11,0,0,0);
        send_frame(0,'h12,1,1,0);wait(dut.guide_active);
        wait(dut.dynamic_leds.state==3);
        @(negedge clk);k2=0;repeat(8)@(negedge clk);k2=1;
        wait(dut.player_reset_n);expect_dark();
        if(dut.guide_active || dut.score_player.selected_track)$fatal(1,"Guide reset retained playback");
        if(checked<10)$fatal(1,"Missing production-timing serial frames");
        passed=1;
        $display("PASS guide integration: actual top/UART/SD, group2 key7, same-group chords, cross-group collision/fallback, C8, EOF/STOP/marimba/audition/error/reset; %0d frames; PCM/DAC/UART/SD cycle-exact against player without LEDs",checked);
        $finish;
    end
    initial begin #1000000000;$fatal(1,"Guide integration timeout");end
endmodule
