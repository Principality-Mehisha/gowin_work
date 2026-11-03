`timescale 1ns/1ps
module tb_uart_protocol #(parameter integer UART_TICKS=5208);
 reg clk=0,rst_n=0,rx=1,passed=0;
 always #10 clk=~clk;
 wire tx,play,stop,overflow;
 wire [1:0] view_mode;
 wire [1:0] fx_mode;
 wire [6:0] fx_amount;
 wire guide_mode,guide_changed;
 wire note_previous,note_next,note_play;
 wire select_piano,select_marimba;
 reg marimba_selected=0;
 integer piano_count=0,marimba_count=0;
 integer previous_count=0,next_count=0,note_count=0;
 integer mode_changes=0;
 wire [7:0] track;
 reg [7:0] state=0,selected=0,error=0;
 reg [6:0] note_selected=0;
 integer starts=0,stops=0,snapshots=0,reply_count=0;
 integer fields[0:7];
 integer modes[0:255],amounts[0:255];
 integer guides[0:255];
 integer results[0:255],commands[0:255],states[0:255],tracks[0:255];
 reg seen[0:255];
 reg overflow_reported=0;
 uart_score_control #(.CLK_HZ(UART_TICKS*9600),.TIMEOUT_CYCLES(150000)) dut (
  .clk(clk),.rst_n(rst_n),.rx(rx),.tx(tx),.player_state(state),
  .player_track(selected),.player_error(error),.play_request(play),
  .selected_note(note_selected),
  .selected_marimba(marimba_selected),.note_select_piano(select_piano),.note_select_marimba(select_marimba),
  .stop_request(stop),.requested_track(track),.display_mode(view_mode),.overflow(overflow),
  .effect_mode(fx_mode),.effect_amount(fx_amount),
  .guide_mode(guide_mode),.guide_changed(guide_changed),
  .note_previous(note_previous),.note_next(note_next),.note_play(note_play));
 `include "uart_test_tasks.vh"
 always @(posedge clk) if(rst_n) begin
  if(guide_changed)mode_changes=mode_changes+1;
  if(play) begin starts=starts+1; selected<=track; state<=1; end
  if(stop) begin stops=stops+1; selected<=0; state<=0; end
  if(note_previous) begin previous_count=previous_count+1;note_selected<=(note_selected==0)?87:note_selected-1'b1;end
  if(note_next) begin next_count=next_count+1;note_selected<=(note_selected==87)?0:note_selected+1'b1;end
  if(note_play) note_count=note_count+1;
  if(select_piano) begin piano_count=piano_count+1;marimba_selected<=0;end
  if(select_marimba) begin marimba_count=marimba_count+1;marimba_selected<=1;end
 end
 // Decode physical TX independently of the transmitter/formatter internals.
 reg [7:0] c;
 integer bit_index,ff=0,pos=0,number=0,field=0,i;
 reg [103:0] prefix;
 reg [287:0] text_command=0;
 initial forever begin
  @(negedge tx);
  repeat(UART_TICKS/2) @(posedge clk);
  if(tx!==0) $fatal(1,"TX invalid start bit");
  for(bit_index=0;bit_index<8;bit_index=bit_index+1) begin
   repeat(UART_TICKS) @(posedge clk);c[bit_index]=tx;
  end
  repeat(UART_TICKS) @(posedge clk);
  if(tx!==1) $fatal(1,"TX invalid stop bit");
  if(c==8'hff) begin
   ff=ff+1;
   if(ff==3) begin
    if(pos==0) begin
     // A leading FF fence discards a partial command after FPGA reset.
    end else if(field==8) begin
     if(text_command!="every.tNote.txt=\"A0\"" && text_command!="every.tNote.txt=\"C8\"")
      $fatal(1,"Native note command invalid: %s",text_command);
     if(fields[5]=='h40 && fields[4]==16 && text_command!="every.tNote.txt=\"C8\"")
      $fatal(1,"Previous note reply did not contain C8");
     if(fields[5]=='h41 && fields[4]==17 && text_command!="every.tNote.txt=\"A0\"")
      $fatal(1,"Next note reply did not contain A0");
     field=9;
    end else if(field==9) begin
     if(text_command!={"every.tInstrument.txt=\"",32'hb8d6c7d9,"\""} &&
        text_command!={"every.tInstrument.txt=\"",64'hc2edc1d6b0cdc7d9,"\""})
      $fatal(1,"Native instrument command invalid: %h",text_command);
     if(fields[4]==20 && fields[5]=='h44 &&
        text_command!={"every.tInstrument.txt=\"",64'hc2edc1d6b0cdc7d9,"\""})
      $fatal(1,"Marimba reply snapshot precedes execution");
     if(fields[4]==21 && fields[5]=='h43 &&
        text_command!={"every.tInstrument.txt=\"",32'hb8d6c7d9,"\""})
      $fatal(1,"Piano reply snapshot precedes execution");
     field=10;
    end else if(field==10) begin
     if(pos!=13 || prefix!="main.n8.val=" || number>1)
      $fatal(1,"Invalid guide mode echo");
     if(fields[2]=='h60) overflow_reported=1;
     snapshots=snapshots+1;
     if(fields[5]!=8'h81) begin
      seen[fields[4]]=1; results[fields[4]]=fields[3];commands[fields[4]]=fields[5];
      states[fields[4]]=fields[0];tracks[fields[4]]=fields[1];reply_count=reply_count+1;
      modes[fields[4]]=fields[6];amounts[fields[4]]=fields[7];
      guides[fields[4]]=number;
     end
     field=0;
    end else begin
     if(pos<14 || prefix!={"page0.n",8'h30+field[7:0],".val="})
      $fatal(1,"Native TJC prefix/value invalid field=%0d pos=%0d prefix=%h",field,pos,prefix);
     fields[field]=number;field=field+1;
    end
    ff=0;pos=0;number=0;prefix=0;text_command=0;
   end
  end else begin
   if(ff!=0) $fatal(1,"Missing three FF terminators");
   if(field==8 || field==9) text_command={text_command[279:0],c};
   else if(pos<(field==10 ? 12 : 13)) prefix={prefix[95:0],c};
   else begin
    if(c<"0" || c>"9") $fatal(1,"Non-decimal native value");
    number=number*10+c-"0";
   end
   pos=pos+1;
  end
 end
 task expect_reply;
  input integer sequence_number,result,command;
  begin
   wait(seen[sequence_number]);
   if(results[sequence_number]!=result || commands[sequence_number]!=command)
    $fatal(1,"Reply mismatch seq=%0d result=%0d cmd=%0d",sequence_number,results[sequence_number],commands[sequence_number]);
  end
 endtask
 initial begin
  for(i=0;i<256;i=i+1) seen[i]=0;
  repeat(10) @(negedge clk);rst_n=1;
  wait(snapshots==1);
  send_frame(1,'h12,1,1,0);expect_reply(1,0,'h12);
  if(starts!=1 || states[1]!=1 || tracks[1]!=4) $fatal(1,"Play snapshot precedes command execution");
  send_frame(2,'h12,1,0,0);expect_reply(2,1,'h12);
  send_frame(3,'h12,2,1,1);expect_reply(3,1,'h12);
  send_frame(4,'h99,0,0,0);expect_reply(4,2,'h99);
  if(starts!=1) $fatal(1,"Invalid request changed player");
  // Wrong checksum, version and tail, random bytes, overlapping headers.
  send_byte('ha5);send_byte('h5a);send_byte(1);send_byte(5);send_byte('h12);
  send_byte(1);send_byte(2);send_byte(0);send_byte(0);send_byte('h0d);
  send_byte('ha5);send_byte('h5a);send_byte(2);send_byte(6);send_byte('h12);
  send_byte(1);send_byte(2);send_byte(0);send_byte('h1d);send_byte('h0d);
  send_byte('ha5);send_byte('h5a);send_byte(1);send_byte(7);send_byte('h12);
  send_byte(1);send_byte(2);send_byte(0);send_byte('h1d);send_byte('h0e);
  send_byte('h65);send_byte('hff);send_byte('ha5);
  send_frame(8,'h01,0,0,0);expect_reply(8,0,'h01);
  if(starts!=1 || seen[5] || seen[6] || seen[7]) $fatal(1,"Corrupt frame accepted");
  // A valid-looking frame split by timeout must not execute.
  send_byte('ha5);send_byte('h5a);send_byte(1);send_byte(9);
  repeat(180000) @(negedge clk);
  send_byte('h12);send_byte(1);send_byte(2);send_byte(0);send_byte('h1f);send_byte('h0d);
  send_frame(10,'h11,0,0,0);expect_reply(10,0,'h11);
  if(starts!=1 || stops!=1 || states[10]!=0) $fatal(1,"Timeout/stop handling");
  // Bad stop bit/break and a short low glitch must recover cleanly.
  @(negedge clk);rx=0;repeat(UART_TICKS*12) @(negedge clk);
  rx=1;repeat(UART_TICKS*2) @(negedge clk);
  rx=0;repeat(UART_TICKS/260>0 ? UART_TICKS/260 : 1) @(negedge clk);rx=1;repeat(UART_TICKS*2) @(negedge clk);
  send_frame(11,'h12,1,2,0);expect_reply(11,0,'h12);
  if(starts!=2 || selected!=5) $fatal(1,"RX did not recover after framing error");
  // Queue several replies while the long native return is still in flight.
  send_frame(12,1,0,0,0);send_frame(13,1,0,0,0);send_frame(14,1,0,0,0);
  expect_reply(12,0,1);expect_reply(13,0,1);expect_reply(14,0,1);
  send_frame(255,1,0,0,0);expect_reply(255,0,1);
  send_frame('ha5,1,0,0,0);expect_reply('ha5,0,1);
  send_frame('h5a,1,0,0,0);expect_reply('h5a,0,1);
  send_frame('h0d,1,0,0,0);expect_reply('h0d,0,1);
  if(overflow) $fatal(1,"Normal command burst overflowed feedback");
  send_frame(16,'h40,0,0,0);expect_reply(16,0,'h40);
  send_frame(17,'h41,0,0,0);expect_reply(17,0,'h41);
  send_frame(18,'h42,0,0,0);expect_reply(18,0,'h42);
  send_frame(19,'h42,1,0,0);expect_reply(19,1,'h42);
  if(previous_count!=1 || next_count!=1 || note_count!=1)
   $fatal(1,"Three-key command count/argument validation");
  send_frame(20,'h44,0,0,0);expect_reply(20,0,'h44);
  send_frame(21,'h43,0,0,0);expect_reply(21,0,'h43);
  send_frame(22,'h44,1,0,0);expect_reply(22,1,'h44);
  send_frame(23,'h43,0,1,0);expect_reply(23,1,'h43);
  send_frame(24,'h44,0,0,1);expect_reply(24,1,'h44);
  if(piano_count!=1 || marimba_count!=1 || marimba_selected)
   $fatal(1,"Instrument commands accepted invalid parameters");
  send_frame(25,'h45,0,0,0);expect_reply(25,2,'h45);
  send_frame(29,'h10,4,0,0);expect_reply(29,2,'h10);
  for(i=1;i<=3;i=i+1)begin
   send_frame(90+i,'h10,i,0,0);expect_reply(90+i,2,'h10);
  end
  if(starts!=2 || selected!=5 || tracks[29]!=5 || piano_count!=1 || marimba_count!=1)
   $fatal(1,"Removed commands changed track or instrument");
  send_frame(70,'h50,1,0,0);expect_reply(70,0,'h50);
  if(view_mode!=1 || starts!=2)$fatal(1,"Spectrum selection changed playback");
  send_frame(71,'h50,2,0,0);expect_reply(71,0,'h50);
  if(view_mode!=2)$fatal(1,"Waveform selection failed");
  send_frame(72,'h50,3,0,0);expect_reply(72,1,'h50);
  send_frame(73,'h50,0,1,0);expect_reply(73,1,'h50);
  send_frame(74,'h50,0,0,1);expect_reply(74,1,'h50);
  if(view_mode!=2 || starts!=2 || note_count!=1)$fatal(1,"Invalid display request changed state");
  send_frame(75,'h50,0,0,0);expect_reply(75,0,'h50);
  if(view_mode!=0)$fatal(1,"Waterfall restore failed");
  send_frame(76,'h12,1,1,0);expect_reply(76,0,'h12);
  if(starts!=3 || selected!=4 || tracks[76]!=4)$fatal(1,"PN001 mapping");
  send_frame(77,'h12,2,100,0);expect_reply(77,0,'h12);
  if(starts!=4 || selected!=203 || tracks[77]!=203)$fatal(1,"MB100 mapping");
  send_frame(78,'h12,0,1,0);expect_reply(78,1,'h12);
  send_frame(79,'h12,3,1,0);expect_reply(79,1,'h12);
  send_frame(80,'h12,1,0,0);expect_reply(80,1,'h12);
  send_frame(81,'h12,1,101,0);expect_reply(81,1,'h12);
  send_frame(82,'h12,1,1,1);expect_reply(82,1,'h12);
  if(starts!=4 || selected!=203)$fatal(1,"Invalid numbered command changed playback");
  if(fx_mode!=0 || fx_amount!=30)$fatal(1,"FX reset defaults");
  for(i=0;i<4;i=i+1)begin
   send_frame(100+i,'h51,i,0,0);expect_reply(100+i,0,'h51);
   if(fx_mode!=i || modes[100+i]!=i)$fatal(1,"FX mode snapshot precedes execution");
  end
  send_frame(104,'h52,100,0,0);expect_reply(104,0,'h52);
  if(fx_amount!=100 || amounts[104]!=100)$fatal(1,"FX amount snapshot");
  send_frame(105,'h51,4,0,0);expect_reply(105,1,'h51);
  send_frame(106,'h52,101,0,0);expect_reply(106,1,'h52);
  send_frame(107,'h52,50,1,0);expect_reply(107,1,'h52);
  send_frame(108,'h51,1,0,1);expect_reply(108,1,'h51);
  if(fx_mode!=3 || fx_amount!=100 || starts!=4 || stops!=1 ||
     piano_count!=1 || marimba_count!=1 || view_mode!=0)$fatal(1,"Effects affected transport/view/instrument");
  send_frame(109,'h52,0,0,0);expect_reply(109,0,'h52);
  if(fx_amount || amounts[109])$fatal(1,"FX amount zero");
  send_frame(110,'h53,1,0,0);expect_reply(110,0,'h53);
  if(!guide_mode || guides[110]!=1)$fatal(1,"Guide on/echo failed");
  send_frame(111,'h53,2,0,0);expect_reply(111,1,'h53);
  send_frame(112,'h53,0,1,0);expect_reply(112,1,'h53);
  send_frame(113,'h53,0,0,1);expect_reply(113,1,'h53);
  if(!guide_mode || !guides[113])$fatal(1,"Bad guide arguments changed mode");
  send_frame(115,'h53,1,0,0);expect_reply(115,0,'h53);
  if(mode_changes!=1 || starts!=4 || stops!=1)$fatal(1,"Duplicate guide mode restarted transport");
  send_frame(114,'h53,0,0,0);expect_reply(114,0,'h53);
  if(guide_mode || guides[114] || mode_changes!=2)$fatal(1,"Guide off/echo failed");
  // Deliberately exceed the documented host pacing; STOP must still work,
  // and overflow must be observable once queued native replies drain.
  for(i=30;i<54;i=i+1) send_frame(i,1,0,0,0);
  send_frame(60,'h11,0,0,0);
  wait(stops==2);
  if(!overflow || state!=0) begin repeat(4) @(negedge clk); end
  if(!overflow || state!=0) $fatal(1,"Saturated feedback blocked stop");
  wait(overflow_reported);
  passed=1;$display("PASS UART: 9600 8N1, checksum/version/tail, resync, timeout, break, arguments, native TX, queued replies");$finish;
 end
 initial begin #(64'd15000000000);$fatal(1,"UART protocol timeout");end
endmodule
