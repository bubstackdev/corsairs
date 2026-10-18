//! Read-only AIModelAsset metadata and summary. Every accessor's lowering is
//! taken from experiments/swift/AssetReference.swift's emitted IR, and the
//! creator-defined metadata from CreatorMetadataReference.swift's.
use super::{
    Metadata, NativeFailure, NativeMetadata, NativeSession, NativeValue, OwnedWord, Result, arm64,
    metal::{Pool, call6},
};
use std::cell::Cell;
use std::collections::BTreeMap;
use std::ffi::{CStr, c_void};
use std::mem;
use std::path::Path;
use std::ptr;

#[derive(Clone, Debug, PartialEq)]
pub struct NativeAssetMetadata {
    pub author: String,
    pub license: String,
    pub description: String,
    /// Seconds since 1970-01-01 UTC.
    pub creation_unix_seconds: Option<f64>,
    pub creator_defined: BTreeMap<String, NativeCreatorValue>,
}
/// One `AIModelAsset.Metadata.CreatorDefinedValue`, in declaration order.
#[derive(Clone, Debug, PartialEq)]
pub enum NativeCreatorValue {
    String(String),
    Integer(i64),
    Number(f64),
    Bool(bool),
    Array(Vec<NativeCreatorValue>),
    Dictionary(BTreeMap<String, NativeCreatorValue>),
}
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct NativeAssetValue {
    pub name: String,
    pub type_name: String,
}
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct NativeAssetFunction {
    pub name: String,
    pub inputs: Vec<NativeAssetValue>,
    pub states: Vec<NativeAssetValue>,
    pub outputs: Vec<NativeAssetValue>,
}
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct NativeAssetSummary {
    pub functions: Vec<NativeAssetFunction>,
    /// (type name, count); empty unless statistics were requested.
    pub storage_types: Vec<(String, usize)>,
    pub compute_types: Vec<String>,
    /// (operation name, count); empty unless statistics were requested.
    pub operations: Vec<(String, usize)>,
}
#[derive(Clone, Debug, PartialEq)]
pub struct NativeAssetInfo {
    pub metadata: NativeAssetMetadata,
    pub summary: Option<NativeAssetSummary>,
}

const ASSET: &CStr = c"$s11CoreAIAsset12AIModelAssetVMa";
const METADATA: &CStr = c"$s11CoreAIAsset12AIModelAssetV8MetadataVMa";
const SUMMARY: &CStr = c"$s11CoreAIAsset12AIModelAssetV7SummaryVMa";
const FUNCTION: &CStr = c"$s11CoreAIAsset12AIModelAssetV18FunctionDescriptorVMa";
const VALUE: &CStr = c"$s11CoreAIAsset12AIModelAssetV15ValueDescriptorVMa";
const STORAGE: &CStr = c"$s11CoreAIAsset12AIModelAssetV7SummaryV11StorageTypeVMa";
const OPERATION: &CStr = c"$s11CoreAIAsset12AIModelAssetV7SummaryV14OperationCountVMa";
const CREATOR_VALUE: &CStr = c"$s11CoreAIAsset12AIModelAssetV8MetadataV19CreatorDefinedValueOMa";
// Case tags are the resilient enum's exported `WC` constants, in the order of
// NativeCreatorValue; their values are loaded, never assumed.
const CREATOR_CASES: [&CStr; 6] = [
    c"$s11CoreAIAsset12AIModelAssetV8MetadataV19CreatorDefinedValueO6stringyAGSScAGmFWC",
    c"$s11CoreAIAsset12AIModelAssetV8MetadataV19CreatorDefinedValueO7integeryAGSicAGmFWC",
    c"$s11CoreAIAsset12AIModelAssetV8MetadataV19CreatorDefinedValueO6numberyAGSdcAGmFWC",
    c"$s11CoreAIAsset12AIModelAssetV8MetadataV19CreatorDefinedValueO4boolyAGSbcAGmFWC",
    c"$s11CoreAIAsset12AIModelAssetV8MetadataV19CreatorDefinedValueO5arrayyAGSayAGGcAGmFWC",
    c"$s11CoreAIAsset12AIModelAssetV8MetadataV19CreatorDefinedValueO10dictionaryyAGSDySSAGGcAGmFWC",
];
// Bounds for natively reported collection sizes, before any allocation.
const MAX_ENTRIES: usize = 1 << 16;
// Creator-defined values come from an untrusted asset: bound the nesting (Core
// AI's JSON reader itself stops near 512 levels) and the total value count.
const MAX_CREATOR_DEPTH: usize = 512;
const MAX_CREATOR_VALUES: usize = 1 << 16;

