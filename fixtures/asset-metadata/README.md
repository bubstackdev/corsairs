# Asset metadata fixture

`model.aimodel` is the `double_f32_2x3` x+x asset with author, license,
description and creation date written by
[`AssetMetadataWriter.swift`](../../experiments/swift/AssetMetadataWriter.swift)
through `AIModelAsset.updateMetadata`. The strings exercise non-ASCII text,
an emoji ZWJ sequence, quotes, a newline and a tab. The requested date
`1234567890.25` is stored at whole-second precision (`20090213T233130Z`).

Regenerate:

```sh
xcrun swiftc -parse-as-library -O experiments/swift/AssetMetadataWriter.swift -o target/asset/writer
target/asset/writer fixtures/double_f32_2x3/double_f32_2x3.aimodel fixtures/asset-metadata/model.aimodel
```
