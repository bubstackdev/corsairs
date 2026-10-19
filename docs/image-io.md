# Image and pixel-buffer I/O (v0.5)

Recorded 2026-10-18 on macOS 27.0.1 (26A434), Xcode/SDK 27 (Swift 6.4), device
architecture `h17c`, against the pinned `coreai-core 1.0.0b3`. Targets v0.5.0;
the crate version is unchanged.

Functions whose inputs or outputs are packed `24RGB`, `32ARGB` or `32BGRA`
images now load and run on CPU-only, GPU-preferred and Neural Engine-preferred
compute. Corsairs is byte-exact against frozen goldens from the Swift oracle and
b3 on every case and backend. Planar 4:2:0 traps Core AI, so Corsairs describes
it but rejects every run before creating a buffer. 0.4.1 failed `load_function`
on any image signature (`unsupported: non-tensor value x`).

## What is exposed

```rust,ignore
#[non_exhaustive] pub enum PixelFormat { Rgb24, Argb32, Bgra32 }
impl PixelFormat {
    pub const fn os_type(self) -> u32;                  // 24, 32, 'BGRA' (1111970369)
    pub const fn from_os_type(value: u32) -> Option<Self>;
    pub const fn bytes_per_pixel(self) -> usize;        // 3, 4, 4
    pub const fn name(self) -> &'static str;            // "24RGB", "32ARGB", "32BGRA"
}
pub struct Image;   // new, with_bytes_per_row, zeros, format, width, height,
                    // bytes_per_row, row, as_bytes, to_tight_bytes, into_bytes
pub struct ImageMap; // same API as TensorMap
#[non_exhaustive] pub struct ImageDescriptor { pub name: String, pub width: usize,
                                               pub height: usize, pub pixel_format_type: u32 }
impl ImageDescriptor { pub fn format(&self) -> Option<PixelFormat>; }

FunctionDescriptor { .., pub image_inputs: Vec<ImageDescriptor>, pub image_outputs: Vec<ImageDescriptor> }
RunResult { .., pub images: ImageMap }
Function::run_with_images(inputs: TensorMap, images: ImageMap, states: TensorMap) -> Task<RunResult>
Error::InvalidImage(String)
```

- Bytes are CoreVideo memory order: R,G,B for 24RGB; A,R,G,B for 32ARGB;
  B,G,R,A for 32BGRA. Nothing is converted, normalized or swizzled.
- `Image::new` takes tight rows. `Image::with_bytes_per_row` accepts padded
  rows and requires exactly `bytes_per_row * height` bytes; padding is never
  read. Images in `RunResult::images` always have tight rows.
- `Function::run(inputs, states)` keeps its signature and is
  `run_with_images` with an empty map. A function with tensor inputs and image
  outputs therefore works through `run`, and its images arrive in
  `RunResult::images`.
- Descriptors keep tensors and images apart: `inputs`/`outputs` still list only
  tensors. A function whose image format is not a `PixelFormat` (planar,
  `Unknown`, raw FourCC) loads; `format()` is `None`, the raw OSType is kept,
  and every run returns `Unsupported` before any CVPixelBuffer exists.
- Errors before dispatch: a missing or unexpected image is `MissingTensor` /
  `UnexpectedTensor` with kind `"image input"`; a wrong format or size is
  `DescriptorMismatch`; an inconsistent size, stride or byte length is
  `InvalidImage` from the `Image` constructors. Storage is limited to 4 GiB per
  image, like tensors.
- `run_native` (tensor handles) and `encode` (Metal) reject image signatures
  with `Unsupported`. Functions loaded through `load_functions` support images
  like any other function. Image states fail `load_function` with
  `Unsupported`.
- The CLI accepts `--image NAME FORMAT WIDTHxHEIGHT FILE` (tight bytes) on
  `run` and `bench`; `inspect` prints `image_inputs`/`image_outputs`, and
  results include an `images` group.

