`timescale 1ns/1ps
module tb_tjc_status;
 reg clk=0,rst_n=0,valid=0,passed=0;
 reg [71:0] snapshot=0;
 wire ready,byte_valid;
 wire [7:0] data;
 reg [3:0] cycle=0;
 wire byte_ready=cycle[1];
 always #10 clk=~clk;
 always @(posedge clk) cycle<=cycle+1'b1;
 tjc_status_tx dut (.clk(clk),.rst_n(rst_n),.snapshot(snapshot),.valid(valid),.ready(ready),
  .byte_data(data),.byte_valid(byte_valid),.byte_ready(byte_ready));
 string expected[0:87];
 string line="",expected_line;
 integer fields[0:7];
 integer field=0,ff=0,packets=0,fences=0,n;
 reg stalled=0;
 reg [7:0] held;
 always @(posedge clk) if(rst_n) begin
  if(stalled && (!byte_valid || data!==held)) $fatal(1,"TX byte changed under backpressure");
  stalled=byte_valid && !byte_ready;held=data;
  if(byte_valid && byte_ready) begin
   if(data==8'hff) begin
    ff=ff+1;
    if(ff==3) begin
     if(line=="") fences=fences+1;
     else begin
      if(field==9) begin
       if(n/88==1) expected_line={"every.tInstrument.txt=\"",64'hc2edc1d6b0cdc7d9,"\""};
       else expected_line={"every.tInstrument.txt=\"",32'hb8d6c7d9,"\""};
      end
      else if(field==8) expected_line={"every.tNote.txt=\"",expected[n%88],"\""};
      else expected_line=$sformatf("page0.n%0d.val=%0d",field,fields[field]);
      if(line!=expected_line) $fatal(1,"Packet %0d field %0d: got %s expected %s",n,field,line,expected_line);
      if(field==9) begin field=0;packets=packets+1;end
      else field=field+1;
     end
     ff=0;line="";
    end
   end else begin
    if(ff) $fatal(1,"Incomplete FF terminator");
    line={line,$sformatf("%c",data)};
   end
  end
 end
 initial begin
  for(n=0;n<88;n=n+1)begin
   case((n+21)%12)
    0:expected[n]="C";1:expected[n]="C#";2:expected[n]="D";3:expected[n]="D#";
    4:expected[n]="E";5:expected[n]="F";6:expected[n]="F#";7:expected[n]="G";
    8:expected[n]="G#";9:expected[n]="A";10:expected[n]="A#";11:expected[n]="B";
   endcase
   expected[n]={expected[n],$sformatf("%0d",(n+21)/12-1)};
  end
  repeat(4)@(negedge clk);rst_n=1;
  for(n=0;n<176;n=n+1) begin
   fields[0]=n%5;fields[1]=n%4;fields[2]=0;fields[3]=0;fields[4]=(255-n)&255;fields[5]='h41;
   fields[6]=n%4;fields[7]=n%101;
   wait(ready);@(negedge clk);
   snapshot={8'(fields[6]),8'(fields[7]),1'(n/88==1),7'(n%88),8'(fields[0]),8'(fields[1]),8'd0,8'd0,8'(fields[4]),8'h41};valid=1;
   @(negedge clk);valid=0;snapshot='1;
   // Input changes during byte transmission must not affect this snapshot.
   wait(packets==n+1);@(negedge clk);
  end
  if(fences!=176) $fatal(1,"Each snapshot needs an initial command fence");
  passed=1;$display("PASS TJC status: all 88 note names for both GB2312 instruments, numeric fields, FF fences, backpressure and atomic snapshots");$finish;
 end
 initial begin #10000000;$fatal(1,"TJC status timeout");end
endmodule
