//Copyright (C)2014-2026 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.12.03 (64-bit)
//Part Number: GW5AT-LV60PG484AC1/I0
//Device: GW5AT-60
//Device Version: B
//Created Time: Tue Nov  3 02:53:12 2026

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	Gowin_Audio_FIFO32 your_instance_name(
		.Data(Data), //input [31:0] Data
		.WrReset(WrReset), //input WrReset
		.RdReset(RdReset), //input RdReset
		.WrClk(WrClk), //input WrClk
		.RdClk(RdClk), //input RdClk
		.WrEn(WrEn), //input WrEn
		.RdEn(RdEn), //input RdEn
		.Almost_Full(Almost_Full), //output Almost_Full
		.Q(Q), //output [31:0] Q
		.Empty(Empty), //output Empty
		.Full(Full) //output Full
	);

//--------Copy end-------------------
