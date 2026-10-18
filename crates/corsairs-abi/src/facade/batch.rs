//! Same-runtime model batch loading.
use super::*;
#[cfg(any(feature = "abi-research", test))]
pub type BatchLoadMetrics = crate::native::NativeBatchMetrics;
/// One asset and its specialization choices for [`Runtime::load_models`].
#[derive(Clone, Debug)]
pub struct ModelLoadRequest {
    /// Native `.aimodel` asset path.
    pub path: PathBuf,
    /// Options applied to this model independently of the other batch members.
    pub options: LoadOptions,
}
/// Development diagnostics for overlapping native invocation lifetimes.
#[cfg(any(feature = "abi-research", test))]
pub struct BatchLoadReport {
    pub result: Result<Vec<Model>, Error>,
    pub metrics: BatchLoadMetrics,
}
struct BatchOutcome {
    result: Result<Vec<Model>, Error>,
    #[cfg(any(feature = "abi-research", test))]
    metrics: Option<BatchLoadMetrics>,
}
impl Runtime {
    /// Load several assets on this runtime, starting their native loads before
    /// waiting for the complete batch. Models retain their request order and
    /// individual options, and can exchange native tensor handles.
    ///
    /// Every started load finishes before success or error is returned. If any
    /// load fails, the successful models from that batch are released and one
    /// error is returned. Dropping the task preserves this cleanup guarantee.
    /// Overlapping invocation lifetimes do not guarantee backend concurrency
    /// or lower wall time. An empty request list returns an empty model list.
    pub fn load_models(&self, requests: Vec<ModelLoadRequest>) -> Task<Vec<Model>> {
        let runtime = self.clone();
        self.worker
            .submit(move |session| load_batch(session, runtime, requests, false).result)
    }
    /// Development diagnostics; measures invocation lifetimes, not concurrent
    /// GPU execution. No independent worker or runtime is created.
    #[cfg(any(feature = "abi-research", test))]
    pub fn load_models_profiled(&self, requests: Vec<ModelLoadRequest>) -> Task<BatchLoadReport> {
        let runtime = self.clone();
        self.worker.submit(move |session| {
            let BatchOutcome { result, metrics } = load_batch(session, runtime, requests, true);
            Ok(BatchLoadReport {
                result,
                metrics: metrics.expect("profiling was requested"),
            })
        })
    }
}
fn load_batch(
    session: &mut NativeSession,
    runtime: Runtime,
    requests: Vec<ModelLoadRequest>,
    profile: bool,
) -> BatchOutcome {
    let inputs = requests
        .iter()
        .map(|request| {
            (
                request.path.clone(),
                NativeLoadOptions {
                    compute: request.options.compute.into(),
                    expect_frequent_reshapes: request.options.expect_frequent_reshapes,
                },
            )
        })
        .collect();
    // SAFETY: One worker owns the session and every prepared native argument.
    let outcome: crate::native::NativeBatchOutcome =
        unsafe { session.load_models_batch(inputs, profile) };
    let result = outcome.models.map_err(native_error).map(|models| {
        models
            .into_iter()
            .zip(requests)
            .map(|(model, request)| {
                Model(Arc::new(ModelInner {
                    runtime: runtime.clone(),
                    id: model.id,
                    names: model.function_names,
                    path: request.path,
                    options: request.options,
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
        runtime.flush().wait().unwrap();
        runtime.flush().wait().unwrap();
    }
    #[test]
    #[ignore = "requires permitted Core AI and CORSAIRS_TEST_MODEL x+x fixture"]
    fn native_batch_joins_errors_and_releases_dropped_future_models() {
        let runtime = Runtime::new().unwrap();
        let path =
            PathBuf::from(std::env::var_os("CORSAIRS_TEST_MODEL").expect("CORSAIRS_TEST_MODEL"));
        let request = |compute, reshape| ModelLoadRequest {
            path: path.clone(),
            options: LoadOptions {
                compute,
                expect_frequent_reshapes: reshape,
            },
        };
        let baseline = counts(&runtime);
        {
            let report = runtime
                .load_models_profiled(vec![
                    request(Compute::CpuOnly, Some(false)),
                    request(Compute::GpuPreferred, Some(true)),
                    request(Compute::CpuOnly, None),
                ])
                .wait()
                .unwrap();
            assert_eq!(report.metrics.entries, 3);
            assert_eq!(report.metrics.returns, 3);
            assert_eq!(report.metrics.active_at_join, 0);
            let models = report.result.unwrap();
            assert_eq!(counts(&runtime).0, baseline.0 + 3);
            assert_eq!(
                models[0].load_options().expect_frequent_reshapes,
                Some(false)
            );
            assert_eq!(
                models[1].load_options().expect_frequent_reshapes,
                Some(true)
            );
        }
        settle(&runtime);
        assert_eq!(counts(&runtime), baseline);
        let missing = PathBuf::from(format!(
            "/private/tmp/corsairs-batch-missing-{}.aimodel",
            std::process::id()
        ));
        assert!(!missing.exists());
        let report = runtime
            .load_models_profiled(vec![
                request(Compute::CpuOnly, None),
                ModelLoadRequest {
                    path: missing,
                    options: Compute::CpuOnly.into(),
                },
                request(Compute::GpuPreferred, None),
            ])
            .wait()
            .unwrap();
        assert!(report.result.is_err());
        assert_eq!(report.metrics.entries, 3);
        assert_eq!(report.metrics.returns, 3);
        assert_eq!(report.metrics.active_at_join, 0);
        assert_eq!(counts(&runtime), baseline);
        for _ in 0..5 {
            drop(runtime.load_models(vec![
                request(Compute::CpuOnly, Some(true)),
                request(Compute::GpuPreferred, Some(false)),
            ]));
        }
        settle(&runtime);
        assert_eq!(counts(&runtime), baseline);
    }
}
