#!/usr/bin/env python3
"""Verify typed errors and recovery for existing, malformed model assets."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / 'target/malformed-assets'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--native', action='store_true', help='Execute in a permitted native Core AI environment')
    args = parser.parse_args()
    OUTPUT.mkdir(parents=True, exist_ok=True)
    fixtures = OUTPUT / 'fixtures'
    fixtures.mkdir(exist_ok=True)
    paths = []
    for name, payload in [('truncated', b'ML\xefR'), ('nonsense', b'not a Core AI model\n')]:
        path = fixtures / f'{name}.aimodel'
        path.mkdir(exist_ok=True)
        (path / 'main.mlirb').write_bytes(payload)
        paths.append(path)
    path = fixtures / 'text.aimodel'
    path.write_bytes(b'not a model\n')
    paths.append(path)
    report = {'commands': [], 'native_requested': args.native, 'passed': False}
    try:
        commands = [
            ['cargo', 'build', '--offline', '-p', 'corsairs', '--release', '--lib'],
            ['rustc', '--edition=2024', '-Dwarnings', '-O', str(ROOT / 'experiments/rust/malformed_assets.rs'),
             '--extern', f'corsairs={ROOT / "target/release/libcorsairs.rlib"}',
             '-L', f'dependency={ROOT / "target/release/deps"}', '-o', str(OUTPUT / 'driver')],
        ]
        if args.native:
            commands.append([str(OUTPUT / 'driver'), str(ROOT / 'fixtures/parity-v01/double_float32/model.aimodel'),
                             *map(str, paths)])
        for command in commands:
            result = subprocess.run(command, cwd=ROOT, capture_output=True, text=True, timeout=180)
            report['commands'].append({'command': command, 'exit_status': result.returncode,
                                       'stdout': result.stdout, 'stderr': result.stderr})
            if result.returncode:
                raise RuntimeError(f'Failed: {command}\n{result.stdout}\n{result.stderr}')
        if args.native:
            events = [json.loads(line) for line in report['commands'][-1]['stdout'].splitlines()]
            if len(events) != 9 or events[-1] != {'event': 'complete', 'passed': True}:
                raise RuntimeError('Expected six typed errors, two recovery checks, and completion')
        sources = [ROOT / 'experiments/rust/malformed_assets.rs', ROOT / 'scripts/check_malformed.py',
                   ROOT / 'target/release/libcorsairs.rlib', OUTPUT / 'driver']
        sources.extend((ROOT / 'crates/corsairs-abi').rglob('*.rs'))
        sources.extend(path for path in fixtures.rglob('*') if path.is_file())
        report['sha256'] = {str(path.relative_to(ROOT)): hashlib.sha256(path.read_bytes()).hexdigest()
                            for path in sorted(sources)}
        report['compiler'] = subprocess.check_output(['rustc', '--version'], text=True).strip()
        report['passed'] = True
    except Exception as error:
        report['error'] = str(error)
        print(error, file=sys.stderr)
    (OUTPUT / 'checks.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({'passed': report['passed'], 'native_requested': args.native, 'report': str(OUTPUT / 'checks.json')}))
    return 0 if report['passed'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
