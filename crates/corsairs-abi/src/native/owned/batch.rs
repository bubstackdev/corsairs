//! Prepare, enqueue, and join independent loads on one native session.
#[cfg(any(feature = "abi-research", test))]
use super::super::async_task::OverlapReport;
use super::super::async_task::{OverlapProbe, PendingCall, Scheduling};
use super::*;
use std::path::PathBuf;
use std::sync::Arc;

#[cfg(any(feature = "abi-research", test))]
pub type NativeBatchMetrics = OverlapReport;
pub struct NativeBatchOutcome {
    pub models: Result<Vec<NativeModel>>,
    #[cfg(any(feature = "abi-research", test))]
    pub metrics: Option<NativeBatchMetrics>,
}
struct LoadCompletion {
    result: super::super::async_task::AsyncResult,
    error_release: unsafe extern "C" fn(*mut c_void),
}
impl LoadCompletion {
    fn take_error(&mut self) -> usize {
        mem::take(&mut self.result.error)
    }
}
impl Drop for LoadCompletion {
    fn drop(&mut self) {
        if self.result.error != 0 {
            // SAFETY: This guard owns the unclaimed Error +1 from completion.
            unsafe {
                (self.error_release)(self.result.error as _);
            }
        }
    }
}
struct PreparedModelLoad<'runtime> {
    runtime: &'runtime Runtime,
    pending: Option<PendingCall<'runtime>>,
    model: Option<NativeValue>,
    url: NativeValue,
    options: NativeValue,
    error_release: unsafe extern "C" fn(*mut c_void),
    completion: Option<LoadCompletion>,
}
impl PreparedModelLoad<'_> {
    unsafe fn start(&mut self, probe: Option<Arc<OverlapProbe>>) -> Result<()> {
        // SAFETY: All three allocations remain owned here until join/drop. The
        // known initializer consumes URL/options on both success and error.
        let pending = unsafe {
            self.runtime.start_native(c"$s13CoreAIRuntime7AIModelV0A11AIDelegatesE10contentsOf7optionsAC10Foundation3URLV_AD21SpecializationOptionsVtYaKcfCTu", [self.model.as_ref().unwrap().address(), self.url.address(), self.options.address(), 0], 0, true, Scheduling::Global, probe)?
        };
        self.url.initialized = false;
        self.options.initialized = false;
        self.pending = Some(pending);
        Ok(())
    }
    fn join(&mut self) {
        if let Some(pending) = self.pending.take() {
            let result = pending.wait();
            self.model.as_mut().unwrap().initialized = result.error == 0;
            self.completion = Some(LoadCompletion {
                result,
                error_release: self.error_release,
            });
        }
    }
}
impl Drop for PreparedModelLoad<'_> {
    fn drop(&mut self) {
        self.join();
    }
}
struct PreparedBatch<'runtime> {
    loads: Vec<PreparedModelLoad<'runtime>>,
}
impl PreparedBatch<'_> {
    fn join_all(&mut self) {
        // Store completions in their existing slots: this join pass allocates
        // nothing and destroys no native value/error before all calls finish.
        for load in &mut self.loads {
            load.join();
        }
    }
}
impl Drop for PreparedBatch<'_> {
    fn drop(&mut self) {
        // This also protects Rust early-return/unwind paths. Field destruction
        // (including every LoadCompletion error guard) follows the full join.
        self.join_all();
    }
}

