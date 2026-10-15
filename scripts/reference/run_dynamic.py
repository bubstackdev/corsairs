#!/usr/bin/env python3
"""Reference variable-batch inference on one loaded b3 function per backend."""
import asyncio
import hashlib
import json
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from environment import ROOT, initialize, identity, write_json
initialize()
import numpy as np
from coreai.runtime import AIModel, ComputeUnitKind, NDArray, SpecializationOptions, _use_os_coreai


async def main():
    directory = ROOT / 'fixtures/parity-v02/dynamic-double'
    manifest = json.loads((directory / 'manifest.json').read_text())
    for relative, expected in manifest['sha256'].items():
        if hashlib.sha256((directory / relative).read_bytes()).hexdigest() != expected:
            raise RuntimeError(f'Fixture changed: {relative}')
    report = {'reference': identity(), 'os_backed': _use_os_coreai, 'backends': [], 'passed': False}
    for backend in ['cpu', 'gpu-preferred']:
        options = (SpecializationOptions.cpu_only() if backend == 'cpu' else
                   SpecializationOptions.from_preferred_compute_unit_kind(ComputeUnitKind.gpu()))
        model = await AIModel.load(directory / 'model.aimodel', options)
        function = model.load_function('main')
        steps = []
        for index, step in enumerate(manifest['steps']):
            x = np.frombuffer((directory / step['input']).read_bytes(), dtype='<f4').reshape(step['shape']).copy()
            outputs = await function(inputs={'x': NDArray(x)}, state={})
            y = outputs['y']
            payload = y.numpy().tobytes(order='C')
            assert list(y.shape) == step['shape']
            assert y.dtype == 'float32'
            assert payload == (directory / step['expected']).read_bytes()
            steps.append({'step': index, 'shape': list(y.shape), 'dtype': y.dtype,
                          'strides': list(y.strides), 'sha256': hashlib.sha256(payload).hexdigest(), 'passed': True})
        report['backends'].append({'compute': backend, 'steps': steps})
    report['passed'] = True
    write_json(directory / 'python-results.json', report)
    print(json.dumps({'passed': True, 'backends': 2, 'shape_changes_per_function': 4}), flush=True)


if __name__ == '__main__':
    asyncio.run(main())
