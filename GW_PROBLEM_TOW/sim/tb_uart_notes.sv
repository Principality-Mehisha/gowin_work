`timescale 1ns/1ps
module tb_uart_notes;
 localparam UART_TICKS=8;
 reg clk=0,rx=1,k0=1,k1=1,k2=1,passed=0;
 always #10 clk=~clk;
 integer ons=0,offs=0,heard=0;
 wire tx;
 integer displayed_note=-1,display_count=0;
 integer displayed_instrument=-1,instrument_displays=0,prior_ons;
 reg [6:0] expected_note=0;
 piano_score_player #(.POWER_ON_CYCLES(8),.DEBOUNCE_CYCLES(8),.AUDIO_START_CYCLES(32),
  .UART_CLK_HZ(76800),.UART_BAUD(9600),.UART_TIMEOUT_CYCLES(4000),.NOTE_GATE_CYCLES(30000),.NOTE_TAIL_CYCLES(40000)) dut (
  .sys_clk(clk),.KEY0(k0),.KEY1(k1),.KEY2(k2),.uart_rx(rx),.uart_tx(tx),
  .HP_BCK(),.HP_WS(),.HP_DIN(),.PA_EN(),.sd_cs_n(),.sd_sck(),.sd_mosi(),.sd_miso(1'b1),.LEDs());
 `include "uart_test_tasks.vh"
 // Simulate the screen receiving real UART bytes, independently of DUT TX.
 reg [7:0] screen_byte;
 reg [287:0] screen_command=0;
 integer screen_bit,screen_ff=0,screen_pos=0;
 reg is_note=0;
 initial forever begin
  @(negedge tx);repeat(UART_TICKS/2)@(posedge clk);
  for(screen_bit=0;screen_bit<8;screen_bit=screen_bit+1) begin
   repeat(UART_TICKS)@(posedge clk);screen_byte[screen_bit]=tx;
  end
  repeat(UART_TICKS)@(posedge clk);
  if(tx!==1) $fatal(1,"Screen received invalid stop bit");
  if(screen_byte==8'hff) begin
   screen_ff=screen_ff+1;
   if(screen_ff==3) begin
    if(is_note) begin
     // Both text commands start with 'e'; identify the full command below.
     case(screen_command)
      "every.tNote.txt=\"A0\"": displayed_note=0;
      "every.tNote.txt=\"A#0\"": displayed_note=1;
      "every.tNote.txt=\"B0\"": displayed_note=2;
      "every.tNote.txt=\"C8\"": displayed_note=87;
      "every.tNote.txt=\"C2\"": displayed_note=15;
      "every.tNote.txt=\"C#2\"": displayed_note=16;
      "every.tNote.txt=\"B5\"": displayed_note=62;
      {"every.tInstrument.txt=\"",32'hb8d6c7d9,"\""}: begin
       displayed_instrument=0;instrument_displays=instrument_displays+1;
      end
      {"every.tInstrument.txt=\"",64'hc2edc1d6b0cdc7d9,"\""}: begin
       displayed_instrument=1;instrument_displays=instrument_displays+1;
      end
      default: $fatal(1,"Wrong text sent to screen: %s",screen_command);
     endcase
     display_count=display_count+1;
    end
    screen_ff=0;screen_pos=0;screen_command=0;is_note=0;
   end
  end else begin
   if(screen_ff) $fatal(1,"Broken screen terminator");
   if(screen_pos==0) is_note=screen_byte=="e";
   screen_command={screen_command[279:0],screen_byte};screen_pos=screen_pos+1;
  end
 end
 always @(posedge clk) if(dut.rst_n) begin
  if(dut.deadline_error) $fatal(1,"Virtual note compute deadline");
  if(dut.pcm!=0) heard=heard+1;
  if(dut.note_busy && (!dut.manual_mode || dut.marimba_mode!==dut.selected_marimba || dut.storage_enable))
   $fatal(1,"Single note routed to wrong instrument/SD");
  if(dut.note_busy && dut.synth_event_valid && dut.synth_event_ready) begin
   if(dut.synth_event_note!==expected_note || dut.synth_event_dynamics!=192)
    $fatal(1,"Wrong selected note/velocity");
   if(dut.synth_event_on) ons=ons+1;else offs=offs+1;
  end
 end
 task settle;
  begin wait(dut.uart_control.link.count==0 && dut.uart_control.link.formatter.ready);repeat(100)@(negedge clk);end
 endtask
 task play_and_finish;
  input [6:0] pitch;
  integer initial_ons,initial_offs;
  begin
   expected_note=pitch;initial_ons=ons;initial_offs=offs;heard=0;
   send_frame(0,'h42,0,0,0);wait(dut.note_busy);wait(!dut.note_busy);
   settle();repeat(3)@(posedge dut.sample_tick);
   if(ons!=initial_ons+1 || offs!=initial_offs+1 || !heard || dut.pcm!=0)
    $fatal(1,"One press must emit exactly one on/off with audio and finish silent pitch=%0d",pitch);
  end
 endtask
 initial begin
  wait(dut.rst_n);wait(display_count>0);settle();
  if(displayed_note!=0) $fatal(1,"Startup screen note must be A0");
  send_frame(0,'h40,0,0,0);settle();
  if(dut.selected_note!=87 || ons || heard) $fatal(1,"Previous should silently select C8");
  if(displayed_note!=87) $fatal(1,"Previous did not update screen to C8");
  play_and_finish(87);
  send_frame(0,'h41,0,0,0);settle();
  if(dut.selected_note!=0) $fatal(1,"Next C8 must wrap to A0");
  if(displayed_note!=0) $fatal(1,"Next did not update screen to A0");
  play_and_finish(0);
  send_frame(0,'h41,0,0,0);settle();
  expected_note=1;send_frame(0,'h42,0,0,0);wait(ons==3);
  send_frame(0,'h41,0,0,0);settle();
  if(dut.selected_note!=2 || dut.note_event_note!=1) $fatal(1,"Choosing next changed active pitch");
  if(displayed_note!=2) $fatal(1,"Screen must show selected B0, not the sounding A#0");
  expected_note=2;send_frame(0,'h42,0,0,0);wait(ons==4);
  send_frame(0,'h11,0,0,0);settle();
  if(dut.note_busy || dut.selected_note!=2 || dut.pcm!=0) $fatal(1,"Stop must silence and preserve selection");
  displayed_note=-1;send_frame(0,'h01,0,0,0);settle();
  if(displayed_note!=2) $fatal(1,"Query did not refresh unchanged screen note");
  // Single note playback takes over a loading SD song, then KEY0 returns to SD.
  send_frame(0,'h10,1,0,0);wait(dut.ringtone_active);
  send_frame(0,'h42,0,0,0);wait(ons==5);
  if(dut.ringtone_active || dut.last_error) $fatal(1,"Single note failed to cancel SD loading");
  @(negedge clk);k0=0;repeat(32)@(negedge clk);k0=1;repeat(32)@(negedge clk);
  if(dut.note_busy || !dut.ringtone_active) $fatal(1,"KEY0 failed to preempt single note");
  send_frame(0,'h11,0,0,0);settle();
  @(negedge clk);k2=0;repeat(4)@(negedge clk);k2=1;wait(dut.rst_n);
  if(dut.selected_note || dut.note_busy) $fatal(1,"KEY2 must reset selection");
  wait(displayed_note==0);settle();
  if(displayed_instrument!=0) $fatal(1,"Reset must display piano");
  // Selecting an instrument cancels a loading song and never emits a note.
  send_frame(0,'h10,1,0,0);wait(dut.ringtone_active);
  prior_ons=ons;send_frame(0,'h44,0,0,0);settle();
  if(dut.ringtone_active || dut.note_busy || ons!=prior_ons || dut.pcm!=0 ||
     !dut.selected_marimba || displayed_instrument!=1 || displayed_note!=15)
   $fatal(1,"Marimba selection/SD cancellation/screen synchronization");
  send_frame(0,'h40,0,0,0);settle();
  if(displayed_note!=62) $fatal(1,"Marimba previous must display B5");
  play_and_finish(83);
  send_frame(0,'h41,0,0,0);settle();
  if(displayed_note!=15) $fatal(1,"Marimba next must display C2");
  play_and_finish(36);
  expected_note=36;send_frame(0,'h42,0,0,0);wait(dut.note_busy);
  send_frame(0,'h41,0,0,0);settle();
  if(displayed_note!=16 || dut.note_event_note!=36) $fatal(1,"Marimba selection changed sounding pitch");
  send_frame(0,'h43,0,0,0);settle();
  if(dut.note_busy || dut.pcm!=0 || displayed_instrument!=0 || displayed_note!=0)
   $fatal(1,"Switch to piano must stop and restore its note");
  play_and_finish(0);
  send_frame(0,'h44,0,0,0);settle();
  if(displayed_note!=16 || displayed_instrument!=1) $fatal(1,"Marimba note was not remembered");
  play_and_finish(37);
  // Physical KEY1 still starts its original marimba sequence at MIDI 36.
  @(negedge clk);k1=0;
  wait(dut.audition_event_valid && dut.audition_event_on);
  if(!dut.marimba_mode || dut.audition_event_note!=36) $fatal(1,"KEY1 behavior changed");
  repeat(32)@(negedge clk);k1=1;
  send_frame(0,'h44,0,0,0);settle();
  if(dut.pcm!=0 || dut.note_busy || displayed_note!=16) $fatal(1,"Reselect must clear physical audition");
  displayed_instrument=-1;send_frame(0,'h01,0,0,0);settle();
  if(displayed_instrument!=1) $fatal(1,"Query must restore instrument text");
  @(negedge clk);k2=0;repeat(4)@(negedge clk);k2=1;wait(dut.rst_n);
  wait(displayed_instrument==0 && displayed_note==0);settle();
  if(dut.selected_marimba || displayed_instrument!=0 || displayed_note!=0 || dut.uart_notes.marimba_note!=15)
   $fatal(1,"KEY2 must restore both instrument selections");
  passed=1;$display("PASS UART audition: piano/marimba audio and mapping, screen GB2312 instrument/note, memory, switching, query, reset, SD/KEY0/KEY1 arbitration");$finish;
 end
 initial begin #100000000;$fatal(1,"UART notes timeout");end
endmodule
