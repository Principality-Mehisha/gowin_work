`timescale 1ns/1ps
module GSR(input GSRI);endmodule
module tb_piano_views;
 localparam UART_TICKS=8;
 reg clk=0,rx=1,follow=1,k2=1,passed=0;
 always #10 clk=~clk;
 wire reference_rx=follow ? rx : 1'b1;
 wire [1:0] mode;
 wire tick,enabled,clear;
 wire signed [15:0] pcm;
 integer heard=0,captures=0,rows=0,i;
 integer input_file,result_file;
 wire result_valid;
 wire [8:0] result_address;
 wire [31:0] result_data;
 piano_score_player #(.POWER_ON_CYCLES(8),.UART_CLK_HZ(76800),.UART_BAUD(9600)) dut (
  .sys_clk(clk),.KEY2(k2),.uart_rx(rx),.uart_tx(),.sd_miso(1'b1),
  .display_mode(mode),.piano_audio_active(enabled),.analysis_clear(clear),
  .analysis_sample_tick(tick),.analysis_pcm(pcm));
 piano_score_player #(.POWER_ON_CYCLES(8),.UART_CLK_HZ(76800),.UART_BAUD(9600)) reference (
  .sys_clk(clk),.KEY2(k2),.uart_rx(reference_rx),.uart_tx(),.sd_miso(1'b1));
 piano_audio_analysis analysis(.clk(clk),.reset_n(dut.rst_n),.clear(clear),.sample_valid(tick && enabled),
  .sample_pcm(pcm),.out_ready(1'b1),.out_valid(result_valid),.out_address(result_address),
  .out_data(result_data),.completed_frames(),.busy());
 `include "uart_test_tasks.vh"
 always @(posedge clk)if(dut.rst_n)begin
  if(dut.pcm!==reference.pcm || dut.HP_DIN!==reference.HP_DIN || dut.HP_WS!==reference.HP_WS || dut.HP_BCK!==reference.HP_BCK)
   $fatal(1,"Display commands altered actual audio/DAC");
  if(tick && pcm!==dut.audio.left_sample)$fatal(1,"Analysis sample differs from DAC latch");
  if(pcm!=0)heard=heard+1;
  if(analysis.first_sample || (analysis.state==1 && tick && enabled && !clear))begin
   if(captures<1024)$fdisplay(input_file,"%04x",pcm);
   captures=captures+1;
  end
  if(result_valid)begin
   if(result_address!==rows[8:0])$fatal(1,"Actual piano analysis row order");
   $fdisplay(result_file,"%08x",result_data);rows=rows+1;
  end
 end
 task settle;
  begin wait(dut.uart_control.link.count==0 && dut.uart_control.link.formatter.ready);repeat(100)@(negedge clk);end
 endtask
 task view;
  input [7:0] value;
  begin follow=0;send_frame(0,'h50,value,0,0);settle();end
 endtask
 initial begin
  input_file=$fopen("output/piano_analysis/piano_input.hex","w");
  result_file=$fopen("output/piano_analysis/piano_result.hex","w");
  wait(dut.rst_n);settle();
  for(i=0;i<39;i=i+1)begin send_frame(0,'h41,0,0,0);settle();end // C4, through the real UART.
  send_frame(0,'h42,0,0,0);wait(enabled);view(1);
  if(mode!=1 || !enabled)$fatal(1,"Spectrum command failed");
  view(2);if(mode!=2 || !enabled)$fatal(1,"Waveform command failed");
  view(3);if(mode!=2)$fatal(1,"Invalid view accepted");
  follow=0;send_frame(0,'h50,0,1,0);settle();if(mode!=2)$fatal(1,"Invalid view parameters accepted");
  view(0);if(mode!=0)$fatal(1,"Waterfall command failed");
  wait(rows==512);@(negedge clk);$fclose(input_file);$fclose(result_file);
  if(captures!=1024 || !heard)$fatal(1,"Missing actual piano PCM frame");
  follow=1;send_frame(0,'h11,0,0,0);settle();
  if(enabled || !clear)$fatal(1,"Stop left piano analysis enabled");
  send_frame(0,'h44,0,0,0);settle();send_frame(0,'h42,0,0,0);wait(dut.system.note_busy);
  heard=0;repeat(16)@(posedge tick);
  if(enabled || !clear || !heard)$fatal(1,"Marimba leaked into piano analysis or audio stopped");
  view(2);
  @(negedge clk);k2=0;repeat(5)@(negedge clk);k2=1;wait(dut.rst_n);
  if(mode || enabled)$fatal(1,"KEY2 did not restore waterfall/idle");
  passed=1;$display("PASS piano views: UART 0/1/2 and invalid arguments, unchanged PCM/DAC, 1024 real piano samples, marimba exclusion, stop/reset");$finish;
 end
 initial begin #300000000;$fatal(1,"Piano view integration timeout");end
endmodule