### Breaking changes (v0.5)

- `FunctionDescriptor` and `RunResult` gain fields and become
  `#[non_exhaustive]`. Struct literals and exhaustive destructuring of either
  outside the crate no longer compile; field access is unchanged.
- `load_function` now succeeds on image signatures instead of returning
  `Unsupported`. Code that relied on that error to skip image models must check
  `descriptor().image_inputs`/`image_outputs` instead.
- `Error` gains `InvalidImage`; it was already `#[non_exhaustive]`.
- No existing method signature changes.

### Compute paths

| Compute | Path | Bound |
| --- | --- | --- |
| CPU-only | `run(inputs:states:outputViews:)` with `Inputs`/`MutableViews` | 4 GiB per image or tensor |
| GPU- and Neural Engine-preferred | the same plain `run`, not the persistent stream | fixed tensor shapes and at most 1 GiB per value, the stateful-GPU envelope |

Stateless tensor calls on accelerated compute use the persistent
`ComputeStream`; image calls do not, because the stream's pixel-buffer
`AsyncValue`/`AsyncMutableValue` constructors are not bound. The Swift oracle
measured plain `run` byte-exact on GPU and Neural Engine preference, and the
Rust results below confirm it. Image signatures on accelerated compute keep the
one-GiB fixed envelope already used for stateful GPU calls; larger or dynamic
signatures return `Unsupported`. Large images were not qualified.

## Binding evidence

Every Swift call comes from the `@inline(never)` wrappers in
[`ImageReference.swift`](../experiments/swift/ImageReference.swift), compiled
with `-emit-ir`. All 35 symbols are exported by the SDK `CoreAIRuntime` or
`CoreVideo` `.tbd` ([calibration](evidence/v0.5/image-abi-calibration.json)).
The binding needed no wrapper beyond those already calibrated.

| Step | Symbol | Lowering used |
| --- | --- | --- |
| Descriptor case | `$s13CoreAIRuntime14InferenceValueV10DescriptorO5imageyAeA05ImageE0VcAEmFWC` | `i32` tag compared with VWT `GetEnumTag` (11), then project (12) and `ImageDescriptor` (`…15ImageDescriptorVMa`) `InitializeWithTake` (4): the NDArray sequence |
| `width`, `height` | `…15ImageDescriptorV5widthSivg`, `…V6heightSivg` | `swiftcc i64 (ptr swiftself)` |
| `pixelFormatType` | `…V15pixelFormatTypes6UInt32Vvg` | `swiftcc i32 (ptr swiftself)`: only w0 is defined, so x0 is truncated to `u32` |
| Wrap | `$s9CoreVideo20CVMutablePixelBufferV06unsafeE0ACSo11CVBufferRefan_tcfC` | `swiftcc void (sret x8, ptr x0)`; x0 consumed (`sending`). Storage from `$s9CoreVideo20CVMutablePixelBufferVMa`'s VWT, destroyed with slot 1 |
| Input | `…InferenceFunctionV6InputsV6insert_3foryx_SStAA0C5ValueV17ViewRepresentableRzRi_zlF` | x0 borrowed `T*`, x1/x2 String, x3 `CVMutablePixelBuffer` metadata, x4 `…CVMutablePixelBufferV0A9AIRuntime14InferenceValueV17ViewRepresentableADWP`, x20 `Inputs` |
| Output view | `…MutableViewsV6insert_3foryxz_SStAA0C5ValueV0E17ViewRepresentableRzRi_zlF` | x0 inout `T*`, x1/x2 String, x3 metadata, x4 `…24MutableViewRepresentableADWP`, x20 `MutableViews` |
| Run | `InferenceFunction.run(inputs:states:outputViews:)` | unchanged |

