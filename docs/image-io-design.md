# Image and pixel-buffer I/O design (v0.5)

Recorded 2026-10-18 on macOS 27.0.1 (26A434), Xcode/SDK 27 (Swift 6.4), device
architecture `h17c`, against Corsairs 0.4.1 and the pinned `coreai-core 1.0.0b3`.

Status: design and calibration only. No production binding exists yet; 0.4.1
still fails `load_function` on any image signature (`unsupported: non-tensor
value x`). A safe binding is feasible for three packed formats. Planar 4:2:0
must be rejected before dispatch, because Core AI traps the process on it.

## Findings

| Question | Answer |
| --- | --- |
| Formats b3 can author | `FourCC` enum: `RGB24`, `ARGB32`, `BGRA32`, `YpCbCr8420Planar`, `Unknown` |
| Formats that execute | `RGB24`, `ARGB32`, `BGRA32` (inputs and outputs, every backend) |
| Planar `YpCbCr8420Planar` | Image inputs trap (SIGTRAP, `CoreAIRuntime/ImageUtils.swift:91`); `tensor_to_image` throws |
| Image outputs | Yes. Without a view, Core AI allocates an IOSurface-backed buffer; with a caller view, it writes the view and returns no value |
| IOSurface required | No. Memory-backed inputs and output views are byte-exact on `run` and `encode` |
| Compute preferences | CPU-only, GPU- and Neural Engine-preferred: image conversion is byte-exact on all three |
| Row padding | Every buffer was padded: 4-pixel rows are 64 bytes (32-bit) or 192 bytes (RGB24). Core AI honors `bytesPerRow` |
| Validation | Wrong format and wrong size throw `CoreAIError` (`Invalid value`) before any trap, on every backend |

### Pixel formats and OSTypes

`ImageDescriptor.pixelFormatType` is the CoreVideo OSType. The b3 attribute,
CoreVideo constant and asset summary text agree:

| b3 `FourCC` | MLIR attribute | OSType | CoreVideo constant | `image_to_tensor` shape (uint8) | Asset summary `type_name` |
| --- | --- | --- | --- | --- | --- |
| `RGB24` | `k24RGB` | `0x00000018` (24) | `kCVPixelFormatType_24RGB` | `[H, W, 3]` | `Image (4 × 2, 24RGB)` |
| `ARGB32` | `k32ARGB` | `0x00000020` (32) | `kCVPixelFormatType_32ARGB` | `[H, W, 4]` | `Image (4 × 2, 32ARGB)` |
| `BGRA32` | `k32BGRA` | `'BGRA'` (1111970369) | `kCVPixelFormatType_32BGRA` | `[H, W, 4]` | `Image (4 × 2, 32BGRA)` |
| `YpCbCr8420Planar` | `k420YpCbCr8Planar` | `'y420'` (2033463856) | `kCVPixelFormatType_420YpCbCr8Planar` | `[H·W + 2·(H/2)·(W/2)]` | `Image (4 × 2, 420YpCbCr8Planar)` |
| `Unknown` | `kUnknown` | 0 | none | `[H·W]` | not authored to an asset |

The tensor is the pixel memory, row by row without padding, in the format's own
byte order. ARGB32 gives A, R, G, B and BGRA32 gives B, G, R, A. No conversion
or normalization happens. The summary text prints width before height. The
public `ImageType` facade takes only the enum. `FourCCAttr.get_raw` builds
attributes such as `"L008"` and `"RGfA"`, but no raw-FourCC image was authored.
`ImageConstraints(CVPixelBuffer, rowAlignmentsPerPlane: [64])` is accepted, and
default CoreVideo buffers satisfy it ([authoring record](evidence/v0.5/image-swift-oracle.json),
`models_manifest`).

### Run and encode behavior

[`ImageReference.swift`](../experiments/swift/ImageReference.swift) runs 25 tiny
models (`to_tensor`, `from_tensor`, `identity`, a `255 − x` `invert`,
row-aligned and 3×5/16×16 variants, plus a tensor-only `uint8` control). Each
runs under all three preferences, through both `run(inputs:outputViews:)` and
`ComputeStream` `encode`, with IOSurface-backed or memory-backed buffers, with
`CVReadOnlyPixelBuffer` or `CVMutablePixelBuffer` inputs, and with or without
caller output views ([oracle](evidence/v0.5/image-swift-oracle.json)):

