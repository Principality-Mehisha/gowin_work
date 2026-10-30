`timescale 1ns/1ps
module tb_audio_analysis;
 reg clk=0,reset_n=0,clear=1,sample_valid=0,ready=1,passed=0;
 always #10 clk=~clk;
 reg signed [15:0] pcm=0;
 wire valid,busy;
 wire [8:0] address;
 wire [31:0] data,frames;
 reg [15:0] samples[0:6143];
 reg [31:0] expected[0:3071];
 integer vector_index=0,n,received=0,clocks=0,start_clock,max_compute=0;
 reg compare=1,stalled=0;
 reg [40:0] held;
 piano_audio_analysis dut(.clk(clk),.reset_n(reset_n),.clear(clear),.sample_valid(sample_valid),
  .sample_pcm(pcm),.out_ready(ready),.out_valid(valid),.out_address(address),.out_data(data),
  .completed_frames(frames),.busy(busy));
 always @(posedge clk)begin
  clocks=clocks+1;
  if(reset_n && !clear)begin
   if(stalled && (!valid || {address,data}!==held))$fatal(1,"Analysis result changed under backpressure");
   stalled=valid && !ready;held={address,data};
   if(valid && ready && compare)begin
    if(address!==received[8:0] || data!==expected[vector_index*512+received])
     $fatal(1,"FFT/wave mismatch vector=%0d row=%0d address=%0d got=%h expected=%h",vector_index,received,address,data,expected[vector_index*512+received]);
    received=received+1;
   end
  end else stalled=0;
 end
 task sample;
  input signed [15:0] value;
  begin @(negedge clk);pcm=value;sample_valid=1;@(negedge clk);sample_valid=0;repeat(14)@(negedge clk);end
 endtask
 initial begin
  $readmemh("output/piano_analysis/input.hex",samples);
  $readmemh("output/piano_analysis/expected.hex",expected);
  repeat(5)@(negedge clk);reset_n=1;clear=0;
  for(vector_index=0;vector_index<6;vector_index=vector_index+1)begin
   clear=1;repeat(4)@(negedge clk);clear=0;received=0;
   sample(-1);
   for(n=0;n<1024;n=n+1)sample(samples[vector_index*1024+n]);
   start_clock=clocks;
   wait(valid);@(negedge clk);ready=0;repeat(100)@(negedge clk);ready=1;
   wait(received==512);@(negedge clk);
   if(clocks-start_clock>40000)$fatal(1,"Analysis exceeded block compute budget");
   if(clocks-start_clock>max_compute)max_compute=clocks-start_clock;
  end
  // Stop during capture, FFT and a stalled output; no stale data may escape.
  compare=0;
  sample(-1);sample(0);sample(1000);clear=1;repeat(4)@(negedge clk);
  if(valid || busy)$fatal(1,"Capture cancellation failed");
  clear=0;sample(-1);for(n=0;n<1024;n=n+1)sample(0);
  wait(dut.state==5);@(negedge clk);clear=1;repeat(4)@(negedge clk);
  if(valid || busy)$fatal(1,"FFT cancellation failed");
  clear=0;sample(-1);for(n=0;n<1024;n=n+1)sample(0);
  wait(valid);@(negedge clk);ready=0;reset_n=0;repeat(4)@(negedge clk);reset_n=1;
  if(valid || busy)$fatal(1,"Output/reset cancellation failed");
  passed=1;$display("PASS audio analysis: 3072 exact FFT/wave rows, silence/sine/two-tone/DC/full-scale/noise, backpressure/cancel/reset, max=%0d clocks",max_compute);$finish;
 end
 initial begin #30000000;$fatal(1,"Audio analysis timeout");end
endmodule