/// Metadata, witness tables and case tags shared by one creator-metadata walk.
struct Creator {
    value: NativeMetadata,
    optional_value: NativeMetadata,
    string: NativeMetadata,
    optional_string: NativeMetadata,
    hashable: usize,
    iterator: NativeMetadata,
    tags: [u32; 6],
    remaining: Cell<usize>,
}
impl Creator {
    /// Charge `count` values against the walk's budget before reading them.
    fn consume(&self, count: usize) -> Result<()> {
        let remaining = self.remaining.get().checked_sub(count).ok_or_else(|| {
            NativeFailure::Unsupported(format!(
                "creator metadata holds more than {MAX_CREATOR_VALUES} values"
            ))
        })?;
        self.remaining.set(remaining);
        Ok(())
    }
}

impl NativeSession {
    /// # Safety
    /// Uses only the compiler-verified AIModelAsset accessors listed above.
    pub unsafe fn inspect_asset(&self, path: &Path, statistics: bool) -> Result<NativeAssetInfo> {
        // SAFETY: Each call matches its declaration in AssetReference.swift IR;
        // every returned owner is held by NativeValue/OwnedWord until dropped.
        unsafe {
            // Asset reads autorelease Foundation objects; without a scoped pool
            // the worker thread retains ~450 bytes per inspection indefinitely.
            // Declared first, so it drains after every native value is dropped.
            let _pool = Pool::new();
            let text = path
                .to_str()
                .ok_or_else(|| NativeFailure::InvalidData("asset path must be UTF8".into()))?;
            let text = self.string(text)?;
            let mut url = NativeValue::allocate(self.metadata(c"$s10Foundation3URLVMa")?)?;
            let url_init = self.symbol(c"$s10Foundation3URLV15fileURLWithPathACSSh_tcfC")?;
            arm64::call_sync(url_init, [text.words[0], text.words[1], 0], url.ptr(), 0);
            url.initialized = true;
            // init(contentsOf:) accepts missing or non-asset paths without
            // throwing and reports empty metadata, so validity is checked first.
            let valid = self.call(
                c"$s11CoreAIAsset12AIModelAssetV7isValid2atSb10Foundation3URLV_tFZ",
                [url.address(), 0, 0],
                ptr::null_mut(),
                0,
            )?;
            if valid & 1 == 0 {
                return Err(NativeFailure::InvalidAsset(path.display().to_string()));
            }
            let asset_md = self.metadata(ASSET)?;
            let mut asset = NativeValue::allocate(asset_md)?;
            // Resolve all fallible symbols before consuming any values.
            let open = self
                .symbol(c"$s11CoreAIAsset12AIModelAssetV10contentsOfAC10Foundation3URLV_tKcfC")?;
            let error =
                arm64::call_throwing(open, [url.address(), 0, 0], asset.ptr(), asset_md.pointer);
            // Initializer arguments are owned: the URL is consumed even on throw.
            url.initialized = false;
            if !error.is_null() {
                return Err(self.failure(error as _, "open_asset"));
            }
            asset.initialized = true;

            let mut metadata = NativeValue::allocate(self.metadata(METADATA)?)?;
            self.call(
                c"$s11CoreAIAsset12AIModelAssetV8metadataAC8MetadataVvg",
                [0; 3],
                metadata.ptr(),
                asset.address(),
            )?;
            metadata.initialized = true;
            let metadata = self.asset_metadata(&metadata)?;

            let summary_md = self.metadata(SUMMARY)?;
            let mut optional = NativeValue::allocate(self.optional(summary_md)?)?;
            let error = arm64::call_throwing(
                self.symbol(c"$s11CoreAIAsset12AIModelAssetV7summary19includingStatisticsAC7SummaryVSgSb_tKF")?,
                [usize::from(statistics), 0, 0],
                optional.ptr(),
                asset.address(),
            );
            if !error.is_null() {
                return Err(self.failure(error as _, "asset_summary"));
            }
            optional.initialized = true;
            let summary = match optional.take_optional(summary_md)? {
                Some(summary) => Some(self.asset_summary(&summary)?),
                None => None,
            };
            Ok(NativeAssetInfo { metadata, summary })
        }
    }

