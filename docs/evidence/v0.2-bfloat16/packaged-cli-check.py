import hashlib, json, subprocess
from pathlib import Path

root = Path('/Users/zakkeown/Code/aether/lab/corsairs')
binary = root / 'target/package-check-v02/package-target/release/corsairs'
fixture = root / 'fixtures/parity-v02/bfloat16/double'
rows = []
for backend in ['cpu', 'gpu-preferred']:
    output = Path('/private/tmp/corsairs-bf16-cli-untraced-' + backend)
    command = [str(binary), 'run', str(fixture / 'model.aimodel'), '--compute', backend,
        '--expect-frequent-reshapes', 'true', '--input', 'x', 'bfloat16', '2,3',
        str(fixture / '0-x.bin'), '--output-dir', str(output)]
    result = subprocess.run(command, cwd=root, capture_output=True, text=True, timeout=30)
    assert result.returncode == 0, result.stderr
    report = json.loads(result.stdout)
    value = report['outputs'][0]
    assert value['dtype'] == 'bfloat16' and value['shape'] == [2, 3] and value['strides'] == [3, 1]
    assert report['expect_frequent_reshapes'] is True
    payload = Path(value['file']).read_bytes()
    assert payload == (fixture / '0-expected-y.bin').read_bytes()
    negative = list(command)
    negative[negative.index('bfloat16')] = 'float16'
    rejected = subprocess.run(negative, cwd=root, capture_output=True, text=True, timeout=30)
    assert rejected.returncode == 1 and 'bfloat16' in rejected.stderr
    rows.append({'backend': backend, 'command': command, 'exit_status': result.returncode,
        'stdout': result.stdout, 'stderr': result.stderr,
        'output_sha256': hashlib.sha256(payload).hexdigest(), 'exact_fixture_bytes': True,
        'same_width_wrong_dtype': {'command': negative, 'exit_status': rejected.returncode,
            'stdout': rejected.stdout, 'stderr': rejected.stderr}})
report = {'passed': True, 'child_cli_under_debugger': False,
    'binary': str(binary), 'binary_sha256': hashlib.sha256(binary.read_bytes()).hexdigest(),
    'cases': rows, 'direct_observation_limit': 'Earlier direct LLDB CLI observations contain unclassified EXC_BREAKPOINT stops and are not used as a clean execution gate. This check runs the same packaged CLI as untraced child processes of the permitted native runner, like the package-consumer gate.'}
path = root / 'docs/evidence/v0.2-bfloat16/packaged-cli-untraced-check.json'
path.write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps({'passed': True, 'compute_settings': 2, 'same_width_dtype_rejections': 2, 'report': str(path)}))
