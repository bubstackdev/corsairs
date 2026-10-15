//! Development-only executable; dynamically loads the pinned Swift oracle ABI.
use corsairs::{Compute, ModelLoadRequest, Runtime};
use std::path::PathBuf;
fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args = std::env::args_os()
        .skip(1)
        .map(PathBuf::from)
        .collect::<Vec<_>>();
    if args.len() != 2 {
        return Err("usage: throw-probe MODEL ORACLE_DYLIB".into());
    }
    let runtime = Runtime::new()?;
    let models = runtime
        .load_models(
            (0..4)
                .map(|_| ModelLoadRequest {
                    path: args[0].clone(),
                    options: Compute::CpuOnly.into(),
                })
                .collect(),
        )
        .wait()?;
    // SAFETY: Root native runner supplies the exact compiler+SHA-pinned test
    // dylib from FunctionThrowOracle.swift, never arbitrary application code.
    let report = unsafe { runtime.function_throw_probe(args[1].clone(), models, 25) }.wait()?;
    assert_eq!(report.created_payloads, 100);
    assert_eq!(report.destroyed_payloads, 100);
    assert_eq!(report.observed_native_errors, 50);
    assert_eq!(report.invocations, 200);
    println!(
        "{{\"event\":\"swift_throw_lifetime\",\"invocations\":{},\"observed_errors\":{},\"created_payloads\":{},\"destroyed_payloads\":{},\"observed_rounds\":{},\"abandoned_rounds\":{},\"peak_native_inflight\":{},\"error_types\":{:?},\"passed\":true}}",
        report.invocations,
        report.observed_native_errors,
        report.created_payloads,
        report.destroyed_payloads,
        report.observed_rounds,
        report.abandoned_rounds,
        report.peak_in_flight,
        report.error_types
    );
    Ok(())
}