    /// # Safety
    /// Calls the verified static AIModel.deviceArchitectureName getter.
    pub unsafe fn device_architecture(&self) -> Result<String> {
        // SAFETY: swiftcc () -> String; the two returned words are owned.
        unsafe {
            let _pool = Pool::new();
            let (a, b) = self.pair(
                c"$s13CoreAIRuntime7AIModelV0A11AIDelegatesE22deviceArchitectureNameSSvgZ",
                [0; 3],
                ptr::null_mut(),
                0,
            )?;
            self.string_words([a, b])
        }
    }

    unsafe fn asset_metadata(&self, metadata: &NativeValue) -> Result<NativeAssetMetadata> {
        // SAFETY: Borrowed Metadata in x20 for every getter.
        unsafe {
            let receiver = metadata.address();
            let date_md = self.metadata(c"$s10Foundation4DateVMa")?;
            let mut optional = NativeValue::allocate(self.optional(date_md)?)?;
            self.call(
                c"$s11CoreAIAsset12AIModelAssetV8MetadataV12creationDate10Foundation0G0VSgvg",
                [0; 3],
                optional.ptr(),
                receiver,
            )?;
            optional.initialized = true;
            let creation_unix_seconds = match optional.take_optional(date_md)? {
                Some(date) => Some(arm64::call_f64(
                    self.symbol(c"$s10Foundation4DateV21timeIntervalSince1970Sdvg")?,
                    date.address(),
                )),
                None => None,
            };
            Ok(NativeAssetMetadata {
                author: self.text_getter(
                    c"$s11CoreAIAsset12AIModelAssetV8MetadataV6authorSSvg",
                    receiver,
                )?,
                license: self.text_getter(
                    c"$s11CoreAIAsset12AIModelAssetV8MetadataV7licenseSSvg",
                    receiver,
                )?,
                description: self.text_getter(
                    c"$s11CoreAIAsset12AIModelAssetV8MetadataV11descriptionSSvg",
                    receiver,
                )?,
                creation_unix_seconds,
                creator_defined: self.creator_defined(receiver)?,
            })
        }
    }

    unsafe fn creator_defined(
        &self,
        receiver: usize,
    ) -> Result<BTreeMap<String, NativeCreatorValue>> {
        // SAFETY: Borrowed Metadata in x20; the getter returns a +1 Dictionary
        // word. Every metadata argument below is the one the IR passes.
        unsafe {
            let value = self.metadata(CREATOR_VALUE)?;
            if value.layout.flags & 0x0020_0000 == 0 {
                return Err(NativeFailure::Binding("enum witnesses absent".into()));
            }
            let string = NativeMetadata::copy(&Metadata::from_response(self.symbol(c"$sSSN")?, 0)?);
            let hashable = self.symbol(c"$sSSSHsWP")? as usize;
            let (pointer, state, _) = call6(
                self.symbol(c"$sSD4KeysV8IteratorVMa")?,
                [0, string.pointer, value.pointer, hashable, 0, 0],
                ptr::null_mut(),
                0,
            );
            let iterator = NativeMetadata::copy(&Metadata::from_response(pointer as _, state)?);
            let mut tags = [0; 6];
            for (tag, case) in tags.iter_mut().zip(CREATOR_CASES) {
                *tag = self.symbol(case)?.cast::<u32>().read();
            }
            let creator = Creator {
                value,
                optional_value: self.optional(value)?,
                string,
                optional_string: self.optional(string)?,
                hashable,
                iterator,
                tags,
                remaining: Cell::new(MAX_CREATOR_VALUES),
            };
            let word = self.call(
                c"$s11CoreAIAsset12AIModelAssetV8MetadataV014creatorDefinedE0SDySSAE07CreatorG5ValueOGvg",
                [0; 3],
                ptr::null_mut(),
                receiver,
            )?;
            self.creator_dictionary(&creator, word, 0)
        }
    }

