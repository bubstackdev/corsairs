# Persistent Metal ownership

The development API owns a persistent `MetalQueue` and Core AI compute stream. `MetalBuffer` keeps shared Metal storage, while `MetalValue` retains a read-only input/output view suitable for another encoded call. Clones share backing storage. They do not make immutable snapshots.

```rust,no_run
use corsairs::{DType, Function, MetalBufferMap, MetalValueMap, Runtime, Tensor};

fn example(runtime: &Runtime, function: &Function) -> Result<(), corsairs::Error> {
    let queue = runtime.metal_queue().wait()?;
    let input = queue.upload(Tensor::from_vec([2, 3], vec![1f32; 6])?).wait()?;
    let output = queue.buffer(DType::Float32, vec![2, 3]).wait()?;
    let result = function.encode(
        &queue,
        MetalValueMap::from([("x", input)]),
        MetalBufferMap::new(),
        MetalBufferMap::from([("y", output)]),
    ).wait()?;
    let host = result.outputs.get("y").unwrap().download().wait()?;
    assert_eq!(host.to_vec::<f32>()?, vec![2.; 6]);
    Ok(())
}
```

`buffer` zero-initializes its logical storage. `upload` copies a checked owned tensor once. `write` and `download` run after queue completion; no safe raw host mapping is exposed. Automatic output values can feed the next `Function::encode` through `MetalValueMap`, without a Rust payload round trip. Explicitly bound outputs also appear in `MetalRunResult.outputs`; `states` returns the supplied `MetalBufferMap` updated in place.

The initial implementation fences each inference and checks throwing readiness for all bound states/outputs and captured automatic outputs. This preserves queue/resource ownership but limits pipelining. `MetalQueue::fence` awaits the Core AI stream and then commits/waits a command buffer on the same application queue. A stream-only fence would not establish completion of unrelated application commands. If completion cannot be established after encode, the process aborts rather than releasing potentially borrowed native storage. Ordinary native encode/readiness errors are returned after the work is fenced.

## Foreign objects and application kernels

Unsafe `Runtime::import_metal_queue` and `MetalQueue::import_buffer` retain the supplied object immediately, before submitting a worker request. The pointer must be a valid Metal protocol object for that call. A dropped future still owns its retained import until the request completes.

Imports check exact device identity, shared storage mode, byte extent, offset and scalar alignment. The imported logical bytes must have valid initialized scalar encodings, including zero/one boolean bytes. Backing storage must remain mapped, initialized and nonpurgeable until every retained library import/view and queued job is gone. Retaining an MTLBuffer does not prevent Empty/Volatile purgeability or keep externally allocated no-copy memory alive: the caller must never discard that storage or free/invalidate its backing during this lifetime. External submissions and CPU mappings must be coordinated with library operations. Different Metal objects that alias the same heap/suballocation are excluded by the unsafe contract. Reimporting the same object is supported: mutable input/state/output overlap checks use the underlying object identity and byte ranges, including across duplicate imports.

Unsafe `export_queue` and `export_buffer` return `MetalObject`, which owns an additional Objective-C reference and retains its Rust queue/runtime/buffer owner. `as_raw` borrows that object pointer while the guard lives. This allows application Metal code or an optional external adapter to use the persistent queue and buffers. External commands must retain their resources and respect logical buffer offsets, scalar encodings, bounds, submission order, and synchronization. Backing must remain mapped, initialized and nonpurgeable for all retained library owners/jobs, including after the exported guard drops. The guard alone does not prevent racing external GPU writes, purgeability changes or invalidation of no-copy memory.

## Supported boundary and validation

Every public request retains its function/model, queue, input views, mutable bindings and storage until fence/readiness, even when its future is dropped. Native records stay on the session worker. Captured outputs retain deduplicated backing-buffer origins so mutable overlap checks remain conservative without exponential reference growth. All output IDs are reserved before committing returned values to the native store. Store destruction releases encoded values, buffers, and queues before the framework handle.

Explicit state/output bindings currently require fully fixed descriptor shapes. A wildcard output can use automatic allocation and receives its concrete shape through readiness. Input rank, fixed dimensions, dtype, element/byte count, storage limits and names are validated. Downloads share the checked nonnegative-stride packing code with native tensor handles; negative strides remain unsupported. Managed/private storage needs separate synchronization support and is rejected.

The [ABI investigation](metal-abi.md) links independent compiler and standalone native proof evidence. The production [core matrix](evidence/v0.2-core/checks-metal.json) passed 64 Metal configurations in each of debug/release, covering CPU-only/GPU-preferred, automatic/explicit outputs, the five public dtypes, scalar/empty tensors, and repeated state updates. [Native lifecycle execution](evidence/v0.2-lifecycle-native-observation.json) passed all four ignored tests, including `native_metal_import_reuse_abandoned_futures_and_cleanup`: retained import/export, 100 reused calls, chaining, overlap/extent rejection, abandoned jobs, and return to zero native Metal stores. [Krea Metal execution](evidence/v0.2-krea-metal-observation.json) matched its recorded reference hashes using one persistent queue and reused bound outputs. These are host/fixture results; the final source/build identities are recorded with their associated reports.

The additional application-side kernel proof, [MetalApplicationKernel.m](../experiments/c/MetalApplicationKernel.m) and [metal_app_kernel.rs](../experiments/rust/metal_app_kernel.rs), passed a [native release observation](evidence/v0.2-metal-app-kernel-native.json), exit 0 with complete coverage. An application kernel scaled the input by three using the exported queue/buffer; immediately before the public queue fence its command status was 2 (committed), and afterward it was 4 (completed). Downloaded input matched 3× and the following Core AI x+x call matched 6×, without a host write after the application kernel. The [initial build manifest](evidence/v0.2-metal-app/release-initial-build.json) pins that executable, helper and production sources. This establishes ordering for this shared-buffer, same-queue fixture, not arbitrary cross-queue synchronization or a performance benefit.

[build_metal_app.py](../scripts/build_metal_app.py) creates the pinned executable/helper without running native work. The helper is development evidence and is never loaded by the production library. After the initial passing observation, its release function was strengthened to wait for command completion on early-error cleanup as well as the successful path; the [original helper](evidence/v0.2-metal-app/MetalApplicationKernel-initial.m) and passing manifest remain retained. The [drain revision build](evidence/v0.2-metal-app/release-drain-build.json) pins the revised helper with the unchanged original Rust executable. Its separate [native observation](evidence/v0.2-metal-app-kernel-drain-native.json) also passed exit 0 with complete coverage, status 2→4 and exact 3×/6× values. This rerun exercised its normal path; early-error cleanup is additionally established by the explicit wait in the helper's release function, without an injected GPU-failure test.
