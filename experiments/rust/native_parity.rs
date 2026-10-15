#![forbid(unsafe_code)]
//! Check native storage against the frozen, backend-specific Python b3 grid.
use corsairs::{Compute, DType, Runtime, Tensor, TensorHandleMap};
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

fn upload(runtime: &Runtime, root: &Path, specs: &[Spec]) -> Result<TensorHandleMap> {
    specs
        .iter()
        .map(|spec| {
            let tensor = Tensor::from_bytes(
                spec.dtype,
                spec.shape.to_vec(),
                std::fs::read(root.join(spec.file))?,
            )?;
            Ok((spec.name, runtime.upload(tensor).wait()?))
        })
        .collect()
}

fn compare(root: &Path, values: &TensorHandleMap, expected: &[Spec]) -> Result<()> {
    if values.len() != expected.len() {
        return Err("tensor names/count differ".into());
    }
    for spec in expected {
        let value = values.get(spec.name).ok_or("missing native tensor")?;
        if value.dtype() != spec.dtype || value.shape() != spec.shape {
            return Err(format!("{} native dtype/shape differs", spec.name).into());
        }
        let host = value.download().wait()?;
        if host.dtype() != spec.dtype
            || host.shape() != spec.shape
            || host.strides() != spec.strides
            || host.as_bytes() != std::fs::read(root.join(spec.file))?
        {
            return Err(
                format!("{} downloaded tensor differs from {}", spec.name, spec.file).into(),
            );
        }
    }
    Ok(())
}

fn run(runtime: &Runtime, root: &Path, case: &Case) -> Result<()> {
    let model = runtime
        .load_model(root.join(case.model), case.compute)
        .wait()?;
    let function = model.load_function("main").wait()?;
    if function.descriptor().inputs.len() != case.inputs.len() {
        return Err("descriptor count differs".into());
    }
    let mut states = upload(runtime, root, case.initial_state)?;
    for step in case.steps {
        let inputs = upload(runtime, root, step.inputs)?;
        let result = function.run_native(inputs, states).wait()?;
        compare(root, &result.outputs, step.outputs)?;
        compare(root, &result.states, step.states)?;
        states = result.states;
    }
    Ok(())
}

fn main() -> Result<()> {
    let root = std::env::args_os().nth(1).ok_or("fixture root required")?;
    let root = Path::new(&root);
    let runtime = Runtime::new()?;
    let mut failures = Vec::new();
    for case in CASES {
        let result = run(&runtime, root, case);
        println!(
            "{{\"event\":\"native_parity\",\"name\":\"{}\",\"backend\":\"{}\",\"passed\":{}}}",
            case.name,
            case.backend,
            result.is_ok()
        );
        if let Err(error) = result {
            failures.push(format!("{} / {}: {error}", case.name, case.backend));
        }
    }
    runtime.flush().wait()?;
    runtime.flush().wait()?;
    if !failures.is_empty() {
        return Err(failures.join("\n").into());
    }
    println!("{{\"event\":\"complete\",\"configurations\":32,\"passed\":true}}");
    Ok(())
}