    /// Read a +1 `[String: CreatorDefinedValue]` word through its keys
    /// iterator and keyed subscript; no Dictionary storage layout is assumed.
    unsafe fn creator_dictionary(
        &self,
        creator: &Creator,
        word: usize,
        depth: usize,
    ) -> Result<BTreeMap<String, NativeCreatorValue>> {
        // SAFETY: Each generic entry point takes (String, CreatorDefinedValue,
        // String: Hashable) after its value arguments, per the -Onone IR.
        unsafe {
            let dictionary = OwnedWord {
                word,
                release: self.release(c"swift_bridgeObjectRelease")?,
            };
            let generic = [
                creator.string.pointer,
                creator.value.pointer,
                creator.hashable,
            ];
            let (count, _, _) = call6(
                self.symbol(c"$sSD5countSivg")?,
                [word, generic[0], generic[1], generic[2], 0, 0],
                ptr::null_mut(),
                0,
            );
            creator.consume(count)?;
            // Resolve and allocate first: nothing may fail while Keys is owned.
            let keys_getter = self.symbol(c"$sSD4keysSD4KeysVyxq__Gvg")?;
            let make_iterator = self.symbol(c"$sSD4KeysV12makeIteratorAB0C0Vyxq___GyF")?;
            let next = self.symbol(c"$sSD4KeysV8IteratorV4nextxSgyF")?;
            let lookup = self.symbol(c"$sSDyq_Sgxcig")?;
            let mut iterator = NativeValue::allocate(creator.iterator)?;
            // keys borrows the dictionary and returns a +1 Keys word, which
            // makeIterator consumes into the runtime-sized Keys.Iterator.
            let (keys, _, _) = call6(
                keys_getter,
                [word, generic[0], generic[1], generic[2], 0, 0],
                ptr::null_mut(),
                0,
            );
            call6(
                make_iterator,
                [keys, generic[0], generic[1], generic[2], 0, 0],
                iterator.ptr(),
                0,
            );
            iterator.initialized = true;
            let mut entries = BTreeMap::new();
            loop {
                let mut optional = NativeValue::allocate(creator.optional_string)?;
                // next: x8 = Optional<String>, x0 = Keys.Iterator metadata,
                // x20 = the iterator, mutated in place.
                call6(
                    next,
                    [creator.iterator.pointer, 0, 0, 0, 0, 0],
                    optional.ptr(),
                    iterator.address(),
                );
                optional.initialized = true;
                let Some(mut key) = optional.take_optional(creator.string)? else {
                    break;
                };
                if entries.len() == count {
                    return Err(NativeFailure::Binding(
                        "creator metadata keys exceed their count".into(),
                    ));
                }
                // subscript(key:): x8 = Optional<Value>, x0 = borrowed key
                // address, x1 = borrowed dictionary word.
                let mut found = NativeValue::allocate(creator.optional_value)?;
                call6(
                    lookup,
                    [key.address(), word, generic[0], generic[1], generic[2], 0],
                    found.ptr(),
                    0,
                );
                found.initialized = true;
                let value = found.take_optional(creator.value)?.ok_or_else(|| {
                    NativeFailure::Binding("creator metadata key has no value".into())
                })?;
                // Move the key's two String words out of its native storage.
                let words = key.ptr().cast::<[usize; 2]>().read();
                key.initialized = false;
                let key = self.string_words(words)?;
                let value = self.creator_value(creator, value, depth + 1)?;
                if entries.insert(key, value).is_some() {
                    return Err(NativeFailure::Binding(
                        "duplicate creator metadata key".into(),
                    ));
                }
            }
            if entries.len() != count {
                return Err(NativeFailure::Binding(
                    "creator metadata keys fall short of their count".into(),
                ));
            }
            drop(dictionary);
            Ok(entries)
        }
    }

