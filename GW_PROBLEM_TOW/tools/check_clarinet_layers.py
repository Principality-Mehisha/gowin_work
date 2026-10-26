"""Exact independent checks of every measured profile and blend boundary."""
from pathlib import Path
import json,sys
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'output/marimba_tools'))
import numpy as np
from clarinet_reference import ClarinetReference

def main():
    out=ROOT/'output/clarinet_calibration';rows=np.loadtxt(out/'layer_pcm.txt',dtype=np.int64)
    cases=[(m,v) for v in (64,160,240) for m in range(50,95)]
    cases += [(69,v) for v in (1,63,64,65,127,128,159,160,161,180,191,192,223,239,240,241,254,255)]
    assert rows.shape==(len(cases)*512,3)
    for i,(pitch,velocity) in enumerate(cases):
        chunk=rows[i*512:(i+1)*512]
        assert np.all(chunk[:,0]==pitch) and np.all(chunk[:,1]==velocity)
        model=ClarinetReference();model.event(True,pitch,velocity)
        for frame in range(512):
            if frame==256:model.event(False,pitch,velocity)
            expected=model.frame()
            assert chunk[frame,2]==expected,(pitch,velocity,frame,int(chunk[frame,2]),expected)
    result=dict(profiles=135,interpolation_boundary_cases=18,exact_samples=len(rows),passed=True)
    (out/'layer_report.json').write_text(json.dumps(result,indent=2)+'\n')
    print('PASS:',result)
if __name__=='__main__':main()
