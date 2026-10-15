#!/usr/bin/env python3
"""Opt-in fresh-process, at-most30second standalone Swift CPU diagnostic."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import subprocess
import time

STAGING = Path('/private/tmp/corsairs-empty-broadcast-diagnostic')
EVIDENCE = Path('/Users/zakkeown/Code/aether/lab/corsairs/docs/evidence/v0.3-final/empty-broadcast-diagnostic')


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--native',action='store_true')
    parser.add_argument('--timeout',type=float,default=30)
    parser.add_argument('--output',type=Path,default=STAGING/'native')
    args = parser.parse_args()
    if not 0 < args.timeout <= 30:
        parser.error('Diagnostic timeout must be positive and no more than30seconds')
    receipt_path = EVIDENCE/'preparation.json'
    receipt = json.loads(receipt_path.read_text())
    for path,digest in receipt['sha256'].items():
        if sha(path)!=digest:
            raise RuntimeError(f'Pinned artifact changed: {path}')
    if not args.native:
        print(json.dumps({'prepared':True,'native_executed':False,'receipt':str(receipt_path)}))
        return 0
    output = args.output.resolve()
    if output.exists() and any(output.iterdir()):
        raise RuntimeError('Use a fresh output directory; preserve earlier diagnostic outcomes')
    output.mkdir(parents=True,exist_ok=True)
    command = [receipt['binary'],receipt['asset']]
    started = time.monotonic()
    with (output/'events.jsonl').open('w') as out,(output/'native.stderr.log').open('w') as err:
        child = subprocess.Popen(command,stdout=out,stderr=err)
        try:
            status = child.wait(timeout=args.timeout)
            timed_out = False
        except subprocess.TimeoutExpired:
            child.kill()
            status = child.wait()
            timed_out = True
    stdout = (output/'events.jsonl').read_text()
    stderr = (output/'native.stderr.log').read_text()
    events = [json.loads(line) for line in stdout.splitlines() if line.startswith('{')]
    passed = status==0 and not timed_out and bool(events) and events[-1].get('passed') is True
    report = {
        'kind':'standalone-swift-empty-broadcast-cpu-diagnostic',
        'created_utc':datetime.now(timezone.utc).isoformat(),
        'passed':passed,'native_executed':True,
        'preparation_sha256':sha(receipt_path),
        'command':command,'exit_status':status,'signal':-status if status<0 else None,
        'timed_out':timed_out,'timeout_seconds':args.timeout,
        'elapsed_seconds':time.monotonic()-started,
        'events':events,'stdout':stdout,'stderr':stderr,
        'last_event':events[-1] if events else None,
        'scope':'Fresh standalone Swift ordinary CoreAI CPU run, same fixed graph and empty input; no Corsairs or Rust code. A crash here demonstrates independent native reproduction. It does not by itself localize the framework internal fault or establish a general empty-broadcast limitation.',
    }
    (output/'checks.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({'passed':passed,'exit_status':status,'report':str(output/'checks.json')}),flush=True)
    return 0 if passed else 1

if __name__=='__main__':
    raise SystemExit(main())
