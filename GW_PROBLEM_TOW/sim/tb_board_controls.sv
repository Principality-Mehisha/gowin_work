`timescale 1ns/1ps
module GSR(input GSRI); wire GSRO=GSRI; endmodule
module tb_board_controls;
 localparam UART_TICKS=8;
 reg clk=0,rx=1,k0=1,k1=1,k2=1,passed=0;
 always #10 clk=~clk;
 wire cs;
 integer ons=0,offs=0,heard=0,saved,i;
 GW_PROBLEM_TOW #(.VIDEO_ENABLE(0)) dut (
  .sys_clk(clk),.KEY0(k0),.KEY1(k1),.KEY2(k2),.uart_rx(rx),.uart_tx(),
  .sd_cs_n(cs),.sd_sck(),.sd_mosi(),.sd_miso(1'b1),
  .HP_BCK(),.HP_WS(),.HP_DIN(),.PA_EN(),.LEDs());
 defparam dut.score_player.POWER_ON_CYCLES=8;
 defparam dut.score_player.UART_CLK_HZ=76800;
 defparam dut.score_player.UART_BAUD=9600;
 defparam dut.score_player.NOTE_GATE_CYCLES=30000;
 defparam dut.score_player.NOTE_TAIL_CYCLES=250000;
 `include "uart_test_tasks.vh"
 always @(posedge clk) if(dut.score_player.rst_n) begin
  if(dut.score_player.system.deadline_error) $fatal(1,"Compute deadline");
  if(dut.score_player.pcm!=0) heard=heard+1;
  if(dut.score_player.system.synth_event_valid && dut.score_player.system.synth_event_ready) begin
   if(dut.score_player.system.synth_event_on) ons=ons+1; else offs=offs+1;
  end
 end
 task toggle_pins;
  begin
   for(i=0;i<100;i=i+1) begin
    @(negedge clk); k0=~k0;
    repeat(17)@(negedge clk); k1=~k1;
    repeat(19)@(negedge clk);
   end
   k0=1;k1=1;
  end
 endtask
 initial begin
  wait(dut.score_player.rst_n);
  toggle_pins();
  if(ons || offs || heard || !dut.score_player.system.manual_mode || cs!==1)
   $fatal(1,"Board pins triggered idle audio or SD access");
  send_frame(0,'h12,1,1,0);
  saved=ons; toggle_pins();
  if(!dut.score_player.system.ringtone_active || dut.score_player.selected_track!=4 || ons!=saved)
   $fatal(1,"Board pins changed SD loading state");
  send_frame(0,'h11,0,0,0);
  send_frame(0,'h44,0,0,0);
  send_frame(0,'h42,0,0,0);wait(ons==1);
  toggle_pins();
  if(!dut.score_player.system.note_busy || !dut.score_player.system.marimba_mode || ons!=1)
   $fatal(1,"Board pins interrupted UART audition");
  wait(!dut.score_player.system.note_busy);
  if(ons!=1 || offs!=1 || !heard) $fatal(1,"UART audition/audio failed");
  toggle_pins();
  if(ons!=1 || dut.score_player.pcm!=0) $fatal(1,"Idle pins retriggered audio");
  send_frame(0,'h43,0,0,0);
  send_frame(0,'h42,0,0,0);wait(ons==2);
  @(negedge clk);k2=0;
  #1;
  if(dut.score_player.rst_n!==0 || dut.score_player.system.note_busy!==0 || dut.score_player.pcm!==0)
   $fatal(1,"KEY2 did not asynchronously reset active audition");
  repeat(4)@(negedge clk);k2=1;wait(dut.score_player.rst_n);
  repeat(4)@(posedge dut.score_player.sample_tick);
  if(dut.score_player.selected_note ||
     dut.score_player.selected_marimba || dut.score_player.system.ringtone_active || cs!==1 || dut.score_player.pcm!=0)
   $fatal(1,"KEY2 did not restore idle piano selection");
  passed=1;
  $display("PASS board controls: KEY0/KEY1 inert in idle/SD/UART, UART audio, KEY2 reset");
  $finish;
 end
 initial begin #100000000;$fatal(1,"Board controls timeout");end
endmodule
