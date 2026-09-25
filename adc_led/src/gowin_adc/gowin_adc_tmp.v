//Copyright (C)2014-2026 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.12.03 (64-bit)
//IP Version: 1.1
//Part Number: GW5AT-LV60PG484AC1/I0
//Device: GW5AT-60
//Device Version: B
//Created Time: Fri Sep 25 23:24:36 2026

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    Gowin_ADC your_instance_name(
        .adcrdy(adcrdy), //output adcrdy
        .adcvalue(adcvalue), //output [13:0] adcvalue
        .mdrp_rdata(mdrp_rdata), //output [7:0] mdrp_rdata
        .adcmode(adcmode), //input adcmode
        .vsenctl(vsenctl), //input [2:0] vsenctl
        .clk(clk), //input clk
        .drstn(drstn), //input drstn
        .adcreqi(adcreqi), //input adcreqi
        .mdrp_clk(mdrp_clk), //input mdrp_clk
        .mdrp_wdata(mdrp_wdata), //input [7:0] mdrp_wdata
        .mdrp_a_inc(mdrp_a_inc), //input mdrp_a_inc
        .mdrp_opcode(mdrp_opcode) //input [1:0] mdrp_opcode
    );

//--------Copy end-------------------
