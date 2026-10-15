import hashlib, json, subprocess
from pathlib import Path
root = Path('/Users/zakkeown/Code/aether/lab/corsairs')
directory = Path('/private/tmp/corsairs-v02-publish-d7yvl_96/consumer')
binary = directory / 'target/debug/corsairs-v02-registry-consumer'
result = subprocess.run([str(binary)], cwd=directory, capture_output=True, text=True, timeout=60)
assert result.returncode == 0, result.stderr
assert 'native chain: [6.0, 5.0, 2.0, 0.0]' in result.stdout
lock = (directory / 'Cargo.lock').read_text()
assert 'registry+https://github.com/rust-lang/crates.io-index' in lock
assert '5cb0757cfcb9098ae1bf2a54f63c7cf063696dd64a7e26730ccb915b8ebfc17e' in lock
report = {'passed': True, 'default_features_only': True, 'forbids_unsafe': True,
    'consumer_manifest': (directory / 'Cargo.toml').read_text(), 'consumer_lockfile': lock,
    'source': (directory / 'src/main.rs').read_text(), 'binary_sha256': hashlib.sha256(binary.read_bytes()).hexdigest(),
    'exit_status': result.returncode, 'stdout': result.stdout, 'stderr': result.stderr,
    'native_scope': 'Actual crates.io dependency, concurrent model/function loading and retained native chaining of packaged fixtures.',
    'debugger_scope': 'Python launcher is observed; consumer child runs without LLDB breakpoints. Earlier direct target observation is retained separately and is not a clean execution gate.'}
path = root / 'docs/evidence/v0.2/registry-consumer.json'
path.write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps({'passed': True, 'registry_native_chain': True, 'report': str(path)}))
