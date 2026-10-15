# Native tensor handles

The development API provides `TensorHandle` alongside owned `Tensor` values. A handle retains one native NDArray on its runtime's worker. Cloning retains that storage; it does not clone a Rust byte buffer. Metadata access does not download the payload.

```rust,no_run
use corsairs::{Function, Runtime, Tensor, TensorHandleMap};

async fn chain(
    runtime: &Runtime,
    first: &Function,
    second: &Function,
    input: Tensor,
) -> Result<Tensor, corsairs::Error> {
    let x = runtime.upload(input).await?;
    let first_outputs = first.run_native(
        TensorHandleMap::from([("x", x)]),
        TensorHandleMap::new(),
    ).await?;
    let y = first_outputs.outputs.get("y").expect("model returns y").clone();
    let second_outputs = second.run_native(
        TensorHandleMap::from([("x", y)]),
        TensorHandleMap::new(),
    ).await?;
    second_outputs.outputs.get("y").expect("model returns y").download().await
}
```

All functions and handles in a native call must belong to the same runtime. A foreign handle returns an error before native access. Pending jobs retain their functions and handles through true native completion, including when a future is dropped. Final handle destruction queues native release on its owner. A native output remains retained even after the intermediate result map is dropped.

`download()` packs nonnegative native strides into contiguous row-major host storage, with checked shape multiplication, storage extent, byte offsets, and the existing rank/size limits. Negative strides return an explicit unsupported error until their storage-origin contract is established. Scalar, empty, padded, transposed, and broadcast packing have focused unit coverage. Native chaining avoids Rust host payload copies; it does not promise that Core AI avoids its own device copies.

State handles mutate in place, and clones observe subsequent changes. Failed native inference may leave state changed; rollback is not promised. Mutable state cannot overlap an input or another state handle. Conservative possible-alias provenance follows source handles and treats all inference-produced storage as potentially shared, including constants from unrelated calls or models. This can reject physically separate inference outputs. An explicit download and upload creates an independent mutable allocation. Independently uploaded states work without that restriction, and immutable inputs may share handles.

[Native validation](evidence/v0.2-native-handles.json) covers two-function chaining, clone retention, cross-runtime rejection, shared-state updates, rejected mutable aliases, and abandoned requests returning the native tensor store to zero. These small fixtures do not establish large-model performance; the [Krea acceptance workload](v0.2-krea.md) measures that separately.

The [debug and release core gate](evidence/v0.2-core/checks-pre-metal.json) additionally matches all 32 frozen Python configurations using native storage, covering all five dtypes, scalar and empty tensors, arithmetic and shape operations, and three-step state updates. Dynamic owned and native calls each pass 24 concrete-shape executions and 18 invalid-signature cases per profile. Reproduce with `python3 -B scripts/check_v02.py --native`; preparation without `--native` compiles and pins the drivers without claiming execution.

The [final core run](evidence/v0.2/final-core/checks.json) repeats those checks on the completed BF16/drain source. The distinct sixth dtype, [bfloat16](bfloat16-abi.md), has its own independent Swift comparisons across owned tensors, native handles, state, dynamic calls and Metal storage. Use [transitive drain](runtime-drain.md) after dropping stage resources when a single queue marker is insufficient.
