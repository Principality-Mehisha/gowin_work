`timescale 1ns/1ps
module GSR(input GSRI); endmodule
module uart_player_case #(
    parameter IMAGE="output/fixed_slots/player.hex",
    parameter integer ERROR=0, EMPTY=0, AUTOPLAY=0
)(output reg passed=0);
    localparam UART_TICKS=8;
    reg clk=0,rx=1,k2=1;
    always #10 if(!passed)clk=~clk;
    wire cs,sck,mosi,miso;
    integer ons=0,offs=0,heard=0,starts=0,saved=0,i;
    piano_score_player #(.SD_SCORE_ENABLE(AUTOPLAY),.POWER_ON_CYCLES(8),.AUDIO_START_CYCLES(32),
        .UART_CLK_HZ(76800),.UART_BAUD(9600),.UART_TIMEOUT_CYCLES(4000),
        .SD_POWER_WAIT_CYCLES(4),.SD_INIT_HALF_DIV(1),.SD_READ_HALF_DIV(1),.CLOCKS_PER_MS(128)) dut(
        .sys_clk(clk),.KEY2(k2),.uart_rx(rx),.uart_tx(),
        .upload_complete(1'b0),.upload_invalidated(1'b0),.uploaded_track(8'd0),
        .HP_BCK(),.HP_WS(),.HP_DIN(),.PA_EN(),.sd_cs_n(cs),.sd_sck(sck),
        .sd_mosi(mosi),.sd_miso(miso),.LEDs());
    sd_card_model #(.IMAGE_FILE(IMAGE),.IMAGE_BYTES(33554432)) card(
        .rst_n(dut.rst_n),.cs_n(cs),.sck(sck),.mosi(mosi),.miso(miso),
        .profile(2'd2),.fault(4'd0),.last_argument(),.read_commands(),.cmd16_seen());
    `include "uart_test_tasks.vh"
    always @(posedge clk)if(dut.rst_n)begin
        if(dut.system.deadline_error)$fatal(1,"Numbered player compute deadline");
        if(dut.pcm!==dut.pcm_right)$fatal(1,"Stereo mismatch");
        if(dut.video_active || dut.video_keys!=0)$fatal(1,"Old fixed-score display became active");
        if(dut.pcm!=0)heard=heard+1;
        if(dut.system.uart_start)starts=starts+1;
        if(dut.system.synth_event_valid && dut.system.synth_event_ready)begin
            if(dut.system.manual_mode)$fatal(1,"Unexpected audition event");
            if(dut.system.synth_event_on)ons=ons+1;else offs=offs+1;
            if(dut.system.marimba_mode!=(dut.selected_track>=104))$fatal(1,"Wrong numbered instrument");
            if(dut.system.voices.marimba.event_valid && dut.system.voices.piano.event_valid)
                $fatal(1,"Both instruments received the same event");
        end
    end
    task select_score(input integer kind,input integer number);
        begin send_frame(0,'h12,kind,number,0);end
    endtask
    task complete_score(input integer kind,input integer number);
        integer before_events,before_starts;
        begin
            before_events=ons;heard=0;select_score(kind,number);
            wait(dut.playing);wait(ons>before_events);
            before_starts=starts;
            select_score(kind,number);repeat(20)@(negedge clk);
            if(starts!=before_starts)$fatal(1,"Duplicate numbered selection restarted playback");
            wait(!dut.system.ringtone_active);repeat(10)@(negedge clk);
            if(!heard || dut.last_error || dut.pcm!=0)$fatal(1,"Numbered EOF/audio/error handling");
        end
    endtask
    initial begin
        wait(dut.rst_n);repeat(20)@(negedge clk);
        if(AUTOPLAY)begin
            if(dut.selected_track!=4)$fatal(1,"Startup did not select PN001");
            wait(ons>0);wait(!dut.system.ringtone_active);
            if(dut.last_error || !heard)$fatal(1,"PN001 startup playback failed");
            passed=1;$display("PASS optional startup plays PN001 once and returns idle");
        end else begin
            // Every old selection is rejected before any SD transaction.
            for(i=1;i<=3;i=i+1)send_frame(i,'h10,i,0,0);
            repeat(200)@(negedge clk);
            if(starts || dut.selected_track || card.read_commands || cs!==1)
                $fatal(1,"Removed 0x10 command touched playback or SD");
            if(ERROR)begin
                select_score(1,1);wait(dut.system.ringtone_error);repeat(10)@(negedge clk);
                if(dut.last_error!=ERROR || ons || dut.pcm!=0)$fatal(1,"Numbered failure not retained");
                send_frame(0,'h11,0,0,0);repeat(20)@(negedge clk);
                if(dut.last_error || dut.player_state)$fatal(1,"Stop did not clear numbered failure");
                complete_score(1,2);
            end else if(EMPTY)begin
                select_score(1,1);wait(dut.catalog_valid);wait(!dut.system.ringtone_active);
                if(ons || dut.last_error || dut.selected_track)$fatal(1,"Empty preset did not return quietly");
                complete_score(1,2);
            end else begin
                complete_score(1,1);complete_score(1,2);complete_score(2,1);complete_score(2,100);
                select_score(1,1);wait(dut.playing);
                saved=starts;
                for(i=1;i<=3;i=i+1)send_frame(0,'h10,i,0,0);
                if(starts!=saved || dut.selected_track!=4)$fatal(1,"Old command interrupted PN001");
                select_score(2,1);wait(dut.selected_track==104);wait(dut.playing);
                select_score(1,2);wait(dut.selected_track==5);wait(dut.playing);
                if(dut.system.marimba_mode || dut.score_stream.decoder.marimba_format)
                    $fatal(1,"Numbered format/instrument switching failed");
                send_frame(0,'h11,0,0,0);repeat(30)@(negedge clk);
                if(dut.pcm!=0 || cs!==1 || dut.system.ringtone_active)$fatal(1,"Stop not silent");
                select_score(1,1);send_frame(0,'h11,0,0,0);
                if(dut.system.ringtone_active)$fatal(1,"Stop during loading failed");
                select_score(2,100);@(negedge clk);k2=0;repeat(8)@(negedge clk);k2=1;
                wait(dut.rst_n);repeat(10)@(negedge clk);
                if(dut.selected_track || dut.system.ringtone_active || dut.last_error || dut.pcm!=0)
                    $fatal(1,"KEY2 failed to return idle");
            end
            passed=1;$display("PASS numbered player: PN/MB synthesis, EOF, switching, stop/reset, old commands rejected; error=%h",ERROR);
        end
    end
    initial begin #1000000000;$fatal(1,"Numbered UART player watchdog");end
endmodule
module tb_uart_player;
    wire a,b,c,d;
    reg passed=0;
    uart_player_case normal(a);
    uart_player_case #(.IMAGE("output/fixed_slots/bad_crc.hex"),.ERROR('h26)) crc_case(b);
    uart_player_case #(.IMAGE("output/fixed_slots/bad_format.hex"),.ERROR('h31)) format_case(c);
    uart_player_case #(.IMAGE("output/fixed_slots/empty.hex"),.EMPTY(1)) empty_case(d);
    initial begin wait(a&&b&&c&&d);passed=1;$display("PASS all numbered UART player cases");$finish;end
endmodule
