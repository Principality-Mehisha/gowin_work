from pathlib import Path
p=Path('tmp/ddr3/tb_native_mc.sv');s=p.read_text().replace('TEST_BURSTS(1024)','TEST_BURSTS(65536)').replace('commands!=1024 || beats!=1024 || writes!=1024','commands!=65536 || beats!=65536 || writes!=65536').replace('#300000;', '#5000000;');Path('tmp/ddr3/tb_native_large.sv').write_text(s.replace('tb_native_mc','tb_native_large'))