The inserts take five argument registers; `arm64::call_sync5` is the new
helper (x0–x4, x20, no sret). Both inserts are declared
`@_lifetime(self: borrow value)` / `@_lifetime(self: &value)`, so each
`CVMutablePixelBuffer` lives in a fixed heap allocation that outlives its
container. `CVMutablePixelBuffer` is `~Copyable`; Corsairs never copies it, and
inputs use it instead of the `CVReadOnlyPixelBuffer` class (the oracle's
`run_mutable_input`).

CoreVideo is plain C, opened from
`/System/Library/Frameworks/CoreVideo.framework/Versions/A/CoreVideo`. Swift
cannot call `CVPixelBufferRetain`/`Release`, so
[`CoreVideoReference.c`](../experiments/c/CoreVideoReference.c) records every
C call's clang IR and checks its `CoreVideo.tbd` export
([C calibration](evidence/v0.5/image-corevideo-c-abi.json)):

| Call | Declaration |
| --- | --- |
| `CVPixelBufferCreate` | `i32 (ptr, i64, i64, i32, ptr, ptr)`; NULL allocator and attributes give a memory-backed +1 buffer |
| `CVPixelBufferLockBaseAddress`, `…Unlock…` | `i32 (ptr, i64)`; `kCVPixelBufferLock_ReadOnly` = 1 |
| `GetBaseAddress` / `GetBytesPerRow` / `GetWidth` / `GetHeight` / `GetDataSize` | `ptr (ptr)` / `i64 (ptr)` |
| `GetPixelFormatType` / `IsPlanar` | `i32 (ptr)` / `zeroext i8 (ptr)` |
| `CVPixelBufferRetain` / `Release` | `ptr (ptr)` / `void (ptr)` |

Ownership and order in `run_with_images`:

1. Reject any image descriptor whose OSType is not a verified packed format,
   then validate names, formats, sizes and storage. This is the only defense
   against the planar trap.
2. Per image input and per image output: `CVPixelBufferCreate` (+1, kept by
   Corsairs). Require status 0, non-planar, the requested format and size,
   `bytesPerRow ≥ width·bpp` and `bytesPerRow·height ≤ dataSize`. Inputs are
   copied row by row under a lock that a guard always unlocks with the same
   flags. `CVPixelBufferRetain` once more, then wrap; the wrapper consumes that
   reference.
3. Insert inputs into `Inputs` and outputs into the output `MutableViews`.
   Corsairs always supplies a view for every image output.
4. After completion, `Outputs.count` must be 0 for names Corsairs did not
   remove, which also rejects an image returned despite a view. Each view is
   read back under a read-only lock into tight rows, then checked against its
   descriptor.
5. Containers are declared after the buffers, so they drop first. Each image
   drops its Swift wrapper before Corsairs' own reference. An autorelease
   `Pool` is pushed first for image calls and drains last.

## Verification

[`fixtures/parity-v05/images`](../fixtures/parity-v05/images) holds 22 cases
authored by `build_image_fixtures.py` with b3: for each packed format,
`to_tensor` (2×4 and 3×5), `identity` (2×4 and 3×5), `from_tensor`,
`aligned_to_tensor` (64-byte row-alignment constraint) and `invert`
(`255 − x`), plus `mixed_bgra32` (an image and a tensor in, an image and a
tensor out). Inputs use the oracle's deterministic pattern. Seven negatives
cover planar 4:2:0 with and without an image (never executed), wrong format,
wrong size, transposed size, missing image and unexpected image.

| Step | Script | Result |
| --- | --- | --- |
| Swift oracle | `run_image_suite.py --source swift` | all 21 single-input cases on 3 backends; every completed oracle variant (IOSurface/memory input, read-only/mutable wrapper, with/without view, `encode`) agrees per case |
| b3 | `run_image_suite.py --source b3` | 10 comparable cases per backend (BGRA32 and tensor inputs); 12 RGB24/ARGB32-input cases per backend are not comparable because b3 always supplies 32BGRA |
| Freeze | `freeze_image_goldens.py` | 69 goldens; 27 confirmed by both references, 0 disagreements; 3 reviewed digests; `sha256.json` digests of all 142 fixture files |
| Rust | `scripts/check_images.py` | 123 runs, 30 checks, all byte-exact; [report](evidence/v0.5/image-parity.json) |

