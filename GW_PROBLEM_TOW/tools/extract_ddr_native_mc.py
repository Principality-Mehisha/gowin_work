"""Wrap the public, generated simulation netlist's MC for a PHY-free regression.

No protected source is decoded. The netlist is produced by Gowin EDA and the
simulation uses its supplied primitive library. Never add this wrapper to GPRJ.
"""
from pathlib import Path
import re
import sys

root = Path(__file__).resolve().parents[1]
source = root / 'src/ddr/ip/memory/ddr3_memory_interface.vo'
destination = Path(sys.argv[1]) if len(sys.argv) > 1 else root / 'output/ddr_migration/native_mc_probe.v'
text = source.read_text(encoding='utf-8-sig')
instance_pattern = r'^([A-Za-z][A-Za-z0-9_]*)\s+(\\\S+|\w+)\s*\(\s*\n(.*?)^\);'
instances = [m for m in re.finditer(instance_pattern, text, re.M | re.S)
             if m[2].startswith('\\gw3_top/u_gwmc_top/')]
assert instances, 'No MC found in generated Gowin simulation netlist'
declared = set(re.findall(r'^wire\s+(?:\[[^]]+\]\s+)?(\S+)\s*;', text, re.M))
used, driven = set(), set()
for instance in instances:
    for pin, expression in re.findall(r'\.(\w+)\((.*?)\)', instance[3]):
        names = set(re.findall(r'\\\S+|\b\w+\b', expression)) & declared
        used |= names
        if pin in {'F', 'Q', 'O', 'DO', 'SUM', 'COUT', 'CO'}:
            driven |= names
known_inputs = {
    'clk_out', 'ddr_rst', 'VCC', 'GND', 'addr', 'cmd', 'cmd_en',
    'wr_data', 'wr_data_en', 'wr_data_end', 'wr_data_mask',
    'sr_req', 'ref_req', 'burst',
    '\\gw3_top/ddr_init_internal', '\\gw3_top/eye_app_addr_Z',
    '\\gw3_top/eye_app_cmd_Z', '\\gw3_top/eye_app_cmd_en_Z',
    '\\gw3_top/eye_app_wdf_wdata_Z', '\\gw3_top/eye_app_wdf_wren_Z',
    '\\gw3_top/eye_calib_rdata', '\\gw3_top/eye_calib_start_Z',
    '\\gw3_top/phy_rd_data_valid',
}
assert not (used - driven - known_inputs), f'Unmodelled MC inputs: {used - driven - known_inputs}'
ports = {'clk', 'reset', 'cmd', 'cmd_en', 'addr', 'wr_data', 'wr_data_en',
         'wr_data_end', 'wr_data_mask', 'cmd_ready', 'wr_data_rdy', 'send_wr'}
declarations = []
for line in text.splitlines():
    if line.startswith('wire '):
        name = re.match(r'wire\s+(?:\[[^]]+\]\s+)?(\S+)\s*;', line)[1]
        if name not in ports:
            declarations.append(line)
selected_names = {m[2] for m in instances}
parameters = [line for line in text.splitlines()
              if line.startswith('defparam ') and line.split()[1] in selected_names]
header = '''// MC instances copied unchanged from the Gowin-generated simulation netlist.
// Copyright (C)2014-2026 Gowin Semiconductor Corporation. All rights reserved.
`timescale 1ns/1ps
module native_mc_probe(input clk,reset,input [2:0] cmd,input cmd_en,
input [28:0] addr,input [127:0] wr_data,input wr_data_en,wr_data_end,
input [15:0] wr_data_mask,output cmd_ready,wr_data_rdy,send_wr);
'''
environment = r'''
assign clk_out=clk;
assign ddr_rst=reset;
assign VCC=1'b1;
assign GND=1'b0;
assign sr_req=1'b0;
assign ref_req=1'b0;
assign burst=1'b1;
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
'''
destination.parent.mkdir(parents=True, exist_ok=True)
destination.write_text(header + '\n'.join(declarations) + '\n' + environment +
                       '\n'.join(m[0] for m in instances) + '\n' +
                       '\n'.join(parameters) + '\nendmodule\n', encoding='utf-8')
print(f'Extracted {len(instances)} unchanged MC instances; all boundary inputs modelled.')