    /// Consume one owned CreatorDefinedValue: getEnumTag (VWT 11), match a `WC`
    /// constant, destructiveProjectEnumData (VWT 12), then load the payload
    /// from offset 0 exactly as CreatorMetadataReference.swift's -O IR does.
    unsafe fn creator_value(
        &self,
        creator: &Creator,
        mut value: NativeValue,
        depth: usize,
    ) -> Result<NativeCreatorValue> {
        // SAFETY: `value` is an initialized CreatorDefinedValue whose metadata
        // carries enum witnesses (checked in creator_defined). After projection
        // the storage holds the payload, so the enum itself is never destroyed.
        unsafe {
            if depth > MAX_CREATOR_DEPTH {
                return Err(NativeFailure::Unsupported(format!(
                    "creator metadata nests deeper than {MAX_CREATOR_DEPTH} levels"
                )));
            }
            let md = creator.value;
            let get_tag: unsafe extern "C" fn(*mut c_void, *mut c_void) -> u32 =
                mem::transmute(md.witness(11));
            let tag = get_tag(value.ptr(), md.pointer as _);
            let Some(case) = creator.tags.iter().position(|known| *known == tag) else {
                // A future case: `value` is still the whole enum and drops normally.
                return Err(NativeFailure::Unsupported(format!(
                    "creator metadata value case tag {tag}"
                )));
            };
            let project: unsafe extern "C" fn(*mut c_void, *mut c_void) =
                mem::transmute(md.witness(12));
            project(value.ptr(), md.pointer as _);
            value.initialized = false;
            let payload = value.ptr().cast::<usize>();
            Ok(match case {
                0 => NativeCreatorValue::String(
                    self.string_words([payload.read(), payload.add(1).read()])?,
                ),
                1 => NativeCreatorValue::Integer(payload.read() as i64),
                2 => NativeCreatorValue::Number(f64::from_bits(payload.read() as u64)),
                // The IR loads an i1: only the low bit is defined.
                3 => NativeCreatorValue::Bool(value.ptr().cast::<u8>().read() & 1 != 0),
                4 => {
                    let elements = self.elements(payload.read(), md)?;
                    creator.consume(elements.len())?;
                    let mut values = Vec::with_capacity(elements.len());
                    for element in elements {
                        values.push(self.creator_value(creator, element, depth + 1)?);
                    }
                    NativeCreatorValue::Array(values)
                }
                _ => NativeCreatorValue::Dictionary(self.creator_dictionary(
                    creator,
                    payload.read(),
                    depth,
                )?),
            })
        }
    }

    unsafe fn asset_summary(&self, summary: &NativeValue) -> Result<NativeAssetSummary> {
        // SAFETY: Borrowed Summary in x20; each getter returns a +1 Array word.
        unsafe {
            let receiver = summary.address();
            let mut functions = Vec::new();
            let word = self.call(
                c"$s11CoreAIAsset12AIModelAssetV7SummaryV9functionsSayAC18FunctionDescriptorVGvg",
                [0; 3],
                ptr::null_mut(),
                receiver,
            )?;
            for function in self.elements(word, self.metadata(FUNCTION)?)? {
                let receiver = function.address();
                functions.push(NativeAssetFunction {
                    name: self.text_getter(
                        c"$s11CoreAIAsset12AIModelAssetV18FunctionDescriptorV4nameSSvg",
                        receiver,
                    )?,
                    inputs: self.asset_values(
                        c"$s11CoreAIAsset12AIModelAssetV18FunctionDescriptorV6inputsSayAC05ValueF0VGvg",
                        receiver,
                    )?,
                    states: self.asset_values(
                        c"$s11CoreAIAsset12AIModelAssetV18FunctionDescriptorV6statesSayAC05ValueF0VGvg",
                        receiver,
                    )?,
                    outputs: self.asset_values(
                        c"$s11CoreAIAsset12AIModelAssetV18FunctionDescriptorV7outputsSayAC05ValueF0VGvg",
                        receiver,
                    )?,
                });
            }
            let word = self.call(
                c"$s11CoreAIAsset12AIModelAssetV7SummaryV12storageTypesSayAE11StorageTypeVGvg",
                [0; 3],
                ptr::null_mut(),
                receiver,
            )?;
            let storage_types = self.counted(
                word,
                STORAGE,
                c"$s11CoreAIAsset12AIModelAssetV7SummaryV11StorageTypeV8typeNameSSvg",
                c"$s11CoreAIAsset12AIModelAssetV7SummaryV11StorageTypeV5countSivg",
            )?;
            let word = self.call(
                c"$s11CoreAIAsset12AIModelAssetV7SummaryV12computeTypesSaySSGvg",
                [0; 3],
                ptr::null_mut(),
                receiver,
            )?;
            let compute_types = self.strings(word)?;
            let word = self.call(
                c"$s11CoreAIAsset12AIModelAssetV7SummaryV21operationDistributionSayAE14OperationCountVGvg",
                [0; 3],
                ptr::null_mut(),
                receiver,
            )?;
            let operations = self.counted(
                word,
                OPERATION,
                c"$s11CoreAIAsset12AIModelAssetV7SummaryV14OperationCountV13operationNameSSvg",
                c"$s11CoreAIAsset12AIModelAssetV7SummaryV14OperationCountV5countSivg",
            )?;
            Ok(NativeAssetSummary {
                functions,
                storage_types,
                compute_types,
                operations,
            })
        }
    }

