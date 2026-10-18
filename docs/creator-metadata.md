# Creator-defined asset metadata

Recorded 2026-10-18 on macOS 27.0.1 (26A434), Xcode/SDK 27, device architecture `h17c`.
Targets v0.5.0.

`Runtime::inspect_asset` now also returns Core AI's
`AIModelAsset.Metadata.creatorDefinedMetadata`, read-only, as
`AssetMetadata::creator_defined`. `corsairs inspect` prints it.

```rust,no_run
use corsairs::{CreatorValue, Runtime};
fn main() -> Result<(), corsairs::Error> {
    let runtime = Runtime::new()?;
    let info = runtime.inspect_asset("model.aimodel", false).wait()?;
    if let Some(CreatorValue::String(revision)) = info.metadata.creator_defined.get("revision") {
        println!("revision {revision}");
    }
    Ok(())
}
```

## What is exposed

| Rust | Core AI |
| --- | --- |
| `AssetMetadata::creator_defined: BTreeMap<String, CreatorValue>` | `creatorDefinedMetadata: [String: CreatorDefinedValue]` |
| `CreatorValue::String(String)` | `.string(String)` |
| `CreatorValue::Integer(i64)` | `.integer(Int)` |
| `CreatorValue::Number(f64)` | `.number(Double)`, bit for bit |
| `CreatorValue::Bool(bool)` | `.bool(Bool)` |
| `CreatorValue::Array(Vec<CreatorValue>)` | `.array([CreatorDefinedValue])` |
| `CreatorValue::Dictionary(BTreeMap<String, CreatorValue>)` | `.dictionary([String: CreatorDefinedValue])` |

`CreatorValue` is `#[non_exhaustive]`, like the Swift enum, which is resilient
and may gain cases. Keys are kept byte for byte; precomposed and decomposed
`é` are distinct keys. `BTreeMap` orders keys by UTF-8 bytes; Swift's
Dictionary order is unspecified.

`corsairs inspect` adds `asset.creator_defined`, with each value a one-key
object naming its case, so `{"integer":1}`, `{"number":1.0}` and
`{"bool":true}` stay distinct:

```json
"creator_defined":{"integer_max":{"integer":9223372036854775807},"number":{"number":0.1},
"array_mixed":{"array":[{"string":"a"},{"integer":7},{"number":1.5},{"bool":true}]}}
```

Numbers print as Rust's shortest round-trip form. NaN and infinities, which
Core AI cannot produce, would print as the strings `"NaN"`, `"inf"` and
`"-inf"`.

### Breaking changes for v0.5.0

- `AssetMetadata` has a new field (it was already `#[non_exhaustive]`).
- `AssetMetadata` no longer implements `Eq`, because `CreatorValue` holds an
  `f64`. `PartialEq` remains.

## Binding evidence

[`CreatorMetadataReference.swift`](../experiments/swift/CreatorMetadataReference.swift)
wraps each accessor in an `@inline(never)` function.
[`check_creator_metadata.py`](../scripts/check_creator_metadata.py) compiles
it to `-O` and `-Onone` IR and SIL and fails unless each declaration below
appears verbatim. Every symbol is in the SDK `CoreAIAsset.tbd` or
`libswiftCore.tbd`.

| Step | Compiler-established contract |
| --- | --- |
| `Metadata.creatorDefinedMetadata` getter | x20 = borrowed Metadata; returns a +1 Dictionary word in x0 (`@owned`) |
| `CreatorDefinedValue` case | VWT slot 11 `getEnumTag`, compared against each case's exported `WC` constant, which is loaded, never assumed |
| Payload | VWT slot 12 `destructiveProjectEnumData`, then the payload is loaded from offset 0: String as two words (the second released with `swift_bridgeObjectRelease`), `Int`/`Double` as one i64, `Bool` as an i1, Array and Dictionary as one owned word |
| `Dictionary.count` | x0 = Dictionary word, then String metadata (`$sSSN`), CreatorDefinedValue metadata, `String: Hashable` witness table (`$sSSSHsWP`) |
| `Dictionary.keys` | Same arguments; borrows the dictionary and returns a +1 `Keys` word |
| `Keys.makeIterator()` | x8 = `Keys.Iterator` (sized by `$sSD4KeysV8IteratorVMa` metadata), x0 = `Keys` word consumed (`@owned`), then the generic arguments |
| `Keys.Iterator.next()` | x8 = `Optional<String>`, x0 = `Keys.Iterator` metadata, x20 = iterator (`@inout`) |
| `Dictionary.subscript(key:)` | x8 = `Optional<CreatorDefinedValue>`, x0 = borrowed key address, x1 = borrowed Dictionary word, then the generic arguments |
| `Array.count`, `Array.subscript` | Existing contracts (`docs/abi-contracts.md`), with CreatorDefinedValue element metadata |

