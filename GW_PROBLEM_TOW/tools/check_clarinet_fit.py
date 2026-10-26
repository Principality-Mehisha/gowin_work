"""Compare old/new harmonic shapes against held-out recording windows."""
from pathlib import Path
import json
from fit_clarinet_params import ROOT,DYNAMICS,REGIONS,read_aiff,harmonic_frame,OUT_FS
import numpy as np

def distance(estimate,reference,limit):
    reference=np.asarray(reference,dtype=float);estimate=np.asarray(estimate,dtype=float)
    ref=reference/max(reference[0],1e-20);est=estimate/max(estimate[0],1e-20)
    eligible=(np.arange(32)<limit)&(ref>10**(-45/20))
    error=np.abs(20*np.log10(np.maximum(est,1e-3))-20*np.log10(np.maximum(ref,1e-3)))
    return float(np.mean(error[eligible]))

def main():
    measured=json.loads((ROOT/'assets/clarinet/measurements.json').read_text())
    old=[int(s,16) for s in (ROOT/'output/clarinet_calibration/before/src/rom/clarinet45.hex').read_text().split()]
    words=[int(s,16) for s in (ROOT/'src/rom/clarinet45.hex').read_text().split()]
    results=[]
    for bank,d in enumerate(DYNAMICS):
        for region,low,high in REGIONS:
            x=read_aiff(ROOT/f'assets/clarinet/source/{d}/BbClar.{d}.{region}.aiff')
            for midi in range(low,min(high,94)+1):
                n=measured[d][str(midi)]
                start=min(n['end_seconds']-.3,n['start_seconds']+(n['end_seconds']-n['start_seconds'])*.76)
                frame=harmonic_frame(x,start,.2,midi)
                before=np.array([(old[midi-50]>>(16*i))&65535 if i<8 else 0 for i in range(32)])
                after=np.array([(words[(bank*45+midi-50)*32+i]>>16)&65535 for i in range(32)])
                expected=440*2**((midi-69)/12);available=min(32,int(.46875*OUT_FS/expected))
                results.append(dict(midi=midi,dynamic=d,heldout_start_seconds=start,
                    old_error_db=distance(before,frame['amplitude'],available),
                    new_error_db=distance(after,frame['amplitude'],available),
                    old_first8_error_db=distance(before,frame['amplitude'],min(8,available)),
                    new_first8_error_db=distance(after,frame['amplitude'],min(8,available))))
    report=dict(method='Mean absolute harmonic-level error relative to the fundamental, reference harmonics above -45 dB; held-out 200 ms windows later in the same recordings',
        profiles=len(results),old_median_error_db=float(np.median([r['old_error_db'] for r in results])),
        new_median_error_db=float(np.median([r['new_error_db'] for r in results])),
        old_first8_median_db=float(np.median([r['old_first8_error_db'] for r in results])),
        new_first8_median_db=float(np.median([r['new_first8_error_db'] for r in results])),
        improved_profiles=sum(r['new_error_db']<r['old_error_db'] for r in results),results=results)
    out=ROOT/'output/clarinet_calibration/fit_comparison.json';out.write_text(json.dumps(report,indent=2)+'\n')
    assert report['new_median_error_db']<report['old_median_error_db']*.7
    print(json.dumps({k:v for k,v in report.items() if k!='results'},indent=2))
if __name__=='__main__':main()
