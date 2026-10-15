#![forbid(unsafe_code)]
//! Public-API phase timings. Correctness and transitive cleanup are untimed.
use corsairs::{
    Compute, DType, LoadOptions, MetalBufferMap, MetalValueMap, Runtime, Tensor, TensorHandleMap,
    TensorMap,
};
use std::{collections::BTreeSet, path::PathBuf, time::Instant};

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;
const PHASES: [&str; 8] = [
    "worker_flush",
    "upload_inputs",
    "download_inputs",
    "owned_run",
    "native_run",
    "native_run_download",
    "metal_encode",
    "metal_encode_download",
];
struct Spec {
    name: String,
    dtype: DType,
    shape: Vec<usize>,
    file: PathBuf,
}
struct Args {
    model: PathBuf,
    function: String,
    backend: String,
    reshape: Option<bool>,
    warmup: usize,
    samples: usize,
    output: PathBuf,
    inputs: Vec<Spec>,
    expected: Vec<Spec>,
    phases: Vec<String>,
}
fn dtype(name: &str) -> Result<DType> {
    Ok(match name {
        "float16" => DType::Float16,
        "bfloat16" => DType::BFloat16,
        "float32" => DType::Float32,
        "int32" => DType::Int32,
        "int64" => DType::Int64,
        "bool" => DType::Bool,
        _ => return Err(format!("unsupported dtype {name}").into()),
    })
}
fn parse() -> Result<Args> {
    let mut args = Args {
        model: PathBuf::new(),
        function: "main".into(),
        backend: "cpu".into(),
        reshape: None,
        warmup: 10,
        samples: 100,
        output: PathBuf::new(),
        inputs: vec![],
        expected: vec![],
        phases: PHASES.map(str::to_string).into(),
    };
    let mut values = std::env::args().skip(1);
    let next = |values: &mut std::iter::Skip<std::env::Args>| -> Result<String> {
        values.next().ok_or_else(|| "missing argument value".into())
    };
    while let Some(flag) = values.next() {
        match flag.as_str() {
            "--model" => args.model = next(&mut values)?.into(),
            "--function" => args.function = next(&mut values)?,
            "--backend" => args.backend = next(&mut values)?,
            "--reshape" => args.reshape = match next(&mut values)?.as_str() {
                "default" => None, "true" => Some(true), "false" => Some(false),
                _ => return Err("reshape must be default,true,false".into()),
            },
            "--warmup" => args.warmup = next(&mut values)?.parse()?,
            "--samples" => args.samples = next(&mut values)?.parse()?,
            "--output" => args.output = next(&mut values)?.into(),
            "--phases" => args.phases = next(&mut values)?.split(',').map(str::to_string).collect(),
            "--input" | "--expected" => {
                let name = next(&mut values)?;
                let dtype = dtype(&next(&mut values)?)?;
                let shape = next(&mut values)?;
                let shape = if shape == "scalar" { vec![] } else {
                    shape.split(',').map(str::parse).collect::<std::result::Result<Vec<_>, _>>()?
                };
                let file = next(&mut values)?.into();
                let spec = Spec { name, dtype, shape, file };
                if flag == "--input" { args.inputs.push(spec); } else { args.expected.push(spec); }
            }
            "--help" => return Err("--model PATH --function NAME --backend cpu|gpu-preferred --reshape default|true|false --warmup10 --samples100 --output REPORT --input NAME DTYPE SHAPE FILE [--input ...] --expected NAME DTYPE SHAPE FILE [--expected ...] [--phases comma,list]; scalar shape is 'scalar'".into()),
            _ => return Err(format!("unknown argument {flag}").into()),
        }
    }
    if args.model.as_os_str().is_empty()
        || args.output.as_os_str().is_empty()
        || args.inputs.is_empty()
        || args.expected.is_empty()
        || args.samples == 0
        || args.warmup > 1_000_000
        || args.samples > 1_000_000
        || !["cpu", "gpu-preferred"].contains(&args.backend.as_str())
        || args.phases.is_empty()
        || args.phases.iter().any(|p| !PHASES.contains(&p.as_str()))
    {
        return Err("invalid/incomplete benchmark arguments".into());
    }
    for specs in [&args.inputs, &args.expected] {
        let names: BTreeSet<_> = specs.iter().map(|s| &s.name).collect();
        if names.len() != specs.len() {
            return Err("duplicate tensor name".into());
        }
    }
    Ok(args)
}
fn quoted(value: &str) -> String {
    let mut result = String::from("\"");
    for ch in value.chars() {
        match ch {
            '"' => result.push_str("\\\""),
            '\\' => result.push_str("\\\\"),
            '\n' => result.push_str("\\n"),
            '\r' => result.push_str("\\r"),
            '\t' => result.push_str("\\t"),
            ch if ch < ' ' => result.push_str(&format!("\\u{:04x}", ch as u32)),
            ch => result.push(ch),
        }
    }
    result.push('"');
    result
}
fn sha_file(path: &std::path::Path) -> Result<String> {
    let out = std::process::Command::new("/usr/bin/shasum")
        .args(["-a", "256"])
        .arg(path)
        .output()?;
    if !out.status.success() {
        return Err(String::from_utf8_lossy(&out.stderr).into_owned().into());
    }
    Ok(String::from_utf8(out.stdout)?
        .split_whitespace()
        .next()
        .ok_or("missing digest")?
        .into())
}
fn specs_json(specs: &[Spec]) -> Result<String> {
    specs
        .iter()
        .map(|s| {
            Ok(format!(
                "{{\"name\":{},\"dtype\":{},\"shape\":{:?},\"file\":{},\"sha256\":{}}}",
                quoted(&s.name),
                quoted(&s.dtype.to_string()),
                s.shape,
                quoted(&s.file.to_string_lossy()),
                quoted(&sha_file(&s.file)?)
            ))
        })
        .collect::<Result<Vec<_>>>()
        .map(|v| format!("[{}]", v.join(",")))
}
fn tensors(specs: &[Spec]) -> Result<TensorMap> {
    specs
        .iter()
        .map(|s| {
            Ok((
                s.name.clone(),
                Tensor::from_bytes(s.dtype, s.shape.clone(), std::fs::read(&s.file)?)?,
            ))
        })
        .collect()
}
fn verify(actual: &TensorMap, expected: &TensorMap) -> Result<()> {
    if actual.len() != expected.len() {
        return Err("output name count mismatch".into());
    }
    for (name, wanted) in expected.iter() {
        let actual = actual.get(name).ok_or("missing output")?;
        if actual.dtype() != wanted.dtype()
            || actual.shape() != wanted.shape()
            || actual.as_bytes() != wanted.as_bytes()
        {
            return Err(format!("exact output mismatch: {name}").into());
        }
    }
    Ok(())
}
fn download(handles: &TensorHandleMap) -> Result<TensorMap> {
    handles
        .iter()
        .map(|(name, value)| Ok((name.to_string(), value.download().wait()?)))
        .collect()
}
fn measure<T>(
    runtime: &Runtime,
    args: &Args,
    name: &str,
    boundary: &str,
    mut call: impl FnMut() -> Result<T>,
    mut check: impl FnMut(&T) -> Result<()>,
) -> Result<String> {
    let mut samples = Vec::with_capacity(args.samples);
    for iteration in 0..args.warmup + args.samples {
        let begin = Instant::now();
        let result = call()?;
        let elapsed = begin.elapsed().as_nanos();
        // Exact validation (including any diagnostic readback), result release,
        // and all descendant cleanup occur outside the measured call boundary.
        check(&result)?;
        drop(result);
        runtime.drain().wait()?;
        if iteration >= args.warmup {
            samples.push(elapsed);
        }
    }
    let mut sorted = samples.clone();
    sorted.sort_unstable();
    let count = sorted.len();
    let median = if count % 2 == 0 {
        (sorted[count / 2 - 1] + sorted[count / 2]) as f64 / 2.0
    } else {
        sorted[count / 2] as f64
    };
    let p95 = sorted[(count * 95).div_ceil(100) - 1];
    Ok(format!(
        "{{\"phase\":{},\"boundary\":{},\"warmup\":{},\"samples\":{},\"median_ns\":{},\"p95_ns\":{},\"min_ns\":{},\"max_ns\":{},\"samples_ns\":{:?},\"every_iteration_exact\":true}}",
        quoted(name),
        quoted(boundary),
        args.warmup,
        count,
        median,
        p95,
        sorted[0],
        sorted[count - 1],
        samples
    ))
}
fn run() -> Result<()> {
    let args = parse()?;
    let input_specs = specs_json(&args.inputs)?;
    let output_specs = specs_json(&args.expected)?;
    let asset_sha = sha_file(&args.model.join("main.mlirb"))?;
    let inputs = tensors(&args.inputs)?;
    let expected = tensors(&args.expected)?;
    let runtime = Runtime::new()?;
    let mut options = LoadOptions::new(if args.backend == "cpu" {
        Compute::CpuOnly
    } else {
        Compute::GpuPreferred
    });
    if let Some(value) = args.reshape {
        options = options.with_expect_frequent_reshapes(value);
    }
    let begin = Instant::now();
    let model = runtime
        .load_model_with_options(&args.model, options)
        .wait()?;
    let model_load_ns = begin.elapsed().as_nanos();
    let begin = Instant::now();
    let function = model.load_function(&args.function).wait()?;
    let function_load_ns = begin.elapsed().as_nanos();
    if !function.descriptor().states.is_empty() {
        return Err("benchmark supports stateless cases only".into());
    }
    let native_inputs: TensorHandleMap = inputs
        .iter()
        .map(|(n, t)| Ok((n.to_string(), runtime.upload(t.clone()).wait()?)))
        .collect::<Result<_>>()?;
    runtime.drain().wait()?;
    let mut phases = vec![];
    for name in &args.phases {
        let result = match name.as_str() {
            "worker_flush" => measure(
                &runtime,
                &args,
                name,
                "submit ordered worker marker and wait",
                || Ok(runtime.flush().wait()?),
                |_| Ok(()),
            )?,
            "upload_inputs" => measure(
                &runtime,
                &args,
                name,
                "clone owned input bytes, allocate/upload native tensors, await each",
                || {
                    inputs
                        .iter()
                        .map(|(n, t)| Ok((n.to_string(), runtime.upload(t.clone()).wait()?)))
                        .collect::<Result<TensorHandleMap>>()
                },
                |v| verify(&download(v)?, &inputs),
            )?,
            "download_inputs" => measure(
                &runtime,
                &args,
                name,
                "download persistent native inputs to owned host tensors, await each",
                || download(&native_inputs),
                |v| verify(v, &inputs),
            )?,
            "owned_run" => measure(
                &runtime,
                &args,
                name,
                "clone owned input bytes/map, submit run, wait, return all owned output bytes",
                || Ok(function.run(inputs.clone(), TensorMap::new()).wait()?),
                |v| {
                    if !v.states.is_empty() {
                        return Err("unexpected states".into());
                    }
                    verify(&v.outputs, &expected)
                },
            )?,
            "native_run" => measure(
                &runtime,
                &args,
                name,
                "clone handle map, submit retained native run and wait; no host readback within timing",
                || {
                    Ok(function
                        .run_native(native_inputs.clone(), TensorHandleMap::new())
                        .wait()?)
                },
                |v| verify(&download(&v.outputs)?, &expected),
            )?,
            "native_run_download" => measure(
                &runtime,
                &args,
                name,
                "clone handle map, submit retained native run, wait, download every output",
                || {
                    let result = function
                        .run_native(native_inputs.clone(), TensorHandleMap::new())
                        .wait()?;
                    let downloaded = download(&result.outputs)?;
                    Ok((result, downloaded))
                },
                |v| verify(&v.1, &expected),
            )?,
            "metal_encode" | "metal_encode_download" => {
                let queue = runtime.metal_queue().wait()?;
                let metal_inputs: MetalValueMap = inputs
                    .iter()
                    .map(|(n, t)| Ok((n.to_string(), queue.upload(t.clone()).wait()?)))
                    .collect::<Result<_>>()?;
                let bindings: MetalBufferMap = expected
                    .iter()
                    .map(|(n, t)| {
                        Ok((
                            n.to_string(),
                            queue.buffer(t.dtype(), t.shape().to_vec()).wait()?,
                        ))
                    })
                    .collect::<Result<_>>()?;
                let result = if name == "metal_encode" {
                    measure(
                        &runtime,
                        &args,
                        name,
                        "clone persistent input/output maps, encode with reused fixed output buffers and public fence/readiness; no host readback within timing",
                        || {
                            Ok(function
                                .encode(
                                    &queue,
                                    metal_inputs.clone(),
                                    MetalBufferMap::new(),
                                    bindings.clone(),
                                )
                                .wait()?)
                        },
                        |v| {
                            let downloaded: TensorMap = v
                                .outputs
                                .iter()
                                .map(|(n, value)| Ok((n.to_string(), value.download().wait()?)))
                                .collect::<Result<_>>()?;
                            verify(&downloaded, &expected)
                        },
                    )?
                } else {
                    measure(
                        &runtime,
                        &args,
                        name,
                        "clone persistent input/output maps, encode with reused fixed output buffers, public fence/readiness, download every output",
                        || {
                            let result = function
                                .encode(
                                    &queue,
                                    metal_inputs.clone(),
                                    MetalBufferMap::new(),
                                    bindings.clone(),
                                )
                                .wait()?;
                            let downloaded: TensorMap = result
                                .outputs
                                .iter()
                                .map(|(n, v)| Ok((n.to_string(), v.download().wait()?)))
                                .collect::<Result<_>>()?;
                            Ok((result, downloaded))
                        },
                        |v| verify(&v.1, &expected),
                    )?
                };
                drop(bindings);
                drop(metal_inputs);
                drop(queue);
                runtime.drain().wait()?;
                result
            }
            _ => unreachable!(),
        };
        phases.push(result);
    }
    drop(native_inputs);
    drop(function);
    drop(model);
    runtime.drain().wait()?;
    let reshape = args.reshape.map(|v| v.to_string()).unwrap_or("null".into());
    let report = format!(
        "{{\"schema\":1,\"language\":\"rust\",\"public_api_only\":true,\"passed\":true,\"backend\":{},\"expect_frequent_reshapes\":{},\"model\":{},\"function\":{},\"model_main_mlirb_sha256\":{},\"model_load_ns\":{},\"function_load_ns\":{},\"inputs\":{},\"expected_outputs\":{},\"phases\":[{}],\"timing_clock\":\"std::time::Instant\",\"cleanup\":\"exact validation, diagnostic readback, output drop and Runtime::drain outside every measured interval\",\"limits\":\"Sequential warm stateless calls; persistent retained/Metal inputs and buffers prepared outside timing; no pipeline/device concurrency claim; loading observed separately without cache purge\"}}\n",
        quoted(&args.backend),
        reshape,
        quoted(&args.model.to_string_lossy()),
        quoted(&args.function),
        quoted(&asset_sha),
        model_load_ns,
        function_load_ns,
        input_specs,
        output_specs,
        phases.join(",")
    );
    if let Some(parent) = args.output.parent() {
        std::fs::create_dir_all(parent)?;
    }
    std::fs::write(&args.output, report)?;
    println!(
        "{{\"passed\":true,\"report\":{}}}",
        quoted(&args.output.to_string_lossy())
    );
    Ok(())
}
fn main() -> Result<()> {
    run()
}
