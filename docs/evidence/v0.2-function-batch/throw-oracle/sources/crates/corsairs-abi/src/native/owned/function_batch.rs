//! Disposable function materialization batch; all native owners stay on worker.
use super::super::async_task::{OverlapProbe, PendingCall};
use super::*;
#[cfg(feature = "abi-research")]
mod throw_oracle;
use std::sync::Arc;
#[cfg(feature = "abi-research")]
pub use throw_oracle::FunctionThrowReport;

pub struct NativeFunctionBatchOutcome {
    pub functions: Result<Vec<NativeFunction>>,
    #[cfg(any(feature = "abi-research", test))]
    pub metrics: Option<super::batch::NativeBatchMetrics>,
}

struct CompletionGuard {
    result: super::super::async_task::AsyncResult,
    release: unsafe extern "C" fn(*mut c_void),
}
impl Drop for CompletionGuard {
    fn drop(&mut self) {
        if self.result.error != 0 {
            // SAFETY: Unique unclaimed owned synchronous Swift error +1.
            unsafe { (self.release)(self.result.error as _) };
        }
    }
}

struct PreparedFunctionLoad<'session> {
    runtime: &'session Runtime,
    model: &'session ModelRecord,
    model_id: u64,
    name: NativeString,
    requested_name: String,
    output: Option<NativeValue>,
    function_metadata: NativeMetadata,
    release_error: unsafe extern "C" fn(*mut c_void),
    pending: Option<PendingCall<'session>>,
    completion: Option<CompletionGuard>,
}
impl PreparedFunctionLoad<'_> {
    unsafe fn start(&mut self, probe: Option<Arc<OverlapProbe>>) -> Result<()> {
        // SAFETY: SDK AIModel is Sendable; loadFunction is nonmutating. The
        // worker retains this distinct model, String and result storage. Only
        // their stable native addresses/word arguments enter the Swift task.
        let pending = unsafe {
            self.runtime.start_sync_native(
                c"$s13CoreAIRuntime7AIModelV12loadFunction5namedAA09InferenceE0VSgSS_tKF",
                [
                    self.name.words[0],
                    self.name.words[1],
                    0,
                    self.output.as_ref().unwrap().address(),
                ],
                self.model.value.address(),
                probe,
            )?
        };
        self.pending = Some(pending);
        Ok(())
    }
    fn join(&mut self) {
        if let Some(pending) = self.pending.take() {
            let result = pending.wait();
            self.output.as_mut().unwrap().initialized = result.error == 0;
            self.completion = Some(CompletionGuard {
                result,
                release: self.release_error,
            });
        }
    }
}
impl Drop for PreparedFunctionLoad<'_> {
    fn drop(&mut self) {
        self.join();
    }
}
struct PreparedBatch<'session> {
    loads: Vec<PreparedFunctionLoad<'session>>,
}
impl PreparedBatch<'_> {
    fn join_all(&mut self) {
        for load in &mut self.loads {
            load.join();
        }
    }
}
impl Drop for PreparedBatch<'_> {
    fn drop(&mut self) {
        // Join the entire started set before ANY field/native owner destruction.
        self.join_all();
    }
}

impl NativeSession {
    unsafe fn prepare_function_load(
        &self,
        model: u64,
        name: String,
    ) -> Result<PreparedFunctionLoad<'_>> {
        // SAFETY: Preparation stays on the existing owner and starts no task.
        unsafe {
            let model_record = self
                .models
                .get(&model)
                .ok_or(NativeFailure::InvalidHandle {
                    kind: "model",
                    id: model,
                })?;
            let function_metadata = self.metadata(super::super::FUNCTION_METADATA)?;
            let output = NativeValue::allocate(self.optional(function_metadata)?)?;
            let native_name = self.string(&name)?;
            let release_error = self.release(c"swift_errorRelease")?;
            Ok(PreparedFunctionLoad {
                runtime: &self.runtime,
                model: model_record,
                model_id: model,
                name: native_name,
                requested_name: name,
                output: Some(output),
                function_metadata,
                release_error,
                pending: None,
                completion: None,
            })
        }
    }
    /// # Safety
    /// SDK Sendable/nonmutating synchronous function-load contract. This method
    /// remains owner-thread-only; every started native task joins before cleanup.
    pub unsafe fn load_functions_batch(
        &mut self,
        requests: Vec<(u64, String)>,
        _profile: bool,
    ) -> NativeFunctionBatchOutcome {
        #[cfg(any(feature = "abi-research", test))]
        let probe = _profile.then(|| Arc::new(OverlapProbe::new(requests.len())));
        #[cfg(not(any(feature = "abi-research", test)))]
        let probe: Option<Arc<OverlapProbe>> = None;
        // SAFETY: Distinct borrowed native model storage and disjoint owned
        // results survive every callback. Session maps never enter callbacks.
        let functions = unsafe {
            (|| -> Result<Vec<NativeFunction>> {
                let mut models = HashSet::new();
                if requests.iter().any(|(model, _)| !models.insert(*model)) {
                    return Err(NativeFailure::Unsupported(
                        "function batches require distinct model handles".into(),
                    ));
                }
                let mut batch = PreparedBatch {
                    loads: requests
                        .into_iter()
                        .map(|(model, name)| self.prepare_function_load(model, name))
                        .collect::<Result<Vec<_>>>()?,
                };
                let mut first_error = None;
                for load in &mut batch.loads {
                    if let Err(error) = load.start(probe.clone()) {
                        first_error = Some(error);
                        break;
                    }
                }
                batch.join_all();
                for completion in batch
                    .loads
                    .iter_mut()
                    .filter_map(|load| load.completion.as_mut())
                {
                    let error = mem::take(&mut completion.result.error);
                    let checked = if error == 0 {
                        Self::lifecycle(&completion.result)
                    } else {
                        Err(self.failure(error, "load_functions_batch"))
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
                    let function = load
                        .output
                        .as_mut()
                        .unwrap()
                        .take_optional(load.function_metadata)?
                        .ok_or_else(|| {
                            NativeFailure::InvalidData(format!(
                                "function {} was not found",
                                load.requested_name
                            ))
                        })?;
                    let descriptor = self.inspect_function(&function)?;
                    values.push((function, descriptor, load.model_id));
                }
                drop(batch);
                // Resolve all fallible reflection and ID allocation before any
                // function is inserted into the worker's native session store.
                let mut prepared = Vec::with_capacity(values.len());
                for (value, descriptor, model) in values {
                    prepared.push((self.id()?, value, descriptor, model));
                }
                let mut result = Vec::with_capacity(prepared.len());
                for (id, value, descriptor, model) in prepared {
                    self.functions.insert(
                        id,
                        FunctionRecord {
                            value,
                            descriptor: descriptor.clone(),
                            model,
                        },
                    );
                    result.push(NativeFunction { id, descriptor });
                }
                Ok(result)
            })()
        };
        NativeFunctionBatchOutcome {
            functions,
            #[cfg(any(feature = "abi-research", test))]
            metrics: probe.map(|probe| probe.report()),
        }
    }
}
