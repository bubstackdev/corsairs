#!/usr/bin/env python3
"""Append two CPU-authored x+x signatures; never rebuild existing assets.

This is reference-only preparation. It imports authoring/compiler tools, creates
no NDArray/model/runtime, and performs no inference or GPU work. A fresh tree
without these two cases is required; existing fixtures are never overwritten.
"""
from copy import deepcopy
from datetime import datetime, timezone
import hashlib
import json
import math
from pathlib import Path
import shutil
import sys
import tempfile
from typing import Annotated

sys.path.insert(0, str(Path(__file__).resolve().parent))
from environment import ROOT, identity, initialize, write_json


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def main():
    initialize()
    import numpy as np
    import coreai.authoring as authoring

    directory = ROOT / 'fixtures/parity-v03/large-tensors'
    manifest_path = directory / 'manifest.json'
    original_bytes = manifest_path.read_bytes()
    original = json.loads(original_bytes)
    before = {str(p.relative_to(directory)): sha(p)
              for p in sorted(directory.rglob('*'))
              if p.is_file() and p != manifest_path}
    if before != original['sha256']:
        raise RuntimeError('Existing fixture bytes differ from the shared manifest')
    reference = identity()
    for key in ['coreai_core', 'wheel_filename', 'wheel_sha256']:
        if reference[key] != original['reference'][key]:
            raise RuntimeError(f'Authoring identity differs: {key}')
    cases = [
        ('gpu-limit-f32', [536870912]),
        ('h3-rgb173', [173, 1344, 768, 3]),
    ]
    for name, _ in cases:
        if (directory / name).exists() or any(c['name'] == name for c in original['cases']):
            raise RuntimeError(f'Refusing to replace an existing case: {name}')
    evidence = ROOT / 'docs/evidence/v0.3-large-tensors/gpu-envelope-authoring'
    if evidence.exists():
        raise RuntimeError('Preserve existing authoring evidence; choose a fresh preparation tree')

    with tempfile.TemporaryDirectory(prefix='corsairs-v03-gpu-authoring-', dir='/private/tmp') as staging:
        staging = Path(staging)
        new_cases = []
        for name, shape in cases:
            target = staging / name
            target.mkdir()
            module = authoring.Module.create()
            with module:
                def body(x):
                    return authoring.add(x, x)
                body.__annotations__ = {
                    'x': Annotated[authoring.Value, authoring.TensorType(shape, np.float32)],
                    'return': Annotated[authoring.Value, authoring.TensorType(shape, np.float32, name='y')],
                }
                authoring.graph(body, provided_name='main')
            module.verify()
            (target / 'graph.mlir').write_text(module.as_string() + '\n')
            authoring.AIProgram(module).save_asset(target / 'model.aimodel')
            if (target / 'model.aimodel/main.hash').read_bytes().hex() != sha(target / 'model.aimodel/main.mlirb'):
                raise RuntimeError(f'Asset digest mismatch: {name}')
            new_cases.append({'name': name, 'dtype': 'float32', 'shape': shape,
                              'bytes': math.prod(shape) * 4,
                              'asset': name + '/model.aimodel'})
        if manifest_path.read_bytes() != original_bytes:
            raise RuntimeError('Shared manifest changed during authoring')
        if any(sha(directory / path) != digest for path, digest in before.items()):
            raise RuntimeError('Existing fixture bytes changed during authoring')
        for name, _ in cases:
            shutil.copytree(staging / name, directory / name)

    updated = deepcopy(original)
    updated['cases'].extend(new_cases)
    additions = {str(p.relative_to(directory)): sha(p)
                 for name, _ in cases for p in sorted((directory / name).rglob('*'))
                 if p.is_file()}
    updated['sha256'].update(additions)
    # All pre-existing identity, scope and pattern fields remain exact objects.
    if any(updated[key] != value for key, value in original.items()
           if key not in ['cases', 'sha256']):
        raise RuntimeError('An existing manifest field changed')
    if updated['cases'][:len(original['cases'])] != original['cases']:
        raise RuntimeError('An existing case changed')
    if any(updated['sha256'][path] != digest or sha(directory / path) != digest
           for path, digest in before.items()):
        raise RuntimeError('An existing graph/asset byte changed')
    write_json(manifest_path, updated)

    report = {
        'kind': 'corsairs-v03-gpu-envelope-fixture-authoring',
        'created_at': datetime.now(timezone.utc).isoformat(),
        'native_inference_executed': False, 'gpu_work_executed': False,
        'reference': reference,
        'source_pins': {str(p.relative_to(ROOT)): sha(p) for p in [
            Path(__file__), ROOT / 'scripts/reference/environment.py',
            ROOT / 'scripts/reference/build_large_fixtures.py']},
        'python_executable_sha256': sha(sys.executable),
        'authoring_module': str(Path(authoring.__file__)),
        'authoring_module_sha256': sha(authoring.__file__),
        'command': [sys.executable, '-B', str(Path(__file__).relative_to(ROOT))],
        'previous_manifest_sha256': hashlib.sha256(original_bytes).hexdigest(),
        'updated_manifest_sha256': sha(manifest_path),
        'existing_graph_asset_file_count': len(before),
        'existing_graph_asset_bytes_unchanged': True,
        'existing_graph_asset_sha256': before,
        'existing_cases_unchanged': True,
        'existing_reference_scope_pattern_unchanged': True,
        'new_cases': new_cases, 'new_files_sha256': additions,
        'new_asset_source_bytes': {c['name']: (directory / c['asset'] / 'main.mlirb').stat().st_size
                                   for c in new_cases},
        'scope': 'Two mechanical x+x signatures for subsequent GPU envelope qualification. CPU-only authoring, no tensor payload allocation, runtime/model construction, inference, GPU/REA/process-scenario launch or asset rebuild of old cases.',
    }
    evidence.mkdir(parents=True)
    (evidence / 'manifest-before.json').write_bytes(original_bytes)
    (evidence / 'generator.py').write_bytes(Path(__file__).read_bytes())
    write_json(evidence / 'preparation.json', report)
    print(json.dumps({'prepared': new_cases, 'evidence': str(evidence / 'preparation.json'),
                      'old_fixture_bytes_unchanged': True, 'native_inference_executed': False}))


if __name__ == '__main__':
    main()
