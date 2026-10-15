#!/usr/bin/env python3
"""Build/pin safe empty-descriptor GPU rejection qualification; native is opt-in.

CPU runs are restricted to the two logical-empty x+x graphs. Both broadcast
output graphs are exercised only through expected predispatch GPU rejection.
The original authoring manifest is retained; this checker defines qualification
policy separately from the initial planned cpu_run metadata.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[1]
FIXTURES = ROOT/'fixtures/parity-v03/gpu-rejections'


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def save(path, obj):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(obj, indent=2, allow_nan=False)+'\n')


def sources():
    paths = [ROOT/name for name in ['Cargo.toml','Cargo.lock',
        'scripts/check_gpu_rejections.py','scripts/reference/environment.py',
        'scripts/reference/build_gpu_rejection_fixtures.py','experiments/rust/gpu_rejections.rs']]
    paths += list((ROOT/'crates').rglob('*.rs')) + list((ROOT/'crates').rglob('Cargo.toml'))
    paths += [p for p in FIXTURES.rglob('*') if p.is_file()]
    return {str(p.relative_to(ROOT)):sha(p) for p in sorted(set(paths))}


def command(argv):
    argv = list(map(str,argv))
    result = subprocess.run(argv,cwd=ROOT,capture_output=True,text=True,timeout=300)
    record = dict(command=argv,exit_status=result.returncode,stdout=result.stdout,stderr=result.stderr)
    if result.returncode:
        raise RuntimeError(json.dumps(record))
    return record


def cpu_qualifies(case):
    return case['operation'] == 'double' and case['name'] in {'empty-at-gpu-limit','empty-over-gpu-limit'}


def expected_calls(fixtures):
    expected = set()
    for case in fixtures['cases']:
        name = case['name']
        if cpu_qualifies(case):
            if case['output_bytes']:
                raise RuntimeError('CPU branch must never execute a nonempty output')
            expected.update((name,'cpu',api,'value') for api in ['owned','native'])
        kind = 'unsupported' if case['gpu_reject'] else 'value'
        apis = ['owned','native','metal-auto']
        if 0 in case['output_shape']:
            apis.append('metal-bound')
        expected.update((name,'gpu-preferred',api,kind) for api in apis)
    return expected


def verify_build(manifest, before):
    if manifest['source_hashes'] != before:
        raise RuntimeError('Pinned sources differ; rebuild before native qualification')
    for path,digest in manifest['binaries'].items():
        if sha(path) != digest:
            raise RuntimeError(f'Pinned binary differs: {path}')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--build',action='store_true',help='Build in an isolated directory; never implies native execution')
    parser.add_argument('--no-build',action='store_true',help='Require exact pinned source and binary hashes')
    parser.add_argument('--native',action='store_true',help='Execute only in a coordinated permitted native environment')
    parser.add_argument('--build-dir',type=Path,default=Path('/private/tmp/corsairs-v03-gpu-rejections/build'))
    parser.add_argument('--output',type=Path,default=Path('/private/tmp/corsairs-v03-gpu-rejections/native'))
    parser.add_argument('--timeout',type=float,default=180,help='Native child timeout only; build commands allow300seconds')
    args = parser.parse_args()
    if args.build and args.no_build:
        parser.error('--build and --no-build are mutually exclusive')
    if args.timeout <= 0:
        parser.error('--timeout must be positive')
    build = args.build_dir.resolve()
    build.mkdir(parents=True,exist_ok=True)
    manifest_path = build/'build-manifest.json'
    fixtures = json.loads((FIXTURES/'manifest.json').read_text())
    for path,digest in fixtures['sha256'].items():
        if sha(FIXTURES/path) != digest:
            raise RuntimeError(f'Fixture differs: {path}')
    before = sources()
    if args.build:
        cargo = build/'cargo'
        rlib = cargo/'release/libcorsairs.rlib'
        driver = build/'driver-release'
        commands = [command(['cargo','build','--offline','-p','corsairs','--release','--lib','--target-dir',cargo])]
        commands.append(command(['rustc','--edition=2024','-Dwarnings','-O',ROOT/'experiments/rust/gpu_rejections.rs',
            '--extern',f'corsairs={rlib}','-L',f'dependency={rlib.parent/"deps"}','-o',driver]))
        if sources() != before:
            raise RuntimeError('Sources changed during build; do not use these binaries')
        manifest = dict(kind='corsairs-v03-gpu-rejection-build',created_utc=datetime.now(timezone.utc).isoformat(),
            source_hashes=before,binaries={str(p):sha(p) for p in [rlib,driver]},commands=commands,
            rustc=command(['rustc','-Vv'])['stdout'],os=command(['sw_vers'])['stdout'],
            native_executed=False,features=[],profile='release')
        save(manifest_path,manifest)
    else:
        manifest = json.loads(manifest_path.read_text())
    verify_build(manifest,before)
    if not args.native:
        print(json.dumps(dict(prepared=True,native_executed=False,build_manifest=str(manifest_path),
            expected_inference_checks=len(expected_calls(fixtures)))))
        return 0
    output = args.output.resolve()
    if output == ROOT or ROOT in output.parents:
        raise RuntimeError('Native process output must be outside the source tree')
    output.mkdir(parents=True,exist_ok=True)
    report = dict(kind='corsairs-v03-gpu-descriptor-rejections',passed=False,
        created_utc=datetime.now(timezone.utc).isoformat(),build_manifest_sha256=sha(manifest_path),
        source_hashes=before,fixture_manifest_sha256=sha(FIXTURES/'manifest.json'),
        scope=fixtures['scope'],native_executed=True,
        cpu_qualification_cases=[c['name'] for c in fixtures['cases'] if cpu_qualifies(c)],
        cpu_policy='Only x+x empty graphs are CPU-qualified. Both broadcast graphs are GPU descriptor rejection probes; their historical authoring cpu_run metadata does not select CPU execution.',
        dispatch_scope='Typed Unsupported + policy reason; fixed descriptor source guard precedes dispatch. Public API has no dispatch/allocation counter. Drop/drain and post-rejection recovery are checked; leak freedom is not measured.')
    save(output/'checks.json',report)
    argv = [str(build/'driver-release'),str(FIXTURES)]
    started = time.monotonic()
    try:
        # File-backed live capture lets the coordinator monitor a native window.
        with (output/'events.jsonl').open('w') as out,(output/'native.stderr.log').open('w') as err:
            process = subprocess.Popen(argv,cwd=ROOT,stdout=out,stderr=err)
            try:
                status = process.wait(timeout=args.timeout)
                timed_out = False
            except subprocess.TimeoutExpired:
                process.kill()
                status = process.wait()
                timed_out = True
        report['process'] = dict(command=argv,exit_status=status,timed_out=timed_out,
            elapsed_seconds=time.monotonic()-started,stdout=(output/'events.jsonl').read_text(),
            stderr=(output/'native.stderr.log').read_text())
        if status or timed_out:
            raise RuntimeError(f'Native probe failed exit={status},timeout={timed_out}')
        events = [json.loads(line) for line in report['process']['stdout'].splitlines() if line.strip()]
        expected = expected_calls(fixtures)
        actual = [(e['case'],e['compute'],e['api'],e['kind']) for e in events
                  if e.get('event')=='check' and e.get('kind') in ['value','unsupported']]
        if len(actual) != len(expected) or set(actual) != expected:
            raise RuntimeError(f'Inference coverage differs: expected={sorted(expected)},actual={actual}')
        if not events or events[-1].get('event')!='complete' or events[-1].get('passed') is not True:
            raise RuntimeError('Missing successful completion event')
        if any(e.get('passed') is not True for e in events):
            raise RuntimeError('A native event did not pass')
        checks = [e for e in events if e.get('event')=='check']
        if len(checks)!=45 or len(events)!=46:
            raise RuntimeError('Missing metadata/storage/lifecycle coverage')
        for case in fixtures['cases']:
            computes = ['gpu-preferred'] + (['cpu'] if cpu_qualifies(case) else [])
            for compute in computes:
                apis = {e['api'] for e in checks if e['case']==case['name'] and e['compute']==compute}
                if not {'descriptor','native-upload-download','drop-drain'}.issubset(apis):
                    raise RuntimeError('Missing descriptor, raw upload or drop/drain result')
            if not any(e['case']==case['name'] and e['api']=='metal-upload-download' for e in checks):
                raise RuntimeError('Missing tiny/empty Metal raw-storage roundtrip')
        if sources()!=before:
            raise RuntimeError('Sources changed during native run; preserve raw output and rerun after pinning')
        verify_build(manifest,before)
        report.update(passed=True,events=events,inference_checks=len(actual),
            expected_gpu_rejections=sum(e[3]=='unsupported' for e in actual),
            positive_empty_results=sum(e[3]=='value' for e in actual),native_validated=True)
    except Exception as error:
        report['error']=str(error)
    save(output/'checks.json',report)
    print(json.dumps(dict(passed=report['passed'],report=str(output/'checks.json'))),flush=True)
    return 0 if report['passed'] else 1

if __name__=='__main__':
    raise SystemExit(main())
