"""Collect passing test evidence and exact DDR build/resource results."""
from pathlib import Path
import hashlib
import json
from datetime import datetime, timezone, timedelta

ROOT = Path(__file__).resolve().parents[1]
groups = {
    'output/ddr_migration': ['tb_keys','tb_limiter','tb_dac','tb_synth','tb_marimba',
                            'tb_marimba_controls','tb_uart_protocol','tb_uart_player','tb_uart_notes',
                            'tb_ddr_assets','tb_ddr_clarinet','tb_ddr_player','tb_ddr_native_write'],
    'sim': ['tb_tjc_status','tb_note_audition','tb_score_full','tb_score_player'],
    'output/nocturne': ['tb_nocturne_full','tb_nocturne_sd'],
    'output/video_integration': ['tb_video_sync','tb_video_timeline','tb_video_line',
                               'tb_video_scene','tb_video_raster','tb_tmds','tb_video_player'],
}
evidence = {}
for directory, benches in groups.items():
    for bench in benches:
        path = ROOT/directory/(bench+'.log')
        content = path.read_text(errors='replace')
        assert 'Errors: 0' in content and 'PASS' in content, f'Incomplete test: {path}'
        evidence[bench] = dict(log=path.relative_to(ROOT).as_posix(),
                               sha256=hashlib.sha256(path.read_bytes()).hexdigest(),
                               results=[line for line in content.splitlines() if 'PASS' in line])
manifest = json.loads((ROOT/'output/build_manifest.json').read_text())
bitstream = ROOT/manifest['bitstream']
assert hashlib.sha256(bitstream.read_bytes()).hexdigest() == manifest['bitstream_sha256']
for path, digest in manifest['inputs'].items():
    assert hashlib.sha256((ROOT/path).read_bytes()).hexdigest() == digest, f'Changed build input: {path}'
result = dict(created_at=datetime.now(timezone(timedelta(hours=8))).isoformat(),
              tests=evidence, distinct_testbenches=len(evidence),
              resources=json.loads((ROOT/'output/ddr_migration/resources.json').read_text()),
              timing=manifest['timing'], bitstream_sha256=manifest['bitstream_sha256'],
              hardware_tested=False)
out = ROOT/'output/ddr_migration/verification.json'
out.write_text(json.dumps(result, indent=2)+'\n')
print(f'PASS: {len(evidence)} distinct testbenches, current inputs/bitstream and DDR resources recorded')
