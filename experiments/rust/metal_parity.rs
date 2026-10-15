#![forbid(unsafe_code)]
//! Exercise automatic and explicitly bound Metal outputs against Python goldens.
use corsairs::{Compute, DType, MetalBufferMap, MetalQueue, MetalValueMap, Runtime, Tensor};
use std::path::Path;

struct Spec {
    name: &'static str,
    dtype: DType,
    shape: &'static [usize],
    strides: &'static [usize],
    file: &'static str,
}
struct Step {
    inputs: &'static [Spec],
    outputs: &'static [Spec],
    states: &'static [Spec],
}
struct Case {
    name: &'static str,
    backend: &'static str,
    compute: Compute,
    model: &'static str,
    inputs: &'static [Spec],
    initial_state: &'static [Spec],
    steps: &'static [Step],
}
include!(env!("CORSAIRS_V01_CASES"));

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

fn upload(queue: &MetalQueue, root: &Path, specs: &[Spec]) -> Result<MetalBufferMap> {
    specs
        .iter()
        .map(|spec| {
            let tensor = Tensor::from_bytes(
                spec.dtype,
                spec.shape.to_vec(),
                std::fs::read(root.join(spec.file))?,
            )?;
            Ok((spec.name, queue.upload(tensor).wait()?))
        })
        .collect()
}

fn check(root: &Path, value: &Tensor, spec: &Spec) -> Result<()> {
    if value.dtype() != spec.dtype
        || value.shape() != spec.shape
        || value.strides() != spec.strides
        || value.as_bytes() != std::fs::read(root.join(spec.file))?
    {
        return Err(format!("{} differs from {}", spec.name, spec.file).into());
    }
    Ok(())
}

fn run(runtime: &Runtime, queue: &MetalQueue, root: &Path, case: &Case, bound: bool) -> Result<()> {
    let model = runtime
        .load_model(root.join(case.model), case.compute)
        .wait()?;
    let function = model.load_function("main").wait()?;
    if function.descriptor().inputs.len() != case.inputs.len() {
        return Err("input descriptor count differs".into());
    }
    let mut states = upload(queue, root, case.initial_state)?;
    let mut bindings = MetalBufferMap::new();
    if bound {
        for spec in case.steps[0].outputs {
            bindings.insert(
                spec.name,
                queue.buffer(spec.dtype, spec.shape.to_vec()).wait()?,
            );
        }
    }
    for step in case.steps {
        let uploaded = upload(queue, root, step.inputs)?;
        let inputs: MetalValueMap = uploaded
            .iter()
            .map(|(name, buffer)| (name, buffer.clone()))
            .collect();
        let result = function
            .encode(queue, inputs, states, bindings.clone())
            .wait()?;
        if result.outputs.len() != step.outputs.len() || result.states.len() != step.states.len() {
            return Err("output/state count differs".into());
        }
        for spec in step.outputs {
            let value = result.outputs.get(spec.name).ok_or("missing output")?;
            check(root, &value.download().wait()?, spec)?;
        }
        for spec in step.states {
            let value = result.states.get(spec.name).ok_or("missing state")?;
            check(root, &value.download().wait()?, spec)?;
        }
        states = result.states;
    }
    Ok(())
}

fn main() -> Result<()> {
    let root = std::env::args_os().nth(1).ok_or("fixture root required")?;
    let root = Path::new(&root);
    let runtime = Runtime::new()?;
    let queue = runtime.metal_queue().wait()?;
    let mut failures = Vec::new();
    for bound in [false, true] {
        for case in CASES {
            let result = run(&runtime, &queue, root, case, bound);
            println!(
                "{{\"event\":\"metal_parity\",\"name\":\"{}\",\"backend\":\"{}\",\"explicit_outputs\":{},\"passed\":{}}}",
                case.name,
                case.backend,
                bound,
                result.is_ok()
            );
            if let Err(error) = result {
                failures.push(format!(
                    "{} / {} / bound {bound}: {error}",
                    case.name, case.backend
                ));
            }
        }
    }
    queue.fence().wait()?;
    runtime.flush().wait()?;
    runtime.flush().wait()?;
    if !failures.is_empty() {
        return Err(failures.join("\n").into());
    }
    println!("{{\"event\":\"complete\",\"configurations\":64,\"passed\":true}}");
    Ok(())
}
