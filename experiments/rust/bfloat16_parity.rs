#![forbid(unsafe_code)]
//! Public BF16 storage/inference probes. Native execution is coordinated separately.
use corsairs::{
    BFloat16, Compute, DType, Function, MetalBufferMap, MetalQueue, MetalValueMap, Runtime,
    Tensor, TensorDescriptor, TensorHandleMap, TensorMap,
};
use std::path::Path;

struct Spec {
    name: &'static str,
    shape: &'static [usize],
    file: &'static str,
}
struct Step {
    inputs: &'static [Spec],
    outputs: &'static [Spec],
    states: &'static [Spec],
}
struct Case {
    name: &'static str,
    model: &'static str,
    dynamic: bool,
    initial_state: &'static [Spec],
    steps: &'static [Step],
}
include!(env!("CORSAIRS_BF16_CASES"));
type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

fn tensor(root: &Path, spec: &Spec) -> Result<Tensor> {
    Ok(Tensor::from_bytes(
        DType::BFloat16,
        spec.shape.to_vec(),
        std::fs::read(root.join(spec.file))?,
    )?)
}
fn owned(root: &Path, specs: &[Spec]) -> Result<TensorMap> {
    specs.iter().map(|spec| Ok((spec.name, tensor(root, spec)?))).collect()
}
fn native(runtime: &Runtime, root: &Path, specs: &[Spec]) -> Result<TensorHandleMap> {
    specs.iter().map(|spec| Ok((spec.name, runtime.upload(tensor(root, spec)?).wait()?))).collect()
}
fn metal(queue: &MetalQueue, root: &Path, specs: &[Spec]) -> Result<MetalBufferMap> {
    specs.iter().map(|spec| Ok((spec.name, queue.upload(tensor(root, spec)?).wait()?))).collect()
}
fn signature(actual: &[TensorDescriptor], expected: &[Spec], dynamic: bool) -> Result<()> {
    if actual.len() != expected.len() { return Err("descriptor count".into()); }
    for spec in expected {
        let actual = actual.iter().find(|item| item.name == spec.name).ok_or("descriptor name")?;
        let mut shape: Vec<_> = spec.shape.iter().copied().map(Some).collect();
        if dynamic { shape[0] = None; }
        if actual.dtype != DType::BFloat16 || actual.shape != shape {
            return Err(format!("BF16 descriptor mismatch: {actual:?}").into());
        }
    }
    Ok(())
}
fn descriptors(function: &Function, case: &Case) -> Result<()> {
    let actual = function.descriptor();
    if actual.name != "main" { return Err("function descriptor name".into()); }
    signature(&actual.inputs, case.steps[0].inputs, case.dynamic)?;
    signature(&actual.outputs, case.steps[0].outputs, case.dynamic)?;
    signature(&actual.states, case.initial_state, false)
}
fn check(root: &Path, actual: &Tensor, expected: &Spec) -> Result<()> {
    if actual.dtype() != DType::BFloat16 || actual.shape() != expected.shape
        || actual.as_bytes() != std::fs::read(root.join(expected.file))? {
        return Err(format!("{} BF16 bytes/metadata mismatch", expected.file).into());
    }
    Ok(())
}
fn save(output: &Path, label: &str, kind: &str, actual: &Tensor, expected: &Spec,
        native_strides: Option<&[isize]>) -> Result<()> {
    let file = format!("{label}-{kind}-{}.bin", expected.name);
    std::fs::write(output.join(&file), actual.as_bytes())?;
    let native_strides = native_strides.map_or_else(|| "null".to_string(), |value| format!("{value:?}"));
    println!("{{\"event\":\"bf16_value\",\"label\":\"{label}\",\"kind\":\"{kind}\",\"name\":\"{}\",\"dtype\":\"bfloat16\",\"shape\":{:?},\"packed_strides\":{:?},\"native_strides\":{},\"file\":\"{file}\",\"exact\":true}}",
        expected.name, actual.shape(), actual.strides(), native_strides);
    Ok(())
}
fn raw_roundtrip(runtime: &Runtime, queue: &MetalQueue, root: &Path, output: &Path) -> Result<()> {
    let bits: Vec<_> = (0..=u16::MAX).map(BFloat16::from_bits).collect();
    let expected = std::fs::read(root.join("all-encodings.bin"))?;
    let value = Tensor::from_vec([65536], bits.clone())?;
    if value.as_bytes() != expected || value.to_vec::<BFloat16>()? != bits { return Err("host allbits".into()); }
    let copy = value.clone();
    drop(value);
    let handle = runtime.upload(copy.clone()).wait()?;
    if handle.dtype() != DType::BFloat16 || handle.shape() != [65536] || handle.strides() != [1] {
        return Err("allbits native metadata".into());
    }
    let retained = handle.clone();
    drop(handle);
    let actual = retained.download().wait()?;
    if actual != copy { return Err("native allbits".into()); }
    std::fs::write(output.join("native-all-encodings.bin"), actual.as_bytes())?;
    drop(retained);
    let buffer = queue.upload(copy.clone()).wait()?;
    let retained = buffer.clone();
    drop(buffer);
    let actual = retained.download().wait()?;
    if actual != copy { return Err("Metal allbits".into()); }
    std::fs::write(output.join("metal-all-encodings.bin"), actual.as_bytes())?;
    println!("{{\"event\":\"bf16_raw\",\"encodings\":65536,\"native_exact\":true,\"metal_exact\":true,\"clone_drop\":true}}");
    Ok(())
}
fn run_owned(runtime: &Runtime, root: &Path, output: &Path, case: &Case, compute: Compute, backend: &str) -> Result<()> {
    let model = runtime.load_model(root.join(case.model), compute).wait()?;
    let function = model.load_function("main").wait()?;
    descriptors(&function, case)?;
    let mut states = owned(root, case.initial_state)?;
    for (index, step) in case.steps.iter().enumerate() {
        let result = function.run(owned(root, step.inputs)?, states).wait()?;
        if result.outputs.len() != step.outputs.len() || result.states.len() != step.states.len() { return Err("owned counts".into()); }
        let label = format!("{backend}-owned-{}-{index}", case.name);
        for (kind, specs, values) in [("output", step.outputs, &result.outputs), ("state", step.states, &result.states)] {
            for spec in specs {
                let actual = values.get(spec.name).ok_or("missing owned value")?;
                check(root, actual, spec)?;
                save(output, &label, kind, actual, spec, None)?;
            }
        }
        states = result.states;
    }
    Ok(())
}
fn run_native(runtime: &Runtime, root: &Path, output: &Path, case: &Case, compute: Compute, backend: &str) -> Result<()> {
    let model = runtime.load_model(root.join(case.model), compute).wait()?;
    let function = model.load_function("main").wait()?;
    descriptors(&function, case)?;
    let mut states = native(runtime, root, case.initial_state)?;
    for (index, step) in case.steps.iter().enumerate() {
        let result = function.run_native(native(runtime, root, step.inputs)?, states).wait()?;
        if result.outputs.len() != step.outputs.len() || result.states.len() != step.states.len() { return Err("native counts".into()); }
        let label = format!("{backend}-native-{}-{index}", case.name);
        for (kind, specs, values) in [("output", step.outputs, &result.outputs), ("state", step.states, &result.states)] {
            for spec in specs {
                let value = values.get(spec.name).ok_or("missing native value")?;
                if value.dtype() != DType::BFloat16 || value.shape() != spec.shape { return Err("native metadata".into()); }
                let actual = value.download().wait()?;
                check(root, &actual, spec)?;
                save(output, &label, kind, &actual, spec, Some(value.strides()))?;
            }
        }
        states = result.states;
    }
    Ok(())
}
fn run_metal(runtime: &Runtime, queue: &MetalQueue, root: &Path, output: &Path, case: &Case, compute: Compute, backend: &str, bound: bool) -> Result<()> {
    let model = runtime.load_model(root.join(case.model), compute).wait()?;
    let function = model.load_function("main").wait()?;
    descriptors(&function, case)?;
    let mut states = metal(queue, root, case.initial_state)?;
    let mut bindings = MetalBufferMap::new();
    if bound {
        for spec in case.steps[0].outputs {
            bindings.insert(spec.name, queue.buffer(DType::BFloat16, spec.shape.to_vec()).wait()?);
        }
    }
    for (index, step) in case.steps.iter().enumerate() {
        let buffers = metal(queue, root, step.inputs)?;
        let inputs: MetalValueMap = buffers.iter().map(|(name, buffer)| (name, buffer.clone())).collect();
        let result = function.encode(queue, inputs, states, bindings.clone()).wait()?;
        if result.outputs.len() != step.outputs.len() || result.states.len() != step.states.len() { return Err("Metal counts".into()); }
        let mode = if bound { "metal-bound" } else { "metal-auto" };
        let label = format!("{backend}-{mode}-{}-{index}", case.name);
        for spec in step.outputs {
            let value = result.outputs.get(spec.name).ok_or("missing Metal output")?;
            if value.dtype() != DType::BFloat16 || value.shape() != spec.shape { return Err("Metal metadata".into()); }
            let actual = value.download().wait()?;
            check(root, &actual, spec)?;
            save(output, &label, "output", &actual, spec, None)?;
        }
        for spec in step.states {
            let value = result.states.get(spec.name).ok_or("missing Metal state")?;
            let actual = value.download().wait()?;
            check(root, &actual, spec)?;
            save(output, &label, "state", &actual, spec, None)?;
        }
        states = result.states;
    }
    Ok(())
}
fn chain_and_abandon(runtime: &Runtime, queue: &MetalQueue, root: &Path, compute: Compute) -> Result<()> {
    let model = runtime.load_model(root.join("double/model.aimodel"), compute).wait()?;
    let function = model.load_function("main").wait()?;
    let spec = &CASES.iter().find(|case| case.name == "double").ok_or("double case")?.steps[0].inputs[0];
    let input = tensor(root, spec)?;
    let expected = Tensor::from_vec([2,3], vec![BFloat16::from_f32(4.), BFloat16::from_f32(-8.), BFloat16::from_f32(0.), BFloat16::from_f32(2.), BFloat16::from_f32(400.), BFloat16::from_f32(-1.)])?;
    let result = function.run_native(TensorHandleMap::from([("x", runtime.upload(input.clone()).wait()?)]), TensorHandleMap::new()).wait()?;
    let retained = result.outputs.get("y").ok_or("first native y")?.clone();
    drop(result);
    let result = function.run_native(TensorHandleMap::from([("x", retained)]), TensorHandleMap::new()).wait()?;
    if result.outputs.get("y").ok_or("chained native y")?.download().wait()? != expected { return Err("native chain".into()); }
    let result = function.encode(queue, MetalValueMap::from([("x", queue.upload(input.clone()).wait()?)]), MetalBufferMap::new(), MetalBufferMap::new()).wait()?;
    let retained = result.outputs.get("y").ok_or("first Metal y")?.clone();
    drop(result);
    let result = function.encode(queue, MetalValueMap::from([("x", retained)]), MetalBufferMap::new(), MetalBufferMap::new()).wait()?;
    if result.outputs.get("y").ok_or("chained Metal y")?.download().wait()? != expected { return Err("Metal chain".into()); }
    for _ in 0..10 {
        drop(runtime.upload(input.clone()));
        drop(queue.upload(input.clone()));
        drop(function.run(TensorMap::from([("x", input.clone())]), TensorMap::new()));
        drop(function.run_native(TensorHandleMap::from([("x", runtime.upload(input.clone()).wait()?)]), TensorHandleMap::new()));
        drop(function.encode(queue, MetalValueMap::from([("x", queue.upload(input.clone()).wait()?)]), MetalBufferMap::new(), MetalBufferMap::new()));
        drop(function.run(TensorMap::new(), TensorMap::new()));
        drop(function.run_native(TensorHandleMap::new(), TensorHandleMap::new()));
        drop(function.encode(queue, MetalValueMap::new(), MetalBufferMap::new(), MetalBufferMap::new()));
    }
    queue.fence().wait()?;
    Ok(())
}
fn main() -> Result<()> {
    let arguments: Vec<_> = std::env::args_os().collect();
    if arguments.len() != 3 { return Err("usage: bfloat16-parity FIXTURE_ROOT OUTPUT_DIRECTORY".into()); }
    let root = Path::new(&arguments[1]);
    let output = Path::new(&arguments[2]);
    std::fs::create_dir_all(output)?;
    let runtime = Runtime::new()?;
    let queue = runtime.metal_queue().wait()?;
    raw_roundtrip(&runtime, &queue, root, output)?;
    let mut configurations = 0;
    for (compute, backend) in [(Compute::CpuOnly, "cpu"), (Compute::GpuPreferred, "gpu-preferred")] {
        for case in CASES {
            run_owned(&runtime, root, output, case, compute, backend)?;
            run_native(&runtime, root, output, case, compute, backend)?;
            run_metal(&runtime, &queue, root, output, case, compute, backend, false)?;
            configurations += 3;
            if !case.dynamic {
                run_metal(&runtime, &queue, root, output, case, compute, backend, true)?;
                configurations += 1;
            }
        }
        chain_and_abandon(&runtime, &queue, root, compute)?;
    }
    queue.fence().wait()?;
    drop(queue);
    runtime.drain().wait()?;
    println!("{{\"event\":\"complete\",\"configurations\":{configurations},\"passed\":true,\"chained_backends\":2,\"abandoned_iterations\":20}}");
    Ok(())
}
