#!/usr/bin/env python3
"""Prepare a small variable-batch fixture using the pinned b3 authoring API."""
import hashlib
from pathlib import Path
import sys
from typing import Annotated

sys.path.insert(0, str(Path(__file__).resolve().parent))
from environment import ROOT, initialize, identity, write_json
initialize()
import numpy as np
import coreai.authoring as a

directory = ROOT / 'fixtures/parity-v02/dynamic-double'
directory.mkdir(parents=True, exist_ok=True)
module = a.Module.create()
with module:
    def body(x):
        return a.add(x, x)
    body.__annotations__ = {
        'x': Annotated[a.Value, a.TensorType([-1, 3], np.float32)],
        'return': Annotated[a.Value, a.TensorType([-1, 3], np.float32, name='y')],
    }
    a.graph(body, provided_name='main')
module.verify()
(directory / 'graph.mlir').write_text(module.as_string() + '\n')
a.AIProgram(module).save_asset(directory / 'model.aimodel')
steps = []
for index, rows in enumerate([1, 4, 2, 1]):
    x = (np.arange(rows * 3, dtype=np.float32) - np.float32(2.5)).reshape(rows, 3)
    inputs = directory / f'{index}-x.f32'
    outputs = directory / f'{index}-expected-y.f32'
    inputs.write_bytes(x.astype('<f4').tobytes())
    outputs.write_bytes((x + x).astype('<f4').tobytes())
    steps.append({'shape': [rows, 3], 'input': inputs.name, 'expected': outputs.name})
write_json(directory / 'manifest.json', {
    'reference': identity(), 'input_signature': [None, 3], 'output_signature': [None, 3],
    'steps': steps, 'comparison': 'Exact float32 bytes and actual output shapes, changing batch size on one function.',
    'sha256': {str(path.relative_to(directory)): hashlib.sha256(path.read_bytes()).hexdigest()
               for path in sorted(directory.rglob('*')) if path.is_file() and path.name != 'manifest.json'},
})
print(directory)
