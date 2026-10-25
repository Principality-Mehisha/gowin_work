`timescale 1ns/1ps
`include "../output/nocturne/params.vh"
module tb_nocturne_synth;
 reg clk=0,rst_n=0,tick=0,valid=0,on_value=0,passed=0;
 reg [6:0] note=0;
 reg [7:0] dynamics=0;
 always #10 clk=~clk;
 wire ready,pcm_valid,deadline,saturated;
 wire signed [15:0] pcm;
 reg [63:0] events[0:`NOCTURNE_EVENTS-1];
 integer index=0,frame,fd,cycles,max_cycles=0;
 clarinet_synth dut (
  .clk(clk),.reset_n(rst_n),.stop_all(1'b0),.sample_tick(tick),
  .event_valid(valid),.event_on(on_value),.event_note(note),.event_dynamics(dynamics),
  .pitch_ratio(18'd193274),.event_ready(ready),.pcm(pcm),.pcm_valid(pcm_valid),
  .mix_sample(),.mix_valid(),.limiting(),.saturated(saturated),.deadline_error(deadline));
 initial begin
  $readmemh("output/nocturne/events.hex",events);
  fd=$fopen("output/nocturne/nocturne_pcm.txt","w");if(!fd)$fatal(1,"Cannot open audio output");
  repeat(4)@(negedge clk);rst_n=1;
  for(frame=0;frame<`NOCTURNE_FRAMES;frame=frame+1)begin
   while(index<`NOCTURNE_EVENTS-1 && 64'd3072000*frame>=64'd50000000*events[index][31:0])begin
    @(negedge clk);while(!ready)@(negedge clk);
    valid=1;on_value=events[index][55:48]!=0;note=events[index][46:40];dynamics={events[index][54:48],1'b0};
    @(negedge clk);valid=0;index=index+1;
   end
   @(negedge clk);tick=1;@(negedge clk);tick=0;cycles=0;
   while(!pcm_valid && cycles<3072)begin @(negedge clk);cycles=cycles+1;end
   if(cycles>max_cycles)max_cycles=cycles;
   if(!pcm_valid || deadline || saturated || ^pcm===1'bx)$fatal(1,"Nocturne audio frame %0d",frame);
   $fdisplay(fd,"%0d",pcm);
   if(frame%250000==0)$display("Nocturne frame %0d / %0d",frame,`NOCTURNE_FRAMES);
  end
  if(index!=`NOCTURNE_EVENTS-1 || pcm!=0)$fatal(1,"Nocturne incomplete or release not silent");
  $fclose(fd);passed=1;$display("PASS: full real-time clarinet Nocturne, %0d samples, max latency %0d clocks",frame,max_cycles);$finish;
 end
 initial begin #(64'd6000000000);$fatal(1,"Nocturne synth timeout");end
endmodule
