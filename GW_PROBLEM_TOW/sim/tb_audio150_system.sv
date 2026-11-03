`timescale 1ns/1ps
module tb_audio150_system;
    localparam UART_TICKS=8;
    reg clk=0,k2=0,rx=1,passed=0;
    always #10 clk=~clk;
    GSR GSR(.GSRI(1'b1));
    reg [6:0] group_mask=7'b0001000;
    reg [11:0] voltages[0:15],adc_data=3510,pipeline0=3510,pipeline1=3510;
    `include "pressure_scan_mapping.vh"
    wire [3:0] select;
    wire adc_clk,cs,sck,mosi,miso,bck,ws,din,led;
    wire [7:0] leds;
    integer i,ons=0,updates=0,heard=0,sd_starts=0,saved_ons,epoch_index;
    integer audio_cycles=0,last_tick=-1,dac_frames=0,returned_samples=0,return_packets=0;
    integer wr_count[0:255],rd_count[0:255];
    reg [31:0] packets[0:255][0:16383];
    reg expected_sample_valid=0;
    reg [15:0] expected_sample;
    reg [7:0] initial_marimba_gain;
    GW_PROBLEM_TOW #(.VIDEO_ENABLE(0),.POWER_ON_CYCLES(8),.AUDIO_START_CYCLES(32),
        .PRESSURE_CALIBRATION_LOG2(1),.PITCH_GROUP_STABLE_CYCLES(3),
        .PRESSURE_LONG_HOLD_FRAMES(4)) dut(
        .sys_clk(clk),.KEY0(1'b1),.KEY1(1'b1),.KEY2(k2),
        .ADC_DATA(adc_data),.pitch_group(group_mask),.S(select),.S_EN(),.CLK_500kHz(adc_clk),
        .uart_rx(rx),.uart_tx(),.bt_rx(1'b1),.bt_tx(),
        .HP_BCK(bck),.HP_WS(ws),.HP_DIN(din),.PA_EN(),
        .sd_cs_n(cs),.sd_sck(sck),.sd_mosi(mosi),.sd_miso(miso),.LEDs(leds),
        .tmds_data_p(),.tmds_data_n(),.tmds_clk_p(),.tmds_clk_n(),
        .LED_indicator_static(),.LED_indicator_dynamic(led));
    defparam dut.score_player.UART_CLK_HZ=76800;
    defparam dut.score_player.UART_BAUD=9600;
    defparam dut.score_player.UART_TIMEOUT_CYCLES=4000;
    defparam dut.score_player.NOTE_GATE_CYCLES=100000;
    defparam dut.score_player.NOTE_TAIL_CYCLES=200000;
    defparam dut.score_player.SD_POWER_WAIT_CYCLES=4;
    defparam dut.score_player.SD_INIT_HALF_DIV=1;
    defparam dut.score_player.SD_READ_HALF_DIV=1;
    defparam dut.score_player.CLOCKS_PER_MS=10000;
    sd_card_model #(.IMAGE_FILE("output/key_guide/card.hex"),.IMAGE_BYTES(33554432)) card(
        .rst_n(dut.player_reset_n),.cs_n(cs),.sck(sck),.mosi(mosi),.miso(miso),
        .profile(2'd2),.fault(4'd0),.last_argument(),.read_commands(),.cmd16_seen());
    always @(posedge adc_clk)begin
        pipeline0<=voltages[pressure_key_for_select(select)];pipeline1<=pipeline0;adc_data<=#120 pipeline1;
    end
    `include "uart_test_tasks.vh"
    `include "key_guide_reference.vh"
    wire [383:0] led_frame;
    wire led_valid;
    wire signed [31:0] led_frames;
    reg [383:0] expected_led=0;
    reg saw_green=0,saw_yellow=0;
    ws2812_monitor led_monitor(.clk(clk),.reset_n(dut.player_reset_n),.data_in(led),
        .frame(led_frame),.frame_valid(led_valid),.frames(led_frames));
    wire fft_valid,fft_busy;
    wire [8:0] fft_address;
    wire [31:0] fft_data;
    reg recording=0;
    integer captures=0,rows=0,input_file,result_file;
    piano_audio_analysis analysis(
        .clk(clk),.reset_n(dut.player_reset_n),.clear(dut.analysis_clear),
        .sample_valid(dut.analysis_sample_tick && dut.audio_analysis_active),.sample_pcm(dut.analysis_pcm),
        .out_ready(1'b1),.out_valid(fft_valid),.out_address(fft_address),.out_data(fft_data),
        .completed_frames(),.busy(fft_busy));
    always @(posedge dut.score_player.audio_clk)begin
        if(!dut.score_player.audio_reset_n)begin audio_cycles=0;last_tick=-1;end
        else begin
            audio_cycles=audio_cycles+1;
            if(dut.score_player.sample_tick)begin
                if((^dut.score_player.dac_sample_pcm)===1'bx)$fatal(1,"Unknown native DAC word");
                if(last_tick>=0 && audio_cycles-last_tick!=3072)$fatal(1,"Native DAC sample cadence");
                last_tick=audio_cycles;
            end
        end
        if(dut.score_player.system.engine_reset_n)begin
            if(dut.score_player.system.audio_deadline_error || dut.score_player.system.audio_effect_fault)
                $fatal(1,"150 MHz render/effects deadline");
            if(dut.score_player.system.audio_event_valid && dut.score_player.system.audio_event_ready)begin
                if(dut.score_player.system.audio_event_update)updates=updates+1;
                else if(dut.score_player.system.audio_event_on)ons=ons+1;
            end
        end
        if(dut.score_player.system.clock_bridge.feedback.wr_valid &&
           dut.score_player.system.clock_bridge.feedback.wr_ready)begin
            epoch_index=dut.score_player.system.clock_bridge.return_word[30:23];
            if(wr_count[epoch_index]>=16384)$fatal(1,"Test packet capacity");
            packets[epoch_index][wr_count[epoch_index]]=dut.score_player.system.clock_bridge.return_word;
            wr_count[epoch_index]=wr_count[epoch_index]+1;
        end
    end
    always @(posedge clk)begin
        expected_sample_valid=0;
        if(dut.player_reset_n)begin
            if(dut.score_player.system.bridge_fault)$fatal(1,"Normal native flow overflowed CDC");
            if(dut.score_player.system.uart_start)sd_starts=sd_starts+1;
            if(dut.score_player.system.clock_bridge.return_valid &&
               !dut.score_player.system.control_restart &&
               dut.score_player.system.clock_bridge.returned[30:23]==dut.score_player.system.clock_bridge.epoch)begin
                epoch_index=dut.score_player.system.clock_bridge.epoch;
                if(rd_count[epoch_index]>=wr_count[epoch_index] ||
                   dut.score_player.system.clock_bridge.returned!==packets[epoch_index][rd_count[epoch_index]])
                    $fatal(1,"Actual DAC/event feedback CDC changed or reordered a packet");
                rd_count[epoch_index]=rd_count[epoch_index]+1;return_packets=return_packets+1;
                if(dut.score_player.system.clock_bridge.returned[31])begin
                    expected_sample_valid=1;
                    expected_sample=dut.score_player.system.clock_bridge.returned[15:0];
                end
            end
            if(dut.dynamic_leds.state==0 && dut.dynamic_leds.wait_count==dut.dynamic_leds.wait_last)
                expected_led<=reference_frame(dut.video_keys,dut.guide_active && !dut.upload_active,
                                              dut.guide_palette);
            if(led_valid)begin
                if(led_frame!==expected_led)$fatal(1,"Native domain broke 50 MHz guide");
                if(led_frame[216 +:24]==24'h400000)saw_green=1;
                if(led_frame[216 +:24]==24'h404000)saw_yellow=1;
            end
            if(recording && (analysis.first_sample ||
               (analysis.state==1 && dut.analysis_sample_tick && dut.audio_analysis_active && !dut.analysis_clear)))begin
                if(captures<1024)$fdisplay(input_file,"%04x",dut.analysis_pcm);
                captures=captures+1;
            end
            if(recording && fft_valid && rows<512)begin
                if(fft_address!==rows[8:0])$fatal(1,"Native FFT row order");
                $fdisplay(result_file,"%08x",fft_data);rows=rows+1;
                if(rows==512)recording=0;
            end
        end
    end
    always @(negedge clk)if(dut.player_reset_n)begin
        if(dut.analysis_sample_tick!==expected_sample_valid)$fatal(1,"Feedback sample-valid pulse");
        if(dut.analysis_sample_tick)begin
            if((^dut.analysis_pcm)===1'bx)$fatal(1,"Unknown native analysis sample");
            if(dut.analysis_pcm!==expected_sample)$fatal(1,"FFT input differs from captured DAC word");
            returned_samples=returned_samples+1;
            if(dut.analysis_pcm!=0)heard=heard+1;
        end
    end
    reg [31:0] dac_word;
    reg [15:0] latched;
    integer bit_number;
    initial forever begin
        @(posedge dut.score_player.sample_tick);
        fork:capture_dac
            begin
                #0.001;latched=dut.score_player.dac_sample_pcm;dac_word=0;
                for(bit_number=0;bit_number<32;bit_number=bit_number+1)begin
                    @(posedge bck);dac_word={dac_word[30:0],din};
                    if(ws!==(bit_number>=16))$fatal(1,"Native PT8211 word select");
                end
                if(dac_word!=={latched,latched})$fatal(1,"Native actual DAC serial sample");
                dac_frames=dac_frames+1;
            end
            begin @(negedge dut.score_player.audio_reset_n);end
        join_any
        disable capture_dac;
    end
    task settle;
        begin wait(dut.score_player.uart_control.link.count==0 &&
                   dut.score_player.uart_control.link.formatter.ready);
            repeat(100)@(negedge clk);end
    endtask
    task stop_playing;
        begin send_frame(0,'h11,0,0,0);settle();
            repeat(64)@(posedge dut.score_player.sample_tick);
            if(dut.score_player.pcm!=0 || dut.audio_analysis_active)
                $fatal(1,"Native STOP retained audio/analysis");end
    endtask
    initial begin
        for(i=0;i<256;i=i+1)begin wr_count[i]=0;rd_count[i]=0;end
        for(i=0;i<16;i=i+1)voltages[i]=3510;
        repeat(8)@(negedge clk);k2=1;wait(dut.player_reset_n);
        wait(dut.score_player.system.pressure_calibrated==16'hffff &&
             dut.score_player.system.audio_link_ready);settle();
        input_file=$fopen("output/audio150/piano_input.hex","w");
        result_file=$fopen("output/audio150/piano_result.hex","w");recording=1;
        for(i=0;i<16;i=i+1)voltages[i]=1900;
        wait(dut.score_player.system.pressure_pressed==16'hffff);
        repeat(1600)@(posedge dut.score_player.sample_tick);
        wait(rows==512);recording=0;$fclose(input_file);$fclose(result_file);
        if(captures!=1024 || ons!=16 || dut.score_player.system.voices.piano.active_voices!=16 ||
           leds!=0 || !heard)$fatal(1,"Native pressure/FFT/hold LED coverage");
        saved_ons=ons;
        for(i=0;i<16;i=i+1)voltages[i]=2400;
        repeat(600)@(posedge dut.score_player.sample_tick);
        if(ons!=saved_ons || !updates ||
           dut.score_player.system.voices.piano.voice_ram[48][90:83]>180)
            $fatal(1,"Native live pressure retrigger/slew");
        for(i=0;i<16;i=i+1)voltages[i]=3510;
        wait(dut.score_player.system.pressure_pressed==0);
        if(leds!==8'hff)$fatal(1,"Native release retained hold lights");
        stop_playing();
        send_frame(0,'h44,0,0,0);settle();group_mask=7'b0000100;
        repeat(1000)@(negedge clk);voltages[0]=1900;
        wait(ons==saved_ons+1);@(negedge dut.score_player.audio_clk);
        initial_marimba_gain=dut.score_player.system.voices.marimba.dynamics_by_note[32];
        if((^initial_marimba_gain)===1'bx)$fatal(1,"Unknown native marimba strike gain");
        repeat(128)@(posedge dut.score_player.sample_tick);voltages[0]=1300;
        repeat(300)@(posedge dut.score_player.sample_tick);
        if(ons!=saved_ons+1 ||
           dut.score_player.system.voices.marimba.dynamics_by_note[32]!==initial_marimba_gain)
            $fatal(1,"Native marimba pressure retriggered or changed attack");
        voltages[0]=3510;wait(dut.score_player.system.pressure_pressed==0);stop_playing();
        send_frame(0,'h12,1,1,0);wait(dut.score_player.playing);
        wait(!dut.score_player.sd_active);repeat(4)@(negedge clk);
        if(!saw_green || !saw_yellow || sd_starts!=1)$fatal(1,"Native SD/guide timeline");
        send_frame(0,'h12,2,1,0);wait(dut.score_player.playing);
        wait(!dut.score_player.sd_active);stop_playing();
        send_frame(0,'h12,1,2,0);wait(dut.score_player.last_error=='h31);stop_playing();
        send_frame(0,'h42,0,0,0);wait(dut.score_player.system.note_busy);
        @(negedge clk);k2=0;repeat(8)@(negedge clk);
        for(i=0;i<256;i=i+1)begin wr_count[i]=0;rd_count[i]=0;end
        k2=1;
        wait(dut.player_reset_n);wait(dut.score_player.audio_reset_n);settle();
        if(dut.score_player.selected_track || dut.score_player.pcm || dut.guide_active)
            $fatal(1,"Native KEY2 retained an old session");
        if(dac_frames<1024 || returned_samples<1024 || return_packets<1024)
            $fatal(1,"Missing native sample/packet serial coverage");
        passed=1;
        $display("PASS native system: real 50 MHz ADC/UART/SD/LED and official 150 MHz PLL/FIFOs, 16-key piano/pressure updates, marimba, PN/MB playback, errors/STOP/reset, 1024 actual DAC FFT samples; %0d stereo frames, %0d exact return packets",dac_frames,return_packets);
        $finish;
    end
    initial begin #500000000;$fatal(1,"Native system timeout");end
endmodule
