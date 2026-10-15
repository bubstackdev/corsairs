#!/usr/bin/env python3
"""Prepare step-zero Krea inputs with standard-library code, without Core AI."""
import argparse
import hashlib
import json
import math
from pathlib import Path
import re
import struct
import tempfile

ROOT = Path(__file__).resolve().parents[4]
KREA = Path('/Users/zakkeown/Code/atelier/lab/krea-lab')


def sha(path):
    result = hashlib.sha256()
    with Path(path).open('rb') as stream:
        for chunk in iter(lambda: stream.read(8 << 20), b''):
            result.update(chunk)
    return result.hexdigest()


def half_bits(bits):
    sign = (bits >> 16) & 0x8000
    exponent = ((bits >> 23) & 255) - 127 + 15
    fraction = bits & 0x7fffff
    assert (bits >> 23) & 255 != 255, 'nonfinite source'
    if exponent >= 31:
        return sign | 0x7c00
    if exponent < -10:
        return sign

    def rounded(number, shift):
        retained, discarded = divmod(number, 1 << shift)
        halfway = 1 << (shift - 1)
        return retained + int(discarded > halfway or
                              (discarded == halfway and retained & 1))

    if exponent <= 0:
        return sign | rounded(fraction | 0x800000, 14 - exponent)
    return sign | ((exponent << 10) + rounded(fraction, 13))


