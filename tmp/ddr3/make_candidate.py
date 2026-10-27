from pathlib import Path
s=Path('ddr3_test/src/ddr3_bist.v').read_text()
s=s.replace('reg command_sent, data_sent;', 'reg command_sent, data_sent;\n    reg [1:0] write_gap;')
s=s.replace('state==WRITE && !command_sent;', 'state==WRITE && !command_sent && cmd_ready && wr_data_rdy && write_gap==0;')
s=s.replace('state==WRITE && !data_sent;', 'state==WRITE && !data_sent && cmd_ready && wr_data_rdy && write_gap==0;')
s=s.replace('command_sent<=0; data_sent<=0; watchdog<=0;', 'command_sent<=0; data_sent<=0; watchdog<=0; write_gap<=0;')
s=s.replace('if(!active || progress) watchdog<=0;', 'if(write_gap!=0) write_gap<=write_gap-1\'b1;\n            if(!active || progress) watchdog<=0;')
s=s.replace('command_sent<=0; data_sent<=0;\n                        if(index', 'command_sent<=0; data_sent<=0; write_gap<=2;\n                        if(index')
Path('tmp/ddr3/ddr3_bist_candidate.v').write_text(s)
