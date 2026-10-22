`timescale 1ns/1ps
`include "../output/ringtone_test/params.vh"
module tb_ringtone_synth;
 reg clk=0;always #10 clk=~clk;
 reg rst=0,tick=0,valid=0,on_value=0;
 reg [6:0] note=0;reg [7:0] dyn=0;
 wire ready,pcm_valid,deadline,saturated;
 wire signed [15:0] pcm;
 reg [63:0] events[0:`RINGTONE_EVENTS-1];
 integer event_index=0,frame,fd,cycles;
 reg passed=0;
 marimba_synth dut(.clk(clk),.reset_n(rst),.sample_tick(tick),.stop_all(1'b0),
  .event_valid(valid),.event_on(on_value),.event_note(note),.event_dynamics(dyn),
  .event_ready(ready),.mix_sample(),.mix_valid(),.pcm(pcm),.pcm_valid(pcm_valid),
  .limiting(),.saturated(saturated),.deadline_error(deadline));
 initial begin
  $readmemh("output/ringtone_test/events.hex",events);
  fd=$fopen("sim/ringtone_synth_pcm.txt","w");
  repeat(4)@(negedge clk);rst=1;
  for(frame=0;frame<`RINGTONE_FRAMES;frame=frame+1) begin
   while(event_index<`RINGTONE_EVENTS-1 &&
         (64'd3072000*frame >= 64'd50000000*events[event_index][31:0])) begin
    @(negedge clk);while(!ready)@(negedge clk);
    valid=1;on_value=events[event_index][55:48]!=0;
    note=events[event_index][46:40];dyn={events[event_index][54:48],1'b0};
    @(negedge clk);valid=0;event_index=event_index+1;
   end
   @(negedge clk);tick=1;@(negedge clk);tick=0;cycles=0;
   while(!pcm_valid && cycles<3072)begin @(negedge clk);cycles=cycles+1;end
   if(!pcm_valid || deadline || saturated || (^pcm===1'bx)) $fatal(1,"Ringtone audio frame %0d",frame);
   $fdisplay(fd,"%0d",pcm);repeat(2)@(negedge clk);
   if(frame%16000==0)$display("Ringtone frame %0d",frame);
  end
  if(event_index!=`RINGTONE_EVENTS-1)$fatal(1,"Lost score events");
  $fclose(fd);passed=1;$display("PASS: complete event-driven RTL ringtone, %0d frames",frame);$finish;
 end
 initial begin #(64'd20000000000);$fatal(1,"Audio timeout");end
endmodule
