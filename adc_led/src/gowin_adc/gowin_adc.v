//Copyright (C)2014-2026 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//Tool Version: V1.9.12.03 (64-bit)
//IP Version: 1.1
//Part Number: GW5AT-LV60PG484AC1/I0
//Device: GW5AT-60
//Device Version: B
//Created Time: Fri Sep 25 23:24:36 2026

module Gowin_ADC (adcrdy, adcvalue, mdrp_rdata, adcmode, vsenctl, clk, drstn, adcreqi, mdrp_clk, mdrp_wdata, mdrp_a_inc, mdrp_opcode);

output adcrdy;
output [13:0] adcvalue;
output [7:0] mdrp_rdata;
input adcmode;
input [2:0] vsenctl;
input clk;
input drstn;
input adcreqi;
input mdrp_clk;
input [7:0] mdrp_wdata;
input mdrp_a_inc;
input [1:0] mdrp_opcode;

wire adceno;
wire adc1bit;
wire adcclko;
wire [12:0] adcbit;
wire clko;
wire eoc;
wire gw_vcc;
wire gw_gnd;

assign gw_vcc = 1'b1;
assign gw_gnd = 1'b0;

ADC_SAR adc_sar_inst (
    .ADCENO(adceno),
    .ADCRDY(adcrdy),
    .ADCVALUE(adcvalue),
    .MDRP_RDATA(mdrp_rdata),
    .ADC1BIT(adc1bit),
    .ADCCLKO(adcclko),
    .ADCBIT(adcbit),
    .CLKO(clko),
    .EOC(eoc),
    .ADCMODE(adcmode),
    .VSENCTL(vsenctl),
    .CLK(clk),
    .DRSTN(drstn),
    .ADCREQI(adcreqi),
    .MDRP_CLK(mdrp_clk),
    .MDRP_WDATA(mdrp_wdata),
    .MDRP_A_INC(mdrp_a_inc),
    .MDRP_OPCODE(mdrp_opcode),
    .ADCENI(gw_vcc),
    .CLKI(gw_gnd),
    .CHEN({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
    .RSTN(gw_gnd),
    .SOC(gw_gnd)
);

defparam adc_sar_inst.BUF_EN = 29'b00000000010000000000010001001;
defparam adc_sar_inst.CLK_SEL = 1'b1;
defparam adc_sar_inst.DIV_CTL = 2'd3;
defparam adc_sar_inst.ADC_EN_SEL = 1'b0;
defparam adc_sar_inst.PHASE_SEL = 1'b0;
defparam adc_sar_inst.CSR_ADC_MODE = 1'b1;
defparam adc_sar_inst.CSR_VSEN_CTRL = 3'd0;
defparam adc_sar_inst.CSR_SAMPLE_CNT_SEL = 3'd4;
defparam adc_sar_inst.CSR_RATE_CHANGE_CTRL = 3'd5;
defparam adc_sar_inst.CSR_FSCAL = 10'd653;
defparam adc_sar_inst.CSR_OFFSET = 12'd0;

endmodule //Gowin_ADC
