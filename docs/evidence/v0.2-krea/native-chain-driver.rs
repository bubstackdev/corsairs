#![forbid(unsafe_code)]
//! Acceptance probe only: external immutable model/input paths, owned or native
//! carries, eight separately rounded Float32 Euler steps and exact Swift hashes.
use corsairs::{Compute, DType, Float16, Function, LoadOptions, Runtime, Tensor, TensorHandle, TensorHandleMap, TensorMap};
use std::io::Write;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};
use std::time::Instant;

include!(env!("CORSAIRS_KREA_DATA"));

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
    // A system hash utility is test instrumentation, outside timed model calls.
    // Production Corsairs does not launch helpers or depend on this executable.
    let mut child = Command::new("/usr/bin/shasum").args(["-a", "256"])
        .stdin(Stdio::piped()).stdout(Stdio::piped()).stderr(Stdio::piped())
        .spawn().map_err(error)?;
    child.stdin.take().ok_or("hash stdin unavailable")?.write_all(bytes).map_err(error)?;
    let output = child.wait_with_output().map_err(error)?;
    check(output.status.success(), String::from_utf8_lossy(&output.stderr).into_owned())?;
    String::from_utf8(output.stdout).map_err(error)?.split_whitespace().next()
        .map(str::to_string).ok_or("hash output absent".into())
}
fn read_floats(path: &str, count: usize) -> Result<Vec<f32>, String> {
    let payload = std::fs::read(path).map_err(error)?;
    check(payload.len() == count * 4, format!("unexpected bytes in {path}"))?;
    Ok(payload.chunks_exact(4).map(|v| f32::from_le_bytes(v.try_into().unwrap())).collect())
}
fn halves(values: &[f32], shape: &[usize]) -> Result<Tensor, String> {
    Tensor::from_vec(shape.to_vec(), values.iter().copied().map(Float16::from_f32).collect()).map_err(error)
}
fn verify_tensor(tensor: &Tensor, dtype: DType, shape: &[usize], name: &str) -> Result<(), String> {
    check(tensor.dtype() == dtype, format!("{name} dtype mismatch: {}", tensor.dtype()))?;
    check(tensor.shape() == shape, format!("{name} shape mismatch: {:?}", tensor.shape()))
}
fn verify_handle(tensor: &TensorHandle, dtype: DType, shape: &[usize], name: &str) -> Result<(), String> {
    check(tensor.dtype() == dtype, format!("{name} dtype mismatch: {}", tensor.dtype()))?;
    check(tensor.shape() == shape, format!("{name} shape mismatch: {:?}", tensor.shape()))
}
fn carry_shape(name: &str) -> &[usize] {
    if name == "cond" { &[8, 6144] }
    else if name.starts_with("text_") { &[20, 6144] } else { &[4032, 6144] }
}
fn dump(path: &Path, tensor: &Tensor, expected: &str, event: &str) -> Result<(), String> {
    let actual = hash(tensor.as_bytes())?;
    std::fs::write(path, tensor.as_bytes()).map_err(error)?;
    println!("{{\"event\":{},\"file\":{},\"sha256\":{},\"expected_sha256\":{},\"passed\":{}}}",
        quoted(event), quoted(&path.to_string_lossy()), quoted(&actual), quoted(expected), actual == expected);
    check(actual == expected, format!("{event} hash mismatch: {actual} != {expected}"))
}
fn load(runtime: &Runtime, path: &str, name: &str, reshapes: bool) -> Result<Function, String> {
    let started = Instant::now();
    let options = LoadOptions::from(Compute::GpuPreferred).with_expect_frequent_reshapes(reshapes);
    let model = runtime.load_model_with_options(path, options).wait().map_err(error)?;
    let function = model.load_function(name).wait().map_err(error)?;
    println!("{{\"event\":\"loaded\",\"model\":{},\"function\":{},\"expect_frequent_reshapes\":{reshapes},\"seconds\":{}}}",
        quoted(path), quoted(name), started.elapsed().as_secs_f64());
    Ok(function) // Function's safe ownership retains its Model.
}
// The separate non-inlined call prevents contraction into a fused multiply-add.
#[inline(never)]
fn rounded_product(delta: f32, velocity: f32) -> f32 { delta * velocity }
fn euler(latents: &mut [f32], velocity: &Tensor, delta: f32) -> Result<(), String> {
    verify_tensor(velocity, DType::Float16, &[4032, 64], "velocity")?;
    let values = velocity.to_vec::<Float16>().map_err(error)?;
    check(values.len() == latents.len(), "velocity element count mismatch")?;
    for (latent, velocity) in latents.iter_mut().zip(values) {
        let velocity = velocity.to_f32();
        let product = rounded_product(delta, velocity);
        let result = *latent + product;
        check(velocity.is_finite() && result.is_finite(), "nonfinite Euler result")?;
        *latent = result;
    }
    Ok(())
}
fn native_step(runtime: &Runtime, functions: &[Function], text: &TensorHandle, rope: &TensorHandle,
    latent_input: Tensor, sigma: Tensor, step: usize, output: &Path) -> Result<Tensor, String> {
    let started = Instant::now();
    let latent_input = runtime.upload(latent_input).wait().map_err(error)?;
    let sigma = runtime.upload(sigma).wait().map_err(error)?;
    println!("{{\"event\":\"step_upload\",\"step\":{step},\"tensors\":2,\"seconds\":{}}}", started.elapsed().as_secs_f64());
    let mut carries = TensorHandleMap::new();
    let mut velocity = None;
    for (segment, function) in functions.iter().enumerate() {
        let mut inputs = TensorHandleMap::new();
        for descriptor in &function.descriptor().inputs {
            let name = descriptor.name.as_str();
            let tensor = match name {
                "latents" => latent_input.clone(), "text_embeds" => text.clone(),
                "sigma" => sigma.clone(), "rope_image" => rope.clone(),
                "cond" => carries.get(name).cloned().ok_or("missing native conditioning carry")?,
                _ => carries.remove(name).ok_or_else(|| format!("missing native {name} before segment {segment}"))?,
            };
            inputs.insert(name, tensor);
        }
        let started = Instant::now();
        let result = function.run_native(inputs, TensorHandleMap::new()).wait().map_err(error)?;
        println!("{{\"event\":\"segment\",\"step\":{step},\"segment\":{segment},\"api\":\"run_native\",\"seconds\":{}}}", started.elapsed().as_secs_f64());
        check(result.states.is_empty(), "unexpected Krea native state output")?;
        for (name, tensor) in result.outputs.iter() {
            if name == "velocity" {
                verify_handle(tensor, DType::Float16, &[4032, 64], name)?;
                velocity = Some(tensor.clone());
                continue;
            }
            verify_handle(tensor, DType::Float32, carry_shape(name), name)?;
            if step == 0 && segment == 0 {
                let expected = FIRST_CARRIES.iter().find(|(key, _)| *key == name).ok_or("unexpected first native carry")?.1;
                let started = Instant::now();
                let checkpoint = tensor.download().wait().map_err(error)?;
                println!("{{\"event\":\"checkpoint_download\",\"name\":{},\"bytes\":{},\"seconds\":{}}}", quoted(name), checkpoint.as_bytes().len(), started.elapsed().as_secs_f64());
                verify_tensor(&checkpoint, DType::Float32, carry_shape(name), name)?;
                dump(&output.join(format!("first-{name}.f32")), &checkpoint, expected, &format!("first_{name}"))?;
            }
            // Clones retain the exact output handle; checkpoint readbacks never
            // replace it with an upload or owned host tensor for later segments.
            carries.insert(name, tensor.clone());
        }
    }
    let velocity = velocity.ok_or("last native segment did not produce velocity")?;
    let started = Instant::now();
    let velocity = velocity.download().wait().map_err(error)?;
    println!("{{\"event\":\"velocity_download\",\"step\":{step},\"bytes\":{},\"seconds\":{}}}", velocity.as_bytes().len(), started.elapsed().as_secs_f64());
    Ok(velocity)
}
fn run() -> Result<(), String> {
    let args: Vec<_> = std::env::args().collect();
    let output = PathBuf::from(args.get(1).ok_or("output directory required")?);
    let mode = args.get(2).map(String::as_str).unwrap_or("eight-step");
    check(matches!(mode, "eight-step" | "first-segment" | "native-chain"), "unknown acceptance mode")?;
    check(!output.starts_with(env!("CORSAIRS_KREA_WORKSPACE")), "large results must be outside Corsairs workspace")?;
    std::fs::create_dir_all(&output).map_err(error)?;
    let mut latents = read_floats(NOISE_PATH, 4032 * 64)?;
    let text = read_floats(TEXT_PATH, 20 * 30720)?;
    let rope_bytes = std::fs::read(ROPE_PATH).map_err(error)?;
    let text = halves(&text, &[20, 30720])?;
    let rope = Tensor::from_bytes(DType::Float32, [4032, 2, 128], rope_bytes).map_err(error)?;
    let runtime = Runtime::new().map_err(error)?;
    let count = if mode == "first-segment" { 1 } else { 4 };
    let mut functions = Vec::new();
    for path in MODELS.iter().take(count) { functions.push(load(&runtime, path, "segment", true)?); }
    let generation_started = Instant::now();
    let static_handles = if mode == "native-chain" {
        let started = Instant::now();
        let handles = (runtime.upload(text.clone()).wait().map_err(error)?, runtime.upload(rope.clone()).wait().map_err(error)?);
        println!("{{\"event\":\"static_upload\",\"tensors\":2,\"bytes\":{},\"seconds\":{}}}", text.as_bytes().len() + rope.as_bytes().len(), started.elapsed().as_secs_f64());
        Some(handles)
    } else { None };
    for step in 0..if mode == "first-segment" { 1 } else { 8 } {
        let step_started = Instant::now();
        let latent_input = halves(&latents, &[4032, 64])?;
        let sigma = Tensor::from_vec([1], vec![f32::from_bits(TIMESTEP_BITS[step])]).map_err(error)?;
        let velocity = if let Some((text, rope)) = &static_handles {
            native_step(&runtime, &functions, text, rope, latent_input, sigma, step, &output)?
        } else {
        let mut carries = TensorMap::new();
        let mut velocity = None;
        for (segment, function) in functions.iter().enumerate() {
            let mut inputs = TensorMap::new();
            for descriptor in &function.descriptor().inputs {
                let name = descriptor.name.as_str();
                let tensor = match name {
                    "latents" => latent_input.clone(), "text_embeds" => text.clone(),
                    "sigma" => sigma.clone(), "rope_image" => rope.clone(),
                    "cond" => carries.get(name).cloned().ok_or("missing conditioning carry")?,
                    _ => carries.remove(name).ok_or_else(|| format!("missing {name} before segment {segment}"))?,
                };
                inputs.insert(name, tensor);
            }
            let started = Instant::now();
            let result = function.run(inputs, TensorMap::new()).wait().map_err(error)?;
            println!("{{\"event\":\"segment\",\"step\":{step},\"segment\":{segment},\"seconds\":{}}}", started.elapsed().as_secs_f64());
            check(result.states.is_empty(), "unexpected Krea state output")?;
            for (name, tensor) in result.outputs.iter() {
                if name == "velocity" { velocity = Some(tensor.clone()); continue; }
                verify_tensor(tensor, DType::Float32, carry_shape(name), name)?;
                if step == 0 && segment == 0 {
                    let expected = FIRST_CARRIES.iter().find(|(key, _)| *key == name).ok_or("unexpected first carry")?.1;
                    dump(&output.join(format!("first-{name}.f32")), tensor, expected, &format!("first_{name}"))?;
                }
                carries.insert(name, tensor.clone());
            }
            if mode == "first-segment" {
                drop(functions); runtime.flush().wait().map_err(error)?;
                println!("{{\"event\":\"complete\",\"mode\":\"first-segment\",\"passed\":true}}");
                return Ok(());
            }
        }
        velocity.ok_or("last segment did not produce velocity")?
        };
        euler(&mut latents, &velocity, f32::from_bits(DELTA_BITS[step]))?;
        let tensor = Tensor::from_vec([84, 48, 64], latents.clone()).map_err(error)?;
        dump(&output.join(format!("step{step}.latents.f32")), &tensor, STEP_HASHES[step], &format!("step{step}_latents"))?;
        println!("{{\"event\":\"step_complete\",\"step\":{step},\"seconds\":{}}}", step_started.elapsed().as_secs_f64());
    }
    drop(functions); drop(static_handles); runtime.flush().wait().map_err(error)?;
    let final_tensor = Tensor::from_vec([84, 48, 64], latents.clone()).map_err(error)?;
    dump(&output.join("final.latents.f32"), &final_tensor, FINAL_HASH, "final_latents")?;
    let decoder = load(&runtime, DECODER, "decode", false)?;
    let started = Instant::now();
    let input = halves(&latents, &[84, 48, 64])?;
    let mut decoded = decoder.run(TensorMap::from([("latents", input)]), TensorMap::new()).wait().map_err(error)?;
    let pixels = decoded.outputs.remove("image").ok_or("decoder has no image output")?;
    verify_tensor(&pixels, DType::Float32, &[3, 1344, 768], "image")?;
    dump(&output.join("pixels.chw.f32"), &pixels, PIXEL_HASH, "decoded_pixels")?;
    println!("{{\"event\":\"decode_complete\",\"seconds\":{}}}", started.elapsed().as_secs_f64());
    drop(decoder); runtime.flush().wait().map_err(error)?;
    println!("{{\"event\":\"complete\",\"mode\":{},\"steps\":8,\"decoder_api\":\"run\",\"seconds\":{},\"passed\":true}}", quoted(mode), generation_started.elapsed().as_secs_f64());
    Ok(())
}
fn main() {
    if let Err(error) = run() { eprintln!("{error}"); std::process::exit(1); }
}
