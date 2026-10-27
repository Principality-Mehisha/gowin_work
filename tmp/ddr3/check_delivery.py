import hashlib, html, re, pathlib, xml.etree.ElementTree as ET
root=pathlib.Path('ddr3_test')
project=ET.parse(root/'ddr3_test.gprj')
for el in project.findall('.//File'):
    p=root/el.attrib['path']
    assert p.is_file(), p
ports={}
cst=(root/'src/ddr3_test.cst').read_text()
for net,balls in re.findall(r'IO_LOC\s+"([^"]+)"\s+([^;]+);',cst):
    for ball in balls.strip().split(','):
        assert ball not in ports, (ball,net,ports.get(ball))
        ports[ball]=net
assert len(ports)==53,len(ports)
assert ports['U12']=='led_run' and ports['G11']=='led_result'
assert ports['F4']=='reset_button' and ports['V22']=='sys_clk'
assert 'ddr_addr[15]' not in cst
source='\n'.join(p.read_text() for p in (root/'src').glob('*.v') if p.name not in ('pll_init.v','pll_mDRP_intf.v'))
assert not re.search(r'\buart',source,re.I)
params=(root/'src/ip/ddr3/ddr3_memory_interface/temp/DDR3/gwmc_param.v').read_text()
for name,value in {'DQ_WIDTH':'16','DRAM_WIDTH':'16','ROW_WIDTH':'15','COL_WIDTH':'10','BANK_WIDTH':'3','nCK_PER_CLK':'4','tCK':'2500','CL':'6','CWL':'5'}.items():
    assert re.search(r'parameter\s+'+name+r'\s*=\s*'+value+r'\s*;',params),name
for bench in ('tb_ddr3_bist','tb_ddr3_status'):
    text=(root/f'sim/{bench}.log').read_text()
    assert 'ALL '+('BIST' if bench.endswith('bist') else 'STATUS')+' TESTS PASSED' in text
    assert 'Errors: 0' in text
report=html.unescape(re.sub('<[^>]+>',' ',(root/'impl/pnr/ddr3_test_tr_content.html').read_text()))
report=re.sub(r'\s+',' ',report)
for kind in ('Setup','Hold'):
    assert re.search('Numbers of '+kind+' Violated Endpoints 0',report)
bit=root/'impl/pnr/ddr3_test.fs'
assert bit.is_file() and bit.stat().st_size>100000
print('PASS: project sources, 53 unique constrained pins, x16 geometry, no UART, simulations, setup/hold')
print('fs:',bit.stat().st_size,'bytes; sha256:',hashlib.sha256(bit.read_bytes()).hexdigest())
print(report[report.index('Max Frequency Summary:'):report.index('Total Negative Slack Summary:')])
