`timescale 1ns/1ps
module tb_uart_protocol;
 localparam UART_TICKS=434;
 reg clk=0,rst_n=0,rx=1,passed=0;
 always #10 clk=~clk;
 wire tx,play,stop,overflow;
 wire note_previous,note_next,note_play;
 integer previous_count=0,next_count=0,note_count=0;
 wire [7:0] track;
 reg [7:0] state=0,selected=0,error=0;
 reg [6:0] note_selected=0;
 integer starts=0,stops=0,snapshots=0,reply_count=0;
 integer fields[0:5];
 integer results[0:255],commands[0:255],states[0:255],tracks[0:255];
 reg seen[0:255];
 reg overflow_reported=0;
 uart_score_control #(.TIMEOUT_CYCLES(12000)) dut (
  .clk(clk),.rst_n(rst_n),.rx(rx),.tx(tx),.player_state(state),
  .player_track(selected),.player_error(error),.play_request(play),
  .selected_note(note_selected),
  .stop_request(stop),.requested_track(track),.overflow(overflow),
  .note_previous(note_previous),.note_next(note_next),.note_play(note_play));
 `include "uart_test_tasks.vh"
 always @(posedge clk) if(rst_n) begin
  if(play) begin starts=starts+1; selected<=track; state<=1; end
  if(stop) begin stops=stops+1; selected<=0; state<=0; end
  if(note_previous) begin previous_count=previous_count+1;note_selected<=(note_selected==0)?87:note_selected-1'b1;end
  if(note_next) begin next_count=next_count+1;note_selected<=(note_selected==87)?0:note_selected+1'b1;end
  if(note_play) note_count=note_count+1;
 end
 // Decode physical TX independently of the transmitter/formatter internals.
 reg [7:0] c;
 integer bit_index,ff=0,pos=0,number=0,field=0,i;
 reg [103:0] prefix;
 reg [191:0] text_command=0;
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
    end else if(field==6) begin
     if(text_command!="every.tNote.txt=\"A0\"" && text_command!="every.tNote.txt=\"C8\"")
      $fatal(1,"Native note command invalid: %s",text_command);
     if(fields[5]=='h40 && fields[4]==16 && text_command!="every.tNote.txt=\"C8\"")
      $fatal(1,"Previous note reply did not contain C8");
     if(fields[5]=='h41 && fields[4]==17 && text_command!="every.tNote.txt=\"A0\"")
      $fatal(1,"Next note reply did not contain A0");
     if(fields[2]=='h60) overflow_reported=1;
     snapshots=snapshots+1;
     if(fields[5]!=8'h81) begin
      seen[fields[4]]=1; results[fields[4]]=fields[3];commands[fields[4]]=fields[5];
      states[fields[4]]=fields[0];tracks[fields[4]]=fields[1];reply_count=reply_count+1;
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
   if(field==6) text_command={text_command[183:0],c};
   else if(pos<13) prefix={prefix[95:0],c};
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
  send_frame(1,'h10,1,0,0);expect_reply(1,0,'h10);
  if(starts!=1 || states[1]!=1 || tracks[1]!=1) $fatal(1,"Play snapshot precedes command execution");
  send_frame(2,'h10,4,0,0);expect_reply(2,1,'h10);
  send_frame(3,'h10,2,1,0);expect_reply(3,1,'h10);
  send_frame(4,'h99,0,0,0);expect_reply(4,2,'h99);
  if(starts!=1) $fatal(1,"Invalid request changed player");
  // Wrong checksum, version and tail, random bytes, overlapping headers.
  send_byte('ha5);send_byte('h5a);send_byte(1);send_byte(5);send_byte('h10);
  send_byte(2);send_byte(0);send_byte(0);send_byte(0);send_byte('h0d);
  send_byte('ha5);send_byte('h5a);send_byte(2);send_byte(6);send_byte('h10);
  send_byte(2);send_byte(0);send_byte(0);send_byte('h1a);send_byte('h0d);
  send_byte('ha5);send_byte('h5a);send_byte(1);send_byte(7);send_byte('h10);
  send_byte(2);send_byte(0);send_byte(0);send_byte('h1a);send_byte('h0e);
  send_byte('h65);send_byte('hff);send_byte('ha5);
  send_frame(8,'h01,0,0,0);expect_reply(8,0,'h01);
  if(starts!=1 || seen[5] || seen[6] || seen[7]) $fatal(1,"Corrupt frame accepted");
  // A valid-looking frame split by timeout must not execute.
  send_byte('ha5);send_byte('h5a);send_byte(1);send_byte(9);
  repeat(15000) @(negedge clk);
  send_byte('h10);send_byte(2);send_byte(0);send_byte(0);send_byte('h1c);send_byte('h0d);
  send_frame(10,'h11,0,0,0);expect_reply(10,0,'h11);
  if(starts!=1 || stops!=1 || states[10]!=0) $fatal(1,"Timeout/stop handling");
  // Bad stop bit/break and a short low glitch must recover cleanly.
  @(negedge clk);rx=0;repeat(UART_TICKS*12) @(negedge clk);
  rx=1;repeat(UART_TICKS*2) @(negedge clk);
  rx=0;repeat(20) @(negedge clk);rx=1;repeat(UART_TICKS*2) @(negedge clk);
  send_frame(11,'h10,3,0,0);expect_reply(11,0,'h10);
  if(starts!=2 || selected!=3) $fatal(1,"RX did not recover after framing error");
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
  // Deliberately exceed the documented host pacing; STOP must still work,
  // and overflow must be observable once queued native replies drain.
  for(i=30;i<54;i=i+1) send_frame(i,1,0,0,0);
  send_frame(60,'h11,0,0,0);
  wait(stops==2);
  if(!overflow || state!=0) begin repeat(4) @(negedge clk); end
  if(!overflow || state!=0) $fatal(1,"Saturated feedback blocked stop");
  wait(overflow_reported);
  passed=1;$display("PASS UART: 115200 8N1, checksum/version/tail, resync, timeout, break, arguments, native TX, queued replies");$finish;
 end
 initial begin #1000000000;$fatal(1,"UART protocol timeout");end
endmodule
