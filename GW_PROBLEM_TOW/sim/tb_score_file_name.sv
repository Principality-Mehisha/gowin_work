`timescale 1ns/1ps
module tb_score_file_name;
    reg [7:0] track=0;
    wire [87:0] file_name;
    wire marimba, numbered;
    reg passed=0;
    reg [87:0] expected_name;
    integer kind, number, digit;
    score_file_name dut(.*);
    initial begin
        for(kind=1;kind<=2;kind=kind+1)
            for(number=1;number<=100;number=number+1) begin
                track=number+(kind==1 ? 3 : 103);
                expected_name=kind==1 ? "PN000   BIN" : "MB000   BIN";
                expected_name[71:64]="0"+number/100;
                expected_name[63:56]="0"+(number/10)%10;
                expected_name[55:48]="0"+number%10;
                #1;
                if(file_name!==expected_name || !numbered || marimba!=(kind==2))
                    $fatal(1,"Name mapping track=%0d got=%s expected=%s",track,file_name,expected_name);
            end
        track=1;#1;if(file_name!="ANDROID BIN" || !marimba || numbered)$fatal(1,"Legacy Android");
        track=2;#1;if(file_name!="RINGTONEBIN" || !marimba || numbered)$fatal(1,"Legacy ringtone");
        track=3;#1;if(file_name!="PIANO   BIN" || marimba || numbered)$fatal(1,"Legacy piano");
        passed=1;$display("PASS: 200 numbered names and legacy mappings");$finish;
    end
endmodule
