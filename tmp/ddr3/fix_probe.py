from pathlib import Path
import re
p=Path('tmp/ddr3/native_mc_probe.v'); s=p.read_text(); ports={'clk','reset','cmd','cmd_en','addr','wr_data','wr_data_en','wr_data_end','wr_data_mask','cmd_ready','wr_data_rdy','send_wr'}
s='\n'.join(l for l in s.splitlines() if not (re.match(r'wire\s+(?:\[[^]]+\]\s+)?(\w+)\s*;',l) and re.match(r'wire\s+(?:\[[^]]+\]\s+)?(\w+)\s*;',l)[1] in ports))+'\n'; p.write_text(s)
