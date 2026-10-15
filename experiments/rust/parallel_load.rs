#![forbid(unsafe_code)]
//! Same-runtime batch-load correctness/overlap probe; requires abi-research.
use corsairs::{
    BatchLoadMetrics, Compute, LoadOptions, ModelLoadRequest, Runtime, Tensor, TensorHandleMap,
};
use std::path::PathBuf;
use std::time::Instant;
fn report(name: &str, metrics: &BatchLoadMetrics, elapsed: u128) {
    println!(
        "{{\"event\":\"batch\",\"name\":{name:?},\"peak_native_inflight\":{},\"active_at_join\":{},\"entries\":{},\"returns\":{},\"elapsed_us\":{},\"overlap_observed\":{}}}",
        metrics.peak_in_flight,
        metrics.active_at_join,
        metrics.entries,
        metrics.returns,
        elapsed,
        metrics.peak_in_flight > 1
    );
    for event in &metrics.events {
        println!(
            "{{\"event\":\"native_interval\",\"batch\":{name:?},\"task\":{},\"stage\":{:?},\"elapsed_ns\":{}}}",
            event.task, event.stage, event.elapsed_nanos
        );
    }
    assert_eq!(metrics.active_at_join, 0);
    assert_eq!(metrics.entries, metrics.returns);
}
fn request(path: &PathBuf, compute: Compute, reshape: Option<bool>) -> ModelLoadRequest {
    ModelLoadRequest {
        path: path.clone(),
        options: LoadOptions {
            compute,
            expect_frequent_reshapes: reshape,
        },
    }
}
fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args: Vec<PathBuf> = std::env::args_os().skip(1).map(PathBuf::from).collect();
    if args.len() != 3 {
        return Err("usage: batch-load DOUBLE_MODEL FEEDFORWARD_MODEL MISSING_MODEL".into());
    }
    let runtime = Runtime::new()?;
    let requests = vec![
        request(&args[0], Compute::CpuOnly, Some(false)),
        request(&args[1], Compute::GpuPreferred, Some(true)),
        request(&args[0], Compute::CpuOnly, None),
    ];
    let clock = Instant::now();
    let batch = runtime.load_models_profiled(requests.clone()).wait()?;
    report("success", &batch.metrics, clock.elapsed().as_micros());
    let models = batch.result?;
    assert_eq!(models.len(), 3);
    for (model, request) in models.iter().zip(&requests) {
        assert_eq!(model.load_options(), request.options);
    }
    let first = models[0].load_function("main").wait()?;
    let last = models[2].load_function("main").wait()?;
    let input = runtime
        .upload(Tensor::from_vec([2, 3], vec![1f32; 6])?)
        .wait()?;
    let mut first = first
        .run_native(
            TensorHandleMap::from([("x", input)]),
            TensorHandleMap::new(),
        )
        .wait()?;
    let input = first.outputs.remove("y").ok_or("missing first output")?;
    let last = last
        .run_native(
            TensorHandleMap::from([("x", input)]),
            TensorHandleMap::new(),
        )
        .wait()?;
    assert_eq!(
        last.outputs
            .get("y")
            .ok_or("missing final output")?
            .download()
            .wait()?
            .to_vec::<f32>()?,
        [4.; 6]
    );
    println!("{{\"event\":\"same_runtime_tensor_chain\",\"passed\":true}}");
    let mixed = vec![
        request(&args[0], Compute::CpuOnly, Some(true)),
        request(&args[2], Compute::GpuPreferred, None),
        request(&args[1], Compute::CpuOnly, Some(false)),
    ];
    let clock = Instant::now();
    let failed = runtime.load_models_profiled(mixed).wait()?;
    report(
        "one_bad_asset",
        &failed.metrics,
        clock.elapsed().as_micros(),
    );
    assert!(failed.result.is_err());
    assert_eq!(failed.metrics.entries, 3);
    drop(runtime.load_models(requests));
    runtime.flush().wait()?;
    runtime.flush().wait()?;
    let recovery = runtime.load_model(&args[0], Compute::CpuOnly).wait()?;
    assert!(recovery.function_names().iter().any(|name| name == "main"));
    println!(
        "{{\"event\":\"complete\",\"correctness_passed\":true,\"overlap_is_reported_separately\":true}}"
    );
    Ok(())
}
