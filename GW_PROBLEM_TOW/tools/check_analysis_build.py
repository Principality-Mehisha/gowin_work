"""Freeze verified analysis images, regression evidence and actual implementation."""
from pathlib import Path
import argparse
import hashlib
import json
import re
from check_structure import implementation

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT/'output/piano_analysis'
BENCHES = ('tb_audio_analysis', 'tb_analysis_cdc', 'tb_piano_views', 'tb_analysis_render',
           'tb_uart_protocol', 'tb_uart_notes', 'tb_uart_player', 'tb_video_player',
           'tb_video_raster', 'tb_video_sync', 'tb_tmds', 'tb_video_scene', 'tb_video_hardware')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--baseline', type=Path, default=OUT/'before/GW_PROBLEM_TOW.rpt.txt')
    args = parser.parse_args()
    manifest = json.loads((ROOT/'output/build_manifest.json').read_text())
    for name, digest in manifest['inputs'].items():
        assert hashlib.sha256((ROOT/name).read_bytes()).hexdigest() == digest, f'Stale build input: {name}'
    digest = manifest['bitstream_sha256']
    for name in (manifest['bitstream'], 'output/GW_PROBLEM_TOW.fs'):
        assert hashlib.sha256((ROOT/name).read_bytes()).hexdigest() == digest
    assert all(c['setup_violations'] == c['hold_violations'] == 0 for c in manifest['timing']['clocks'].values())
    netlist = (ROOT/'impl/gwsynthesis/GW_PROBLEM_TOW.vg').read_text()
    for module in ('piano_audio_analysis', 'analysis_frame_cdc', 'piano_analysis_scene'):
        assert re.search(r'\bmodule '+module+r'\b', netlist), module
    tests = {}
    for bench in BENCHES:
        path = OUT/(bench+'.log')
        content = path.read_text(errors='replace')
        assert 'Errors: 0' in content and '# PASS' in content and '** Fatal' not in content, bench
        tests[bench] = dict(log=path.relative_to(ROOT).as_posix(),
                            sha256=hashlib.sha256(path.read_bytes()).hexdigest(),
                            results=[line for line in content.splitlines() if line.startswith('# PASS')])
    before = implementation(args.baseline)
    after = implementation(ROOT/'impl/pnr/GW_PROBLEM_TOW.rpt.txt')
    assert after['BSRAM']['used'] <= after['BSRAM']['total']
    artifacts = {p.name: hashlib.sha256(p.read_bytes()).hexdigest()
                 for p in [OUT/n for n in ('piano_input.hex', 'piano_result.hex', 'spectrum.png', 'waveform.png', 'preview.png')]}
    result = dict(tests=tests, distinct_testbenches=len(tests), before=before, after=after,
                  baseline_report=str(args.baseline.resolve()),
                  timing=manifest['timing'], bitstream_sha256=digest, artifacts=artifacts,
                  sample_rate_hz=50000000/3072, fft_points=1024, fft_bin_hz=50000000/(3072*1024),
                  waveform_samples=512, pixel_checks=3*1600*900, hardware_tested=False)
    (OUT/'verification.json').write_text(json.dumps(result, indent=2)+'\n')
    print(f'PASS: {len(tests)} testbenches, three complete RGB scenes, exact current build/artifact fingerprints')


if __name__ == '__main__':
    main()
