use super::*;
use crate::native::{NativeAssetFunction, NativeAssetInfo, NativeAssetValue, NativeCreatorValue};
use std::collections::BTreeMap;
use std::time::{Duration, SystemTime};

/// Read-only description of a model asset, without loading or specializing it.
#[derive(Debug, Clone, PartialEq)]
#[non_exhaustive]
pub struct AssetInfo {
    pub metadata: AssetMetadata,
    /// None when Core AI reports no summary for the asset.
    pub summary: Option<AssetSummary>,
}

/// Author-supplied asset metadata. Absent text fields are empty strings.
#[derive(Debug, Clone, PartialEq)]
#[non_exhaustive]
pub struct AssetMetadata {
    pub author: String,
    pub license: String,
    pub description: String,
    pub created: Option<SystemTime>,
    /// Core AI's `creatorDefinedMetadata`; empty when the asset has none.
    pub creator_defined: BTreeMap<String, CreatorValue>,
}

/// A creator-defined metadata value, mirroring Core AI's
/// `AIModelAsset.Metadata.CreatorDefinedValue` case for case.
///
/// The case is Core AI's reading of the asset's JSON, not the value written:
/// whole numbers read back as [`CreatorValue::Integer`], and `0`, `1` and
/// `-0.0` as [`CreatorValue::Bool`]. See `docs/creator-metadata.md`.
#[derive(Debug, Clone, PartialEq)]
#[non_exhaustive]
pub enum CreatorValue {
    String(String),
    Integer(i64),
    Number(f64),
    Bool(bool),
    Array(Vec<CreatorValue>),
    Dictionary(BTreeMap<String, CreatorValue>),
}

/// The asset's declared functions and, when requested, its statistics.
#[derive(Debug, Clone, PartialEq, Eq)]
#[non_exhaustive]
pub struct AssetSummary {
    pub functions: Vec<AssetFunction>,
    /// Stored tensor element types and their counts. Statistics only.
    pub storage_types: Vec<AssetCount>,
    /// Element types used by computation. Statistics only.
    pub compute_types: Vec<String>,
    /// Operation names and their counts. Statistics only.
    pub operations: Vec<AssetCount>,
}

/// A function as declared by the asset, before specialization.
#[derive(Debug, Clone, PartialEq, Eq)]
#[non_exhaustive]
pub struct AssetFunction {
    pub name: String,
    pub inputs: Vec<AssetValue>,
    pub states: Vec<AssetValue>,
    pub outputs: Vec<AssetValue>,
}

/// A declared value and Core AI's human-readable description of its type, for
/// example `NDArray (Float32, 2 × 3)`. Use `Function::descriptor()` for typed
/// shapes and dtypes.
#[derive(Debug, Clone, PartialEq, Eq)]
#[non_exhaustive]
pub struct AssetValue {
    pub name: String,
    pub type_name: String,
}

/// A named count in an asset summary.
#[derive(Debug, Clone, PartialEq, Eq)]
#[non_exhaustive]
pub struct AssetCount {
    pub name: String,
    pub count: usize,
}

impl Runtime {
    /// Read an asset's metadata and summary without loading a model.
    /// `statistics` adds storage types, compute types and operation counts.
    /// A path that is not a valid asset returns [`Error::InvalidAsset`].
    pub fn inspect_asset(&self, path: impl AsRef<Path>, statistics: bool) -> Task<AssetInfo> {
        let path = path.as_ref().to_path_buf();
        self.worker.submit(move |session| {
            // SAFETY: Only this worker owns the session; no handles are created.
            let info = unsafe { session.inspect_asset(&path, statistics) }.map_err(native_error)?;
            Ok(asset_info(info))
        })
    }
    /// Core AI's name for this device's architecture, such as `h17c`.
    pub fn device_architecture(&self) -> Task<String> {
        self.worker.submit(|session| {
            // SAFETY: A static getter on the session-owned library.
            unsafe { session.device_architecture() }.map_err(native_error)
        })
    }
}

fn asset_info(info: NativeAssetInfo) -> AssetInfo {
    let value = |v: NativeAssetValue| AssetValue {
        name: v.name,
        type_name: v.type_name,
    };
    let function = |f: NativeAssetFunction| AssetFunction {
        name: f.name,
        inputs: f.inputs.into_iter().map(value).collect(),
        states: f.states.into_iter().map(value).collect(),
        outputs: f.outputs.into_iter().map(value).collect(),
    };
    let counts = |rows: Vec<(String, usize)>| {
        rows.into_iter()
            .map(|(name, count)| AssetCount { name, count })
            .collect()
    };
    AssetInfo {
        metadata: AssetMetadata {
            author: info.metadata.author,
            license: info.metadata.license,
            description: info.metadata.description,
            created: info.metadata.creation_unix_seconds.and_then(system_time),
            creator_defined: creator_entries(info.metadata.creator_defined),
        },
        summary: info.summary.map(|summary| AssetSummary {
            functions: summary.functions.into_iter().map(function).collect(),
            storage_types: counts(summary.storage_types),
            compute_types: summary.compute_types,
            operations: counts(summary.operations),
        }),
    }
}