| Format | Exact | Inexact | Rejected before execution | Trapped |
| --- | --- | --- | --- | --- |
| RGB24, ARGB32, BGRA32 (each) | 85 | 8 (`invert`, Neural Engine) | 30 | 0 |
| YpCbCr8420Planar | 0 | 0 | 30 (+18 `tensor_to_image` throws) | 75 of 75 isolated cases |
| `uint8` tensor control | 5 | 3 (Neural Engine) | — | 0 |

- Inexact results come only from `255 − x` under Neural Engine preference: the
  output is all 255. The tensor-only control does the same, so this is backend
  `uint8` arithmetic, not image I/O. Every identity and conversion is exact on
  every backend. Image fixtures should avoid arithmetic, or treat it as a
  reviewed backend digest.
- Caller output views: `Outputs.count` is 0, `remove` returns nil, and the view
  holds the exact bytes. This holds for `MutableViews` and for
  `AsyncMutableViews`, memory-backed or IOSurface-backed.
- Each trap was confirmed in a fresh process per backend. All 75 combinations
  exited with SIGTRAP: `run`/`encode`, IOSurface/memory, read-only/mutable
  wrapper, 2×4 and 16×16. `CoreAIRuntime` imports only `CVPixelBufferGetBaseAddress`
  among the CoreVideo base-address APIs, never a per-plane accessor. For a planar
  buffer that pointer is the `CVPlanarPixelBufferInfo` header.
- A 5,000-iteration image-in/image-out soak (fresh input and output view each
  iteration) stays exact. RSS grew by 240 KiB on CPU, 128 KiB on GPU and 0 on
  Neural Engine after warmup. A [20,000-iteration CPU soak](evidence/v0.5/image-soak-cpu-20000.json)
  stays between 12,336 and 12,352 KiB from iteration 6,000 to 20,000.

### b3 runtime as a second reference

b3's `_PixelBuffer` turns every PIL input (`RGB`, `RGBA`, `L`) into a 32BGRA
buffer. RGB and L get alpha 255, and R and B are swapped into BGRA order. Images
come back as PIL images, decoded as BGRA for every 32-bit format. So b3 can feed
only BGRA32 inputs, and it misreads ARGB32 outputs. Tensor `[1,4,7,10]` read as
A, R, G, B comes back as PIL RGBA `[7,4,1,10]`. Its runtime confirms that
RGB24/ARGB32/planar models reject its BGRA input, and that planar
`tensor_to_image` throws ([b3 runs](evidence/v0.5/image-b3-runtime.json)).
Wherever the inputs coincide, after b3's documented swizzles, b3 and the Swift
oracle agree on 27 of 27 cases, including the Neural Engine `invert` bytes.
The 30 RGB24/ARGB32 RGBA-mode runs are not comparable ([differential](evidence/v0.5/image-differential.json)).

## Swift ABI

Every lowering below comes from `-emit-ir` of an `@inline(never)` wrapper. Each
symbol is exported by the SDK `.tbd` named
([calibration](evidence/v0.5/image-abi-calibration.json): 35 symbols, none
missing from the IR, none unexported). VWT indices are the ones Corsairs already
uses for NDArray descriptors.

### Descriptors (`Function::descriptor`)

`inputDescriptor(of:)`/`outputDescriptor(of:)`/`stateDescriptor(of:)` already
return `Optional<InferenceValue.Descriptor>` into `inspect_tensor`. The image
case follows the same sequence as `ndArray`:

| Step | Lowering |
| --- | --- |
| Case test | VWT `GetEnumTag` (11) vs the `i32` global `$s13CoreAIRuntime14InferenceValueV10DescriptorO5imageyAeA05ImageE0VcAEmFWC` |
| Payload | VWT `DestructiveProjectEnumData` (12), then `ImageDescriptor` (`$s13CoreAIRuntime15ImageDescriptorVMa`) `InitializeWithTake` (4) |
| `width`, `height` | `swiftcc i64 (ptr swiftself)`: `…ImageDescriptorV5widthSivg`, `…V6heightSivg` |
| `pixelFormatType` | `swiftcc i32 (ptr swiftself)`: `…V15pixelFormatTypes6UInt32Vvg`. The result is in w0, so Rust must truncate x0 to `u32` |

