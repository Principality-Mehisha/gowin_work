`timescale 1ns/1ps
module tb_key_guide_integration #(parameter integer WARM_CATALOG=0);
    localparam UART_TICKS=8;
    reg clk=0,k2=0,rx=1,passed=0;
    always #10 clk=~clk;
    reg [11:0] voltage[0:15];
    reg [11:0] adc_data=3510,pipeline0=3510,pipeline1=3510;
    wire [3:0] select;
    wire adc_clk,cs,sck,mosi,miso,led,frame_valid;
    wire [383:0] frame;
    wire signed [31:0] frames;
    reg [383:0] expected=0;
    integer i,target,heard=0,ons=0,checked=0,saved;
    GW_PROBLEM_TOW #(.VIDEO_ENABLE(0),.POWER_ON_CYCLES(8),.AUDIO_START_CYCLES(32),
        .PITCH_GROUP_STABLE_CYCLES(3),.PRESSURE_CALIBRATION_LOG2(1),
        .PRESSURE_SLOT_CYCLES(100),.PRESSURE_ADC_HALF_CYCLES(2)) dut(
        .sys_clk(clk),.KEY0(1'b1),.KEY1(1'b1),.KEY2(k2),
        .ADC_DATA(adc_data),.pitch_group(7'b1000000),.S(select),.S_EN(),.CLK_500kHz(adc_clk),
        .uart_rx(rx),.uart_tx(),.bt_rx(1'b1),.bt_tx(),
        .HP_BCK(),.HP_WS(),.HP_DIN(),.PA_EN(),
        .sd_cs_n(cs),.sd_sck(sck),.sd_mosi(mosi),.sd_miso(miso),.LEDs(),
        .tmds_data_p(),.tmds_data_n(),.tmds_clk_p(),.tmds_clk_n(),
        .LED_indicator_static(),.LED_indicator_dynamic(led));
    defparam dut.score_player.UART_CLK_HZ=76800;
    defparam dut.score_player.UART_BAUD=9600;
    defparam dut.score_player.UART_TIMEOUT_CYCLES=4000;
    defparam dut.score_player.NOTE_GATE_CYCLES=10000;
    defparam dut.score_player.NOTE_TAIL_CYCLES=20000;
    defparam dut.score_player.SD_POWER_WAIT_CYCLES=4;
    defparam dut.score_player.SD_INIT_HALF_DIV=1;
    defparam dut.score_player.SD_READ_HALF_DIV=1;
    defparam dut.score_player.CLOCKS_PER_MS=2000;
    sd_card_model #(.IMAGE_FILE("output/key_guide/card.hex"),.IMAGE_BYTES(33554432)) card(
        .rst_n(dut.player_reset_n),.cs_n(cs),.sck(sck),.mosi(mosi),.miso(miso),
        .profile(2'd2),.fault(4'd0),.last_argument(),.read_commands(),.cmd16_seen());
    always @(posedge adc_clk)begin
        pipeline0<=voltage[select];pipeline1<=pipeline0;adc_data<=#120 pipeline1;
    end
    ws2812_monitor monitor(.clk(clk),.reset_n(dut.player_reset_n),.data_in(led),
        .frame(frame),.frame_valid(frame_valid),.frames(frames));
    `include "uart_test_tasks.vh"
    `include "key_guide_reference.vh"
    always @(posedge clk) begin
        if(dut.player_reset_n && dut.dynamic_leds.state==0 &&
           dut.dynamic_leds.wait_count==dut.dynamic_leds.wait_last)
            expected<=reference_frame(dut.guide_keys,dut.guide_active && !dut.upload_active,dut.guide_palette);
        if(dut.player_reset_n && frame_valid)begin
            if(frame!==expected)$fatal(1,"Serial guide frame differs from target snapshot");
            checked=checked+1;
        end
        if(dut.player_reset_n)begin
            if(dut.score_player.pcm!=0)heard=heard+1;
            if(dut.score_player.system.synth_event_valid && dut.score_player.system.synth_event_ready &&
               dut.score_player.system.synth_event_on && !dut.score_player.system.synth_event_update)ons=ons+1;
            if(dut.score_player.system.guide_session && dut.score_player.dds_event_valid)
                $fatal(1,"Guide sent score events to audio");
            if(dut.score_player.last_error)$fatal(1,"Unexpected guide/player error %h",dut.score_player.last_error);
        end
    end
    task scans(input integer n);repeat(n*1600)@(negedge clk);endtask
    task release_all;
        begin for(i=0;i<16;i=i+1)voltage[i]=3510;scans(20);end
    endtask
    task expect_dark;
        begin target=frames+2;wait(frames>=target);@(negedge clk);
            if(frame!==0)$fatal(1,"Guide did not clear");end
    endtask
    task expect_step(input integer t,input [87:0] notes);
        begin wait(dut.guide_active && dut.score_player.elapsed_ms==t);#1;
            if(dut.guide_keys!==notes)$fatal(1,"Wrong step target t=%0d keys=%h",t,dut.guide_keys);
            target=frames+2;wait(frames>=target);@(negedge clk);
            if(frame==0)$fatal(1,"No visible target frame");
            $display("CHECK follow target time=%0d keys=%h",t,notes);end
    endtask
    initial begin
        for(i=0;i<16;i=i+1)voltage[i]=3510;
        repeat(20)@(negedge clk);k2=1;wait(dut.player_reset_n);scans(4);expect_dark();
        // Optional cache setup avoids repeating the cold 200-slot scan.
        // Descriptors, FAT, CRC and score bytes still travel over real SPI.
        if(WARM_CATALOG)begin
            @(negedge clk);dut.score_player.catalog_valid=1;
            dut.score_player.catalog=(200'b1<<0)|(200'b1<<1)|(200'b1<<100);
        end
        send_frame(0,'h12,1,1,0);wait(dut.score_player.playing);expect_dark();
        wait(!dut.score_player.sd_active);if(!heard || !ons)$fatal(1,"Normal auto playback lost audio");
        $display("CHECK automatic playback audible, guide dark");
        send_frame(0,'h12,1,1,0);wait(dut.score_player.playing);
        send_frame(0,'h53,1,0,0);
        expect_step(0,(88'b1<<22)|(88'b1<<25));heard=0;saved=ons;scans(20);
        if(dut.score_player.pcm!=0 || heard || ons!=saved || dut.score_player.elapsed_ms!=0)
            $fatal(1,"Unplayed guide target was audible / advanced");
        voltage[0]=1900;scans(12);
        if(dut.score_player.elapsed_ms!=0)$fatal(1,"Wrong key advanced");release_all();
        voltage[6]=1900;scans(12);
        if(dut.score_player.elapsed_ms!=0 || !heard || !dut.score_player.video_keys[22])
            $fatal(1,"Partial chord advanced / physical key did not sound in target group");
        voltage[9]=1900;expect_step(40,88'b1<<22);scans(12);
        if(dut.score_player.elapsed_ms!=40)$fatal(1,"Held key skipped first repeated target");
        release_all();voltage[6]=1900;expect_step(80,88'b1<<22);scans(12);
        if(dut.score_player.elapsed_ms!=80)$fatal(1,"Held key skipped second repeated target");
        release_all();voltage[6]=1900;expect_step(120,88'b1<<54);
        release_all();voltage[6]=1900;expect_step(160,88'b1<<87);
        release_all();saved=ons;voltage[8]=1900;scans(12);
        if(ons!=saved || dut.score_player.elapsed_ms!=160)$fatal(1,"Top-group extra key aliased C8");
        release_all();voltage[7]=1900;expect_step(200,(88'b1<<0)|(88'b1<<15));
        release_all();voltage[0]=1900;scans(12);
        if(dut.score_player.elapsed_ms!=200)$fatal(1,"Final partial chord advanced");
        voltage[15]=1900;wait(!dut.score_player.sd_active);expect_dark();release_all();
        send_frame(0,'h12,1,1,0);expect_step(0,(88'b1<<22)|(88'b1<<25));
        send_frame(0,'h11,0,0,0);expect_dark();
        send_frame(0,'h12,1,1,0);expect_step(0,(88'b1<<22)|(88'b1<<25));
        saved=ons;send_frame(0,'h53,0,0,0);wait(ons>saved);expect_dark();
        send_frame(0,'h53,1,0,0);expect_step(0,(88'b1<<22)|(88'b1<<25));
        send_frame(0,'h12,2,1,0);wait(dut.score_player.selected_track==104);expect_dark();
        wait(!dut.score_player.sd_active);
        send_frame(0,'h12,1,1,0);expect_step(0,(88'b1<<22)|(88'b1<<25));
        @(negedge clk);k2=0;repeat(8)@(negedge clk);k2=1;
        wait(dut.player_reset_n);expect_dark();
        if(dut.score_player.guide_mode || dut.score_player.selected_track)$fatal(1,"Reset retained mode/track");
        if(checked<20)$fatal(1,"Not enough real LED frames");
        passed=1;$display("PASS follow guide top: actual UART/SD/ADC/audio/LED, default auto/dark, silent wait, manual sound, high-group-only chords, repeats, C8 non-aliasing, mode restart, EOF/STOP/MB/reset; %0d serial frames",checked);$finish;
    end
    initial begin #1500000000;$fatal(1,"Follow guide top timeout time=%d",dut.score_player.elapsed_ms);end
endmodule