fn creator_value(value: NativeCreatorValue) -> CreatorValue {
    match value {
        NativeCreatorValue::String(text) => CreatorValue::String(text),
        NativeCreatorValue::Integer(value) => CreatorValue::Integer(value),
        NativeCreatorValue::Number(value) => CreatorValue::Number(value),
        NativeCreatorValue::Bool(value) => CreatorValue::Bool(value),
        NativeCreatorValue::Array(values) => {
            CreatorValue::Array(values.into_iter().map(creator_value).collect())
        }
        NativeCreatorValue::Dictionary(entries) => {
            CreatorValue::Dictionary(creator_entries(entries))
        }
    }
}

fn creator_entries(
    entries: BTreeMap<String, NativeCreatorValue>,
) -> BTreeMap<String, CreatorValue> {
    entries
        .into_iter()
        .map(|(key, value)| (key, creator_value(value)))
        .collect()
}

/// Convert Unix seconds, including pre-1970 dates; non-finite or
/// unrepresentable values are reported as absent.
fn system_time(seconds: f64) -> Option<SystemTime> {
    let magnitude = Duration::try_from_secs_f64(seconds.abs()).ok()?;
    if seconds >= 0.0 {
        SystemTime::UNIX_EPOCH.checked_add(magnitude)
    } else {
        SystemTime::UNIX_EPOCH.checked_sub(magnitude)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn creation_dates_convert_both_sides_of_the_epoch_and_reject_nonfinite() {
        let epoch = SystemTime::UNIX_EPOCH;
        assert_eq!(system_time(0.0), Some(epoch));
        assert_eq!(system_time(1.5), Some(epoch + Duration::from_millis(1500)));
        assert_eq!(system_time(-2.0), Some(epoch - Duration::from_secs(2)));
        for value in [f64::NAN, f64::INFINITY, f64::NEG_INFINITY, f64::MAX] {
            assert_eq!(system_time(value), None);
        }
    }

    #[test]
    #[ignore = "requires permitted native Core AI"]
    fn native_creator_metadata_reads_every_case_of_the_written_fixture() {
        use CreatorValue::{Array, Bool, Dictionary, Integer, Number, String as Text};
        let runtime = Runtime::new().unwrap();
        let path = Path::new(env!("CARGO_MANIFEST_DIR"))
            .join("../../fixtures/asset-metadata-creator/model.aimodel");
        let metadata = runtime.inspect_asset(path, false).wait().unwrap().metadata;
        let text = |value: &str| Text(value.into());
        let map = |entries: Vec<(&str, CreatorValue)>| {
            entries
                .into_iter()
                .map(|(key, value)| (key.to_owned(), value))
                .collect::<BTreeMap<_, _>>()
        };
        let mut nested = Dictionary(map(vec![("depth", Integer(40)), ("leaf", text("bottom"))]));
        for _ in 0..40 {
            nested = Array(vec![nested]);
        }
        // Values as Core AI reads them back from the JSON CreatorMetadataWriter
        // wrote: 0, 1 and -0.0 become Bool and the whole 3.0 becomes Integer.
        let expected = map(vec![
            ("", text("empty top-level key")),
            ("array_empty", Array(vec![])),
            (
                "array_mixed",
                Array(vec![
                    text("a"),
                    Integer(7),
                    Number(1.5),
                    Bool(true),
                    Array(vec![]),
                    Dictionary(BTreeMap::new()),
                    Array(vec![Array(vec![Array(vec![text("deep")])])]),
                    Dictionary(map(vec![("k", text("v"))])),
                ]),
            ),
            ("bool_false", Bool(false)),
            ("bool_true", Bool(true)),
            (
                "dictionary",
                Dictionary(map(vec![
                    ("", text("empty key")),
                    (
                        "nested",
                        Dictionary(map(vec![(
                            "inner",
                            Dictionary(map(vec![(
                                "list",
                                Array(vec![
                                    Bool(true),
                                    Integer(2),
                                    Dictionary(BTreeMap::new()),
                                    Array(vec![]),
                                ]),
                            )])),
                        )])),
                    ),
                    ("\u{e9}", text("precomposed e-acute key")),
                    ("ключ", text("значение")),
                    ("🔑", text("emoji key")),
                ])),
            ),
            (
                "dictionary_decomposed",
                Dictionary(map(vec![("e\u{301}", text("decomposed e-acute key"))])),
            ),
            ("dictionary_empty", Dictionary(BTreeMap::new())),
            ("integer_max", Integer(i64::MAX)),
            ("integer_min", Integer(i64::MIN)),
            ("integer_negative", Integer(-42)),
            ("integer_one", Bool(true)),
            ("integer_two", Integer(2)),
            ("integer_zero", Bool(false)),
            ("nested_40", nested),
            ("number", Number(0.1)),
            ("number_large", Number(1e300)),
            ("number_max", Number(f64::MAX)),
            ("number_min_normal", Number(f64::MIN_POSITIVE)),
            ("number_negative", Number(-2.5)),
            ("number_negative_zero", Bool(false)),
            ("number_subnormal", Number(f64::from_bits(1))),
            ("number_whole", Integer(3)),
            ("string", text("plain")),
            ("string_empty", text("")),
            (
                "string_unicode",
                text("Zoë 🏴\u{200d}☠️ \"quoted\"\nline\t× 日本語 \u{0}nul"),
            ),
            (
                "日本語キー",
                Array(vec![
                    text("配列"),
                    Integer(7),
                    Dictionary(map(vec![("キー", Bool(false))])),
                ]),
            ),
        ]);
        assert_eq!(metadata.creator_defined, expected);
        assert_eq!(metadata.author, "Creator metadata fixture");
    }

    #[test]
    #[ignore = "requires permitted native Core AI"]
    fn native_asset_metadata_preserves_written_text_and_date() {
        let runtime = Runtime::new().unwrap();
        let path = Path::new(env!("CARGO_MANIFEST_DIR"))
            .join("../../fixtures/asset-metadata/model.aimodel");
        let metadata = runtime.inspect_asset(path, false).wait().unwrap().metadata;
        assert_eq!(
            metadata,
            AssetMetadata {
                author: "Zoë Corsair 🏴\u{200d}☠️".into(),
                license: "MIT OR Apache-2.0".into(),
                description: "x + x \"quoted\"\nsecond line\t× ünïcødé".into(),
                // Written as 1234567890.25; Core AI stores whole seconds.
                created: Some(SystemTime::UNIX_EPOCH + Duration::from_secs(1_234_567_890)),
                creator_defined: BTreeMap::new(),
            }
        );
    }

    #[test]
    #[ignore = "requires permitted native Core AI and CORSAIRS_TEST_MODEL x+x fixture"]
    fn native_asset_inspection_matches_the_swift_oracle() {
        let runtime = Runtime::new().unwrap();
        let path =
            PathBuf::from(std::env::var_os("CORSAIRS_TEST_MODEL").expect("CORSAIRS_TEST_MODEL"));
        let x = || AssetValue {
            name: "x".into(),
            type_name: "NDArray (Float32, 2 × 3)".into(),
        };
        let y = AssetValue {
            name: "y".into(),
            ..x()
        };
        let main = AssetFunction {
            name: "main".into(),
            inputs: vec![x()],
            states: vec![],
            outputs: vec![y],
        };
        let plain = runtime.inspect_asset(&path, false).wait().unwrap();
        assert_eq!(
            plain.summary,
            Some(AssetSummary {
                functions: vec![main.clone()],
                storage_types: vec![],
                compute_types: vec![],
                operations: vec![],
            })
        );
        let metadata = &plain.metadata;
        assert_eq!(
            (
                &*metadata.author,
                &*metadata.license,
                &*metadata.description
            ),
            ("", "", "")
        );
        assert!(metadata.creator_defined.is_empty());
        assert!(
            metadata
                .created
                .is_some_and(|created| created > SystemTime::UNIX_EPOCH)
        );
        let detailed = runtime.inspect_asset(&path, true).wait().unwrap();
        assert_eq!(detailed.metadata, plain.metadata);
        let summary = detailed.summary.unwrap();
        assert_eq!(summary.functions, [main]);
        assert_eq!(summary.compute_types, ["Float32"]);
        assert_eq!(
            summary.operations,
            [AssetCount {
                name: "add".into(),
                count: 1
            }]
        );
        let architecture = runtime.device_architecture().wait().unwrap();
        assert!(!architecture.is_empty() && architecture.is_ascii());
        for invalid in [
            path.with_file_name("does-not-exist.aimodel"),
            path.with_file_name("README.md"),
        ] {
            assert!(matches!(
                runtime.inspect_asset(&invalid, true).wait(),
                Err(Error::InvalidAsset(reported)) if reported == invalid.display().to_string()
            ));
        }
        // Inspection creates no model, function or tensor handles.
        runtime.drain().wait().unwrap();
        assert_eq!(
            runtime
                .worker
                .submit(|session| Ok((session.live_counts(), session.live_tensor_count())))
                .wait()
                .unwrap(),
            ((0, 0), 0)
        );
    }
}