b3's comparable subset follows its documented conversions: a BGRA32 input is
fed as PIL RGBA with R and B swapped, every 32-bit output is decoded as BGRA
and un-swapped, and RGB24 outputs are unchanged.

The only goldens that differ from the analytic bytes are `invert` under Neural
Engine preference, for all three formats: every byte is 255. The freezer
accepts exactly those digests (`sha256(ff × 24)` for RGB24, `sha256(ff × 32)`
for the 32-bit formats). b3 and the oracle agree on BGRA32; a tensor-only
`uint8` control does the same, so this is backend `uint8` arithmetic, not image
I/O. Every conversion and identity is exact on every backend.

The Rust driver ([`image_parity.rs`](../experiments/rust/image_parity.rs)):

- Runs each image-input case twice: tight, and with 13 bytes of `0xEE` padding
  per row. Both match the golden. Tensor-only inputs use `Function::run`.
- Checks descriptors (names, OSTypes, sizes) against the suite. The planar
  descriptor reports `0x79343230` (`'y420'`) with `format() == None`.
- Checks that every negative returns its expected variant on every backend, that
  `run_native` and `encode` return `Unsupported`, and that a short stride fails
  `Image` construction with `InvalidImage`.
- Soaks 10,000 `BGRA32_identity` runs per backend with a fresh,
  iteration-dependent image each time. All outputs are exact. RSS growth from
  the 10% sample to the end: 208 KiB on CPU, 96 KiB on GPU preference and 0
  on Neural Engine preference.
- Drop/cancel: 100 abandoned and 100 cancelled requests per backend, then
  `drain` and a successful run. Every cancellation was prevented, and RSS
  changed by at most 208 KiB (CPU) across the cycle.

Before running anything, `scripts/check_images.py` verifies that the set is
the frozen one. It pins the digest of `sha256.json`, which the freezer writes
once and which covers every model file, payload, `suite.json`, both reference
results and `backend-goldens.json`. It checks each file against it, and that no
file was added or removed. It also checks `suite.json`'s payload digests, the
goldens' `suite_sha256` and `sources`, that each golden equals its references'
bytes, and that every unreviewed golden equals its `expected-*.bin`. A swapped
model or an edited input with a matching golden therefore fails the gate
(`scripts/reference/tests/test_image_fixtures.py`). It also pins the set's
shape (22 cases, 19 with image inputs, 7 negatives, 23 goldens per backend,
and the reviewed cases) and the full run grid. The set does not fit `check_v01.py`'s tensor grid, so it is not
in `GOLDEN_SETS`. A crate test, `native_images_round_trip_on_every_backend`,
covers padded input, `run` with image outputs and planar rejection under
`cargo test -- --include-ignored`.

A [100,000-iteration soak](evidence/v0.5/image-soak-rust-100000.json) per
backend (`--soak 100000 --drop 0`) is exact throughout. CPU RSS rises from
30,800 to 31,104 KiB by iteration 20,000 and stays there to 100,000; GPU
preference stays at 31,168 KiB throughout, and Neural Engine preference falls
from 31,168 to 31,072 KiB at iteration 60,000 and stays there. Calls take
about 21 µs. The Rust path
levels off like the Swift oracle's. The autorelease pool scoped around every
image call is kept; this record did not measure the path without it.

Reproduce (the reference scripts need the `.local` reference environment):

```sh
python3.12 -I -B scripts/reference/build_image_fixtures.py
python3 -B scripts/reference/run_image_suite.py --source swift
python3.12 -I -B scripts/reference/run_image_suite.py --source b3
python3 -B scripts/reference/freeze_image_goldens.py
python3 -B scripts/check_images.py --soak 10000 --drop 100
python3 -B experiments/python/image_c_calibration.py docs/evidence/v0.5/image-corevideo-c-abi.json
```

