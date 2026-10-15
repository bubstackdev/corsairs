//! Disposable test-only oracle reuses production PendingCall and join-all guards.
use super::*;
use std::path::Path;

#[derive(Debug)]
pub struct FunctionThrowReport {
    pub observed_rounds: usize,
    pub abandoned_rounds: usize,
    pub invocations: usize,
    pub observed_native_errors: usize,
    pub created_payloads: u32,
    pub destroyed_payloads: u32,
    pub peak_in_flight: usize,
    pub error_types: Vec<String>,
}
impl NativeSession {
    /// # Safety
    /// `path` is exactly the pinned FunctionThrowOracle.swift dylib. Never part
    /// of the ordinary product; every owner remains in this disposable worker.
    pub unsafe fn function_throw_oracle(
        &self,
        path: &Path,
        models: &[u64],
        rounds: usize,
    ) -> Result<FunctionThrowReport> {
        if models.len() != 4 || !(1..=1000).contains(&rounds) {
            return Err(NativeFailure::InvalidData(
                "oracle requires four models and1..1000rounds".into(),
            ));
        }
        let path = CString::new(
            path.to_str()
                .ok_or_else(|| NativeFailure::InvalidData("oracle path UTF8".into()))?,
        )
        .map_err(|e| NativeFailure::InvalidData(e.to_string()))?;
        // SAFETY: Exact test-only library. Pin Swift metadata/code through process
        // exit; dlopen handle itself balances. No runtime Swift unload is assumed.
        let runtime = Runtime {
            // SAFETY: Pinned test library and existing verified SDK dlopen flags.
            library: unsafe {
                super::super::super::loader::Library::open_flags(&path, 2 | 4 | 0x80)?
            },
        };
        let counts = runtime
            .library
            .symbol(c"corsairs_function_throw_counts")?
            .as_ptr();
        // SAFETY: Independent @_cdecl oracle returns exactly packed UInt32 counts.
        let counts =
            unsafe { mem::transmute::<*mut c_void, unsafe extern "C" fn() -> u64>(counts) };
        // SAFETY: This C entry only snapshots a synchronized Swift counter.
        let before = unsafe { counts() };
        let mut report = FunctionThrowReport {
            observed_rounds: rounds,
            abandoned_rounds: rounds,
            invocations: 0,
            observed_native_errors: 0,
            created_payloads: 0,
            destroyed_payloads: 0,
            peak_in_flight: 0,
            error_types: Vec::new(),
        };
        for abandoned in [false, true] {
            for _ in 0..rounds {
                let probe = Arc::new(OverlapProbe::new(4));
                // SAFETY: Preparation uses existing worker-only argument owners.
                let mut batch = PreparedBatch {
                    loads: models
                        .iter()
                        .enumerate()
                        .map(|(index, model)| {
                            // SAFETY: Existing worker-only native argument preparation.
                            unsafe {
                                self.prepare_function_load(
                                    *model,
                                    if index % 2 == 1 {
                                        "__corsairs_swift_throw__"
                                    } else {
                                        "main"
                                    }
                                    .into(),
                                )
                            }
                        })
                        .collect::<Result<Vec<_>>>()?,
                };
                for load in &mut batch.loads {
                    // SAFETY: Exact compiler-verified instance-method oracle shape.
                    // The retained model/name/output allocations are the original
                    // production PreparedFunctionLoad owners, with no Rust map
                    // access inside callbacks. Any early return drops the batch
                    // guard, which joins ALL started calls before owner cleanup.
                    let pending = unsafe {
                        runtime.start_sync_native(
                            c"corsairs_function_throw_oracle",
                            [
                                load.name.words[0],
                                load.name.words[1],
                                0,
                                load.output.as_ref().unwrap().address(),
                            ],
                            load.model.value.address(),
                            Some(Arc::clone(&probe)),
                        )?
                    };
                    load.pending = Some(pending);
                }
                if abandoned {
                    // Production batch drop joins, then unclaimed Error guards
                    // release the native +1 without any reflection/observation.
                    drop(batch);
                } else {
                    batch.join_all();
                    for completion in batch
                        .loads
                        .iter_mut()
                        .map(|load| load.completion.as_mut().unwrap())
                    {
                        Self::lifecycle(&completion.result)?;
                        let error = mem::take(&mut completion.result.error);
                        if error != 0 {
                            // SAFETY: Actual Swift throw returned owned x21 error.
                            let error = unsafe { self.failure(error, "function_throw_oracle") };
                            match error {
                                NativeFailure::Native { type_name, .. }
                                    if type_name.contains("DeliberateFailure") =>
                                {
                                    report.observed_native_errors += 1;
                                    if !report.error_types.contains(&type_name) {
                                        report.error_types.push(type_name);
                                    }
                                }
                                error => return Err(error),
                            }
                        }
                    }
                    drop(batch);
                }
                let metrics = probe.report();
                if metrics.entries != 4 || metrics.returns != 4 || metrics.active_at_join != 0 {
                    return Err(NativeFailure::Binding(
                        "oracle calls did not all join".into(),
                    ));
                }
                report.invocations += metrics.entries;
                report.peak_in_flight = report.peak_in_flight.max(metrics.peak_in_flight);
            }
        }
        // SAFETY: Same synchronized C counter accessor, with all calls joined.
        let after = unsafe { counts() };
        report.created_payloads = ((after >> 32) as u32) - ((before >> 32) as u32);
        report.destroyed_payloads = (after as u32) - (before as u32);
        let expected = (rounds * 4) as u32;
        if report.observed_native_errors != rounds * 2
            || report.created_payloads != expected
            || report.destroyed_payloads != expected
        {
            return Err(NativeFailure::Binding(format!(
                "Swift error payload lifetimes did not balance: {report:?}"
            )));
        }
        Ok(report)
    }
}
