#!/usr/bin/env python3
"""Author tiny symbolic GPU descriptor-limit fixtures with pinned published b3.

This preparation uses only authoring/compiler APIs. It constructs no runtime,
NDArray, weight payload or inference request. Existing destinations are refused.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import math
from pathlib import Path
import sys
from typing import Annotated

sys.path.insert(0, str(Path(__file__).resolve().parent))
from environment import ROOT, initialize, identity

CASES = [
    dict(name='empty-at-gpu-limit', operation='double', input_shape=[0,536870912], output_shape=[0,536870912], gpu_reject=False, cpu_run=True),
    dict(name='empty-over-gpu-limit', operation='double', input_shape=[0,536870913], output_shape=[0,536870913], gpu_reject=True, cpu_run=True),
    dict(name='empty-output-over-gpu-limit', operation='broadcast', input_shape=[0,1], output_shape=[0,536870913], gpu_reject=True, cpu_run=True),
    dict(name='nonempty-output-over-gpu-limit', operation='broadcast', input_shape=[1], output_shape=[536870913], gpu_reject=True, cpu_run=False),
]


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, default=ROOT/'fixtures/parity-v03/gpu-rejections')
    args = parser.parse_args()
    output = args.output.resolve()
    if output.exists():
        raise RuntimeError('Destination exists; use a fresh --output to reproduce and compare')
    initialize()
    import numpy as np
    import coreai.authoring as authoring

    output.mkdir(parents=True)
    cases = []
    for spec in CASES:
        case = dict(spec)
        directory = output / case['name']
        directory.mkdir()
        module = authoring.Module.create()
        with module:
            def body(x):
                if case['operation'] == 'double':
                    return authoring.add(x,x)
                return authoring.broadcast_to(x,case['output_shape'])
            body.__annotations__ = {
                'x': Annotated[authoring.Value,authoring.TensorType(case['input_shape'],np.float32)],
                'return': Annotated[authoring.Value,authoring.TensorType(case['output_shape'],np.float32,name='y')],
            }
            authoring.graph(body,provided_name='main')
        module.verify()
        (directory/'graph.mlir').write_text(module.as_string()+'\n')
        authoring.AIProgram(module).save_asset(directory/'model.aimodel')
        if (directory/'model.aimodel/main.hash').read_bytes().hex() != sha(directory/'model.aimodel/main.mlirb'):
            raise RuntimeError('Saved graph hash mismatch')
        case.update(dtype='float32', function='main', input_name='x', output_name='y',
                    asset=f"{case['name']}/model.aimodel",
                    input_bytes=math.prod(case['input_shape'])*4,
                    output_bytes=math.prod(case['output_shape'])*4,
                    input_nonzero_extent_bytes=math.prod(max(d,1) for d in case['input_shape'])*4,
                    output_nonzero_extent_bytes=math.prod(max(d,1) for d in case['output_shape'])*4,
                    model_source_bytes=(directory/'model.aimodel/main.mlirb').stat().st_size)
        cases.append(case)
    package = Path(authoring.__file__).parents[1]
    tools = sorted((package/'authoring').rglob('*.py')) + sorted((package/'_compiler').rglob('*.so'))
    tools += [Path(sys.executable)]
    manifest = {
        'kind':'corsairs-v03-gpu-descriptor-rejection-fixtures',
        'created_utc':datetime.now(timezone.utc).isoformat(),
        'reference':identity(),
        'native_inference_executed':False, 'gpu_work_executed':False,
        'host_storage_limit_bytes':1<<32, 'gpu_inference_limit_bytes':1<<31,
        'scope':'Mechanical fixed descriptors for predispatch GPU rejection and exact-boundary empty success. Nonempty output-over-limit graph is GPU-rejection-only: never execute its CPU path or allocate its output. All prepared inputs have zero/four payload bytes. Logical empty shape guards include nonzero dimension extent.',
        'source_sha256':{str(p.relative_to(ROOT)):sha(p) for p in [Path(__file__),ROOT/'scripts/reference/environment.py']},
        'tool_sha256':{str(p):sha(p) for p in tools},
        'cases':cases,
        'sha256':{str(p.relative_to(output)):sha(p) for p in sorted(output.rglob('*')) if p.is_file()},
        'reproduce':[sys.executable,'-B',str(Path(__file__).relative_to(ROOT)),'--output','FRESH_DIRECTORY'],
    }
    (output/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    print(json.dumps({'fixtures':str(output),'cases':len(cases),'native_inference_executed':False}))

if __name__ == '__main__':
    main()
