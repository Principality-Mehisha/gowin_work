`timescale 1ns/1ps
module tb_ddr_player;
    reg passed=0;
    wire a,b;
    nocturne_sd_case #(.EXTERNAL_TABLES(1)) fat16(a);
    nocturne_sd_case #(.EXTERNAL_TABLES(1),.PROFILE(2),.IMAGE("output/nocturne/fat32.hex")) fat32(b);
    initial begin
        wait(a && b);passed=1;
        $display("PASS: actual player with DDR tables, delayed calibration, C45S FAT16/FAT32, UART stop/restart/instrument/reset and audio");$finish;
    end
    initial begin #100000000;$fatal(1,"DDR player timeout");end
endmodule
