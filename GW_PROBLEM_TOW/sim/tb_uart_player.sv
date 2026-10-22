`timescale 1ns/1ps
module GSR(input GSRI); endmodule
module uart_player_case #(
 parameter IMAGE="output/uart_test/three_scores.hex",parameter ERROR=0
)(output reg passed=0);
 localparam UART_TICKS=8;
 reg clk=0,rx=1,k0=1,k1=1,k2=1;
 always #10 if(!passed) clk=~clk;
 wire cs,sck,mosi,miso;
 integer ons=0,manuals=0,heard=0,starts=0,saved,i;
 integer note_index=0;
 reg [15:0] expected_notes[0:5];
 reg [7:0] last_track=0;
 piano_score_player #(.POWER_ON_CYCLES(8),.DEBOUNCE_CYCLES(8),.AUDIO_START_CYCLES(32),
  .UART_CLK_HZ(76800),.UART_TIMEOUT_CYCLES(4000),.SD_POWER_WAIT_CYCLES(16),
  .SD_INIT_HALF_DIV(3),.SD_READ_HALF_DIV(3),.CLOCKS_PER_MS(128)) dut (
  .sys_clk(clk),.KEY0(k0),.KEY1(k1),.KEY2(k2),.uart_rx(rx),.uart_tx(),
  .HP_BCK(),.HP_WS(),.HP_DIN(),.PA_EN(),.sd_cs_n(cs),.sd_sck(sck),
  .sd_mosi(mosi),.sd_miso(miso),.LEDs());
 sd_card_model #(.IMAGE_FILE(IMAGE),.IMAGE_BYTES(600000)) card (
  .rst_n(dut.storage_rst_n),.cs_n(cs),.sck(sck),.mosi(mosi),.miso(miso),
  .profile(2'd0),.fault(4'd0),.last_argument(),.read_commands(),.cmd16_seen());
 `include "uart_test_tasks.vh"
 always @(posedge clk) if(dut.rst_n) begin
  if(dut.deadline_error) $fatal(1,"UART integration compute deadline");
  if(dut.pcm!==dut.pcm_right) $fatal(1,"Stereo mismatch");
  if(dut.pcm!=0) heard=heard+1;
  if(dut.uart_start) starts=starts+1;
  if(dut.control_restart) note_index=0;
  if(dut.synth_event_valid && dut.synth_event_ready && dut.synth_event_on) begin
   if(dut.manual_mode) manuals=manuals+1;
   else begin
    if(note_index>1 || {dut.synth_event_dynamics,1'b0,dut.synth_event_note} !==
                          expected_notes[(dut.selected_track-1)*2+note_index])
     $fatal(1,"Wrong source note/velocity track=%0d note=%0d dynamics=%0d",dut.selected_track,dut.synth_event_note,dut.synth_event_dynamics);
    note_index=note_index+1;
    ons=ons+1;
    if(dut.selected_track==3 && dut.marimba_mode) $fatal(1,"Piano routed to marimba");
    if(dut.selected_track!=3 && !dut.marimba_mode) $fatal(1,"Marimba routed to piano");
    if(dut.marimba.event_valid && dut.piano_path.synth.event_valid) $fatal(1,"Two synth sources active");
   end
  end
 end
 task key0;
  begin @(negedge clk);k0=0;repeat(32)@(negedge clk);k0=1;repeat(32)@(negedge clk);end
 endtask
 initial begin
  $readmemh("output/uart_test/expected.hex",expected_notes);
  wait(dut.rst_n);repeat(20)@(negedge clk);
  if(!dut.manual_mode || dut.initialized) $fatal(1,"Unexpected startup access");
  send_frame(1,'h10,2,0,0);
  if(ERROR) begin
   wait(dut.ringtone_error);repeat(10)@(negedge clk);
   if(dut.last_error!=ERROR || dut.player_state!=3 || dut.selected_track!=2 || dut.pcm!=0)
    $fatal(1,"Error not retained code=%h expected=%h",dut.last_error,ERROR);
   send_frame(2,'h11,0,0,0);repeat(10)@(negedge clk);
   if(dut.player_state!=0 || dut.last_error!=0) $fatal(1,"Stop did not clear failure");
   send_frame(3,'h10,1,0,0);wait(dut.playing);wait(ons>=1);
   send_frame(4,'h11,0,0,0);
  end else begin
   // Complete all three files with actual source note/velocity values.
   wait(dut.playing);wait(!dut.ringtone_active);
   if(ons!=2 || heard==0 || dut.last_error) $fatal(1,"Apple events/audio/EOF failed");
   for(i=1;i<=3;i=i+2) begin
    saved=ons;heard=0;
    send_frame(10+i,'h10,i,0,0);wait(dut.playing);wait(ons>=saved+1);
    saved=starts;
    send_frame(20+i,'h10,i,0,0);repeat(20)@(negedge clk);
    if(starts!=saved) $fatal(1,"Duplicate play restarted score");
    @(negedge clk);k1=0;repeat(32)@(negedge clk);k1=1;
    wait(!dut.ringtone_active);
    if(heard==0 || dut.last_error || manuals) $fatal(1,"Track/KEY1 isolation/audio failed track=%0d",i);
   end
   send_frame(30,'h10,1,0,0);wait(dut.playing);
   // Switch while playing; filename/format/synth must change as one operation.
   send_frame(31,'h10,3,0,0);wait(dut.selected_track==3);wait(dut.playing);
   if(dut.marimba_mode || dut.decoder.marimba_format) $fatal(1,"Switch format wrong");
   send_frame(32,'h11,0,0,0);repeat(20)@(negedge clk);
   if(!dut.manual_mode || dut.pcm!=0 || cs!==1) $fatal(1,"Stop not silent/reset");
   // Stop during loading and restart, physical keys, and board reset.
   send_frame(33,'h10,2,0,0);send_frame(34,'h11,0,0,0);
   if(dut.ringtone_active) $fatal(1,"Loading stop failed");
   key0();if(dut.selected_track!=1 || !dut.ringtone_active) $fatal(1,"KEY0 no longer Android");
   key0();if(!dut.manual_mode) $fatal(1,"KEY0 stop failed");
   @(negedge clk);k1=0;wait(manuals==1);k1=1;
   send_frame(35,'h10,2,0,0);@(negedge clk);k2=0;repeat(4)@(negedge clk);k2=1;
   wait(dut.rst_n);
   if(!dut.manual_mode || dut.selected_track || dut.last_error) $fatal(1,"Board reset failed");
  end
  passed=1;$display("PASS UART player: three-score routing, real synthesis, controls, errors=%h",ERROR);
 end
endmodule
module tb_uart_player;
 wire a,b,c;
 reg passed=0;
 uart_player_case normal(a);
 uart_player_case #(.IMAGE("output/uart_test/missing_apple.hex"),.ERROR('h24)) missing(b);
 uart_player_case #(.IMAGE("output/uart_test/bad_apple.hex"),.ERROR('h31)) wrong_format(c);
 initial begin wait(a&&b&&c);passed=1;$display("PASS UART player suite");$finish;end
 initial begin #200000000;$fatal(1,"UART player timeout");end
endmodule
