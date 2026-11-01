`timescale 1ns/1ps
// Independent old-style full synths are the bit-exact output reference.
module tb_instrument_bank;
 reg clk=0,reset_n=0,tick=0,stop_all=0,valid=0,on=0,passed=0;
 reg [1:0] instrument=0;
 reg [6:0] note=0;
 reg [7:0] velocity=192;
 always #10 clk=~clk;
 wire ready,deadline,pcm_valid;
 wire signed [15:0] pcm,piano_pcm,marimba_pcm;
 wire pr,mr,pv,mv,pd,md;
 integer frame_index,total_frames=0,mode,cycles;
 reg bank_seen,ref_seen;
 reg signed [15:0] bank_sample,ref_sample;
 wire reference_ready=instrument==1 ? mr : pr;
 wire reference_valid=instrument==1 ? mv : pv;
 wire signed [15:0] reference_pcm=instrument==1 ? marimba_pcm : piano_pcm;
 instrument_voice_bank #(.LIVE_DYNAMICS(1)) bank(.clk(clk),.reset_n(reset_n),.sample_tick(tick),.stop_all(stop_all),
  .marimba_mode(instrument==1),.event_valid(valid),.event_on(on),.event_update(1'b0),
  .event_note(note),.event_dynamics(velocity),.pitch_ratio(18'd193274),
  .event_ready(ready),.deadline_error(deadline),.pcm(pcm),.pcm_valid(pcm_valid));
 piano_synth piano(.clk(clk),.reset_n(reset_n),.sample_tick(tick),.stop_all(stop_all),
  .event_valid(valid && instrument==0),.event_on(on),.event_note(note),.event_dynamics(velocity),
  .pitch_ratio(18'd193274),.event_ready(pr),.pcm(piano_pcm),.pcm_valid(pv),.deadline_error(pd));
 marimba_synth marimba(.clk(clk),.reset_n(reset_n),.sample_tick(tick),.stop_all(stop_all),
  .event_valid(valid && instrument==1),.event_on(on),.event_note(note),.event_dynamics(velocity),
  .event_ready(mr),.pcm(marimba_pcm),.pcm_valid(mv),.deadline_error(md));
 task event_send;
  input [6:0] pitch;input gate;input [7:0] dynamics;
  begin
   @(negedge clk);wait(ready && reference_ready);
   note=pitch;on=gate;velocity=dynamics;valid=1;
   @(negedge clk);valid=0;
  end
 endtask
 task frame;
  begin
   @(negedge clk);tick=1;bank_seen=0;ref_seen=0;
   @(negedge clk);tick=0;
   for(cycles=0;cycles<3071;cycles=cycles+1) begin
    if(pcm_valid)begin bank_seen=1;bank_sample=pcm;end
    if(reference_valid)begin ref_seen=1;ref_sample=reference_pcm;end
    @(negedge clk);
   end
   if(!bank_seen || !ref_seen || bank_sample!==ref_sample || deadline || pd || md)
    $fatal(1,"Shared limiter changed audio mode=%0d frame=%0d got=%0d expected=%0d",instrument,total_frames,bank_sample,ref_sample);
   total_frames=total_frames+1;
  end
 endtask
 initial begin
  repeat(4)@(negedge clk);reset_n=1;
  for(mode=0;mode<4;mode=mode+1)begin
   @(negedge clk);stop_all=1;instrument=mode%2;
   repeat(4)@(negedge clk);stop_all=0;
   event_send(instrument==1 ? 36+mode*8 : 39+mode*7,1,mode<2 ? 255 : 64);
   if(instrument==0)begin event_send(43,1,255);event_send(46,1,255);end
   for(frame_index=0;frame_index<192;frame_index=frame_index+1)frame();
   event_send(note,0,0);
   for(frame_index=0;frame_index<96;frame_index=frame_index+1)frame();
  end
  passed=1;$display("PASS instrument bank: %0d exact PCM frames, all timbres, chords, dynamics, release and switches",total_frames);$finish;
 end
 initial begin #300000000;$fatal(1,"Instrument bank timeout");end
endmodule
