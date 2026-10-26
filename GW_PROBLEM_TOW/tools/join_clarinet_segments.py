"""Validate completed RTL segments and concatenate them for the full PCM check."""
import hashlib
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]


def main():
    folder=ROOT/'output/clarinet_calibration/segments'
    manifest=json.loads((folder/'manifest.json').read_text())
    for path,digest in manifest['inputs'].items():
        assert hashlib.sha256((ROOT/path).read_bytes()).hexdigest()==digest,('Changed segment input',path)
    counts=[];dest=ROOT/'output/nocturne/nocturne_pcm.txt'
    # Validate every part before replacing the earlier partial output.
    for segment in manifest['segments']:
        number=segment['number'];log=(folder/f'segment{number}.log').read_text()
        assert '# PASS: full real-time clarinet Nocturne' in log and '** Fatal' not in log,number
        with (folder/f'segment{number}_pcm.txt').open() as f:count=sum(1 for _ in f)
        assert count==segment['end_frame']-segment['start_frame'],(number,count)
        counts.append(count)
    assert sum(counts)==manifest['frames']
    with dest.open('w') as target:
        for segment in manifest['segments']:
            with (folder/f"segment{segment['number']}_pcm.txt").open() as source:
                for line in source:target.write(line)
    manifest['completed_frames']=sum(counts)
    manifest['pcm_sha256']=hashlib.sha256(dest.read_bytes()).hexdigest()
    (folder/'completed.json').write_text(json.dumps(manifest,indent=2)+'\n')
    print(f'PASS: {sum(counts)} contiguous RTL samples, four matching state boundaries')


if __name__=='__main__':main()
