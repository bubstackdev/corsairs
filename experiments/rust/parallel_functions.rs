#![forbid(unsafe_code)]
//! Function-load overlap/correctness driver; requires abi-research.
use corsairs::{
    BatchLoadMetrics, Compute, FunctionLoadRequest, ModelLoadRequest, Runtime, Tensor,
    TensorHandleMap,
};
use std::path::PathBuf;
use std::time::Instant;

fn report(name: &str, metrics: &BatchLoadMetrics, elapsed: u128) {
    println!(
        "{{\"event\":\"function_batch\",\"name\":{name:?},\"peak_native_inflight\":{},\"active_at_join\":{},\"entries\":{},\"returns\":{},\"elapsed_us\":{elapsed}}}",
        metrics.peak_in_flight, metrics.active_at_join, metrics.entries, metrics.returns
    );
    for event in &metrics.events {
        println!(
            "{{\"event\":\"function_interval\",\"batch\":{name:?},\"task\":{},\"stage\":{:?},\"elapsed_ns\":{}}}",
            event.task, event.stage, event.elapsed_nanos
        );
    }
    assert_eq!(metrics.active_at_join, 0);
    assert_eq!(metrics.entries, metrics.returns);
}
fn main() -> Result<(), Box<dyn std::error::Error>> {
    let path = PathBuf::from(
        std::env::args_os()
            .nth(1)
            .ok_or("usage: function-load DOUBLE_MODEL")?,
    );
    let runtime = Runtime::new()?;
    let models = runtime
        .load_models(vec![
            ModelLoadRequest {
                path: path.clone(),
                options: Compute::CpuOnly.into(),
            },
            ModelLoadRequest {
                path: path.clone(),
                options: Compute::GpuPreferred.into(),
            },
            ModelLoadRequest {
                path,
                options: Compute::CpuOnly.into(),
            },
        ])
        .wait()?;
    let requests = models
        .iter()
        .map(|model| FunctionLoadRequest {
            model: model.clone(),
            name: "main".into(),
        })
        .collect::<Vec<_>>();
    let clock = Instant::now();
    let loaded = runtime.load_functions_profiled(requests.clone()).wait()?;
    report("success", &loaded.metrics, clock.elapsed().as_micros());
    assert_eq!(loaded.metrics.entries, 3);
    let functions = loaded.result?;
    assert_eq!(functions.len(), 3);
    let input = runtime
        .upload(Tensor::from_vec([2, 3], vec![1f32; 6])?)
        .wait()?;
    let mut first = functions[0]
        .run_native(
            TensorHandleMap::from([("x", input)]),
            TensorHandleMap::new(),
        )
        .wait()?;
    let input = first.outputs.remove("y").ok_or("missing first output")?;
    let result = functions[2]
        .run_native(
            TensorHandleMap::from([("x", input)]),
            TensorHandleMap::new(),
        )
        .wait()?;
    assert_eq!(
        result
            .outputs
            .get("y")
            .ok_or("missing final output")?
            .download()
            .wait()?
            .to_vec::<f32>()?,
        [4.; 6]
    );
    println!("{{\"event\":\"same_runtime_function_chain\",\"passed\":true}}");
    let mut bad = requests.clone();
    bad[1].name = "__corsairs_intentionally_missing__".into();
    let clock = Instant::now();
    let failed = runtime.load_functions_profiled(bad).wait()?;
    report(
        "one_missing_function",
        &failed.metrics,
        clock.elapsed().as_micros(),
    );
    assert_eq!(failed.metrics.entries, 3);
    assert!(failed.result.is_err());
    let duplicate = runtime
        .load_functions_profiled(vec![requests[0].clone(), requests[0].clone()])
        .wait()?;
    assert!(duplicate.result.is_err());
    assert_eq!(duplicate.metrics.entries, 0);
    drop(runtime.load_functions(requests));
    runtime.flush().wait()?;
    runtime.flush().wait()?;
    let recovered = models[0].load_function("main").wait()?;
    assert_eq!(recovered.descriptor().name, "main");
    assert!(runtime.load_functions(Vec::new()).wait()?.is_empty());
    let other = Runtime::new()?;
    assert!(
        other
            .load_functions(vec![FunctionLoadRequest {
                model: models[0].clone(),
                name: "main".into()
            }])
            .wait()
            .is_err()
    );
    println!(
        "{{\"event\":\"complete\",\"correctness_passed\":true,\"overlap_is_reported_separately\":true}}"
    );
    Ok(())
}