### CoreVideo C API (plain C, `CoreVideo.tbd`)

`CVPixelBufferCreate(ptr allocator, i64 w, i64 h, i32 format, ptr attrs, ptr *out) -> i32`
returns a +1 buffer. With `attrs = NULL` the buffer is memory-backed, which is
sufficient (above), so no CFDictionary is needed. `Lock`/`UnlockBaseAddress(ptr, i64 flags)`
(1 = read-only), `GetBaseAddress`, `GetBytesPerRow`, `GetWidth`, `GetHeight`,
`GetPixelFormatType -> i32`, `IsPlanar -> u8`, `GetDataSize` and `GetIOSurface`
are all plain `ptr`/`i64` signatures. Corsairs adds `CFRetain`/`CFRelease` for
its own reference. Open CoreVideo (and CoreFoundation) explicitly at their fixed
framework paths rather than relying on `dlsym` through CoreAI's dependency graph.

### Pixel-buffer values (phase 1: synchronous `run`)

| Operation | Symbol | Lowering and ownership |
| --- | --- | --- |
| Wrap | `$s9CoreVideo20CVMutablePixelBufferV06unsafeE0ACSo11CVBufferRefan_tcfC` | `swiftcc void (sret x8, ptr x0)`. x0 is consumed (`an_` = `sending __owned`). Storage is sized by `$s9CoreVideo20CVMutablePixelBufferVMa`'s VWT. Destroy (1) releases it |
| Input | `$s13CoreAIRuntime17InferenceFunctionV6InputsV6insert_3foryx_SStAA0C5ValueV17ViewRepresentableRzRi_zlF` | `(x0 ptr→borrowed T, x1/x2 String, x3 T metadata, x4 witness table, x20 &mut Inputs)`. T = `CVMutablePixelBuffer`, WT = `$s9CoreVideo20CVMutablePixelBufferV0A9AIRuntime14InferenceValueV17ViewRepresentableADWP` (static, exported by CoreAIRuntime). Inputs borrows the value until it is destroyed |
| Output view | `$s13CoreAIRuntime17InferenceFunctionV12MutableViewsV6insert_3foryxz_SStAA0C5ValueV0E17ViewRepresentableRzRi_zlF` | `(x0 inout T, x1/x2 String, x3 metadata, x4 WT …V24MutableViewRepresentableADWP, x20 &mut MutableViews)` |
| Run | existing `InferenceFunction.run(inputs:states:outputViews:)` | unchanged |
| Read back | C API on Corsairs' own retained `CVPixelBuffer` | after native completion. `Outputs.remove` must return nil for that name |

Inserts take five argument registers, so phase 1 needs a `call_sync5`
helper (today `call_sync` passes three). Inputs can use the `CVMutablePixelBuffer`
struct: it conforms to `ViewRepresentable`, and the oracle shows it is
byte-exact as an input (`run_mutable_input`). Corsairs then never constructs the
`CVReadOnlyPixelBuffer` class.

### Calibrated, not needed in phase 1

- `InferenceValue.kind` (`sret Kind`, x20 borrowed). Compare against the
  `…KindO5imageyA2EmFWC` tag. `InferenceValue.pixelBuffer` is
  `(sret Optional<CVMutablePixelBuffer>, x20 consumed)`. These are needed only if
  Core AI ever returns an image despite a supplied view.
- `withUnsafeBuffer`: `(sret R, x0 closure, x1 context, x2 R metadata, x20 self, x21 error)`.
  The closure is `(sret R, x0 guaranteed CVPixelBuffer, x20 context, x21 error)`.
  The emitted R metadata is client-local foreign metadata (`$sSo11CVBufferRefaMa`,
  `linkonce_odr`), so Rust needs a second wrapper with an exported R before it
  could use this. Supplying output views avoids it.
- Stream path: `AsyncValue(CVReadOnlyPixelBuffer)` and
  `CVReadOnlyPixelBuffer(unsafeBuffer:)` are emitted as `swift_allocObject`
  (size `u32` at metadata+48, alignment mask `u16` at +52) followed by the
  initializing `fc` (x0 consumed, x20 object). `AsyncMutableValue(CVMutablePixelBuffer)`
  is `fC (sret, x0 consumed storage)`. `AsyncValue.pixelBuffer` is an async
  getter (`…CSgvgTu`) returning one word.

