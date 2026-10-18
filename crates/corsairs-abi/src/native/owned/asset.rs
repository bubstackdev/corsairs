//! Read-only AIModelAsset metadata and summary. Every accessor's lowering is
//! taken from experiments/swift/AssetReference.swift's emitted IR.
use super::{
    NativeFailure, NativeMetadata, NativeSession, NativeValue, OwnedWord, Result, arm64,
    metal::Pool,
};
use std::ffi::CStr;
use std::path::Path;
use std::ptr;

#[derive(Clone, Debug, PartialEq)]
pub struct NativeAssetMetadata {
    pub author: String,
    pub license: String,
    pub description: String,
    /// Seconds since 1970-01-01 UTC.
    pub creation_unix_seconds: Option<f64>,
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
// Bounds for natively reported collection sizes, before any allocation.
const MAX_ENTRIES: usize = 1 << 16;

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
