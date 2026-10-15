//! Same-runtime synchronous function materialization batches.
use super::*;

#[derive(Clone)]
/// One named function to materialize from a retained model.
pub struct FunctionLoadRequest {
    /// Model loaded by the runtime receiving this batch.
    pub model: Model,
    /// Named function to load.
    pub name: String,
}
#[cfg(any(feature = "abi-research", test))]
/// Development diagnostics for a completed function-materialization batch.
pub struct FunctionBatchLoadReport {
    /// Functions in request order, or one error after every started call joined.
    pub result: Result<Vec<Function>, Error>,
    /// Overlapping synchronous native invocation lifetimes; no GPU concurrency claim.
    pub metrics: crate::native::NativeBatchMetrics,
}
struct BatchOutcome {
    result: Result<Vec<Function>, Error>,
    #[cfg(any(feature = "abi-research", test))]
    metrics: Option<crate::native::NativeBatchMetrics>,
}
impl Runtime {
    /// Materialize functions from distinct models on this runtime, starting
    /// their synchronous native loads on Swift tasks before joining the batch.
    /// Returned functions preserve request order and retain their source models.
    ///
    /// All started calls finish before success or error is returned. A failure
    /// releases successful functions from that batch. Dropping the task preserves
    /// this cleanup guarantee. Duplicate model handles and models from another
    /// runtime are rejected; an empty batch returns an empty list.
    /// Overlapping invocation lifetimes do not guarantee lower wall time.
    pub fn load_functions(&self, requests: Vec<FunctionLoadRequest>) -> Task<Vec<Function>> {
        let runtime = self.clone();
        self.worker
            .submit(move |session| load_batch(session, &runtime, requests, false).result)
    }
    #[cfg(any(feature = "abi-research", test))]
    /// Development timing/counts for synchronous native function invocations.
    pub fn load_functions_profiled(
        &self,
        requests: Vec<FunctionLoadRequest>,
    ) -> Task<FunctionBatchLoadReport> {
        let runtime = self.clone();
        self.worker.submit(move |session| {
            let outcome = load_batch(session, &runtime, requests, true);
            match (outcome.result, outcome.metrics) {
                (result, Some(metrics)) => Ok(FunctionBatchLoadReport { result, metrics }),
                (Err(error), None) => Err(error),
                (Ok(_), None) => Err(Error::Binding("missing function batch diagnostics".into())),
            }
        })
    }
}
fn load_batch(
    session: &mut NativeSession,
    runtime: &Runtime,
    requests: Vec<FunctionLoadRequest>,
    profile: bool,
) -> BatchOutcome {
    if requests
        .iter()
        .any(|request| !request.model.0.runtime.worker.same_worker(&runtime.worker))
    {
        return BatchOutcome {
            result: Err(Error::Unsupported(
                "function batch models must belong to this runtime".into(),
            )),
            #[cfg(any(feature = "abi-research", test))]
            metrics: None,
        };
    }
    let native_requests = requests
        .iter()
        .map(|request| (request.model.0.id, request.name.clone()))
        .collect();
    // SAFETY: This worker owns the session and all requested models. The native
    // batch keeps all argument/output owners until every started call joins.
    let outcome: crate::native::NativeFunctionBatchOutcome =
        unsafe { session.load_functions_batch(native_requests, profile) };
    let result = outcome.functions.map_err(native_error).map(|functions| {
        functions
            .into_iter()
            .zip(requests)
            .map(|(function, request)| {
                Function(Arc::new(FunctionInner {
                    id: function.id,
                    descriptor: descriptor(function.descriptor),
                    model: request.model,
                }))
            })
            .collect()
    });
    BatchOutcome {
        result,
        #[cfg(any(feature = "abi-research", test))]
        metrics: outcome.metrics,
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    fn counts(runtime: &Runtime) -> (usize, usize) {
        runtime
            .worker
            .submit(|session| Ok(session.live_counts()))
            .wait()
            .unwrap()
    }
    fn settle(runtime: &Runtime) {
        for _ in 0..4 {
            runtime.flush().wait().unwrap();
        }
    }
    #[test]
    #[ignore = "requires permitted Core AI and CORSAIRS_TEST_MODEL x+x fixture"]
    fn native_function_batch_join_and_drop_cleanup() {
        let runtime = Runtime::new().unwrap();
        let path =
            PathBuf::from(std::env::var_os("CORSAIRS_TEST_MODEL").expect("CORSAIRS_TEST_MODEL"));
        {
            let models = runtime
                .load_models(
                    (0..3)
                        .map(|_| ModelLoadRequest {
                            path: path.clone(),
                            options: Compute::CpuOnly.into(),
                        })
                        .collect(),
                )
                .wait()
                .unwrap();
            let requests = models
                .iter()
                .map(|model| FunctionLoadRequest {
                    model: model.clone(),
                    name: "main".into(),
                })
                .collect::<Vec<_>>();
            let baseline = counts(&runtime);
            {
                let report = runtime
                    .load_functions_profiled(requests.clone())
                    .wait()
                    .unwrap();
                assert_eq!(report.metrics.entries, 3);
                assert_eq!(report.metrics.returns, 3);
                assert_eq!(report.metrics.active_at_join, 0);
                let functions = report.result.unwrap();
                assert_eq!(functions.len(), 3);
                assert_eq!(counts(&runtime), (baseline.0, baseline.1 + 3));
            }
            settle(&runtime);
            assert_eq!(counts(&runtime), baseline);
            let mut bad = requests.clone();
            bad[1].name = "__corsairs_missing_function__".into();
            let report = runtime.load_functions_profiled(bad).wait().unwrap();
            assert!(matches!(report.result, Err(Error::FunctionNotFound(_))));
            assert_eq!(report.metrics.entries, 3);
            assert_eq!(report.metrics.returns, 3);
            assert_eq!(report.metrics.active_at_join, 0);
            assert_eq!(counts(&runtime), baseline);
            let duplicate = runtime
                .load_functions_profiled(vec![requests[0].clone(), requests[0].clone()])
                .wait()
                .unwrap();
            assert!(duplicate.result.is_err());
            assert_eq!(duplicate.metrics.entries, 0);
            let empty = runtime.load_functions_profiled(Vec::new()).wait().unwrap();
            assert!(empty.result.unwrap().is_empty());
            assert_eq!(empty.metrics.entries, 0);
            assert_eq!(empty.metrics.returns, 0);
            assert_eq!(empty.metrics.active_at_join, 0);
            assert!(
                runtime
                    .load_functions(Vec::new())
                    .wait()
                    .unwrap()
                    .is_empty()
            );
            for _ in 0..5 {
                drop(runtime.load_functions(requests.clone()));
            }
            settle(&runtime);
            assert_eq!(counts(&runtime), baseline);
        }
        settle(&runtime);
        assert_eq!(counts(&runtime), (0, 0));
    }
}