The generic Dictionary entry points come from `-Onone` IR because their
optimized bodies inline, as for the existing Array accessors. No Dictionary or
enum storage layout is assumed. The values come from an untrusted asset, so
nesting is capped at 512 levels and a walk at 65,536 values in total. Both are
checked before the values are read. An unknown future case returns
`Error::Unsupported` and the value is destroyed intact.

## Behavior findings

The full report, with its exact IR, SIL and SDK checks, is in
[`check.json`](evidence/v0.5/creator-metadata/check.json). The Swift oracle's
output is in [`swift-oracle.json`](evidence/v0.5/creator-metadata/swift-oracle.json).

- **Field-for-field parity.** The oracle walks values with ordinary Swift
  pattern matching and `for (key, value) in`, not with the wrappers Rust
  follows. `corsairs inspect` matches it on
  [`fixtures/asset-metadata-creator`](../fixtures/asset-metadata-creator/README.md)
  (27 top-level entries, every case, 40-level nesting, `Int.min`/`Int.max`,
  subnormal and maximum doubles, empty containers, Unicode and empty keys).
  It also matches on all 83 repository assets. The other 82 have no creator
  metadata and report an empty map.
- **Core AI reads back JSON types, not written cases.** The metadata is stored
  as JSON in `metadata.json`. On reading, `0`, `1`, `0.0`, `1.0` and `-0.0`
  become `.bool`, and whole doubles such as `3.0`, `2.0` and `1e2` become
  `.integer`. `-0.0` therefore cannot be read back as a number.
  `1e19` stays `.number`. Rust reports what Core AI reads.
- **NaN and infinities are unrepresentable.** `updateMetadata` given
  `.number(.nan)` aborts the process: JSONSerialization raises an uncaught
  `NSInvalidArgumentException` ("Invalid number value (NaN) in JSON write").
  A hand-written `1e999` is rejected on read.
- **Malformed creator JSON makes the asset invalid.** In these cases
  `isValid(at:)` is false, so `inspect_asset` returns `Error::InvalidAsset`,
  and model loading fails too: a `null` value or a `UInt64.max` integer (the
  oracle's `AIModelAsset(contentsOf:)` throws `AssetError.corruptedMetadata`),
  and `1e999` or nesting past Core AI's JSON limit (a Foundation `NSError`; a
  value 512 levels deep is rejected, 511 is accepted). A
  `creatorDefinedMetadata` that is a JSON array instead of an object is
  silently ignored, and both sides report an empty map.
- **Limits.** A value 511 levels deep (the deepest Core AI accepts) is read in
  full, also by the debug build on its default 2 MiB worker stack. With its
  key, an array of 65,535 elements totals exactly the 65,536-value budget and
  matches. One element more returns
  `Error::Unsupported("creator metadata holds more than 65536 values")`, while
  Swift reads it. That divergence is intended.
- **Memory.** 20,000 inspections of the fixture, with statistics and checked
  for equality each time, kept RSS flat inside the existing per-inspection
  autorelease pool. RSS was 13,872 KiB at 4,000 inspections and 13,808 KiB at
  20,000 ([`soak`](evidence/v0.5/creator-metadata/check.json)).

Reproduce (native Core AI; writes only under `target/`):

```sh
python3 -B scripts/check_creator_metadata.py --soak 20000
```

## Not covered

- Writing creator-defined metadata (`updateMetadata`, the Metadata subscript
  setters).
- The typed `Metadata` subscripts (`subscript(key:type:)`). The full map
  carries the same values.
- Assets whose creator metadata exceeds the 65,536-value budget. They return
  an error rather than a partial map.
