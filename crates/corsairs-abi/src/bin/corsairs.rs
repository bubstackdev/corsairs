#![forbid(unsafe_code)]
use corsairs::{
    AssetInfo, AssetValue, Compute, DType, FunctionDescriptor, LoadOptions, RunResult, Runtime,
    Tensor, TensorMap,
};
use std::{
    error::Error,
    path::{Path, PathBuf},
    time::Instant,
};

fn main() {
    if let Err(error) = execute() {
        eprintln!("{{\"error\":{}}}", quoted(&error.to_string()));
        std::process::exit(1);
    }
}

fn execute() -> Result<(), Box<dyn Error>> {
    let args: Vec<String> = std::env::args().skip(1).collect();
    if args.is_empty() || args[0] == "--help" || args[0] == "help" {
        println!(
            "corsairs inspect MODEL [--compute cpu|gpu-preferred|neural-engine-preferred] [--function NAME]\ncorsairs run MODEL --input NAME DTYPE SHAPE FILE [--state NAME DTYPE SHAPE FILE] [--output-dir DIR] [--repeat N] [--drop-futures N]\ncorsairs bench MODEL --input NAME DTYPE SHAPE FILE [--compute cpu|gpu-preferred|neural-engine-preferred] [--warmup N] [--repeat N]\nAll commands accept --expect-frequent-reshapes true|false (omitted: SDK default).\nDTYPE: float16|bfloat16|float32|int32|int64|bool. SHAPE: comma-separated dimensions, or scalar."
        );
        return Ok(());
    }
    if args[0] == "--version" {
        println!("corsairs {}", env!("CARGO_PKG_VERSION"));
        return Ok(());
    }
    if args.len() < 2 {
        return Err("a command and model path are required".into());
    }
    let command = &args[0];
    if !["inspect", "run", "bench"].contains(&command.as_str()) {
        return Err(format!("unknown command {command:?}").into());
    }
    let mut compute = Compute::CpuOnly;
    let mut expect_frequent_reshapes = None;
    let mut function_name = "main".to_owned();
    let mut selected_function = false;
    let mut inputs = TensorMap::new();
    let mut states = TensorMap::new();
    let mut directory = None;
    let mut repeat = if command == "bench" { 100 } else { 1 };
    let mut warmup = if command == "bench" { 10 } else { 0 };
    let mut abandoned = 0usize;
    let mut index = 2;
    while index < args.len() {
        let option = &args[index];
        index += 1;
        match option.as_str() {
            "--input" | "--state" => {
                if index + 4 > args.len() {
                    return Err(format!("{option} requires NAME DTYPE SHAPE FILE").into());
                }
                let name = args[index].clone();
                let dtype = parse_dtype(&args[index + 1])?;
                let shape = parse_shape(&args[index + 2])?;
                let bytes = std::fs::read(&args[index + 3])?;
                let tensor = Tensor::from_bytes(dtype, shape, bytes)?;
                let map = if option == "--input" {
                    &mut inputs
                } else {
                    &mut states
                };
                if map.insert(name.clone(), tensor).is_some() {
                    return Err(format!("duplicate {option} {name:?}").into());
                }
                index += 4;
            }
            "--compute" => {
                compute = match next(&args, &mut index, option)? {
                    "cpu" => Compute::CpuOnly,
                    "gpu-preferred" => Compute::GpuPreferred,
                    "neural-engine-preferred" => Compute::NeuralEnginePreferred,
                    value => return Err(format!("unknown compute policy {value:?}").into()),
                };
            }
            "--expect-frequent-reshapes" => {
                expect_frequent_reshapes = Some(parse_bool(next(&args, &mut index, option)?)?);
            }
            "--function" => {
                function_name = next(&args, &mut index, option)?.into();
                selected_function = true;
            }
            "--output-dir" => {
                directory = Some(PathBuf::from(next(&args, &mut index, option)?));
            }
            "--repeat" => {
                repeat = next(&args, &mut index, option)?.parse::<usize>()?;
            }
            "--warmup" => {
                warmup = next(&args, &mut index, option)?.parse::<usize>()?;
            }
            "--drop-futures" => {
                abandoned = next(&args, &mut index, option)?.parse::<usize>()?;
            }
            value => return Err(format!("unknown option {value:?}").into()),
        }
    }
    if repeat == 0 || repeat > 1_000_000 || warmup > 1_000_000 || abandoned > 1_000_000 {
        return Err("repeat must be1..1000000; warmup/drop-futures must be0..1000000".into());
    }
    let runtime = Runtime::new()?;
    let start = Instant::now();
    let model = runtime
        .load_model_with_options(
            &args[1],
            LoadOptions {
                compute,
                expect_frequent_reshapes,
            },
        )
        .wait()?;
    // This is the requested override, not an assertion about effective native
    // specialization. null records that the SDK default was left untouched.
    let reshape_override = match model.load_options().expect_frequent_reshapes {
        Some(true) => "true",
        Some(false) => "false",
        None => "null",
    };
    let load_us = start.elapsed().as_secs_f64() * 1e6;
    if command == "inspect" {
        let names: Vec<_> = if selected_function {
            vec![function_name]
        } else {
            model.function_names().to_vec()
        };
        let mut descriptors = Vec::new();
        for name in names {
            let function = model.load_function(name).wait()?;
            descriptors.push(descriptor_json(function.descriptor()));
        }
        let asset = runtime.inspect_asset(&args[1], true).wait()?;
        let architecture = runtime.device_architecture().wait()?;
        println!(
            "{{\"model\":{},\"compute\":{},\"expect_frequent_reshapes\":{reshape_override},\"device_architecture\":{},\"asset\":{},\"functions\":[{}]}}",
            quoted(&args[1]),
            quoted(compute_name(compute)),
            quoted(&architecture),
            asset_json(&asset),
            descriptors.join(",")
        );
        return Ok(());
    }
    let function = model.load_function(function_name).wait()?;
    // Dropped futures still own independent requests; those jobs can safely
    // finish even after this caller has discarded their output interest.
    for _ in 0..abandoned {
        drop(function.run(inputs.clone(), states.clone()));
    }
    runtime.flush().wait()?;
    let mut last = None;
    let mut samples = Vec::with_capacity(repeat);
    for iteration in 0..warmup + repeat {
        let started = Instant::now();
        let result = function.run(inputs.clone(), states).wait()?;
        let elapsed = started.elapsed().as_secs_f64() * 1e6;
        if iteration >= warmup {
            samples.push(elapsed);
        }
        states = result.states.clone();
        last = Some(result);
    }
    let result = last.ok_or("no inference result")?;
    let payload = result_json(&result, directory.as_deref())?;
    if command == "bench" {
        let mut sorted = samples.clone();
        sorted.sort_by(f64::total_cmp);
        let median = sorted[sorted.len() / 2];
        let p95 = sorted[((sorted.len() - 1) * 95) / 100];
        let samples = samples
            .iter()
            .map(ToString::to_string)
            .collect::<Vec<_>>()
            .join(",");
        println!(
            "{{\"compute\":{},\"expect_frequent_reshapes\":{reshape_override},\"load_us\":{load_us},\"warmup\":{warmup},\"iterations\":{repeat},\"median_us\":{median},\"p95_us\":{p95},\"samples_us\":[{samples}],\"boundary\":\"clone host inputs, allocate native tensors, submit, await, copy outputs/state to host\",{payload}}}",
            quoted(compute_name(compute))
        );
    } else {
        println!(
            "{{\"compute\":{},\"expect_frequent_reshapes\":{reshape_override},\"completed\":{repeat},\"dropped_futures\":{abandoned},{payload}}}",
            quoted(compute_name(compute))
        );
    }
    drop(function);
    drop(model);
    runtime.flush().wait()?;
    Ok(())
}
fn next<'a>(
    args: &'a [String],
    index: &mut usize,
    option: &str,
) -> Result<&'a str, Box<dyn Error>> {
    let value = args
        .get(*index)
        .ok_or_else(|| format!("{option} requires a value"))?;
    *index += 1;
    Ok(value)
}
fn parse_dtype(value: &str) -> Result<DType, Box<dyn Error>> {
    Ok(match value {
        "float16" => DType::Float16,
        "bfloat16" => DType::BFloat16,
        "float32" => DType::Float32,
        "int32" => DType::Int32,
        "int64" => DType::Int64,
        "bool" => DType::Bool,
        _ => return Err(format!("unsupported dtype {value:?}").into()),
    })
}
fn parse_bool(value: &str) -> Result<bool, Box<dyn Error>> {
    match value {
        "true" => Ok(true),
        "false" => Ok(false),
        _ => Err(format!("expected true or false, got {value:?}").into()),
    }
}
fn parse_shape(value: &str) -> Result<Vec<usize>, Box<dyn Error>> {
    if value == "scalar" {
        return Ok(vec![]);
    }
    value
        .split(',')
        .map(|n| n.parse::<usize>().map_err(Into::into))
        .collect()
}
fn compute_name(value: Compute) -> &'static str {
    match value {
        Compute::CpuOnly => "cpu",
        Compute::GpuPreferred => "gpu-preferred",
        Compute::NeuralEnginePreferred => "neural-engine-preferred",
        _ => "unknown",
    }
}
fn descriptor_json(value: &FunctionDescriptor) -> String {
    let group = |descriptors: &[corsairs::TensorDescriptor]| {
        descriptors
            .iter()
            .map(|d| {
                let shape = d
                    .shape
                    .iter()
                    .map(|n| n.map_or("null".into(), |n| n.to_string()))
                    .collect::<Vec<_>>()
                    .join(",");
                format!(
                    "{{\"name\":{},\"dtype\":{},\"shape\":[{shape}]}}",
                    quoted(&d.name),
                    quoted(d.dtype.name())
                )
            })
            .collect::<Vec<_>>()
            .join(",")
    };
    format!(
        "{{\"name\":{},\"inputs\":[{}],\"outputs\":[{}],\"states\":[{}]}}",
        quoted(&value.name),
        group(&value.inputs),
        group(&value.outputs),
        group(&value.states)
    )
}
fn result_json(value: &RunResult, directory: Option<&Path>) -> Result<String, Box<dyn Error>> {
    if let Some(directory) = directory {
        std::fs::create_dir_all(directory)?;
    }
    let mut groups = Vec::new();
    for (group, tensors) in [("outputs", &value.outputs), ("states", &value.states)] {
        let mut rows = Vec::new();
        for (index, (name, tensor)) in tensors.iter().enumerate() {
            let file = if let Some(directory) = directory {
                let path = directory.join(format!("{group}-{index}.bin"));
                std::fs::write(&path, tensor.as_bytes())?;
                quoted(&path.to_string_lossy())
            } else {
                "null".into()
            };
            let hex = if directory.is_none() {
                quoted(
                    &tensor
                        .as_bytes()
                        .iter()
                        .map(|b| format!("{b:02x}"))
                        .collect::<String>(),
                )
            } else {
                "null".into()
            };
            rows.push(format!("{{\"name\":{},\"dtype\":{},\"shape\":{:?},\"strides\":{:?},\"file\":{file},\"hex\":{hex}}}",quoted(name),quoted(tensor.dtype().name()),tensor.shape(),tensor.strides()));
        }
        groups.push(format!("{}:[{}]", quoted(group), rows.join(",")));
    }
    Ok(groups.join(","))
}
fn asset_json(asset: &AssetInfo) -> String {
    let created = asset
        .metadata
        .created
        .and_then(|time| time.duration_since(std::time::UNIX_EPOCH).ok())
        .map_or("null".into(), |since| since.as_secs_f64().to_string());
    let values = |values: &[AssetValue]| {
        let rows: Vec<_> = values
            .iter()
            .map(|v| {
                format!(
                    "{{\"name\":{},\"type_name\":{}}}",
                    quoted(&v.name),
                    quoted(&v.type_name)
                )
            })
            .collect();
        format!("[{}]", rows.join(","))
    };
    let summary = asset.summary.as_ref().map_or("null".into(), |summary| {
        let functions: Vec<_> = summary
            .functions
            .iter()
            .map(|f| {
                format!(
                    "{{\"name\":{},\"inputs\":{},\"states\":{},\"outputs\":{}}}",
                    quoted(&f.name),
                    values(&f.inputs),
                    values(&f.states),
                    values(&f.outputs)
                )
            })
            .collect();
        let counts = |rows: &[corsairs::AssetCount]| {
            let rows: Vec<_> = rows
                .iter()
                .map(|row| format!("{{\"name\":{},\"count\":{}}}", quoted(&row.name), row.count))
                .collect();
            format!("[{}]", rows.join(","))
        };
        let compute: Vec<_> = summary
            .compute_types
            .iter()
            .map(|name| quoted(name))
            .collect();
        format!(
            "{{\"functions\":[{}],\"storage_types\":{},\"compute_types\":[{}],\"operations\":{}}}",
            functions.join(","),
            counts(&summary.storage_types),
            compute.join(","),
            counts(&summary.operations)
        )
    });
    format!(
        "{{\"author\":{},\"license\":{},\"description\":{},\"created_unix_seconds\":{created},\"summary\":{summary}}}",
        quoted(&asset.metadata.author),
        quoted(&asset.metadata.license),
        quoted(&asset.metadata.description)
    )
}
fn quoted(value: &str) -> String {
    use std::fmt::Write;
    let mut result = String::from("\"");
    for c in value.chars() {
        match c {
            '"' => result.push_str("\\\""),
            '\\' => result.push_str("\\\\"),
            c if c <= '\u{1f}' => write!(&mut result, "\\u{:04x}", c as u32).unwrap(),
            c => result.push(c),
        }
    }
    result.push('"');
    result
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn reshape_override_requires_an_explicit_boolean() {
        assert!(parse_bool("true").unwrap());
        assert!(!parse_bool("false").unwrap());
        for value in ["1", "0", "yes", "False", ""] {
            assert!(parse_bool(value).is_err());
        }
    }
}