impl NativeSession {
    unsafe fn prepare_model_load(
        &self,
        path: &Path,
        load_options: NativeLoadOptions,
    ) -> Result<PreparedModelLoad<'_>> {
        // SAFETY: This is the existing load_model_with_options preparation body,
        // using only its compiler-verified constructors and option accessors.
        unsafe {
            let path = path
                .to_str()
                .ok_or_else(|| NativeFailure::InvalidData("asset path must be UTF8".into()))?;
            let path = self.string(path)?;
            let mut url = NativeValue::allocate(self.metadata(c"$s10Foundation3URLVMa")?)?;
            let mut options = NativeValue::allocate(
                self.metadata(c"$s15CoreAIDelegates21SpecializationOptionsVMa")?,
            )?;
            let model = NativeValue::allocate(self.metadata(super::super::MODEL_METADATA)?)?;
            // Resolve all fallible symbols before consuming any values.
            let url_init = self.symbol(c"$s10Foundation3URLV15fileURLWithPathACSSh_tcfC")?;
            arm64::call_sync(url_init, [path.words[0], path.words[1], 0], url.ptr(), 0);
            url.initialized = true;
            match load_options.compute {
                NativeCompute::CpuOnly => {
                    self.call(
                        c"$s15CoreAIDelegates21SpecializationOptionsV7cpuOnlyACvgZ",
                        [0; 3],
                        options.ptr(),
                        0,
                    )?;
                }
                NativeCompute::GpuPreferred => {
                    let md = self.metadata(c"$s15CoreAIDelegates15ComputeUnitKindOMa")?;
                    let mut kind = NativeValue::allocate(md)?;
                    self.inject(
                        &mut kind,
                        c"$s15CoreAIDelegates15ComputeUnitKindO3gpuyA2CmFWC",
                    )?;
                    let initialize = self.symbol(c"$s15CoreAIDelegates21SpecializationOptionsV24preferredComputeUnitKindAcA0fgH0O_tcfC")?;
                    arm64::call_sync(initialize, [kind.address(), 0, 0], options.ptr(), 0);
                    kind.initialized = false;
                }
            }
            options.initialized = true;
            if let Some(enabled) = load_options.expect_frequent_reshapes {
                // LoadOptionsReference.swift: Bool in w0; inout/borrowed self
                // in x20. Resolve both accessors before mutation. No field
                // offset or SpecializationOptions representation is assumed.
                let set = self.symbol(
                    c"$s15CoreAIDelegates21SpecializationOptionsV22expectFrequentReshapesSbvs",
                )?;
                let get = self.symbol(
                    c"$s15CoreAIDelegates21SpecializationOptionsV22expectFrequentReshapesSbvg",
                )?;
                arm64::call_sync(
                    set,
                    [usize::from(enabled), 0, 0],
                    ptr::null_mut(),
                    options.address(),
                );
                let actual = arm64::call_sync(get, [0; 3], ptr::null_mut(), options.address());
                if actual & 1 != usize::from(enabled) {
                    return Err(NativeFailure::Binding(
                        "native frequent-reshape option did not round-trip".into(),
                    ));
                }
            }

            let error_release = self.release(c"swift_errorRelease")?;
            Ok(PreparedModelLoad {
                runtime: &self.runtime,
                pending: None,
                model: Some(model),
                url,
                options,
                error_release,
                completion: None,
            })
        }
    }
    /// # Safety
    /// The same session/ABI contracts as loading one model. Every started call
    /// is joined before any success/error cleanup or result is exposed.
    pub unsafe fn load_models_batch(
        &mut self,
        requests: Vec<(PathBuf, NativeLoadOptions)>,
        _profile: bool,
    ) -> NativeBatchOutcome {
        #[cfg(any(feature = "abi-research", test))]
        let probe = _profile.then(|| Arc::new(OverlapProbe::new(requests.len())));
        #[cfg(not(any(feature = "abi-research", test)))]
        let probe: Option<Arc<OverlapProbe>> = None;
        // SAFETY: Each preparation owns its distinct argument/result storage;
        // all calls use the same long-lived runtime and session worker.
        let models = unsafe {
            (|| -> Result<Vec<NativeModel>> {
                let mut batch = PreparedBatch {
                    loads: requests
                        .iter()
                        .map(|(path, options)| self.prepare_model_load(path, *options))
                        .collect::<Result<Vec<_>>>()?,
                };
                let mut first_error = None;
                for load in &mut batch.loads {
                    if let Err(error) = load.start(probe.clone()) {
                        first_error = Some(error);
                        break;
                    }
                }
                // Finish ALL started native operations before reflecting errors,
                // destroying successful models, or freeing any argument allocation.
                batch.join_all();
                for completion in batch
                    .loads
                    .iter_mut()
                    .filter_map(|load| load.completion.as_mut())
                {
                    let error = completion.take_error();
                    let checked = if error != 0 {
                        Err(self.failure(error, "load_models_batch"))
                    } else {
                        Self::lifecycle(&completion.result)
                    };
                    if let Err(error) = checked
                        && first_error.is_none()
                    {
                        first_error = Some(error);
                    }
                }
                if let Some(error) = first_error {
                    return Err(error);
                }
                let mut values = Vec::with_capacity(batch.loads.len());
                for load in &mut batch.loads {
                    let model = load.model.as_ref().expect("prepared model");
                    let names = self.call(
                        c"$s13CoreAIRuntime7AIModelV13functionNamesSaySSGvg",
                        [0; 3],
                        ptr::null_mut(),
                        model.address(),
                    )?;
                    let names = self.strings(names)?;
                    values.push((load.model.take().unwrap(), names));
                }
                drop(batch);
                // Transactional commit: no model is inserted until every result and
                // native reflection succeeded and every ID has been allocated.
                let mut prepared = Vec::with_capacity(values.len());
                for (value, names) in values {
                    prepared.push((self.id()?, value, names));
                }
                let mut models = Vec::with_capacity(prepared.len());
                for (id, value, names) in prepared {
                    self.models.insert(
                        id,
                        ModelRecord {
                            value,
                            names: names.clone(),
                        },
                    );
                    models.push(NativeModel {
                        id,
                        function_names: names,
                    });
                }
                Ok(models)
            })()
        };
        NativeBatchOutcome {
            models,
            #[cfg(any(feature = "abi-research", test))]
            metrics: probe.map(|probe| probe.report()),
        }
    }
}
