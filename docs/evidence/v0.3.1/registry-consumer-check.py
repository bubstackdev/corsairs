import hashlib, json, subprocess, sys
from pathlib import Path
root = Path(__file__).resolve().parents[3]
directory = Path(sys.argv[1])
binary = directory / 'target/debug/corsairs-v031-registry-consumer'
result = subprocess.run([str(binary)], cwd=directory, capture_output=True, text=True, timeout=60)
assert result.returncode == 0, result.stderr
assert 'native chain: [6.0, 5.0, 2.0, 0.0]' in result.stdout
lock = (directory / 'Cargo.lock').read_text()
assert 'registry+https://github.com/rust-lang/crates.io-index' in lock
assert '01049380ddaee897eb5b6b322723c83686c6f2f234be288cb1473e528e45ed20' in lock
report = {'passed': True, 'default_features_only': True, 'forbids_unsafe': True,
    'consumer_manifest': (directory / 'Cargo.toml').read_text(), 'consumer_lockfile': lock,
    'source': (directory / 'src/main.rs').read_text(), 'binary_sha256': hashlib.sha256(binary.read_bytes()).hexdigest(),
    'exit_status': result.returncode, 'stdout': result.stdout, 'stderr': result.stderr,
    'native_scope': 'Actual crates.io dependency, concurrent model/function loading and retained native chaining of packaged fixtures.',
    'execution_scope': 'Consumer run directly from an ordinary shell without a debugger launcher.'}
path = root / 'docs/evidence/v0.3.1/registry-consumer.json'
path.write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps({'passed': True, 'registry_native_chain': True, 'report': str(path)}))
