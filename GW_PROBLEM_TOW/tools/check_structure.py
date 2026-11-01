"""Collect structure regression evidence and compare real implementation reports."""
from pathlib import Path
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'output/no_clarinet'
BENCHES = ('tb_instrument_bank', 'tb_board_controls', 'tb_note_audition',
           'tb_tjc_status', 'tb_uart_protocol', 'tb_uart_notes', 'tb_uart_player',
           'tb_video_player', 'tb_score_full', 'tb_score_player')


def implementation(path):
    report = path.read_text()
    result = {}
    for name in ('Logic', 'Register', 'CLS', 'BSRAM', 'DSP'):
        m = re.search(r'^\s*' + name + r'\s*\|\s*([\d.]+)/([\d.]+)', report, re.M)
        assert m, f'Missing resource: {name}'
        result[name] = {'used': float(m[1]), 'total': float(m[2])}
    for name, pattern in (
        ('placement_seconds', r'Total Placement:.*?Elapsed time = '),
        ('routing_seconds', r'Total Routing:.*?Elapsed time = '),
        ('pnr_seconds', r'Total Time and Memory Usage:.*?Elapsed time = '),
    ):
        m = re.search(pattern + r'(\d+)h (\d+)m ([\d.]+)s', report)
        assert m, f'Missing elapsed time: {name}'
        result[name] = int(m[1])*3600 + int(m[2])*60 + float(m[3])
    return result


def main():
    manifest = json.loads((ROOT/'output/build_manifest.json').read_text())
    for name, digest in manifest['inputs'].items():
        assert hashlib.sha256((ROOT/name).read_bytes()).hexdigest() == digest, f'Stale build: {name}'
    assert hashlib.sha256((ROOT/manifest['bitstream']).read_bytes()).hexdigest() == manifest['bitstream_sha256']
    netlist = (ROOT/'impl/gwsynthesis/GW_PROBLEM_TOW.vg').read_text()
    instances = re.findall(r'^\s*output_limiter\s+\w+\s*\(', netlist, re.M)
    assert len(instances) == 1, f'Expected one shared limiter, got {len(instances)}'
    assert not re.search(r'\bmodule (?:clarinet_synth|audio_ddr3|ddr_asset_service|ddr_asset_seed|DDR3_Memory_Interface_Top)\b', netlist), 'Removed subsystem still synthesized'
    assert not (ROOT/'src/ddr').exists()
    tests = {}
    for bench in BENCHES:
        path = OUT/(bench+'.log')
        content = path.read_text(errors='replace')
        assert 'Errors: 0' in content and '# PASS' in content and '** Fatal' not in content, bench
        tests[bench] = {'log': path.relative_to(ROOT).as_posix(),
                        'sha256': hashlib.sha256(path.read_bytes()).hexdigest(),
                        'results': [line for line in content.splitlines() if line.startswith('# PASS')]}
    after = implementation(ROOT/'impl/pnr/GW_PROBLEM_TOW.rpt.txt')
    assert after['BSRAM']['used'] < 104
    result = {'tests': tests, 'distinct_testbenches': len(tests), 'after': after,
              'shared_limiters': len(instances), 'removed_subsystems_absent': True,
              'timing': manifest['timing'], 'bitstream_sha256': manifest['bitstream_sha256'],
              'hardware_tested': False}
    baseline = OUT/'before/GW_PROBLEM_TOW.rpt.txt'
    if baseline.exists():
        result['before'] = before = implementation(baseline)
        result['bsram_released'] = before['BSRAM']['used'] - after['BSRAM']['used']
        result['pnr_reduction_percent'] = 100*(1-after['pnr_seconds']/before['pnr_seconds'])
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT/'verification.json').write_text(json.dumps(result, indent=2)+'\n')
    print(f'PASS: {len(tests)} regressions, one limiter, removed subsystems absent, current build fingerprints')


if __name__ == '__main__':
    main()
