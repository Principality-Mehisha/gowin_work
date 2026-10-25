`timescale 1ns/1ps
`include "../output/nocturne/params.vh"
module tb_nocturne_full;
 reg clk=0,rst_n=0,passed=0;
 always #10 clk=~clk;
 reg [7:0] bytes[0:`NOCTURNE_BYTES-1];
 reg [63:0] expected[0:`NOCTURNE_EVENTS-1];
 reg valid=0,file_done=0;
 reg [7:0] data=0;
 wire ready,event_valid,event_ready,format_ok,complete,dispatch_valid,on_value;
 wire [63:0] event_data;
 wire [6:0] note;
 wire [7:0] dynamics;
 wire [3:0] code;
 wire playing,finished,error;
 wire [31:0] elapsed;
 integer i,parsed=0,dispatched=0,cycle=0;
 wire dispatch_ready=(cycle%7)<4;
 piano_score_reader #(.DYNAMIC_FORMAT(1)) decoder (
  .clk(clk),.rst_n(rst_n),.marimba_format(1'b0),.clarinet_format(1'b1),
  .data(data),.valid(valid),.ready(ready),.file_found(rst_n),.file_size(`NOCTURNE_BYTES),
  .file_done(file_done),.event_data(event_data),.event_valid(event_valid),.event_ready(event_ready),
  .format_ok(format_ok),.complete(complete),.error_code(code));
 piano_score_sequencer #(.CLOCKS_PER_MS(100)) sequencer (
  .clk(clk),.rst_n(rst_n),.paused(1'b0),.format_ok(format_ok),.stream_complete(complete),.stream_error(code!=0),
  .event_data(event_data),.event_valid(event_valid),.event_ready(event_ready),
  .dispatch_ready(dispatch_ready),.dispatch_valid(dispatch_valid),.dispatch_on(on_value),
  .dispatch_note(note),.dispatch_dynamics(dynamics),.notes(),.velocities(),.gates(),.triggers(),
  .playing(playing),.finished(finished),.error(error),.elapsed_ms(elapsed));
 always @(posedge clk)if(rst_n)begin
  cycle=cycle+1;
  if(code || error)$fatal(1,"Full nocturne decoder/sequencer error");
  if(event_valid && event_ready)begin
   if(event_data!==expected[parsed])$fatal(1,"Parsed event %0d differs from BIN",parsed);
   parsed=parsed+1;
  end
  if(dispatch_valid && dispatch_ready)begin
   if(dispatched>=`NOCTURNE_EVENTS-1 || note!==expected[dispatched][46:40] ||
      on_value!==(expected[dispatched][55:48]!=0) || dynamics!=={expected[dispatched][54:48],1'b0} ||
      elapsed<expected[dispatched][31:0])$fatal(1,"Nocturne dispatch order/timing %0d",dispatched);
   dispatched=dispatched+1;
  end
  if(finished)begin
   if(!complete || parsed!=`NOCTURNE_EVENTS || dispatched!=`NOCTURNE_EVENTS-1)
    $fatal(1,"Nocturne full score incomplete");
   passed=1;$display("PASS: full Nocturne C45S, %0d parsed events, %0d exact dispatches with backpressure",parsed,dispatched);$finish;
  end
 end
 initial begin
  $readmemh("output/nocturne/score_bytes.hex",bytes);$readmemh("output/nocturne/events.hex",expected);
  repeat(4)@(negedge clk);rst_n=1;
  for(i=0;i<`NOCTURNE_BYTES;i=i+1)begin
   @(negedge clk);data=bytes[i];valid=1;
   @(posedge clk);while(!ready)@(posedge clk);
   @(negedge clk);valid=0;
  end
  file_done=1;@(negedge clk);file_done=0;
 end
 initial begin #500000000;$fatal(1,"Nocturne full score timeout");end
endmodule
