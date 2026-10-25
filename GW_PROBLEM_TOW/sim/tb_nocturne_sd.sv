`timescale 1ns/1ps
module GSR(input GSRI);endmodule
module nocturne_sd_case #(
 parameter IMAGE="output/nocturne/fat16.hex",parameter PROFILE=0,parameter ERROR=0
)(output reg passed=0);
 localparam UART_TICKS=8;
 reg clk=0,rx=1,k2=1;
 always #10 if(!passed)clk=~clk;
 wire cs,sck,mosi,miso;
 integer ons=0,offs=0,heard=0,starts=0,saved;
 piano_score_player #(.POWER_ON_CYCLES(8),.DEBOUNCE_CYCLES(8),.AUDIO_START_CYCLES(32),
  .UART_CLK_HZ(76800),.UART_BAUD(9600),.UART_TIMEOUT_CYCLES(4000),
  .SD_POWER_WAIT_CYCLES(16),.SD_INIT_HALF_DIV(3),.SD_READ_HALF_DIV(3),.CLOCKS_PER_MS(128)) dut (
  .sys_clk(clk),.KEY0(1'b1),.KEY1(1'b1),.KEY2(k2),.uart_rx(rx),.uart_tx(),
  .HP_BCK(),.HP_WS(),.HP_DIN(),.PA_EN(),.sd_cs_n(cs),.sd_sck(sck),.sd_mosi(mosi),.sd_miso(miso),.LEDs());
 sd_card_model #(.IMAGE_FILE(IMAGE),.IMAGE_BYTES(600000)) card (
  .rst_n(dut.storage_rst_n),.cs_n(cs),.sck(sck),.mosi(mosi),.miso(miso),
  .profile(PROFILE[1:0]),.fault(4'd0),.last_argument(),.read_commands(),.cmd16_seen());
 `include "uart_test_tasks.vh"
 always @(posedge clk)if(dut.rst_n)begin
  if(dut.uart_start)starts=starts+1;
  if(dut.deadline_error)$fatal(1,"Nocturne SD deadline");
  if(dut.ringtone_active && dut.selected_track==4 && (!dut.clarinet_mode || dut.marimba_mode))
   $fatal(1,"SD clarinet mode incorrect");
  if(dut.pcm!=0)heard=heard+1;
  if(dut.synth_event_valid && dut.synth_event_ready && dut.ringtone_active)begin
   if(dut.selected_track!=4 || !dut.clarinet.event_valid || dut.marimba.event_valid || dut.piano_path.synth.event_valid)
    $fatal(1,"Nocturne event routed to wrong synth");
   if(dut.synth_event_on)begin
    if(dut.synth_event_note!=(ons==0 ? 58 : 67) || dut.synth_event_dynamics!=180)
     $fatal(1,"Nocturne MIDI or velocity mismatch");
    ons=ons+1;
   end else offs=offs+1;
  end
 end
 initial begin
  wait(dut.rst_n);send_frame(1,'h10,4,0,0);
  if(ERROR)begin
   wait(dut.ringtone_error);repeat(4)@(negedge clk);
   if(dut.last_error!=ERROR || dut.pcm!=0 || dut.player_state!=3)
    $fatal(1,"C45S rejection code got=%h expected=%h",dut.last_error,ERROR);
   send_frame(2,'h11,0,0,0);repeat(4)@(negedge clk);
   if(dut.last_error || !dut.manual_mode)$fatal(1,"C45S stop did not clear error");
  end else begin
   wait(dut.playing);saved=starts;send_frame(2,'h10,4,0,0);
   if(starts!=saved)$fatal(1,"Duplicate nocturne play restarted SD");
   wait(!dut.ringtone_active);repeat(3)@(posedge dut.sample_tick);
   if(ons!=2 || offs!=2 || !heard || dut.last_error || dut.pcm!=0 || dut.clarinet_mode)
    $fatal(1,"Nocturne EOF/audio/dispatch failed");
   send_frame(3,'h10,4,0,0);send_frame(4,'h11,0,0,0);repeat(4)@(negedge clk);
   if(dut.ringtone_active || cs!==1 || dut.pcm!=0)$fatal(1,"Nocturne loading stop failed");
   send_frame(5,'h10,4,0,0);send_frame(6,'h45,0,0,0);repeat(4)@(negedge clk);
   if(dut.ringtone_active || !dut.selected_clarinet || dut.note_busy || dut.pcm!=0)
    $fatal(1,"Instrument selection failed to preempt SD");
   send_frame(7,'h10,4,0,0);@(negedge clk);k2=0;repeat(4)@(negedge clk);k2=1;wait(dut.rst_n);
   if(dut.ringtone_active || dut.selected_track || dut.pcm!=0)$fatal(1,"Nocturne reset failed");
  end
  passed=1;$display("PASS nocturne SD: FAT profile=%0d expected_error=%h",PROFILE,ERROR);
 end
endmodule
module tb_nocturne_sd;
 wire a,b,c,d,e,f,g;
 reg passed=0;
 nocturne_sd_case c16(a);
 nocturne_sd_case #(.IMAGE("output/nocturne/fat32.hex"),.PROFILE(2)) c32(b);
 nocturne_sd_case #(.IMAGE("output/nocturne/missing.hex"),.ERROR('h24)) missing(c);
 nocturne_sd_case #(.IMAGE("output/nocturne/wrong_magic.hex"),.ERROR('h31)) magic_case(d);
 nocturne_sd_case #(.IMAGE("output/nocturne/low_note.hex"),.ERROR('h32)) low_case(e);
 nocturne_sd_case #(.IMAGE("output/nocturne/high_note.hex"),.ERROR('h32)) high_case(f);
 nocturne_sd_case #(.IMAGE("output/nocturne/wrong_slot.hex"),.ERROR('h32)) slot_case(g);
 initial begin wait(a&&b&&c&&d&&e&&f&&g);passed=1;$display("PASS nocturne SD suite: C45S FAT16/FAT32, real synthesis, commands and malformed files");$finish;end
 initial begin #100000000;$fatal(1,"Nocturne SD timeout");end
endmodule