## Calibration findings (design phase)

| Question | Answer |
| --- | --- |
| Formats b3 can author | `FourCC` enum: `RGB24`, `ARGB32`, `BGRA32`, `YpCbCr8420Planar`, `Unknown` |
| Formats that execute | `RGB24`, `ARGB32`, `BGRA32` (inputs and outputs, every backend) |
| Planar `YpCbCr8420Planar` | Image inputs trap (SIGTRAP, `CoreAIRuntime/ImageUtils.swift:91`) in all 75 isolated cases; `tensor_to_image` throws |
| Image outputs | Without a view Core AI allocates an IOSurface buffer with padded rows (64 bytes for a 4-pixel 32-bit row); with a caller view it writes the view and returns no value |
| IOSurface required | No. Memory-backed inputs and views are byte-exact for `run` and `encode` |
| Validation | Wrong format and wrong size throw `CoreAIError` (`Invalid value`) before execution |

| b3 `FourCC` | OSType | CoreVideo constant | `image_to_tensor` (uint8) | Asset summary |
| --- | --- | --- | --- | --- |
| `RGB24` | 24 | `kCVPixelFormatType_24RGB` | `[H, W, 3]` | `Image (4 × 2, 24RGB)` |
| `ARGB32` | 32 | `kCVPixelFormatType_32ARGB` | `[H, W, 4]` | `Image (4 × 2, 32ARGB)` |
| `BGRA32` | `'BGRA'` (1111970369) | `kCVPixelFormatType_32BGRA` | `[H, W, 4]` | `Image (4 × 2, 32BGRA)` |
| `YpCbCr8420Planar` | `'y420'` (2033463856) | `kCVPixelFormatType_420YpCbCr8Planar` | `[H·W + 2·(H/2)·(W/2)]` | `Image (4 × 2, 420YpCbCr8Planar)` |

The tensor is the pixel memory without row padding, in the format's own byte
order; the summary prints width first. The oracle covered 25 models, all three
preferences, `run` and `encode`, IOSurface and memory buffers, both wrappers,
and with or without output views: 85 exact completions per packed format, 30
rejections and 0 traps. A Swift-side 20,000-iteration CPU soak stayed between
12,336 and 12,352 KiB ([oracle](evidence/v0.5/image-swift-oracle.json),
[b3](evidence/v0.5/image-b3-runtime.json),
[differential](evidence/v0.5/image-differential.json),
[soak](evidence/v0.5/image-soak-cpu-20000.json)). These are reproduced with
`experiments/python/image_{models,oracle,calibration,b3_run,differential}.py`.

Calibrated but unused: `InferenceValue.kind`/`.pixelBuffer` (needed only if
Core AI returned an image despite a view), `withUnsafeBuffer` (its `R`
metadata is client-local `linkonce_odr`), and the stream constructors
`AsyncValue(CVReadOnlyPixelBuffer)` (`swift_allocObject` + `fc`) and
`AsyncMutableValue(CVMutablePixelBuffer)` (`fC`, sret).

## Not covered

- Planar and bi-planar YCbCr, `Unknown` and raw FourCCs: described, never run.
- The persistent-stream path for images, `TensorHandle` chaining, Metal
  `encode`, `MTLTexture`-backed images, and unsafe CVPixelBuffer
  import/export (an `ImageHandle` for chaining is future work).
- Image states, dynamic image sizes, IOSurface backing and row-alignment
  controls. Corsairs always creates default memory-backed buffers.
- Colour conversion, normalization and channel swizzling.
- Large images. Only 2×4 and 3×5 (and the oracle's 16×16) were run; GPU and
  Neural Engine size limits beyond the fixed one-GiB envelope are unmeasured.
- Arithmetic on the Neural Engine is not exact for `uint8` (`255 − x`); compare
  with the same compute configuration.
