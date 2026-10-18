# Additional scalar types

Recorded 2026-10-18 on macOS 27.0.1 (26A434), device architecture `h17c`, with
pinned `coreai-core 1.0.0b3` as the reference.

v0.4 adds `DType::{Float64, Int8, Int16, UInt8, UInt16, UInt32, UInt64}`, backed
by the Rust primitives `f64`, `i8`, `i16`, `u8`, `u16`, `u32` and `u64`. Each maps to the
matching `NDArray.ScalarType` case. Storage is little-endian, and float64 NaN
payloads are kept bit for bit. `DType` is now `#[non_exhaustive]`.
`DType::all()` (added in v0.4.1) returns every supported type as a slice that
can grow. The fixed-length `DType::ALL` array keeps its v0.4.0 contents (13 types,
no float8) so its type stays stable, and is deprecated.

Core AI defines 35 scalar types. The packed sub-byte types (`int2`–`int7`,
`uint1`–`uint7`, `float4e2m1fn`), `float8e8m0fn`, the 128-bit integers and the
complex types are not exposed. Float8 E4M3FN and E5M2 were added after v0.4.0;
see [below](#float8).

## Reference grid

`scripts/reference/build_scalar_fixtures.py` authors 35 cases in
[`fixtures/parity-v04/scalar-types`](../fixtures/parity-v04/scalar-types/README.md).
Each integer type gets `double`, `scalar`, `empty`, `transpose` (the type's
extremes moved through a stride-changing layout) and `wrap` (overflowing `x + x`).
float64 gets `double`, `scalar`, `empty`, `transpose` and `edges` (signed zeros,
infinities, a NaN payload and the minimum subnormal). The existing `run_suite.py`
executed all 35 cases on CPU-only, GPU-preferred and Neural Engine-preferred
options, one OS-backed child process per configuration. 100 of the 105
configurations match NumPy exactly. Five reviewed outcomes are frozen by digest
or error text in `freeze_goldens.py --scalar-types`; repeated runs reproduced
each one:

| Backend | Case | Observation | Interpretation |
| --- | --- | --- | --- |
| Neural Engine | `int8_wrap` | `[-128, 127, 0, 2, 127, -128]` | Saturates instead of wrapping |
| Neural Engine | `uint8_wrap` | `[0, 255, 0, 2, 255, 4]` | Saturates instead of wrapping |
| Neural Engine | `int16_transpose` | 32766 → 32767, −32767 → −32768 | Consistent with float16 rounding; storage identity is not preserved |
| CPU | `int16_empty`, `uint16_empty` | `inferenceFailed(-1)` | Core AI rejects the valid empty request |

CPU and GPU wrap integer overflow, as NumPy does. On the Neural Engine,
applications should not rely on int16 values beyond ±2048 surviving even a
layout-only operation. uint16 extremes did survive there, which suggests, but
does not prove, that the operation fell back to another unit. No delegate trace
was collected.

## Rust verification

The 103 frozen successes join the existing grid in `check_v01.py`. Both
`check_v01.py --native` and `check_v02.py --native` now cover 151 positive and
24 negative configurations in debug and release: owned public API, native handles
(151/151) and Metal buffers (302/302), all byte-exact. That includes the Neural
Engine's saturated and rounded results. For the two reviewed CPU errors,
`native_cpu_rejects_empty_16_bit_integers_as_a_typed_error` checks that Corsairs
returns `Error::Native { operation: "run", type_name: "CoreAIRuntime.InferenceError" }`
and that GPU preference returns the empty `[0, 3]` result. Unit tests round-trip
each type's extremes and float64 NaN payload bits.

A builder bug during this work is worth recording. `np.ascontiguousarray`
promoted the rank-0 fixtures to shape `[1]`. b3 then fed a rank-1 tensor to a
rank-0 function, and Core AI trapped with SIGTRAP inside `CoreAIRuntime` rather
than throwing. Corsairs validates shapes against the descriptor before dispatch,
so it cannot reach that path.

## Float8

Added in v0.4.1: `DType::{Float8E4M3Fn, Float8E5M2}` with the
`Float8E4M3Fn` and `Float8E5M2` element types. Both preserve every encoding in
storage and provide an exact `to_f32` and a round-to-nearest-even `from_f32`
that match ml_dtypes:

| Type | Layout | Largest finite | Overflow | NaN |
| --- | --- | --- | --- | --- |
| `Float8E4M3Fn` | 4 exponent bits (bias 7), 3 fraction bits, no infinity | 448 | NaN (`0x7f`/`0xff`) | only `0x7f`/`0xff` |
| `Float8E5M2` | 5 exponent bits (bias 15), 2 fraction bits, IEEE-like | 57344 | ±infinity (`0x7c`/`0xfc`) | `0x7d`–`0x7f`, `0xfd`–`0xff` |

At the top of the range, ties round to even: 464 narrows to 448 in E4M3FN, and
61440 narrows to infinity in E5M2. `from_f32` maps every NaN to the canonical NaN
of its sign (`0x7f` and `0x7e` respectively), as ml_dtypes does.

[`check_float8.py`](../scripts/check_float8.py) compares Rust with pinned
ml_dtypes 0.6.0 in debug and release, without running Core AI
([report](evidence/v0.4/float8-conversion.json)). It widens all 256 encodings of
each type and narrows 1,002,151 unique binary32 inputs: every representable
value, every rounding midpoint with its binary32 neighbors, the exact
max/overflow ties (±464 and ±61440) with their neighbors, overflow boundaries,
specials and one million seeded random bit patterns (3,729 NaN). It found 0
mismatches. A sanity comparison of E4M3FN output against E5M2 expectations
reports 567,920 differences, so the comparison does detect errors.

[`fixtures/parity-v04/float8`](../fixtures/parity-v04/float8/README.md) adds
`double`, `scalar`, `empty`, `transpose` (raw encodings including NaN and E5M2
infinity) and `edges` (overflow and subnormal doubling) for each type. All 30
b3 configurations on CPU-only, GPU-preferred and Neural Engine-preferred options
match ml_dtypes arithmetic exactly, with no backend difference to review. b3
reports these dtypes as `float8e4m3fn` and `float8e5m2`; the reference runner
accepts exactly those two aliases. With these goldens, the Rust grids cover 181
positive configurations: native handles 181/181 and Metal buffers 362/362 in
debug and release, plus the full public-API grid and stress.