def convert(source, target, count):
    raw = source.read_bytes()
    assert len(raw) == count * 4
    converted = bytearray()
    for (bits,), (value,) in zip(struct.iter_unpack('<I', raw),
                                struct.iter_unpack('<f', raw)):
        bits16 = half_bits(bits)
        encoded = bits16.to_bytes(2, 'little')
        # Independent Python binary16 conversion must agree for every scalar.
        assert encoded == struct.pack('<e', value)
        assert bits16 & 0x7c00 != 0x7c00, 'nonfinite derived input'
        converted.extend(encoded)
    with target.open('xb') as stream:
        stream.write(converted)
    return {'source_file': str(source), 'source_sha256': sha(source),
            'file': str(target), 'sha256': sha(target), 'scalars': count,
            'source_dtype': 'float32', 'dtype': 'float16',
            'source_bytes': len(raw), 'bytes': len(converted),
            'every_scalar_matches_struct_binary16': True,
            'finite': True, 'axis_permutation': False,
            'conversion': 'Exact little-endian binary32 -> binary16, round-to-nearest ties-to-even; signed zeros preserved; no scaling, clipping or axis permutation.'}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--case', type=Path, default=ROOT / 'docs/evidence/v0.3-benchmarks/cases/krea-first-segment.json')
    parser.add_argument('--derived-dir', type=Path)
    args = parser.parse_args()
    assert not args.case.exists(), 'Preserve the existing case; choose a new destination'
    data_path = ROOT / 'target/krea-check/data.rs'
    data = data_path.read_text()

    def constant(name):
        match = re.search(r'const ' + name + r': &str = ("[^"\n]*");', data)
        assert match, name
        return Path(json.loads(match[1]))

    noise, text, rope = (constant(x) for x in ['NOISE_PATH', 'TEXT_PATH', 'ROPE_PATH'])
    model = KREA / 'forge/fixed-first/tower-first.aimodel'
    assert str(model) in data
    first = int(re.search(r'const TIMESTEP_BITS: &\[u32\] = &\[(\d+)', data)[1])
    assert first == 0x3f800000
    record_path = KREA / 'records/round4/fixed-paired-tower/record.json'
    record = json.loads(record_path.read_text())
    assert sha(record_path) == 'accbccdbac8c50e2833245addf001efc4cbf4083c213ea6ef766005965bf8bdf'
    assert sha(noise) == record['inputSHA256']['noise']
    assert sha(text) == record['inputSHA256']['text']
    carry_path = KREA / 'records/round4/block-inputs-tower/inputs.json'
    carries = json.loads(carry_path.read_text())
    assert sha(carry_path) == '4a5d6e6311c0bffe4c658f872bf6c768e17c6fb427d431498891a9658032192f'
    rope_spec = next(s for s in carries['inputs'] if s['name'] == 'rope_image')
    assert sha(rope) == rope_spec['sha256']
    model_hash = sha(model / 'main.mlirb')
    assert model_hash == (model / 'main.hash').read_bytes().hex()
    assert model_hash == 'bec8df89165b2dfa2aa69a793fb589c28e0e44d23179727cd5d796874945569a'
    if args.derived_dir:
        directory = args.derived_dir.resolve()
        assert directory.is_relative_to(Path('/private/tmp'))
        directory.mkdir(exist_ok=False)
    else:
        directory = Path(tempfile.mkdtemp(prefix='corsairs-v03-krea-first-', dir='/private/tmp'))
    conversions = [convert(noise, directory / 'latents.f16', 4032 * 64),
                   convert(text, directory / 'text-embeds.f16', 20 * 30720)]
    sigma = directory / 'sigma.f32'
    with sigma.open('xb') as stream:
        stream.write(first.to_bytes(4, 'little'))
    inputs = [
        {'name': 'latents', 'dtype': 'float16', 'shape': [4032, 64],
         'file': conversions[0]['file'], 'sha256': conversions[0]['sha256']},
        {'name': 'text_embeds', 'dtype': 'float16', 'shape': [20, 30720],
         'file': conversions[1]['file'], 'sha256': conversions[1]['sha256']},
        {'name': 'sigma', 'dtype': 'float32', 'shape': [1],
         'file': str(sigma), 'sha256': sha(sigma)},
        {'name': 'rope_image', 'dtype': 'float32', 'shape': [4032, 2, 128],
         'file': str(rope), 'sha256': rope_spec['sha256']},
    ]
    outputs = []
    for spec in carries['inputs']:
        if spec['name'] == 'rope_image':
            continue
        path = carry_path.parent / spec['file']
        assert sha(path) == spec['sha256']
        assert path.stat().st_size == math.prod(spec['shape']) * 4
        outputs.append({'name': spec['name'] if spec['name'] == 'cond' else spec['name'] + '_1',
                        'dtype': 'float32', 'shape': spec['shape'],
                        'file': str(path), 'sha256': spec['sha256']})
    sources = [data_path, ROOT / 'scripts/check_krea.py', ROOT / 'experiments/rust/krea_driver.rs',
               ROOT / 'crates/corsairs-abi/src/dtype.rs', Path(__file__),
               record_path, carry_path, KREA / 'records/corsairs-readiness/summary.json']
    case = {'schema': 1, 'name': 'krea-first-segment', 'model': str(model),
            'model_main_mlirb_sha256': model_hash, 'model_main_mlirb_bytes': (model / 'main.mlirb').stat().st_size,
            'function': 'segment', 'compute': 'gpu-preferred', 'expect_frequent_reshapes': None,
            'warmup': 3, 'samples': 10, 'inputs': inputs, 'outputs': outputs,
            'scope': 'One unchanged fixed Krea step0/segment0, saved provided-text/noise/rope fixtures and sigma=1. Three exact original Swift F32 carries, including94.5MiB image_1. No full generation, encoder, scheduler update or decoder. Both paired arms omit the reshape hint because public Python b3 cannot set it; production/retained acceptance uses explicit true. Exact correctness under the omitted hint remains to be tested; do not relax the output gate.',
            'provenance': {'native_executed': False, 'external_files_modified': False,
                           'source_hashes': {str(p): sha(p) for p in sources},
                           'source_model_hash_fully_verified': True,
                           'float16_conversions': conversions,
                           'sigma': {'value': 1.0, 'binary32_bits': first,
                                     'source': 'TIMESTEP_BITS[0] in target/krea-check/data.rs',
                                     'file': str(sigma), 'sha256': sha(sigma)},
                           'source_noise_shape': [84, 48, 64],
                           'denoiser_latent_shape': [4032, 64],
                           'packing': 'C-order flatten84*48 rows to4032 rows; same scalar order as existing Krea driver halves(), no axis permutation.',
                           'output_source_record': str(carry_path),
                           'source_acceptance_reshape_hint': True,
                           'benchmark_reshape_hint': None,
                           'input_bytes': sum(Path(x['file']).stat().st_size for x in inputs),
                           'output_bytes': sum(Path(x['file']).stat().st_size for x in outputs),
                           'derived_directory': str(directory)}}
    args.case.parent.mkdir(parents=True, exist_ok=True)
    with args.case.open('x') as stream:
        json.dump(case, stream, indent=2, allow_nan=False)
        stream.write('\n')
    print(json.dumps({'case': str(args.case.resolve()), 'sha256': sha(args.case),
                      'derived_directory': str(directory), 'native_executed': False}))


if __name__ == '__main__':
    main()
