#![forbid(unsafe_code)]
//! Bounded H3 acceptance only. External assets stay unchanged; the application
//! fixture supplies tags, rotary tables, timesteps and modulation-cache identity.
use corsairs::{BFloat16, Compute, DType, Function, LoadOptions, Runtime, Tensor, TensorMap};
use std::io::Write;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};
use std::time::Instant;

struct InputSpec {
    name: &'static str,
    dtype: DType,
    shape: &'static [usize],
    path: &'static str,
    narrow_i64: bool,
}
include!(env!("CORSAIRS_H3_DATA"));

fn check(condition: bool, reason: impl Into<String>) -> Result<(), String> {
    condition.then_some(()).ok_or_else(|| reason.into())
}
fn error(value: impl std::fmt::Display) -> String { value.to_string() }
fn quoted(value: &str) -> String {
    let mut out = String::from("\"");
    for ch in value.chars() {
        match ch {
            '"' => out.push_str("\\\""), '\\' => out.push_str("\\\\"),
            '\n' => out.push_str("\\n"), '\r' => out.push_str("\\r"), '\t' => out.push_str("\\t"),
            ch if ch < ' ' => out.push_str(&format!("\\u{:04x}", ch as u32)), ch => out.push(ch),
        }
    }
    out.push('"'); out
}
fn hash(bytes: &[u8]) -> Result<String, String> {
    let mut child = Command::new("/usr/bin/shasum").args(["-a", "256"])
        .stdin(Stdio::piped()).stdout(Stdio::piped()).stderr(Stdio::piped())
        .spawn().map_err(error)?;
    child.stdin.take().ok_or("hash stdin unavailable")?.write_all(bytes).map_err(error)?;
    let output = child.wait_with_output().map_err(error)?;
    check(output.status.success(), String::from_utf8_lossy(&output.stderr).into_owned())?;
    String::from_utf8(output.stdout).map_err(error)?.split_whitespace().next()
        .map(str::to_string).ok_or("hash output absent".into())
}
fn read_input(spec: &InputSpec) -> Result<Tensor, String> {
    let mut bytes = std::fs::read(spec.path).map_err(error)?;
    if spec.narrow_i64 {
        check(bytes.len() % 8 == 0, "invalid int64 tag storage")?;
        let mut narrowed = Vec::with_capacity(bytes.len() / 2);
        for source in bytes.chunks_exact(8) {
            let value = i64::from_le_bytes(source.try_into().unwrap());
            narrowed.extend_from_slice(&i32::try_from(value).map_err(error)?.to_le_bytes());
        }
        bytes = narrowed;
    }
    Tensor::from_bytes(spec.dtype, spec.shape.to_vec(), bytes).map_err(error)
}
fn inputs(specs: &[InputSpec]) -> Result<TensorMap, String> {
    specs.iter().map(|spec| Ok((spec.name, read_input(spec)?))).collect()
}
fn load(runtime: &Runtime, path: &str, name: &str) -> Result<Function, String> {
    let started = Instant::now();
    let model = runtime.load_model_with_options(path,
        LoadOptions::from(Compute::GpuPreferred).with_expect_frequent_reshapes(true)).wait().map_err(error)?;
    let function = model.load_function(name).wait().map_err(error)?;
    println!("{{\"event\":\"loaded\",\"asset\":{},\"function\":{},\"compute\":\"gpu-preferred\",\"expect_frequent_reshapes\":true,\"seconds\":{}}}",
        quoted(path), quoted(name), started.elapsed().as_secs_f64());
    Ok(function)
}
fn evaluate(function: &Function, inputs: TensorMap, name: &str) -> Result<Tensor, String> {
    let mut result = function.run(inputs, TensorMap::new()).wait().map_err(error)?;
    check(result.states.is_empty() && result.outputs.len() == 1, "unexpected H3 outputs or states")?;
    result.outputs.remove(name).ok_or_else(|| format!("missing H3 output {name}"))
}
fn verify(tensor: &Tensor, shape: &[usize], expected: &str, path: &Path, event: &str) -> Result<(), String> {
    check(tensor.dtype() == DType::BFloat16 && tensor.shape() == shape, format!("{event} BF16 metadata mismatch"))?;
    check(tensor.as_bytes().chunks_exact(2).all(|value|
        BFloat16::from_bits(u16::from_le_bytes(value.try_into().unwrap())).to_f32().is_finite()),
        format!("{event} nonfinite BF16 output"))?;
    let actual = hash(tensor.as_bytes())?;
    std::fs::write(path, tensor.as_bytes()).map_err(error)?;
    println!("{{\"event\":{},\"file\":{},\"dtype\":\"bfloat16\",\"shape\":{:?},\"bytes\":{},\"sha256\":{},\"swift_sha256\":{},\"passed\":{}}}",
        quoted(event), quoted(&path.to_string_lossy()), tensor.shape(), tensor.as_bytes().len(), quoted(&actual), quoted(expected), actual == expected);
    check(actual == expected, format!("{event} Swift-byte mismatch: {actual} != {expected}"))
}
fn block(runtime: &Runtime, output: &Path, schedule: bool) -> Result<(), String> {
    let base = inputs(BLOCK_INPUTS)?;
    let modulation = load(runtime, MODULATION_ASSET, "modulation")?;
    let live = load(runtime, LIVE_ASSET, "block")?;
    let cached = load(runtime, CACHED_ASSET, "block")?;
    let count = if schedule { 50 } else { 1 };
    for index in 0..count {
        let started = Instant::now();
        let mut live_inputs = base.clone();
        if schedule { live_inputs.insert("temb", read_input(&SCHEDULE_INPUTS[index])?); }
        let temb = live_inputs.get("temb").ok_or("missing timestep fixture")?.clone();
        let table = evaluate(&modulation, TensorMap::from([("temb", temb)]), "modulations")?;
        let table_sha = if schedule { SCHEDULE_TABLE_HASHES[index] } else { GPU_TABLE_HASH };
        let prefix = if schedule { format!("step{index:02}-") } else { String::new() };
        verify(&table, &[6, 9, 5376], table_sha, &output.join(format!("{prefix}modulations.bf16")), &format!("{prefix}modulations"))?;
        let mut cached_inputs = live_inputs.clone();
        cached_inputs.insert("temb", table);
        let live_output = evaluate(&live, live_inputs, "hidden_out")?;
        let cached_output = evaluate(&cached, cached_inputs, "hidden_out")?;
        let expected = if schedule { SCHEDULE_OUTPUT_HASHES[index] } else { GPU_OUTPUT_HASH };
        verify(&live_output, &[1, 128, 5376], expected, &output.join(format!("{prefix}live.bf16")), &format!("{prefix}live"))?;
        verify(&cached_output, &[1, 128, 5376], expected, &output.join(format!("{prefix}cached.bf16")), &format!("{prefix}cached"))?;
        check(live_output.as_bytes() == cached_output.as_bytes(), "live/cached BF16 bytes differ")?;
        println!("{{\"event\":\"pair_complete\",\"step\":{},\"seconds\":{}}}", if schedule { index } else { 17 }, started.elapsed().as_secs_f64());
    }
    drop((modulation, live, cached));
    runtime.drain().wait().map_err(error)?;
    Ok(())
}
fn backbone(runtime: &Runtime, output: &Path, first: usize, end: usize, resume: Option<&str>) -> Result<(), String> {
    let base: TensorMap = BACKBONE_INPUTS.iter().filter(|spec| spec.name != "hidden")
        .map(|spec| Ok((spec.name, read_input(spec)?))).collect::<Result<_, String>>()?;
    let mut hidden = if let Some(path) = resume {
        Tensor::from_bytes(DType::BFloat16, [1, 19350, 5376], std::fs::read(path).map_err(error)?).map_err(error)?
    } else { read_input(BACKBONE_INPUTS.iter().find(|spec| spec.name == "hidden").ok_or("missing backbone hidden fixture")?)? };
    for (segment, path) in BACKBONE_ASSETS.iter().enumerate().take(end).skip(first) {
        let mut tables = Vec::with_capacity(25 * 6 * 9 * 5376 * 2);
        for path in &BACKBONE_TABLE_PATHS[segment * 25..(segment + 1) * 25] {
            tables.extend_from_slice(&std::fs::read(path).map_err(error)?);
        }
        let mut values = base.clone();
        values.insert("hidden", hidden);
        values.insert("tables", Tensor::from_bytes(DType::BFloat16, [25, 6, 9, 5376], tables).map_err(error)?);
        let function = load(runtime, path, "segment")?;
        let started = Instant::now();
        hidden = evaluate(&function, values, "hidden_out")?;
        check(hidden.dtype() == DType::BFloat16 && hidden.shape() == [1, 19350, 5376], "backbone BF16 metadata mismatch")?;
        println!("{{\"event\":\"segment_complete\",\"segment\":{segment},\"first_block\":{},\"end_block_exclusive\":{},\"seconds\":{}}}", segment * 25, (segment + 1) * 25, started.elapsed().as_secs_f64());
        // Host-owned outputs let this stage's function and model be released
        // transitively before acquiring the next 25-block graph.
        drop(function); runtime.drain().wait().map_err(error)?;
        println!("{{\"event\":\"stage_drained\",\"segment\":{segment}}}");
    }
    if end == 1 {
        check(hidden.as_bytes().chunks_exact(2).all(|value|
            BFloat16::from_bits(u16::from_le_bytes(value.try_into().unwrap())).to_f32().is_finite()), "nonfinite backbone checkpoint")?;
        let path = output.join("checkpoint.bf16");
        let digest = hash(hidden.as_bytes())?;
        std::fs::write(&path, hidden.as_bytes()).map_err(error)?;
        // The lab did not retain a block-24 hash. This checkpoint enables the
        // next process; only the final backbone comparison completes the gate.
        println!("{{\"event\":\"backbone_checkpoint\",\"file\":{},\"dtype\":\"bfloat16\",\"shape\":[1,19350,5376],\"bytes\":{},\"sha256\":{},\"exact_swift_comparison\":false,\"passed\":true}}", quoted(&path.to_string_lossy()), hidden.as_bytes().len(), quoted(&digest));
        Ok(())
    } else { verify(&hidden, &[1, 19350, 5376], BACKBONE_OUTPUT_HASH, &output.join("backbone.bf16"), "backbone") }
}
fn run() -> Result<(), String> {
    let args: Vec<_> = std::env::args().collect();
    let output = PathBuf::from(args.get(1).ok_or("output directory required")?);
    let mode = args.get(2).map(String::as_str).unwrap_or("block128");
    check(matches!(mode, "block128" | "schedule50" | "backbone" | "backbone-stage0" | "backbone-stage1"), "unknown H3 gate")?;
    check(!output.starts_with(env!("CORSAIRS_H3_WORKSPACE")) && !output.starts_with(H3_ROOT), "H3 outputs must stay outside source/external input trees")?;
    std::fs::create_dir_all(&output).map_err(error)?;
    let runtime = Runtime::new().map_err(error)?;
    let started = Instant::now();
    if mode == "backbone" { backbone(&runtime, &output, 0, 2, None)?; }
    else if mode == "backbone-stage0" { backbone(&runtime, &output, 0, 1, None)?; }
    else if mode == "backbone-stage1" {
        backbone(&runtime, &output, 1, 2, Some(args.get(3).ok_or("verified backbone checkpoint path required")?))?;
    }
    else { block(&runtime, &output, mode == "schedule50")?; }
    println!("{{\"event\":\"complete\",\"mode\":{},\"api\":\"owned\",\"seconds\":{},\"passed\":true}}", quoted(mode), started.elapsed().as_secs_f64());
    Ok(())
}
fn main() {
    if let Err(reason) = run() { eprintln!("{reason}"); std::process::exit(1); }
}