## Proposed v0.5 API

The design is additive where it can be. Tensors keep `TensorMap`, and images
travel in a parallel map. One `enum Value { Tensor, Image }` would break every
`run` caller, `TensorMap` user and `RunResult.outputs` reader; it is not proposed.

```rust,ignore
/// Pixel formats verified end to end. Bytes are the CoreVideo memory order.
#[non_exhaustive]
pub enum PixelFormat { Rgb24, Argb32, Bgra32 }
impl PixelFormat {
    pub const fn os_type(self) -> u32;               // 24, 32, 'BGRA'
    pub const fn from_os_type(value: u32) -> Option<Self>;
    pub const fn bytes_per_pixel(self) -> usize;     // 3, 4, 4
}

/// An owned packed image. Rows may be padded on input; outputs are tight.
pub struct Image { /* format, width, height, bytes_per_row, bytes */ }
impl Image {
    pub fn new(format: PixelFormat, width: usize, height: usize, bytes: Vec<u8>) -> Result<Self, Error>;
    pub fn with_bytes_per_row(format: PixelFormat, width: usize, height: usize,
                              bytes_per_row: usize, bytes: Vec<u8>) -> Result<Self, Error>;
    pub fn format(&self) -> PixelFormat;  // + width(), height(), bytes_per_row()
    pub fn row(&self, y: usize) -> &[u8];
    pub fn as_bytes(&self) -> &[u8];
    pub fn into_bytes(self) -> Vec<u8>;
}
pub struct ImageMap(/* BTreeMap<String, Image>, same API as TensorMap */);

#[non_exhaustive]
pub struct ImageDescriptor { pub name: String, pub width: usize, pub height: usize, pub pixel_format_type: u32 }
impl ImageDescriptor { pub fn format(&self) -> Option<PixelFormat>; }

#[non_exhaustive]                       // breaking: was exhaustive
pub struct FunctionDescriptor { /* name, inputs, outputs, states, */
    pub image_inputs: Vec<ImageDescriptor>, pub image_outputs: Vec<ImageDescriptor> }

#[non_exhaustive]                       // breaking: was exhaustive
pub struct RunResult { pub outputs: TensorMap, pub states: TensorMap, pub images: ImageMap }

impl Function {
    pub fn run(&self, inputs: TensorMap, states: TensorMap) -> Task<RunResult>;  // unchanged signature
    pub fn run_with_images(&self, inputs: TensorMap, images: ImageMap, states: TensorMap) -> Task<RunResult>;
}
```

- `run` is `run_with_images` with an empty `ImageMap`. A function with image
  outputs and tensor inputs works through `run` unchanged, and its images appear
  in `RunResult::images`. Missing or unexpected images reuse `MissingTensor`/`UnexpectedTensor`
  with kind `"image input"`. A wrong format or size is a `DescriptorMismatch`. A
  bad stride or byte length is a new `Error::InvalidImage(String)`; `Error` is
  already `#[non_exhaustive]`.
- Descriptors report image values in separate vectors, so existing
  `inputs`/`outputs` iteration still sees only tensors. A function whose image
  format is planar or unknown still loads: `format()` is `None` and the raw
  OSType stays visible. Running it returns `Unsupported` before dispatch.
- `TensorHandle` runs, `Function::encode` (Metal bindings), states and
  `FunctionBatch` reject image signatures with `Unsupported` in 0.5.0.
- Breaking changes: `FunctionDescriptor` and `RunResult` gain fields and become
  `#[non_exhaustive]`, which breaks struct literals and exhaustive destructuring.
  `load_function` now succeeds on image signatures instead of failing with
  `Unsupported`. Signatures of existing methods do not change.

### Paths and safety rules

