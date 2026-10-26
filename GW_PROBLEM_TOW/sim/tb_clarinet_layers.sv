`timescale 1ns/1ps
module tb_clarinet_layers;
 reg clk=0,rst_n=0,stop=0,tick=0,valid=0,on_value=0,passed=0;
 reg [6:0] note=50;
 reg [7:0] dynamics=64;
 always #10 clk=~clk;
 wire ready,pcm_valid,deadline,saturated;
 wire signed [15:0] pcm;
 integer bank,midi,i,fd,cycles,case_index=0;
 integer boundaries[0:17];
 clarinet_synth dut(.clk(clk),.reset_n(rst_n),.stop_all(stop),.sample_tick(tick),
  .event_valid(valid),.event_on(on_value),.event_note(note),.event_dynamics(dynamics),
  .pitch_ratio(18'd193274),.event_ready(ready),.pcm(pcm),.pcm_valid(pcm_valid),
  .mix_sample(),.mix_valid(),.limiting(),.saturated(saturated),.deadline_error(deadline));
 task send(input bit on,input integer pitch,input integer velocity);
  begin @(negedge clk);while(!ready)@(negedge clk);valid=1;on_value=on;note=pitch;dynamics=velocity;
   @(negedge clk);valid=0;end
 endtask
 task frame;
  begin
   @(negedge clk);tick=1;@(negedge clk);tick=0;cycles=0;
   while(!pcm_valid && cycles<3072)begin @(negedge clk);cycles=cycles+1;end
   if(!pcm_valid || deadline || saturated || ^pcm===1'bx)$fatal(1,"Layer output/deadline");
   $fdisplay(fd,"%0d %0d %0d",note,dynamics,pcm);
  end
 endtask
 task check_case(input integer pitch,input integer velocity);
  begin
   @(negedge clk);stop=1;@(negedge clk);stop=0;
   send(1,pitch,velocity);repeat(256)frame();send(0,pitch,velocity);repeat(256)frame();
   case_index=case_index+1;
  end
 endtask
 initial begin
  boundaries[0]=1;boundaries[1]=63;boundaries[2]=64;boundaries[3]=65;
  boundaries[4]=127;boundaries[5]=128;boundaries[6]=159;boundaries[7]=160;
  boundaries[8]=161;boundaries[9]=180;boundaries[10]=191;boundaries[11]=192;
  boundaries[12]=223;boundaries[13]=239;boundaries[14]=240;boundaries[15]=241;
  boundaries[16]=254;boundaries[17]=255;
  fd=$fopen("output/clarinet_calibration/layer_pcm.txt","w");if(!fd)$fatal(1,"Layer output file");
  repeat(4)@(negedge clk);rst_n=1;
  for(bank=0;bank<3;bank=bank+1)
   for(midi=50;midi<=94;midi=midi+1)check_case(midi,bank==0?64:(bank==1?160:240));
  for(i=0;i<18;i=i+1)check_case(69,boundaries[i]);
  $fclose(fd);passed=1;$display("PASS: all 135 pitch/dynamic profiles plus 18 interpolation boundary cases (%0d)",case_index);$finish;
 end
 initial begin #(64'd2000000000);$fatal(1,"Clarinet layer timeout");end
endmodule
