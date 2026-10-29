`timescale 1ns/1ps
`include "../output/ringtone_test/params.vh"
module GSR(input GSRI); endmodule
module sd_ringtone_case #(
 parameter IMAGE="output/ringtone_test/fat16.hex", parameter PROFILE=0,
 parameter EXPECT_ERROR=0, parameter CONTROLS=0
)(output reg passed=0);
 localparam UART_TICKS=8;
 reg clk=0,rx=1,k2=1;
 always #10 if(!passed) clk=~clk;
 wire cs,sck,mosi,miso,bck,ws,din;
 reg [3:0] fault=0;
 reg [63:0] expected_events[0:`RINGTONE_EVENTS-1];
 integer dispatched=0,ons=0,heard=0,saved,manuals=0;
 reg [3:0] cause=0;
 piano_score_player #(.POWER_ON_CYCLES(8),.AUDIO_START_CYCLES(32),.UART_CLK_HZ(76800),.UART_BAUD(9600),
  .SD_POWER_WAIT_CYCLES(16),.SD_INIT_HALF_DIV(3),.SD_READ_HALF_DIV(3),.CLOCKS_PER_MS(1000)) dut (
  .sys_clk(clk),.KEY2(k2),.HP_BCK(bck),.HP_WS(ws),.HP_DIN(din),.PA_EN(),
  .uart_rx(rx),.uart_tx(),
  .sd_cs_n(cs),.sd_sck(sck),.sd_mosi(mosi),.sd_miso(miso),.LEDs());
 sd_card_model #(.IMAGE_FILE(IMAGE),.IMAGE_BYTES(600000)) card (
  .rst_n(dut.storage_rst_n),.cs_n(cs),.sck(sck),.mosi(mosi),.miso(miso),
  .profile(PROFILE[1:0]),.fault(fault),.last_argument(),.read_commands(),.cmd16_seen());
 always @(posedge clk) if(dut.rst_n) begin
  if(dut.system.deadline_error) $fatal(1,"Compute deadline");
  if(dut.pcm!=0) heard=heard+1;
  if(dut.pcm!==dut.pcm_right) $fatal(1,"Synth stereo duplication mismatch");
  if(dut.system.failed) cause <= dut.sd_error_code!=0 ? dut.sd_error_code :
                              (dut.fat_error!=0 ? dut.fat_error : dut.score_error);
  if(dut.system.synth_event_valid && dut.system.synth_event_ready) begin
   if(dut.system.manual_mode) manuals=manuals+1;
   else if(!EXPECT_ERROR) begin
    if(dispatched>=`RINGTONE_EVENTS-1 || dut.system.synth_event_note!==expected_events[dispatched][46:40] ||
       dut.system.synth_event_on !== (expected_events[dispatched][55:48]!=0) ||
       dut.system.synth_event_dynamics !== {expected_events[dispatched][54:48],1'b0} ||
       dut.elapsed_ms < expected_events[dispatched][31:0])
      $fatal(1,"SD event mismatch event=%0d note=%0d",dispatched,dut.system.synth_event_note);
    if(dut.system.synth_event_on) ons=ons+1;
    dispatched=dispatched+1;
   end
  end
 end
 `include "uart_test_tasks.vh"
 task toggle; begin
  if(dut.system.ringtone_active) send_frame(0,'h11,0,0,0);
  else send_frame(0,'h10,1,0,0);
 end endtask
 task reset; begin @(negedge clk);k2=0;repeat(4)@(negedge clk);k2=1;wait(dut.rst_n);end endtask
 initial begin
  $readmemh("output/ringtone_test/events.hex",expected_events);
  wait(dut.rst_n);repeat(20)@(negedge clk);
  if(!dut.system.manual_mode || dut.initialized || cs!==1'b1) $fatal(1,"Unexpected startup SD read");
  if(EXPECT_ERROR==10) fault=1;
  if(CONTROLS) begin
   toggle();wait(dut.system.ringtone_active);toggle();wait(dut.system.manual_mode);
   if(cs!==1'b1 || dut.pcm!==0) $fatal(1,"Loading stop did not silence/reset SD");
  end
  toggle();
  if(EXPECT_ERROR) begin
   wait(dut.system.ringtone_error);repeat(20)@(negedge clk);
   if(cause!=EXPECT_ERROR || !dut.system.manual_mode || dut.pcm!==0)
    $fatal(1,"Failure handling error=%0d actual=%0d",EXPECT_ERROR,cause);
   toggle();wait(dut.system.ringtone_active);reset();
   if(dut.system.ringtone_active || dut.system.ringtone_error) $fatal(1,"Reset did not clear failure/retry");
   $display("PASS SD ringtone error=%0d",EXPECT_ERROR);
  end else begin
   wait(dut.playing);
   if(manuals!=0) $fatal(1,"Unexpected manual event during SD score");
   wait(!dut.system.ringtone_active);repeat(4)@(posedge dut.sample_tick);
   if(dispatched!=`RINGTONE_EVENTS-1 || ons!=`RINGTONE_NOTE_ONS || heard==0 || dut.system.ringtone_error || dut.pcm!==0)
    $fatal(1,"EOF count/silence failure dispatched=%0d ons=%0d",dispatched,ons);
   if(CONTROLS) begin
    dispatched=0;ons=0;toggle();wait(ons>=1);toggle();wait(dut.system.manual_mode);
    repeat(3)@(posedge dut.sample_tick);
    if(dut.pcm!==0) $fatal(1,"Mid-score stop not silent");
    toggle();wait(dut.system.ringtone_active);reset();
    if(!dut.system.manual_mode) $fatal(1,"Loading reset did not return manual mode");
    repeat(64)@(negedge clk);
    if(manuals!=0) $fatal(1,"Unexpected idle note");
   end
   $display("PASS SD ringtone FAT profile=%0d: Android events, EOF, controls",PROFILE);
  end
  passed=1;
 end
endmodule
module tb_sd_ringtone;
 wire a,b,c,d,e,f;
 reg passed=0;
 sd_ringtone_case #(.CONTROLS(1)) c16(a);
 sd_ringtone_case #(.IMAGE("output/ringtone_test/fat32.hex"),.PROFILE(2)) c32(b);
 sd_ringtone_case #(.IMAGE("output/ringtone_test/missing.hex"),.EXPECT_ERROR(4)) missing(c);
 sd_ringtone_case #(.IMAGE("output/ringtone_test/wrong_format.hex"),.EXPECT_ERROR(1)) format_case(d);
 sd_ringtone_case #(.IMAGE("output/ringtone_test/bad_note.hex"),.EXPECT_ERROR(2)) note_case(e);
 sd_ringtone_case #(.EXPECT_ERROR(10)) crc_case(f);
 initial begin wait(a&&b&&c&&d&&e&&f);passed=1;$display("PASS SD ringtone suite");$finish;end
 initial begin #1000000000;$fatal(1,"SD ringtone timeout");end
endmodule
