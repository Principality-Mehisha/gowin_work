from pathlib import Path
import re,collections
p=Path('ddr3_test/src/ip/ddr3/ddr3_memory_interface/ddr3_memory_interface.vo')
s=p.read_text()
pat=r'^([A-Za-z][A-Za-z0-9_]*)\s+(\\\S+|\w+)\s*\(\s*\n(.*?)^\);'
inst=[m for m in re.finditer(pat,s,re.M|re.S) if m[2].startswith('\\gw3_top/u_gwmc_top/')]
outports={'F','Q','O','DO','SUM','COUT','CO'}
driven=set(); used=set()
def names(expr):
    declared=set(re.findall(r'^wire\s+(?:\[[^]]+\]\s+)?(\S+)\s*;',s,re.M))
    return set(re.findall(r'\\\S+|\b\w+\b',expr)) & declared

for m in inst:
    for pin,expr in re.findall(r'\.(\w+)\((.*?)\)',m[3]):
        ns=names(expr)
        used|=ns
        if pin in outports: driven|=ns
print('instances',len(inst),'types',collections.Counter(m[1] for m in inst))
print('external inputs:')
print('\n'.join(sorted(used-driven)))
wire_decls='\n'.join(line for line in s.splitlines() if line.startswith('wire '))
selected_names={m[2] for m in inst}
params='\n'.join(line for line in s.splitlines() if line.startswith('defparam ') and line.split()[1].split('.INIT=')[0].split(' .')[0] in selected_names)
# Each defparam uses an escaped identifier terminated by whitespace.
params='\n'.join(line for line in s.splitlines() if line.startswith('defparam ') and line.split()[1] in selected_names)
body='\n'.join(m[0] for m in inst)
header='''`timescale 1ns/1ps
module native_mc_probe(input clk,reset,input [2:0] cmd,input cmd_en,
input [28:0] addr,input [127:0] wr_data,input wr_data_en,wr_data_end,
input [15:0] wr_data_mask, output cmd_ready,wr_data_rdy,send_wr);
'''
assigns=r'''
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
'''
Path('tmp/ddr3/native_mc_probe.v').write_text(header+wire_decls+'\n'+assigns+'\n'+body+'\n'+params+'\nendmodule\n')
