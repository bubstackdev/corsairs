import hashlib, json, subprocess, sys
from pathlib import Path
root = Path(__file__).resolve().parents[3]
directory = Path(sys.argv[1])
binary = directory / 'target/debug/corsairs-v050-registry-consumer'
result = subprocess.run([str(binary)], cwd=directory, capture_output=True, text=True, timeout=60)
assert result.returncode == 0, result.stderr
for line in ['native chain: [6.0, 5.0, 2.0, 0.0]', 'neural-engine-preferred: [6.0, 5.0, 2.0, 0.0]', 'asset: 1 function, 21 operations', 'cancel: TooLate; u8 roundtrip: ok', 'float8: e4m3fn roundtrip and e5m2 overflow ok; dtypes 15', 'images: bgra32 identity exact on 3 backends', 'creator metadata: 27 entries']: assert line in result.stdout, line
lock = (directory / 'Cargo.lock').read_text()
assert 'registry+https://github.com/rust-lang/crates.io-index' in lock
assert '1c0124742e29b0e29bf389415f7d9eae0e8c850ec10249198098053e9b2f715c' in lock
report = {'passed': True, 'default_features_only': True, 'forbids_unsafe': True,
    'consumer_manifest': (directory / 'Cargo.toml').read_text(), 'consumer_lockfile': lock,
    'source': (directory / 'src/main.rs').read_text(), 'binary_sha256': hashlib.sha256(binary.read_bytes()).hexdigest(),
    'exit_status': result.returncode, 'stdout': result.stdout, 'stderr': result.stderr,
    'native_scope': 'Actual crates.io dependency: concurrent loading and native chaining, Neural Engine-preferred run, asset inspection with statistics, device architecture, cancellation outcome, u8 storage, float8 storage and conversion, DType::all(), BGRA32 image identity on CPU-only, GPU-preferred and Neural Engine-preferred compute, and creator-defined metadata.',
    'execution_scope': 'Consumer run directly from an ordinary shell without a debugger launcher.'}
path = root / 'docs/evidence/v0.5/registry-consumer.json'
path.write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps({'passed': True, 'registry_native_chain': True, 'report': str(path)}))
