`timescale 1ns/1ps
module tb_analysis_cdc;
 reg sys_clk=0,pixel_clk=0,rst=0,clear=1,write_valid=0,frame_tick=0,passed=0;
 always #10 sys_clk=~sys_clk;
 always #4.63 pixel_clk=~pixel_clk;
 reg [8:0] wa=0,ra=0;
 reg [31:0] wd=0;
 wire ready,visible;
 wire [31:0] data;
 integer i,generation=0,checks=0;
 reg [1:0] mode=0;
 wire [1:0] received_mode;
 wire snapshot_update;
 analysis_frame_cdc dut(.sys_clk(sys_clk),.sys_reset_n(rst),.clear(clear),.write_valid(write_valid),
  .write_address(wa),.write_data(wd),.write_ready(ready),.pixel_clk(pixel_clk),.pixel_reset_n(rst),
  .frame_tick(frame_tick),.read_address(ra),.read_data(data),.visible_valid(visible));
 playback_video_cdc modes(.sys_clk(sys_clk),.sys_reset_n(rst),.pixel_clk(pixel_clk),.pixel_reset_n(rst),
  .frame_tick(frame_tick),.active(1'b0),.elapsed_ms(32'd0),.keys(88'd0),.display_mode(mode),
  .video_mode(received_mode),.update(snapshot_update),.video_active(),.video_ms(),.video_keys());
 task vblank;
  begin @(negedge pixel_clk);frame_tick=1;@(negedge pixel_clk);frame_tick=0;repeat(12)@(negedge pixel_clk);end
 endtask
 task write_frame;
  input integer id;
  begin
   wait(ready);
   for(i=0;i<512;i=i+1)begin
    @(negedge sys_clk);write_valid=1;wa=i;wd=(id<<16)|i;
   end
   @(negedge sys_clk);write_valid=0;repeat(8)@(negedge pixel_clk);
  end
 endtask
 task inspect;
  input integer id;
  begin
   for(i=0;i<512;i=i+1)begin
    @(negedge pixel_clk);ra=i;repeat(2)@(negedge pixel_clk);
    if(data!==((id<<16)|i))$fatal(1,"Torn frame expected=%0d row=%0d data=%h",id,i,data);
    checks=checks+1;
   end
  end
 endtask
 initial begin
  repeat(6)@(negedge sys_clk);rst=1;clear=0;
  write_frame(1);
  if(visible)$fatal(1,"Frame became visible before vertical blank");
  mode=1;vblank();wait(ready);
  if(!visible || received_mode!=1)$fatal(1,"Frame/mode did not swap");
  inspect(1);
  write_frame(2);inspect(1); // Producer is blocked; the old bank stays immutable.
  mode=2;vblank();wait(ready);inspect(2);
  if(received_mode!=2)$fatal(1,"Mode snapshot lost");
  write_frame(3);
  // Multiple stop/retrigger edges between video frames cannot alias an old frame.
  repeat(3)begin @(negedge sys_clk);clear=1;repeat(4)@(negedge sys_clk);clear=0;repeat(4)@(negedge sys_clk);end
  vblank();wait(ready);
  if(visible)$fatal(1,"Stale pending frame survived stream cancellation");
  write_frame(4);vblank();wait(ready);inspect(4);
  write_frame(5);@(negedge sys_clk);rst=0;repeat(5)@(negedge sys_clk);rst=1;
  vblank();if(visible)$fatal(1,"Reset resurrected a frame");
  write_frame(6);mode=0;vblank();wait(ready);inspect(6);
  if(received_mode!=0)$fatal(1,"Waterfall mode not restored");
  passed=1;$display("PASS analysis CDC: %0d exact bank reads, vblank-only swaps, held payloads, mode snapshots, rapid cancel and pending reset",checks);$finish;
 end
 initial begin #10000000;$fatal(1,"Analysis CDC timeout");end
endmodule
