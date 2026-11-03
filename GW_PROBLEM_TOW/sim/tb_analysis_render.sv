`timescale 1ns/1ps
module tb_analysis_render #(
 parameter DATA_FILE="output/piano_analysis/render_data.hex",
 parameter SPECTRUM_FILE="output/piano_analysis/spectrum.ppm",
 parameter WAVEFORM_FILE="output/piano_analysis/waveform.ppm",
 parameter integer ANALYSIS_RATE_RATIO=1
);
 reg clk=0,rst=0,passed=0;
 always #4.63 clk=~clk;
 reg [1:0] mode=1;
 wire [8:0] address;
 reg [31:0] data;
 reg [31:0] points[0:511];
 wire [7:0] r,g,b;
 wire hs,vs,de;
 integer frame,cycle,n,x,y,fd;
 video_source #(.ANALYSIS_RATE_RATIO(ANALYSIS_RATE_RATIO)) dut(
  .pixel_clk(clk),.reset_n(rst),.test_pattern(1'b0),.update(1'b0),.active(1'b0),
  .elapsed_ms(32'd0),.lit_keys(88'd0),.display_mode(mode),.analysis_valid(1'b1),
  .analysis_data(data),.analysis_address(address),.frame_tick(),.red(r),.green(g),.blue(b),
  .hsync(hs),.vsync(vs),.de(de));
 always @(posedge clk)data<=points[address];
 initial begin
  $readmemh(DATA_FILE,points);
  for(frame=1;frame<=2;frame=frame+1)begin
   rst=0;repeat(4)@(negedge clk);mode=frame;rst=1;
   if(frame==1)fd=$fopen(SPECTRUM_FILE,"wb");
   else fd=$fopen(WAVEFORM_FILE,"wb");
   $fwrite(fd,"P6\n1600 900\n255\n");
   for(cycle=0;cycle<1800004;cycle=cycle+1)begin
    @(posedge clk);#1;n=cycle-4;
    if(n>=0)begin
     x=n%1800;y=n/1800;
     if(de!==(x<1600 && y<900) || hs!==(x>=1624 && x<1704) || vs!==(y>=901 && y<904))
      $fatal(1,"Analysis RGB/control alignment frame=%0d x=%0d y=%0d",frame,x,y);
     if((^{r,g,b})===1'bx)$fatal(1,"Unknown analysis pixel");
     if(de)$fwrite(fd,"%c%c%c",r,g,b);
     else if({r,g,b}!==0)$fatal(1,"Analysis blanking pixel not zero");
    end
    @(negedge clk);
   end
   $fclose(fd);
  end
  passed=1;$display("PASS analysis render: both 1600x900 frames, RGB/control alignment, blanking, no unknowns, PPM export");$finish;
 end
 initial begin #60000000;$fatal(1,"Analysis raster timeout");end
endmodule
