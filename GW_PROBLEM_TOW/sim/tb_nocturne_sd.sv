`timescale 1ns/1ps
module GSR(input GSRI);endmodule
module nocturne_sd_case #(
 parameter IMAGE="output/nocturne/fat16.hex",parameter PROFILE=0,parameter ERROR=0,
 parameter integer EXTERNAL_TABLES=0
)(output reg passed=0);
 localparam UART_TICKS=8;
 reg clk=0,rx=1,k2=1;
 always #10 if(!passed)clk=~clk;
 wire cs,sck,mosi,miso;
 integer ons=0,offs=0,heard=0,starts=0,saved;
 wire ddr_ready,ddr_fault,ddr_request,ddr_cancel,ddr_request_ready,ddr_response_valid;
 wire [10:0] ddr_address;
 wire [127:0] ddr_response_data;
 piano_score_player #(.POWER_ON_CYCLES(8),.DEBOUNCE_CYCLES(8),.AUDIO_START_CYCLES(32),
  .EXTERNAL_CLARINET_TABLES(EXTERNAL_TABLES),
  .UART_CLK_HZ(76800),.UART_BAUD(9600),.UART_TIMEOUT_CYCLES(4000),
  .SD_POWER_WAIT_CYCLES(16),.SD_INIT_HALF_DIV(3),.SD_READ_HALF_DIV(3),.CLOCKS_PER_MS(1024)) dut (
  .sys_clk(clk),.KEY0(1'b1),.KEY1(1'b1),.KEY2(k2),.uart_rx(rx),.uart_tx(),
  .HP_BCK(),.HP_WS(),.HP_DIN(),.PA_EN(),.sd_cs_n(cs),.sd_sck(sck),.sd_mosi(mosi),.sd_miso(miso),.LEDs(),
  .ddr_ready(ddr_ready),.ddr_fault(ddr_fault),.ddr_request(ddr_request),.ddr_cancel(ddr_cancel),
  .ddr_address(ddr_address),.ddr_request_ready(ddr_request_ready),.ddr_response_valid(ddr_response_valid),
  .ddr_response_data(ddr_response_data));
 generate if(EXTERNAL_TABLES!=0)begin: ddr_model
  reg ui_clk=0,calibrated=0;
  always #5 if(!passed)ui_clk=~ui_clk;
  // Deliberately hold calibration beyond the first SD load: elapsed time
  // must stay paused until the DDR tables have been checked.
  initial begin repeat(100000)@(negedge ui_clk);calibrated=1;end
  wire [2:0] cmd;
  wire cmd_en,cmd_ready,wr_ready,wr_en,wr_end,rd_valid,rd_end;
  wire [28:0] addr;
  wire [127:0] wr_data,rd_data;
  wire [15:0] mask;
  ddr_asset_service service(.sys_clk(clk),.reset_n(dut.rst_n),.cancel(ddr_cancel),
   .request(ddr_request),.address(ddr_address),.request_ready(ddr_request_ready),
   .response_valid(ddr_response_valid),.response_data(ddr_response_data),.ready(ddr_ready),.fault(ddr_fault),
   .ui_clk(ui_clk),.ui_reset(!dut.rst_n),.calibrated(calibrated),.cmd(cmd),.cmd_en(cmd_en),.addr(addr),
   .cmd_ready(cmd_ready),.wr_data(wr_data),.wr_data_en(wr_en),.wr_data_end(wr_end),.wr_data_mask(mask),
   .wr_data_rdy(wr_ready),.rd_data(rd_data),.rd_data_valid(rd_valid),.rd_data_end(rd_end),.ui_fault());
  ddr_native_model memory(.clk(ui_clk),.reset(!dut.rst_n),.cmd(cmd),.cmd_en(cmd_en),.addr(addr),
   .wr_data(wr_data),.wr_data_en(wr_en),.wr_data_end(wr_end),.wr_data_mask(mask),
   .cmd_ready(cmd_ready),.wr_data_rdy(wr_ready),.rd_data(rd_data),.rd_data_valid(rd_valid),
   .rd_data_end(rd_end),.freeze(1'b0),.corrupt(1'b0),.end_fault(1'b0),.writes(),.reads());
  always @(posedge clk)if(dut.rst_n && dut.ringtone_active && dut.selected_track==4 && !ddr_ready && dut.elapsed_ms!=0)
   $fatal(1,"Score clock ran before DDR initialization");
 end else begin: no_ddr_model
  assign ddr_ready=1;assign ddr_fault=0;assign ddr_request_ready=0;
  assign ddr_response_valid=0;assign ddr_response_data=0;
 end endgenerate
 sd_card_model #(.IMAGE_FILE(IMAGE),.IMAGE_BYTES(600000)) card (
  .rst_n(dut.storage_rst_n),.cs_n(cs),.sck(sck),.mosi(mosi),.miso(miso),
  .profile(PROFILE[1:0]),.fault(4'd0),.last_argument(),.read_commands(),.cmd16_seen());
 `include "uart_test_tasks.vh"
 always @(posedge clk)if(dut.rst_n)begin
  if(dut.uart_start)starts=starts+1;
  if(dut.deadline_error)$fatal(1,"Nocturne SD deadline");
  if(dut.ringtone_active && dut.selected_track==4 && (!dut.clarinet_mode || dut.marimba_mode))
   $fatal(1,"SD clarinet mode incorrect");
  if(dut.pcm!=0)heard=heard+1;
  if(dut.synth_event_valid && dut.synth_event_ready && dut.ringtone_active)begin
   if(dut.selected_track!=4 || !dut.clarinet.event_valid || dut.marimba.event_valid || dut.piano_path.synth.event_valid)
    $fatal(1,"Nocturne event routed to wrong synth");
   if(dut.synth_event_on)begin
    if(dut.synth_event_note!=(ons==0 ? 58 : 67) || dut.synth_event_dynamics!=180)
     $fatal(1,"Nocturne MIDI or velocity mismatch");
    ons=ons+1;
   end else offs=offs+1;
  end
 end
 initial begin
  wait(dut.rst_n);send_frame(1,'h10,4,0,0);
  if(ERROR)begin
   wait(dut.ringtone_error);repeat(4)@(negedge clk);
   if(dut.last_error!=ERROR || dut.pcm!=0 || dut.player_state!=3)
    $fatal(1,"C45S rejection code got=%h expected=%h",dut.last_error,ERROR);
   send_frame(2,'h11,0,0,0);repeat(4)@(negedge clk);
   if(dut.last_error || !dut.manual_mode)$fatal(1,"C45S stop did not clear error");
  end else begin
   wait(dut.playing);saved=starts;send_frame(2,'h10,4,0,0);
   if(starts!=saved)$fatal(1,"Duplicate nocturne play restarted SD");
   wait(!dut.ringtone_active);repeat(3)@(posedge dut.sample_tick);
   if(ons!=2 || offs!=2 || !heard || dut.last_error || dut.pcm!=0 || dut.clarinet_mode)
    $fatal(1,"Nocturne EOF/audio/dispatch failed");
   send_frame(3,'h10,4,0,0);send_frame(4,'h11,0,0,0);repeat(4)@(negedge clk);
   if(dut.ringtone_active || cs!==1 || dut.pcm!=0)$fatal(1,"Nocturne loading stop failed");
   send_frame(5,'h10,4,0,0);send_frame(6,'h45,0,0,0);repeat(4)@(negedge clk);
   if(dut.ringtone_active || !dut.selected_clarinet || dut.note_busy || dut.pcm!=0)
    $fatal(1,"Instrument selection failed to preempt SD");
   send_frame(7,'h10,4,0,0);@(negedge clk);k2=0;repeat(4)@(negedge clk);k2=1;wait(dut.rst_n);
   if(dut.ringtone_active || dut.selected_track || dut.pcm!=0)$fatal(1,"Nocturne reset failed");
  end
  passed=1;$display("PASS nocturne SD: FAT profile=%0d expected_error=%h",PROFILE,ERROR);
 end
endmodule
module tb_nocturne_sd;
 wire a,b,c,d,e,f,g;
 reg passed=0;
 nocturne_sd_case c16(a);
 nocturne_sd_case #(.IMAGE("output/nocturne/fat32.hex"),.PROFILE(2)) c32(b);
 nocturne_sd_case #(.IMAGE("output/nocturne/missing.hex"),.ERROR('h24)) missing(c);
 nocturne_sd_case #(.IMAGE("output/nocturne/wrong_magic.hex"),.ERROR('h31)) magic_case(d);
 nocturne_sd_case #(.IMAGE("output/nocturne/low_note.hex"),.ERROR('h32)) low_case(e);
 nocturne_sd_case #(.IMAGE("output/nocturne/high_note.hex"),.ERROR('h32)) high_case(f);
 nocturne_sd_case #(.IMAGE("output/nocturne/wrong_slot.hex"),.ERROR('h32)) slot_case(g);
 initial begin wait(a&&b&&c&&d&&e&&f&&g);passed=1;$display("PASS nocturne SD suite: C45S FAT16/FAT32, real synthesis, commands and malformed files");$finish;end
 initial begin #100000000;$fatal(1,"Nocturne SD timeout");end
endmodule
