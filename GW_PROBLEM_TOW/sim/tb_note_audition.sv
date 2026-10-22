`timescale 1ns/1ps
module tb_note_audition;
 reg clk=0,rst_n=0,prev=0,next=0,play=0,cancel=0,ready=0,passed=0;
 always #10 clk=~clk;
 wire valid,on,busy,clear;
 wire [6:0] selected,note;
 wire [7:0] dynamics;
 integer i,ons=0,offs=0;
 uart_note_audition #(.GATE_CYCLES(8),.TAIL_CYCLES(8)) dut (
  .clk(clk),.rst_n(rst_n),.previous_request(prev),.next_request(next),.play_request(play),
  .cancel(cancel),.event_ready(ready),.selected_note(selected),.event_valid(valid),
  .event_on(on),.event_note(note),.event_dynamics(dynamics),.busy(busy),.clear(clear));
 always @(posedge clk) if(valid && ready) begin
  if(on) ons=ons+1;else offs=offs+1;
 end
 task step_next;
  begin @(negedge clk);next=1;@(negedge clk);next=0;end
 endtask
 task step_previous;
  begin @(negedge clk);prev=1;@(negedge clk);prev=0;end
 endtask
 task trigger;
  begin @(negedge clk);play=1;@(negedge clk);play=0;end
 endtask
 initial begin
  repeat(4)@(negedge clk);rst_n=1;
  for(i=0;i<88;i=i+1) begin
   if(selected!==i[6:0] || busy || valid) $fatal(1,"Selection/order error %0d",i);
   trigger();
   repeat(3) begin @(negedge clk);
    if(!valid || !on || note!==i[6:0] || dynamics!=192) $fatal(1,"Note-on not held for ready");
   end
   ready=1;@(negedge clk);ready=0;
   wait(valid && !on);
   repeat(3) begin @(negedge clk);
    if(!valid || on || note!==i[6:0]) $fatal(1,"Note-off not held for ready");
   end
   ready=1;@(negedge clk);ready=0;
   wait(!busy);if(!clear) $fatal(1,"Tail clear missing");
   step_next();
  end
  if(selected!=0 || ons!=88 || offs!=88) $fatal(1,"88-note roundtrip failed");
  step_previous();if(selected!=87) $fatal(1,"A0 previous must wrap to C8");
  trigger();step_next();if(selected!=0 || note!=87) $fatal(1,"Selection changed a held note");
  ready=1;repeat(3)@(negedge clk);trigger();
  if(note!=0) $fatal(1,"Retrigger did not snapshot new selection");
  cancel=1;@(negedge clk);cancel=0;
  if(busy || valid || selected!=0) $fatal(1,"Cancel must stop sound, preserve selection");
  step_previous();@(negedge clk);rst_n=0;@(negedge clk);rst_n=1;
  if(selected || busy) $fatal(1,"Reset must select A0 and stop");
  passed=1;$display("PASS: all 88 notes, both wraps, stable selection/held note, ready/valid, automatic off/tail, retrigger/cancel/reset");$finish;
 end
 initial begin #10000000;$fatal(1,"Note audition timeout");end
endmodule