    unsafe fn asset_values(&self, getter: &CStr, receiver: usize) -> Result<Vec<NativeAssetValue>> {
        // SAFETY: Borrowed FunctionDescriptor in x20; +1 Array<ValueDescriptor>.
        unsafe {
            let word = self.call(getter, [0; 3], ptr::null_mut(), receiver)?;
            self.elements(word, self.metadata(VALUE)?)?
                .iter()
                .map(|value| {
                    Ok(NativeAssetValue {
                        name: self.text_getter(
                            c"$s11CoreAIAsset12AIModelAssetV15ValueDescriptorV4nameSSvg",
                            value.address(),
                        )?,
                        type_name: self.text_getter(
                            c"$s11CoreAIAsset12AIModelAssetV15ValueDescriptorV8typeNameSSvg",
                            value.address(),
                        )?,
                    })
                })
                .collect()
        }
    }

    /// Read an Array of (String, Int) structs through their two getters.
    unsafe fn counted(
        &self,
        word: usize,
        element: &CStr,
        name: &CStr,
        count: &CStr,
    ) -> Result<Vec<(String, usize)>> {
        // SAFETY: Borrowed element in x20 for both getters; Int in x0.
        unsafe {
            self.elements(word, self.metadata(element)?)?
                .iter()
                .map(|value| {
                    let total = self.call(count, [0; 3], ptr::null_mut(), value.address())?;
                    Ok((self.text_getter(name, value.address())?, total))
                })
                .collect()
        }
    }

    unsafe fn text_getter(&self, getter: &CStr, receiver: usize) -> Result<String> {
        // SAFETY: swiftcc (ptr swiftself) -> String, returning owned words.
        unsafe {
            let (a, b) = self.pair(getter, [0; 3], ptr::null_mut(), receiver)?;
            self.string_words([a, b])
        }
    }

    /// Copy every element of a +1 Array<Element> into owned native values.
    unsafe fn elements(&self, word: usize, element: NativeMetadata) -> Result<Vec<NativeValue>> {
        // SAFETY: count/subscript take the array word and element metadata; the
        // subscript getter initializes an owned element copy at the out pointer.
        unsafe {
            let _array = OwnedWord {
                word,
                release: self.release(c"swift_bridgeObjectRelease")?,
            };
            let count = self.call(
                c"$sSa5countSivg",
                [word, element.pointer, 0],
                ptr::null_mut(),
                0,
            )?;
            if count > MAX_ENTRIES {
                return Err(NativeFailure::Binding(
                    "excessive native asset entry count".into(),
                ));
            }
            let mut values = Vec::with_capacity(count);
            for index in 0..count {
                let mut value = NativeValue::allocate(element)?;
                self.call(
                    c"$sSayxSicig",
                    [index, word, element.pointer],
                    value.ptr(),
                    0,
                )?;
                value.initialized = true;
                values.push(value);
            }
            Ok(values)
        }
    }
}
