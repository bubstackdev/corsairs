# Creator-defined metadata fixture

`model.aimodel` is the `double_f32_2x3` x+x asset with an author and 27
top-level creator-defined entries written by
[`CreatorMetadataWriter.swift`](../../experiments/swift/CreatorMetadataWriter.swift)
through `AIModelAsset.updateMetadata`. The entries cover every
`CreatorDefinedValue` case: strings (empty, non-ASCII, an emoji ZWJ sequence,
quotes, control characters and an interior NUL), `Int.min`/`Int.max`, finite
doubles from the subnormal minimum to `greatestFiniteMagnitude`, booleans,
empty and nested arrays and dictionaries (40 levels deep), and keys that are
empty, non-ASCII, emoji, and precomposed versus decomposed `é` in separate
dictionaries.

Core AI stores JSON, and its reader does not return every written case: `0`,
`1` and `-0.0` read back as booleans and `3.0` as an integer. Rust and the
oracle both report what Core AI reads. NaN and infinities cannot be written
(see [creator-metadata.md](../../docs/creator-metadata.md)).

Regenerate (the writer's key order varies per run; the parsed JSON does not):

```sh
xcrun swiftc -parse-as-library -O experiments/swift/CreatorMetadataWriter.swift -o target/creator-metadata/writer
target/creator-metadata/writer fixtures/double_f32_2x3/double_f32_2x3.aimodel fixtures/asset-metadata-creator/model.aimodel
```

`python3 -B scripts/check_creator_metadata.py` regenerates it under `target/`
and fails if the parsed JSON or model files differ from this copy.
