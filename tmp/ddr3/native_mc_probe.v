`timescale 1ns/1ps
module native_mc_probe(input clk,reset,input [2:0] cmd,input cmd_en,
input [28:0] addr,input [127:0] wr_data,input wr_data_en,wr_data_end,
input [15:0] wr_data_mask, output cmd_ready,wr_data_rdy,send_wr);
wire GND;
wire [15:0] IO_ddr_dq;
wire [1:0] IO_ddr_dqs;
wire [1:0] IO_ddr_dqs_n;
wire [14:0] O_ddr_addr;
wire [2:0] O_ddr_ba;
wire O_ddr_cas_n;
wire O_ddr_cke;
wire O_ddr_clk;
wire O_ddr_clk_n;
wire O_ddr_cs_n;
wire [1:0] O_ddr_dqm;
wire O_ddr_odt;
wire O_ddr_ras_n;
wire O_ddr_reset_n;
wire O_ddr_we_n;
wire VCC;
wire burst;
wire clk_out;
wire ddr_rst;
wire init_calib_complete;
wire memory_clk;
wire pll_lock;
wire pll_stop;
wire [127:0] rd_data;
wire rd_data_end;
wire rd_data_valid;
wire ref_ack;
wire ref_req;
wire rst_n;
wire sr_ack;
wire sr_req;
wire \gw3_top/full ;
wire \gw3_top/init_complete_r ;
wire \gw3_top/phy_rd_data_valid ;
wire \gw3_top/eye_app_cmd_en_Z ;
wire \gw3_top/eye_app_wdf_wren_Z ;
wire \gw3_top/eye_calib_start_Z ;
wire \gw3_top/ddr_init_internal ;
wire [3:2] \gw3_top/mc_ras_n_Z ;
wire [3:2] \gw3_top/mc_cas_n_Z ;
wire [3:2] \gw3_top/mc_we_n_Z ;
wire [54:30] \gw3_top/mc_address_Z ;
wire [11:6] \gw3_top/mc_bank_Z ;
wire [3:2] \gw3_top/mc_cs_n_Z ;
wire [1:1] \gw3_top/mc_odt_Z ;
wire [3:3] \gw3_top/mc_cke_Z ;
wire [127:0] \gw3_top/mc_wrdata ;
wire [15:0] \gw3_top/mc_wrdata_mask_Z ;
wire [127:0] \gw3_top/eye_calib_rdata ;
wire [127:67] \gw3_top/eye_app_wdf_wdata_Z ;
wire [0:0] \gw3_top/eye_app_cmd_Z ;
wire [12:3] \gw3_top/eye_app_addr_Z ;
wire \gw3_top/u_gwmc_top/n8_4 ;
wire \gw3_top/u_gwmc_top/n11_3 ;
wire \gw3_top/u_gwmc_top/n35_3 ;
wire \gw3_top/u_gwmc_top/n36_3 ;
wire \gw3_top/u_gwmc_top/n37_3 ;
wire \gw3_top/u_gwmc_top/n41_3 ;
wire \gw3_top/u_gwmc_top/n42_3 ;
wire \gw3_top/u_gwmc_top/n43_3 ;
wire \gw3_top/u_gwmc_top/n44_3 ;
wire \gw3_top/u_gwmc_top/n113_3 ;
wire \gw3_top/u_gwmc_top/n40_7 ;
wire \gw3_top/u_gwmc_top/n39_7 ;
wire \gw3_top/u_gwmc_top/n38_7 ;
wire \gw3_top/u_gwmc_top/n34_7 ;
wire \gw3_top/u_gwmc_top/n33_7 ;
wire \gw3_top/u_gwmc_top/n32_7 ;
wire \gw3_top/u_gwmc_top/n31_7 ;
wire \gw3_top/u_gwmc_top/n30_7 ;
wire \gw3_top/u_gwmc_top/n29_7 ;
wire \gw3_top/u_gwmc_top/n28_7 ;
wire \gw3_top/u_gwmc_top/n27_7 ;
wire \gw3_top/u_gwmc_top/n26_7 ;
wire \gw3_top/u_gwmc_top/n25_7 ;
wire \gw3_top/u_gwmc_top/n24_7 ;
wire \gw3_top/u_gwmc_top/n23_7 ;
wire \gw3_top/u_gwmc_top/n22_7 ;
wire \gw3_top/u_gwmc_top/n21_7 ;
wire \gw3_top/u_gwmc_top/n20_7 ;
wire \gw3_top/u_gwmc_top/n9_7 ;
wire \gw3_top/u_gwmc_top/n10_7 ;
wire \gw3_top/u_gwmc_top/n45_7 ;
wire \gw3_top/u_gwmc_top/n46_7 ;
wire \gw3_top/u_gwmc_top/n47_7 ;
wire \gw3_top/u_gwmc_top/eye_calib_start_addr ;
wire \gw3_top/u_gwmc_top/app_en ;
wire \gw3_top/u_gwmc_top/eye_calib_start_cmd ;
wire \gw3_top/u_gwmc_top/cmd_empty_Z ;
wire \gw3_top/u_gwmc_top/mem_RAMOUT_175_G[0]_2 ;
wire \gw3_top/u_gwmc_top/mem_RAMOUT_182_G[0]_2 ;
wire \gw3_top/u_gwmc_top/mem_RAMOUT_189_G[0]_2 ;
wire \gw3_top/u_gwmc_top/mem_RAMOUT_0_G[0]_4 ;
wire \gw3_top/u_gwmc_top/mem_RAMOUT_7_G[0]_4 ;
wire \gw3_top/u_gwmc_top/mem_RAMOUT_14_G[0]_4 ;
wire \gw3_top/u_gwmc_top/mem_RAMOUT_21_G[0]_4 ;
wire \gw3_top/u_gwmc_top/mem_RAMOUT_28_G[0]_4 ;
wire \gw3_top/u_gwmc_top/mem_RAMOUT_35_G[0]_4 ;
wire \gw3_top/u_gwmc_top/mem_RAMOUT_42_G[0]_4 ;
wire \gw3_top/u_gwmc_top/mem_RAMOUT_49_G[0]_4 ;
wire \gw3_top/u_gwmc_top/mem_RAMOUT_56_G[0]_4 ;
wire \gw3_top/u_gwmc_top/mem_RAMOUT_63_G[0]_4 ;
wire \gw3_top/u_gwmc_top/mem_RAMOUT_70_G[0]_4 ;
wire \gw3_top/u_gwmc_top/mem_RAMOUT_77_G[0]_4 ;
wire \gw3_top/u_gwmc_top/mem_RAMOUT_84_G[0]_4 ;
wire \gw3_top/u_gwmc_top/mem_RAMOUT_91_G[0]_4 ;
wire \gw3_top/u_gwmc_top/mem_RAMOUT_98_G[0]_4 ;
wire \gw3_top/u_gwmc_top/mem_RAMOUT_105_G[0]_4 ;
wire \gw3_top/u_gwmc_top/mem_RAMOUT_112_G[0]_4 ;
wire \gw3_top/u_gwmc_top/mem_RAMOUT_119_G[0]_4 ;
wire \gw3_top/u_gwmc_top/mem_RAMOUT_126_G[0]_4 ;
wire \gw3_top/u_gwmc_top/mem_RAMOUT_133_G[0]_4 ;
wire \gw3_top/u_gwmc_top/mem_RAMOUT_140_G[0]_4 ;
wire \gw3_top/u_gwmc_top/mem_RAMOUT_147_G[0]_4 ;
wire \gw3_top/u_gwmc_top/mem_RAMOUT_154_G[0]_4 ;
wire \gw3_top/u_gwmc_top/mem_RAMOUT_161_G[0]_4 ;
wire \gw3_top/u_gwmc_top/mem_RAMOUT_168_G[0]_4 ;
wire \gw3_top/u_gwmc_top/mem_RAMOUT_196_G[0]_4 ;
wire \gw3_top/u_gwmc_top/mem_RAMOUT_203_G[0]_4 ;
wire \gw3_top/u_gwmc_top/mem_RAMOUT_210_G[0]_4 ;
wire \gw3_top/u_gwmc_top/mem_RAMOUT_217_G[0]_4 ;
wire \gw3_top/u_gwmc_top/cmd_write_Z ;
wire \gw3_top/u_gwmc_top/cmd_read_Z ;
wire \gw3_top/u_gwmc_top/send_zqcs_Z ;
wire \gw3_top/u_gwmc_top/idle1 ;
wire \gw3_top/u_gwmc_top/idle2 ;
wire \gw3_top/u_gwmc_top/idle3 ;
wire \gw3_top/u_gwmc_top/send_wr ;
wire \gw3_top/u_gwmc_top/send_rd ;
wire \gw3_top/u_gwmc_top/send_pre_Z ;
wire \gw3_top/u_gwmc_top/pre_all_Z ;
wire \gw3_top/u_gwmc_top/send_ref_Z ;
wire \gw3_top/u_gwmc_top/send_sre_Z ;
wire \gw3_top/u_gwmc_top/cke_set_Z ;
wire \gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_WRITE ;
wire \gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_READ ;
wire \gw3_top/u_gwmc_top/cmd_accept_ref_Z_3 ;
wire \gw3_top/u_gwmc_top/cmd_accept_sre_Z ;
wire \gw3_top/u_gwmc_top/cmd_accept_ref_Z ;
wire \gw3_top/u_gwmc_top/cmd_accept_Z ;
wire \gw3_top/u_gwmc_top/refresh_request_Z ;
wire \gw3_top/u_gwmc_top/sre_request_Z ;
wire [2:0] \gw3_top/u_gwmc_top/app_cmd ;
wire [27:0] \gw3_top/u_gwmc_top/app_addr ;
wire [3:2] \gw3_top/u_gwmc_top/mc_ras_n_dly ;
wire [3:2] \gw3_top/u_gwmc_top/mc_cas_n_dly ;
wire [3:2] \gw3_top/u_gwmc_top/mc_we_n_dly ;
wire [54:30] \gw3_top/u_gwmc_top/mc_address_dly ;
wire [11:6] \gw3_top/u_gwmc_top/mc_bank_dly ;
wire [3:2] \gw3_top/u_gwmc_top/mc_cs_n_dly ;
wire [1:1] \gw3_top/u_gwmc_top/mc_odt_dly ;
wire [3:3] \gw3_top/u_gwmc_top/mc_cke_dly ;
wire [0:0] \gw3_top/u_gwmc_top/act_shift_reg ;
wire [2:0] \gw3_top/u_gwmc_top/bank_d ;
wire [14:0] \gw3_top/u_gwmc_top/row_d ;
wire [9:0] \gw3_top/u_gwmc_top/col_d ;
wire [127:0] \gw3_top/u_gwmc_top/mc_wrdata_dly ;
wire [15:0] \gw3_top/u_gwmc_top/mc_wrdata_mask_dly ;
wire [11:6] \gw3_top/u_gwmc_top/mc_bank_out ;
wire [54:30] \gw3_top/u_gwmc_top/mc_address_out ;
wire [2:2] \gw3_top/u_gwmc_top/mc_ras_n_out ;
wire [2:2] \gw3_top/u_gwmc_top/mc_cas_n_out ;
wire [3:2] \gw3_top/u_gwmc_top/mc_we_n_out ;
wire [21:21] \gw3_top/u_gwmc_top/cmd3 ;
wire [3:2] \gw3_top/u_gwmc_top/mc_cs_n_out ;
wire [0:0] \gw3_top/u_gwmc_top/mc_odt_out ;
wire [3:3] \gw3_top/u_gwmc_top/mc_cke_out ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_178_G[2]_1 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_179_G[2]_1 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_180_G[2]_1 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_181_G[2]_1 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_185_G[2]_1 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_186_G[2]_1 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_187_G[2]_1 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_188_G[2]_1 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_192_G[2]_1 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_193_G[2]_1 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_194_G[2]_1 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_195_G[2]_1 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n468_20 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n468_21 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n468_22 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n468_23 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n469_20 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n469_21 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n469_22 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n469_23 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n470_20 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n470_21 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n470_22 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n470_23 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n471_20 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n471_21 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n471_22 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n471_23 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n472_20 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n472_21 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n472_22 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n472_23 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n473_20 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n473_21 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n473_22 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n473_23 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n474_20 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n474_21 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n474_22 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n474_23 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n475_20 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n475_21 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n475_22 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n475_23 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n476_20 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n476_21 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n476_22 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n476_23 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n477_20 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n477_21 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n477_22 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n477_23 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n478_20 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n478_21 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n478_22 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n478_23 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n479_20 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n479_21 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n479_22 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n479_23 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n480_20 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n480_21 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n480_22 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n480_23 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n481_20 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n481_21 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n481_22 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n481_23 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n482_20 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n482_21 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n482_22 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n482_23 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_3_G[2]_9 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_3_G[2]_10 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_3_G[2]_11 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_3_G[2]_12 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_10_G[2]_9 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_10_G[2]_10 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_10_G[2]_11 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_10_G[2]_12 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_17_G[2]_9 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_17_G[2]_10 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_17_G[2]_11 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_17_G[2]_12 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_24_G[2]_9 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_24_G[2]_10 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_24_G[2]_11 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_24_G[2]_12 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_31_G[2]_9 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_31_G[2]_10 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_31_G[2]_11 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_31_G[2]_12 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_38_G[2]_9 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_38_G[2]_10 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_38_G[2]_11 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_38_G[2]_12 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_45_G[2]_9 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_45_G[2]_10 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_45_G[2]_11 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_45_G[2]_12 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_52_G[2]_9 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_52_G[2]_10 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_52_G[2]_11 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_52_G[2]_12 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_59_G[2]_9 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_59_G[2]_10 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_59_G[2]_11 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_59_G[2]_12 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_66_G[2]_9 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_66_G[2]_10 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_66_G[2]_11 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_66_G[2]_12 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_73_G[2]_9 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_73_G[2]_10 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_73_G[2]_11 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_73_G[2]_12 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_80_G[2]_9 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_80_G[2]_10 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_80_G[2]_11 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_80_G[2]_12 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_87_G[2]_9 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_87_G[2]_10 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_87_G[2]_11 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_87_G[2]_12 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_94_G[2]_9 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_94_G[2]_10 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_94_G[2]_11 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_94_G[2]_12 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_101_G[2]_9 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_101_G[2]_10 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_101_G[2]_11 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_101_G[2]_12 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_108_G[2]_9 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_108_G[2]_10 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_108_G[2]_11 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_108_G[2]_12 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_115_G[2]_9 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_115_G[2]_10 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_115_G[2]_11 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_115_G[2]_12 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_122_G[2]_9 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_122_G[2]_10 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_122_G[2]_11 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_122_G[2]_12 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_129_G[2]_9 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_129_G[2]_10 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_129_G[2]_11 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_129_G[2]_12 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_136_G[2]_9 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_136_G[2]_10 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_136_G[2]_11 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_136_G[2]_12 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_143_G[2]_9 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_143_G[2]_10 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_143_G[2]_11 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_143_G[2]_12 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_150_G[2]_9 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_150_G[2]_10 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_150_G[2]_11 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_150_G[2]_12 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_157_G[2]_9 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_157_G[2]_10 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_157_G[2]_11 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_157_G[2]_12 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_164_G[2]_9 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_164_G[2]_10 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_164_G[2]_11 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_164_G[2]_12 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_171_G[2]_9 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_171_G[2]_10 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_171_G[2]_11 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_171_G[2]_12 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_199_G[2]_9 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_199_G[2]_10 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_199_G[2]_11 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_199_G[2]_12 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_206_G[2]_9 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_206_G[2]_10 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_206_G[2]_11 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_206_G[2]_12 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_213_G[2]_9 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_213_G[2]_10 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_213_G[2]_11 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_213_G[2]_12 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_220_G[2]_9 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_220_G[2]_10 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_220_G[2]_11 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_220_G[2]_12 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n41_3 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n183_3 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n218_3 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n253_3 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n289_3 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n324_3 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n360_3 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n396_3 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n433_3 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/write ;
wire \gw3_top/u_gwmc_top/gw_cmd0/read ;
wire \gw3_top/u_gwmc_top/gw_cmd0/cmd_empty_5 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_335 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_337 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_339 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_341 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_343 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_345 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_347 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_349 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n34_6 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n75_7 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n41_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n183_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n218_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n253_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n360_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/write_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/cmd_empty_6 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/cmd_empty_7 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/cmd_empty_8 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_353 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_355 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/next_waddr_0_15 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n510_5 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/next_raddr_0_12 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/full_invalid_10 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/full_rr ;
wire \gw3_top/u_gwmc_top/gw_cmd0/full_r ;
wire \gw3_top/u_gwmc_top/gw_cmd0/full_invalid ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[0]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[1]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[2]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[3]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[4]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[5]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[6]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[7]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[8]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[9]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[10]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[11]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[12]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[13]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[14]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[15]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[16]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[17]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[18]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[19]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[20]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[21]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[22]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[23]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[24]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[25]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[26]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[27]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[28]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[29]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[30]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[31]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[0]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[1]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[2]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[3]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[4]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[5]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[6]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[7]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[8]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[9]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[10]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[11]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[12]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[13]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[14]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[15]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[16]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[17]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[18]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[19]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[20]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[21]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[22]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[23]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[24]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[25]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[26]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[27]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[28]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[29]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[30]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[31]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[0]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[1]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[2]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[3]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[4]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[5]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[6]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[7]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[8]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[9]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[10]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[11]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[12]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[13]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[14]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[15]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[16]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[17]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[18]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[19]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[20]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[21]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[22]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[23]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[24]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[25]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[26]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[27]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[28]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[29]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[30]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[31]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[0]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[1]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[2]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[3]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[4]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[5]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[6]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[7]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[8]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[9]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[10]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[11]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[12]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[13]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[14]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[15]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[16]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[17]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[18]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[19]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[20]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[21]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[22]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[23]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[24]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[25]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[26]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[27]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[28]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[29]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[30]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[31]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[0]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[1]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[2]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[3]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[4]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[5]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[6]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[7]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[8]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[9]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[10]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[11]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[12]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[13]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[14]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[15]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[16]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[17]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[18]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[19]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[20]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[21]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[22]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[23]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[24]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[25]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[26]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[27]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[28]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[29]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[30]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[31]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[0]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[1]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[2]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[3]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[4]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[5]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[6]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[7]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[8]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[9]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[10]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[11]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[12]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[13]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[14]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[15]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[16]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[17]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[18]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[19]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[20]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[21]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[22]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[23]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[24]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[25]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[26]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[27]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[28]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[29]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[30]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[31]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[0]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[1]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[2]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[3]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[4]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[5]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[6]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[7]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[8]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[9]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[10]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[11]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[12]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[13]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[14]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[15]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[16]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[17]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[18]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[19]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[20]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[21]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[22]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[23]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[24]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[25]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[26]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[27]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[28]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[29]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[30]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[31]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[0]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[1]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[2]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[3]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[4]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[5]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[6]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[7]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[8]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[9]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[10]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[11]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[12]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[13]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[14]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[15]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[16]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[17]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[18]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[19]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[20]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[21]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[22]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[23]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[24]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[25]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[26]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[27]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[28]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[29]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[30]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[31]_4 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n29_0_SUM ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n29_3 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n28_0_SUM ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n28_3 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n27_2 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n27_0_COUT ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n17_1_SUM ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n17_3 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n18_1_SUM ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n18_3 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n19_1_SUM ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n19_3 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n464_1_SUM ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n464_3 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n465_1_SUM ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n465_3 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n466_1_SUM ;
wire \gw3_top/u_gwmc_top/gw_cmd0/bank_change ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n483_1_SUM ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n483_3 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n484_1_SUM ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n484_3 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n485_1_SUM ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n485_3 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n486_1_SUM ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n486_3 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n487_1_SUM ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n487_3 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n488_1_SUM ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n488_3 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n489_1_SUM ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n489_3 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n490_1_SUM ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n490_3 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n491_1_SUM ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n491_3 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n492_1_SUM ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n492_3 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n493_1_SUM ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n493_3 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n494_1_SUM ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n494_3 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n495_1_SUM ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n495_3 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n496_1_SUM ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n496_3 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n497_1_SUM ;
wire \gw3_top/u_gwmc_top/gw_cmd0/row_change ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_176_G[1]_2 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_177_G[1]_2 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_183_G[1]_2 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_184_G[1]_2 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_190_G[1]_2 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_191_G[1]_2 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n468_25 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n468_27 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n469_25 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n469_27 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n470_25 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n470_27 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n471_25 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n471_27 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n472_25 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n472_27 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n473_25 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n473_27 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n474_25 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n474_27 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n475_25 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n475_27 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n476_25 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n476_27 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n477_25 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n477_27 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n478_25 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n478_27 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n479_25 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n479_27 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n480_25 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n480_27 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n481_25 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n481_27 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n482_25 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n482_27 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_3_G[2]_14 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_3_G[2]_16 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_10_G[2]_14 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_10_G[2]_16 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_17_G[2]_14 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_17_G[2]_16 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_24_G[2]_14 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_24_G[2]_16 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_31_G[2]_14 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_31_G[2]_16 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_38_G[2]_14 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_38_G[2]_16 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_45_G[2]_14 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_45_G[2]_16 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_52_G[2]_14 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_52_G[2]_16 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_59_G[2]_14 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_59_G[2]_16 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_66_G[2]_14 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_66_G[2]_16 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_73_G[2]_14 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_73_G[2]_16 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_80_G[2]_14 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_80_G[2]_16 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_87_G[2]_14 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_87_G[2]_16 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_94_G[2]_14 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_94_G[2]_16 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_101_G[2]_14 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_101_G[2]_16 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_108_G[2]_14 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_108_G[2]_16 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_115_G[2]_14 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_115_G[2]_16 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_122_G[2]_14 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_122_G[2]_16 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_129_G[2]_14 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_129_G[2]_16 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_136_G[2]_14 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_136_G[2]_16 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_143_G[2]_14 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_143_G[2]_16 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_150_G[2]_14 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_150_G[2]_16 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_157_G[2]_14 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_157_G[2]_16 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_164_G[2]_14 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_164_G[2]_16 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_171_G[2]_14 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_171_G[2]_16 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_199_G[2]_14 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_199_G[2]_16 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_206_G[2]_14 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_206_G[2]_16 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_213_G[2]_14 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_213_G[2]_16 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_220_G[2]_14 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_220_G[2]_16 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n468_29 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n469_29 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n470_29 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n471_29 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n472_29 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n473_29 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n474_29 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n475_29 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n476_29 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n477_29 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n478_29 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n479_29 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n480_29 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n481_29 ;
wire \gw3_top/u_gwmc_top/gw_cmd0/n482_29 ;
wire [2:1] \gw3_top/u_gwmc_top/gw_cmd0/next_waddr ;
wire [2:1] \gw3_top/u_gwmc_top/gw_cmd0/next_raddr ;
wire [2:0] \gw3_top/u_gwmc_top/gw_cmd0/bank_in_tmp ;
wire [14:0] \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0] ;
wire [14:0] \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1] ;
wire [14:0] \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2] ;
wire [14:0] \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3] ;
wire [14:0] \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4] ;
wire [14:0] \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5] ;
wire [14:0] \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6] ;
wire [14:0] \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7] ;
wire [2:0] \gw3_top/u_gwmc_top/gw_cmd0/waddr ;
wire [2:0] \gw3_top/u_gwmc_top/gw_cmd0/raddr ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n951_20 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n951_21 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n951_22 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n951_23 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n60_3 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n119_3 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n340_4 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n345_3 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_3 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2076_3 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2089_3 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_satisfied_8 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_7_8 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_6_8 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_5_8 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_4_8 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_3_8 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_2_8 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_1_8 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_0_8 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SRE_57 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_74 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_74 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_74 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_61 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ZQ_59 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SREI_59 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_WR_70 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_RD_71 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_W2R_60 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2AW_59 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2AR_58 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_R2W_60 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_59 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AR_58 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2WR_59 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2REF_57 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2SRE_57 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2RD_59 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2REF_57 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2SRE_57 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SRE_59 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SREE_55 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_POWERON_55 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1778_7 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1777_7 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n317_7 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n314_7 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n313_7 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n138_7 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n133_7 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n132_7 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n131_7 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n79_7 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n75_7 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n73_7 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n72_7 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2024_6 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2020_6 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n35_6 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n33_6 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n32_6 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n30_6 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n29_6 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1687_7 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1943_7 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1942_7 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1941_7 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1940_7 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1938_7 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1776_6 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n316_6 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n9_5 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n9_6 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n9_7 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n60_4 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n119_5 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n119_6 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/cmd_accept_sre_Z_3 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_one_bank_4 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_one_bank_5 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_4 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_6 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2076_4 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2076_5 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_7_9 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_7_9 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_3_9 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRP_cnt_1_9 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_4_9 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_4_10 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRCD_cnt_1_9 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTW_cnt_1_9 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTR_cnt_2_9 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRAS_cnt_2_9 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTP_cnt_1_9 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTP_cnt_2_9 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_62 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_63 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_64 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_75 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_76 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_76 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_77 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_75 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_76 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_77 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_78 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_65 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SREI_60 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SREI_61 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_WR_71 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_RD_72 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_W2R_61 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_W2R_62 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2AW_60 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2AW_61 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_R2W_61 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_61 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_62 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AR_59 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2WR_60 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2WR_62 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2RD_60 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1908_18 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n318_8 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n313_8 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n137_8 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n135_8 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n132_8 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n78_8 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n76_8 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n72_8 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n36_8 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n31_7 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1941_8 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1940_8 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1939_8 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1776_7 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n316_7 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_one_bank_6 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_7_10 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_67 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_77 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_78 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_79 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_80 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_78 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_79 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_80 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_81 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_81 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_82 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_83 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_68 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_69 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SREI_62 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_WR_72 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_WR_73 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_WR_74 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_RD_73 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_RD_74 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_W2R_65 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_63 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_64 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_81 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_84 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_85 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_86 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_WR_75 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_RD_75 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_66 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_68 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n119_8 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n136_10 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1939_10 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n340_8 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n340_10 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n60_7 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n77_10 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n9_9 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_7_12 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_72 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_84 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_84 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SREI_65 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_74 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2WR_65 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_W2R_67 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n74_10 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n76_10 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_9 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_11 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n315_10 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n318_10 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n32_9 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n34_8 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_W2R_69 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2AR_61 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_88 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_70 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_90 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2WR_67 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2084_5 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1757_5 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ZQ_62 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_86 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n36_10 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_one_bank ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1847_8 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1848_8 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n315_12 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n319_9 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n291_7 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n218_5 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n74_13 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt_9_14 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n77_13 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n78_11 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n80_10 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n81_10 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n134_11 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt_9_15 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n135_11 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n136_13 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n137_11 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n139_10 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n140_10 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n295_6 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n320_13 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_7_13 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1749_12 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1750_11 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1775_9 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_4_15 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1779_9 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1803_12 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1804_11 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1815_10 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1816_9 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1828_10 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1829_9 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1830_9 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1846_10 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRAS_cnt_2_15 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1861_10 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1862_9 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1874_9 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1875_10 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1876_10 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1937_9 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_7_17 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1944_10 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1908_21 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1909_16 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1910_18 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n134_15 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n31_9 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_satisfied ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_satisfied ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/init_done_r ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_cmd_read ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_cmd_write ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_satisfied ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_satisfied ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_REF ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ZQ ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_IDLE ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_SREI ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT_WR ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT_RD ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_W2R ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_WP2AW ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_WP2AR ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_R2W ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_RP2AW ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_RP2AR ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT2WR ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_WP2REF ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_WP2SRE ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT2RD ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_RP2REF ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_RP2SRE ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_SRE ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_SREE ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_POWERON ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_info_valid ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_st_ref ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n951_25 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n951_27 ;
wire \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n951_29 ;
wire [7:0] \gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt ;
wire [2:0] \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_bank ;
wire [14:0] \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row ;
wire [9:0] \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col ;
wire [4:1] \gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_shift_reg_0 ;
wire [9:0] \gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt ;
wire [9:0] \gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt ;
wire [7:0] \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt ;
wire [7:0] \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted ;
wire [4:0] \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt ;
wire [2:0] \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRAS_cnt ;
wire [7:0] \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt ;
wire [1:0] \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRP_cnt ;
wire [1:0] \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRCD_cnt ;
wire [1:0] \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTW_cnt ;
wire [2:0] \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTR_cnt ;
wire [1:0] \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTP_cnt ;
wire [2:0] \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTP_cnt ;
wire [2:0] \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tFAW_cnt ;
wire \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n34_3 ;
wire \gw3_top/u_gwmc_top/gwmc_timing_ctrl/sre_accepted_5 ;
wire \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n68_7 ;
wire \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n46_7 ;
wire \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n44_7 ;
wire \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n43_7 ;
wire \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n17_7 ;
wire \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n14_7 ;
wire \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n45_6 ;
wire \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n42_6 ;
wire \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n18_6 ;
wire \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n15_6 ;
wire \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n34_5 ;
wire \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n73_4 ;
wire \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n44_8 ;
wire \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n17_8 ;
wire \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n34_7 ;
wire \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n43_10 ;
wire \gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_request_7 ;
wire \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n16_9 ;
wire \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n73_6 ;
wire \gw3_top/u_gwmc_top/gwmc_timing_ctrl/rank_cnt_0_10 ;
wire \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n94_6 ;
wire \gw3_top/u_gwmc_top/gwmc_timing_ctrl/sre_accept ;
wire \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n47_7 ;
wire \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n19_7 ;
wire [5:0] \gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt ;
wire [5:0] \gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer ;
wire [0:0] \gw3_top/u_gwmc_top/gwmc_timing_ctrl/rank_cnt ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n458_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n459_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n460_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n461_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n462_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n463_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n464_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n465_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n466_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n467_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n468_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n469_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n470_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n471_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n472_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n473_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n491_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n492_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n494_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n495_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n496_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n498_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n499_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n500_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n501_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n503_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n504_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n505_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n524_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n525_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n526_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n527_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n528_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n529_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n530_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n531_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n532_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n533_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n534_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n535_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n536_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n537_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n538_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n539_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n557_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n558_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n560_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n561_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n564_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n565_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n567_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n569_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n571_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n572_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n590_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n591_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n592_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n593_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n594_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n595_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n596_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n597_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n598_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n599_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n600_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n601_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n602_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n603_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n604_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n605_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n623_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n624_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n626_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n627_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n628_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n630_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n631_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n632_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n633_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n635_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n636_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n637_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n656_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n657_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n658_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n659_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n660_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n661_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n662_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n663_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n664_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n665_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n666_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n667_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n668_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n669_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n670_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n671_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n689_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n690_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n692_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n693_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n696_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n697_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n699_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n701_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n703_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n704_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n756_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n722_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n723_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n724_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n725_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n726_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n727_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n728_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n729_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n730_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n731_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n732_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n733_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n734_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n735_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n736_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n737_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n691_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n559_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n694_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n562_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n695_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n563_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n698_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n566_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n700_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n568_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n702_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n570_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n625_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n493_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n629_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n497_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n634_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n502_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n638_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n506_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_wen ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/wr_wrbuf ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_full_r ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/n760_6 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_full ;
wire [8:0] \gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq ;
wire [143:0] \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n28_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n24_4 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wfull_val ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/awfull_val ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next_0_8 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_f_0_7 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wfull_val_4 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wfull_val_5 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next_3_8 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next_3_8 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wfull_val_6 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n641_8 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next_0_10 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rempty_val ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/Full ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wr_buf_empt ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wcnt_sub_0_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wcnt_sub_1_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wcnt_sub_2_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wcnt_sub_3_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wcnt_sub_4_0_COUT ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n652_1_SUM ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n652_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n653_1_SUM ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n653_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n654_1_SUM ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n654_3 ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n655_1_SUM ;
wire \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n655_3 ;
wire [4:1] \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next ;
wire [4:1] \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next ;
wire [3:0] \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_f ;
wire [3:0] \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_dly ;
wire [4:0] \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin ;
wire [4:0] \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin ;
wire [4:0] \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wcnt_sub ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n297_7 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n209_7 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n213_7 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n214_7 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n215_7 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n216_7 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n218_7 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n219_7 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n220_7 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n221_7 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n222_7 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n223_7 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n224_7 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n225_7 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n226_7 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n227_7 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n229_8 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n230_7 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n217_8 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n210_10 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n228_9 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n278_9 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n279_9 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n280_9 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n286_9 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n287_9 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n288_9 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n289_9 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n290_9 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n291_9 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n292_9 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n293_9 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n294_9 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n295_9 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/sent_col ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n411_10 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n217_10 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n209_10 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n212_9 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n211_9 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n210_12 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/sent_row ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cs_en2 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cs_en3 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/col_cmd_we ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/slot_0_read_5 ;
wire \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n298_8 ;
wire [0:0] \gw3_top/u_gwmc_top/gwmc_rank_ctrl/auxgen.mc_aux_out_r ;
wire [0:0] \gw3_top/u_gwmc_top/gwmc_rank_ctrl/auxgen.mc_aux_out_r_1 ;
wire [21:21] \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2 ;
wire \gw3_top/u_ddr_phy_top/n501_3 ;
wire \gw3_top/u_ddr_phy_top/n502_3 ;
wire \gw3_top/u_ddr_phy_top/n503_3 ;
wire \gw3_top/u_ddr_phy_top/n504_3 ;
wire \gw3_top/u_ddr_phy_top/n1454_3 ;
wire \gw3_top/u_ddr_phy_top/n106_4 ;
wire \gw3_top/u_ddr_phy_top/n108_8 ;
wire \gw3_top/u_ddr_phy_top/n238_9 ;
wire \gw3_top/u_ddr_phy_top/n235_9 ;
wire \gw3_top/u_ddr_phy_top/n234_9 ;
wire \gw3_top/u_ddr_phy_top/n232_9 ;
wire \gw3_top/u_ddr_phy_top/n231_9 ;
wire \gw3_top/u_ddr_phy_top/n230_9 ;
wire \gw3_top/u_ddr_phy_top/n227_9 ;
wire \gw3_top/u_ddr_phy_top/n226_9 ;
wire \gw3_top/u_ddr_phy_top/n224_9 ;
wire \gw3_top/u_ddr_phy_top/n223_9 ;
wire \gw3_top/u_ddr_phy_top/n222_9 ;
wire \gw3_top/u_ddr_phy_top/n221_9 ;
wire \gw3_top/u_ddr_phy_top/n217_9 ;
wire \gw3_top/u_ddr_phy_top/n216_9 ;
wire \gw3_top/u_ddr_phy_top/n215_9 ;
wire \gw3_top/u_ddr_phy_top/n214_9 ;
wire \gw3_top/u_ddr_phy_top/n213_9 ;
wire \gw3_top/u_ddr_phy_top/n209_9 ;
wire \gw3_top/u_ddr_phy_top/n208_9 ;
wire \gw3_top/u_ddr_phy_top/n207_9 ;
wire \gw3_top/u_ddr_phy_top/n205_9 ;
wire \gw3_top/u_ddr_phy_top/n204_9 ;
wire \gw3_top/u_ddr_phy_top/n202_9 ;
wire \gw3_top/u_ddr_phy_top/n200_9 ;
wire \gw3_top/u_ddr_phy_top/n199_9 ;
wire \gw3_top/u_ddr_phy_top/n197_9 ;
wire \gw3_top/u_ddr_phy_top/n196_9 ;
wire \gw3_top/u_ddr_phy_top/n194_9 ;
wire \gw3_top/u_ddr_phy_top/n192_9 ;
wire \gw3_top/u_ddr_phy_top/n191_9 ;
wire \gw3_top/u_ddr_phy_top/n188_9 ;
wire \gw3_top/u_ddr_phy_top/n187_9 ;
wire \gw3_top/u_ddr_phy_top/n185_9 ;
wire \gw3_top/u_ddr_phy_top/n183_9 ;
wire \gw3_top/u_ddr_phy_top/n180_9 ;
wire \gw3_top/u_ddr_phy_top/n179_9 ;
wire \gw3_top/u_ddr_phy_top/n177_9 ;
wire \gw3_top/u_ddr_phy_top/n175_9 ;
wire \gw3_top/u_ddr_phy_top/n172_9 ;
wire \gw3_top/u_ddr_phy_top/n171_9 ;
wire \gw3_top/u_ddr_phy_top/n168_9 ;
wire \gw3_top/u_ddr_phy_top/n167_9 ;
wire \gw3_top/u_ddr_phy_top/n164_9 ;
wire \gw3_top/u_ddr_phy_top/n163_9 ;
wire \gw3_top/u_ddr_phy_top/n160_9 ;
wire \gw3_top/u_ddr_phy_top/n159_9 ;
wire \gw3_top/u_ddr_phy_top/n158_9 ;
wire \gw3_top/u_ddr_phy_top/n157_9 ;
wire \gw3_top/u_ddr_phy_top/n154_9 ;
wire \gw3_top/u_ddr_phy_top/n153_9 ;
wire \gw3_top/u_ddr_phy_top/n150_9 ;
wire \gw3_top/u_ddr_phy_top/n149_9 ;
wire \gw3_top/u_ddr_phy_top/n146_9 ;
wire \gw3_top/u_ddr_phy_top/n145_9 ;
wire \gw3_top/u_ddr_phy_top/n141_9 ;
wire \gw3_top/u_ddr_phy_top/n139_9 ;
wire \gw3_top/u_ddr_phy_top/n137_9 ;
wire \gw3_top/u_ddr_phy_top/n135_9 ;
wire \gw3_top/u_ddr_phy_top/n133_9 ;
wire \gw3_top/u_ddr_phy_top/n131_9 ;
wire \gw3_top/u_ddr_phy_top/n129_9 ;
wire \gw3_top/u_ddr_phy_top/n127_9 ;
wire \gw3_top/u_ddr_phy_top/n126_9 ;
wire \gw3_top/u_ddr_phy_top/n124_9 ;
wire \gw3_top/u_ddr_phy_top/n122_9 ;
wire \gw3_top/u_ddr_phy_top/n120_9 ;
wire \gw3_top/u_ddr_phy_top/n118_9 ;
wire \gw3_top/u_ddr_phy_top/n116_9 ;
wire \gw3_top/u_ddr_phy_top/n114_9 ;
wire \gw3_top/u_ddr_phy_top/n112_9 ;
wire \gw3_top/u_ddr_phy_top/n15_9 ;
wire \gw3_top/u_ddr_phy_top/n19_9 ;
wire \gw3_top/u_ddr_phy_top/n23_9 ;
wire \gw3_top/u_ddr_phy_top/n27_9 ;
wire \gw3_top/u_ddr_phy_top/n16_9 ;
wire \gw3_top/u_ddr_phy_top/n37_8 ;
wire \gw3_top/u_ddr_phy_top/n39_8 ;
wire \gw3_top/u_ddr_phy_top/n42_8 ;
wire \gw3_top/u_ddr_phy_top/n44_8 ;
wire \gw3_top/u_ddr_phy_top/n47_8 ;
wire \gw3_top/u_ddr_phy_top/n48_8 ;
wire \gw3_top/u_ddr_phy_top/n239_8 ;
wire \gw3_top/u_ddr_phy_top/n240_8 ;
wire \gw3_top/u_ddr_phy_top/n241_8 ;
wire \gw3_top/u_ddr_phy_top/n242_8 ;
wire \gw3_top/u_ddr_phy_top/n243_8 ;
wire \gw3_top/u_ddr_phy_top/n244_8 ;
wire \gw3_top/u_ddr_phy_top/n245_8 ;
wire \gw3_top/u_ddr_phy_top/n246_8 ;
wire \gw3_top/u_ddr_phy_top/n247_8 ;
wire \gw3_top/u_ddr_phy_top/n248_8 ;
wire \gw3_top/u_ddr_phy_top/n249_8 ;
wire \gw3_top/u_ddr_phy_top/n250_8 ;
wire \gw3_top/u_ddr_phy_top/n251_8 ;
wire \gw3_top/u_ddr_phy_top/n252_8 ;
wire \gw3_top/u_ddr_phy_top/n253_8 ;
wire \gw3_top/u_ddr_phy_top/n254_8 ;
wire \gw3_top/u_ddr_phy_top/n237_8 ;
wire \gw3_top/u_ddr_phy_top/n236_8 ;
wire \gw3_top/u_ddr_phy_top/n233_8 ;
wire \gw3_top/u_ddr_phy_top/n229_8 ;
wire \gw3_top/u_ddr_phy_top/n228_8 ;
wire \gw3_top/u_ddr_phy_top/n225_8 ;
wire \gw3_top/u_ddr_phy_top/n220_8 ;
wire \gw3_top/u_ddr_phy_top/n219_8 ;
wire \gw3_top/u_ddr_phy_top/n218_8 ;
wire \gw3_top/u_ddr_phy_top/n212_8 ;
wire \gw3_top/u_ddr_phy_top/n211_8 ;
wire \gw3_top/u_ddr_phy_top/n210_8 ;
wire \gw3_top/u_ddr_phy_top/n206_8 ;
wire \gw3_top/u_ddr_phy_top/n203_8 ;
wire \gw3_top/u_ddr_phy_top/n201_8 ;
wire \gw3_top/u_ddr_phy_top/n198_8 ;
wire \gw3_top/u_ddr_phy_top/n195_8 ;
wire \gw3_top/u_ddr_phy_top/n193_8 ;
wire \gw3_top/u_ddr_phy_top/n190_8 ;
wire \gw3_top/u_ddr_phy_top/n189_8 ;
wire \gw3_top/u_ddr_phy_top/n186_8 ;
wire \gw3_top/u_ddr_phy_top/n184_8 ;
wire \gw3_top/u_ddr_phy_top/n182_8 ;
wire \gw3_top/u_ddr_phy_top/n181_8 ;
wire \gw3_top/u_ddr_phy_top/n178_8 ;
wire \gw3_top/u_ddr_phy_top/n176_8 ;
wire \gw3_top/u_ddr_phy_top/n174_8 ;
wire \gw3_top/u_ddr_phy_top/n173_8 ;
wire \gw3_top/u_ddr_phy_top/n170_8 ;
wire \gw3_top/u_ddr_phy_top/n169_8 ;
wire \gw3_top/u_ddr_phy_top/n166_8 ;
wire \gw3_top/u_ddr_phy_top/n165_8 ;
wire \gw3_top/u_ddr_phy_top/n162_8 ;
wire \gw3_top/u_ddr_phy_top/n161_8 ;
wire \gw3_top/u_ddr_phy_top/n156_8 ;
wire \gw3_top/u_ddr_phy_top/n155_8 ;
wire \gw3_top/u_ddr_phy_top/n152_8 ;
wire \gw3_top/u_ddr_phy_top/n151_8 ;
wire \gw3_top/u_ddr_phy_top/n148_8 ;
wire \gw3_top/u_ddr_phy_top/n147_8 ;
wire \gw3_top/u_ddr_phy_top/n144_8 ;
wire \gw3_top/u_ddr_phy_top/n143_8 ;
wire \gw3_top/u_ddr_phy_top/n142_8 ;
wire \gw3_top/u_ddr_phy_top/n140_8 ;
wire \gw3_top/u_ddr_phy_top/n138_8 ;
wire \gw3_top/u_ddr_phy_top/n136_8 ;
wire \gw3_top/u_ddr_phy_top/n134_8 ;
wire \gw3_top/u_ddr_phy_top/n132_8 ;
wire \gw3_top/u_ddr_phy_top/n130_8 ;
wire \gw3_top/u_ddr_phy_top/n128_8 ;
wire \gw3_top/u_ddr_phy_top/n125_8 ;
wire \gw3_top/u_ddr_phy_top/n123_8 ;
wire \gw3_top/u_ddr_phy_top/n121_8 ;
wire \gw3_top/u_ddr_phy_top/n119_8 ;
wire \gw3_top/u_ddr_phy_top/n117_8 ;
wire \gw3_top/u_ddr_phy_top/n115_8 ;
wire \gw3_top/u_ddr_phy_top/n113_8 ;
wire \gw3_top/u_ddr_phy_top/n111_8 ;
wire \gw3_top/u_ddr_phy_top/n99_8 ;
wire \gw3_top/u_ddr_phy_top/n98_8 ;
wire \gw3_top/u_ddr_phy_top/n97_8 ;
wire \gw3_top/u_ddr_phy_top/n94_8 ;
wire \gw3_top/u_ddr_phy_top/n64_8 ;
wire \gw3_top/u_ddr_phy_top/n63_8 ;
wire \gw3_top/u_ddr_phy_top/n62_8 ;
wire \gw3_top/u_ddr_phy_top/n61_8 ;
wire \gw3_top/u_ddr_phy_top/n60_8 ;
wire \gw3_top/u_ddr_phy_top/n59_8 ;
wire \gw3_top/u_ddr_phy_top/n58_8 ;
wire \gw3_top/u_ddr_phy_top/n57_8 ;
wire \gw3_top/u_ddr_phy_top/n56_8 ;
wire \gw3_top/u_ddr_phy_top/n55_8 ;
wire \gw3_top/u_ddr_phy_top/n54_8 ;
wire \gw3_top/u_ddr_phy_top/n53_8 ;
wire \gw3_top/u_ddr_phy_top/n52_8 ;
wire \gw3_top/u_ddr_phy_top/n51_8 ;
wire \gw3_top/u_ddr_phy_top/n50_8 ;
wire \gw3_top/u_ddr_phy_top/n49_8 ;
wire \gw3_top/u_ddr_phy_top/n106_6 ;
wire \gw3_top/u_ddr_phy_top/n96_5 ;
wire \gw3_top/u_ddr_phy_top/n95_5 ;
wire \gw3_top/u_ddr_phy_top/n46_5 ;
wire \gw3_top/u_ddr_phy_top/n45_5 ;
wire \gw3_top/u_ddr_phy_top/n43_5 ;
wire \gw3_top/u_ddr_phy_top/n41_5 ;
wire \gw3_top/u_ddr_phy_top/n40_5 ;
wire \gw3_top/u_ddr_phy_top/n38_5 ;
wire \gw3_top/u_ddr_phy_top/n36_5 ;
wire \gw3_top/u_ddr_phy_top/n30_5 ;
wire \gw3_top/u_ddr_phy_top/n26_5 ;
wire \gw3_top/u_ddr_phy_top/n22_5 ;
wire \gw3_top/u_ddr_phy_top/n18_5 ;
wire \gw3_top/u_ddr_phy_top/n17_5 ;
wire \gw3_top/u_ddr_phy_top/n14_6 ;
wire \gw3_top/u_ddr_phy_top/ddr_init_internal_rr ;
wire \gw3_top/u_ddr_phy_top/eye_calib_start_r ;
wire \gw3_top/u_ddr_phy_top/eye_calib_start_rr ;
wire \gw3_top/u_ddr_phy_top/mux_reset_n ;
wire \gw3_top/u_ddr_phy_top/ddr_init_st_r ;
wire \gw3_top/u_ddr_phy_top/ddr_init_st_rr ;
wire \gw3_top/u_ddr_phy_top/ddr_init_st_rrr ;
wire \gw3_top/u_ddr_phy_top/ddr_init_internal_r ;
wire \gw3_top/u_ddr_phy_top/dll_lock ;
wire \gw3_top/u_ddr_phy_top/n7_6 ;
wire \gw3_top/u_ddr_phy_top/n509_6 ;
wire \gw3_top/u_ddr_phy_top/n1437_6 ;
wire \gw3_top/u_ddr_phy_top/eye_calib_start_r_6 ;
wire \gw3_top/u_ddr_phy_top/eye_calib_valid ;
wire \gw3_top/u_ddr_phy_top/read_line3 ;
wire \gw3_top/u_ddr_phy_top/read_line2 ;
wire \gw3_top/u_ddr_phy_top/read_line1 ;
wire \gw3_top/u_ddr_phy_top/init_rmove_done_r ;
wire \gw3_top/u_ddr_phy_top/sys_reset_Z ;
wire \gw3_top/u_ddr_phy_top/if_fifo_rst_Z ;
wire \gw3_top/u_ddr_phy_top/rmove_left_done_Z ;
wire \gw3_top/u_ddr_phy_top/eye_calib_done_Z ;
wire \gw3_top/u_ddr_phy_top/eye_calib_rmove_Z ;
wire \gw3_top/u_ddr_phy_top/eye_calib_done_r ;
wire \gw3_top/u_ddr_phy_top/rmove_left_flag_Z ;
wire \gw3_top/u_ddr_phy_top/phy_reset_n ;
wire \gw3_top/u_ddr_phy_top/wrlvl_start ;
wire \gw3_top/u_ddr_phy_top/init_rmove_start_Z ;
wire \gw3_top/u_ddr_phy_top/wrlvl_complete_Z ;
wire \gw3_top/u_ddr_phy_top/phy_dqs ;
wire \gw3_top/u_ddr_phy_top/read_calibration_logic_gen[0].read_adj ;
wire \gw3_top/u_ddr_phy_top/read_calibration_logic_gen[1].read_adj ;
wire \gw3_top/u_ddr_phy_top/stop_d ;
wire \gw3_top/u_ddr_phy_top/pause ;
wire \gw3_top/u_ddr_phy_top/dll_rsti ;
wire \gw3_top/u_ddr_phy_top/ddr_init_st_Z ;
wire \gw3_top/u_ddr_phy_top/uddcntln ;
wire [3:0] \gw3_top/u_ddr_phy_top/mux_cs_n ;
wire [3:2] \gw3_top/u_ddr_phy_top/mux_ras_n ;
wire [3:2] \gw3_top/u_ddr_phy_top/mux_cas_n ;
wire [3:2] \gw3_top/u_ddr_phy_top/mux_we_n ;
wire [3:3] \gw3_top/u_ddr_phy_top/mux_cke ;
wire [59:29] \gw3_top/u_ddr_phy_top/mux_addr ;
wire [11:6] \gw3_top/u_ddr_phy_top/mux_bank ;
wire [1:1] \gw3_top/u_ddr_phy_top/mux_odt ;
wire [127:0] \gw3_top/u_ddr_phy_top/mux_wrdata ;
wire [15:0] \gw3_top/u_ddr_phy_top/mux_wrdata_mask ;
wire [1:0] \gw3_top/u_ddr_phy_top/rmove ;
wire [1:0] \gw3_top/u_ddr_phy_top/rdir ;
wire [1:1] \gw3_top/u_ddr_phy_top/wloadn ;
wire [2:0] \gw3_top/u_ddr_phy_top/stop_reg ;
wire [1:0] \gw3_top/u_ddr_phy_top/ddr_rsti_reg ;
wire [7:0] \gw3_top/u_ddr_phy_top/dll_step_base ;
wire [7:0] \gw3_top/u_ddr_phy_top/dll_step ;
wire [1:0] \gw3_top/u_ddr_phy_top/phy_rdbk_data_valid ;
wire [1:0] \gw3_top/u_ddr_phy_top/in_dq0_Z ;
wire [0:0] \gw3_top/u_ddr_phy_top/RBURST ;
wire [0:0] \gw3_top/u_ddr_phy_top/rvalid_Z ;
wire [1:1] \gw3_top/u_ddr_phy_top/RBURST_0 ;
wire [1:1] \gw3_top/u_ddr_phy_top/rvalid_Z_0 ;
wire [1:0] \gw3_top/u_ddr_phy_top/init_rmove ;
wire [1:1] \gw3_top/u_ddr_phy_top/init_rdir ;
wire [15:0] \gw3_top/u_ddr_phy_top/realtime_dllcode_Z ;
wire [1:0] \gw3_top/u_ddr_phy_top/rdir_0 ;
wire [1:0] \gw3_top/u_ddr_phy_top/eye_rmove ;
wire [0:0] \gw3_top/u_ddr_phy_top/eye_calib_error_valid_Z ;
wire [1:0] \gw3_top/u_ddr_phy_top/eye_calib_error_Z ;
wire [1:1] \gw3_top/u_ddr_phy_top/phy_odt_d1 ;
wire [1:1] \gw3_top/u_ddr_phy_top/phy_odt_d2 ;
wire [3:3] \gw3_top/u_ddr_phy_top/phy_cas_n ;
wire [3:3] \gw3_top/u_ddr_phy_top/phy_ras_n ;
wire [3:3] \gw3_top/u_ddr_phy_top/phy_cs_n ;
wire [3:0] \gw3_top/u_ddr_phy_top/phy_we_n ;
wire [57:47] \gw3_top/u_ddr_phy_top/phy_addr ;
wire [10:9] \gw3_top/u_ddr_phy_top/phy_bank ;
wire [0:0] \gw3_top/u_ddr_phy_top/phy_cke ;
wire [15:0] \gw3_top/u_ddr_phy_top/wstep_Z ;
wire [5:0] \gw3_top/u_ddr_phy_top/rclk_sel ;
wire [7:0] \gw3_top/u_ddr_phy_top/read ;
wire [1:0] \gw3_top/u_ddr_phy_top/read_calib_rmove_Z ;
wire [1:1] \gw3_top/u_ddr_phy_top/phy_odt_pre ;
wire [1:0] \gw3_top/u_ddr_phy_top/hold_Z ;
wire [3:3] \gw3_top/u_ddr_phy_top/cs_memsync ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/n65_4 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/n72_4 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/n79_5 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/n86_5 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/n308_3 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/n318_3 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/n1047_3 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/n50_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/n45_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/n30_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/n20_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/n58_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/n308_4 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/n308_5 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/n318_4 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/n318_5 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/dqsts0_d ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/dqts_d ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/dqts0_d ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/mux_dqs ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/dqsts1_d ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/dq_iobuf_gen[0].dq_iodelay_1_DF ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/dq_iobuf_gen[1].dq_iodelay_1_DF ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/dq_iobuf_gen[2].dq_iodelay_1_DF ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/dq_iobuf_gen[3].dq_iodelay_1_DF ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/dq_iobuf_gen[4].dq_iodelay_1_DF ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/dq_iobuf_gen[5].dq_iodelay_1_DF ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/dq_iobuf_gen[6].dq_iodelay_1_DF ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/dq_iobuf_gen[7].dq_iodelay_1_DF ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/dq_iobuf_gen[8].dq_iodelay_1_DF ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/dq_iobuf_gen[9].dq_iodelay_1_DF ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/dq_iobuf_gen[10].dq_iodelay_1_DF ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/dq_iobuf_gen[11].dq_iodelay_1_DF ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/dq_iobuf_gen[12].dq_iodelay_1_DF ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/dq_iobuf_gen[13].dq_iodelay_1_DF ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/dq_iobuf_gen[14].dq_iodelay_1_DF ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/dq_iobuf_gen[15].dq_iodelay_1_DF ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/invalid_dqs_r ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/dqs_r ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/n250_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/n251_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/n257_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/n258_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/n395_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/dqs_reg ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/dqsts1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/invalid_wdata_en_Z ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/ddr_clk_out ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/if_wrreset_Z ;
wire [1:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/in_dqs ;
wire [15:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/in_dq ;
wire [1:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/in_dq0_reg ;
wire [1:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/if_fifo_rd_flg ;
wire [15:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/in_dq_p ;
wire [0:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/out_dqs ;
wire [0:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/out_dqsts ;
wire [7:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/out_dq ;
wire [7:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/out_dqts ;
wire [0:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/out_dm ;
wire [0:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/out_dmts_Z ;
wire [1:1] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/out_dqs_0 ;
wire [1:1] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/out_dqsts_0 ;
wire [15:8] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/out_dq_0 ;
wire [15:8] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/out_dqts_0 ;
wire [1:1] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/out_dm_0 ;
wire [1:1] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/out_dmts_Z_0 ;
wire [23:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/cmd_line ;
wire [2:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/if_raddr ;
wire [2:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/if_waddr ;
wire [0:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/if_empty ;
wire [5:3] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/if_raddr_0 ;
wire [5:3] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/if_waddr_0 ;
wire [1:1] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/if_empty_0 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n587_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n588_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n589_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n590_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n591_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n592_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n593_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n594_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n595_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n596_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n597_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n598_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n599_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n600_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n601_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n602_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n603_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n604_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n605_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n606_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n607_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n608_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n609_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n610_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n611_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n612_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n613_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n614_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n615_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n616_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n617_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n618_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n619_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n620_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n621_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n622_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n623_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n624_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n625_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n626_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n627_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n628_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n629_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n630_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n631_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n632_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n633_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n634_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n635_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n636_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n637_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n638_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n639_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n640_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n641_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n642_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n643_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n644_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n645_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n646_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n647_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n648_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n649_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n650_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n651_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n652_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n653_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n654_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n655_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n656_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n657_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/n658_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/invalid_dqs ;
wire [71:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/of_WrData_r ;
wire [71:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/of_WrData_rr ;
wire [71:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/of_WrData_rrr ;
wire [71:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/oserdes_dq ;
wire [63:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/iserdes_dq_Z ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/u_ddr_phy_data_io/dqsts0_r ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/u_ddr_phy_data_io/dqsts1_r ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/u_ddr_phy_data_io/dqts_r ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/u_ddr_phy_data_io/dqts0_r ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/u_ddr_phy_data_io/rmove_r ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/u_ddr_phy_data_io/rdir_r ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/u_ddr_phy_data_io/ides_calib_d ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/u_ddr_phy_data_io/dqsr90 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/u_ddr_phy_data_io/dqsw0 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/u_ddr_phy_data_io/dqsw270 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/u_ddr_phy_data_io/rvalid_wire ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/u_ddr_phy_data_io/rflag_wire ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/u_ddr_phy_data_io/wflag ;
wire [71:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/u_ddr_phy_data_io/oserdes_dq_r ;
wire [71:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/u_ddr_phy_data_io/oserdes_dq_rr ;
wire [63:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/u_ddr_phy_data_io/iserdes_dq_wire ;
wire [2:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/u_ddr_phy_data_io/rpoint ;
wire [2:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[0].u_ddr_phy_data_lane/u_ddr_phy_data_io/wpoint ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n587_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n588_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n589_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n590_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n591_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n592_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n593_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n594_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n595_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n596_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n597_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n598_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n599_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n600_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n601_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n602_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n603_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n604_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n605_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n606_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n607_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n608_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n609_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n610_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n611_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n612_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n613_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n614_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n615_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n616_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n617_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n618_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n619_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n620_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n621_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n622_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n623_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n624_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n625_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n626_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n627_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n628_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n629_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n630_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n631_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n632_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n633_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n634_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n635_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n636_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n637_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n638_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n639_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n640_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n641_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n642_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n643_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n644_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n645_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n646_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n647_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n648_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n649_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n650_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n651_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n652_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n653_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n654_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n655_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n656_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n657_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/n658_8 ;
wire [71:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/of_WrData_r ;
wire [71:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/of_WrData_rr ;
wire [71:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/of_WrData_rrr ;
wire [71:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/oserdes_dq ;
wire [63:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/iserdes_dq_Z ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/u_ddr_phy_data_io/rmove_r ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/u_ddr_phy_data_io/rdir_r ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/u_ddr_phy_data_io/ides_calib_d ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/u_ddr_phy_data_io/dqsr90 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/u_ddr_phy_data_io/dqsw0 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/u_ddr_phy_data_io/dqsw270 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/u_ddr_phy_data_io/rvalid_wire ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/u_ddr_phy_data_io/rflag_wire ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/u_ddr_phy_data_io/wflag ;
wire [71:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/u_ddr_phy_data_io/oserdes_dq_r ;
wire [71:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/u_ddr_phy_data_io/oserdes_dq_rr ;
wire [63:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/u_ddr_phy_data_io/iserdes_dq_wire ;
wire [2:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/u_ddr_phy_data_io/rpoint ;
wire [2:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/data_lane_gen[1].u_ddr_phy_data_lane/u_ddr_phy_data_io/wpoint ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/u_ddr_phy_cmd_lane/n245_3 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/u_ddr_phy_cmd_lane/n288_3 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/u_ddr_phy_cmd_lane/read_line0 ;
wire [3:2] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/u_ddr_phy_cmd_lane/cmd_wr ;
wire [3:2] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/u_ddr_phy_cmd_lane/cmd_rd ;
wire [3:2] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/u_ddr_phy_cmd_lane/cmd_rd_q_reg ;
wire [3:2] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/u_ddr_phy_cmd_lane/cmd_wr_q_reg ;
wire [95:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/u_ddr_phy_cmd_lane/oserdes_d_reg ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/u_ddr_phy_cmd_lane/u_ddr_phy_cmd_io/cmd_oserdes_gen[0].u_cmd_gen_1_Q1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/u_ddr_phy_cmd_lane/u_ddr_phy_cmd_io/cmd_oserdes_gen[1].u_cmd_gen_1_Q1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/u_ddr_phy_cmd_lane/u_ddr_phy_cmd_io/cmd_oserdes_gen[2].u_cmd_gen_1_Q1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/u_ddr_phy_cmd_lane/u_ddr_phy_cmd_io/cmd_oserdes_gen[3].u_cmd_gen_1_Q1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/u_ddr_phy_cmd_lane/u_ddr_phy_cmd_io/cmd_oserdes_gen[4].u_cmd_gen_1_Q1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/u_ddr_phy_cmd_lane/u_ddr_phy_cmd_io/cmd_oserdes_gen[5].u_cmd_gen_1_Q1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/u_ddr_phy_cmd_lane/u_ddr_phy_cmd_io/cmd_oserdes_gen[6].u_cmd_gen_1_Q1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/u_ddr_phy_cmd_lane/u_ddr_phy_cmd_io/cmd_oserdes_gen[7].u_cmd_gen_1_Q1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/u_ddr_phy_cmd_lane/u_ddr_phy_cmd_io/cmd_oserdes_gen[8].u_cmd_gen_1_Q1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/u_ddr_phy_cmd_lane/u_ddr_phy_cmd_io/cmd_oserdes_gen[9].u_cmd_gen_1_Q1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/u_ddr_phy_cmd_lane/u_ddr_phy_cmd_io/cmd_oserdes_gen[10].u_cmd_gen_1_Q1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/u_ddr_phy_cmd_lane/u_ddr_phy_cmd_io/cmd_oserdes_gen[11].u_cmd_gen_1_Q1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/u_ddr_phy_cmd_lane/u_ddr_phy_cmd_io/cmd_oserdes_gen[12].u_cmd_gen_1_Q1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/u_ddr_phy_cmd_lane/u_ddr_phy_cmd_io/cmd_oserdes_gen[13].u_cmd_gen_1_Q1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/u_ddr_phy_cmd_lane/u_ddr_phy_cmd_io/cmd_oserdes_gen[14].u_cmd_gen_1_Q1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/u_ddr_phy_cmd_lane/u_ddr_phy_cmd_io/cmd_oserdes_gen[15].u_cmd_gen_1_Q1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/u_ddr_phy_cmd_lane/u_ddr_phy_cmd_io/cmd_oserdes_gen[16].u_cmd_gen_1_Q1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/u_ddr_phy_cmd_lane/u_ddr_phy_cmd_io/cmd_oserdes_gen[17].u_cmd_gen_1_Q1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/u_ddr_phy_cmd_lane/u_ddr_phy_cmd_io/cmd_oserdes_gen[18].u_cmd_gen_1_Q1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/u_ddr_phy_cmd_lane/u_ddr_phy_cmd_io/cmd_oserdes_gen[19].u_cmd_gen_1_Q1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/u_ddr_phy_cmd_lane/u_ddr_phy_cmd_io/cmd_oserdes_gen[20].u_cmd_gen_1_Q1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/u_ddr_phy_cmd_lane/u_ddr_phy_cmd_io/cmd_oserdes_gen[21].u_cmd_gen_1_Q1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/u_ddr_phy_cmd_lane/u_ddr_phy_cmd_io/cmd_oserdes_gen[22].u_cmd_gen_1_Q1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/u_ddr_phy_cmd_lane/u_ddr_phy_cmd_io/cmd_oserdes_gen[23].u_cmd_gen_1_Q1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/u_ddr_phy_cmd_lane/u_ddr_phy_cmd_io/u_ck_gen_1_Q1 ;
wire [95:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/u_ddr_phy_cmd_lane/u_ddr_phy_cmd_io/oserdes_d_r ;
wire [95:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/u_ddr_phy_cmd_lane/u_ddr_phy_cmd_io/oserdes_d_rr ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[0].fifo_ctrl/if_wbinnext_0_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[0].fifo_ctrl/if_wbinnext_2_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[0].fifo_ctrl/if_rbinnext_1_10 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[0].fifo_ctrl/if_rbinnext_0_11 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[0].fifo_ctrl/if_rempty_val ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[0].fifo_ctrl/n31_1_SUM ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[0].fifo_ctrl/n31_3 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[0].fifo_ctrl/n32_1_SUM ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[0].fifo_ctrl/n32_3 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[0].fifo_ctrl/n33_1_SUM ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[0].fifo_ctrl/n33_3 ;
wire [3:1] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[0].fifo_ctrl/if_rbinnext ;
wire [3:1] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[0].fifo_ctrl/if_wbinnext ;
wire [2:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[0].fifo_ctrl/if_wgraynext ;
wire [2:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[0].fifo_ctrl/if_rgraynext ;
wire [3:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[0].fifo_ctrl/if_rq1_wptr ;
wire [3:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[0].fifo_ctrl/if_rq2_wptr ;
wire [3:3] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[0].fifo_ctrl/if_rbin ;
wire [2:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[0].fifo_ctrl/if_wptr ;
wire [3:3] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[0].fifo_ctrl/if_wbin ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[1].fifo_ctrl/if_wbinnext_0_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[1].fifo_ctrl/if_wbinnext_2_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[1].fifo_ctrl/if_rbinnext_1_10 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[1].fifo_ctrl/if_rbinnext_0_11 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[1].fifo_ctrl/if_rempty_val ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[1].fifo_ctrl/n31_1_SUM ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[1].fifo_ctrl/n31_3 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[1].fifo_ctrl/n32_1_SUM ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[1].fifo_ctrl/n32_3 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[1].fifo_ctrl/n33_1_SUM ;
wire \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[1].fifo_ctrl/n33_3 ;
wire [3:1] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[1].fifo_ctrl/if_rbinnext ;
wire [3:1] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[1].fifo_ctrl/if_wbinnext ;
wire [2:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[1].fifo_ctrl/if_wgraynext ;
wire [2:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[1].fifo_ctrl/if_rgraynext ;
wire [3:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[1].fifo_ctrl/if_rq1_wptr ;
wire [3:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[1].fifo_ctrl/if_rq2_wptr ;
wire [3:3] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[1].fifo_ctrl/if_rbin ;
wire [2:0] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[1].fifo_ctrl/if_wptr ;
wire [3:3] \gw3_top/u_ddr_phy_top/u_ddr_phy_wds/fifo_ctrl_gen[1].fifo_ctrl/if_wbin ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n109_3 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n64_3 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n110_3 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n172_3 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n291_3 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n353_3 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n172_4 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n110_1_4 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n291_1_4 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/realtime_dllcode_15_7 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/realtime_dllcode_7_7 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n327_6 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n326_6 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n325_6 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n324_6 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n323_6 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n322_6 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n321_6 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n320_6 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n146_6 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n145_6 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n144_6 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n143_6 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n142_6 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n141_6 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n140_6 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n139_6 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n254_8 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n245_5 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n435_8 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n426_5 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n102_5 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n284_5 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n465_5 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/init_rmove_start_rr ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/init_rmove_done_rr ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/rmove_start ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/init_rmove_done_Z ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/init_rmove_start_r ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n138_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n138_1_1 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n137_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n137_1_1 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n136_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n136_1_1 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n135_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n135_1_1 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n134_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n134_1_1 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n133_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n133_1_1 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n132_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n132_1_1 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n131_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n131_1_0_COUT ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n319_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n319_1_1 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n318_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n318_1_1 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n317_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n317_1_1 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n316_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n316_1_1 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n315_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n315_1_1 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n314_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n314_1_1 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n313_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n313_1_1 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n312_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n312_1_0_COUT ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n72_1 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n72_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n71_1 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n71_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n70_1 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n70_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n69_1 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n69_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n68_1 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n68_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n67_1 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n67_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n66_1 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n66_0_COUT ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n253_1 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n253_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n252_1 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n252_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n251_1 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n251_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n250_1 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n250_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n249_1 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n249_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n248_1 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n248_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n247_1 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n247_0_COUT ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n434_1 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n434_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n433_1 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n433_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n432_1 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n432_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n431_1 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n431_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n430_1 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n430_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n429_1 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n429_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n428_1 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n428_0_COUT ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n40_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n40_3 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n39_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n39_3 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n38_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n38_3 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n37_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n37_3 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n36_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n36_3 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n35_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n35_3 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n34_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n34_0_COUT ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n53_1_SUM ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n53_3 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n54_1_SUM ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n54_3 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n55_1_SUM ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n55_3 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n56_1_SUM ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n56_3 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n57_1_SUM ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n57_3 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n58_1_SUM ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n58_3 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n59_1_SUM ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n59_3 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n60_1_SUM ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n61_2 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n53_2_SUM ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n53_5 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n54_2_SUM ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n54_5 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n55_2_SUM ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n55_5 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n56_2_SUM ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n56_5 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n57_2_SUM ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n57_5 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n58_2_SUM ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n58_5 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n59_2_SUM ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n59_5 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n274_1_SUM ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n274_3 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n275_1_SUM ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n275_3 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n276_1_SUM ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n276_3 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n277_1_SUM ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n277_3 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n278_1_SUM ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n278_3 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n279_1_SUM ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n279_3 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n280_1_SUM ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n280_3 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n455_1_SUM ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n455_3 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n456_1_SUM ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n456_3 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n457_1_SUM ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n457_3 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n458_1_SUM ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n458_3 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n459_1_SUM ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n459_3 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n460_1_SUM ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n460_3 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n461_1_SUM ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n461_3 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n73_6 ;
wire \gw3_top/u_ddr_phy_top/u_init_rmove_mod/n41_7 ;
wire [1:0] \gw3_top/u_ddr_phy_top/u_init_rmove_mod/read_calib_rmove_r ;
wire [1:0] \gw3_top/u_ddr_phy_top/u_init_rmove_mod/read_calib_rmove_rr ;
wire [7:0] \gw3_top/u_ddr_phy_top/u_init_rmove_mod/dllstep_r ;
wire [7:0] \gw3_top/u_ddr_phy_top/u_init_rmove_mod/STATIC_RMOVE_TIMES ;
wire [7:0] \gw3_top/u_ddr_phy_top/u_init_rmove_mod/init_rmove_cnt ;
wire [7:0] \gw3_top/u_ddr_phy_top/u_init_rmove_mod/rdir_gen[0].rigth_stop ;
wire [7:0] \gw3_top/u_ddr_phy_top/u_init_rmove_mod/rdir_gen[0].add_rmove_cnt ;
wire [1:0] \gw3_top/u_ddr_phy_top/u_init_rmove_mod/sys_reset_ch ;
wire [7:0] \gw3_top/u_ddr_phy_top/u_init_rmove_mod/rdir_gen[1].add_rmove_cnt ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n85_3 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n92_3 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n107_3 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n124_3 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n125_3 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n126_3 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n127_3 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n128_3 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n129_3 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n130_3 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n131_3 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n211_3 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n377_3 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n378_3 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n379_3 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n380_3 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n381_3 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n382_3 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n383_3 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n384_3 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n464_3 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/realtime_dllcode_rr_7_8 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/eye_calib_gen[0].cor_cnt_7_6 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/realtime_dllcode_rr_15_8 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/eye_calib_gen[1].cor_cnt_7_6 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n_s.LEFT_EDGE_MOVE_16 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n233_36 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n486_36 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n405_38 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n152_38 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n511_7 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n506_7 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n258_7 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n253_7 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n415_6 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n162_6 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/c_s.RIGHT_MOVE_8 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n_s.EYE_CALIB_STOP ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n124_4 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n126_4 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n129_4 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n377_4 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n378_4 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n379_4 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n382_4 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n233_37 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n233_38 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n486_37 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n486_38 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n405_39 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n152_39 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n513_8 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n510_8 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n508_8 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n260_8 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n257_8 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n255_8 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n256_10 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n509_10 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/c_s.LEFT_EDGE_MOVE_10 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n128_6 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n127_6 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n381_6 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n380_6 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n254_10 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n255_10 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n256_12 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n257_10 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n259_9 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n260_10 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n507_10 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n508_10 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n509_12 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n510_10 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n512_9 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n513_10 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n177_12 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n178_8 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n430_12 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n431_8 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n254_12 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n507_12 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/n125_6 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/c_s.EYE_CALIB_STOP ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/rmove_left_flag_r ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/c_s.LEFT_EDGE_MOVE ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/c_s.RIGHT_MOVE ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/c_s.IDLE ;
wire [1:1] \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/eye_calib_error_valid_r ;
wire [1:0] \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/eye_calib_error_r ;
wire [1:1] \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/eye_calib_error_valid_rr ;
wire [1:0] \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/eye_calib_error_rr ;
wire [1:1] \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/eye_calib_error_valid_rrr ;
wire [1:0] \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/eye_calib_error_rrr ;
wire [1:0] \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/rmove_r ;
wire [1:0] \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/rmove_rr ;
wire [15:0] \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/realtime_dllcode_r ;
wire [1:0] \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/rflag_r ;
wire [1:0] \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/screen_valid ;
wire [7:0] \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/eye_calib_gen[0].cor_cnt ;
wire [7:0] \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/eye_calib_gen[1].cor_cnt ;
wire [15:0] \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/realtime_dllcode_rr ;
wire [1:0] \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/eye_calib_gen[0].rmove_cnt ;
wire [1:0] \gw3_top/u_ddr_phy_top/u_eye_calib_rmove_mod/eye_calib_gen[1].rmove_cnt ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n2727_3 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/row1_2_7 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4113_3 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4124_3 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4288_5 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4289_4 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4163_5 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4206_5 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/col1_3_8 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n_s.WR_BURST ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n_s.WR_CONTI_17 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n_s.RD_BURST_17 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4309_6 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4090_6 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4393_7 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4390_7 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4240_8 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4239_8 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4237_9 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n3771_18 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n3768_17 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4438_6 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n3804_17 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/c_s.WAIT_RMOVE_8 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error1_0_8 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2_0_8 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error3_0_8 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error4_0_8 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error1_1_8 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2_1_8 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error3_1_8 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error4_1_8 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n_s.WR_BURST_11 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4089_7 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4087_7 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4392_8 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4238_9 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4438_7 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4438_8 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error1_0_9 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error1_0_10 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error1_0_11 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2_0_9 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2_0_10 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error3_0_9 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error3_0_10 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error4_0_9 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error1_1_9 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error1_1_10 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error1_1_11 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2_1_9 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2_1_10 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error3_1_9 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error3_1_10 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error3_1_11 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error4_1_10 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4290_7 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n_s.WR_BURST_12 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4240_10 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error1_0_13 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error1_0_14 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error1_0_15 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2_0_11 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2_0_12 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2_0_13 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2_0_14 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error3_0_11 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error3_0_12 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error3_0_13 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error3_0_14 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error3_0_16 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error3_0_17 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error4_0_10 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error4_0_11 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error4_0_12 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error4_0_13 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error1_1_13 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error1_1_14 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error1_1_15 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error1_1_16 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error1_1_17 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error1_1_18 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2_1_11 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2_1_12 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2_1_13 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2_1_14 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error3_1_12 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error3_1_13 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error3_1_14 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error3_1_15 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error3_1_16 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error3_1_17 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error4_1_11 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error4_1_12 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error4_1_13 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error4_1_14 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error4_1_15 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error4_1_16 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error1_0_16 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error1_0_17 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error1_0_18 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error1_0_19 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error1_0_20 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error1_0_21 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2_0_15 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2_0_16 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2_0_17 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2_0_18 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2_0_19 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2_0_20 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2_0_21 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2_0_22 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error3_0_18 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error3_0_19 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error3_0_20 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error3_0_21 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error3_0_22 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error3_0_23 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error4_0_14 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error4_0_15 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error4_0_16 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error4_0_17 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error4_0_18 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error4_0_19 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error4_0_20 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error4_0_21 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error1_1_19 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error1_1_20 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error1_1_22 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error1_1_23 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2_1_15 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2_1_16 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2_1_17 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2_1_18 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2_1_19 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2_1_20 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2_1_21 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2_1_22 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error3_1_18 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error3_1_19 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error3_1_21 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error3_1_22 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error4_1_17 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error4_1_18 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error1_0_22 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error1_0_23 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error1_0_24 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error1_0_25 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error1_0_26 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2_0_23 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2_0_24 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2_0_25 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error3_0_24 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error3_0_25 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error4_0_22 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error4_0_23 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error4_0_24 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2_1_23 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2_1_24 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2_1_25 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error4_1_19 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error4_1_20 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error4_1_21 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error4_1_22 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error4_1_23 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error1_1_25 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error3_0_27 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error3_1_24 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n3812_19 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n3810_18 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4088_9 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4139_5 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4238_11 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4290_9 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4391_10 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n3777_16 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4288_10 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4240_12 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/c_s.RD_CONTI_9 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n3802_20 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error1_0_28 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error1_1_29 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error4_1_25 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4086_9 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4087_10 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4088_12 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4089_10 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4091_9 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4092_9 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4394_10 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/cnt_r[0]_1_15 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4395_10 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4391_13 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4392_11 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n_s.RMOVE_LEFT_19 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4113_6 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n_s.WAIT_RMOVE_18 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n_s.RD_CONTI_19 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/c_s.WR_CONTI_10 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/timeout_6_19 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_rmove_r ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_rdata_valid_r ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/eye_rdata_valid_rr ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/rmove_left_done_r ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/clr_error ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/c_s.WR_BURST ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/timeout_flg ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/timeout_flg_r ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/timeout_flg_pulse ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/c_s.WAIT_RMOVE ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/c_s.WR_CONTI ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/c_s.RD_BURST ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/c_s.RD_CONTI ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/c_s.IDLE ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/c_s.RMOVE_LEFT ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n4310_9 ;
wire \gw3_top/u_ddr_phy_top/u_eye_calib/n5117_13 ;
wire [127:0] \gw3_top/u_ddr_phy_top/u_eye_calib/eye_rdata_r ;
wire [1:0] \gw3_top/u_ddr_phy_top/u_eye_calib/cnt ;
wire [6:0] \gw3_top/u_ddr_phy_top/u_eye_calib/timeout ;
wire [3:0] \gw3_top/u_ddr_phy_top/u_eye_calib/col1 ;
wire [2:0] \gw3_top/u_ddr_phy_top/u_eye_calib/row1 ;
wire [5:2] \gw3_top/u_ddr_phy_top/u_eye_calib/cnt_stop ;
wire [1:0] \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error1 ;
wire [1:0] \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error2 ;
wire [1:0] \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error3 ;
wire [1:0] \gw3_top/u_ddr_phy_top/u_eye_calib/eye_calib_error4 ;
wire [1:0] \gw3_top/u_ddr_phy_top/u_eye_calib/cnt_r[0] ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n219_3 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n294_3 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n483_3 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n488_3 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n491_3 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n600_4 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/cke_en ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1173_3 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1975_3 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1991_3 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_calibration_logic_gen[0].rburst_t ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2057_3 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2396_3 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2218_3 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2274_3 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2283_3 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_calibration_logic_gen[1].rburst_t ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2466_3 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2805_3 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2627_3 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2683_3 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2692_3 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2877_3 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2156_28 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2157_23 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2158_22 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2159_23 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2565_28 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2566_23 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2567_22 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2568_23 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/repeat_done_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_calibration_logic_gen[0].cal_cnt_3_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/rburst_cnt_9_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/readback_check_0_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_calibration_logic_gen[1].cal_cnt_3_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/rburst_cnt_19_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/readback_check_1_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.LOAD_MR ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.WRLVL_LOAD_MR1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.WRLVL_LOAD_MR2 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.WRITE_LEVELING ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.WRLVL_MODE_CLOSE1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.WRLVL_MODE_CLOSE2 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.BURST_MODE_RECOVER ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.ZQCL ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.RESET_WAIT ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.CKE_EN ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.XPR_WAIT ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.LOAD_MR_WAIT ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.ZQCL_WAIT ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.WRLVL_LOAD_MR2_WAIT ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.WRLVL_LOAD_MR1_WAIT ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.WRLVL_MODE_CLOSE1_WAIT ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.READ_CALIBRATION ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.EYE_SCAN ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.INIT_DONE ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_next_state.WRLVL_SEND_DQS ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_next_state.WRLVL_DONE ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_WRITE_CMD ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_READ_CMD ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_ACTIVE_CMD ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_PRECHARGE ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_WAIT ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_HOLD ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_READ_CMD_WAIT ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_WRITE_CMD_WAIT ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_ACTIVE_CMD_WAIT ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_RSEL_ADJ_WAIT ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_PRECHARGE_WAIT ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_IDLE ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_RBURST_CHECK ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_RBURST_CHECK_WAIT ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_RBURST_CHECK_WAIT1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_RSEL_ADJ ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_DONE ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_next_state.WRLVL_ODT_EN_16 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_next_state.WRLVL_ODT_DIS_17 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_next_state.WRLVL_SEND_DQS_WAIT_17 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_next_state.WRLVL_ODT_WAIT_17 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_next_state.WRLVL_ODT_DIS_WAIT_17 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_next_state.WRLVL_ADJ_WAIT_17 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_next_state.WRLVL_IDLE_16 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_next_state.WRLVL_RECHECK_DQ_17 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_next_state.WRLVL_ADJ_DQS_17 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2655_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2654_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2653_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2652_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2651_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2650_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2649_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2648_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2646_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2597_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2594_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2593_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2590_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2490_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2246_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2245_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2244_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2243_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2242_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2241_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2240_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2239_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2237_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2188_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2185_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2184_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2181_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2081_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1933_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1932_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1928_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1493_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1256_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1255_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1254_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1253_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1252_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1250_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n471_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2816_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2815_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2814_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2813_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2553_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2551_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2550_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2407_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2406_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2405_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2404_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2144_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2142_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2141_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1198_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1197_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1195_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1194_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1193_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1192_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1191_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1190_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1189_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n330_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n328_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2370_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2779_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1560_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1510_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1278_9 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2105_4 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2514_4 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n483_4 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n491_4 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n491_5 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n600_5 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1173_4 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1173_5 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1173_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1991_4 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1991_5 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2057_4 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2396_4 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2132_4 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2218_5 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2274_5 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2283_4 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2434_4 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2466_4 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2805_4 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2541_4 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2627_5 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2683_5 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2692_4 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2843_4 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2877_4 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2877_5 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2877_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2877_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2156_29 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2156_30 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2157_24 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2157_25 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2158_23 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2158_24 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2159_24 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2159_25 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2565_29 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2565_30 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2566_24 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2566_25 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2567_23 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2567_24 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2568_24 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2568_25 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/timer_cnt0_7_11 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/rburst_cnt_9_9 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.LOAD_MR_24 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.LOAD_MR_25 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.LOAD_MR_26 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.WRLVL_LOAD_MR1_24 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.WRLVL_LOAD_MR2_23 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.WRITE_LEVELING_23 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.WRITE_LEVELING_24 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.RESET_WAIT_23 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.CKE_EN_23 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.CKE_EN_24 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_next_state.WRLVL_SEND_DQS_18 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_next_state.WRLVL_SEND_DQS_19 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_next_state.WRLVL_DONE_18 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_WRITE_CMD_23 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_WRITE_CMD_24 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_READ_CMD_22 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_ACTIVE_CMD_23 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_PRECHARGE_24 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_RBURST_CHECK_23 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_RSEL_ADJ_23 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_DONE_24 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_next_state.WRLVL_ODT_EN_17 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_next_state.WRLVL_ADJ_DQS_18 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2652_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2649_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2647_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2596_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2593_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2591_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2493_9 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2491_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2243_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2240_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2238_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2187_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2184_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2182_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2084_9 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2082_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1932_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1930_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1492_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1253_9 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1252_9 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1196_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1194_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1190_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n329_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n490_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2370_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2779_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1173_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1173_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1173_9 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2434_5 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2843_5 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2157_26 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2158_25 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2566_26 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2567_25 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/timer_cnt0_7_12 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.LOAD_MR_27 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.LOAD_MR_28 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.LOAD_MR_29 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.LOAD_MR_30 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.WRLVL_LOAD_MR1_25 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.WRLVL_LOAD_MR2_24 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.WRLVL_LOAD_MR2_25 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.WRLVL_LOAD_MR2_26 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.WRITE_LEVELING_25 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.WRITE_LEVELING_26 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.WRITE_LEVELING_27 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.WRITE_LEVELING_28 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.CKE_EN_25 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_next_state.WRLVL_SEND_DQS_20 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_next_state.WRLVL_SEND_DQS_21 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_next_state.WRLVL_SEND_DQS_22 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_WRITE_CMD_25 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_WRITE_CMD_26 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_WRITE_CMD_27 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_WRITE_CMD_28 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_WRITE_CMD_29 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_READ_CMD_23 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_READ_CMD_24 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_ACTIVE_CMD_24 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_ACTIVE_CMD_25 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_RBURST_CHECK_24 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_RBURST_CHECK_25 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_DONE_25 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_next_state.WRLVL_ODT_EN_18 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2370_9 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2370_10 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2370_11 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2370_12 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2779_9 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2779_10 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2779_11 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2779_12 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/timer_cnt0_7_13 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.LOAD_MR_31 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.LOAD_MR_32 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.LOAD_MR_33 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_next_state.WRLVL_SEND_DQS_23 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_next_state.WRLVL_SEND_DQS_24 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_WRITE_CMD_31 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_WRITE_CMD_33 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_WRITE_CMD_34 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_WRITE_CMD_35 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2370_13 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2370_14 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2370_15 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2370_16 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2370_17 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2370_18 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2370_19 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2370_20 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2370_21 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2370_22 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2370_23 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2370_24 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2370_25 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2370_26 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2370_27 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2370_28 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2779_13 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2779_14 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2779_15 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2779_16 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2779_17 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2779_18 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2779_19 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2779_20 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2779_21 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2779_22 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2779_23 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2779_24 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2779_25 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2779_26 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2779_27 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2779_28 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_WRITE_CMD_36 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/timer_cnt0_7_15 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.EYE_SCAN_28 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.IDLE ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.ZQCL_26 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1250_11 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1251_11 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n601_5 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_next_state.WRLVL_ODT_DIS_21 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2082_10 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2186_9 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/phy_odt_pre_1_10 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2242_10 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_calibration_logic_gen[0].cal_cnt_3_11 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2491_10 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2595_9 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2651_10 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_calibration_logic_gen[1].cal_cnt_3_11 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_next_state.WRLVL_ODT_DIS_23 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_next_state.WRLVL_ODT_WAIT_20 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1196_9 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1931_9 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2183_9 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2218_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2239_10 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2274_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2592_9 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2627_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2648_10 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2683_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1192_9 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n490_10 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n331_9 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n329_11 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n470_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_WRITE_CMD_38 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_next_state.WRLVL_READ_DQ_18 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/pre_dq_0_10 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1570_5 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1520_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2083_9 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2084_11 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2492_9 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2493_11 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n483_9 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/rvalid_cnt_19_11 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/rvalid_cnt_9_11 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1256_11 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2434_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2843_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_next_state.READ_CAL_WRITE_CMD_40 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_next_state.WRITE_LEVELING_31 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1537_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1528_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1587_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1578_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2106_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2103_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2107_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2143_10 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2132_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2515_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2512_7 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2516_8 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2552_10 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2541_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1249_11 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/timer_cnt0_7_19 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1492_10 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_sendDQS_Counter_3_14 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1494_9 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1495_10 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1906_10 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1929_10 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cmd_cnt_7_14 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1930_10 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1931_12 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1934_9 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1935_9 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2182_10 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2183_12 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2186_12 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2187_10 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2189_9 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2190_9 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2292_9 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2293_9 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2293_11 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2591_10 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2592_12 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2595_12 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2596_10 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2598_9 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2599_9 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2701_9 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2702_9 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2702_11 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/timer_cnt0_7_21 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1929_14 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2238_10 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2647_10 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n330_10 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n481_9 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/rvalid_cnt_19_20 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/rvalid_cnt_9_20 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cmd0 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cmd ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_state.LOAD_MR ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_state.WRLVL_LOAD_MR1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_state.WRLVL_LOAD_MR2 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_state.WRITE_LEVELING ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_state.WRLVL_MODE_CLOSE1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_state.WRLVL_MODE_CLOSE2 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_state.BURST_MODE_RECOVER ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_state.ZQCL ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_state.IDLE ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_state.RESET_WAIT ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_state.CKE_EN ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_state.XPR_WAIT ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_state.LOAD_MR_WAIT ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_state.ZQCL_WAIT ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_state.WRLVL_LOAD_MR2_WAIT ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_state.WRLVL_LOAD_MR1_WAIT ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_state.WRLVL_MODE_CLOSE1_WAIT ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_state.READ_CALIBRATION ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_state.EYE_SCAN ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/init_state.INIT_DONE ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/timer_go ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/repeat_done ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_state.WRLVL_ODT_EN ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_state.WRLVL_ODT_DIS ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_state.WRLVL_SEND_DQS_WAIT ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_state.WRLVL_ODT_WAIT ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_state.WRLVL_ODT_DIS_WAIT ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_state.WRLVL_ADJ_WAIT ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_state.WRLVL_IDLE ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_state.WRLVL_SEND_DQS ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_state.WRLVL_READ_DQ ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_state.WRLVL_RECHECK_DQ ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_state.WRLVL_ADJ_DQS ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_state.WRLVL_DONE ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_state.READ_CAL_WRITE_CMD ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_state.READ_CAL_READ_CMD ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_state.READ_CAL_ACTIVE_CMD ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_state.READ_CAL_PRECHARGE ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_state.READ_CAL_WAIT ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_state.READ_CAL_HOLD ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_state.READ_CAL_READ_CMD_WAIT ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_state.READ_CAL_WRITE_CMD_WAIT ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_state.READ_CAL_ACTIVE_CMD_WAIT ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_state.READ_CAL_RSEL_ADJ_WAIT ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_state.READ_CAL_PRECHARGE_WAIT ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_state.READ_CAL_IDLE ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_state.READ_CAL_RBURST_CHECK ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_state.READ_CAL_RBURST_CHECK_WAIT ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_state.READ_CAL_RBURST_CHECK_WAIT1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_state.READ_CAL_RSEL_ADJ ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_state.READ_CAL_DONE ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/rvalid_cnt_clr ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cmd_cnt_clr ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/hold_gen[0].hold_i ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/hold_gen[1].hold_i ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_calibration_logic_gen[0].rburst_pos ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_calibration_logic_gen[0].rburst_neg ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_calibration_logic_gen[0].rburst_neg_r ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_calibration_logic_gen[0].rburst_t_r ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_calibration_logic_gen[0].read_cal_done ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_calibration_logic_gen[1].rburst_pos ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_calibration_logic_gen[1].rburst_neg ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_calibration_logic_gen[1].rburst_neg_r ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_calibration_logic_gen[1].rburst_t_r ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_calibration_logic_gen[1].read_cal_done ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cal_complete ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/read_cmd_wait_ov ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/filter_first_burst ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1536_1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1536_2 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1535_1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1535_2 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1534_1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1534_2 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1533_1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1533_2 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1532_1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1532_2 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1531_1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1531_2 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1530_1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1530_0_COUT ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1586_1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1586_2 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1585_1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1585_2 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1584_1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1584_2 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1583_1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1583_2 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1582_1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1582_2 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1581_1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1581_2 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1580_1 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1580_0_COUT ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n340_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/phy_reset_n_c_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n2031_6 ;
wire \gw3_top/u_ddr_phy_top/u_ddr_init/n1279_6 ;
wire [1:0] \gw3_top/u_ddr_phy_top/u_ddr_init/phy_rdbk_data_valid_r ;
wire [127:0] \gw3_top/u_ddr_phy_top/u_ddr_init/phy_rdbk_data_r ;
wire [12:0] \gw3_top/u_ddr_phy_top/u_ddr_init/read_cmd1 ;
wire [9:0] \gw3_top/u_ddr_phy_top/u_ddr_init/timer_cnt ;
wire [1:0] \gw3_top/u_ddr_phy_top/u_ddr_init/repeat_cnt ;
wire [2:0] \gw3_top/u_ddr_phy_top/u_ddr_init/ddr_init_complete_d ;
wire [3:0] \gw3_top/u_ddr_phy_top/u_ddr_init/ddr_init_complete_inter ;
wire [1:0] \gw3_top/u_ddr_phy_top/u_ddr_init/edge_pos ;
wire [15:0] \gw3_top/u_ddr_phy_top/u_ddr_init/wstep_reg ;
wire [15:0] \gw3_top/u_ddr_phy_top/u_ddr_init/wstep_reg_d ;
wire [3:3] \gw3_top/u_ddr_phy_top/u_ddr_init/read_line ;
wire [0:0] \gw3_top/u_ddr_phy_top/u_ddr_init/hold_gen[0].hold_reg ;
wire [6:0] \gw3_top/u_ddr_phy_top/u_ddr_init/hold_gen[0].hold_reg_d ;
wire [1:0] \gw3_top/u_ddr_phy_top/u_ddr_init/rburst_reg ;
wire [3:0] \gw3_top/u_ddr_phy_top/u_ddr_init/read_calibration_logic_gen[0].read_i ;
wire [1:0] \gw3_top/u_ddr_phy_top/u_ddr_init/rvalid_cnt_check ;
wire [1:0] \gw3_top/u_ddr_phy_top/u_ddr_init/rburst_cnt_check ;
wire [1:0] \gw3_top/u_ddr_phy_top/u_ddr_init/read_rclksel_conf ;
wire [3:0] \gw3_top/u_ddr_phy_top/u_ddr_init/read_calibration_logic_gen[0].ides_calib_cnt ;
wire [3:0] \gw3_top/u_ddr_phy_top/u_ddr_init/read_calibration_logic_gen[1].read_i ;
wire [3:0] \gw3_top/u_ddr_phy_top/u_ddr_init/read_calibration_logic_gen[1].ides_calib_cnt ;
wire [7:0] \gw3_top/u_ddr_phy_top/u_ddr_init/timer_cnt0 ;
wire [3:0] \gw3_top/u_ddr_phy_top/u_ddr_init/wrlvl_sendDQS_Counter ;
wire [1:0] \gw3_top/u_ddr_phy_top/u_ddr_init/pre_dq ;
wire [7:0] \gw3_top/u_ddr_phy_top/u_ddr_init/read_cmd_cnt ;
wire [3:0] \gw3_top/u_ddr_phy_top/u_ddr_init/read_calibration_logic_gen[0].cal_cnt ;
wire [19:0] \gw3_top/u_ddr_phy_top/u_ddr_init/rvalid_cnt ;
wire [19:0] \gw3_top/u_ddr_phy_top/u_ddr_init/rburst_cnt ;
wire [1:0] \gw3_top/u_ddr_phy_top/u_ddr_init/readback_check ;
wire [3:0] \gw3_top/u_ddr_phy_top/u_ddr_init/read_calibration_logic_gen[1].cal_cnt ;
wire [3:0] \gw3_top/u_ddr_phy_top/u_ddr_init/rdback_check_cnt ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/n19_3 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/n92_4 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/flag_d_0_14 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/flag_d_0_16 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/ns_memsync_5_16 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/ns_memsync_4_16 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/ns_memsync_3_16 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/ns_memsync_2_16 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/ns_memsync_1_16 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/ns_memsync_0_16 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/flag_d_1_17 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/n298_8 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/n297_7 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/n296_7 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/n55_6 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/n51_6 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/n49_6 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/n47_6 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/n46_6 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/n92_6 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/n92_7 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/n92_8 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/flag_d_1_18 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/flag_d_0_17 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/flag_d_0_19 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/ns_memsync_5_17 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/ns_memsync_5_18 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/ns_memsync_5_19 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/ns_memsync_4_17 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/ns_memsync_3_17 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/ns_memsync_2_17 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/ns_memsync_2_18 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/ns_memsync_0_17 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/ns_memsync_0_18 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/flag_d_1_19 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/n298_9 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/n54_7 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/n53_7 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/n52_7 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/n50_7 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/n48_7 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/n46_7 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/n45_7 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/flag_d_0_20 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/flag_d_0_21 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/ns_memsync_4_19 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/ns_memsync_2_19 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/ns_memsync_1_18 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/n298_10 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/flag_d_0_23 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/n44_9 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/n52_9 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/ns_memsync_1_20 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/ns_memsync_4_21 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/ns_memsync_5_22 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/n57_11 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/lock_cnt_15_16 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/n92_10 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/lock_cnt_15_15 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/n56_8 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/n54_9 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/n53_9 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/n50_9 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/n48_9 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/n45_9 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/n44_11 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/n43_8 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/lock_d2 ;
wire \gw3_top/u_ddr_phy_top/ddr_sync/ready ;
wire [1:0] \gw3_top/u_ddr_phy_top/ddr_sync/recalib_s ;
wire [1:0] \gw3_top/u_ddr_phy_top/ddr_sync/lock_syn ;
wire [5:5] \gw3_top/u_ddr_phy_top/ddr_sync/cs_memsync_0 ;
wire [2:0] \gw3_top/u_ddr_phy_top/ddr_sync/count ;
wire [14:0] \gw3_top/u_ddr_phy_top/ddr_sync/lock_cnt ;
wire [1:0] \gw3_top/u_ddr_phy_top/ddr_sync/flag ;

assign clk_out=clk;
assign ddr_rst=reset;
assign VCC=1'b1;
assign GND=1'b0;
assign \gw3_top/ddr_init_internal =1'b1;
assign \gw3_top/eye_app_addr_Z =0;
assign \gw3_top/eye_app_cmd_Z =0;
assign \gw3_top/eye_app_cmd_en_Z =0;
assign \gw3_top/eye_app_wdf_wdata_Z =0;
assign \gw3_top/eye_app_wdf_wren_Z =0;
assign \gw3_top/eye_calib_rdata =0;
assign \gw3_top/eye_calib_start_Z =0;
assign \gw3_top/phy_rd_data_valid =0;
assign send_wr=\gw3_top/u_gwmc_top/send_wr ;
GSR GSR(.GSRI(1'b1));

LUT3 \gw3_top/u_gwmc_top/n8_s0  (
	.I0(\gw3_top/eye_app_cmd_en_Z ),
	.I1(cmd_en),
	.I2(\gw3_top/u_gwmc_top/eye_calib_start_cmd ),
	.F(\gw3_top/u_gwmc_top/n8_4 )
);
LUT3 \gw3_top/u_gwmc_top/n11_s0  (
	.I0(cmd[0]),
	.I1(\gw3_top/eye_app_cmd_Z [0]),
	.I2(\gw3_top/u_gwmc_top/eye_calib_start_cmd ),
	.F(\gw3_top/u_gwmc_top/n11_3 )
);
LUT3 \gw3_top/u_gwmc_top/n35_s0  (
	.I0(\gw3_top/eye_app_addr_Z [12]),
	.I1(addr[12]),
	.I2(\gw3_top/u_gwmc_top/eye_calib_start_addr ),
	.F(\gw3_top/u_gwmc_top/n35_3 )
);
LUT3 \gw3_top/u_gwmc_top/n36_s0  (
	.I0(addr[11]),
	.I1(\gw3_top/eye_app_addr_Z [11]),
	.I2(\gw3_top/u_gwmc_top/eye_calib_start_addr ),
	.F(\gw3_top/u_gwmc_top/n36_3 )
);
LUT3 \gw3_top/u_gwmc_top/n37_s0  (
	.I0(addr[10]),
	.I1(\gw3_top/eye_app_addr_Z [10]),
	.I2(\gw3_top/u_gwmc_top/eye_calib_start_addr ),
	.F(\gw3_top/u_gwmc_top/n37_3 )
);
LUT3 \gw3_top/u_gwmc_top/n41_s0  (
	.I0(addr[6]),
	.I1(\gw3_top/eye_app_addr_Z [6]),
	.I2(\gw3_top/u_gwmc_top/eye_calib_start_addr ),
	.F(\gw3_top/u_gwmc_top/n41_3 )
);
LUT3 \gw3_top/u_gwmc_top/n42_s0  (
	.I0(addr[5]),
	.I1(\gw3_top/eye_app_addr_Z [5]),
	.I2(\gw3_top/u_gwmc_top/eye_calib_start_addr ),
	.F(\gw3_top/u_gwmc_top/n42_3 )
);
LUT3 \gw3_top/u_gwmc_top/n43_s0  (
	.I0(addr[4]),
	.I1(\gw3_top/eye_app_addr_Z [4]),
	.I2(\gw3_top/u_gwmc_top/eye_calib_start_addr ),
	.F(\gw3_top/u_gwmc_top/n43_3 )
);
LUT3 \gw3_top/u_gwmc_top/n44_s0  (
	.I0(addr[3]),
	.I1(\gw3_top/eye_app_addr_Z [3]),
	.I2(\gw3_top/u_gwmc_top/eye_calib_start_addr ),
	.F(\gw3_top/u_gwmc_top/n44_3 )
);
LUT2 \gw3_top/u_gwmc_top/n113_s0  (
	.I0(\gw3_top/ddr_init_internal ),
	.I1(\gw3_top/eye_calib_start_Z ),
	.F(\gw3_top/u_gwmc_top/n113_3 )
);
LUT2 \gw3_top/u_gwmc_top/n40_s2  (
	.I0(\gw3_top/u_gwmc_top/eye_calib_start_addr ),
	.I1(addr[7]),
	.F(\gw3_top/u_gwmc_top/n40_7 )
);
LUT2 \gw3_top/u_gwmc_top/n39_s2  (
	.I0(\gw3_top/u_gwmc_top/eye_calib_start_addr ),
	.I1(addr[8]),
	.F(\gw3_top/u_gwmc_top/n39_7 )
);
LUT2 \gw3_top/u_gwmc_top/n38_s2  (
	.I0(\gw3_top/u_gwmc_top/eye_calib_start_addr ),
	.I1(addr[9]),
	.F(\gw3_top/u_gwmc_top/n38_7 )
);
LUT2 \gw3_top/u_gwmc_top/n34_s2  (
	.I0(\gw3_top/u_gwmc_top/eye_calib_start_addr ),
	.I1(addr[13]),
	.F(\gw3_top/u_gwmc_top/n34_7 )
);
LUT2 \gw3_top/u_gwmc_top/n33_s2  (
	.I0(\gw3_top/u_gwmc_top/eye_calib_start_addr ),
	.I1(addr[14]),
	.F(\gw3_top/u_gwmc_top/n33_7 )
);
LUT2 \gw3_top/u_gwmc_top/n32_s2  (
	.I0(\gw3_top/u_gwmc_top/eye_calib_start_addr ),
	.I1(addr[15]),
	.F(\gw3_top/u_gwmc_top/n32_7 )
);
LUT2 \gw3_top/u_gwmc_top/n31_s2  (
	.I0(\gw3_top/u_gwmc_top/eye_calib_start_addr ),
	.I1(addr[16]),
	.F(\gw3_top/u_gwmc_top/n31_7 )
);
LUT2 \gw3_top/u_gwmc_top/n30_s2  (
	.I0(\gw3_top/u_gwmc_top/eye_calib_start_addr ),
	.I1(addr[17]),
	.F(\gw3_top/u_gwmc_top/n30_7 )
);
LUT2 \gw3_top/u_gwmc_top/n29_s2  (
	.I0(\gw3_top/u_gwmc_top/eye_calib_start_addr ),
	.I1(addr[18]),
	.F(\gw3_top/u_gwmc_top/n29_7 )
);
LUT2 \gw3_top/u_gwmc_top/n28_s2  (
	.I0(\gw3_top/u_gwmc_top/eye_calib_start_addr ),
	.I1(addr[19]),
	.F(\gw3_top/u_gwmc_top/n28_7 )
);
LUT2 \gw3_top/u_gwmc_top/n27_s2  (
	.I0(\gw3_top/u_gwmc_top/eye_calib_start_addr ),
	.I1(addr[20]),
	.F(\gw3_top/u_gwmc_top/n27_7 )
);
LUT2 \gw3_top/u_gwmc_top/n26_s2  (
	.I0(\gw3_top/u_gwmc_top/eye_calib_start_addr ),
	.I1(addr[21]),
	.F(\gw3_top/u_gwmc_top/n26_7 )
);
LUT2 \gw3_top/u_gwmc_top/n25_s2  (
	.I0(\gw3_top/u_gwmc_top/eye_calib_start_addr ),
	.I1(addr[22]),
	.F(\gw3_top/u_gwmc_top/n25_7 )
);
LUT2 \gw3_top/u_gwmc_top/n24_s2  (
	.I0(\gw3_top/u_gwmc_top/eye_calib_start_addr ),
	.I1(addr[23]),
	.F(\gw3_top/u_gwmc_top/n24_7 )
);
LUT2 \gw3_top/u_gwmc_top/n23_s2  (
	.I0(\gw3_top/u_gwmc_top/eye_calib_start_addr ),
	.I1(addr[24]),
	.F(\gw3_top/u_gwmc_top/n23_7 )
);
LUT2 \gw3_top/u_gwmc_top/n22_s2  (
	.I0(\gw3_top/u_gwmc_top/eye_calib_start_addr ),
	.I1(addr[25]),
	.F(\gw3_top/u_gwmc_top/n22_7 )
);
LUT2 \gw3_top/u_gwmc_top/n21_s2  (
	.I0(\gw3_top/u_gwmc_top/eye_calib_start_addr ),
	.I1(addr[26]),
	.F(\gw3_top/u_gwmc_top/n21_7 )
);
LUT2 \gw3_top/u_gwmc_top/n20_s2  (
	.I0(\gw3_top/u_gwmc_top/eye_calib_start_addr ),
	.I1(addr[27]),
	.F(\gw3_top/u_gwmc_top/n20_7 )
);
LUT2 \gw3_top/u_gwmc_top/n9_s2  (
	.I0(\gw3_top/u_gwmc_top/eye_calib_start_cmd ),
	.I1(cmd[2]),
	.F(\gw3_top/u_gwmc_top/n9_7 )
);
LUT2 \gw3_top/u_gwmc_top/n10_s2  (
	.I0(\gw3_top/u_gwmc_top/eye_calib_start_cmd ),
	.I1(cmd[1]),
	.F(\gw3_top/u_gwmc_top/n10_7 )
);
LUT2 \gw3_top/u_gwmc_top/n45_s2  (
	.I0(\gw3_top/u_gwmc_top/eye_calib_start_addr ),
	.I1(addr[2]),
	.F(\gw3_top/u_gwmc_top/n45_7 )
);
LUT2 \gw3_top/u_gwmc_top/n46_s2  (
	.I0(\gw3_top/u_gwmc_top/eye_calib_start_addr ),
	.I1(addr[1]),
	.F(\gw3_top/u_gwmc_top/n46_7 )
);
LUT2 \gw3_top/u_gwmc_top/n47_s2  (
	.I0(\gw3_top/u_gwmc_top/eye_calib_start_addr ),
	.I1(addr[0]),
	.F(\gw3_top/u_gwmc_top/n47_7 )
);
DFFCE \gw3_top/u_gwmc_top/eye_calib_start_addr_s0  (
	.D(\gw3_top/eye_calib_start_Z ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/eye_calib_start_addr )
);
DFFCE \gw3_top/u_gwmc_top/app_en_s0  (
	.D(\gw3_top/u_gwmc_top/n8_4 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/app_en )
);
DFFCE \gw3_top/u_gwmc_top/app_cmd_2_s0  (
	.D(\gw3_top/u_gwmc_top/n9_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/app_cmd [2])
);
DFFCE \gw3_top/u_gwmc_top/app_cmd_1_s0  (
	.D(\gw3_top/u_gwmc_top/n10_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/app_cmd [1])
);
DFFCE \gw3_top/u_gwmc_top/app_cmd_0_s0  (
	.D(\gw3_top/u_gwmc_top/n11_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/app_cmd [0])
);
DFFCE \gw3_top/u_gwmc_top/app_addr_27_s0  (
	.D(\gw3_top/u_gwmc_top/n20_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/app_addr [27])
);
DFFCE \gw3_top/u_gwmc_top/app_addr_26_s0  (
	.D(\gw3_top/u_gwmc_top/n21_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/app_addr [26])
);
DFFCE \gw3_top/u_gwmc_top/app_addr_25_s0  (
	.D(\gw3_top/u_gwmc_top/n22_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/app_addr [25])
);
DFFCE \gw3_top/u_gwmc_top/app_addr_24_s0  (
	.D(\gw3_top/u_gwmc_top/n23_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/app_addr [24])
);
DFFCE \gw3_top/u_gwmc_top/app_addr_23_s0  (
	.D(\gw3_top/u_gwmc_top/n24_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/app_addr [23])
);
DFFCE \gw3_top/u_gwmc_top/app_addr_22_s0  (
	.D(\gw3_top/u_gwmc_top/n25_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/app_addr [22])
);
DFFCE \gw3_top/u_gwmc_top/app_addr_21_s0  (
	.D(\gw3_top/u_gwmc_top/n26_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/app_addr [21])
);
DFFCE \gw3_top/u_gwmc_top/app_addr_20_s0  (
	.D(\gw3_top/u_gwmc_top/n27_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/app_addr [20])
);
DFFCE \gw3_top/u_gwmc_top/app_addr_19_s0  (
	.D(\gw3_top/u_gwmc_top/n28_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/app_addr [19])
);
DFFCE \gw3_top/u_gwmc_top/app_addr_18_s0  (
	.D(\gw3_top/u_gwmc_top/n29_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/app_addr [18])
);
DFFCE \gw3_top/u_gwmc_top/app_addr_17_s0  (
	.D(\gw3_top/u_gwmc_top/n30_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/app_addr [17])
);
DFFCE \gw3_top/u_gwmc_top/app_addr_16_s0  (
	.D(\gw3_top/u_gwmc_top/n31_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/app_addr [16])
);
DFFCE \gw3_top/u_gwmc_top/app_addr_15_s0  (
	.D(\gw3_top/u_gwmc_top/n32_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/app_addr [15])
);
DFFCE \gw3_top/u_gwmc_top/app_addr_14_s0  (
	.D(\gw3_top/u_gwmc_top/n33_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/app_addr [14])
);
DFFCE \gw3_top/u_gwmc_top/app_addr_13_s0  (
	.D(\gw3_top/u_gwmc_top/n34_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/app_addr [13])
);
DFFCE \gw3_top/u_gwmc_top/app_addr_12_s0  (
	.D(\gw3_top/u_gwmc_top/n35_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/app_addr [12])
);
DFFCE \gw3_top/u_gwmc_top/app_addr_11_s0  (
	.D(\gw3_top/u_gwmc_top/n36_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/app_addr [11])
);
DFFCE \gw3_top/u_gwmc_top/app_addr_10_s0  (
	.D(\gw3_top/u_gwmc_top/n37_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/app_addr [10])
);
DFFCE \gw3_top/u_gwmc_top/app_addr_9_s0  (
	.D(\gw3_top/u_gwmc_top/n38_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/app_addr [9])
);
DFFCE \gw3_top/u_gwmc_top/app_addr_8_s0  (
	.D(\gw3_top/u_gwmc_top/n39_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/app_addr [8])
);
DFFCE \gw3_top/u_gwmc_top/app_addr_7_s0  (
	.D(\gw3_top/u_gwmc_top/n40_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/app_addr [7])
);
DFFCE \gw3_top/u_gwmc_top/app_addr_6_s0  (
	.D(\gw3_top/u_gwmc_top/n41_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/app_addr [6])
);
DFFCE \gw3_top/u_gwmc_top/app_addr_5_s0  (
	.D(\gw3_top/u_gwmc_top/n42_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/app_addr [5])
);
DFFCE \gw3_top/u_gwmc_top/app_addr_4_s0  (
	.D(\gw3_top/u_gwmc_top/n43_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/app_addr [4])
);
DFFCE \gw3_top/u_gwmc_top/app_addr_3_s0  (
	.D(\gw3_top/u_gwmc_top/n44_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/app_addr [3])
);
DFFCE \gw3_top/u_gwmc_top/app_addr_2_s0  (
	.D(\gw3_top/u_gwmc_top/n45_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/app_addr [2])
);
DFFCE \gw3_top/u_gwmc_top/app_addr_1_s0  (
	.D(\gw3_top/u_gwmc_top/n46_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/app_addr [1])
);
DFFCE \gw3_top/u_gwmc_top/app_addr_0_s0  (
	.D(\gw3_top/u_gwmc_top/n47_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/app_addr [0])
);
DFFCE \gw3_top/u_gwmc_top/mc_ras_n_dly_3_s0  (
	.D(VCC),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_ras_n_dly [3])
);
DFFCE \gw3_top/u_gwmc_top/mc_ras_n_dly_2_s0  (
	.D(\gw3_top/u_gwmc_top/mc_ras_n_out [2]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_ras_n_dly [2])
);
DFFCE \gw3_top/u_gwmc_top/mc_cas_n_dly_3_s0  (
	.D(\gw3_top/u_gwmc_top/cmd3 [21]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_cas_n_dly [3])
);
DFFCE \gw3_top/u_gwmc_top/mc_cas_n_dly_2_s0  (
	.D(\gw3_top/u_gwmc_top/mc_cas_n_out [2]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_cas_n_dly [2])
);
DFFCE \gw3_top/u_gwmc_top/mc_we_n_dly_3_s0  (
	.D(\gw3_top/u_gwmc_top/mc_we_n_out [3]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_we_n_dly [3])
);
DFFCE \gw3_top/u_gwmc_top/mc_we_n_dly_2_s0  (
	.D(\gw3_top/u_gwmc_top/mc_we_n_out [2]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_we_n_dly [2])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_dly_54_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_out [54]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_dly [54])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_dly_53_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_out [53]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_dly [53])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_dly_52_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_out [52]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_dly [52])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_dly_51_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_out [51]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_dly [51])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_dly_50_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_out [50]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_dly [50])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_dly_49_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_out [49]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_dly [49])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_dly_48_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_out [48]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_dly [48])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_dly_47_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_out [47]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_dly [47])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_dly_46_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_out [46]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_dly [46])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_dly_45_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_out [45]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_dly [45])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_dly_44_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_out [44]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_dly [44])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_dly_43_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_out [43]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_dly [43])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_dly_42_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_out [42]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_dly [42])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_dly_41_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_out [41]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_dly [41])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_dly_40_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_out [40]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_dly [40])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_dly_39_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_out [39]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_dly [39])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_dly_38_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_out [38]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_dly [38])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_dly_37_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_out [37]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_dly [37])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_dly_36_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_out [36]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_dly [36])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_dly_35_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_out [35]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_dly [35])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_dly_34_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_out [34]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_dly [34])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_dly_33_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_out [33]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_dly [33])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_dly_32_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_out [32]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_dly [32])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_dly_31_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_out [31]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_dly [31])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_dly_30_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_out [30]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_dly [30])
);
DFFCE \gw3_top/u_gwmc_top/mc_bank_dly_11_s0  (
	.D(\gw3_top/u_gwmc_top/mc_bank_out [11]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_bank_dly [11])
);
DFFCE \gw3_top/u_gwmc_top/mc_bank_dly_10_s0  (
	.D(\gw3_top/u_gwmc_top/mc_bank_out [10]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_bank_dly [10])
);
DFFCE \gw3_top/u_gwmc_top/mc_bank_dly_9_s0  (
	.D(\gw3_top/u_gwmc_top/mc_bank_out [9]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_bank_dly [9])
);
DFFCE \gw3_top/u_gwmc_top/mc_bank_dly_8_s0  (
	.D(\gw3_top/u_gwmc_top/mc_bank_out [8]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_bank_dly [8])
);
DFFCE \gw3_top/u_gwmc_top/mc_bank_dly_7_s0  (
	.D(\gw3_top/u_gwmc_top/mc_bank_out [7]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_bank_dly [7])
);
DFFCE \gw3_top/u_gwmc_top/mc_bank_dly_6_s0  (
	.D(\gw3_top/u_gwmc_top/mc_bank_out [6]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_bank_dly [6])
);
DFFCE \gw3_top/u_gwmc_top/mc_cs_n_dly_3_s0  (
	.D(\gw3_top/u_gwmc_top/mc_cs_n_out [3]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_cs_n_dly [3])
);
DFFCE \gw3_top/u_gwmc_top/mc_cs_n_dly_2_s0  (
	.D(\gw3_top/u_gwmc_top/mc_cs_n_out [2]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_cs_n_dly [2])
);
DFFCE \gw3_top/u_gwmc_top/mc_odt_dly_1_s0  (
	.D(\gw3_top/u_gwmc_top/mc_odt_out [0]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_odt_dly [1])
);
DFFCE \gw3_top/u_gwmc_top/mc_cke_dly_3_s0  (
	.D(\gw3_top/u_gwmc_top/mc_cke_out [3]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_cke_dly [3])
);
DFFCE \gw3_top/u_gwmc_top/mc_ras_n_3_s0  (
	.D(\gw3_top/u_gwmc_top/mc_ras_n_dly [3]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_ras_n_Z [3])
);
DFFCE \gw3_top/u_gwmc_top/mc_ras_n_2_s0  (
	.D(\gw3_top/u_gwmc_top/mc_ras_n_dly [2]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_ras_n_Z [2])
);
DFFCE \gw3_top/u_gwmc_top/mc_cas_n_3_s0  (
	.D(\gw3_top/u_gwmc_top/mc_cas_n_dly [3]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_cas_n_Z [3])
);
DFFCE \gw3_top/u_gwmc_top/mc_cas_n_2_s0  (
	.D(\gw3_top/u_gwmc_top/mc_cas_n_dly [2]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_cas_n_Z [2])
);
DFFCE \gw3_top/u_gwmc_top/mc_we_n_3_s0  (
	.D(\gw3_top/u_gwmc_top/mc_we_n_dly [3]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_we_n_Z [3])
);
DFFCE \gw3_top/u_gwmc_top/mc_we_n_2_s0  (
	.D(\gw3_top/u_gwmc_top/mc_we_n_dly [2]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_we_n_Z [2])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_54_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_dly [54]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_address_Z [54])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_53_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_dly [53]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_address_Z [53])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_52_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_dly [52]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_address_Z [52])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_51_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_dly [51]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_address_Z [51])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_50_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_dly [50]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_address_Z [50])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_49_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_dly [49]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_address_Z [49])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_48_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_dly [48]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_address_Z [48])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_47_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_dly [47]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_address_Z [47])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_46_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_dly [46]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_address_Z [46])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_45_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_dly [45]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_address_Z [45])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_44_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_dly [44]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_address_Z [44])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_43_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_dly [43]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_address_Z [43])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_42_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_dly [42]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_address_Z [42])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_41_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_dly [41]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_address_Z [41])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_40_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_dly [40]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_address_Z [40])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_39_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_dly [39]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_address_Z [39])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_38_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_dly [38]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_address_Z [38])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_37_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_dly [37]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_address_Z [37])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_36_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_dly [36]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_address_Z [36])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_35_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_dly [35]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_address_Z [35])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_34_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_dly [34]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_address_Z [34])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_33_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_dly [33]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_address_Z [33])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_32_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_dly [32]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_address_Z [32])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_31_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_dly [31]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_address_Z [31])
);
DFFCE \gw3_top/u_gwmc_top/mc_address_30_s0  (
	.D(\gw3_top/u_gwmc_top/mc_address_dly [30]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_address_Z [30])
);
DFFCE \gw3_top/u_gwmc_top/mc_bank_11_s0  (
	.D(\gw3_top/u_gwmc_top/mc_bank_dly [11]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_bank_Z [11])
);
DFFCE \gw3_top/u_gwmc_top/mc_bank_10_s0  (
	.D(\gw3_top/u_gwmc_top/mc_bank_dly [10]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_bank_Z [10])
);
DFFCE \gw3_top/u_gwmc_top/mc_bank_9_s0  (
	.D(\gw3_top/u_gwmc_top/mc_bank_dly [9]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_bank_Z [9])
);
DFFCE \gw3_top/u_gwmc_top/mc_bank_8_s0  (
	.D(\gw3_top/u_gwmc_top/mc_bank_dly [8]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_bank_Z [8])
);
DFFCE \gw3_top/u_gwmc_top/mc_bank_7_s0  (
	.D(\gw3_top/u_gwmc_top/mc_bank_dly [7]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_bank_Z [7])
);
DFFCE \gw3_top/u_gwmc_top/mc_bank_6_s0  (
	.D(\gw3_top/u_gwmc_top/mc_bank_dly [6]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_bank_Z [6])
);
DFFCE \gw3_top/u_gwmc_top/mc_cs_n_3_s0  (
	.D(\gw3_top/u_gwmc_top/mc_cs_n_dly [3]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_cs_n_Z [3])
);
DFFCE \gw3_top/u_gwmc_top/mc_cs_n_2_s0  (
	.D(\gw3_top/u_gwmc_top/mc_cs_n_dly [2]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_cs_n_Z [2])
);
DFFCE \gw3_top/u_gwmc_top/mc_odt_1_s0  (
	.D(\gw3_top/u_gwmc_top/mc_odt_dly [1]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_odt_Z [1])
);
DFFCE \gw3_top/u_gwmc_top/mc_cke_3_s0  (
	.D(\gw3_top/u_gwmc_top/mc_cke_dly [3]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_cke_Z [3])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_127_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [127]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [127])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_126_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [126]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [126])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_125_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [125]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [125])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_124_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [124]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [124])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_123_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [123]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [123])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_122_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [122]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [122])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_121_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [121]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [121])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_120_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [120]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [120])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_119_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [119]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [119])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_118_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [118]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [118])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_117_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [117]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [117])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_116_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [116]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [116])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_115_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [115]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [115])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_114_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [114]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [114])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_113_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [113]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [113])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_112_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [112]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [112])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_111_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [111]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [111])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_110_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [110]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [110])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_109_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [109]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [109])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_108_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [108]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [108])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_107_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [107]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [107])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_106_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [106]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [106])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_105_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [105]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [105])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_104_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [104]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [104])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_103_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [103]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [103])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_102_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [102]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [102])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_101_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [101]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [101])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_100_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [100]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [100])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_99_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [99]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [99])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_98_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [98]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [98])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_97_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [97]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [97])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_96_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [96]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [96])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_95_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [95]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [95])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_94_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [94]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [94])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_93_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [93]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [93])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_92_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [92]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [92])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_91_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [91]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [91])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_90_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [90]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [90])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_89_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [89]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [89])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_88_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [88]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [88])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_87_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [87]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [87])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_86_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [86]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [86])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_85_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [85]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [85])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_84_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [84]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [84])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_83_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [83]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [83])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_82_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [82]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [82])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_81_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [81]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [81])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_80_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [80]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [80])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_79_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [79]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [79])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_78_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [78]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [78])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_77_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [77]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [77])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_76_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [76]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [76])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_75_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [75]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [75])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_74_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [74]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [74])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_73_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [73]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [73])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_72_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [72]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [72])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_71_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [71]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [71])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_70_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [70]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [70])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_69_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [69]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [69])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_68_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [68]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [68])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_67_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [67]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [67])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_66_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [66]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [66])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_65_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [65]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [65])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_64_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [64]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [64])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_63_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [63]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [63])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_62_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [62]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [62])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_61_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [61]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [61])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_60_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [60]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [60])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_59_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [59]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [59])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_58_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [58]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [58])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_57_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [57]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [57])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_56_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [56]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [56])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_55_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [55]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [55])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_54_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [54]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [54])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_53_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [53]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [53])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_52_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [52]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [52])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_51_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [51]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [51])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_50_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [50]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [50])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_49_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [49]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [49])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_48_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [48]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [48])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_47_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [47]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [47])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_46_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [46]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [46])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_45_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [45]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [45])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_44_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [44]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [44])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_43_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [43]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [43])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_42_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [42]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [42])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_41_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [41]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [41])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_40_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [40]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [40])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_39_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [39]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [39])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_38_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [38]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [38])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_37_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [37]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [37])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_36_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [36]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [36])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_35_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [35]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [35])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_34_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [34]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [34])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_33_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [33]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [33])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_32_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [32]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [32])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_31_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [31]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [31])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_30_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [30]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [30])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_29_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [29]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [29])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_28_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [28]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [28])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_27_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [27]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [27])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_26_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [26]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [26])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_25_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [25]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [25])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_24_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [24]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [24])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_23_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [23]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [23])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_22_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [22]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [22])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_21_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [21]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [21])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_20_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [20]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [20])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_19_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [19]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [19])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_18_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [18]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [18])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_17_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [17]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [17])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_16_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [16]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [16])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_15_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [15]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [15])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_14_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [14]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [14])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_13_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [13]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [13])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_12_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [12]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [12])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_11_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [11]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [11])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_10_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [10]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [10])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_9_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [9]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [9])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_8_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [8]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [8])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_7_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [7]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [7])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_6_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [6]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [6])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_5_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [5]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [5])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_4_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [4]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [4])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_3_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [3]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [3])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_2_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [2]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [2])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_1_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [1]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [1])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_dly_1_0_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_dly [0]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata [0])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_mask_15_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_mask_dly [15]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata_mask_Z [15])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_mask_14_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_mask_dly [14]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata_mask_Z [14])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_mask_13_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_mask_dly [13]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata_mask_Z [13])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_mask_12_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_mask_dly [12]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata_mask_Z [12])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_mask_11_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_mask_dly [11]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata_mask_Z [11])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_mask_10_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_mask_dly [10]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata_mask_Z [10])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_mask_9_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_mask_dly [9]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata_mask_Z [9])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_mask_8_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_mask_dly [8]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata_mask_Z [8])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_mask_7_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_mask_dly [7]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata_mask_Z [7])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_mask_6_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_mask_dly [6]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata_mask_Z [6])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_mask_5_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_mask_dly [5]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata_mask_Z [5])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_mask_4_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_mask_dly [4]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata_mask_Z [4])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_mask_3_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_mask_dly [3]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata_mask_Z [3])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_mask_2_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_mask_dly [2]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata_mask_Z [2])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_mask_1_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_mask_dly [1]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata_mask_Z [1])
);
DFFCE \gw3_top/u_gwmc_top/mc_wrdata_mask_0_s0  (
	.D(\gw3_top/u_gwmc_top/mc_wrdata_mask_dly [0]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/mc_wrdata_mask_Z [0])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_127_s0  (
	.D(\gw3_top/eye_calib_rdata [127]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[127])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_126_s0  (
	.D(\gw3_top/eye_calib_rdata [126]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[126])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_125_s0  (
	.D(\gw3_top/eye_calib_rdata [125]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[125])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_124_s0  (
	.D(\gw3_top/eye_calib_rdata [124]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[124])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_123_s0  (
	.D(\gw3_top/eye_calib_rdata [123]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[123])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_122_s0  (
	.D(\gw3_top/eye_calib_rdata [122]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[122])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_121_s0  (
	.D(\gw3_top/eye_calib_rdata [121]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[121])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_120_s0  (
	.D(\gw3_top/eye_calib_rdata [120]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[120])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_119_s0  (
	.D(\gw3_top/eye_calib_rdata [63]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[119])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_118_s0  (
	.D(\gw3_top/eye_calib_rdata [62]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[118])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_117_s0  (
	.D(\gw3_top/eye_calib_rdata [61]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[117])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_116_s0  (
	.D(\gw3_top/eye_calib_rdata [60]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[116])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_115_s0  (
	.D(\gw3_top/eye_calib_rdata [59]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[115])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_114_s0  (
	.D(\gw3_top/eye_calib_rdata [58]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[114])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_113_s0  (
	.D(\gw3_top/eye_calib_rdata [57]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[113])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_112_s0  (
	.D(\gw3_top/eye_calib_rdata [56]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[112])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_111_s0  (
	.D(\gw3_top/eye_calib_rdata [119]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[111])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_110_s0  (
	.D(\gw3_top/eye_calib_rdata [118]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[110])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_109_s0  (
	.D(\gw3_top/eye_calib_rdata [117]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[109])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_108_s0  (
	.D(\gw3_top/eye_calib_rdata [116]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[108])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_107_s0  (
	.D(\gw3_top/eye_calib_rdata [115]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[107])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_106_s0  (
	.D(\gw3_top/eye_calib_rdata [114]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[106])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_105_s0  (
	.D(\gw3_top/eye_calib_rdata [113]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[105])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_104_s0  (
	.D(\gw3_top/eye_calib_rdata [112]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[104])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_103_s0  (
	.D(\gw3_top/eye_calib_rdata [55]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[103])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_102_s0  (
	.D(\gw3_top/eye_calib_rdata [54]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[102])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_101_s0  (
	.D(\gw3_top/eye_calib_rdata [53]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[101])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_100_s0  (
	.D(\gw3_top/eye_calib_rdata [52]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[100])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_99_s0  (
	.D(\gw3_top/eye_calib_rdata [51]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[99])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_98_s0  (
	.D(\gw3_top/eye_calib_rdata [50]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[98])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_97_s0  (
	.D(\gw3_top/eye_calib_rdata [49]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[97])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_96_s0  (
	.D(\gw3_top/eye_calib_rdata [48]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[96])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_95_s0  (
	.D(\gw3_top/eye_calib_rdata [111]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[95])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_94_s0  (
	.D(\gw3_top/eye_calib_rdata [110]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[94])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_93_s0  (
	.D(\gw3_top/eye_calib_rdata [109]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[93])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_92_s0  (
	.D(\gw3_top/eye_calib_rdata [108]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[92])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_91_s0  (
	.D(\gw3_top/eye_calib_rdata [107]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[91])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_90_s0  (
	.D(\gw3_top/eye_calib_rdata [106]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[90])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_89_s0  (
	.D(\gw3_top/eye_calib_rdata [105]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[89])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_88_s0  (
	.D(\gw3_top/eye_calib_rdata [104]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[88])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_87_s0  (
	.D(\gw3_top/eye_calib_rdata [47]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[87])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_86_s0  (
	.D(\gw3_top/eye_calib_rdata [46]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[86])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_85_s0  (
	.D(\gw3_top/eye_calib_rdata [45]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[85])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_84_s0  (
	.D(\gw3_top/eye_calib_rdata [44]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[84])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_83_s0  (
	.D(\gw3_top/eye_calib_rdata [43]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[83])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_82_s0  (
	.D(\gw3_top/eye_calib_rdata [42]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[82])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_81_s0  (
	.D(\gw3_top/eye_calib_rdata [41]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[81])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_80_s0  (
	.D(\gw3_top/eye_calib_rdata [40]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[80])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_79_s0  (
	.D(\gw3_top/eye_calib_rdata [103]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[79])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_78_s0  (
	.D(\gw3_top/eye_calib_rdata [102]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[78])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_77_s0  (
	.D(\gw3_top/eye_calib_rdata [101]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[77])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_76_s0  (
	.D(\gw3_top/eye_calib_rdata [100]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[76])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_75_s0  (
	.D(\gw3_top/eye_calib_rdata [99]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[75])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_74_s0  (
	.D(\gw3_top/eye_calib_rdata [98]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[74])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_73_s0  (
	.D(\gw3_top/eye_calib_rdata [97]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[73])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_72_s0  (
	.D(\gw3_top/eye_calib_rdata [96]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[72])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_71_s0  (
	.D(\gw3_top/eye_calib_rdata [39]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[71])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_70_s0  (
	.D(\gw3_top/eye_calib_rdata [38]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[70])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_69_s0  (
	.D(\gw3_top/eye_calib_rdata [37]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[69])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_68_s0  (
	.D(\gw3_top/eye_calib_rdata [36]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[68])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_67_s0  (
	.D(\gw3_top/eye_calib_rdata [35]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[67])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_66_s0  (
	.D(\gw3_top/eye_calib_rdata [34]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[66])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_65_s0  (
	.D(\gw3_top/eye_calib_rdata [33]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[65])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_64_s0  (
	.D(\gw3_top/eye_calib_rdata [32]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[64])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_63_s0  (
	.D(\gw3_top/eye_calib_rdata [95]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[63])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_62_s0  (
	.D(\gw3_top/eye_calib_rdata [94]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[62])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_61_s0  (
	.D(\gw3_top/eye_calib_rdata [93]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[61])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_60_s0  (
	.D(\gw3_top/eye_calib_rdata [92]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[60])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_59_s0  (
	.D(\gw3_top/eye_calib_rdata [91]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[59])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_58_s0  (
	.D(\gw3_top/eye_calib_rdata [90]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[58])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_57_s0  (
	.D(\gw3_top/eye_calib_rdata [89]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[57])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_56_s0  (
	.D(\gw3_top/eye_calib_rdata [88]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[56])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_55_s0  (
	.D(\gw3_top/eye_calib_rdata [31]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[55])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_54_s0  (
	.D(\gw3_top/eye_calib_rdata [30]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[54])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_53_s0  (
	.D(\gw3_top/eye_calib_rdata [29]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[53])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_52_s0  (
	.D(\gw3_top/eye_calib_rdata [28]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[52])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_51_s0  (
	.D(\gw3_top/eye_calib_rdata [27]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[51])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_50_s0  (
	.D(\gw3_top/eye_calib_rdata [26]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[50])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_49_s0  (
	.D(\gw3_top/eye_calib_rdata [25]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[49])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_48_s0  (
	.D(\gw3_top/eye_calib_rdata [24]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[48])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_47_s0  (
	.D(\gw3_top/eye_calib_rdata [87]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[47])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_46_s0  (
	.D(\gw3_top/eye_calib_rdata [86]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[46])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_45_s0  (
	.D(\gw3_top/eye_calib_rdata [85]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[45])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_44_s0  (
	.D(\gw3_top/eye_calib_rdata [84]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[44])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_43_s0  (
	.D(\gw3_top/eye_calib_rdata [83]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[43])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_42_s0  (
	.D(\gw3_top/eye_calib_rdata [82]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[42])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_41_s0  (
	.D(\gw3_top/eye_calib_rdata [81]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[41])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_40_s0  (
	.D(\gw3_top/eye_calib_rdata [80]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[40])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_39_s0  (
	.D(\gw3_top/eye_calib_rdata [23]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[39])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_38_s0  (
	.D(\gw3_top/eye_calib_rdata [22]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[38])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_37_s0  (
	.D(\gw3_top/eye_calib_rdata [21]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[37])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_36_s0  (
	.D(\gw3_top/eye_calib_rdata [20]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[36])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_35_s0  (
	.D(\gw3_top/eye_calib_rdata [19]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[35])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_34_s0  (
	.D(\gw3_top/eye_calib_rdata [18]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[34])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_33_s0  (
	.D(\gw3_top/eye_calib_rdata [17]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[33])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_32_s0  (
	.D(\gw3_top/eye_calib_rdata [16]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[32])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_31_s0  (
	.D(\gw3_top/eye_calib_rdata [79]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[31])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_30_s0  (
	.D(\gw3_top/eye_calib_rdata [78]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[30])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_29_s0  (
	.D(\gw3_top/eye_calib_rdata [77]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[29])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_28_s0  (
	.D(\gw3_top/eye_calib_rdata [76]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[28])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_27_s0  (
	.D(\gw3_top/eye_calib_rdata [75]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[27])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_26_s0  (
	.D(\gw3_top/eye_calib_rdata [74]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[26])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_25_s0  (
	.D(\gw3_top/eye_calib_rdata [73]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[25])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_24_s0  (
	.D(\gw3_top/eye_calib_rdata [72]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[24])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_23_s0  (
	.D(\gw3_top/eye_calib_rdata [15]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[23])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_22_s0  (
	.D(\gw3_top/eye_calib_rdata [14]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[22])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_21_s0  (
	.D(\gw3_top/eye_calib_rdata [13]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[21])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_20_s0  (
	.D(\gw3_top/eye_calib_rdata [12]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[20])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_19_s0  (
	.D(\gw3_top/eye_calib_rdata [11]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[19])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_18_s0  (
	.D(\gw3_top/eye_calib_rdata [10]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[18])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_17_s0  (
	.D(\gw3_top/eye_calib_rdata [9]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[17])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_16_s0  (
	.D(\gw3_top/eye_calib_rdata [8]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[16])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_15_s0  (
	.D(\gw3_top/eye_calib_rdata [71]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[15])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_14_s0  (
	.D(\gw3_top/eye_calib_rdata [70]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[14])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_13_s0  (
	.D(\gw3_top/eye_calib_rdata [69]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[13])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_12_s0  (
	.D(\gw3_top/eye_calib_rdata [68]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[12])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_11_s0  (
	.D(\gw3_top/eye_calib_rdata [67]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[11])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_10_s0  (
	.D(\gw3_top/eye_calib_rdata [66]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[10])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_9_s0  (
	.D(\gw3_top/eye_calib_rdata [65]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[9])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_8_s0  (
	.D(\gw3_top/eye_calib_rdata [64]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[8])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_7_s0  (
	.D(\gw3_top/eye_calib_rdata [7]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[7])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_6_s0  (
	.D(\gw3_top/eye_calib_rdata [6]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[6])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_5_s0  (
	.D(\gw3_top/eye_calib_rdata [5]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[5])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_4_s0  (
	.D(\gw3_top/eye_calib_rdata [4]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[4])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_3_s0  (
	.D(\gw3_top/eye_calib_rdata [3]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[3])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_2_s0  (
	.D(\gw3_top/eye_calib_rdata [2]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[2])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_1_s0  (
	.D(\gw3_top/eye_calib_rdata [1]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[1])
);
DFFCE \gw3_top/u_gwmc_top/phy_rd_data_dly_0_s0  (
	.D(\gw3_top/eye_calib_rdata [0]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data[0])
);
DFFCE \gw3_top/u_gwmc_top/phy_rddata_valid_dly_s0  (
	.D(\gw3_top/phy_rd_data_valid ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(rd_data_valid)
);
DFFCE \gw3_top/u_gwmc_top/eye_calib_start_cmd_s0  (
	.D(\gw3_top/eye_calib_start_Z ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/eye_calib_start_cmd )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_175_G[0]_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[25]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[25]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_178_G[2]_1 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_175_G[0]_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[25]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[25]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_179_G[2]_1 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_175_G[0]_s5  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[25]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[25]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_180_G[2]_1 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_175_G[0]_s6  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[25]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[25]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_181_G[2]_1 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_182_G[0]_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[26]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[26]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_185_G[2]_1 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_182_G[0]_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[26]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[26]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_186_G[2]_1 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_182_G[0]_s5  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[26]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[26]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_187_G[2]_1 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_182_G[0]_s6  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[26]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[26]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_188_G[2]_1 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_189_G[0]_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[27]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[27]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_192_G[2]_1 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_189_G[0]_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[27]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[27]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_193_G[2]_1 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_189_G[0]_s5  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[27]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[27]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_194_G[2]_1 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_189_G[0]_s6  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[27]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[27]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_195_G[2]_1 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n468_s24  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0] [14]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1] [14]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n468_20 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n468_s25  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2] [14]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3] [14]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n468_21 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n468_s26  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4] [14]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5] [14]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n468_22 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n468_s27  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6] [14]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7] [14]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n468_23 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n469_s24  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0] [13]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1] [13]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n469_20 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n469_s25  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2] [13]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3] [13]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n469_21 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n469_s26  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4] [13]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5] [13]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n469_22 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n469_s27  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6] [13]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7] [13]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n469_23 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n470_s24  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0] [12]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1] [12]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n470_20 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n470_s25  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2] [12]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3] [12]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n470_21 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n470_s26  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4] [12]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5] [12]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n470_22 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n470_s27  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6] [12]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7] [12]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n470_23 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n471_s24  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0] [11]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1] [11]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n471_20 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n471_s25  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2] [11]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3] [11]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n471_21 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n471_s26  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4] [11]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5] [11]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n471_22 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n471_s27  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6] [11]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7] [11]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n471_23 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n472_s24  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0] [10]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1] [10]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n472_20 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n472_s25  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2] [10]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3] [10]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n472_21 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n472_s26  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4] [10]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5] [10]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n472_22 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n472_s27  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6] [10]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7] [10]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n472_23 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n473_s24  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0] [9]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1] [9]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n473_20 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n473_s25  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2] [9]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3] [9]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n473_21 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n473_s26  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4] [9]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5] [9]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n473_22 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n473_s27  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6] [9]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7] [9]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n473_23 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n474_s24  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0] [8]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1] [8]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n474_20 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n474_s25  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2] [8]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3] [8]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n474_21 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n474_s26  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4] [8]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5] [8]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n474_22 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n474_s27  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6] [8]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7] [8]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n474_23 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n475_s24  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0] [7]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1] [7]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n475_20 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n475_s25  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2] [7]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3] [7]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n475_21 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n475_s26  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4] [7]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5] [7]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n475_22 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n475_s27  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6] [7]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7] [7]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n475_23 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n476_s24  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0] [6]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1] [6]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n476_20 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n476_s25  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2] [6]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3] [6]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n476_21 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n476_s26  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4] [6]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5] [6]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n476_22 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n476_s27  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6] [6]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7] [6]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n476_23 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n477_s24  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0] [5]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1] [5]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n477_20 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n477_s25  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2] [5]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3] [5]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n477_21 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n477_s26  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4] [5]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5] [5]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n477_22 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n477_s27  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6] [5]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7] [5]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n477_23 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n478_s24  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0] [4]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1] [4]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n478_20 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n478_s25  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2] [4]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3] [4]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n478_21 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n478_s26  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4] [4]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5] [4]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n478_22 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n478_s27  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6] [4]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7] [4]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n478_23 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n479_s24  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0] [3]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1] [3]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n479_20 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n479_s25  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2] [3]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3] [3]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n479_21 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n479_s26  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4] [3]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5] [3]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n479_22 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n479_s27  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6] [3]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7] [3]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n479_23 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n480_s24  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0] [2]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1] [2]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n480_20 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n480_s25  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2] [2]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3] [2]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n480_21 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n480_s26  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4] [2]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5] [2]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n480_22 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n480_s27  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6] [2]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7] [2]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n480_23 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n481_s24  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0] [1]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1] [1]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n481_20 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n481_s25  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2] [1]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3] [1]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n481_21 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n481_s26  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4] [1]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5] [1]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n481_22 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n481_s27  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6] [1]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7] [1]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n481_23 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n482_s24  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0] [0]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1] [0]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n482_20 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n482_s25  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2] [0]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3] [0]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n482_21 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n482_s26  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4] [0]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5] [0]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n482_22 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n482_s27  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6] [0]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7] [0]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n482_23 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_0_G[0]_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[0]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[0]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_3_G[2]_9 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_0_G[0]_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[0]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[0]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_3_G[2]_10 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_0_G[0]_s5  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[0]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[0]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_3_G[2]_11 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_0_G[0]_s6  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[0]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[0]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_3_G[2]_12 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_7_G[0]_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[1]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[1]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_10_G[2]_9 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_7_G[0]_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[1]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[1]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_10_G[2]_10 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_7_G[0]_s5  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[1]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[1]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_10_G[2]_11 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_7_G[0]_s6  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[1]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[1]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_10_G[2]_12 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_14_G[0]_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[2]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[2]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_17_G[2]_9 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_14_G[0]_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[2]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[2]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_17_G[2]_10 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_14_G[0]_s5  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[2]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[2]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_17_G[2]_11 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_14_G[0]_s6  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[2]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[2]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_17_G[2]_12 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_21_G[0]_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[3]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[3]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_24_G[2]_9 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_21_G[0]_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[3]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[3]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_24_G[2]_10 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_21_G[0]_s5  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[3]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[3]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_24_G[2]_11 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_21_G[0]_s6  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[3]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[3]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_24_G[2]_12 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_28_G[0]_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[4]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[4]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_31_G[2]_9 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_28_G[0]_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[4]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[4]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_31_G[2]_10 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_28_G[0]_s5  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[4]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[4]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_31_G[2]_11 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_28_G[0]_s6  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[4]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[4]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_31_G[2]_12 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_35_G[0]_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[5]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[5]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_38_G[2]_9 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_35_G[0]_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[5]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[5]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_38_G[2]_10 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_35_G[0]_s5  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[5]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[5]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_38_G[2]_11 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_35_G[0]_s6  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[5]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[5]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_38_G[2]_12 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_42_G[0]_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[6]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[6]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_45_G[2]_9 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_42_G[0]_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[6]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[6]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_45_G[2]_10 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_42_G[0]_s5  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[6]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[6]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_45_G[2]_11 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_42_G[0]_s6  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[6]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[6]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_45_G[2]_12 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_49_G[0]_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[7]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[7]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_52_G[2]_9 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_49_G[0]_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[7]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[7]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_52_G[2]_10 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_49_G[0]_s5  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[7]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[7]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_52_G[2]_11 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_49_G[0]_s6  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[7]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[7]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_52_G[2]_12 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_56_G[0]_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[8]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[8]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_59_G[2]_9 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_56_G[0]_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[8]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[8]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_59_G[2]_10 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_56_G[0]_s5  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[8]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[8]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_59_G[2]_11 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_56_G[0]_s6  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[8]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[8]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_59_G[2]_12 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_63_G[0]_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[9]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[9]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_66_G[2]_9 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_63_G[0]_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[9]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[9]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_66_G[2]_10 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_63_G[0]_s5  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[9]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[9]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_66_G[2]_11 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_63_G[0]_s6  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[9]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[9]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_66_G[2]_12 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_70_G[0]_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[10]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[10]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_73_G[2]_9 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_70_G[0]_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[10]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[10]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_73_G[2]_10 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_70_G[0]_s5  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[10]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[10]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_73_G[2]_11 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_70_G[0]_s6  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[10]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[10]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_73_G[2]_12 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_77_G[0]_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[11]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[11]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_80_G[2]_9 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_77_G[0]_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[11]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[11]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_80_G[2]_10 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_77_G[0]_s5  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[11]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[11]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_80_G[2]_11 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_77_G[0]_s6  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[11]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[11]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_80_G[2]_12 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_84_G[0]_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[12]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[12]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_87_G[2]_9 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_84_G[0]_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[12]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[12]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_87_G[2]_10 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_84_G[0]_s5  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[12]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[12]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_87_G[2]_11 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_84_G[0]_s6  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[12]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[12]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_87_G[2]_12 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_91_G[0]_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[13]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[13]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_94_G[2]_9 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_91_G[0]_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[13]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[13]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_94_G[2]_10 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_91_G[0]_s5  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[13]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[13]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_94_G[2]_11 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_91_G[0]_s6  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[13]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[13]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_94_G[2]_12 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_98_G[0]_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[14]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[14]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_101_G[2]_9 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_98_G[0]_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[14]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[14]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_101_G[2]_10 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_98_G[0]_s5  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[14]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[14]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_101_G[2]_11 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_98_G[0]_s6  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[14]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[14]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_101_G[2]_12 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_105_G[0]_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[15]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[15]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_108_G[2]_9 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_105_G[0]_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[15]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[15]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_108_G[2]_10 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_105_G[0]_s5  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[15]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[15]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_108_G[2]_11 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_105_G[0]_s6  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[15]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[15]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_108_G[2]_12 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_112_G[0]_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[16]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[16]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_115_G[2]_9 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_112_G[0]_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[16]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[16]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_115_G[2]_10 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_112_G[0]_s5  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[16]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[16]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_115_G[2]_11 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_112_G[0]_s6  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[16]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[16]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_115_G[2]_12 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_119_G[0]_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[17]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[17]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_122_G[2]_9 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_119_G[0]_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[17]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[17]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_122_G[2]_10 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_119_G[0]_s5  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[17]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[17]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_122_G[2]_11 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_119_G[0]_s6  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[17]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[17]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_122_G[2]_12 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_126_G[0]_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[18]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[18]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_129_G[2]_9 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_126_G[0]_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[18]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[18]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_129_G[2]_10 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_126_G[0]_s5  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[18]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[18]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_129_G[2]_11 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_126_G[0]_s6  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[18]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[18]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_129_G[2]_12 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_133_G[0]_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[19]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[19]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_136_G[2]_9 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_133_G[0]_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[19]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[19]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_136_G[2]_10 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_133_G[0]_s5  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[19]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[19]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_136_G[2]_11 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_133_G[0]_s6  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[19]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[19]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_136_G[2]_12 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_140_G[0]_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[20]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[20]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_143_G[2]_9 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_140_G[0]_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[20]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[20]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_143_G[2]_10 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_140_G[0]_s5  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[20]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[20]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_143_G[2]_11 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_140_G[0]_s6  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[20]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[20]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_143_G[2]_12 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_147_G[0]_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[21]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[21]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_150_G[2]_9 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_147_G[0]_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[21]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[21]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_150_G[2]_10 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_147_G[0]_s5  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[21]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[21]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_150_G[2]_11 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_147_G[0]_s6  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[21]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[21]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_150_G[2]_12 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_154_G[0]_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[22]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[22]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_157_G[2]_9 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_154_G[0]_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[22]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[22]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_157_G[2]_10 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_154_G[0]_s5  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[22]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[22]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_157_G[2]_11 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_154_G[0]_s6  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[22]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[22]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_157_G[2]_12 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_161_G[0]_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[23]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[23]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_164_G[2]_9 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_161_G[0]_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[23]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[23]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_164_G[2]_10 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_161_G[0]_s5  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[23]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[23]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_164_G[2]_11 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_161_G[0]_s6  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[23]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[23]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_164_G[2]_12 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_168_G[0]_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[24]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[24]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_171_G[2]_9 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_168_G[0]_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[24]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[24]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_171_G[2]_10 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_168_G[0]_s5  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[24]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[24]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_171_G[2]_11 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_168_G[0]_s6  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[24]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[24]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_171_G[2]_12 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_196_G[0]_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[28]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[28]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_199_G[2]_9 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_196_G[0]_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[28]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[28]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_199_G[2]_10 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_196_G[0]_s5  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[28]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[28]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_199_G[2]_11 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_196_G[0]_s6  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[28]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[28]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_199_G[2]_12 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_203_G[0]_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[29]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[29]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_206_G[2]_9 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_203_G[0]_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[29]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[29]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_206_G[2]_10 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_203_G[0]_s5  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[29]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[29]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_206_G[2]_11 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_203_G[0]_s6  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[29]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[29]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_206_G[2]_12 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_210_G[0]_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[30]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[30]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_213_G[2]_9 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_210_G[0]_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[30]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[30]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_213_G[2]_10 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_210_G[0]_s5  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[30]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[30]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_213_G[2]_11 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_210_G[0]_s6  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[30]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[30]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_213_G[2]_12 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_217_G[0]_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[31]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[31]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_220_G[2]_9 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_217_G[0]_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[31]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[31]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_220_G[2]_10 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_217_G[0]_s5  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[31]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[31]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_220_G[2]_11 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_217_G[0]_s6  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[31]_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[31]_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_220_G[2]_12 )
);
LUT4 \gw3_top/u_gwmc_top/gw_cmd0/n41_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n41_4 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/next_waddr [2]),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.I3(\gw3_top/u_gwmc_top/app_en ),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n41_3 )
);
LUT2 \gw3_top/u_gwmc_top/gw_cmd0/n183_s0  (
	.I0(\gw3_top/u_gwmc_top/app_addr [27]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n183_4 ),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n183_3 )
);
LUT2 \gw3_top/u_gwmc_top/gw_cmd0/n218_s0  (
	.I0(\gw3_top/u_gwmc_top/app_addr [26]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n218_4 ),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n218_3 )
);
LUT2 \gw3_top/u_gwmc_top/gw_cmd0/n253_s0  (
	.I0(\gw3_top/u_gwmc_top/app_addr [27]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n253_4 ),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n253_3 )
);
LUT2 \gw3_top/u_gwmc_top/gw_cmd0/n289_s0  (
	.I0(\gw3_top/u_gwmc_top/app_addr [26]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n218_4 ),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n289_3 )
);
LUT2 \gw3_top/u_gwmc_top/gw_cmd0/n324_s0  (
	.I0(\gw3_top/u_gwmc_top/app_addr [27]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n183_4 ),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n324_3 )
);
LUT2 \gw3_top/u_gwmc_top/gw_cmd0/n360_s0  (
	.I0(\gw3_top/u_gwmc_top/app_addr [26]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n360_4 ),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n360_3 )
);
LUT2 \gw3_top/u_gwmc_top/gw_cmd0/n396_s0  (
	.I0(\gw3_top/u_gwmc_top/app_addr [27]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n253_4 ),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n396_3 )
);
LUT2 \gw3_top/u_gwmc_top/gw_cmd0/n433_s0  (
	.I0(\gw3_top/u_gwmc_top/app_addr [26]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n360_4 ),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n433_3 )
);
LUT2 \gw3_top/u_gwmc_top/gw_cmd0/write_s0  (
	.I0(\gw3_top/u_gwmc_top/app_cmd [0]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/write_4 ),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/write )
);
LUT2 \gw3_top/u_gwmc_top/gw_cmd0/read_s0  (
	.I0(\gw3_top/u_gwmc_top/app_cmd [0]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/write_4 ),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/read )
);
LUT2 \gw3_top/u_gwmc_top/gw_cmd0/cmd_write_Z_s  (
	.I0(\gw3_top/u_gwmc_top/cmd_empty_Z ),
	.I1(\gw3_top/u_gwmc_top/mem_RAMOUT_196_G[0]_4 ),
	.F(\gw3_top/u_gwmc_top/cmd_write_Z )
);
LUT2 \gw3_top/u_gwmc_top/gw_cmd0/cmd_read_Z_s  (
	.I0(\gw3_top/u_gwmc_top/cmd_empty_Z ),
	.I1(\gw3_top/u_gwmc_top/mem_RAMOUT_203_G[0]_4 ),
	.F(\gw3_top/u_gwmc_top/cmd_read_Z )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/cmd_empty_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/cmd_empty_6 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/cmd_empty_7 ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/cmd_empty_8 ),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/cmd_empty_5 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_s333  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/waddr [1]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/waddr [2]),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/mem_355 ),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_335 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_s334  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/waddr [1]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/waddr [2]),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/mem_353 ),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_337 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_s335  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/waddr [2]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/waddr [1]),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/mem_355 ),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_339 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_s336  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/waddr [2]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/waddr [1]),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/mem_353 ),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_341 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_s337  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/waddr [1]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/waddr [2]),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/mem_355 ),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_343 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_s338  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/waddr [1]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/waddr [2]),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/mem_353 ),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_345 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_s339  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/waddr [1]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/waddr [2]),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/mem_355 ),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_347 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/mem_s340  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/waddr [1]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/waddr [2]),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/mem_353 ),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_349 )
);
LUT2 \gw3_top/u_gwmc_top/gw_cmd0/next_waddr_1_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/waddr [0]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/waddr [1]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/next_waddr [1])
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/next_waddr_2_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/waddr [0]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/waddr [1]),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/waddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/next_waddr [2])
);
LUT2 \gw3_top/u_gwmc_top/gw_cmd0/next_raddr_1_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/next_raddr [1])
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/next_raddr_2_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/next_raddr [2])
);
LUT4 \gw3_top/u_gwmc_top/gw_cmd0/n34_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n19_3 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/full_invalid ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/n27_2 ),
	.I3(\gw3_top/u_gwmc_top/cmd_accept_Z ),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n34_6 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n75_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n19_3 ),
	.I1(\gw3_top/mc_ras_n_Z [3]),
	.I2(\gw3_top/u_gwmc_top/app_en ),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n75_7 )
);
LUT4 \gw3_top/u_gwmc_top/gw_cmd0/n41_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/waddr [1]),
	.I3(\gw3_top/u_gwmc_top/gw_cmd0/waddr [0]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n41_4 )
);
LUT4 \gw3_top/u_gwmc_top/gw_cmd0/n183_s1  (
	.I0(\gw3_top/u_gwmc_top/app_addr [26]),
	.I1(\gw3_top/u_gwmc_top/app_addr [25]),
	.I2(\gw3_top/u_gwmc_top/app_en ),
	.I3(\gw3_top/u_gwmc_top/mc_ras_n_dly [3]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n183_4 )
);
LUT4 \gw3_top/u_gwmc_top/gw_cmd0/n218_s1  (
	.I0(\gw3_top/u_gwmc_top/app_addr [27]),
	.I1(\gw3_top/u_gwmc_top/mc_ras_n_dly [3]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.I3(\gw3_top/u_gwmc_top/app_en ),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n218_4 )
);
LUT4 \gw3_top/u_gwmc_top/gw_cmd0/n253_s1  (
	.I0(\gw3_top/u_gwmc_top/app_addr [25]),
	.I1(\gw3_top/u_gwmc_top/mc_ras_n_dly [3]),
	.I2(\gw3_top/u_gwmc_top/app_addr [26]),
	.I3(\gw3_top/u_gwmc_top/app_en ),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n253_4 )
);
LUT4 \gw3_top/u_gwmc_top/gw_cmd0/n360_s1  (
	.I0(\gw3_top/u_gwmc_top/app_en ),
	.I1(\gw3_top/u_gwmc_top/mc_ras_n_dly [3]),
	.I2(\gw3_top/u_gwmc_top/app_addr [25]),
	.I3(\gw3_top/u_gwmc_top/app_addr [27]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n360_4 )
);
LUT4 \gw3_top/u_gwmc_top/gw_cmd0/write_s1  (
	.I0(\gw3_top/u_gwmc_top/app_cmd [1]),
	.I1(\gw3_top/u_gwmc_top/app_cmd [2]),
	.I2(\gw3_top/u_gwmc_top/app_en ),
	.I3(\gw3_top/u_gwmc_top/mc_ras_n_dly [3]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/write_4 )
);
LUT4 \gw3_top/u_gwmc_top/gw_cmd0/cmd_empty_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/waddr [1]),
	.I3(\gw3_top/u_gwmc_top/gw_cmd0/waddr [0]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/cmd_empty_6 )
);
LUT4 \gw3_top/u_gwmc_top/gw_cmd0/cmd_empty_s5  (
	.I0(\gw3_top/u_gwmc_top/app_en ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/waddr [2]),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/next_raddr [2]),
	.I3(\gw3_top/u_gwmc_top/cmd_accept_Z ),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/cmd_empty_7 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/cmd_empty_s6  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n19_3 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/full_invalid ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/n75_7 ),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/cmd_empty_8 )
);
LUT4 \gw3_top/u_gwmc_top/gw_cmd0/mem_s343  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/waddr [0]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/full_rr ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/full_r ),
	.I3(\gw3_top/u_gwmc_top/app_en ),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_353 )
);
LUT4 \gw3_top/u_gwmc_top/gw_cmd0/mem_s344  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/waddr [0]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/full_rr ),
	.I2(\gw3_top/u_gwmc_top/gw_cmd0/full_r ),
	.I3(\gw3_top/u_gwmc_top/app_en ),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/mem_355 )
);
LUT4 \gw3_top/u_gwmc_top/gw_cmd0/next_waddr_0_s6  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/full_rr ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/full_r ),
	.I2(\gw3_top/u_gwmc_top/app_en ),
	.I3(\gw3_top/u_gwmc_top/gw_cmd0/waddr [0]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/next_waddr_0_15 )
);
LUT3 \gw3_top/u_gwmc_top/gw_cmd0/n510_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/full_r ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/full_rr ),
	.I2(\gw3_top/u_gwmc_top/app_en ),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/n510_5 )
);
LUT4 \gw3_top/u_gwmc_top/gw_cmd0/next_raddr_0_s6  (
	.I0(\gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_WRITE ),
	.I1(\gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_READ ),
	.I2(\gw3_top/u_gwmc_top/cmd_empty_Z ),
	.I3(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/next_raddr_0_12 )
);
LUT4 \gw3_top/u_gwmc_top/gw_cmd0/full_invalid_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n41_3 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_READ ),
	.I2(\gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_WRITE ),
	.I3(\gw3_top/u_gwmc_top/cmd_empty_Z ),
	.F(\gw3_top/u_gwmc_top/gw_cmd0/full_invalid_10 )
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/full_rr_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/full_r ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/full_rr )
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/full_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/n34_6 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/full )
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/bank_in_tmp_2_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [27]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/app_en ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/bank_in_tmp [2])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/bank_in_tmp_1_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [26]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/app_en ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/bank_in_tmp [1])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/bank_in_tmp_0_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [25]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/app_en ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/bank_in_tmp [0])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0]_14_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [24]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n183_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0] [14])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0]_13_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [23]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n183_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0] [13])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0]_12_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [22]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n183_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0] [12])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0]_11_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [21]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n183_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0] [11])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0]_10_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [20]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n183_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0] [10])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0]_9_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [19]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n183_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0] [9])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0]_8_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [18]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n183_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0] [8])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0]_7_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [17]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n183_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0] [7])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0]_6_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [16]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n183_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0] [6])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0]_5_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [15]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n183_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0] [5])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0]_4_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [14]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n183_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0] [4])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0]_3_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [13]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n183_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0] [3])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0]_2_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [12]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n183_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0] [2])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0]_1_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [11]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n183_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0] [1])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0]_0_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [10]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n183_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0] [0])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1]_14_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [24]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n218_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1] [14])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1]_13_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [23]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n218_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1] [13])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1]_12_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [22]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n218_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1] [12])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1]_11_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [21]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n218_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1] [11])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1]_10_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [20]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n218_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1] [10])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1]_9_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [19]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n218_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1] [9])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1]_8_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [18]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n218_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1] [8])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1]_7_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [17]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n218_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1] [7])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1]_6_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [16]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n218_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1] [6])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1]_5_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [15]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n218_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1] [5])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1]_4_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [14]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n218_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1] [4])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1]_3_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [13]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n218_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1] [3])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1]_2_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [12]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n218_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1] [2])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1]_1_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [11]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n218_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1] [1])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1]_0_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [10]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n218_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1] [0])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2]_14_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [24]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n253_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2] [14])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2]_13_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [23]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n253_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2] [13])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2]_12_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [22]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n253_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2] [12])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2]_11_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [21]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n253_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2] [11])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2]_10_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [20]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n253_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2] [10])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2]_9_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [19]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n253_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2] [9])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2]_8_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [18]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n253_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2] [8])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2]_7_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [17]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n253_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2] [7])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2]_6_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [16]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n253_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2] [6])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2]_5_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [15]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n253_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2] [5])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2]_4_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [14]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n253_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2] [4])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2]_3_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [13]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n253_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2] [3])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2]_2_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [12]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n253_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2] [2])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2]_1_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [11]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n253_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2] [1])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2]_0_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [10]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n253_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2] [0])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3]_14_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [24]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n289_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3] [14])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3]_13_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [23]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n289_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3] [13])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3]_12_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [22]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n289_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3] [12])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3]_11_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [21]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n289_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3] [11])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3]_10_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [20]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n289_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3] [10])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3]_9_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [19]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n289_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3] [9])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3]_8_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [18]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n289_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3] [8])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3]_7_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [17]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n289_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3] [7])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3]_6_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [16]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n289_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3] [6])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3]_5_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [15]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n289_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3] [5])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3]_4_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [14]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n289_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3] [4])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3]_3_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [13]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n289_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3] [3])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3]_2_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [12]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n289_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3] [2])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3]_1_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [11]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n289_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3] [1])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3]_0_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [10]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n289_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3] [0])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4]_14_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [24]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n324_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4] [14])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4]_13_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [23]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n324_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4] [13])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4]_12_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [22]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n324_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4] [12])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4]_11_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [21]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n324_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4] [11])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4]_10_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [20]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n324_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4] [10])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4]_9_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [19]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n324_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4] [9])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4]_8_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [18]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n324_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4] [8])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4]_7_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [17]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n324_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4] [7])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4]_6_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [16]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n324_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4] [6])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4]_5_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [15]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n324_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4] [5])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4]_4_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [14]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n324_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4] [4])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4]_3_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [13]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n324_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4] [3])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4]_2_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [12]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n324_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4] [2])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4]_1_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [11]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n324_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4] [1])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4]_0_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [10]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n324_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4] [0])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5]_14_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [24]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n360_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5] [14])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5]_13_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [23]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n360_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5] [13])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5]_12_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [22]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n360_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5] [12])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5]_11_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [21]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n360_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5] [11])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5]_10_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [20]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n360_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5] [10])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5]_9_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [19]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n360_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5] [9])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5]_8_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [18]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n360_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5] [8])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5]_7_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [17]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n360_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5] [7])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5]_6_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [16]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n360_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5] [6])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5]_5_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [15]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n360_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5] [5])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5]_4_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [14]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n360_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5] [4])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5]_3_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [13]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n360_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5] [3])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5]_2_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [12]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n360_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5] [2])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5]_1_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [11]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n360_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5] [1])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5]_0_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [10]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n360_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5] [0])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6]_14_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [24]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n396_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6] [14])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6]_13_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [23]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n396_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6] [13])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6]_12_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [22]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n396_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6] [12])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6]_11_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [21]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n396_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6] [11])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6]_10_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [20]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n396_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6] [10])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6]_9_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [19]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n396_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6] [9])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6]_8_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [18]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n396_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6] [8])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6]_7_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [17]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n396_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6] [7])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6]_6_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [16]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n396_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6] [6])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6]_5_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [15]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n396_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6] [5])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6]_4_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [14]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n396_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6] [4])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6]_3_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [13]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n396_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6] [3])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6]_2_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [12]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n396_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6] [2])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6]_1_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [11]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n396_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6] [1])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6]_0_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [10]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n396_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6] [0])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7]_14_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [24]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n433_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7] [14])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7]_13_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [23]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n433_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7] [13])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7]_12_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [22]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n433_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7] [12])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7]_11_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [21]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n433_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7] [11])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7]_10_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [20]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n433_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7] [10])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7]_9_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [19]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n433_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7] [9])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7]_8_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [18]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n433_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7] [8])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7]_7_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [17]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n433_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7] [7])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7]_6_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [16]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n433_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7] [6])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7]_5_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [15]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n433_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7] [5])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7]_4_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [14]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n433_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7] [4])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7]_3_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [13]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n433_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7] [3])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7]_2_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [12]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n433_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7] [2])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7]_1_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [11]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n433_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7] [1])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7]_0_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [10]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n433_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7] [0])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/waddr_2_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/next_waddr [2]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n510_5 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/waddr [2])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/waddr_1_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/next_waddr [1]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/n510_5 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/waddr [1])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/raddr_2_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/next_raddr [2]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/cmd_accept_Z ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/raddr_1_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/next_raddr [1]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/cmd_accept_Z ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/full_r_s0  (
	.D(\gw3_top/full ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/full_r )
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/full_invalid_s1  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/n41_3 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/full_invalid_10 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/full_invalid )
);
DFFPE \gw3_top/u_gwmc_top/gw_cmd0/cmd_empty_s1  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/n75_7 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/cmd_empty_5 ),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/cmd_empty_Z )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[0]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [0]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_335 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[0]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[1]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [1]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_335 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[1]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[2]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [2]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_335 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[2]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[3]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [3]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_335 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[3]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[4]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [4]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_335 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[4]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[5]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [5]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_335 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[5]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[6]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [6]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_335 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[6]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[7]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [7]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_335 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[7]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[8]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [8]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_335 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[8]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[9]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [9]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_335 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[9]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[10]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [10]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_335 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[10]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[11]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [11]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_335 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[11]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[12]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [12]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_335 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[12]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[13]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [13]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_335 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[13]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[14]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [14]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_335 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[14]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[15]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [15]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_335 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[15]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[16]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [16]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_335 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[16]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[17]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [17]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_335 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[17]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[18]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [18]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_335 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[18]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[19]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [19]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_335 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[19]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[20]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [20]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_335 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[20]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[21]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [21]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_335 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[21]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[22]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [22]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_335 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[22]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[23]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [23]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_335 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[23]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[24]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [24]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_335 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[24]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[25]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [25]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_335 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[25]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[26]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [26]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_335 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[26]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[27]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [27]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_335 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[27]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[28]_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/write ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_335 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[28]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[29]_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/read ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_335 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[29]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[30]_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/row_change ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_335 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[30]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[31]_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/bank_change ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_335 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[31]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[0]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [0]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_337 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[0]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[1]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [1]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_337 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[1]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[2]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [2]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_337 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[2]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[3]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [3]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_337 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[3]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[4]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [4]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_337 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[4]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[5]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [5]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_337 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[5]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[6]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [6]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_337 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[6]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[7]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [7]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_337 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[7]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[8]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [8]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_337 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[8]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[9]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [9]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_337 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[9]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[10]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [10]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_337 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[10]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[11]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [11]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_337 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[11]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[12]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [12]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_337 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[12]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[13]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [13]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_337 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[13]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[14]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [14]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_337 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[14]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[15]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [15]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_337 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[15]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[16]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [16]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_337 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[16]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[17]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [17]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_337 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[17]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[18]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [18]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_337 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[18]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[19]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [19]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_337 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[19]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[20]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [20]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_337 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[20]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[21]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [21]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_337 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[21]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[22]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [22]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_337 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[22]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[23]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [23]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_337 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[23]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[24]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [24]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_337 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[24]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[25]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [25]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_337 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[25]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[26]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [26]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_337 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[26]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[27]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [27]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_337 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[27]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[28]_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/write ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_337 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[28]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[29]_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/read ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_337 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[29]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[30]_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/row_change ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_337 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[30]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[31]_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/bank_change ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_337 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[31]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[0]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [0]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_339 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[0]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[1]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [1]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_339 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[1]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[2]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [2]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_339 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[2]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[3]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [3]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_339 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[3]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[4]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [4]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_339 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[4]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[5]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [5]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_339 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[5]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[6]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [6]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_339 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[6]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[7]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [7]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_339 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[7]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[8]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [8]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_339 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[8]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[9]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [9]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_339 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[9]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[10]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [10]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_339 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[10]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[11]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [11]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_339 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[11]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[12]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [12]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_339 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[12]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[13]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [13]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_339 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[13]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[14]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [14]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_339 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[14]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[15]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [15]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_339 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[15]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[16]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [16]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_339 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[16]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[17]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [17]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_339 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[17]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[18]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [18]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_339 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[18]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[19]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [19]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_339 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[19]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[20]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [20]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_339 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[20]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[21]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [21]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_339 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[21]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[22]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [22]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_339 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[22]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[23]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [23]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_339 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[23]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[24]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [24]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_339 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[24]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[25]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [25]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_339 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[25]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[26]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [26]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_339 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[26]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[27]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [27]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_339 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[27]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[28]_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/write ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_339 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[28]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[29]_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/read ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_339 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[29]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[30]_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/row_change ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_339 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[30]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[31]_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/bank_change ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_339 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[31]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[0]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [0]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_341 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[0]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[1]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [1]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_341 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[1]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[2]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [2]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_341 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[2]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[3]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [3]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_341 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[3]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[4]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [4]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_341 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[4]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[5]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [5]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_341 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[5]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[6]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [6]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_341 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[6]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[7]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [7]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_341 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[7]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[8]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [8]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_341 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[8]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[9]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [9]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_341 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[9]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[10]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [10]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_341 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[10]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[11]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [11]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_341 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[11]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[12]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [12]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_341 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[12]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[13]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [13]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_341 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[13]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[14]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [14]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_341 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[14]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[15]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [15]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_341 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[15]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[16]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [16]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_341 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[16]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[17]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [17]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_341 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[17]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[18]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [18]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_341 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[18]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[19]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [19]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_341 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[19]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[20]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [20]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_341 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[20]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[21]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [21]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_341 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[21]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[22]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [22]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_341 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[22]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[23]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [23]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_341 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[23]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[24]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [24]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_341 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[24]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[25]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [25]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_341 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[25]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[26]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [26]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_341 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[26]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[27]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [27]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_341 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[27]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[28]_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/write ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_341 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[28]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[29]_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/read ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_341 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[29]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[30]_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/row_change ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_341 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[30]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[31]_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/bank_change ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_341 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[31]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[0]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [0]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_343 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[0]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[1]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [1]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_343 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[1]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[2]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [2]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_343 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[2]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[3]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [3]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_343 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[3]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[4]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [4]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_343 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[4]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[5]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [5]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_343 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[5]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[6]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [6]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_343 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[6]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[7]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [7]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_343 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[7]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[8]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [8]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_343 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[8]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[9]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [9]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_343 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[9]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[10]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [10]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_343 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[10]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[11]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [11]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_343 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[11]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[12]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [12]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_343 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[12]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[13]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [13]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_343 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[13]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[14]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [14]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_343 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[14]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[15]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [15]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_343 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[15]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[16]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [16]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_343 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[16]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[17]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [17]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_343 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[17]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[18]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [18]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_343 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[18]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[19]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [19]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_343 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[19]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[20]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [20]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_343 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[20]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[21]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [21]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_343 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[21]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[22]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [22]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_343 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[22]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[23]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [23]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_343 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[23]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[24]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [24]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_343 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[24]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[25]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [25]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_343 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[25]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[26]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [26]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_343 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[26]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[27]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [27]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_343 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[27]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[28]_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/write ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_343 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[28]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[29]_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/read ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_343 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[29]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[30]_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/row_change ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_343 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[30]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[31]_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/bank_change ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_343 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[31]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[0]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [0]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_345 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[0]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[1]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [1]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_345 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[1]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[2]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [2]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_345 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[2]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[3]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [3]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_345 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[3]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[4]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [4]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_345 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[4]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[5]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [5]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_345 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[5]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[6]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [6]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_345 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[6]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[7]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [7]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_345 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[7]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[8]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [8]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_345 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[8]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[9]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [9]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_345 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[9]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[10]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [10]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_345 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[10]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[11]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [11]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_345 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[11]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[12]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [12]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_345 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[12]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[13]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [13]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_345 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[13]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[14]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [14]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_345 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[14]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[15]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [15]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_345 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[15]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[16]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [16]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_345 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[16]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[17]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [17]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_345 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[17]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[18]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [18]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_345 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[18]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[19]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [19]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_345 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[19]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[20]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [20]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_345 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[20]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[21]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [21]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_345 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[21]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[22]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [22]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_345 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[22]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[23]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [23]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_345 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[23]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[24]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [24]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_345 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[24]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[25]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [25]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_345 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[25]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[26]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [26]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_345 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[26]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[27]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [27]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_345 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[27]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[28]_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/write ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_345 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[28]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[29]_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/read ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_345 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[29]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[30]_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/row_change ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_345 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[30]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[31]_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/bank_change ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_345 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[31]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[0]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [0]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_347 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[0]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[1]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [1]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_347 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[1]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[2]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [2]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_347 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[2]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[3]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [3]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_347 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[3]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[4]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [4]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_347 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[4]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[5]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [5]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_347 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[5]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[6]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [6]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_347 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[6]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[7]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [7]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_347 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[7]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[8]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [8]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_347 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[8]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[9]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [9]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_347 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[9]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[10]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [10]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_347 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[10]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[11]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [11]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_347 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[11]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[12]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [12]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_347 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[12]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[13]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [13]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_347 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[13]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[14]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [14]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_347 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[14]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[15]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [15]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_347 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[15]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[16]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [16]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_347 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[16]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[17]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [17]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_347 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[17]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[18]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [18]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_347 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[18]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[19]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [19]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_347 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[19]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[20]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [20]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_347 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[20]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[21]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [21]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_347 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[21]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[22]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [22]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_347 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[22]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[23]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [23]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_347 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[23]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[24]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [24]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_347 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[24]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[25]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [25]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_347 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[25]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[26]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [26]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_347 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[26]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[27]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [27]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_347 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[27]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[28]_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/write ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_347 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[28]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[29]_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/read ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_347 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[29]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[30]_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/row_change ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_347 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[30]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[31]_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/bank_change ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_347 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[31]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[0]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [0]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_349 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[0]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[1]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [1]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_349 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[1]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[2]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [2]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_349 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[2]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[3]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [3]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_349 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[3]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[4]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [4]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_349 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[4]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[5]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [5]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_349 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[5]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[6]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [6]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_349 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[6]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[7]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [7]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_349 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[7]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[8]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [8]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_349 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[8]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[9]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [9]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_349 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[9]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[10]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [10]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_349 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[10]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[11]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [11]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_349 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[11]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[12]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [12]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_349 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[12]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[13]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [13]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_349 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[13]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[14]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [14]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_349 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[14]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[15]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [15]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_349 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[15]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[16]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [16]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_349 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[16]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[17]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [17]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_349 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[17]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[18]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [18]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_349 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[18]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[19]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [19]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_349 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[19]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[20]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [20]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_349 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[20]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[21]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [21]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_349 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[21]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[22]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [22]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_349 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[22]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[23]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [23]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_349 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[23]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[24]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [24]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_349 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[24]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[25]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [25]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_349 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[25]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[26]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [26]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_349 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[26]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[27]_s0  (
	.D(\gw3_top/u_gwmc_top/app_addr [27]),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_349 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[27]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[28]_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/write ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_349 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[28]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[29]_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/read ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_349 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[29]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[30]_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/row_change ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_349 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[30]_4 )
);
DFFRE \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[31]_s0  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/bank_change ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gw_cmd0/mem_349 ),
	.RESET(GND),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[31]_4 )
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/waddr_0_s1  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/next_waddr_0_15 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/waddr [0])
);
DFFCE \gw3_top/u_gwmc_top/gw_cmd0/raddr_0_s1  (
	.D(\gw3_top/u_gwmc_top/gw_cmd0/next_raddr_0_12 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0])
);
ALU \gw3_top/u_gwmc_top/gw_cmd0/n29_s  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/waddr [0]),
	.I3(VCC),
	.CIN(VCC),
	.COUT(\gw3_top/u_gwmc_top/gw_cmd0/n29_3 ),
	.SUM(\gw3_top/u_gwmc_top/gw_cmd0/n29_0_SUM )
);
ALU \gw3_top/u_gwmc_top/gw_cmd0/n28_s  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/waddr [1]),
	.I3(VCC),
	.CIN(\gw3_top/u_gwmc_top/gw_cmd0/n29_3 ),
	.COUT(\gw3_top/u_gwmc_top/gw_cmd0/n28_3 ),
	.SUM(\gw3_top/u_gwmc_top/gw_cmd0/n28_0_SUM )
);
ALU \gw3_top/u_gwmc_top/gw_cmd0/n27_s  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/waddr [2]),
	.I3(VCC),
	.CIN(\gw3_top/u_gwmc_top/gw_cmd0/n28_3 ),
	.COUT(\gw3_top/u_gwmc_top/gw_cmd0/n27_0_COUT ),
	.SUM(\gw3_top/u_gwmc_top/gw_cmd0/n27_2 )
);
ALU \gw3_top/u_gwmc_top/gw_cmd0/n17_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/waddr [0]),
	.I3(GND),
	.CIN(GND),
	.COUT(\gw3_top/u_gwmc_top/gw_cmd0/n17_3 ),
	.SUM(\gw3_top/u_gwmc_top/gw_cmd0/n17_1_SUM )
);
ALU \gw3_top/u_gwmc_top/gw_cmd0/n18_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/waddr [1]),
	.I3(GND),
	.CIN(\gw3_top/u_gwmc_top/gw_cmd0/n17_3 ),
	.COUT(\gw3_top/u_gwmc_top/gw_cmd0/n18_3 ),
	.SUM(\gw3_top/u_gwmc_top/gw_cmd0/n18_1_SUM )
);
ALU \gw3_top/u_gwmc_top/gw_cmd0/n19_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [2]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/waddr [2]),
	.I3(GND),
	.CIN(\gw3_top/u_gwmc_top/gw_cmd0/n18_3 ),
	.COUT(\gw3_top/u_gwmc_top/gw_cmd0/n19_3 ),
	.SUM(\gw3_top/u_gwmc_top/gw_cmd0/n19_1_SUM )
);
ALU \gw3_top/u_gwmc_top/gw_cmd0/n464_s0  (
	.I0(\gw3_top/u_gwmc_top/app_addr [25]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/bank_in_tmp [0]),
	.I3(GND),
	.CIN(GND),
	.COUT(\gw3_top/u_gwmc_top/gw_cmd0/n464_3 ),
	.SUM(\gw3_top/u_gwmc_top/gw_cmd0/n464_1_SUM )
);
ALU \gw3_top/u_gwmc_top/gw_cmd0/n465_s0  (
	.I0(\gw3_top/u_gwmc_top/app_addr [26]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/bank_in_tmp [1]),
	.I3(GND),
	.CIN(\gw3_top/u_gwmc_top/gw_cmd0/n464_3 ),
	.COUT(\gw3_top/u_gwmc_top/gw_cmd0/n465_3 ),
	.SUM(\gw3_top/u_gwmc_top/gw_cmd0/n465_1_SUM )
);
ALU \gw3_top/u_gwmc_top/gw_cmd0/n466_s0  (
	.I0(\gw3_top/u_gwmc_top/app_addr [27]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/bank_in_tmp [2]),
	.I3(GND),
	.CIN(\gw3_top/u_gwmc_top/gw_cmd0/n465_3 ),
	.COUT(\gw3_top/u_gwmc_top/gw_cmd0/bank_change ),
	.SUM(\gw3_top/u_gwmc_top/gw_cmd0/n466_1_SUM )
);
ALU \gw3_top/u_gwmc_top/gw_cmd0/n483_s0  (
	.I0(\gw3_top/u_gwmc_top/app_addr [10]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n482_29 ),
	.I3(GND),
	.CIN(GND),
	.COUT(\gw3_top/u_gwmc_top/gw_cmd0/n483_3 ),
	.SUM(\gw3_top/u_gwmc_top/gw_cmd0/n483_1_SUM )
);
ALU \gw3_top/u_gwmc_top/gw_cmd0/n484_s0  (
	.I0(\gw3_top/u_gwmc_top/app_addr [11]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n481_29 ),
	.I3(GND),
	.CIN(\gw3_top/u_gwmc_top/gw_cmd0/n483_3 ),
	.COUT(\gw3_top/u_gwmc_top/gw_cmd0/n484_3 ),
	.SUM(\gw3_top/u_gwmc_top/gw_cmd0/n484_1_SUM )
);
ALU \gw3_top/u_gwmc_top/gw_cmd0/n485_s0  (
	.I0(\gw3_top/u_gwmc_top/app_addr [12]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n480_29 ),
	.I3(GND),
	.CIN(\gw3_top/u_gwmc_top/gw_cmd0/n484_3 ),
	.COUT(\gw3_top/u_gwmc_top/gw_cmd0/n485_3 ),
	.SUM(\gw3_top/u_gwmc_top/gw_cmd0/n485_1_SUM )
);
ALU \gw3_top/u_gwmc_top/gw_cmd0/n486_s0  (
	.I0(\gw3_top/u_gwmc_top/app_addr [13]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n479_29 ),
	.I3(GND),
	.CIN(\gw3_top/u_gwmc_top/gw_cmd0/n485_3 ),
	.COUT(\gw3_top/u_gwmc_top/gw_cmd0/n486_3 ),
	.SUM(\gw3_top/u_gwmc_top/gw_cmd0/n486_1_SUM )
);
ALU \gw3_top/u_gwmc_top/gw_cmd0/n487_s0  (
	.I0(\gw3_top/u_gwmc_top/app_addr [14]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n478_29 ),
	.I3(GND),
	.CIN(\gw3_top/u_gwmc_top/gw_cmd0/n486_3 ),
	.COUT(\gw3_top/u_gwmc_top/gw_cmd0/n487_3 ),
	.SUM(\gw3_top/u_gwmc_top/gw_cmd0/n487_1_SUM )
);
ALU \gw3_top/u_gwmc_top/gw_cmd0/n488_s0  (
	.I0(\gw3_top/u_gwmc_top/app_addr [15]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n477_29 ),
	.I3(GND),
	.CIN(\gw3_top/u_gwmc_top/gw_cmd0/n487_3 ),
	.COUT(\gw3_top/u_gwmc_top/gw_cmd0/n488_3 ),
	.SUM(\gw3_top/u_gwmc_top/gw_cmd0/n488_1_SUM )
);
ALU \gw3_top/u_gwmc_top/gw_cmd0/n489_s0  (
	.I0(\gw3_top/u_gwmc_top/app_addr [16]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n476_29 ),
	.I3(GND),
	.CIN(\gw3_top/u_gwmc_top/gw_cmd0/n488_3 ),
	.COUT(\gw3_top/u_gwmc_top/gw_cmd0/n489_3 ),
	.SUM(\gw3_top/u_gwmc_top/gw_cmd0/n489_1_SUM )
);
ALU \gw3_top/u_gwmc_top/gw_cmd0/n490_s0  (
	.I0(\gw3_top/u_gwmc_top/app_addr [17]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n475_29 ),
	.I3(GND),
	.CIN(\gw3_top/u_gwmc_top/gw_cmd0/n489_3 ),
	.COUT(\gw3_top/u_gwmc_top/gw_cmd0/n490_3 ),
	.SUM(\gw3_top/u_gwmc_top/gw_cmd0/n490_1_SUM )
);
ALU \gw3_top/u_gwmc_top/gw_cmd0/n491_s0  (
	.I0(\gw3_top/u_gwmc_top/app_addr [18]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n474_29 ),
	.I3(GND),
	.CIN(\gw3_top/u_gwmc_top/gw_cmd0/n490_3 ),
	.COUT(\gw3_top/u_gwmc_top/gw_cmd0/n491_3 ),
	.SUM(\gw3_top/u_gwmc_top/gw_cmd0/n491_1_SUM )
);
ALU \gw3_top/u_gwmc_top/gw_cmd0/n492_s0  (
	.I0(\gw3_top/u_gwmc_top/app_addr [19]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n473_29 ),
	.I3(GND),
	.CIN(\gw3_top/u_gwmc_top/gw_cmd0/n491_3 ),
	.COUT(\gw3_top/u_gwmc_top/gw_cmd0/n492_3 ),
	.SUM(\gw3_top/u_gwmc_top/gw_cmd0/n492_1_SUM )
);
ALU \gw3_top/u_gwmc_top/gw_cmd0/n493_s0  (
	.I0(\gw3_top/u_gwmc_top/app_addr [20]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n472_29 ),
	.I3(GND),
	.CIN(\gw3_top/u_gwmc_top/gw_cmd0/n492_3 ),
	.COUT(\gw3_top/u_gwmc_top/gw_cmd0/n493_3 ),
	.SUM(\gw3_top/u_gwmc_top/gw_cmd0/n493_1_SUM )
);
ALU \gw3_top/u_gwmc_top/gw_cmd0/n494_s0  (
	.I0(\gw3_top/u_gwmc_top/app_addr [21]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n471_29 ),
	.I3(GND),
	.CIN(\gw3_top/u_gwmc_top/gw_cmd0/n493_3 ),
	.COUT(\gw3_top/u_gwmc_top/gw_cmd0/n494_3 ),
	.SUM(\gw3_top/u_gwmc_top/gw_cmd0/n494_1_SUM )
);
ALU \gw3_top/u_gwmc_top/gw_cmd0/n495_s0  (
	.I0(\gw3_top/u_gwmc_top/app_addr [22]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n470_29 ),
	.I3(GND),
	.CIN(\gw3_top/u_gwmc_top/gw_cmd0/n494_3 ),
	.COUT(\gw3_top/u_gwmc_top/gw_cmd0/n495_3 ),
	.SUM(\gw3_top/u_gwmc_top/gw_cmd0/n495_1_SUM )
);
ALU \gw3_top/u_gwmc_top/gw_cmd0/n496_s0  (
	.I0(\gw3_top/u_gwmc_top/app_addr [23]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n469_29 ),
	.I3(GND),
	.CIN(\gw3_top/u_gwmc_top/gw_cmd0/n495_3 ),
	.COUT(\gw3_top/u_gwmc_top/gw_cmd0/n496_3 ),
	.SUM(\gw3_top/u_gwmc_top/gw_cmd0/n496_1_SUM )
);
ALU \gw3_top/u_gwmc_top/gw_cmd0/n497_s0  (
	.I0(\gw3_top/u_gwmc_top/app_addr [24]),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n468_29 ),
	.I3(GND),
	.CIN(\gw3_top/u_gwmc_top/gw_cmd0/n496_3 ),
	.COUT(\gw3_top/u_gwmc_top/gw_cmd0/row_change ),
	.SUM(\gw3_top/u_gwmc_top/gw_cmd0/n497_1_SUM )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_175_G[0]_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_178_G[2]_1 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_179_G[2]_1 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_176_G[1]_2 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_175_G[0]_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_180_G[2]_1 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_181_G[2]_1 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_177_G[1]_2 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_182_G[0]_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_185_G[2]_1 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_186_G[2]_1 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_183_G[1]_2 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_182_G[0]_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_187_G[2]_1 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_188_G[2]_1 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_184_G[1]_2 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_189_G[0]_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_192_G[2]_1 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_193_G[2]_1 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_190_G[1]_2 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_189_G[0]_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_194_G[2]_1 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_195_G[2]_1 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_191_G[1]_2 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/n468_s22  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n468_20 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n468_21 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [26]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n468_25 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/n468_s23  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n468_22 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n468_23 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [26]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n468_27 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/n469_s22  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n469_20 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n469_21 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [26]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n469_25 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/n469_s23  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n469_22 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n469_23 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [26]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n469_27 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/n470_s22  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n470_20 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n470_21 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [26]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n470_25 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/n470_s23  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n470_22 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n470_23 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [26]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n470_27 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/n471_s22  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n471_20 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n471_21 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [26]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n471_25 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/n471_s23  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n471_22 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n471_23 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [26]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n471_27 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/n472_s22  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n472_20 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n472_21 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [26]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n472_25 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/n472_s23  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n472_22 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n472_23 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [26]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n472_27 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/n473_s22  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n473_20 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n473_21 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [26]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n473_25 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/n473_s23  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n473_22 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n473_23 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [26]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n473_27 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/n474_s22  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n474_20 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n474_21 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [26]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n474_25 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/n474_s23  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n474_22 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n474_23 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [26]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n474_27 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/n475_s22  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n475_20 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n475_21 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [26]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n475_25 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/n475_s23  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n475_22 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n475_23 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [26]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n475_27 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/n476_s22  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n476_20 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n476_21 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [26]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n476_25 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/n476_s23  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n476_22 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n476_23 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [26]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n476_27 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/n477_s22  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n477_20 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n477_21 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [26]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n477_25 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/n477_s23  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n477_22 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n477_23 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [26]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n477_27 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/n478_s22  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n478_20 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n478_21 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [26]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n478_25 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/n478_s23  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n478_22 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n478_23 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [26]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n478_27 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/n479_s22  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n479_20 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n479_21 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [26]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n479_25 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/n479_s23  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n479_22 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n479_23 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [26]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n479_27 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/n480_s22  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n480_20 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n480_21 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [26]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n480_25 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/n480_s23  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n480_22 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n480_23 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [26]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n480_27 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/n481_s22  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n481_20 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n481_21 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [26]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n481_25 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/n481_s23  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n481_22 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n481_23 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [26]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n481_27 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/n482_s22  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n482_20 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n482_21 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [26]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n482_25 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/n482_s23  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n482_22 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n482_23 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [26]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n482_27 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_0_G[0]_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_3_G[2]_9 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_3_G[2]_10 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_3_G[2]_14 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_0_G[0]_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_3_G[2]_11 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_3_G[2]_12 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_3_G[2]_16 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_7_G[0]_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_10_G[2]_9 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_10_G[2]_10 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_10_G[2]_14 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_7_G[0]_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_10_G[2]_11 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_10_G[2]_12 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_10_G[2]_16 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_14_G[0]_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_17_G[2]_9 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_17_G[2]_10 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_17_G[2]_14 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_14_G[0]_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_17_G[2]_11 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_17_G[2]_12 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_17_G[2]_16 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_21_G[0]_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_24_G[2]_9 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_24_G[2]_10 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_24_G[2]_14 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_21_G[0]_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_24_G[2]_11 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_24_G[2]_12 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_24_G[2]_16 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_28_G[0]_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_31_G[2]_9 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_31_G[2]_10 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_31_G[2]_14 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_28_G[0]_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_31_G[2]_11 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_31_G[2]_12 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_31_G[2]_16 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_35_G[0]_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_38_G[2]_9 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_38_G[2]_10 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_38_G[2]_14 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_35_G[0]_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_38_G[2]_11 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_38_G[2]_12 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_38_G[2]_16 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_42_G[0]_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_45_G[2]_9 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_45_G[2]_10 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_45_G[2]_14 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_42_G[0]_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_45_G[2]_11 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_45_G[2]_12 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_45_G[2]_16 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_49_G[0]_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_52_G[2]_9 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_52_G[2]_10 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_52_G[2]_14 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_49_G[0]_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_52_G[2]_11 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_52_G[2]_12 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_52_G[2]_16 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_56_G[0]_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_59_G[2]_9 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_59_G[2]_10 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_59_G[2]_14 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_56_G[0]_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_59_G[2]_11 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_59_G[2]_12 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_59_G[2]_16 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_63_G[0]_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_66_G[2]_9 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_66_G[2]_10 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_66_G[2]_14 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_63_G[0]_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_66_G[2]_11 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_66_G[2]_12 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_66_G[2]_16 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_70_G[0]_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_73_G[2]_9 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_73_G[2]_10 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_73_G[2]_14 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_70_G[0]_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_73_G[2]_11 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_73_G[2]_12 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_73_G[2]_16 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_77_G[0]_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_80_G[2]_9 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_80_G[2]_10 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_80_G[2]_14 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_77_G[0]_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_80_G[2]_11 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_80_G[2]_12 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_80_G[2]_16 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_84_G[0]_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_87_G[2]_9 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_87_G[2]_10 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_87_G[2]_14 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_84_G[0]_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_87_G[2]_11 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_87_G[2]_12 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_87_G[2]_16 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_91_G[0]_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_94_G[2]_9 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_94_G[2]_10 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_94_G[2]_14 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_91_G[0]_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_94_G[2]_11 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_94_G[2]_12 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_94_G[2]_16 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_98_G[0]_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_101_G[2]_9 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_101_G[2]_10 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_101_G[2]_14 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_98_G[0]_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_101_G[2]_11 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_101_G[2]_12 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_101_G[2]_16 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_105_G[0]_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_108_G[2]_9 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_108_G[2]_10 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_108_G[2]_14 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_105_G[0]_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_108_G[2]_11 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_108_G[2]_12 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_108_G[2]_16 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_112_G[0]_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_115_G[2]_9 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_115_G[2]_10 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_115_G[2]_14 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_112_G[0]_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_115_G[2]_11 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_115_G[2]_12 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_115_G[2]_16 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_119_G[0]_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_122_G[2]_9 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_122_G[2]_10 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_122_G[2]_14 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_119_G[0]_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_122_G[2]_11 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_122_G[2]_12 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_122_G[2]_16 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_126_G[0]_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_129_G[2]_9 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_129_G[2]_10 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_129_G[2]_14 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_126_G[0]_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_129_G[2]_11 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_129_G[2]_12 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_129_G[2]_16 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_133_G[0]_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_136_G[2]_9 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_136_G[2]_10 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_136_G[2]_14 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_133_G[0]_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_136_G[2]_11 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_136_G[2]_12 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_136_G[2]_16 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_140_G[0]_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_143_G[2]_9 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_143_G[2]_10 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_143_G[2]_14 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_140_G[0]_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_143_G[2]_11 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_143_G[2]_12 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_143_G[2]_16 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_147_G[0]_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_150_G[2]_9 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_150_G[2]_10 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_150_G[2]_14 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_147_G[0]_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_150_G[2]_11 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_150_G[2]_12 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_150_G[2]_16 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_154_G[0]_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_157_G[2]_9 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_157_G[2]_10 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_157_G[2]_14 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_154_G[0]_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_157_G[2]_11 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_157_G[2]_12 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_157_G[2]_16 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_161_G[0]_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_164_G[2]_9 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_164_G[2]_10 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_164_G[2]_14 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_161_G[0]_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_164_G[2]_11 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_164_G[2]_12 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_164_G[2]_16 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_168_G[0]_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_171_G[2]_9 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_171_G[2]_10 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_171_G[2]_14 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_168_G[0]_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_171_G[2]_11 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_171_G[2]_12 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_171_G[2]_16 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_196_G[0]_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_199_G[2]_9 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_199_G[2]_10 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_199_G[2]_14 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_196_G[0]_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_199_G[2]_11 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_199_G[2]_12 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_199_G[2]_16 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_203_G[0]_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_206_G[2]_9 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_206_G[2]_10 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_206_G[2]_14 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_203_G[0]_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_206_G[2]_11 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_206_G[2]_12 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_206_G[2]_16 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_210_G[0]_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_213_G[2]_9 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_213_G[2]_10 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_213_G[2]_14 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_210_G[0]_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_213_G[2]_11 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_213_G[2]_12 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_213_G[2]_16 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_217_G[0]_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_220_G[2]_9 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_220_G[2]_10 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_220_G[2]_14 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_217_G[0]_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_220_G[2]_11 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_220_G[2]_12 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [1]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_220_G[2]_16 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_175_G[0]_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_176_G[1]_2 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_177_G[1]_2 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.O(\gw3_top/u_gwmc_top/mem_RAMOUT_175_G[0]_2 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_182_G[0]_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_183_G[1]_2 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_184_G[1]_2 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.O(\gw3_top/u_gwmc_top/mem_RAMOUT_182_G[0]_2 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_189_G[0]_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_190_G[1]_2 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_191_G[1]_2 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.O(\gw3_top/u_gwmc_top/mem_RAMOUT_189_G[0]_2 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/n468_s21  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n468_25 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n468_27 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [27]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n468_29 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/n469_s21  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n469_25 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n469_27 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [27]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n469_29 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/n470_s21  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n470_25 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n470_27 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [27]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n470_29 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/n471_s21  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n471_25 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n471_27 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [27]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n471_29 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/n472_s21  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n472_25 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n472_27 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [27]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n472_29 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/n473_s21  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n473_25 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n473_27 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [27]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n473_29 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/n474_s21  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n474_25 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n474_27 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [27]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n474_29 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/n475_s21  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n475_25 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n475_27 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [27]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n475_29 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/n476_s21  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n476_25 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n476_27 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [27]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n476_29 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/n477_s21  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n477_25 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n477_27 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [27]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n477_29 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/n478_s21  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n478_25 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n478_27 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [27]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n478_29 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/n479_s21  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n479_25 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n479_27 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [27]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n479_29 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/n480_s21  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n480_25 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n480_27 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [27]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n480_29 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/n481_s21  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n481_25 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n481_27 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [27]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n481_29 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/n482_s21  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/n482_25 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/n482_27 ),
	.S0(\gw3_top/u_gwmc_top/app_addr [27]),
	.O(\gw3_top/u_gwmc_top/gw_cmd0/n482_29 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_0_G[0]_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_3_G[2]_14 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_3_G[2]_16 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.O(\gw3_top/u_gwmc_top/mem_RAMOUT_0_G[0]_4 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_7_G[0]_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_10_G[2]_14 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_10_G[2]_16 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.O(\gw3_top/u_gwmc_top/mem_RAMOUT_7_G[0]_4 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_14_G[0]_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_17_G[2]_14 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_17_G[2]_16 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.O(\gw3_top/u_gwmc_top/mem_RAMOUT_14_G[0]_4 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_21_G[0]_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_24_G[2]_14 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_24_G[2]_16 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.O(\gw3_top/u_gwmc_top/mem_RAMOUT_21_G[0]_4 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_28_G[0]_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_31_G[2]_14 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_31_G[2]_16 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.O(\gw3_top/u_gwmc_top/mem_RAMOUT_28_G[0]_4 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_35_G[0]_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_38_G[2]_14 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_38_G[2]_16 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.O(\gw3_top/u_gwmc_top/mem_RAMOUT_35_G[0]_4 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_42_G[0]_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_45_G[2]_14 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_45_G[2]_16 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.O(\gw3_top/u_gwmc_top/mem_RAMOUT_42_G[0]_4 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_49_G[0]_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_52_G[2]_14 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_52_G[2]_16 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.O(\gw3_top/u_gwmc_top/mem_RAMOUT_49_G[0]_4 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_56_G[0]_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_59_G[2]_14 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_59_G[2]_16 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.O(\gw3_top/u_gwmc_top/mem_RAMOUT_56_G[0]_4 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_63_G[0]_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_66_G[2]_14 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_66_G[2]_16 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.O(\gw3_top/u_gwmc_top/mem_RAMOUT_63_G[0]_4 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_70_G[0]_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_73_G[2]_14 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_73_G[2]_16 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.O(\gw3_top/u_gwmc_top/mem_RAMOUT_70_G[0]_4 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_77_G[0]_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_80_G[2]_14 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_80_G[2]_16 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.O(\gw3_top/u_gwmc_top/mem_RAMOUT_77_G[0]_4 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_84_G[0]_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_87_G[2]_14 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_87_G[2]_16 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.O(\gw3_top/u_gwmc_top/mem_RAMOUT_84_G[0]_4 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_91_G[0]_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_94_G[2]_14 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_94_G[2]_16 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.O(\gw3_top/u_gwmc_top/mem_RAMOUT_91_G[0]_4 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_98_G[0]_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_101_G[2]_14 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_101_G[2]_16 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.O(\gw3_top/u_gwmc_top/mem_RAMOUT_98_G[0]_4 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_105_G[0]_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_108_G[2]_14 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_108_G[2]_16 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.O(\gw3_top/u_gwmc_top/mem_RAMOUT_105_G[0]_4 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_112_G[0]_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_115_G[2]_14 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_115_G[2]_16 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.O(\gw3_top/u_gwmc_top/mem_RAMOUT_112_G[0]_4 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_119_G[0]_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_122_G[2]_14 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_122_G[2]_16 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.O(\gw3_top/u_gwmc_top/mem_RAMOUT_119_G[0]_4 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_126_G[0]_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_129_G[2]_14 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_129_G[2]_16 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.O(\gw3_top/u_gwmc_top/mem_RAMOUT_126_G[0]_4 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_133_G[0]_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_136_G[2]_14 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_136_G[2]_16 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.O(\gw3_top/u_gwmc_top/mem_RAMOUT_133_G[0]_4 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_140_G[0]_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_143_G[2]_14 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_143_G[2]_16 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.O(\gw3_top/u_gwmc_top/mem_RAMOUT_140_G[0]_4 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_147_G[0]_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_150_G[2]_14 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_150_G[2]_16 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.O(\gw3_top/u_gwmc_top/mem_RAMOUT_147_G[0]_4 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_154_G[0]_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_157_G[2]_14 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_157_G[2]_16 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.O(\gw3_top/u_gwmc_top/mem_RAMOUT_154_G[0]_4 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_161_G[0]_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_164_G[2]_14 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_164_G[2]_16 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.O(\gw3_top/u_gwmc_top/mem_RAMOUT_161_G[0]_4 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_168_G[0]_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_171_G[2]_14 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_171_G[2]_16 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.O(\gw3_top/u_gwmc_top/mem_RAMOUT_168_G[0]_4 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_196_G[0]_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_199_G[2]_14 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_199_G[2]_16 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.O(\gw3_top/u_gwmc_top/mem_RAMOUT_196_G[0]_4 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_203_G[0]_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_206_G[2]_14 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_206_G[2]_16 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.O(\gw3_top/u_gwmc_top/mem_RAMOUT_203_G[0]_4 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_210_G[0]_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_213_G[2]_14 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_213_G[2]_16 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.O(\gw3_top/u_gwmc_top/mem_RAMOUT_210_G[0]_4 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_217_G[0]_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_220_G[2]_14 ),
	.I1(\gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_220_G[2]_16 ),
	.S0(\gw3_top/u_gwmc_top/gw_cmd0/raddr [0]),
	.O(\gw3_top/u_gwmc_top/mem_RAMOUT_217_G[0]_4 )
);
INV \gw3_top/u_gwmc_top/gw_cmd0/cmd_ready_d_s0  (
	.I(\gw3_top/full ),
	.O(cmd_ready)
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n951_s24  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted [1]),
	.I2(\gw3_top/u_gwmc_top/mem_RAMOUT_175_G[0]_2 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n951_20 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n951_s25  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted [2]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted [3]),
	.I2(\gw3_top/u_gwmc_top/mem_RAMOUT_175_G[0]_2 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n951_21 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n951_s26  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted [4]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted [5]),
	.I2(\gw3_top/u_gwmc_top/mem_RAMOUT_175_G[0]_2 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n951_22 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n951_s27  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted [6]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted [7]),
	.I2(\gw3_top/u_gwmc_top/mem_RAMOUT_175_G[0]_2 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n951_23 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n60_s0  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [5]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [6]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n60_4 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n60_7 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n60_3 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n119_s0  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [9]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n119_8 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n119_5 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n119_6 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n119_3 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n340_s1  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [7]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n340_10 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n340_8 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n340_4 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n345_s0  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_st_ref ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ZQ ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n345_3 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_s0  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_4 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_9 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_6 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_11 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_3 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2076_s0  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2076_4 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2076_5 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2076_3 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2089_s0  (
	.I0(\gw3_top/u_gwmc_top/sre_request_Z ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_SREE ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2089_3 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_satisfied_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_REF ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n119_3 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_satisfied_8 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_7_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_bank [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_bank [1]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_7_9 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1687_7 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_7_8 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_6_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_bank [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_bank [1]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_7_9 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1687_7 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_6_8 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_5_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_bank [1]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_bank [0]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_7_9 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1687_7 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_5_8 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_4_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_bank [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_bank [1]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_7_9 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1687_7 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_4_8 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_3_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_bank [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_bank [1]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_3_9 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1687_7 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_3_8 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_2_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_bank [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_bank [1]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_3_9 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1687_7 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_2_8 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_1_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_bank [1]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_bank [0]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_3_9 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1687_7 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_1_8 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_0_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_bank [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_bank [1]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_3_9 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1687_7 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_0_8 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_s55  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRP_cnt_1_9 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_62 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_63 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_64 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SRE_57 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_s68  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_75 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_WRITE ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_76 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_74 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_s68  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_86 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_76 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_READ ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_77 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_74 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_s68  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_75 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_76 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_77 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_78 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_74 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_s56  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_65 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_REF ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_74 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_61 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ZQ_s54  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_satisfied ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ZQ_62 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ZQ ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_7_9 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ZQ_59 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SREI_s55  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SREI_60 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/cmd_accept_sre_Z_3 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SREI_61 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2076_4 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SREI_59 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_WR_s65  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_65 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT_WR ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_WR_71 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_WR_70 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_RD_s67  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_65 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT_RD ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_RD_72 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_RD_71 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_W2R_s55  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_86 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_W2R_61 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_W2R ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_W2R_62 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_W2R_60 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2AW_s55  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2AW_60 ),
	.I1(\gw3_top/u_gwmc_top/cmd_write_Z ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2AW_61 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_WP2AW ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2AW_59 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2AR_s54  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2AW_60 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2AR_61 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2AW_61 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_WP2AR ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2AR_58 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_R2W_s55  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ZQ_62 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_R2W ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_R2W_61 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_R2W_60 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_s55  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_70 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_61 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_62 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_RP2AW ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_59 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AR_s54  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_62 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_RP2AR ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AR_59 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AR_58 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2WR_s54  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2WR_60 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2WR_65 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2WR_62 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2WR_67 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2WR_59 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2REF_s53  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2AW_61 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_WP2REF ),
	.I2(\gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_WRITE ),
	.I3(\gw3_top/u_gwmc_top/refresh_request_Z ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2REF_57 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2SRE_s53  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2AW_61 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_WP2SRE ),
	.I2(\gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_WRITE ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/cmd_accept_sre_Z_3 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2SRE_57 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2RD_s54  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2RD_60 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_one_bank_5 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT_RD ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT2RD ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2RD_59 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2REF_s53  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_62 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_RP2REF ),
	.I2(\gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_READ ),
	.I3(\gw3_top/u_gwmc_top/refresh_request_Z ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2REF_57 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2SRE_s53  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_62 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_RP2SRE ),
	.I2(\gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_READ ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/cmd_accept_sre_Z_3 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2SRE_57 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SRE_s54  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ZQ_62 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_SRE ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2084_5 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SRE_59 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SREE_s51  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ZQ_62 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_SREE ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_SRE ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SREE_55 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_POWERON_s51  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ZQ_62 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_POWERON ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_POWERON_55 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1778_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt [1]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_4_10 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1778_7 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1777_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt [1]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt [2]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_4_10 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1777_7 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n317_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [2]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n318_8 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_7_9 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [3]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n317_7 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n314_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [5]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n315_10 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_7_9 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [6]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n314_7 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n313_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n313_8 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n315_10 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_7_9 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [7]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n313_7 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n138_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [1]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [2]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n138_7 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n133_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [6]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n134_15 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n119_3 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [7]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n133_7 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n132_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n132_8 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n134_15 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n119_3 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [8]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n132_7 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n131_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n119_8 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n134_15 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n119_3 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [9]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n131_7 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n79_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [1]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [2]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n79_7 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n75_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [5]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n76_8 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n60_3 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [6]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n75_7 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n73_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [7]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n74_10 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n60_3 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [8]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n73_7 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n72_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n72_8 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n74_10 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n60_3 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [9]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n72_7 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2024_s1  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_info_valid ),
	.I1(\gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_READ ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2024_6 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2020_s1  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_info_valid ),
	.I1(\gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_WRITE ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2020_6 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n35_s1  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [1]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n36_8 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n35_6 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n33_s1  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [2]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n9_5 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [3]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n36_8 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n33_6 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n32_s1  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [4]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n32_9 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n36_8 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n32_6 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n30_s1  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [5]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n31_7 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [6]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n36_8 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n30_6 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n29_s1  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n9_6 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n31_7 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [7]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n36_8 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n29_6 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1687_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_IDLE ),
	.I1(\gw3_top/u_gwmc_top/send_ref_Z ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1687_7 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1943_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [1]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_SREE ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1943_7 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1942_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [1]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [2]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_SREE ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1942_7 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1941_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [3]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1941_8 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_SREE ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1941_7 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1940_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [4]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1940_8 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_SREE ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1940_7 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1938_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [5]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1939_8 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [6]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_SREE ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1938_7 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1776_s1  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt [3]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1776_7 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_4_10 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1776_6 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n316_s1  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n316_7 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n318_8 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_7_9 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [4]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n316_6 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n9_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [1]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n9_5 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n9_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [5]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [6]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n9_6 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n9_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [2]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [3]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [4]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [7]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n9_7 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n60_s1  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [2]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [4]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [3]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [9]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n60_4 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n119_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [1]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n119_5 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n119_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [2]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [4]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [3]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [5]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n119_6 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/cmd_accept_ref_Z_s0  (
	.I0(\gw3_top/u_gwmc_top/idle1 ),
	.I1(\gw3_top/u_gwmc_top/idle2 ),
	.I2(\gw3_top/u_gwmc_top/idle3 ),
	.F(\gw3_top/u_gwmc_top/cmd_accept_ref_Z_3 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/cmd_accept_sre_Z_s0  (
	.I0(\gw3_top/u_gwmc_top/refresh_request_Z ),
	.I1(\gw3_top/u_gwmc_top/sre_request_Z ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/cmd_accept_sre_Z_3 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_one_bank_s1  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT_RD ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT_WR ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_one_bank_4 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_one_bank_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_4_9 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_one_bank_6 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_one_bank_5 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_s1  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_RP2REF ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_RP2SRE ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_RP2AW ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_RP2AR ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_4 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_WP2REF ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_WP2SRE ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_WP2AW ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_WP2AR ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_6 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2076_s1  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_11 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_WP2SRE ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_RP2SRE ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_9 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2076_4 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2076_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_11 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_WP2REF ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_RP2REF ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_9 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2076_5 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_7_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_IDLE ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_st_ref ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_7_9 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_7_s4  (
	.I0(\gw3_top/u_gwmc_top/act_shift_reg [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_bank [2]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_7_9 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_3_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_bank [2]),
	.I1(\gw3_top/u_gwmc_top/act_shift_reg [0]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_3_9 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRP_cnt_1_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_6 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_4 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRP_cnt_1_9 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_4_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt [1]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt [2]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt [3]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_4_9 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_4_s5  (
	.I0(\gw3_top/u_gwmc_top/sre_request_Z ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_IDLE ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1757_5 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2076_4 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_4_10 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRCD_cnt_1_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRCD_cnt [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRCD_cnt [1]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRCD_cnt_1_9 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTW_cnt_1_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTW_cnt [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTW_cnt [1]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTW_cnt_1_9 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTR_cnt_2_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTR_cnt [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTR_cnt [1]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTR_cnt [2]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTR_cnt_2_9 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRAS_cnt_2_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRAS_cnt [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRAS_cnt [1]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRAS_cnt [2]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRAS_cnt_2_9 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTP_cnt_1_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTP_cnt [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTP_cnt [1]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTP_cnt_1_9 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTP_cnt_2_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTP_cnt [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTP_cnt [1]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTP_cnt [2]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTP_cnt_2_9 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_s57  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_REF ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_SREI ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT_RD ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT_WR ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_62 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_s58  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT2RD ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_W2R ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_POWERON ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_63 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_s59  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_IDLE ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ZQ ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n218_5 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_67 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_64 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_s69  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_77 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_78 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2WR_60 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_75 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_75 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_s70  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_info_valid ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_79 ),
	.I2(\gw3_top/u_gwmc_top/cmd_write_Z ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_80 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_76 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_s70  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRCD_cnt_1_9 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT2WR ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_78 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_79 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_76 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_s71  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRCD_cnt_1_9 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT2RD ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_80 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_81 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_77 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_s69  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_88 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2WR_62 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_75 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_s70  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_REF ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_SREE ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_90 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_81 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_76 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_s71  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_7_17 ),
	.I1(sr_ack),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1757_5 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_IDLE ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_77 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_s72  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_satisfied ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ZQ ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_82 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_83 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_78 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_s60  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_68 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_one_bank_5 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2WR_60 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_75 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_65 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SREI_s56  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_st_ref ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_IDLE ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SREI_60 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SREI_s57  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2WR_60 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_75 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SREI_62 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_SREI ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SREI_61 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_WR_s66  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_WR_72 ),
	.I1(\gw3_top/u_gwmc_top/cmd_write_Z ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_WR_73 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_WR_74 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_WR_71 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_RD_s68  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2AR_61 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_WR_72 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_RD_73 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_RD_74 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_RD_72 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_W2R_s56  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_88 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_82 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_79 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_W2R_61 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_W2R_s57  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_W2R_69 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_W2R_67 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_W2R_65 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_W2R_62 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2AW_s56  (
	.I0(\gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_WRITE ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_61 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2AW_60 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2AW_s57  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_W2R_65 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_11 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2WR_60 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_W2R_61 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2AW_61 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_R2W_s56  (
	.I0(\gw3_top/u_gwmc_top/mem_RAMOUT_203_G[0]_4 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_W2R_67 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_70 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_R2W_61 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_s57  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n951_29 ),
	.I1(\gw3_top/u_gwmc_top/mem_RAMOUT_210_G[0]_4 ),
	.I2(\gw3_top/u_gwmc_top/mem_RAMOUT_217_G[0]_4 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_63 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_61 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_s58  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_64 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2WR_62 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_W2R_61 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_68 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_62 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AR_s55  (
	.I0(\gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_READ ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2AR_61 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_61 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AR_59 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2WR_s55  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_64 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_81 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2WR_60 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2WR_s57  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRAS_cnt_2_9 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTP_cnt_2_9 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_6 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_W2R_65 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2WR_62 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2RD_s55  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRCD_cnt_1_9 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2WR_62 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_78 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2WR_60 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2RD_60 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1908_s12  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_shift_reg_0 [4]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tFAW_cnt [0]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tFAW_cnt [1]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_one_bank ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1908_18 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n318_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [1]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n318_8 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n313_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [5]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [6]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n313_8 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n137_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [1]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [2]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n137_8 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n135_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [4]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n136_10 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n135_8 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n132_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [6]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [7]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n132_8 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n78_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [1]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [2]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n78_8 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n76_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [4]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n77_10 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n76_8 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n72_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [7]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [8]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n72_8 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n36_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_satisfied ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n9_9 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/init_done_r ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n36_8 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n31_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [4]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n32_9 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n31_7 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1941_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [1]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [2]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1941_8 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1940_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [1]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [2]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [3]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1940_8 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1939_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [4]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1940_8 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1939_8 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1776_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt [1]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt [2]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1776_7 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n316_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [2]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [3]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n316_7 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_one_bank_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tFAW_cnt [2]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt [4]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRP_cnt [0]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRP_cnt [1]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_one_bank_6 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_7_s5  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [4]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [5]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [6]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_7_10 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_s62  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT2WR ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_SREE ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_SRE ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_R2W ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_67 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_s71  (
	.I0(\gw3_top/u_gwmc_top/cmd_read_Z ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_81 ),
	.I2(\gw3_top/u_gwmc_top/cmd_write_Z ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_84 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_77 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_s72  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_82 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_79 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_78 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_s73  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_st_ref ),
	.I1(\gw3_top/u_gwmc_top/sre_request_Z ),
	.I2(\gw3_top/u_gwmc_top/refresh_request_Z ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_IDLE ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_79 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_s74  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_R2W ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTW_cnt_1_9 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT2WR ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRCD_cnt_1_9 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_80 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_s72  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_81 ),
	.I1(\gw3_top/u_gwmc_top/cmd_write_Z ),
	.I2(\gw3_top/u_gwmc_top/cmd_read_Z ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_84 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_78 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_s73  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_one_bank_6 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_4_9 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_62 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_68 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_79 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_s74  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_84 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_info_valid ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_79 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2AR_61 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_80 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_s75  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT2RD ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTR_cnt_2_9 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_READ ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_W2R ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_81 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_s75  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRAS_cnt_2_9 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTP_cnt_1_9 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_4 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_84 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_81 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_s76  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_85 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_86 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_info_valid ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_79 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_82 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_s77  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_IDLE ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/init_done_r ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_POWERON ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_83 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_s63  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/init_done_r ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_POWERON ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_68 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_s64  (
	.I0(\gw3_top/u_gwmc_top/sre_request_Z ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_72 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_REF ),
	.I3(\gw3_top/u_gwmc_top/refresh_request_Z ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_69 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SREI_s58  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SREI_65 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_72 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_68 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_one_bank_5 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SREI_62 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_WR_s67  (
	.I0(\gw3_top/u_gwmc_top/mem_RAMOUT_217_G[0]_4 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n951_29 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n218_5 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_63 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_WR_72 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_WR_s68  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_85 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_info_valid ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_WR_75 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_79 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_WR_73 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_WR_s69  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_11 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_WP2AW ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_RP2AW ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_9 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_WR_74 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_RD_s69  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_cmd_write ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_info_valid ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_RD_75 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_79 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_RD_73 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_RD_s70  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_11 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_WP2AR ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_RP2AR ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_9 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_RD_74 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_W2R_s60  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTR_cnt [1]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTR_cnt [2]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTR_cnt [0]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_W2R ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_W2R_65 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_s59  (
	.I0(\gw3_top/u_gwmc_top/sre_request_Z ),
	.I1(\gw3_top/u_gwmc_top/refresh_request_Z ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_63 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_s60  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1940_8 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_7_10 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_66 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_SREE ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_64 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_s75  (
	.I0(\gw3_top/u_gwmc_top/mem_RAMOUT_217_G[0]_4 ),
	.I1(\gw3_top/u_gwmc_top/mem_RAMOUT_210_G[0]_4 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_81 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_s78  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTW_cnt [1]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTW_cnt [0]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_R2W ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_84 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_s79  (
	.I0(\gw3_top/u_gwmc_top/mem_RAMOUT_203_G[0]_4 ),
	.I1(\gw3_top/u_gwmc_top/mem_RAMOUT_196_G[0]_4 ),
	.I2(\gw3_top/u_gwmc_top/cmd_empty_Z ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_85 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_s80  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_cmd_write ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_cmd_read ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_86 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_WR_s70  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_cmd_read ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT_WR ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_cmd_write ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_info_valid ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_WR_75 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_RD_s71  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_cmd_read ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_85 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_info_valid ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT_RD ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_RD_75 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_s62  (
	.I0(sr_ack),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [7]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_66 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_s63  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTW_cnt [1]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTW_cnt [0]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_R2W ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_9 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_68 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n119_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [8]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [6]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [7]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n119_8 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n136_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [3]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [0]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [1]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [2]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n136_10 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1939_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [5]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [4]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1940_8 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_SREE ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1939_10 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n340_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [1]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [0]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [5]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [6]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n340_8 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n340_s5  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [4]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [2]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [3]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n340_10 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n60_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [1]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [7]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [8]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n60_7 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n77_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [3]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [0]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [1]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [2]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n77_10 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n9_s5  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n9_5 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [5]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [6]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n9_7 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n9_9 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_7_s6  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1940_8 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [4]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [5]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [6]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_7_12 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_s66  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_85 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_cmd_write ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_cmd_read ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_info_valid ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_72 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_s77  (
	.I0(\gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_READ ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_cmd_write ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_cmd_read ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_84 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_s77  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_85 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n951_29 ),
	.I2(\gw3_top/u_gwmc_top/sre_request_Z ),
	.I3(\gw3_top/u_gwmc_top/refresh_request_Z ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_84 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SREI_s60  (
	.I0(\gw3_top/u_gwmc_top/refresh_request_Z ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_st_ref ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_IDLE ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SREI_65 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_s67  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_69 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_st_ref ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_IDLE ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2076_5 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_74 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2WR_s59  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT_WR ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRCD_cnt_1_9 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_82 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_79 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2WR_65 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_W2R_s61  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_84 ),
	.I1(\gw3_top/u_gwmc_top/mem_RAMOUT_217_G[0]_4 ),
	.I2(\gw3_top/u_gwmc_top/mem_RAMOUT_210_G[0]_4 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_W2R_67 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n74_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [5]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [6]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [4]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n77_10 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n74_10 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n76_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n60_3 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [5]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [4]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n77_10 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n76_10 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_s5  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRAS_cnt_2_9 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTP_cnt [0]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTP_cnt [1]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_9 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_s6  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRAS_cnt_2_9 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTP_cnt [0]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTP_cnt [1]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTP_cnt [2]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_11 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/cmd_accept_sre_Z_s1  (
	.I0(\gw3_top/u_gwmc_top/idle1 ),
	.I1(\gw3_top/u_gwmc_top/idle2 ),
	.I2(\gw3_top/u_gwmc_top/idle3 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/cmd_accept_sre_Z_3 ),
	.F(\gw3_top/u_gwmc_top/cmd_accept_sre_Z )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/cmd_accept_ref_Z_s1  (
	.I0(\gw3_top/u_gwmc_top/idle1 ),
	.I1(\gw3_top/u_gwmc_top/idle2 ),
	.I2(\gw3_top/u_gwmc_top/idle3 ),
	.I3(\gw3_top/u_gwmc_top/refresh_request_Z ),
	.F(\gw3_top/u_gwmc_top/cmd_accept_ref_Z )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n315_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n340_10 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [0]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [1]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n315_10 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n318_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_7_9 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [2]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [0]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [1]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n318_10 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n32_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [2]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [3]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [0]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [1]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n32_9 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n34_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [2]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [0]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [1]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n36_8 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n34_8 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_W2R_s62  (
	.I0(\gw3_top/u_gwmc_top/cmd_write_Z ),
	.I1(\gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_WRITE ),
	.I2(\gw3_top/u_gwmc_top/cmd_empty_Z ),
	.I3(\gw3_top/u_gwmc_top/mem_RAMOUT_203_G[0]_4 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_W2R_69 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2AR_s56  (
	.I0(\gw3_top/u_gwmc_top/mem_RAMOUT_196_G[0]_4 ),
	.I1(\gw3_top/u_gwmc_top/cmd_empty_Z ),
	.I2(\gw3_top/u_gwmc_top/mem_RAMOUT_203_G[0]_4 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2AR_61 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_s81  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT2RD ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT2WR ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRCD_cnt [0]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRCD_cnt [1]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_88 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_s64  (
	.I0(\gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_READ ),
	.I1(\gw3_top/u_gwmc_top/cmd_empty_Z ),
	.I2(\gw3_top/u_gwmc_top/mem_RAMOUT_196_G[0]_4 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_70 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_s82  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_one_bank_4 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_SREI ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_4_9 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_one_bank_6 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_90 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2WR_s60  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_4_9 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_one_bank_6 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT_WR ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT2WR ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2WR_67 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2084_s1  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_SREI ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_4_9 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_one_bank_6 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2084_5 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1757_s1  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_REF ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_4_9 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_one_bank_6 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1757_5 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ZQ_s56  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2WR_62 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_64 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_81 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_W2R_61 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ZQ_62 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_s78  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_11 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_6 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_64 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_81 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_86 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n36_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_satisfied ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n9_9 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/init_done_r ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n36_10 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_one_bank_s5  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT_RD ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT_WR ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_4_9 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_one_bank_6 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_one_bank )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1847_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRAS_cnt [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRAS_cnt [1]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT_RD ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT_WR ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1847_8 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1848_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRAS_cnt [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT_RD ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT_WR ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1848_8 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n315_s5  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_IDLE ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_st_ref ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [5]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n315_10 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n315_12 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n319_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_IDLE ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_st_ref ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [1]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [0]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n319_9 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/cmd_accept_Z_s1  (
	.I0(\gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_READ ),
	.I1(\gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_WRITE ),
	.I2(\gw3_top/u_gwmc_top/cmd_empty_Z ),
	.F(\gw3_top/u_gwmc_top/cmd_accept_Z )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n291_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_info_valid ),
	.I1(\gw3_top/u_gwmc_top/cmd_empty_Z ),
	.I2(\gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_WRITE ),
	.I3(\gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_READ ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n291_7 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n218_s1  (
	.I0(\gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_WRITE ),
	.I1(\gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_READ ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n218_5 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n74_s6  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n74_10 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_satisfied ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n60_3 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [7]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n74_13 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt_9_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n60_3 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_satisfied ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt_9_14 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n77_s6  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n60_3 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_satisfied ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n77_10 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [4]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n77_13 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n78_s5  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_satisfied ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n78_8 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n60_3 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [3]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n78_11 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n80_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n60_3 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_satisfied ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [0]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [1]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n80_10 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n81_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n60_3 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_satisfied ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [0]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n81_10 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n134_s5  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n134_15 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_satisfied ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n119_3 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [6]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n134_11 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt_9_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n119_3 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_satisfied ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt_9_15 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n135_s5  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_satisfied ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n135_8 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n119_3 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [5]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n135_11 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n136_s6  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n119_3 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_satisfied ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n136_10 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [4]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n136_13 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n137_s5  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_satisfied ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n137_8 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n119_3 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [3]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n137_11 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n139_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n119_3 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_satisfied ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [0]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [1]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n139_10 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n140_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n119_3 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_satisfied ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [0]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n140_10 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n295_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_REF ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_satisfied ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ZQ ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_st_ref ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n295_6 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n320_s6  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_st_ref ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_IDLE ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [0]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ZQ ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n320_13 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_7_s6  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_st_ref ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_IDLE ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ZQ ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_7_13 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1749_s5  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRP_cnt [1]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRP_cnt [0]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_6 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_4 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1749_12 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1750_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRP_cnt [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRP_cnt [1]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_6 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_4 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1750_11 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1775_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_4_9 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt [4]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_4_10 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1775_9 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_4_s7  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt [4]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_4_9 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_4_10 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_4_15 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1779_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt [4]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_4_9 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt [0]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_4_10 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1779_9 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1803_s5  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT_RD ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT_WR ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRCD_cnt [1]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRCD_cnt [0]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1803_12 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1804_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRCD_cnt [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRCD_cnt [1]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT_RD ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT_WR ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1804_11 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1815_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_READ ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTW_cnt [1]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTW_cnt [0]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1815_10 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1816_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTW_cnt [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTW_cnt [1]),
	.I2(\gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_READ ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1816_9 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1828_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTR_cnt [1]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTR_cnt [0]),
	.I2(\gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_WRITE ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTR_cnt [2]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1828_10 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1829_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTR_cnt [2]),
	.I1(\gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_WRITE ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTR_cnt [0]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTR_cnt [1]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1829_9 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1830_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTR_cnt [2]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTR_cnt [1]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTR_cnt [0]),
	.I3(\gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_WRITE ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1830_9 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1846_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRAS_cnt [1]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRAS_cnt [0]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRAS_cnt [2]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_one_bank_4 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1846_10 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRAS_cnt_2_s7  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRAS_cnt [2]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRAS_cnt [0]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRAS_cnt [1]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_one_bank_4 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRAS_cnt_2_15 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1861_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_READ ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTP_cnt [1]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTP_cnt [0]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1861_10 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1862_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTP_cnt [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTP_cnt [1]),
	.I2(\gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_READ ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1862_9 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1874_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTP_cnt [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTP_cnt [1]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTP_cnt [2]),
	.I3(\gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_WRITE ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1874_9 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1875_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTP_cnt [2]),
	.I1(\gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_WRITE ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTP_cnt [0]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTP_cnt [1]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1875_10 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1876_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTP_cnt [1]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTP_cnt [2]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTP_cnt [0]),
	.I3(\gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_WRITE ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1876_10 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1937_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_7_12 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [7]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_SREE ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1937_9 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_7_s8  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [7]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_7_12 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_SREE ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_7_17 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1944_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [7]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_7_12 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [0]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_SREE ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1944_10 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1908_s14  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1908_18 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_shift_reg_0 [4]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tFAW_cnt [2]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_one_bank ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1908_21 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1909_s10  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_shift_reg_0 [4]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_one_bank ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tFAW_cnt [1]),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tFAW_cnt [0]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1909_16 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1910_s12  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_shift_reg_0 [4]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_one_bank ),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tFAW_cnt [0]),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1910_18 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n134_s7  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [5]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [4]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n136_10 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n134_15 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n31_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [5]),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [4]),
	.I2(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n32_9 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n36_8 ),
	.F(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n31_9 )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt_6_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n30_6 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [6])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt_5_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n31_9 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [5])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt_4_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n32_6 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [4])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt_3_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n33_6 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [3])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt_2_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n34_8 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [2])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt_1_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n35_6 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [1])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt_0_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n36_10 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [0])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_satisfied_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n9_9 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_satisfied )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_satisfied_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n60_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_satisfied )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/init_done_r_s0  (
	.D(\gw3_top/u_gwmc_top/n113_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/init_done_r )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_cmd_read_s0  (
	.D(\gw3_top/u_gwmc_top/cmd_read_Z ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n218_5 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_cmd_read )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_cmd_write_s0  (
	.D(\gw3_top/u_gwmc_top/cmd_write_Z ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n218_5 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_cmd_write )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_bank_2_s0  (
	.D(\gw3_top/u_gwmc_top/mem_RAMOUT_189_G[0]_2 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n218_5 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_bank [2])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_bank_1_s0  (
	.D(\gw3_top/u_gwmc_top/mem_RAMOUT_182_G[0]_2 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n218_5 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_bank [1])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_bank_0_s0  (
	.D(\gw3_top/u_gwmc_top/mem_RAMOUT_175_G[0]_2 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n218_5 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_bank [0])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row_14_s0  (
	.D(\gw3_top/u_gwmc_top/mem_RAMOUT_168_G[0]_4 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n218_5 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row [14])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row_13_s0  (
	.D(\gw3_top/u_gwmc_top/mem_RAMOUT_161_G[0]_4 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n218_5 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row [13])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row_12_s0  (
	.D(\gw3_top/u_gwmc_top/mem_RAMOUT_154_G[0]_4 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n218_5 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row [12])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row_11_s0  (
	.D(\gw3_top/u_gwmc_top/mem_RAMOUT_147_G[0]_4 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n218_5 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row [11])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row_10_s0  (
	.D(\gw3_top/u_gwmc_top/mem_RAMOUT_140_G[0]_4 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n218_5 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row [10])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row_9_s0  (
	.D(\gw3_top/u_gwmc_top/mem_RAMOUT_133_G[0]_4 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n218_5 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row [9])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row_8_s0  (
	.D(\gw3_top/u_gwmc_top/mem_RAMOUT_126_G[0]_4 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n218_5 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row [8])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row_7_s0  (
	.D(\gw3_top/u_gwmc_top/mem_RAMOUT_119_G[0]_4 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n218_5 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row [7])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row_6_s0  (
	.D(\gw3_top/u_gwmc_top/mem_RAMOUT_112_G[0]_4 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n218_5 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row [6])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row_5_s0  (
	.D(\gw3_top/u_gwmc_top/mem_RAMOUT_105_G[0]_4 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n218_5 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row [5])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row_4_s0  (
	.D(\gw3_top/u_gwmc_top/mem_RAMOUT_98_G[0]_4 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n218_5 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row [4])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row_3_s0  (
	.D(\gw3_top/u_gwmc_top/mem_RAMOUT_91_G[0]_4 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n218_5 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row [3])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row_2_s0  (
	.D(\gw3_top/u_gwmc_top/mem_RAMOUT_84_G[0]_4 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n218_5 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row [2])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row_1_s0  (
	.D(\gw3_top/u_gwmc_top/mem_RAMOUT_77_G[0]_4 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n218_5 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row [1])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row_0_s0  (
	.D(\gw3_top/u_gwmc_top/mem_RAMOUT_70_G[0]_4 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n218_5 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row [0])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col_9_s0  (
	.D(\gw3_top/u_gwmc_top/mem_RAMOUT_63_G[0]_4 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n218_5 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col [9])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col_8_s0  (
	.D(\gw3_top/u_gwmc_top/mem_RAMOUT_56_G[0]_4 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n218_5 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col [8])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col_7_s0  (
	.D(\gw3_top/u_gwmc_top/mem_RAMOUT_49_G[0]_4 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n218_5 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col [7])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col_6_s0  (
	.D(\gw3_top/u_gwmc_top/mem_RAMOUT_42_G[0]_4 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n218_5 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col [6])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col_5_s0  (
	.D(\gw3_top/u_gwmc_top/mem_RAMOUT_35_G[0]_4 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n218_5 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col [5])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col_4_s0  (
	.D(\gw3_top/u_gwmc_top/mem_RAMOUT_28_G[0]_4 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n218_5 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col [4])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col_3_s0  (
	.D(\gw3_top/u_gwmc_top/mem_RAMOUT_21_G[0]_4 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n218_5 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col [3])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col_2_s0  (
	.D(\gw3_top/u_gwmc_top/mem_RAMOUT_14_G[0]_4 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n218_5 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col [2])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col_1_s0  (
	.D(\gw3_top/u_gwmc_top/mem_RAMOUT_7_G[0]_4 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n218_5 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col [1])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col_0_s0  (
	.D(\gw3_top/u_gwmc_top/mem_RAMOUT_0_G[0]_4 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n218_5 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col [0])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_satisfied_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n340_4 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_satisfied )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_zqcs_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n345_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/send_zqcs_Z )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/idle1_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_74 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/idle1 )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/idle2_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_74 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/idle2 )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/idle3_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_74 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/idle3 )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_shift_reg_4_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_shift_reg_0 [3]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_shift_reg_0 [4])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_shift_reg_3_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_shift_reg_0 [2]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_shift_reg_0 [3])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_shift_reg_2_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_shift_reg_0 [1]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_shift_reg_0 [2])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_shift_reg_1_s0  (
	.D(\gw3_top/u_gwmc_top/act_shift_reg [0]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_shift_reg_0 [1])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_shift_reg_0_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_one_bank ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/act_shift_reg [0])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_wr_int_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2020_6 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/send_wr )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_rd_int_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2024_6 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/send_rd )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_pre_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/send_pre_Z )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_all_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2076_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/pre_all_Z )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_ref_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1757_5 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/send_ref_Z )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_sre_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2084_5 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/send_sre_Z )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/cke_set_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2089_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/cke_set_Z )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_bank_tmp_2_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_bank [2]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/bank_d [2])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_bank_tmp_1_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_bank [1]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/bank_d [1])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_bank_tmp_0_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_bank [0]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/bank_d [0])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_row_tmp_14_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row [14]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/row_d [14])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_row_tmp_13_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row [13]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/row_d [13])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_row_tmp_12_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row [12]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/row_d [12])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_row_tmp_11_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row [11]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/row_d [11])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_row_tmp_10_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row [10]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/row_d [10])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_row_tmp_9_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row [9]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/row_d [9])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_row_tmp_8_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row [8]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/row_d [8])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_row_tmp_7_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row [7]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/row_d [7])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_row_tmp_6_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row [6]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/row_d [6])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_row_tmp_5_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row [5]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/row_d [5])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_row_tmp_4_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row [4]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/row_d [4])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_row_tmp_3_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row [3]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/row_d [3])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_row_tmp_2_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row [2]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/row_d [2])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_row_tmp_1_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row [1]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/row_d [1])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_row_tmp_0_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row [0]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/row_d [0])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_col_tmp_9_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col [9]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/col_d [9])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_col_tmp_8_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col [8]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/col_d [8])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_col_tmp_7_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col [7]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/col_d [7])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_col_tmp_6_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col [6]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/col_d [6])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_col_tmp_5_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col [5]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/col_d [5])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_col_tmp_4_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col [4]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/col_d [4])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_col_tmp_3_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col [3]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/col_d [3])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_col_tmp_2_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col [2]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/col_d [2])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_col_tmp_1_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col [1]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/col_d [1])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_col_tmp_0_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col [0]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/col_d [0])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt_7_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n29_6 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt [7])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt_9_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n72_7 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt_9_14 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [9])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt_8_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n73_7 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt_9_14 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [8])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt_6_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n75_7 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt_9_14 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [6])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt_5_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n76_10 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt_9_14 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [5])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt_2_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n79_7 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt_9_14 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [2])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt_9_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n131_7 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt_9_15 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [9])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt_8_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n132_7 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt_9_15 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [8])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt_7_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n133_7 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt_9_15 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [7])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt_2_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n138_7 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt_9_15 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [2])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_satisfied_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n119_3 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_satisfied_8 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_satisfied )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_7_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n313_7 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_7_13 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [7])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_6_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n314_7 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_7_13 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [6])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_5_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n315_12 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_7_13 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [5])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_4_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n316_6 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_7_13 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [4])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_3_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n317_7 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_7_13 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [3])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_2_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n318_10 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_7_13 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [2])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_1_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n319_9 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_7_13 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [1])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_7_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1687_7 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_7_8 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted [7])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_6_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1687_7 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_6_8 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted [6])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_5_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1687_7 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_5_8 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted [5])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_4_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1687_7 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_4_8 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted [4])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_3_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1687_7 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_3_8 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted [3])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_2_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1687_7 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_2_8 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted [2])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_1_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1687_7 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_1_8 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted [1])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_0_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1687_7 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_0_8 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted [0])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_3_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1776_6 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_4_15 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt [3])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_2_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1777_7 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_4_15 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt [2])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_1_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1778_7 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_4_15 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt [1])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRAS_cnt_1_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1847_8 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRAS_cnt_2_15 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRAS_cnt [1])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRAS_cnt_0_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1848_8 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRAS_cnt_2_15 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRAS_cnt [0])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_6_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1938_7 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_7_17 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [6])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_5_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1939_10 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_7_17 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [5])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_4_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1940_7 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_7_17 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [4])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_3_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1941_7 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_7_17 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [3])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_2_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1942_7 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_7_17 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [2])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_1_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1943_7 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_7_17 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [1])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_REF_s2  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_61 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SRE_57 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_REF )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_WRITE_s2  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_74 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SRE_57 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_WRITE )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_READ_s4  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_74 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SRE_57 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_pstate.GWMCST_READ )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ZQ_s14  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ZQ_59 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SRE_57 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ZQ )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_IDLE_s4  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_74 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SRE_57 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_IDLE )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_SREI_s2  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SREI_59 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SRE_57 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_SREI )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT_WR_s2  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_WR_70 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SRE_57 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT_WR )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT_RD_s2  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_RD_71 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SRE_57 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT_RD )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_W2R_s6  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_W2R_60 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SRE_57 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_W2R )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_WP2AW_s12  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2AW_59 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SRE_57 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_WP2AW )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_WP2AR_s6  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2AR_58 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SRE_57 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_WP2AR )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_R2W_s4  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_R2W_60 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SRE_57 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_R2W )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_RP2AW_s10  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_59 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SRE_57 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_RP2AW )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_RP2AR_s4  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AR_58 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SRE_57 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_RP2AR )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT2WR_s10  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2WR_59 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SRE_57 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT2WR )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_WP2REF_s18  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2REF_57 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SRE_57 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_WP2REF )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_WP2SRE_s18  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2SRE_57 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SRE_57 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_WP2SRE )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT2RD_s4  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2RD_59 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SRE_57 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT2RD )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_RP2REF_s18  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2REF_57 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SRE_57 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_RP2REF )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_RP2SRE_s18  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2SRE_57 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SRE_57 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_RP2SRE )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_SRE_s2  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SRE_59 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SRE_57 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_SRE )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_SREE_s18  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SREE_55 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SRE_57 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_SREE )
);
DFFPE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_POWERON_s18  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_POWERON_55 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SRE_57 ),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_POWERON )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_info_valid_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n291_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_info_valid )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt_7_s3  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n74_13 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [7])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt_4_s3  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n77_13 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [4])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt_3_s3  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n78_11 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [3])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt_1_s3  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n80_10 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [1])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt_0_s3  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n81_10 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt [0])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt_6_s3  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n134_11 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [6])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt_5_s3  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n135_11 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [5])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt_4_s3  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n136_13 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [4])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt_3_s3  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n137_11 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [3])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt_1_s3  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n139_10 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [1])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt_0_s3  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n140_10 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt [0])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_st_ref_s5  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n295_6 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_st_ref )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_0_s3  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n320_13 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt [0])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRP_cnt_1_s6  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1749_12 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRP_cnt [1])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRP_cnt_0_s3  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1750_11 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRP_cnt [0])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_4_s6  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1775_9 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt [4])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_0_s3  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1779_9 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt [0])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRCD_cnt_1_s7  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1803_12 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRCD_cnt [1])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRCD_cnt_0_s3  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1804_11 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRCD_cnt [0])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTW_cnt_1_s6  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1815_10 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTW_cnt [1])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTW_cnt_0_s3  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1816_9 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTW_cnt [0])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTR_cnt_2_s6  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1828_10 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTR_cnt [2])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTR_cnt_1_s3  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1829_9 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTR_cnt [1])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTR_cnt_0_s3  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1830_9 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTR_cnt [0])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRAS_cnt_2_s6  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1846_10 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRAS_cnt [2])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTP_cnt_1_s6  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1861_10 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTP_cnt [1])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTP_cnt_0_s3  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1862_9 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTP_cnt [0])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTP_cnt_2_s6  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1874_9 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTP_cnt [2])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTP_cnt_1_s3  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1875_10 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTP_cnt [1])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTP_cnt_0_s3  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1876_10 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTP_cnt [0])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_7_s7  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1937_9 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [7])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_0_s3  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1944_10 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt [0])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tFAW_cnt_2_s2  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1908_21 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tFAW_cnt [2])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tFAW_cnt_1_s2  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1909_16 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tFAW_cnt [1])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tFAW_cnt_0_s2  (
	.D(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1910_18 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/tFAW_cnt [0])
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n951_s22  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n951_20 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n951_21 ),
	.S0(\gw3_top/u_gwmc_top/mem_RAMOUT_182_G[0]_2 ),
	.O(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n951_25 )
);
MUX2_LUT5 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n951_s23  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n951_22 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n951_23 ),
	.S0(\gw3_top/u_gwmc_top/mem_RAMOUT_182_G[0]_2 ),
	.O(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n951_27 )
);
MUX2_LUT6 \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n951_s21  (
	.I0(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n951_25 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n951_27 ),
	.S0(\gw3_top/u_gwmc_top/mem_RAMOUT_189_G[0]_2 ),
	.O(\gw3_top/u_gwmc_top/gwmc_bank_ctrl/n951_29 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n34_s0  (
	.I0(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt [3]),
	.I1(\gw3_top/init_complete_r ),
	.I2(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n34_7 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n34_5 ),
	.F(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n34_3 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_timing_ctrl/sre_accepted_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/sre_accept ),
	.I1(\gw3_top/u_gwmc_top/sre_request_Z ),
	.F(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/sre_accepted_5 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n68_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/rank_cnt [0]),
	.I1(\gw3_top/u_gwmc_top/refresh_request_Z ),
	.F(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n68_7 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n46_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n73_4 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer [1]),
	.I2(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer [0]),
	.F(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n46_7 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n44_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n73_4 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer [3]),
	.I2(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n44_8 ),
	.F(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n44_7 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n43_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer [5]),
	.I1(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer [4]),
	.I2(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n43_10 ),
	.F(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n43_7 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n17_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n34_5 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt [3]),
	.I2(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt [2]),
	.I3(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n17_8 ),
	.F(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n17_7 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n14_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt [4]),
	.I1(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt [3]),
	.I2(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n34_7 ),
	.I3(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt [5]),
	.F(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n14_7 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n45_s1  (
	.I0(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer [1]),
	.I2(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer [2]),
	.F(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n45_6 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n42_s1  (
	.I0(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer [4]),
	.I1(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n43_10 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer [5]),
	.F(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n42_6 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n18_s1  (
	.I0(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt [1]),
	.F(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n18_6 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n15_s1  (
	.I0(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt [3]),
	.I1(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n34_7 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt [4]),
	.F(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n15_6 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n34_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt [4]),
	.I1(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt [5]),
	.F(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n34_5 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n73_s1  (
	.I0(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer [4]),
	.I1(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer [5]),
	.I2(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n43_10 ),
	.F(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n73_4 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n44_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer [1]),
	.I2(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer [2]),
	.F(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n44_8 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n17_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt [1]),
	.F(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n17_8 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n34_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt [2]),
	.I1(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt [0]),
	.I2(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt [1]),
	.F(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n34_7 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n43_s4  (
	.I0(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer [3]),
	.I1(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer [0]),
	.I2(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer [1]),
	.I3(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer [2]),
	.F(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n43_10 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_request_s4  (
	.I0(\gw3_top/u_gwmc_top/cmd_accept_ref_Z_3 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/rank_cnt [0]),
	.I2(\gw3_top/u_gwmc_top/refresh_request_Z ),
	.I3(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n73_6 ),
	.F(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_request_7 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n16_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt [4]),
	.I1(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt [5]),
	.I2(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt [3]),
	.I3(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n34_7 ),
	.F(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n16_9 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n73_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n34_3 ),
	.I1(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer [4]),
	.I2(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer [5]),
	.I3(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n43_10 ),
	.F(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n73_6 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_timing_ctrl/rank_cnt_0_s4  (
	.I0(\gw3_top/u_gwmc_top/refresh_request_Z ),
	.I1(\gw3_top/u_gwmc_top/idle1 ),
	.I2(\gw3_top/u_gwmc_top/idle2 ),
	.I3(\gw3_top/u_gwmc_top/idle3 ),
	.F(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/rank_cnt_0_10 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n94_s2  (
	.I0(\gw3_top/init_complete_r ),
	.I1(sr_ack),
	.I2(\gw3_top/u_gwmc_top/sre_request_Z ),
	.I3(sr_req),
	.F(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n94_6 )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt_5_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n14_7 ),
	.CLK(clk_out),
	.CE(\gw3_top/init_complete_r ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt [5])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt_4_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n15_6 ),
	.CLK(clk_out),
	.CE(\gw3_top/init_complete_r ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt [4])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt_3_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n16_9 ),
	.CLK(clk_out),
	.CE(\gw3_top/init_complete_r ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt [3])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt_2_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n17_7 ),
	.CLK(clk_out),
	.CE(\gw3_top/init_complete_r ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt [2])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt_1_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n18_6 ),
	.CLK(clk_out),
	.CE(\gw3_top/init_complete_r ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt [1])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt_0_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n19_7 ),
	.CLK(clk_out),
	.CE(\gw3_top/init_complete_r ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt [0])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer_5_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n42_6 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n34_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer [5])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer_4_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n43_7 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n34_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer [4])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer_3_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n44_7 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n34_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer [3])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer_2_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n45_6 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n34_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer [2])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer_1_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n46_7 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n34_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer [1])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer_0_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n47_7 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n34_3 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer [0])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_timing_ctrl/ref_accepted_s0  (
	.D(\gw3_top/u_gwmc_top/cmd_accept_ref_Z ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(ref_ack)
);
DFFCE \gw3_top/u_gwmc_top/gwmc_timing_ctrl/sre_accept_s0  (
	.D(\gw3_top/u_gwmc_top/cmd_accept_sre_Z ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/sre_accept )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_timing_ctrl/init_complete_r_s0  (
	.D(\gw3_top/ddr_init_internal ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/init_complete_r )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_timing_ctrl/rank_cnt_0_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n68_7 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/rank_cnt_0_10 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/rank_cnt [0])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_request_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n73_6 ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_request_7 ),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/refresh_request_Z )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_timing_ctrl/sre_accepted_s1  (
	.D(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/sre_accept ),
	.CLK(clk_out),
	.CE(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/sre_accepted_5 ),
	.CLEAR(ddr_rst),
	.Q(sr_ack)
);
DFFCE \gw3_top/u_gwmc_top/gwmc_timing_ctrl/sre_request_s4  (
	.D(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n94_6 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/sre_request_Z )
);
LUT1 \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n47_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer [0]),
	.F(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n47_7 )
);
LUT1 \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n19_s2  (
	.I0(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt [0]),
	.F(\gw3_top/u_gwmc_top/gwmc_timing_ctrl/n19_7 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n458_s0  (
	.I0(\gw3_top/eye_app_wdf_wdata_Z [111]),
	.I1(wr_data[15]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [0]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n458_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n459_s0  (
	.I0(wr_data[14]),
	.I1(\gw3_top/u_gwmc_top/mc_ras_n_dly [3]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [0]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n459_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n460_s0  (
	.I0(wr_data[13]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [108]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [0]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n460_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n461_s0  (
	.I0(wr_data[12]),
	.I1(\gw3_top/u_gwmc_top/mc_ras_n_dly [3]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [0]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n461_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n462_s0  (
	.I0(wr_data[11]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [99]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [0]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n462_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n463_s0  (
	.I0(wr_data[10]),
	.I1(\gw3_top/u_gwmc_top/mc_ras_n_dly [3]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [0]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n463_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n464_s0  (
	.I0(wr_data[9]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [108]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [0]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n464_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n465_s0  (
	.I0(wr_data[8]),
	.I1(\gw3_top/u_gwmc_top/mc_ras_n_dly [3]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [0]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n465_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n466_s0  (
	.I0(wr_data[7]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [71]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [0]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n466_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n467_s0  (
	.I0(wr_data[6]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [110]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [0]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n467_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n468_s0  (
	.I0(wr_data[5]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [110]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [0]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n468_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n469_s0  (
	.I0(wr_data[4]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [106]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [0]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n469_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n470_s0  (
	.I0(wr_data[3]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [67]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [0]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n470_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n471_s0  (
	.I0(wr_data[2]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [106]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [0]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n471_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n472_s0  (
	.I0(wr_data[1]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [106]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [0]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n472_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n473_s0  (
	.I0(wr_data[0]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [110]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [0]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n473_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n491_s0  (
	.I0(\gw3_top/eye_app_wdf_wdata_Z [123]),
	.I1(wr_data[31]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [1]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n491_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n492_s0  (
	.I0(wr_data[30]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [124]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [1]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n492_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n494_s0  (
	.I0(wr_data[28]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [120]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [1]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n494_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n495_s0  (
	.I0(wr_data[27]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [123]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [1]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n495_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n496_s0  (
	.I0(wr_data[26]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [120]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [1]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n496_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n498_s0  (
	.I0(wr_data[24]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [120]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [1]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n498_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n499_s0  (
	.I0(wr_data[23]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [123]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [1]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n499_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n500_s0  (
	.I0(wr_data[22]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [120]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [1]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n500_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n501_s0  (
	.I0(wr_data[21]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [120]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [1]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n501_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n503_s0  (
	.I0(wr_data[19]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [123]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [1]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n503_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n504_s0  (
	.I0(wr_data[18]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [120]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [1]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n504_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n505_s0  (
	.I0(wr_data[17]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [124]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [1]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n505_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n524_s0  (
	.I0(wr_data[47]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [111]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [2]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n524_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n525_s0  (
	.I0(wr_data[46]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [110]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [2]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n525_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n526_s0  (
	.I0(wr_data[45]),
	.I1(\gw3_top/u_gwmc_top/mc_ras_n_dly [3]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [2]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n526_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n527_s0  (
	.I0(wr_data[44]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [108]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [2]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n527_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n528_s0  (
	.I0(wr_data[43]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [111]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [2]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n528_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n529_s0  (
	.I0(wr_data[42]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [106]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [2]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n529_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n530_s0  (
	.I0(wr_data[41]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [108]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [2]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n530_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n531_s0  (
	.I0(wr_data[40]),
	.I1(\gw3_top/u_gwmc_top/mc_ras_n_dly [3]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [2]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n531_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n532_s0  (
	.I0(wr_data[39]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [111]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [2]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n532_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n533_s0  (
	.I0(wr_data[38]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [108]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [2]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n533_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n534_s0  (
	.I0(wr_data[37]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [106]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [2]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n534_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n535_s0  (
	.I0(wr_data[36]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [106]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [2]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n535_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n536_s0  (
	.I0(wr_data[35]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [99]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [2]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n536_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n537_s0  (
	.I0(wr_data[34]),
	.I1(\gw3_top/u_gwmc_top/mc_ras_n_dly [3]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [2]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n537_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n538_s0  (
	.I0(wr_data[33]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [110]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [2]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n538_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n539_s0  (
	.I0(wr_data[32]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [110]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [2]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n539_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n557_s0  (
	.I0(\gw3_top/eye_app_wdf_wdata_Z [127]),
	.I1(wr_data[63]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [3]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n557_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n558_s0  (
	.I0(wr_data[62]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [126]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [3]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n558_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n560_s0  (
	.I0(wr_data[60]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [124]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [3]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n560_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n561_s0  (
	.I0(wr_data[59]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [123]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [3]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n561_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n564_s0  (
	.I0(wr_data[56]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [120]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [3]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n564_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n565_s0  (
	.I0(wr_data[55]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [123]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [3]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n565_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n567_s0  (
	.I0(wr_data[53]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [120]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [3]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n567_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n569_s0  (
	.I0(wr_data[51]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [127]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [3]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n569_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n571_s0  (
	.I0(wr_data[49]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [124]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [3]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n571_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n572_s0  (
	.I0(wr_data[48]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [126]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [3]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n572_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n590_s0  (
	.I0(wr_data[79]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [111]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [4]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n590_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n591_s0  (
	.I0(wr_data[78]),
	.I1(\gw3_top/u_gwmc_top/mc_ras_n_dly [3]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [4]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n591_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n592_s0  (
	.I0(wr_data[77]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [108]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [4]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n592_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n593_s0  (
	.I0(wr_data[76]),
	.I1(\gw3_top/u_gwmc_top/mc_ras_n_dly [3]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [4]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n593_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n594_s0  (
	.I0(wr_data[75]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [99]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [4]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n594_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n595_s0  (
	.I0(wr_data[74]),
	.I1(\gw3_top/u_gwmc_top/mc_ras_n_dly [3]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [4]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n595_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n596_s0  (
	.I0(wr_data[73]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [108]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [4]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n596_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n597_s0  (
	.I0(wr_data[72]),
	.I1(\gw3_top/u_gwmc_top/mc_ras_n_dly [3]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [4]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n597_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n598_s0  (
	.I0(wr_data[71]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [71]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [4]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n598_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n599_s0  (
	.I0(wr_data[70]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [110]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [4]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n599_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n600_s0  (
	.I0(wr_data[69]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [110]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [4]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n600_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n601_s0  (
	.I0(wr_data[68]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [106]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [4]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n601_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n602_s0  (
	.I0(wr_data[67]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [67]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [4]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n602_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n603_s0  (
	.I0(wr_data[66]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [106]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [4]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n603_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n604_s0  (
	.I0(wr_data[65]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [106]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [4]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n604_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n605_s0  (
	.I0(wr_data[64]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [110]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [4]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n605_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n623_s0  (
	.I0(wr_data[95]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [123]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [5]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n623_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n624_s0  (
	.I0(wr_data[94]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [124]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [5]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n624_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n626_s0  (
	.I0(wr_data[92]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [120]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [5]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n626_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n627_s0  (
	.I0(wr_data[91]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [123]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [5]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n627_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n628_s0  (
	.I0(wr_data[90]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [120]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [5]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n628_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n630_s0  (
	.I0(wr_data[88]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [120]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [5]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n630_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n631_s0  (
	.I0(wr_data[87]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [123]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [5]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n631_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n632_s0  (
	.I0(wr_data[86]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [120]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [5]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n632_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n633_s0  (
	.I0(wr_data[85]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [120]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [5]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n633_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n635_s0  (
	.I0(wr_data[83]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [123]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [5]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n635_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n636_s0  (
	.I0(wr_data[82]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [120]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [5]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n636_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n637_s0  (
	.I0(wr_data[81]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [124]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [5]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n637_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n656_s0  (
	.I0(wr_data[111]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [111]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [6]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n656_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n657_s0  (
	.I0(wr_data[110]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [110]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [6]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n657_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n658_s0  (
	.I0(wr_data[109]),
	.I1(\gw3_top/u_gwmc_top/mc_ras_n_dly [3]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [6]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n658_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n659_s0  (
	.I0(wr_data[108]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [108]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [6]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n659_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n660_s0  (
	.I0(wr_data[107]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [111]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [6]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n660_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n661_s0  (
	.I0(wr_data[106]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [106]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [6]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n661_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n662_s0  (
	.I0(wr_data[105]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [108]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [6]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n662_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n663_s0  (
	.I0(wr_data[104]),
	.I1(\gw3_top/u_gwmc_top/mc_ras_n_dly [3]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [6]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n663_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n664_s0  (
	.I0(wr_data[103]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [111]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [6]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n664_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n665_s0  (
	.I0(wr_data[102]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [108]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [6]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n665_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n666_s0  (
	.I0(wr_data[101]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [106]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [6]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n666_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n667_s0  (
	.I0(wr_data[100]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [106]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [6]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n667_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n668_s0  (
	.I0(wr_data[99]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [99]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [6]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n668_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n669_s0  (
	.I0(wr_data[98]),
	.I1(\gw3_top/u_gwmc_top/mc_ras_n_dly [3]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [6]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n669_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n670_s0  (
	.I0(wr_data[97]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [110]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [6]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n670_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n671_s0  (
	.I0(wr_data[96]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [110]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [6]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n671_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n689_s0  (
	.I0(wr_data[127]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [127]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [7]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n689_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n690_s0  (
	.I0(wr_data[126]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [126]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [7]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n690_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n692_s0  (
	.I0(wr_data[124]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [124]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [7]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n692_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n693_s0  (
	.I0(wr_data[123]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [123]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [7]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n693_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n696_s0  (
	.I0(wr_data[120]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [120]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [7]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n696_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n697_s0  (
	.I0(wr_data[119]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [123]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [7]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n697_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n699_s0  (
	.I0(wr_data[117]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [120]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [7]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n699_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n701_s0  (
	.I0(wr_data[115]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [127]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [7]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n701_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n703_s0  (
	.I0(wr_data[113]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [124]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [7]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n703_3 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/n704_s0  (
	.I0(wr_data[112]),
	.I1(\gw3_top/eye_app_wdf_wdata_Z [126]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [7]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n704_3 )
);
LUT4 \gw3_top/u_gwmc_top/gw_wr_data0/n756_s0  (
	.I0(wr_data_end),
	.I1(wr_data_en),
	.I2(\gw3_top/eye_app_wdf_wren_Z ),
	.I3(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_wen ),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n756_3 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/n722_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [8]),
	.I1(wr_data_mask[15]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n722_7 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/n723_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [8]),
	.I1(wr_data_mask[14]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n723_7 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/n724_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [8]),
	.I1(wr_data_mask[13]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n724_7 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/n725_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [8]),
	.I1(wr_data_mask[12]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n725_7 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/n726_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [8]),
	.I1(wr_data_mask[11]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n726_7 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/n727_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [8]),
	.I1(wr_data_mask[10]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n727_7 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/n728_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [8]),
	.I1(wr_data_mask[9]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n728_7 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/n729_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [8]),
	.I1(wr_data_mask[8]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n729_7 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/n730_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [8]),
	.I1(wr_data_mask[7]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n730_7 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/n731_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [8]),
	.I1(wr_data_mask[6]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n731_7 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/n732_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [8]),
	.I1(wr_data_mask[5]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n732_7 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/n733_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [8]),
	.I1(wr_data_mask[4]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n733_7 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/n734_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [8]),
	.I1(wr_data_mask[3]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n734_7 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/n735_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [8]),
	.I1(wr_data_mask[2]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n735_7 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/n736_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [8]),
	.I1(wr_data_mask[1]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n736_7 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/n737_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [8]),
	.I1(wr_data_mask[0]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n737_7 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/n691_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [7]),
	.I1(wr_data[125]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n691_7 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/n559_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [3]),
	.I1(wr_data[61]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n559_7 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/n694_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [7]),
	.I1(wr_data[122]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n694_7 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/n562_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [3]),
	.I1(wr_data[58]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n562_7 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/n695_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [7]),
	.I1(wr_data[121]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n695_7 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/n563_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [3]),
	.I1(wr_data[57]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n563_7 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/n698_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [7]),
	.I1(wr_data[118]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n698_7 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/n566_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [3]),
	.I1(wr_data[54]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n566_7 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/n700_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [7]),
	.I1(wr_data[116]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n700_7 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/n568_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [3]),
	.I1(wr_data[52]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n568_7 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/n702_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [7]),
	.I1(wr_data[114]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n702_7 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/n570_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [3]),
	.I1(wr_data[50]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n570_7 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/n625_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [5]),
	.I1(wr_data[93]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n625_7 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/n493_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [1]),
	.I1(wr_data[29]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n493_7 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/n629_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [5]),
	.I1(wr_data[89]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n629_7 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/n497_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [1]),
	.I1(wr_data[25]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n497_7 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/n634_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [5]),
	.I1(wr_data[84]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n634_7 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/n502_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [1]),
	.I1(wr_data[20]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n502_7 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/n638_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [5]),
	.I1(wr_data[80]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n638_7 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/n506_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [1]),
	.I1(wr_data[16]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n506_7 )
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq_7_s0  (
	.D(\gw3_top/eye_calib_start_Z ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [7])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq_6_s0  (
	.D(\gw3_top/eye_calib_start_Z ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [6])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq_5_s0  (
	.D(\gw3_top/eye_calib_start_Z ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [5])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq_4_s0  (
	.D(\gw3_top/eye_calib_start_Z ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [4])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq_3_s0  (
	.D(\gw3_top/eye_calib_start_Z ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [3])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq_2_s0  (
	.D(\gw3_top/eye_calib_start_Z ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [2])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq_1_s0  (
	.D(\gw3_top/eye_calib_start_Z ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [1])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq_0_s0  (
	.D(\gw3_top/eye_calib_start_Z ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [0])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_wen_s0  (
	.D(\gw3_top/eye_calib_start_Z ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_wen )
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_15_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n458_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [15])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_14_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n459_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [14])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_13_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n460_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [13])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_12_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n461_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [12])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_11_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n462_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [11])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_10_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n463_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [10])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_9_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n464_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [9])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_8_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n465_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [8])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_7_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n466_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [7])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_6_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n467_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [6])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_5_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n468_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [5])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_4_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n469_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [4])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_3_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n470_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [3])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_2_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n471_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [2])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_1_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n472_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [1])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_0_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n473_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [0])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_31_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n491_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [31])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_30_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n492_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [30])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_29_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n493_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [29])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_28_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n494_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [28])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_27_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n495_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [27])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_26_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n496_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [26])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_25_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n497_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [25])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_24_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n498_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [24])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_23_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n499_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [23])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_22_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n500_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [22])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_21_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n501_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [21])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_20_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n502_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [20])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_19_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n503_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [19])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_18_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n504_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [18])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_17_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n505_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [17])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_16_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n506_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [16])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_47_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n524_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [47])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_46_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n525_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [46])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_45_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n526_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [45])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_44_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n527_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [44])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_43_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n528_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [43])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_42_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n529_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [42])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_41_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n530_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [41])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_40_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n531_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [40])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_39_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n532_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [39])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_38_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n533_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [38])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_37_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n534_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [37])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_36_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n535_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [36])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_35_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n536_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [35])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_34_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n537_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [34])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_33_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n538_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [33])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_32_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n539_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [32])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_63_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n557_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [63])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_62_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n558_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [62])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_61_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n559_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [61])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_60_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n560_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [60])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_59_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n561_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [59])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_58_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n562_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [58])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_57_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n563_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [57])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_56_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n564_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [56])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_55_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n565_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [55])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_54_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n566_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [54])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_53_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n567_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [53])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_52_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n568_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [52])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_51_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n569_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [51])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_50_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n570_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [50])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_49_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n571_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [49])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_48_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n572_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [48])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_79_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n590_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [79])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_78_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n591_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [78])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_77_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n592_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [77])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_76_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n593_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [76])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_75_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n594_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [75])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_74_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n595_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [74])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_73_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n596_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [73])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_72_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n597_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [72])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_71_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n598_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [71])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_70_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n599_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [70])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_69_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n600_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [69])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_68_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n601_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [68])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_67_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n602_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [67])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_66_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n603_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [66])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_65_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n604_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [65])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_64_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n605_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [64])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_95_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n623_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [95])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_94_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n624_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [94])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_93_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n625_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [93])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_92_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n626_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [92])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_91_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n627_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [91])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_90_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n628_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [90])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_89_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n629_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [89])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_88_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n630_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [88])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_87_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n631_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [87])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_86_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n632_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [86])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_85_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n633_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [85])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_84_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n634_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [84])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_83_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n635_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [83])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_82_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n636_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [82])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_81_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n637_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [81])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_80_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n638_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [80])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_111_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n656_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [111])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_110_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n657_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [110])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_109_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n658_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [109])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_108_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n659_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [108])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_107_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n660_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [107])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_106_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n661_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [106])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_105_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n662_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [105])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_104_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n663_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [104])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_103_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n664_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [103])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_102_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n665_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [102])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_101_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n666_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [101])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_100_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n667_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [100])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_99_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n668_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [99])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_98_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n669_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [98])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_97_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n670_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [97])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_96_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n671_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [96])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_127_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n689_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [127])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_126_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n690_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [126])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_125_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n691_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [125])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_124_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n692_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [124])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_123_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n693_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [123])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_122_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n694_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [122])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_121_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n695_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [121])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_120_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n696_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [120])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_119_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n697_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [119])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_118_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n698_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [118])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_117_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n699_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [117])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_116_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n700_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [116])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_115_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n701_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [115])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_114_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n702_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [114])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_113_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n703_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [113])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_112_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n704_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [112])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_143_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n722_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [143])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_142_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n723_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [142])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_141_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n724_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [141])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_140_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n725_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [140])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_139_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n726_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [139])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_138_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n727_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [138])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_137_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n728_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [137])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_136_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n729_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [136])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_135_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n730_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [135])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_134_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n731_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [134])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_133_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n732_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [133])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_132_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n733_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [132])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_131_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n734_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [131])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_130_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n735_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [130])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_129_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n736_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [129])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_128_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n737_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [128])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_wrbuf_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n756_3 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_wrbuf )
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_full_r_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_full ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_full_r )
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_rdy_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/n760_6 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(wr_data_rdy)
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq_8_s0  (
	.D(\gw3_top/eye_calib_start_Z ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq [8])
);
LUT1 \gw3_top/u_gwmc_top/gw_wr_data0/n760_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_full ),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/n760_6 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n28_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wr_buf_empt ),
	.I1(\gw3_top/u_gwmc_top/send_wr ),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n28_3 )
);
LUT4 \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n24_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_full_r ),
	.I1(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_full ),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/Full ),
	.I3(\gw3_top/u_gwmc_top/gw_wr_data0/wr_wrbuf ),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n24_4 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wfull_val_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n641_8 ),
	.I1(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wfull_val_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wfull_val_5 ),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wfull_val )
);
LUT4 \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/awfull_val_s15  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wcnt_sub [1]),
	.I1(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wcnt_sub [3]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wcnt_sub [2]),
	.I3(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wcnt_sub [4]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/awfull_val )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next_2_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin [1]),
	.I1(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_f_0_7 ),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin [2]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next [2])
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next_4_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin [3]),
	.I1(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next_3_8 ),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin [4]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next [4])
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next_0_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin [0]),
	.I1(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n24_4 ),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next_0_8 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next_1_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin [0]),
	.I1(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n24_4 ),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin [1]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next [1])
);
LUT4 \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next_2_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin [0]),
	.I1(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin [1]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n24_4 ),
	.I3(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin [2]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next [2])
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next_3_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin [3]),
	.I1(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next_3_8 ),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next [3])
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next_4_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin [3]),
	.I1(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next_3_8 ),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin [4]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next [4])
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_f_0_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wr_buf_empt ),
	.I1(\gw3_top/u_gwmc_top/send_wr ),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin [0]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_f_0_7 )
);
LUT4 \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wfull_val_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wfull_val_6 ),
	.I1(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin [0]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n24_4 ),
	.I3(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next_0_10 ),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wfull_val_4 )
);
LUT4 \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wfull_val_s2  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next [2]),
	.I1(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next [2]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next [3]),
	.I3(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next [3]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wfull_val_5 )
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next_3_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin [2]),
	.I1(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin [1]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_f_0_7 ),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next_3_8 )
);
LUT4 \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next_3_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin [0]),
	.I1(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin [1]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin [2]),
	.I3(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n24_4 ),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next_3_8 )
);
LUT2 \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wfull_val_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin [1]),
	.I1(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next [1]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wfull_val_6 )
);
LUT4 \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next_3_s5  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin [3]),
	.I1(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin [2]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin [1]),
	.I3(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_f_0_7 ),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next [3])
);
LUT4 \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n641_s3  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin [3]),
	.I1(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next_3_8 ),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin [4]),
	.I3(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next [4]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n641_8 )
);
LUT4 \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next_1_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin [1]),
	.I1(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wr_buf_empt ),
	.I2(\gw3_top/u_gwmc_top/send_wr ),
	.I3(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin [0]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next [1])
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next_0_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin [0]),
	.I1(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wr_buf_empt ),
	.I2(\gw3_top/u_gwmc_top/send_wr ),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next_0_10 )
);
LUT4 \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_f_0_s5  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wr_buf_empt ),
	.I1(\gw3_top/u_gwmc_top/send_wr ),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_dly [0]),
	.I3(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_f_0_7 ),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_f [0])
);
LUT4 \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_f_1_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin [1]),
	.I1(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_dly [1]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wr_buf_empt ),
	.I3(\gw3_top/u_gwmc_top/send_wr ),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_f [1])
);
LUT4 \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_f_2_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin [2]),
	.I1(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_dly [2]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wr_buf_empt ),
	.I3(\gw3_top/u_gwmc_top/send_wr ),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_f [2])
);
LUT4 \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_f_3_s4  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin [3]),
	.I1(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_dly [3]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wr_buf_empt ),
	.I3(\gw3_top/u_gwmc_top/send_wr ),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_f [3])
);
LUT3 \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rempty_val_s1  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n655_3 ),
	.I1(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next [4]),
	.I2(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next [4]),
	.F(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rempty_val )
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_dly_2_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_f [2]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(GND),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_dly [2])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_dly_1_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_f [1]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(GND),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_dly [1])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_dly_0_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_f [0]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(GND),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_dly [0])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_4_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next [4]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin [4])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_3_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next [3]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin [3])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_2_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next [2]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin [2])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_1_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next [1]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin [1])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_0_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next_0_10 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin [0])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_4_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next [4]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin [4])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_3_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next [3]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin [3])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_2_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next [2]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin [2])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_1_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next [1]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin [1])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_0_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next_0_8 ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin [0])
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/Full_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wfull_val ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/Full )
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/Almost_Full_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/awfull_val ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_full )
);
DFFCE \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_dly_3_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_f [3]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(GND),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_dly [3])
);
DFFPE \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/Empty_s0  (
	.D(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rempty_val ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wr_buf_empt )
);
SDPX9B \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/mem_mem_0_0_s  (
	.CLKA(clk_out),
	.CEA(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n24_4 ),
	.CLKB(clk_out),
	.CEB(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n28_3 ),
	.OCE(VCC),
	.RESET(ddr_rst),
	.BLKSELA({GND, GND, GND}),
	.BLKSELB({GND, GND, GND}),
	.DI({\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [35:0]}),
	.ADA({GND, GND, GND, GND, GND, \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin [3:0], GND, VCC, VCC, VCC, VCC}),
	.ADB({GND, GND, GND, GND, GND, \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_f [3:0], GND, GND, GND, GND, GND}),
	.DO({\gw3_top/u_gwmc_top/mc_wrdata_dly [35:0]})
);
SDPX9B \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/mem_mem_0_1_s  (
	.CLKA(clk_out),
	.CEA(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n24_4 ),
	.CLKB(clk_out),
	.CEB(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n28_3 ),
	.OCE(VCC),
	.RESET(ddr_rst),
	.BLKSELA({GND, GND, GND}),
	.BLKSELB({GND, GND, GND}),
	.DI({\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [71:36]}),
	.ADA({GND, GND, GND, GND, GND, \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin [3:0], GND, VCC, VCC, VCC, VCC}),
	.ADB({GND, GND, GND, GND, GND, \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_f [3:0], GND, GND, GND, GND, GND}),
	.DO({\gw3_top/u_gwmc_top/mc_wrdata_dly [71:36]})
);
SDPX9B \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/mem_mem_0_2_s  (
	.CLKA(clk_out),
	.CEA(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n24_4 ),
	.CLKB(clk_out),
	.CEB(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n28_3 ),
	.OCE(VCC),
	.RESET(ddr_rst),
	.BLKSELA({GND, GND, GND}),
	.BLKSELB({GND, GND, GND}),
	.DI({\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [107:72]}),
	.ADA({GND, GND, GND, GND, GND, \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin [3:0], GND, VCC, VCC, VCC, VCC}),
	.ADB({GND, GND, GND, GND, GND, \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_f [3:0], GND, GND, GND, GND, GND}),
	.DO({\gw3_top/u_gwmc_top/mc_wrdata_dly [107:72]})
);
SDPX9B \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/mem_mem_0_3_s  (
	.CLKA(clk_out),
	.CEA(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n24_4 ),
	.CLKB(clk_out),
	.CEB(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n28_3 ),
	.OCE(VCC),
	.RESET(ddr_rst),
	.BLKSELA({GND, GND, GND}),
	.BLKSELB({GND, GND, GND}),
	.DI({\gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din [143:108]}),
	.ADA({GND, GND, GND, GND, GND, \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin [3:0], GND, VCC, VCC, VCC, VCC}),
	.ADB({GND, GND, GND, GND, GND, \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_f [3:0], GND, GND, GND, GND, GND}),
	.DO({\gw3_top/u_gwmc_top/mc_wrdata_mask_dly [15:0], \gw3_top/u_gwmc_top/mc_wrdata_dly [127:108]})
);
ALU \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wcnt_sub_0_s  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next_0_8 ),
	.I1(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next_0_10 ),
	.I3(VCC),
	.CIN(VCC),
	.COUT(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wcnt_sub_0_3 ),
	.SUM(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wcnt_sub [0])
);
ALU \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wcnt_sub_1_s  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next [1]),
	.I1(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next [1]),
	.I3(VCC),
	.CIN(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wcnt_sub_0_3 ),
	.COUT(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wcnt_sub_1_3 ),
	.SUM(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wcnt_sub [1])
);
ALU \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wcnt_sub_2_s  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next [2]),
	.I1(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next [2]),
	.I3(VCC),
	.CIN(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wcnt_sub_1_3 ),
	.COUT(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wcnt_sub_2_3 ),
	.SUM(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wcnt_sub [2])
);
ALU \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wcnt_sub_3_s  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next [3]),
	.I1(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next [3]),
	.I3(VCC),
	.CIN(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wcnt_sub_2_3 ),
	.COUT(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wcnt_sub_3_3 ),
	.SUM(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wcnt_sub [3])
);
ALU \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wcnt_sub_4_s  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n641_8 ),
	.I1(GND),
	.I3(VCC),
	.CIN(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wcnt_sub_3_3 ),
	.COUT(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wcnt_sub_4_0_COUT ),
	.SUM(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wcnt_sub [4])
);
ALU \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n652_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next_0_10 ),
	.I1(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next_0_8 ),
	.I3(GND),
	.CIN(GND),
	.COUT(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n652_3 ),
	.SUM(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n652_1_SUM )
);
ALU \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n653_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next [1]),
	.I1(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next [1]),
	.I3(GND),
	.CIN(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n652_3 ),
	.COUT(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n653_3 ),
	.SUM(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n653_1_SUM )
);
ALU \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n654_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next [2]),
	.I1(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next [2]),
	.I3(GND),
	.CIN(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n653_3 ),
	.COUT(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n654_3 ),
	.SUM(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n654_1_SUM )
);
ALU \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n655_s0  (
	.I0(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next [3]),
	.I1(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next [3]),
	.I3(GND),
	.CIN(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n654_3 ),
	.COUT(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n655_3 ),
	.SUM(\gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n655_1_SUM )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/mc_cs_n_out_2_s  (
	.I0(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2 [21]),
	.I1(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/cs_en2 ),
	.F(\gw3_top/u_gwmc_top/mc_cs_n_out [2])
);
LUT2 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/mc_cs_n_out_3_s  (
	.I0(\gw3_top/u_gwmc_top/cmd3 [21]),
	.I1(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/cs_en3 ),
	.F(\gw3_top/u_gwmc_top/mc_cs_n_out [3])
);
LUT4 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/mc_odt_out_0_s  (
	.I0(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/col_cmd_we ),
	.I1(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/cs_en3 ),
	.I2(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/auxgen.mc_aux_out_r [0]),
	.I3(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/auxgen.mc_aux_out_r_1 [0]),
	.F(\gw3_top/u_gwmc_top/mc_odt_out [0])
);
LUT2 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n297_s2  (
	.I0(\gw3_top/u_gwmc_top/send_wr ),
	.I1(\gw3_top/u_gwmc_top/send_rd ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n297_7 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n209_s2  (
	.I0(\gw3_top/u_gwmc_top/act_shift_reg [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n209_10 ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n209_7 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n213_s2  (
	.I0(\gw3_top/u_gwmc_top/row_d [14]),
	.I1(\gw3_top/u_gwmc_top/act_shift_reg [0]),
	.I2(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n209_10 ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n213_7 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n214_s2  (
	.I0(\gw3_top/u_gwmc_top/row_d [13]),
	.I1(\gw3_top/u_gwmc_top/act_shift_reg [0]),
	.I2(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n209_10 ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n214_7 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n215_s2  (
	.I0(\gw3_top/u_gwmc_top/row_d [12]),
	.I1(\gw3_top/u_gwmc_top/act_shift_reg [0]),
	.I2(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n209_10 ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n215_7 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n216_s2  (
	.I0(\gw3_top/u_gwmc_top/row_d [11]),
	.I1(\gw3_top/u_gwmc_top/act_shift_reg [0]),
	.I2(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n209_10 ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n216_7 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n218_s2  (
	.I0(\gw3_top/u_gwmc_top/row_d [9]),
	.I1(\gw3_top/u_gwmc_top/act_shift_reg [0]),
	.I2(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n209_10 ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n218_7 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n219_s2  (
	.I0(\gw3_top/u_gwmc_top/row_d [8]),
	.I1(\gw3_top/u_gwmc_top/act_shift_reg [0]),
	.I2(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n209_10 ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n219_7 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n220_s2  (
	.I0(\gw3_top/u_gwmc_top/row_d [7]),
	.I1(\gw3_top/u_gwmc_top/act_shift_reg [0]),
	.I2(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n209_10 ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n220_7 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n221_s2  (
	.I0(\gw3_top/u_gwmc_top/row_d [6]),
	.I1(\gw3_top/u_gwmc_top/act_shift_reg [0]),
	.I2(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n209_10 ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n221_7 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n222_s2  (
	.I0(\gw3_top/u_gwmc_top/row_d [5]),
	.I1(\gw3_top/u_gwmc_top/act_shift_reg [0]),
	.I2(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n209_10 ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n222_7 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n223_s2  (
	.I0(\gw3_top/u_gwmc_top/row_d [4]),
	.I1(\gw3_top/u_gwmc_top/act_shift_reg [0]),
	.I2(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n209_10 ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n223_7 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n224_s2  (
	.I0(\gw3_top/u_gwmc_top/row_d [3]),
	.I1(\gw3_top/u_gwmc_top/act_shift_reg [0]),
	.I2(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n209_10 ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n224_7 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n225_s2  (
	.I0(\gw3_top/u_gwmc_top/row_d [2]),
	.I1(\gw3_top/u_gwmc_top/act_shift_reg [0]),
	.I2(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n209_10 ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n225_7 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n226_s2  (
	.I0(\gw3_top/u_gwmc_top/row_d [1]),
	.I1(\gw3_top/u_gwmc_top/act_shift_reg [0]),
	.I2(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n209_10 ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n226_7 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n227_s2  (
	.I0(\gw3_top/u_gwmc_top/row_d [0]),
	.I1(\gw3_top/u_gwmc_top/act_shift_reg [0]),
	.I2(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n209_10 ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n227_7 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n229_s3  (
	.I0(\gw3_top/u_gwmc_top/send_ref_Z ),
	.I1(\gw3_top/u_gwmc_top/send_sre_Z ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n229_8 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n230_s2  (
	.I0(\gw3_top/u_gwmc_top/act_shift_reg [0]),
	.I1(\gw3_top/u_gwmc_top/send_pre_Z ),
	.I2(\gw3_top/u_gwmc_top/send_zqcs_Z ),
	.I3(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n229_8 ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n230_7 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n217_s3  (
	.I0(\gw3_top/u_gwmc_top/row_d [10]),
	.I1(\gw3_top/u_gwmc_top/act_shift_reg [0]),
	.I2(\gw3_top/u_gwmc_top/pre_all_Z ),
	.I3(\gw3_top/u_gwmc_top/send_pre_Z ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n217_8 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n210_s4  (
	.I0(\gw3_top/u_gwmc_top/send_zqcs_Z ),
	.I1(\gw3_top/u_gwmc_top/send_ref_Z ),
	.I2(\gw3_top/u_gwmc_top/send_sre_Z ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n210_10 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n228_s3  (
	.I0(\gw3_top/u_gwmc_top/send_ref_Z ),
	.I1(\gw3_top/u_gwmc_top/send_sre_Z ),
	.I2(\gw3_top/u_gwmc_top/send_zqcs_Z ),
	.I3(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n209_7 ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n228_9 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n278_s3  (
	.I0(\gw3_top/u_gwmc_top/bank_d [2]),
	.I1(\gw3_top/u_gwmc_top/send_wr ),
	.I2(\gw3_top/u_gwmc_top/send_rd ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n278_9 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n279_s3  (
	.I0(\gw3_top/u_gwmc_top/bank_d [1]),
	.I1(\gw3_top/u_gwmc_top/send_wr ),
	.I2(\gw3_top/u_gwmc_top/send_rd ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n279_9 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n280_s3  (
	.I0(\gw3_top/u_gwmc_top/bank_d [0]),
	.I1(\gw3_top/u_gwmc_top/send_wr ),
	.I2(\gw3_top/u_gwmc_top/send_rd ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n280_9 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n286_s3  (
	.I0(\gw3_top/u_gwmc_top/col_d [9]),
	.I1(\gw3_top/u_gwmc_top/send_wr ),
	.I2(\gw3_top/u_gwmc_top/send_rd ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n286_9 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n287_s3  (
	.I0(\gw3_top/u_gwmc_top/col_d [8]),
	.I1(\gw3_top/u_gwmc_top/send_wr ),
	.I2(\gw3_top/u_gwmc_top/send_rd ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n287_9 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n288_s3  (
	.I0(\gw3_top/u_gwmc_top/col_d [7]),
	.I1(\gw3_top/u_gwmc_top/send_wr ),
	.I2(\gw3_top/u_gwmc_top/send_rd ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n288_9 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n289_s3  (
	.I0(\gw3_top/u_gwmc_top/col_d [6]),
	.I1(\gw3_top/u_gwmc_top/send_wr ),
	.I2(\gw3_top/u_gwmc_top/send_rd ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n289_9 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n290_s3  (
	.I0(\gw3_top/u_gwmc_top/col_d [5]),
	.I1(\gw3_top/u_gwmc_top/send_wr ),
	.I2(\gw3_top/u_gwmc_top/send_rd ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n290_9 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n291_s3  (
	.I0(\gw3_top/u_gwmc_top/col_d [4]),
	.I1(\gw3_top/u_gwmc_top/send_wr ),
	.I2(\gw3_top/u_gwmc_top/send_rd ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n291_9 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n292_s3  (
	.I0(\gw3_top/u_gwmc_top/col_d [3]),
	.I1(\gw3_top/u_gwmc_top/send_wr ),
	.I2(\gw3_top/u_gwmc_top/send_rd ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n292_9 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n293_s3  (
	.I0(\gw3_top/u_gwmc_top/col_d [2]),
	.I1(\gw3_top/u_gwmc_top/send_wr ),
	.I2(\gw3_top/u_gwmc_top/send_rd ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n293_9 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n294_s3  (
	.I0(\gw3_top/u_gwmc_top/col_d [1]),
	.I1(\gw3_top/u_gwmc_top/send_wr ),
	.I2(\gw3_top/u_gwmc_top/send_rd ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n294_9 )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n295_s3  (
	.I0(\gw3_top/u_gwmc_top/col_d [0]),
	.I1(\gw3_top/u_gwmc_top/send_wr ),
	.I2(\gw3_top/u_gwmc_top/send_rd ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n295_9 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/sent_col_s1  (
	.I0(\gw3_top/u_gwmc_top/send_wr ),
	.I1(\gw3_top/u_gwmc_top/send_rd ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/sent_col )
);
LUT3 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n411_s4  (
	.I0(\gw3_top/u_gwmc_top/cke_set_Z ),
	.I1(\gw3_top/u_gwmc_top/mc_cke_out [3]),
	.I2(\gw3_top/u_gwmc_top/send_sre_Z ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n411_10 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n217_s4  (
	.I0(\gw3_top/u_gwmc_top/send_zqcs_Z ),
	.I1(\gw3_top/u_gwmc_top/send_ref_Z ),
	.I2(\gw3_top/u_gwmc_top/send_sre_Z ),
	.I3(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n217_8 ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n217_10 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n209_s4  (
	.I0(\gw3_top/u_gwmc_top/send_pre_Z ),
	.I1(\gw3_top/u_gwmc_top/send_zqcs_Z ),
	.I2(\gw3_top/u_gwmc_top/send_ref_Z ),
	.I3(\gw3_top/u_gwmc_top/send_sre_Z ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n209_10 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n212_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n210_10 ),
	.I1(\gw3_top/u_gwmc_top/bank_d [0]),
	.I2(\gw3_top/u_gwmc_top/act_shift_reg [0]),
	.I3(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n209_10 ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n212_9 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n211_s3  (
	.I0(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n210_10 ),
	.I1(\gw3_top/u_gwmc_top/bank_d [1]),
	.I2(\gw3_top/u_gwmc_top/act_shift_reg [0]),
	.I3(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n209_10 ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n211_9 )
);
LUT4 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n210_s5  (
	.I0(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n210_10 ),
	.I1(\gw3_top/u_gwmc_top/bank_d [2]),
	.I2(\gw3_top/u_gwmc_top/act_shift_reg [0]),
	.I3(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n209_10 ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n210_12 )
);
LUT2 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/sent_row_s1  (
	.I0(\gw3_top/u_gwmc_top/act_shift_reg [0]),
	.I1(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n209_10 ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/sent_row )
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_20_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n210_12 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_bank_out [8])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_19_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n211_9 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_bank_out [7])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_18_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n212_9 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_bank_out [6])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_17_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n213_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_out [44])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_16_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n214_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_out [43])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_15_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n215_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_out [42])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_14_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n216_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_out [41])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_13_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n217_10 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_out [40])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_12_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n218_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_out [39])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_11_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n219_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_out [38])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_10_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n220_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_out [37])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_9_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n221_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_out [36])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_8_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n222_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_out [35])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_7_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n223_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_out [34])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_6_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n224_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_out [33])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_5_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n225_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_out [32])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_4_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n226_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_out [31])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_3_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n227_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_out [30])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_2_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n228_9 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_ras_n_out [2])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_1_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n229_8 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_cas_n_out [2])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_0_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n230_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_we_n_out [2])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd3_21_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n297_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/cmd3 [21])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd3_20_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n278_9 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_bank_out [11])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd3_19_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n279_9 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_bank_out [10])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd3_18_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n280_9 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_bank_out [9])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd3_12_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n286_9 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_out [54])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd3_11_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n287_9 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_out [53])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd3_10_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n288_9 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_out [52])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd3_9_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n289_9 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_out [51])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd3_8_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n290_9 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_out [50])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd3_7_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n291_9 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_out [49])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd3_6_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n292_9 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_out [48])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd3_5_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n293_9 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_out [47])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd3_4_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n294_9 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_out [46])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd3_3_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n295_9 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_address_out [45])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd3_0_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n298_8 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_we_n_out [3])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cs_en2_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/sent_row ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/cs_en2 )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cs_en3_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/sent_col ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/cs_en3 )
);
DFFCE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/col_cmd_we_s0  (
	.D(\gw3_top/u_gwmc_top/send_wr ),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/col_cmd_we )
);
DFFRE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/auxgen.mc_aux_out_r_0_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/cs_en3 ),
	.CLK(clk_out),
	.CE(VCC),
	.RESET(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/slot_0_read_5 ),
	.Q(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/auxgen.mc_aux_out_r [0])
);
DFFCE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/auxgen.mc_aux_out_r_1_0_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/auxgen.mc_aux_out_r [0]),
	.CLK(clk_out),
	.CE(VCC),
	.CLEAR(GND),
	.Q(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/auxgen.mc_aux_out_r_1 [0])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_21_s0  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n209_7 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2 [21])
);
DFFPE \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cke_s4  (
	.D(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n411_10 ),
	.CLK(clk_out),
	.CE(VCC),
	.PRESET(ddr_rst),
	.Q(\gw3_top/u_gwmc_top/mc_cke_out [3])
);
INV \gw3_top/u_gwmc_top/gwmc_rank_ctrl/slot_0_read_s2  (
	.I(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/col_cmd_we ),
	.O(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/slot_0_read_5 )
);
LUT1 \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n298_s3  (
	.I0(\gw3_top/u_gwmc_top/send_wr ),
	.F(\gw3_top/u_gwmc_top/gwmc_rank_ctrl/n298_8 )
);
defparam \gw3_top/u_gwmc_top/n8_s0 .INIT=8'hAC;
defparam \gw3_top/u_gwmc_top/n11_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/n35_s0 .INIT=8'hAC;
defparam \gw3_top/u_gwmc_top/n36_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/n37_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/n41_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/n42_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/n43_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/n44_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/n113_s0 .INIT=4'hE;
defparam \gw3_top/u_gwmc_top/n40_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/n39_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/n38_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/n34_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/n33_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/n32_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/n31_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/n30_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/n29_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/n28_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/n27_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/n26_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/n25_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/n24_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/n23_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/n22_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/n21_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/n20_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/n9_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/n10_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/n45_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/n46_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/n47_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/eye_calib_start_addr_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/app_en_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/app_cmd_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/app_cmd_1_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/app_cmd_0_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/app_addr_27_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/app_addr_26_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/app_addr_25_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/app_addr_24_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/app_addr_23_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/app_addr_22_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/app_addr_21_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/app_addr_20_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/app_addr_19_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/app_addr_18_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/app_addr_17_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/app_addr_16_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/app_addr_15_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/app_addr_14_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/app_addr_13_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/app_addr_12_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/app_addr_11_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/app_addr_10_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/app_addr_9_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/app_addr_8_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/app_addr_7_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/app_addr_6_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/app_addr_5_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/app_addr_4_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/app_addr_3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/app_addr_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/app_addr_1_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/app_addr_0_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_ras_n_dly_3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_ras_n_dly_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_cas_n_dly_3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_cas_n_dly_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_we_n_dly_3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_we_n_dly_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_dly_54_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_dly_53_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_dly_52_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_dly_51_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_dly_50_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_dly_49_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_dly_48_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_dly_47_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_dly_46_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_dly_45_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_dly_44_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_dly_43_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_dly_42_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_dly_41_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_dly_40_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_dly_39_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_dly_38_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_dly_37_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_dly_36_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_dly_35_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_dly_34_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_dly_33_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_dly_32_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_dly_31_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_dly_30_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_bank_dly_11_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_bank_dly_10_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_bank_dly_9_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_bank_dly_8_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_bank_dly_7_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_bank_dly_6_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_cs_n_dly_3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_cs_n_dly_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_odt_dly_1_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_cke_dly_3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_ras_n_3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_ras_n_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_cas_n_3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_cas_n_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_we_n_3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_we_n_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_54_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_53_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_52_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_51_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_50_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_49_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_48_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_47_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_46_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_45_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_44_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_43_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_42_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_41_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_40_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_39_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_38_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_37_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_36_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_35_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_34_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_33_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_32_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_31_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_address_30_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_bank_11_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_bank_10_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_bank_9_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_bank_8_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_bank_7_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_bank_6_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_cs_n_3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_cs_n_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_odt_1_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_cke_3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_127_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_126_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_125_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_124_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_123_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_122_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_121_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_120_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_119_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_118_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_117_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_116_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_115_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_114_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_113_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_112_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_111_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_110_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_109_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_108_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_107_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_106_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_105_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_104_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_103_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_102_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_101_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_100_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_99_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_98_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_97_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_96_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_95_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_94_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_93_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_92_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_91_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_90_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_89_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_88_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_87_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_86_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_85_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_84_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_83_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_82_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_81_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_80_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_79_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_78_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_77_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_76_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_75_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_74_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_73_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_72_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_71_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_70_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_69_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_68_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_67_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_66_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_65_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_64_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_63_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_62_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_61_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_60_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_59_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_58_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_57_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_56_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_55_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_54_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_53_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_52_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_51_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_50_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_49_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_48_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_47_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_46_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_45_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_44_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_43_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_42_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_41_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_40_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_39_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_38_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_37_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_36_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_35_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_34_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_33_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_32_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_31_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_30_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_29_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_28_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_27_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_26_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_25_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_24_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_23_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_22_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_21_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_20_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_19_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_18_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_17_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_16_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_15_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_14_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_13_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_12_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_11_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_10_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_9_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_8_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_7_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_6_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_5_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_4_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_1_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_dly_1_0_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_mask_15_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_mask_14_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_mask_13_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_mask_12_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_mask_11_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_mask_10_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_mask_9_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_mask_8_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_mask_7_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_mask_6_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_mask_5_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_mask_4_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_mask_3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_mask_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_mask_1_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/mc_wrdata_mask_0_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_127_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_126_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_125_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_124_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_123_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_122_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_121_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_120_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_119_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_118_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_117_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_116_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_115_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_114_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_113_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_112_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_111_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_110_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_109_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_108_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_107_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_106_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_105_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_104_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_103_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_102_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_101_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_100_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_99_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_98_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_97_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_96_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_95_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_94_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_93_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_92_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_91_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_90_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_89_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_88_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_87_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_86_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_85_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_84_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_83_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_82_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_81_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_80_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_79_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_78_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_77_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_76_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_75_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_74_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_73_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_72_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_71_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_70_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_69_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_68_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_67_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_66_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_65_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_64_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_63_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_62_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_61_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_60_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_59_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_58_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_57_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_56_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_55_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_54_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_53_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_52_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_51_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_50_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_49_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_48_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_47_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_46_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_45_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_44_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_43_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_42_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_41_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_40_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_39_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_38_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_37_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_36_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_35_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_34_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_33_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_32_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_31_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_30_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_29_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_28_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_27_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_26_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_25_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_24_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_23_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_22_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_21_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_20_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_19_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_18_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_17_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_16_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_15_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_14_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_13_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_12_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_11_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_10_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_9_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_8_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_7_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_6_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_5_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_4_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_1_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rd_data_dly_0_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/phy_rddata_valid_dly_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/eye_calib_start_cmd_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_175_G[0]_s3 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_175_G[0]_s4 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_175_G[0]_s5 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_175_G[0]_s6 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_182_G[0]_s3 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_182_G[0]_s4 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_182_G[0]_s5 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_182_G[0]_s6 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_189_G[0]_s3 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_189_G[0]_s4 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_189_G[0]_s5 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_189_G[0]_s6 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n468_s24 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n468_s25 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n468_s26 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n468_s27 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n469_s24 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n469_s25 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n469_s26 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n469_s27 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n470_s24 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n470_s25 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n470_s26 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n470_s27 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n471_s24 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n471_s25 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n471_s26 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n471_s27 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n472_s24 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n472_s25 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n472_s26 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n472_s27 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n473_s24 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n473_s25 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n473_s26 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n473_s27 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n474_s24 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n474_s25 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n474_s26 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n474_s27 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n475_s24 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n475_s25 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n475_s26 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n475_s27 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n476_s24 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n476_s25 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n476_s26 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n476_s27 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n477_s24 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n477_s25 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n477_s26 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n477_s27 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n478_s24 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n478_s25 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n478_s26 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n478_s27 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n479_s24 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n479_s25 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n479_s26 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n479_s27 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n480_s24 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n480_s25 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n480_s26 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n480_s27 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n481_s24 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n481_s25 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n481_s26 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n481_s27 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n482_s24 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n482_s25 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n482_s26 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n482_s27 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_0_G[0]_s3 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_0_G[0]_s4 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_0_G[0]_s5 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_0_G[0]_s6 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_7_G[0]_s3 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_7_G[0]_s4 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_7_G[0]_s5 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_7_G[0]_s6 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_14_G[0]_s3 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_14_G[0]_s4 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_14_G[0]_s5 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_14_G[0]_s6 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_21_G[0]_s3 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_21_G[0]_s4 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_21_G[0]_s5 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_21_G[0]_s6 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_28_G[0]_s3 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_28_G[0]_s4 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_28_G[0]_s5 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_28_G[0]_s6 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_35_G[0]_s3 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_35_G[0]_s4 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_35_G[0]_s5 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_35_G[0]_s6 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_42_G[0]_s3 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_42_G[0]_s4 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_42_G[0]_s5 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_42_G[0]_s6 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_49_G[0]_s3 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_49_G[0]_s4 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_49_G[0]_s5 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_49_G[0]_s6 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_56_G[0]_s3 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_56_G[0]_s4 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_56_G[0]_s5 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_56_G[0]_s6 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_63_G[0]_s3 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_63_G[0]_s4 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_63_G[0]_s5 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_63_G[0]_s6 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_70_G[0]_s3 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_70_G[0]_s4 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_70_G[0]_s5 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_70_G[0]_s6 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_77_G[0]_s3 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_77_G[0]_s4 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_77_G[0]_s5 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_77_G[0]_s6 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_84_G[0]_s3 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_84_G[0]_s4 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_84_G[0]_s5 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_84_G[0]_s6 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_91_G[0]_s3 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_91_G[0]_s4 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_91_G[0]_s5 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_91_G[0]_s6 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_98_G[0]_s3 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_98_G[0]_s4 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_98_G[0]_s5 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_98_G[0]_s6 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_105_G[0]_s3 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_105_G[0]_s4 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_105_G[0]_s5 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_105_G[0]_s6 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_112_G[0]_s3 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_112_G[0]_s4 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_112_G[0]_s5 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_112_G[0]_s6 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_119_G[0]_s3 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_119_G[0]_s4 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_119_G[0]_s5 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_119_G[0]_s6 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_126_G[0]_s3 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_126_G[0]_s4 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_126_G[0]_s5 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_126_G[0]_s6 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_133_G[0]_s3 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_133_G[0]_s4 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_133_G[0]_s5 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_133_G[0]_s6 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_140_G[0]_s3 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_140_G[0]_s4 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_140_G[0]_s5 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_140_G[0]_s6 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_147_G[0]_s3 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_147_G[0]_s4 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_147_G[0]_s5 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_147_G[0]_s6 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_154_G[0]_s3 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_154_G[0]_s4 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_154_G[0]_s5 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_154_G[0]_s6 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_161_G[0]_s3 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_161_G[0]_s4 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_161_G[0]_s5 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_161_G[0]_s6 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_168_G[0]_s3 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_168_G[0]_s4 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_168_G[0]_s5 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_168_G[0]_s6 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_196_G[0]_s3 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_196_G[0]_s4 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_196_G[0]_s5 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_196_G[0]_s6 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_203_G[0]_s3 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_203_G[0]_s4 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_203_G[0]_s5 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_203_G[0]_s6 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_210_G[0]_s3 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_210_G[0]_s4 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_210_G[0]_s5 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_210_G[0]_s6 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_217_G[0]_s3 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_217_G[0]_s4 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_217_G[0]_s5 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_RAMOUT_217_G[0]_s6 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n41_s0 .INIT=16'h4100;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n183_s0 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n218_s0 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n253_s0 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n289_s0 .INIT=4'h8;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n324_s0 .INIT=4'h8;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n360_s0 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n396_s0 .INIT=4'h8;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n433_s0 .INIT=4'h8;
defparam \gw3_top/u_gwmc_top/gw_cmd0/write_s0 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_cmd0/read_s0 .INIT=4'h8;
defparam \gw3_top/u_gwmc_top/gw_cmd0/cmd_write_Z_s .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_cmd0/cmd_read_Z_s .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_cmd0/cmd_empty_s3 .INIT=8'h4F;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_s333 .INIT=8'h10;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_s334 .INIT=8'h10;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_s335 .INIT=8'h40;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_s336 .INIT=8'h40;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_s337 .INIT=8'h40;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_s338 .INIT=8'h40;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_s339 .INIT=8'h80;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_s340 .INIT=8'h80;
defparam \gw3_top/u_gwmc_top/gw_cmd0/next_waddr_1_s3 .INIT=4'h6;
defparam \gw3_top/u_gwmc_top/gw_cmd0/next_waddr_2_s2 .INIT=8'h78;
defparam \gw3_top/u_gwmc_top/gw_cmd0/next_raddr_1_s3 .INIT=4'h6;
defparam \gw3_top/u_gwmc_top/gw_cmd0/next_raddr_2_s2 .INIT=8'h78;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n34_s1 .INIT=16'h000E;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n75_s2 .INIT=8'hBF;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n41_s1 .INIT=16'hEB7D;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n183_s1 .INIT=16'h1000;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n218_s1 .INIT=16'h4000;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n253_s1 .INIT=16'h4000;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n360_s1 .INIT=16'h8000;
defparam \gw3_top/u_gwmc_top/gw_cmd0/write_s1 .INIT=16'h1000;
defparam \gw3_top/u_gwmc_top/gw_cmd0/cmd_empty_s4 .INIT=16'hBED7;
defparam \gw3_top/u_gwmc_top/gw_cmd0/cmd_empty_s5 .INIT=16'h4100;
defparam \gw3_top/u_gwmc_top/gw_cmd0/cmd_empty_s6 .INIT=8'hE0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_s343 .INIT=16'h2A00;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_s344 .INIT=16'h1500;
defparam \gw3_top/u_gwmc_top/gw_cmd0/next_waddr_0_s6 .INIT=16'h8F70;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n510_s1 .INIT=8'h70;
defparam \gw3_top/u_gwmc_top/gw_cmd0/next_raddr_0_s6 .INIT=16'hF10E;
defparam \gw3_top/u_gwmc_top/gw_cmd0/full_invalid_s4 .INIT=16'hAAFE;
defparam \gw3_top/u_gwmc_top/gw_cmd0/full_rr_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/full_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/bank_in_tmp_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/bank_in_tmp_1_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/bank_in_tmp_0_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0]_14_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0]_13_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0]_12_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0]_11_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0]_10_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0]_9_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0]_8_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0]_7_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0]_6_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0]_5_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0]_4_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0]_3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0]_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0]_1_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[0]_0_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1]_14_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1]_13_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1]_12_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1]_11_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1]_10_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1]_9_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1]_8_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1]_7_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1]_6_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1]_5_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1]_4_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1]_3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1]_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1]_1_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[1]_0_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2]_14_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2]_13_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2]_12_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2]_11_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2]_10_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2]_9_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2]_8_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2]_7_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2]_6_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2]_5_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2]_4_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2]_3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2]_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2]_1_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[2]_0_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3]_14_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3]_13_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3]_12_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3]_11_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3]_10_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3]_9_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3]_8_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3]_7_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3]_6_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3]_5_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3]_4_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3]_3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3]_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3]_1_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[3]_0_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4]_14_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4]_13_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4]_12_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4]_11_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4]_10_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4]_9_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4]_8_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4]_7_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4]_6_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4]_5_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4]_4_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4]_3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4]_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4]_1_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[4]_0_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5]_14_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5]_13_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5]_12_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5]_11_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5]_10_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5]_9_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5]_8_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5]_7_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5]_6_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5]_5_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5]_4_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5]_3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5]_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5]_1_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[5]_0_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6]_14_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6]_13_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6]_12_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6]_11_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6]_10_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6]_9_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6]_8_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6]_7_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6]_6_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6]_5_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6]_4_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6]_3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6]_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6]_1_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[6]_0_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7]_14_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7]_13_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7]_12_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7]_11_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7]_10_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7]_9_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7]_8_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7]_7_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7]_6_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7]_5_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7]_4_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7]_3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7]_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7]_1_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/row_in_tmp[7]_0_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/waddr_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/waddr_1_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/raddr_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/raddr_1_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/full_r_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/full_invalid_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/cmd_empty_s1 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[0]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[1]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[2]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[3]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[4]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[5]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[6]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[7]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[8]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[9]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[10]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[11]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[12]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[13]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[14]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[15]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[16]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[17]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[18]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[19]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[20]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[21]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[22]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[23]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[24]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[25]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[26]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[27]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[28]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[29]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[30]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_0_G[31]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[0]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[1]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[2]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[3]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[4]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[5]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[6]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[7]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[8]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[9]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[10]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[11]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[12]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[13]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[14]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[15]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[16]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[17]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[18]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[19]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[20]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[21]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[22]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[23]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[24]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[25]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[26]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[27]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[28]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[29]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[30]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_1_G[31]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[0]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[1]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[2]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[3]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[4]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[5]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[6]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[7]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[8]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[9]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[10]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[11]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[12]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[13]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[14]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[15]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[16]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[17]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[18]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[19]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[20]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[21]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[22]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[23]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[24]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[25]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[26]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[27]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[28]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[29]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[30]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_2_G[31]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[0]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[1]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[2]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[3]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[4]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[5]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[6]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[7]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[8]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[9]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[10]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[11]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[12]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[13]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[14]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[15]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[16]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[17]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[18]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[19]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[20]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[21]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[22]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[23]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[24]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[25]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[26]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[27]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[28]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[29]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[30]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_3_G[31]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[0]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[1]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[2]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[3]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[4]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[5]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[6]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[7]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[8]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[9]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[10]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[11]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[12]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[13]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[14]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[15]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[16]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[17]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[18]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[19]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[20]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[21]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[22]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[23]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[24]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[25]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[26]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[27]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[28]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[29]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[30]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_4_G[31]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[0]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[1]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[2]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[3]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[4]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[5]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[6]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[7]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[8]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[9]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[10]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[11]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[12]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[13]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[14]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[15]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[16]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[17]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[18]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[19]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[20]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[21]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[22]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[23]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[24]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[25]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[26]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[27]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[28]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[29]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[30]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_5_G[31]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[0]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[1]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[2]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[3]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[4]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[5]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[6]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[7]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[8]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[9]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[10]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[11]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[12]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[13]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[14]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[15]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[16]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[17]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[18]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[19]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[20]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[21]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[22]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[23]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[24]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[25]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[26]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[27]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[28]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[29]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[30]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_6_G[31]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[0]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[1]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[2]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[3]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[4]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[5]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[6]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[7]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[8]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[9]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[10]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[11]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[12]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[13]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[14]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[15]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[16]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[17]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[18]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[19]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[20]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[21]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[22]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[23]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[24]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[25]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[26]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[27]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[28]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[29]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[30]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/mem_mem_RAMREG_7_G[31]_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/waddr_0_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/raddr_0_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n29_s .ALU_MODE=1;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n28_s .ALU_MODE=1;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n27_s .ALU_MODE=1;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n17_s0 .ALU_MODE=3;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n18_s0 .ALU_MODE=3;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n19_s0 .ALU_MODE=3;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n464_s0 .ALU_MODE=3;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n465_s0 .ALU_MODE=3;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n466_s0 .ALU_MODE=3;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n483_s0 .ALU_MODE=3;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n484_s0 .ALU_MODE=3;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n485_s0 .ALU_MODE=3;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n486_s0 .ALU_MODE=3;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n487_s0 .ALU_MODE=3;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n488_s0 .ALU_MODE=3;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n489_s0 .ALU_MODE=3;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n490_s0 .ALU_MODE=3;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n491_s0 .ALU_MODE=3;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n492_s0 .ALU_MODE=3;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n493_s0 .ALU_MODE=3;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n494_s0 .ALU_MODE=3;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n495_s0 .ALU_MODE=3;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n496_s0 .ALU_MODE=3;
defparam \gw3_top/u_gwmc_top/gw_cmd0/n497_s0 .ALU_MODE=3;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n951_s24 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n951_s25 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n951_s26 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n951_s27 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n60_s0 .INIT=16'h8000;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n119_s0 .INIT=16'h8000;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n340_s1 .INIT=8'h40;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n345_s0 .INIT=4'h8;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_s0 .INIT=16'h4F44;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2076_s0 .INIT=4'h7;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2089_s0 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_satisfied_s3 .INIT=4'hE;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_7_s3 .INIT=16'h80FF;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_6_s3 .INIT=16'h40FF;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_5_s3 .INIT=16'h40FF;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_4_s3 .INIT=16'h10FF;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_3_s3 .INIT=16'h80FF;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_2_s3 .INIT=16'h40FF;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_1_s3 .INIT=16'h40FF;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_0_s3 .INIT=16'h10FF;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_s55 .INIT=16'h7FFF;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_s68 .INIT=8'h4F;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_s68 .INIT=16'h70FF;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_s68 .INIT=16'h07FF;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_s56 .INIT=8'h4F;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ZQ_s54 .INIT=16'hFF70;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SREI_s55 .INIT=16'hF8FF;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_WR_s65 .INIT=8'h4F;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_RD_s67 .INIT=8'h4F;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_W2R_s55 .INIT=16'h70FF;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2AW_s55 .INIT=16'h8F88;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2AR_s54 .INIT=16'h8F88;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_R2W_s55 .INIT=8'hF4;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_s55 .INIT=16'h8F88;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AR_s54 .INIT=8'hF4;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2WR_s54 .INIT=16'h007F;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2REF_s53 .INIT=16'hF444;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2SRE_s53 .INIT=16'hF444;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2RD_s54 .INIT=16'hF5C0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2REF_s53 .INIT=16'hF444;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2SRE_s53 .INIT=16'hF444;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SRE_s54 .INIT=8'hF4;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SREE_s51 .INIT=8'hF4;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_POWERON_s51 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1778_s2 .INIT=8'h90;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1777_s2 .INIT=16'hE100;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n317_s2 .INIT=16'h0B04;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n314_s2 .INIT=16'h0B04;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n313_s2 .INIT=16'h0708;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n138_s2 .INIT=8'h78;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n133_s2 .INIT=16'h0708;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n132_s2 .INIT=16'h0708;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n131_s2 .INIT=16'h0708;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n79_s2 .INIT=8'h78;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n75_s2 .INIT=16'h0708;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n73_s2 .INIT=16'h0708;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n72_s2 .INIT=16'h0708;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2024_s1 .INIT=4'h8;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2020_s1 .INIT=4'h8;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n35_s1 .INIT=8'h60;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n33_s1 .INIT=16'h7800;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n32_s1 .INIT=8'h60;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n30_s1 .INIT=16'h7800;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n29_s1 .INIT=16'h7800;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1687_s2 .INIT=4'h1;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1943_s2 .INIT=8'h9F;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1942_s2 .INIT=16'hE1FF;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1941_s2 .INIT=8'h6F;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1940_s2 .INIT=8'h6F;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1938_s2 .INIT=16'hB4FF;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1776_s1 .INIT=8'h6F;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n316_s1 .INIT=16'hF7F8;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n9_s2 .INIT=4'h8;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n9_s3 .INIT=4'h8;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n9_s4 .INIT=16'h0001;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n60_s1 .INIT=16'h1000;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n119_s2 .INIT=4'h1;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n119_s3 .INIT=16'h1000;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/cmd_accept_ref_Z_s0 .INIT=8'h01;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/cmd_accept_sre_Z_s0 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_one_bank_s1 .INIT=4'h1;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_one_bank_s2 .INIT=4'h8;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_s1 .INIT=16'h0001;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_s3 .INIT=16'h0001;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2076_s1 .INIT=16'h0777;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2076_s2 .INIT=16'h0777;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_7_s4 .INIT=4'h8;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_7_s4 .INIT=4'h8;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_3_s4 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRP_cnt_1_s4 .INIT=4'h8;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_4_s4 .INIT=16'h0001;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_4_s5 .INIT=16'h0700;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRCD_cnt_1_s4 .INIT=4'h1;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTW_cnt_1_s4 .INIT=4'h1;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTR_cnt_2_s4 .INIT=8'h01;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRAS_cnt_2_s4 .INIT=8'h01;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTP_cnt_1_s4 .INIT=4'h1;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTP_cnt_2_s4 .INIT=8'h01;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_s57 .INIT=16'h0001;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_s58 .INIT=8'h01;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_s59 .INIT=16'h0100;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_s69 .INIT=16'h4000;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_s70 .INIT=16'hBF00;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_s70 .INIT=16'h0B00;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_s71 .INIT=16'h0007;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_s69 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_s70 .INIT=16'h0100;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_s71 .INIT=16'h000E;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_s72 .INIT=16'h0007;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_s60 .INIT=16'h4000;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SREI_s56 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SREI_s57 .INIT=16'h7F00;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_WR_s66 .INIT=16'h0700;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_RD_s68 .INIT=16'h0700;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_W2R_s56 .INIT=8'h10;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_W2R_s57 .INIT=8'h07;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2AW_s56 .INIT=4'h8;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2AW_s57 .INIT=16'h4000;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_R2W_s56 .INIT=8'h40;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_s57 .INIT=16'hF800;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_s58 .INIT=16'h4000;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AR_s55 .INIT=8'h80;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2WR_s55 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2WR_s57 .INIT=16'h00F8;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2RD_s55 .INIT=16'h8000;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1908_s12 .INIT=16'hBFFD;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n318_s3 .INIT=4'h1;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n313_s3 .INIT=4'h1;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n137_s3 .INIT=8'h80;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n135_s3 .INIT=4'h8;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n132_s3 .INIT=4'h8;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n78_s3 .INIT=8'h80;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n76_s3 .INIT=4'h8;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n72_s3 .INIT=4'h8;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n36_s3 .INIT=8'h10;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n31_s2 .INIT=4'h8;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1941_s3 .INIT=8'h01;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1940_s3 .INIT=16'h0001;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1939_s3 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1776_s2 .INIT=8'h01;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n316_s2 .INIT=4'h1;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_one_bank_s3 .INIT=16'h0001;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_7_s5 .INIT=8'h01;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_s62 .INIT=16'h0001;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_s71 .INIT=16'hC500;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_s72 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_s73 .INIT=16'h0100;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_s74 .INIT=16'h0777;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_s72 .INIT=16'hA300;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_s73 .INIT=16'h00F8;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_s74 .INIT=16'hB080;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_s75 .INIT=16'hFCA0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_s75 .INIT=16'h00F8;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_s76 .INIT=16'hC500;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_s77 .INIT=8'hE0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_s63 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_s64 .INIT=16'h00BF;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SREI_s58 .INIT=16'h0700;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_WR_s67 .INIT=16'h1000;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_WR_s68 .INIT=16'h0D00;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_WR_s69 .INIT=16'h0777;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_RD_s69 .INIT=16'h7000;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_RD_s70 .INIT=16'h0777;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_W2R_s60 .INIT=16'hFE00;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_s59 .INIT=4'h1;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_s60 .INIT=16'h7F00;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_s75 .INIT=4'h1;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_s78 .INIT=8'hE0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_s79 .INIT=8'h0E;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_s80 .INIT=4'h1;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_WR_s70 .INIT=16'h0B33;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT_RD_s71 .INIT=16'hF3A0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_s62 .INIT=4'h1;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_s63 .INIT=16'h1F00;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n119_s4 .INIT=8'h80;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n136_s4 .INIT=16'h8000;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1939_s4 .INIT=16'h9AFF;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n340_s4 .INIT=16'h0004;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n340_s5 .INIT=8'h01;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n60_s3 .INIT=16'h1000;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n77_s4 .INIT=16'h8000;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n9_s5 .INIT=16'h8000;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_7_s6 .INIT=16'h0002;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_s66 .INIT=16'h0355;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_s77 .INIT=8'h02;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WRITE_s77 .INIT=16'h000D;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_SREI_s60 .INIT=8'h10;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_REF_s67 .INIT=16'hEF00;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2WR_s59 .INIT=16'h0400;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_W2R_s61 .INIT=8'h02;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n74_s4 .INIT=16'h8000;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n76_s4 .INIT=16'h1444;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_s5 .INIT=8'h02;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2059_s6 .INIT=16'h0002;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/cmd_accept_sre_Z_s1 .INIT=16'hFE00;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/cmd_accept_ref_Z_s1 .INIT=16'hFE00;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n315_s4 .INIT=8'h02;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n318_s4 .INIT=16'h4441;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n32_s3 .INIT=16'h8000;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n34_s2 .INIT=16'h6A00;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_W2R_s62 .INIT=16'h0400;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_WP2AR_s56 .INIT=8'h10;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_s81 .INIT=16'hEEE0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_RP2AW_s64 .INIT=8'h20;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_IDLE_s82 .INIT=16'h0DDD;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ACT2WR_s60 .INIT=16'h007F;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n2084_s1 .INIT=8'h80;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1757_s1 .INIT=8'h80;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_ZQ_s56 .INIT=16'h2000;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_nstate.GWMCST_READ_s78 .INIT=16'h0E00;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n36_s4 .INIT=16'h0100;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_one_bank_s5 .INIT=16'hE000;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1847_s2 .INIT=16'hFFF9;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1848_s2 .INIT=8'hFD;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n315_s5 .INIT=16'h0770;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n319_s3 .INIT=16'h7007;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/cmd_accept_Z_s1 .INIT=8'h0E;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n291_s3 .INIT=16'h333A;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n218_s1 .INIT=4'hE;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n74_s6 .INIT=16'h0708;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt_9_s4 .INIT=4'hE;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n77_s6 .INIT=16'h1FE0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n78_s5 .INIT=16'h0708;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n80_s4 .INIT=16'h1FE0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n81_s4 .INIT=8'h14;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n134_s5 .INIT=16'h0708;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt_9_s4 .INIT=4'hE;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n135_s5 .INIT=16'h0708;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n136_s6 .INIT=16'h1FE0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n137_s5 .INIT=16'h0708;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n139_s4 .INIT=16'h1FE0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n140_s4 .INIT=8'h14;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n295_s2 .INIT=16'h8F88;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n320_s6 .INIT=16'h0770;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_7_s6 .INIT=8'hF8;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1749_s5 .INIT=16'h8000;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1750_s4 .INIT=16'h4FFF;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1775_s3 .INIT=8'h4F;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_4_s7 .INIT=8'hBF;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1779_s3 .INIT=16'h4BFF;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1803_s5 .INIT=16'h1000;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1804_s4 .INIT=16'hFFF4;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1815_s4 .INIT=8'h40;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1816_s3 .INIT=8'hF4;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1828_s4 .INIT=16'h0E00;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1829_s3 .INIT=16'hFCCE;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1830_s3 .INIT=16'hFF0E;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1846_s4 .INIT=16'hE000;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRAS_cnt_2_s7 .INIT=16'hFEFF;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1861_s4 .INIT=8'h40;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1862_s3 .INIT=8'hF4;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1874_s3 .INIT=16'hFFE0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1875_s4 .INIT=16'h3002;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1876_s4 .INIT=16'h000E;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1937_s3 .INIT=8'h40;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_7_s8 .INIT=8'hBF;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1944_s4 .INIT=16'h4BFF;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1908_s14 .INIT=16'hC1B4;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1909_s10 .INIT=16'hB4D2;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n1910_s12 .INIT=8'h96;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n134_s7 .INIT=8'h80;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/n31_s3 .INIT=16'h6A00;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt_6_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt_5_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt_4_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt_3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt_1_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt_0_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_satisfied_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_satisfied_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/init_done_r_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_cmd_read_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_cmd_write_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_bank_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_bank_1_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_bank_0_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row_14_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row_13_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row_12_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row_11_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row_10_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row_9_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row_8_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row_7_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row_6_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row_5_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row_4_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row_3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row_1_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_row_0_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col_9_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col_8_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col_7_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col_6_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col_5_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col_4_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col_3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col_1_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_col_0_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_satisfied_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_zqcs_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/idle1_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/idle2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/idle3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_shift_reg_4_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_shift_reg_3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_shift_reg_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_shift_reg_1_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/act_shift_reg_0_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_wr_int_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_rd_int_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_pre_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_all_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_ref_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_sre_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/cke_set_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_bank_tmp_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_bank_tmp_1_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_bank_tmp_0_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_row_tmp_14_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_row_tmp_13_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_row_tmp_12_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_row_tmp_11_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_row_tmp_10_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_row_tmp_9_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_row_tmp_8_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_row_tmp_7_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_row_tmp_6_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_row_tmp_5_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_row_tmp_4_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_row_tmp_3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_row_tmp_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_row_tmp_1_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_row_tmp_0_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_col_tmp_9_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_col_tmp_8_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_col_tmp_7_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_col_tmp_6_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_col_tmp_5_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_col_tmp_4_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_col_tmp_3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_col_tmp_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_col_tmp_1_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/send_col_tmp_0_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/us_cnt_7_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt_9_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt_8_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt_6_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt_5_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt_2_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt_9_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt_8_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt_7_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt_2_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_satisfied_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_7_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_6_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_5_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_4_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_3_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_2_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_1_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_7_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_6_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_5_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_4_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_3_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_2_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_1_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/bank_acted_0_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_3_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_2_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_1_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRAS_cnt_1_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRAS_cnt_0_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_6_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_5_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_4_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_3_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_2_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_1_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_REF_s2 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_WRITE_s2 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_READ_s4 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ZQ_s14 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_IDLE_s4 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_SREI_s2 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT_WR_s2 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT_RD_s2 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_W2R_s6 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_WP2AW_s12 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_WP2AR_s6 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_R2W_s4 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_RP2AW_s10 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_RP2AR_s4 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT2WR_s10 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_WP2REF_s18 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_WP2SRE_s18 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_ACT2RD_s4 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_RP2REF_s18 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_RP2SRE_s18 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_SRE_s2 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_SREE_s18 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/gwmc_pstate.GWMCST_POWERON_s18 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_info_valid_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt_7_s3 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt_4_s3 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt_3_s3 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt_1_s3 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/ms_cnt_0_s3 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt_6_s3 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt_5_s3 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt_4_s3 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt_3_s3 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt_1_s3 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/s_cnt_0_s3 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/pre_st_ref_s5 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tZQCS_cnt_0_s3 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRP_cnt_1_s6 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRP_cnt_0_s3 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_4_s6 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRFC_cnt_0_s3 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRCD_cnt_1_s7 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRCD_cnt_0_s3 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTW_cnt_1_s6 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTW_cnt_0_s3 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTR_cnt_2_s6 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTR_cnt_1_s3 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTR_cnt_0_s3 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRAS_cnt_2_s6 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTP_cnt_1_s6 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tRTP_cnt_0_s3 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTP_cnt_2_s6 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTP_cnt_1_s3 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tWTP_cnt_0_s3 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_7_s7 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tXSDLL_cnt_0_s3 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tFAW_cnt_2_s2 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tFAW_cnt_1_s2 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_bank_ctrl/tFAW_cnt_0_s2 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n34_s0 .INIT=16'h4000;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/sre_accepted_s3 .INIT=4'hB;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n68_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n46_s2 .INIT=8'h41;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n44_s2 .INIT=8'h14;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n43_s2 .INIT=8'h2C;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n17_s2 .INIT=16'h0DF0;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n14_s2 .INIT=16'hEF00;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n45_s1 .INIT=8'hE1;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n42_s1 .INIT=8'hB4;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n18_s1 .INIT=4'h9;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n15_s1 .INIT=8'hB4;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n34_s2 .INIT=4'h1;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n73_s1 .INIT=8'h10;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n44_s3 .INIT=8'h01;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n17_s3 .INIT=4'h1;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n34_s3 .INIT=8'h01;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n43_s4 .INIT=16'h0001;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_request_s4 .INIT=16'hFF10;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n16_s3 .INIT=16'h0EF0;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n73_s2 .INIT=16'h0200;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/rank_cnt_0_s4 .INIT=16'hFFFD;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n94_s2 .INIT=16'hFA30;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt_5_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt_4_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt_3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt_1_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/prescaler_cnt_0_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer_5_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer_4_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer_3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer_1_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_timer_0_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/ref_accepted_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/sre_accept_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/init_complete_r_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/rank_cnt_0_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/refresh_request_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/sre_accepted_s1 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/sre_request_s4 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n47_s2 .INIT=2'h1;
defparam \gw3_top/u_gwmc_top/gwmc_timing_ctrl/n19_s2 .INIT=2'h1;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n458_s0 .INIT=8'hAC;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n459_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n460_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n461_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n462_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n463_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n464_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n465_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n466_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n467_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n468_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n469_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n470_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n471_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n472_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n473_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n491_s0 .INIT=8'hAC;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n492_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n494_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n495_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n496_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n498_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n499_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n500_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n501_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n503_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n504_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n505_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n524_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n525_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n526_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n527_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n528_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n529_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n530_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n531_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n532_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n533_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n534_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n535_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n536_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n537_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n538_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n539_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n557_s0 .INIT=8'hAC;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n558_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n560_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n561_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n564_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n565_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n567_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n569_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n571_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n572_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n590_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n591_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n592_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n593_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n594_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n595_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n596_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n597_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n598_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n599_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n600_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n601_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n602_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n603_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n604_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n605_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n623_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n624_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n626_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n627_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n628_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n630_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n631_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n632_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n633_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n635_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n636_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n637_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n656_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n657_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n658_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n659_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n660_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n661_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n662_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n663_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n664_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n665_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n666_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n667_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n668_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n669_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n670_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n671_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n689_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n690_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n692_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n693_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n696_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n697_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n699_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n701_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n703_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n704_s0 .INIT=8'hCA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n756_s0 .INIT=16'hF088;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n722_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n723_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n724_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n725_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n726_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n727_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n728_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n729_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n730_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n731_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n732_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n733_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n734_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n735_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n736_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n737_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n691_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n559_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n694_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n562_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n695_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n563_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n698_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n566_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n700_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n568_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n702_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n570_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n625_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n493_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n629_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n497_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n634_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n502_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n638_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n506_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq_7_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq_6_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq_5_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq_4_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq_3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq_1_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq_0_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_wen_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_15_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_14_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_13_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_12_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_11_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_10_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_9_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_8_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_7_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_6_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_5_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_4_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_1_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_0_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_31_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_30_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_29_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_28_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_27_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_26_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_25_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_24_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_23_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_22_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_21_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_20_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_19_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_18_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_17_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_16_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_47_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_46_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_45_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_44_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_43_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_42_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_41_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_40_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_39_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_38_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_37_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_36_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_35_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_34_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_33_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_32_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_63_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_62_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_61_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_60_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_59_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_58_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_57_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_56_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_55_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_54_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_53_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_52_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_51_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_50_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_49_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_48_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_79_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_78_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_77_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_76_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_75_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_74_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_73_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_72_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_71_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_70_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_69_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_68_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_67_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_66_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_65_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_64_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_95_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_94_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_93_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_92_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_91_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_90_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_89_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_88_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_87_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_86_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_85_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_84_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_83_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_82_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_81_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_80_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_111_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_110_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_109_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_108_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_107_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_106_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_105_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_104_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_103_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_102_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_101_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_100_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_99_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_98_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_97_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_96_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_127_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_126_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_125_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_124_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_123_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_122_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_121_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_120_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_119_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_118_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_117_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_116_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_115_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_114_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_113_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_112_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_143_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_142_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_141_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_140_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_139_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_138_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_137_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_136_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_135_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_134_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_133_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_132_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_131_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_130_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_129_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_din_128_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_wrbuf_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_full_r_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_buf_rdy_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/eye_calib_start_dq_8_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/n760_s2 .INIT=2'h1;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n28_s0 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n24_s1 .INIT=16'h0700;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wfull_val_s0 .INIT=8'h20;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/awfull_val_s15 .INIT=16'hFF80;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next_2_s3 .INIT=8'h78;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next_4_s2 .INIT=8'h78;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next_0_s3 .INIT=4'h6;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next_1_s3 .INIT=8'h78;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next_2_s3 .INIT=16'h7F80;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next_3_s3 .INIT=4'h6;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next_4_s2 .INIT=8'h78;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_f_0_s4 .INIT=8'h40;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wfull_val_s1 .INIT=16'hD7BD;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wfull_val_s2 .INIT=16'h9009;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next_3_s4 .INIT=8'h80;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_next_3_s4 .INIT=16'h8000;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wfull_val_s3 .INIT=4'h9;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next_3_s5 .INIT=16'h6AAA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n641_s3 .INIT=16'h8778;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next_1_s4 .INIT=16'h9AAA;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_next_0_s4 .INIT=8'h9A;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_f_0_s5 .INIT=16'hFFB0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_f_1_s4 .INIT=16'hCACC;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_f_2_s4 .INIT=16'hCACC;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_f_3_s4 .INIT=16'hCACC;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rempty_val_s1 .INIT=8'h41;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_dly_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_dly_1_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_dly_0_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_4_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_1_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/rbin_0_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_4_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_1_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wbin_0_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/Full_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/Almost_Full_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/raddr_dly_3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/Empty_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/mem_mem_0_0_s .READ_MODE=1'b1;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/mem_mem_0_0_s .BIT_WIDTH_0=36;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/mem_mem_0_0_s .BIT_WIDTH_1=36;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/mem_mem_0_0_s .RESET_MODE="ASYNC";
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/mem_mem_0_0_s .BLK_SEL_0=3'b000;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/mem_mem_0_0_s .BLK_SEL_1=3'b000;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/mem_mem_0_1_s .READ_MODE=1'b1;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/mem_mem_0_1_s .BIT_WIDTH_0=36;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/mem_mem_0_1_s .BIT_WIDTH_1=36;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/mem_mem_0_1_s .RESET_MODE="ASYNC";
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/mem_mem_0_1_s .BLK_SEL_0=3'b000;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/mem_mem_0_1_s .BLK_SEL_1=3'b000;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/mem_mem_0_2_s .READ_MODE=1'b1;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/mem_mem_0_2_s .BIT_WIDTH_0=36;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/mem_mem_0_2_s .BIT_WIDTH_1=36;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/mem_mem_0_2_s .RESET_MODE="ASYNC";
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/mem_mem_0_2_s .BLK_SEL_0=3'b000;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/mem_mem_0_2_s .BLK_SEL_1=3'b000;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/mem_mem_0_3_s .READ_MODE=1'b1;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/mem_mem_0_3_s .BIT_WIDTH_0=36;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/mem_mem_0_3_s .BIT_WIDTH_1=36;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/mem_mem_0_3_s .RESET_MODE="ASYNC";
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/mem_mem_0_3_s .BLK_SEL_0=3'b000;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/mem_mem_0_3_s .BLK_SEL_1=3'b000;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wcnt_sub_0_s .ALU_MODE=1;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wcnt_sub_1_s .ALU_MODE=1;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wcnt_sub_2_s .ALU_MODE=1;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wcnt_sub_3_s .ALU_MODE=1;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/wcnt_sub_4_s .ALU_MODE=1;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n652_s0 .ALU_MODE=3;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n653_s0 .ALU_MODE=3;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n654_s0 .ALU_MODE=3;
defparam \gw3_top/u_gwmc_top/gw_wr_data0/wr_fifo/n655_s0 .ALU_MODE=3;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/mc_cs_n_out_2_s .INIT=4'hB;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/mc_cs_n_out_3_s .INIT=4'hB;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/mc_odt_out_0_s .INIT=16'hFFF8;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n297_s2 .INIT=4'h1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n209_s2 .INIT=4'h4;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n213_s2 .INIT=8'hB0;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n214_s2 .INIT=8'hB0;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n215_s2 .INIT=8'hB0;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n216_s2 .INIT=8'hB0;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n218_s2 .INIT=8'hB0;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n219_s2 .INIT=8'hB0;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n220_s2 .INIT=8'hB0;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n221_s2 .INIT=8'hB0;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n222_s2 .INIT=8'hB0;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n223_s2 .INIT=8'hB0;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n224_s2 .INIT=8'hB0;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n225_s2 .INIT=8'hB0;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n226_s2 .INIT=8'hB0;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n227_s2 .INIT=8'hB0;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n229_s3 .INIT=4'h1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n230_s2 .INIT=16'h0BFF;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n217_s3 .INIT=16'hF0BB;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n210_s4 .INIT=8'h01;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n228_s3 .INIT=16'hFF10;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n278_s3 .INIT=8'hAB;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n279_s3 .INIT=8'hAB;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n280_s3 .INIT=8'hAB;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n286_s3 .INIT=8'hAB;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n287_s3 .INIT=8'hAB;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n288_s3 .INIT=8'hAB;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n289_s3 .INIT=8'hAB;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n290_s3 .INIT=8'hAB;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n291_s3 .INIT=8'hAB;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n292_s3 .INIT=8'hAB;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n293_s3 .INIT=8'hAB;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n294_s3 .INIT=8'hAB;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n295_s3 .INIT=8'hAB;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/sent_col_s1 .INIT=4'hE;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n411_s4 .INIT=8'h0E;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n217_s4 .INIT=16'h0100;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n209_s4 .INIT=16'h0001;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n212_s3 .INIT=16'h8F88;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n211_s3 .INIT=16'h8F88;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n210_s5 .INIT=16'h8F88;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/sent_row_s1 .INIT=4'hB;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_20_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_19_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_18_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_17_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_16_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_15_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_14_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_13_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_12_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_11_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_10_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_9_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_8_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_7_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_6_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_5_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_4_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_3_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_2_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_1_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_0_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd3_21_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd3_20_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd3_19_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd3_18_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd3_12_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd3_11_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd3_10_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd3_9_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd3_8_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd3_7_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd3_6_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd3_5_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd3_4_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd3_3_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd3_0_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cs_en2_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cs_en3_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/col_cmd_we_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/auxgen.mc_aux_out_r_0_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/auxgen.mc_aux_out_r_1_0_s0 .INIT=1'b0;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cmd2_21_s0 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/cke_s4 .INIT=1'b1;
defparam \gw3_top/u_gwmc_top/gwmc_rank_ctrl/n298_s3 .INIT=2'h1;
endmodule
