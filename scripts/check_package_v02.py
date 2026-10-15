#!/usr/bin/env python3
"""Package, inspect, and exercise an isolated consumer of the v0.2 archive.

--native additionally runs the packaged and external consumer examples. This
does not contact a registry or upload anything. See the release contract for the
separate publication step. This candidate permits a dirty working tree and records every packaged source hash.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / 'target/package-check-v02'
REPORT = ROOT / 'docs/evidence/v0.2/package-verification.json'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--native', action='store_true')
    args = parser.parse_args()
    OUTPUT.mkdir(parents=True, exist_ok=True)
    REPORT.parent.mkdir(parents=True, exist_ok=True)
    report = {'started_at': datetime.now(timezone.utc).isoformat(), 'native_requested': args.native,
              'commands': [], 'passed': False, 'uploaded': False, 'registry_checked': False}

    def run(command, *, env=None):
        result = subprocess.run(command, cwd=ROOT, env={**os.environ, **(env or {})},
                                capture_output=True, text=True, timeout=180)
        report['commands'].append({'command': list(map(str, command)), 'environment_overrides': env or {},
                                   'exit_status': result.returncode, 'stdout': result.stdout, 'stderr': result.stderr})
        REPORT.write_text(json.dumps(report, indent=2) + '\n')
        if result.returncode:
            raise RuntimeError(f'Failed: {command}\n{result.stdout}\n{result.stderr}')
        return result.stdout

    try:
        report['rustc'] = run(['rustc', '-Vv']).strip()
        report['os'] = run(['sw_vers']).strip()
        run(['cargo', 'package', '--offline', '--locked', '-p', 'corsairs', '--list', '--allow-dirty'])
        run(['cargo', 'package', '--offline', '--locked', '-p', 'corsairs', '--allow-dirty'])
        archive = ROOT / 'target/package/corsairs-0.2.0.crate'
        package = ROOT / 'target/package/corsairs-0.2.0'
        report['archive'] = {'path': str(archive), 'sha256': digest(archive), 'bytes': archive.stat().st_size}
        files = {}
        with tarfile.open(archive, 'r:gz') as tar:
            for member in tar.getmembers():
                parts = Path(member.name).parts
                if not member.isfile() or '..' in parts or not parts or parts[0] != 'corsairs-0.2.0':
                    raise RuntimeError(f'Unexpected archive entry: {member.name}')
                relative = str(Path(*parts[1:]))
                payload = tar.extractfile(member).read()
                if payload != (package / relative).read_bytes():
                    raise RuntimeError(f'Extracted archive differs: {relative}')
                files[relative] = hashlib.sha256(payload).hexdigest()
        report['packaged_files_sha256'] = files
        required = ['LICENSE-MIT', 'LICENSE-APACHE', 'README.md', 'examples/feedforward.rs',
                    'examples/stateful.rs', 'examples/native_chain.rs', 'examples/metal_chain.rs', 'models/manifest.json', 'src/lib.rs', 'src/bin/corsairs.rs']
        if any(path not in files for path in required):
            raise RuntimeError('Required license, documentation, source, examples, or models omitted')
        for relative, expected in files.items():
            source = ROOT / 'crates/corsairs-abi' / relative
            if relative.startswith(('src/', 'examples/', 'models/')) or relative.startswith('LICENSE') or relative == 'README.md':
                if digest(source) != expected:
                    raise RuntimeError(f'Package/current source differs: {relative}')
        manifest = json.loads((ROOT / 'target/v02-check/build-manifest.json').read_text())
        for relative, expected in manifest['source_hashes'].items():
            if digest(ROOT / relative) != expected:
                raise RuntimeError(f'Tested source differs: {relative}')
        core = json.loads((ROOT / 'target/v02-check/checks.json').read_text())
        if not core.get('passed') or not core.get('native_validated') or core['build_manifest_sha256'] != digest(ROOT / 'target/v02-check/build-manifest.json'):
            raise RuntimeError('Current native core gates must pass before packaging')
        report['tested_source_identity_sha256'] = manifest['source_identity_sha256']
        model_manifest = json.loads((package / 'models/manifest.json').read_text())
        for relative, expected in model_manifest['sha256'].items():
            if digest(package / 'models' / relative) != expected:
                raise RuntimeError(f'Packaged model provenance mismatch: {relative}')
        consumer = OUTPUT / 'consumer'
        consumer.mkdir(exist_ok=True)
        (consumer / 'Cargo.toml').write_text('[package]\nname = "corsairs-release-consumer"\nversion = "0.0.0"\nedition = "2024"\n'
                                           '\n[dependencies]\ncorsairs = { version = "=0.2.0", path = ' + json.dumps(str(package)) + ' }\n\n[workspace]\n')
        shutil.copytree(package / 'examples', consumer / 'examples', dirs_exist_ok=True)
        shutil.copytree(package / 'models', consumer / 'models', dirs_exist_ok=True)
        for example in ['feedforward', 'stateful', 'native_chain', 'metal_chain']:
            if digest(consumer / f'examples/{example}.rs') != files[f'examples/{example}.rs']:
                raise RuntimeError('External consumer example differs from archive')
        consumer_manifest = str(consumer / 'Cargo.toml')
        run(['cargo', 'generate-lockfile', '--offline', '--manifest-path', consumer_manifest])
        features = run(['cargo', 'tree', '--offline', '--locked', '--edges', 'features', '--manifest-path', consumer_manifest])
        if 'abi-research' in features:
            raise RuntimeError('Research features leaked into ordinary consumer')
        consumer_target = OUTPUT / 'consumer-target'
        package_target = OUTPUT / 'package-target'
        run(['cargo', 'build', '--offline', '--locked', '--release', '--examples', '--manifest-path', consumer_manifest],
            env={'CARGO_TARGET_DIR': str(consumer_target)})
        run(['cargo', 'build', '--offline', '--locked', '--release', '--examples', '--bin', 'corsairs',
             '--manifest-path', str(package / 'Cargo.toml')], env={'CARGO_TARGET_DIR': str(package_target)})
        report['consumer'] = {'manifest': consumer_manifest, 'default_features_only': True,
                              'examples_forbid_unsafe': all('#![forbid(unsafe_code)]' in (consumer / f'examples/{name}.rs').read_text()
                                                           for name in ['feedforward', 'stateful', 'native_chain', 'metal_chain'])}
        if not report['consumer']['examples_forbid_unsafe']:
            raise RuntimeError('Consumer examples must forbid unsafe code')
        if args.native:
            for target in [package_target, consumer_target]:
                for example in ['feedforward', 'stateful', 'native_chain', 'metal_chain']:
                    binary = target / 'release/examples' / example
                    run([str(binary)])
                    report.setdefault('native_binary_sha256', {})[str(binary.relative_to(ROOT))] = digest(binary)
            run([str(package_target / 'release/corsairs'), 'inspect', str(package / 'models/feedforward.aimodel'), '--compute', 'gpu-preferred'])
        dist = ROOT / 'dist/v0.2.0'
        dist.mkdir(parents=True, exist_ok=True)
        candidate = dist / archive.name
        shutil.copyfile(archive, candidate)
        (dist / (archive.name + '.sha256')).write_text(f'{digest(candidate)}  {candidate.name}\n')
        (dist / 'source-manifest.json').write_text(json.dumps({'archive_sha256': digest(candidate),
                'tested_source_identity_sha256': manifest['source_identity_sha256'], 'packaged_files_sha256': files}, indent=2) + '\n')
        report['candidate'] = str(candidate)
        report['native_validated'] = args.native
        report['passed'] = True
    except Exception as error:
        report['error'] = str(error)
        print(error)
    REPORT.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({'passed': report['passed'], 'native_validated': report.get('native_validated', False), 'report': str(REPORT)}))
    return 0 if report['passed'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
