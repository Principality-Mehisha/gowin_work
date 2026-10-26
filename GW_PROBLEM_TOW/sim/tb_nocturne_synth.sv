`timescale 1ns/1ps
`include "../output/nocturne/params.vh"
module tb_nocturne_synth #(parameter integer SEGMENT=-1);
 reg clk=0,rst_n=0,tick=0,valid=0,on_value=0,passed=0;
 reg [6:0] note=0;
 reg [7:0] dynamics=0;
 always #10 clk=~clk;
 wire ready,pcm_valid,deadline,saturated;
 wire signed [15:0] pcm;
 reg [63:0] events[0:`NOCTURNE_EVENTS-1];
 integer index=0,frame,fd,cycles,max_cycles=0;
 integer first_frame=0,last_frame=`NOCTURNE_FRAMES,meta_fd,fields;
 integer seed_breath=0,seed_peak=0,end_breath,end_peak;
 clarinet_synth dut (
  .clk(clk),.reset_n(rst_n),.stop_all(1'b0),.sample_tick(tick),
  .event_valid(valid),.event_on(on_value),.event_note(note),.event_dynamics(dynamics),
  .pitch_ratio(18'd193274),.event_ready(ready),.pcm(pcm),.pcm_valid(pcm_valid),
  .mix_sample(),.mix_valid(),.limiting(),.saturated(saturated),.deadline_error(deadline));
 initial begin
  $readmemh("output/nocturne/events.hex",events);
  if(SEGMENT>=0)begin
   meta_fd=$fopen($sformatf("output/clarinet_calibration/segments/segment%0d.meta",SEGMENT),"r");
   if(!meta_fd)$fatal(1,"Missing segment checkpoint");
   fields=$fscanf(meta_fd,"%d %d %d %d %d %d %d",first_frame,last_frame,index,seed_breath,seed_peak,end_breath,end_peak);
   $fclose(meta_fd);if(fields!=7)$fatal(1,"Bad segment checkpoint");
   fd=$fopen($sformatf("output/clarinet_calibration/segments/segment%0d_pcm.txt",SEGMENT),"w");
  end else fd=$fopen("output/nocturne/nocturne_pcm.txt","w");
  if(!fd)$fatal(1,"Cannot open audio output");
  repeat(4)@(negedge clk);rst_n=1;
  if(SEGMENT>=0)begin
   // Boundaries are immediately before a new note-on. That event initializes
   // all per-note state; only breath pressure and limiter peak cross notes.
   // End checks prove the adjacent segments' carried states agree exactly.
   dut.breath_control=seed_breath;dut.limiter.peak=seed_peak;
  end
  for(frame=first_frame;frame<last_frame;frame=frame+1)begin
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
  if(SEGMENT>=0 && ($signed(dut.breath_control)!=end_breath || dut.limiter.peak!=end_peak))
   $fatal(1,"Segment boundary state mismatch segment=%0d breath=%0d/%0d peak=%0d/%0d",SEGMENT,$signed(dut.breath_control),end_breath,dut.limiter.peak,end_peak);
  if(last_frame==`NOCTURNE_FRAMES && (index!=`NOCTURNE_EVENTS-1 || pcm!=0))$fatal(1,"Nocturne incomplete or release not silent");
  $fclose(fd);passed=1;$display("PASS: full real-time clarinet Nocturne, %0d samples, max latency %0d clocks",frame,max_cycles);$finish;
 end
 initial begin #(64'd45000000000);$fatal(1,"Nocturne synth timeout");end
endmodule
