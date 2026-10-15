# Per-model load options

The development API adds `LoadOptions` for each model load. The existing `load_model(path, Compute)` call preserves the SDK's constructor defaults. To provide an explicit hint:

```rust,no_run
use corsairs::{Compute, LoadOptions, Runtime};

fn load(runtime: &Runtime) -> Result<corsairs::Model, corsairs::Error> {
    let options = LoadOptions::new(Compute::GpuPreferred)
        .with_expect_frequent_reshapes(true);
    let model = runtime.load_model_with_options("decoder.aimodel", options).wait()?;
    assert_eq!(model.load_options(), options);
    Ok(model)
}
```

`expect_frequent_reshapes` is an `Option<bool>`: `None` leaves the SDK's value untouched, `Some(true)` enables the hint, and `Some(false)` explicitly disables it. `with_expect_frequent_reshapes(bool)` supplies the override. `LoadOptions::default()` and `LoadOptions::from(Compute)` omit it. Each `Model` retains its requested options; `Model::load_options()` does not claim which internal compilation strategy or device Core AI ultimately selected. GPU preference still permits fallback.

The CLI accepts the same choice for `inspect`, `run`, and `bench`:

```sh
cargo run --offline -p corsairs --bin corsairs -- inspect model.aimodel \
  --compute gpu-preferred --expect-frequent-reshapes true
```

CLI JSON includes `expect_frequent_reshapes` as `true`, `false`, or `null` for the requested override. Omission produces `null` and preserves the previous loader behavior. Values other than the exact strings `true` and `false` are rejected before native loading.

## ABI evidence

The installed macOS 27 SDK declares a public mutable `SpecializationOptions.expectFrequentReshapes: Bool`. [LoadOptionsReference.swift](../experiments/swift/LoadOptionsReference.swift), compiled independently of Rust, establishes two Swift ABI calls:

| Symbol | Lowered contract |
| --- | --- |
| `$s15CoreAIDelegates21SpecializationOptionsV22expectFrequentReshapesSbvs` | Setter: boolean zero/one in w0, inout options storage in x20; no result. |
| `$s15CoreAIDelegates21SpecializationOptionsV22expectFrequentReshapesSbvg` | Getter: borrowed options storage in x20; boolean in the low bit of w0. |

The [compiler manifest](evidence/v0.2-load-options/compiler-manifest.json) retains source/output hashes, commands, IR, SIL, and assembly. Production Rust resolves these existing SDK functions, mutates an initialized options value through its setter, and verifies getter round-trip before handing the consumed options value to the established async model initializer. There is no options field-offset assumption or custom Swift library.

The independent [native Swift oracle](../experiments/swift/LoadOptionsRunReference.swift) returned CPU-only and GPU-preferred defaults of false, then true and false after both setter updates. [REA observation](evidence/v0.2-load-options-swift-native.json), evidence `ev_9706f04e904c70eca2b1b65b5a561972cea4a2df78c15532d20582e3e1a520c2`, recorded all ten accessor calls, complete process stdout, and exit zero on macOS 27.0.1 arm64. The observed false defaults are not hardcoded into the API.

This observation establishes options construction/mutation on that runtime. It does not establish reshape-related performance, cache behavior, fixed-shape offline specialization, or a particular execution device. End-to-end model/inference validation is recorded by the integration harness separately. The local Krea runtime was consulted for its per-asset option policy; that application policy is not embedded in this general-purpose loader.
