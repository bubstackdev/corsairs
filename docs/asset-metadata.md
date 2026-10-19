# Asset metadata and summary

Recorded 2026-10-18 on macOS 27.0.1 (26A434), Xcode/SDK 27, device architecture `h17c`.

`Runtime::inspect_asset(path, statistics)` reads an asset's metadata and summary
without loading or specializing a model. `Runtime::device_architecture()`
returns Core AI's `AIModel.deviceArchitectureName`. `corsairs inspect` prints
both alongside the loaded function descriptors.

```rust,no_run
use corsairs::Runtime;
fn main() -> Result<(), corsairs::Error> {
    let runtime = Runtime::new()?;
    let info = runtime.inspect_asset("model.aimodel", true).wait()?;
    println!("{} ({})", info.metadata.author, info.metadata.license);
    if let Some(summary) = info.summary {
        for operation in &summary.operations {
            println!("{}: {}", operation.name, operation.count);
        }
    }
    Ok(())
}
```

## What is exposed

| Rust | Core AI |
| --- | --- |
| `AssetMetadata { author, license, description, created }` | `AIModelAsset.Metadata` fields; `created` from `creationDate` |
| `AssetMetadata::creator_defined` (`CreatorValue`) | `creatorDefinedMetadata`; see [creator-metadata.md](creator-metadata.md) |
| `AssetSummary::functions` (`AssetFunction` with `AssetValue { name, type_name }`) | `Summary.functions` |
| `AssetSummary::{storage_types, compute_types, operations}` | `Summary.storageTypes`, `computeTypes`, `operationDistribution`; empty unless `statistics` |
| `Error::InvalidAsset` | `AIModelAsset.isValid(at:)` is false |

`type_name` is Core AI's display text, for example `NDArray (Float32, 2 × 3)`.
Use `Function::descriptor()` for typed dtypes and shapes. Every public struct is
`#[non_exhaustive]`.

## Binding evidence

[`AssetReference.swift`](../experiments/swift/AssetReference.swift) wraps each
accessor in an `@inline(never)` function. Its emitted IR fixes every lowering:
indirect results in x8, `self` in x20, `Bool` in w0, errors in x21, `String`
pairs, `Array` words, and the `Double` from `Date.timeIntervalSince1970` in d0
(a new `call_f64` helper). Behavior checked against that oracle:

- `AIModelAsset(contentsOf:)` accepts a missing path or a non-asset file without
  throwing and returns empty metadata, and `summary` then returns nil.
  Corsairs therefore checks `isValid(at:)` first.
- The initializer consumes its `URL` argument, even when it throws.
- Asset reads autorelease Foundation objects. In pure Swift, RSS grew by about 7 MB
  between 4,000 and 20,000 reads without an autorelease pool and stayed flat
  with one. Each Corsairs inspection now runs in a scoped pool; over the same
  window, inspections with statistics grew RSS by 48 KiB.
- [All 36 repository assets](evidence/asset-metadata/swift-oracle.json) match the
  oracle field for field, covering metadata, functions, storage types, compute
  types and operation counts (feedforward: 21 operations across 9 kinds).
- [`fixtures/asset-metadata`](../fixtures/asset-metadata/README.md) carries
  non-empty, non-ASCII metadata written by `AIModelAsset.updateMetadata`. The
  creation date is stored at whole-second precision.

## Not covered

- Writing metadata (`updateMetadata`) and `removeDerivedArtifacts()`.
- The asset JSON's `producer` and `assetVersion` keys, which have no public
  accessor.