| Phase | Path | Scope |
| --- | --- | --- |
| 1a (0.5.0) | Owned, CPU-only | `run`/`run_with_images` through `Inputs`/`MutableViews` and Corsairs-allocated memory-backed views |
| 1b (0.5.0 if qualified) | Owned, GPU/Neural Engine | the existing persistent stream needs `AsyncValue`/`AsyncMutableValue` pixel-buffer constructors (each needs its own IR wrapper first). The plain-`run` route was also exact on these backends, as a measured fallback. Unqualified, accelerated image runs return `Unsupported` |
| 2 (later) | Native/Metal | an `ImageHandle` that keeps a `CVPixelBuffer` for chaining, unsafe `CVPixelBuffer` import/export, `MTLTexture`-backed images (`ImageConstraints(MTLTexture)`, not exercised here) |

Rules the binding must enforce before dispatch:

- The descriptor OSType must be `RGB24`, `ARGB32` or `BGRA32`. Anything else
  returns `Unsupported` before any buffer is created. This is the only defense
  against the planar trap.
- Check name, format, width and height against the descriptor. Check that
  `bytes_per_row ≥ width·bpp`, then compute
  `bytes_per_row·(height−1) + width·bpp` with checked arithmetic, within the
  same 4 GiB CPU and 2 GiB GPU limits as tensors.
- After `CVPixelBufferCreate`, require status 0, a non-planar buffer, the
  requested format and size, `bytesPerRow ≥ width·bpp` and
  `bytesPerRow·height ≤ dataSize`. Copy row by row under a balanced lock and
  unlock.
- Destroy the `Inputs`/`MutableViews` containers before their pixel-buffer
  values, matching the NDArray ordering in `owned.rs`. Release Corsairs' own
  `CFRetain` last.
- After completion, require `Outputs.remove(view name) == nil`. Keep the
  existing undescribed-output check. Wrap creation and execution in the
  autorelease `Pool`, and soak the Rust path for RSS growth (10,000 cycles).

## Verification plan (`fixtures/parity-v05/images`)

1. `scripts/reference/build_image_fixtures.py` (from
   [`experiments/python/image_models.py`](../experiments/python/image_models.py))
   authors `to_tensor`, `from_tensor`, `identity`, odd-size and row-aligned cases
   for the three packed formats. It writes `suite.json` with tight image payloads
   (`{"image": {format, width, height, file, sha256}}`), expected bytes, and
   negatives: wrong format, wrong size, missing image, planar signature (expected
   Rust `Unsupported`, never executed).
2. The Swift oracle freezes per-backend goldens, the primary source for all three
   formats. b3 (`run_suite.py` with an image extension, `--backends cpu
   gpu-preferred neural-engine-preferred`) freezes goldens for its comparable
   subset: BGRA32 inputs and all image outputs, decoded under the swizzle rules
   above. The freezer reviews the ARGB32 decode rule and any arithmetic case
   explicitly, as it does for `float_edges`.
3. A Rust driver (`experiments/rust/image_parity.rs`) checks every case and
   backend against the frozen goldens. It adds the soak and the drop/cancel
   cycles. If the set joins `scripts/check_v01.py` `GOLDEN_SETS`, its backends,
   successes, reviewed errors and negatives are pinned there, and `test_grid.py`
   keeps passing.

Reproduce this record:

```sh
python3.12 -I -B experiments/python/image_models.py MODELS_DIR
python3 -B experiments/python/image_oracle.py MODELS_DIR docs/evidence/v0.5/image-swift-oracle.json
python3 -B experiments/python/image_calibration.py docs/evidence/v0.5/image-abi-calibration.json
python3.12 -I -B experiments/python/image_b3_run.py MODELS_DIR docs/evidence/v0.5/image-b3-runtime.json
python3 -B experiments/python/image_differential.py docs/evidence/v0.5/image-swift-oracle.json \
    docs/evidence/v0.5/image-b3-runtime.json docs/evidence/v0.5/image-differential.json
```

## Not covered

- Planar and bi-planar YCbCr, `Unknown`, and raw FourCCs. They trap or were not
  authored; descriptors expose them, and runs reject them.
- Image states, dynamic image sizes (descriptors carry fixed width/height),
  `MTLTexture` backing, and IOSurface or `kCVPixelBufferBytesPerRowAlignmentKey`
  controls.
- Color conversion, normalization or channel swizzling. Corsairs is byte-exact
  in CoreVideo memory order; b3's PIL conversions are a reference convenience,
  not API.
- Large images. Only 2×4, 3×5 and 16×16 were run; GPU/Neural Engine size
  qualification belongs to phase 1b.
