`timescale 1ns/1ps
module tb_clarinet;
 reg clk=0,reset_n=0,stop_all=0,sample_tick=0,passed=0;
 reg event_valid=0,event_on=0;
 reg [6:0] event_note=50;
 reg [7:0] event_dynamics=192;
 always #10 clk=~clk;
 wire ready,mix_valid,pcm_valid,deadline,limiting,saturated;
 wire signed [31:0] mix_sample;
 wire signed [15:0] pcm;
 integer n,i,cycles,max_cycles=0,heard,fd;
 reg [15:0] held_envelope;
 reg signed [15:0] quiet_peak,loud_peak;
 clarinet_synth dut (
  .clk(clk),.reset_n(reset_n),.sample_tick(sample_tick),.stop_all(stop_all),
  .event_valid(event_valid),.event_on(event_on),.event_note(event_note),
  .event_dynamics(event_dynamics),.pitch_ratio(18'd193274),.event_ready(ready),
  .mix_sample(mix_sample),.mix_valid(mix_valid),.pcm(pcm),.pcm_valid(pcm_valid),
  .limiting(limiting),.saturated(saturated),.deadline_error(deadline));
 task send_event(input bit on_value,input integer note_value,input integer velocity);
  begin
   @(negedge clk);while(!ready)@(negedge clk);
   event_valid=1;event_on=on_value;event_note=note_value;event_dynamics=velocity;
   @(negedge clk);event_valid=0;
  end
 endtask
 task frame;
  begin
   @(negedge clk);sample_tick=1;@(negedge clk);sample_tick=0;cycles=0;
   while(!pcm_valid && cycles<3072)begin @(negedge clk);cycles=cycles+1;end
   if(cycles>max_cycles)max_cycles=cycles;
   if(!pcm_valid || cycles>=3072 || deadline || saturated || limiting)
    $fatal(1,"Clarinet realtime/limiter error: %0d clocks",cycles);
   if(^pcm===1'bx || ^mix_sample===1'bx)$fatal(1,"Unknown clarinet audio");
  end
 endtask
 task clear_voice;
  begin @(negedge clk);stop_all=1;@(negedge clk);stop_all=0;
   if(pcm!=0 || dut.gate || dut.envelope!=0)$fatal(1,"Stop failed");end
 endtask
 initial begin
  repeat(4)@(negedge clk);reset_n=1;
  send_event(1,49,192);send_event(1,95,192);frame();
  if(dut.gate || pcm!=0)$fatal(1,"Invalid pitch accepted");
  fd=$fopen("output/clarinet/clarinet45_pcm.txt","w");
  if(!fd)$fatal(1,"Cannot open audio output");
  for(n=50;n<=94;n=n+1)begin
   clear_voice();send_event(1,n,192);heard=0;
   for(i=0;i<3072;i=i+1)begin
    frame();$fdisplay(fd,"%0d",pcm);
    if(pcm!=0)heard=heard+1;
    if(i==100)begin
     held_envelope=dut.envelope;send_event(0,n==50?51:50,192);
     if(!dut.gate)$fatal(1,"Foreign note-off cut the held note");
    end
   end
   if(heard<2500 || dut.envelope!=32767 || !dut.gate)
    $fatal(1,"Pitch %0d failed attack/sustain",n);
   send_event(0,n,192);
   for(i=0;i<1024;i=i+1)begin frame();$fdisplay(fd,"%0d",pcm);end
   if(dut.envelope!=0 || pcm!=0 || dut.gate)$fatal(1,"Release failed pitch %0d",n);
  end
  $fclose(fd);
  // Velocity affects amplitude, not frequency. Retrigger restarts the envelope.
  send_event(1,69,64);quiet_peak=0;
  repeat(600)begin frame();if(pcm>quiet_peak)quiet_peak=pcm;end
  send_event(1,69,224);if(dut.envelope!=0)$fatal(1,"Retrigger did not restart attack");
  loud_peak=0;repeat(600)begin frame();if(pcm>loud_peak)loud_peak=pcm;end
  if(loud_peak<quiet_peak*3)$fatal(1,"Velocity scaling failed");
  send_event(1,69,0);repeat(520)frame();if(pcm!=0 || dut.gate)$fatal(1,"Zero velocity off failed");
  // A stalled event is accepted once the active frame completes.
  send_event(1,50,192);
  @(negedge clk);sample_tick=1;@(negedge clk);sample_tick=0;
  event_valid=1;event_on=1;event_note=94;event_dynamics=192;
  while(!ready)begin
   if(dut.held_note!=50)$fatal(1,"Event accepted while not ready");
   @(negedge clk);
  end
  @(negedge clk);event_valid=0;
  if(dut.held_note!=94)$fatal(1,"Backpressured event lost");
  // Stop and reset in every computational state, including limiter activity.
  for(i=0;i<14;i=i+1)begin
   clear_voice();send_event(1,60,192);
   @(negedge clk);sample_tick=1;@(negedge clk);sample_tick=0;
   if(i!=0)wait(dut.state==i);
   clear_voice();frame();if(pcm!=0)$fatal(1,"Stop leaked stale audio state=%0d",i);
   send_event(1,60,192);
   @(negedge clk);sample_tick=1;@(negedge clk);sample_tick=0;
   if(i!=0)wait(dut.state==i);
   @(negedge clk);reset_n=0;@(negedge clk);reset_n=1;
   frame();if(pcm!=0)$fatal(1,"Reset leaked stale audio state=%0d",i);
  end
  // A genuinely overlapping frame must report a deadline error; reset clears it.
  @(negedge clk);sample_tick=1;repeat(3)@(negedge clk);sample_tick=0;
  if(!deadline)$fatal(1,"Overlapping sample deadline not detected");
  reset_n=0;@(negedge clk);reset_n=1;
  if(deadline)$fatal(1,"Reset did not clear deadline");
  passed=1;$display("PASS clarinet: all 45 pitches, sustain/release, velocity, note-off matching, backpressure, stop/reset, max output latency %0d clocks",max_cycles);$finish;
 end
 initial begin #1000000000;$fatal(1,"Clarinet timeout");end
endmodule
