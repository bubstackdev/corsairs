#![forbid(unsafe_code)]
//! Public-API differential and lifecycle probe. Native artifacts are generated
//! from suite.json/backend-goldens.json by scripts/check_v01.py.
use corsairs::{Compute, DType, Error, Function, Runtime, Tensor, TensorDescriptor, TensorMap};
use std::future::Future;
use std::path::Path;
use std::sync::Arc;
use std::task::{Context, Poll, Wake, Waker};

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

fn require(condition: bool, message: impl Into<String>) -> Result<(), String> {
    condition.then_some(()).ok_or_else(|| message.into())
}
fn text(error: impl std::fmt::Display) -> String {
    error.to_string()
}
fn json(value: &str) -> String {
    let mut out = String::from("\"");
    for ch in value.chars() {
        match ch {
            '"' => out.push_str("\\\""),
            '\\' => out.push_str("\\\\"),
            '\n' => out.push_str("\\n"),
            '\r' => out.push_str("\\r"),
            '\t' => out.push_str("\\t"),
            ch if ch < ' ' => out.push_str(&format!("\\u{:04x}", ch as u32)),
            ch => out.push(ch),
        }
    }
    out.push('"');
    out
}
fn emit(event: &str, name: &str, backend: &str, result: &Result<(), String>) {
    println!(
        "{{\"event\":{},\"name\":{},\"backend\":{},\"passed\":{},\"error\":{}}}",
        json(event), json(name), json(backend), result.is_ok(),
        result.as_ref().err().map_or_else(|| "null".into(), |e| json(e))
    );
}
fn load_tensors(root: &Path, specs: &[Spec]) -> Result<TensorMap, String> {
    specs.iter().map(|spec| {
        let bytes = std::fs::read(root.join(spec.file)).map_err(text)?;
        let tensor = Tensor::from_bytes(spec.dtype, spec.shape.to_vec(), bytes).map_err(text)?;
        Ok((spec.name, tensor))
    }).collect()
}
fn compare(root: &Path, actual: &TensorMap, expected: &[Spec]) -> Result<(), String> {
    require(actual.len() == expected.len(), "different tensor names/count")?;
    for spec in expected {
        let value = actual.get(spec.name).ok_or_else(|| format!("missing tensor {:?}", spec.name))?;
        require(value.dtype() == spec.dtype, format!("{} dtype mismatch", spec.name))?;
        require(value.shape() == spec.shape, format!("{} shape mismatch: {:?} != {:?}", spec.name, value.shape(), spec.shape))?;
        require(value.strides() == spec.strides, format!("{} strides mismatch: {:?} != {:?}", spec.name, value.strides(), spec.strides))?;
        let wanted = std::fs::read(root.join(spec.file)).map_err(text)?;
        require(value.as_bytes() == wanted, format!("{} exact bytes differ from {}", spec.name, spec.file))?;
    }
    Ok(())
}
fn descriptors(actual: &[TensorDescriptor], expected: &[Spec]) -> Result<(), String> {
    require(actual.len() == expected.len(), "descriptor count mismatch")?;
    for (actual, expected) in actual.iter().zip(expected) {
        require(actual.name == expected.name, format!("descriptor name {:?} != {:?}", actual.name, expected.name))?;
        require(actual.dtype == expected.dtype, format!("descriptor dtype mismatch for {}", actual.name))?;
        let expected_shape: Vec<_> = expected.shape.iter().copied().map(Some).collect();
        require(actual.shape == expected_shape, format!("descriptor shape mismatch for {}", actual.name))?;
    }
    Ok(())
}

struct WakeThread(std::thread::Thread);
impl Wake for WakeThread {
    fn wake(self: Arc<Self>) { self.0.unpark(); }
    fn wake_by_ref(self: &Arc<Self>) { self.0.unpark(); }
}
fn block_on<F: Future>(future: F) -> F::Output {
    let waker = Waker::from(Arc::new(WakeThread(std::thread::current())));
    let mut cx = Context::from_waker(&waker);
    let mut future = std::pin::pin!(future);
    loop {
        match future.as_mut().poll(&mut cx) {
            Poll::Ready(value) => return value,
            Poll::Pending => std::thread::park(),
        }
    }
}
fn run_case(runtime: &Runtime, root: &Path, case: &Case) -> Result<(), String> {
    let model = block_on(async { runtime.load_model(root.join(case.model), case.compute).await }).map_err(text)?;
    require(model.function_names() == ["main"], "function names mismatch")?;
    require(model.compute() == case.compute, "compute choice mismatch")?;
    let function = model.load_function("main").wait().map_err(text)?;
    let descriptor = function.descriptor();
    require(descriptor.name == "main", "function descriptor name mismatch")?;
    descriptors(&descriptor.inputs, case.inputs)?;
    descriptors(&descriptor.outputs, case.steps[0].outputs)?;
    descriptors(&descriptor.states, case.initial_state)?;
    let mut states = load_tensors(root, case.initial_state)?;
    // Keep this exact Function alive across all stateful steps.
    for step in case.steps {
        let inputs = load_tensors(root, step.inputs)?;
        let result = block_on(async { function.run(inputs, states).await }).map_err(text)?;
        compare(root, &result.outputs, step.outputs)?;
        compare(root, &result.states, step.states)?;
        states = result.states;
    }
    drop(function);
    drop(model);
    runtime.flush().wait().map_err(text)
}

fn negative(runtime: &Runtime, root: &Path, backend: &str, name: &str) -> Result<(), String> {
    let compute = if backend == "cpu" { Compute::CpuOnly } else { Compute::GpuPreferred };
    if name == "missing_asset" {
        return match runtime.load_model(root.join("does-not-exist.aimodel"), compute).wait() {
            Err(Error::Native { type_name, .. }) if type_name.contains("AIModelCacheError") => Ok(()),
            Err(other) => Err(format!("wrong missing-asset variant: {other:?}")),
            Ok(_) => Err("absent model loaded".into()),
        };
    }
    let case = CASES.iter().find(|case| case.backend == backend && case.name == if name.contains("state") { "accumulator" } else { "double_float32" }).unwrap();
    let model = runtime.load_model(root.join(case.model), compute).wait().map_err(text)?;
    if name == "missing_function" {
        return match model.load_function("does-not-exist").wait() {
            Err(Error::FunctionNotFound(value)) if value == "does-not-exist" => Ok(()),
            Err(other) => Err(format!("wrong missing-function variant: {other:?}")),
            Ok(_) => Err("absent function loaded".into()),
        };
    }
    let function = model.load_function("main").wait().map_err(text)?;
    let mut inputs = load_tensors(root, case.inputs)?;
    let mut states = load_tensors(root, case.initial_state)?;
    match name {
        "missing_input" => inputs = TensorMap::new(),
        "unknown_input" => { let input = inputs.remove("x").unwrap(); inputs.insert("unknown", input); }
        "wrong_shape" => { inputs.insert("x", Tensor::zeros(DType::Float32, [3, 2]).map_err(text)?); }
        "wrong_dtype" => { inputs.insert("x", Tensor::zeros(DType::Int32, [2, 3]).map_err(text)?); }
        "missing_state" => states = TensorMap::new(),
        "wrong_state_shape" => { states.insert("accumulator", Tensor::zeros(DType::Float32, [3, 2]).map_err(text)?); }
        _ => return Err(format!("unknown negative case {name}")),
    }
    let error = function.run(inputs, states).wait().err().ok_or("invalid request succeeded")?;
    let correct = match (&error, name) {
        (Error::MissingTensor { kind: "input", name }, "missing_input") => name == "x",
        (Error::UnexpectedTensor { kind: "input", name }, "unknown_input") => name == "unknown",
        (Error::DescriptorMismatch { name, reason }, "wrong_shape") => name == "x" && reason.contains("shape"),
        (Error::DescriptorMismatch { name, reason }, "wrong_dtype") => name == "x" && reason.contains("float32") && reason.contains("int32"),
        (Error::MissingTensor { kind: "state", name }, "missing_state") => name == "accumulator",
        (Error::DescriptorMismatch { name, reason }, "wrong_state_shape") => name == "accumulator" && reason.contains("shape"),
        _ => false,
    };
    require(correct, format!("wrong {name} error: {error:?}"))
}

fn load_function(runtime: &Runtime, root: &Path, case: &Case) -> Result<Function, String> {
    let model = runtime.load_model(root.join(case.model), case.compute).wait().map_err(text)?;
    model.load_function("main").wait().map_err(text)
}
fn stress(runtime: &Runtime, root: &Path, backend: &str, cycles: usize, loads: usize, abandoned: usize) -> Result<(), String> {
    let plain = CASES.iter().find(|case| case.backend == backend && case.name == "double_float32").unwrap();
    let stateful = CASES.iter().find(|case| case.backend == backend && case.name == "accumulator").unwrap();
    let function = load_function(runtime, root, plain)?;
    let plain_inputs = load_tensors(root, plain.inputs)?;
    let expected = load_tensors(root, plain.steps[0].outputs)?;
    for _ in 0..cycles {
        let result = function.run(plain_inputs.clone(), TensorMap::new()).wait().map_err(text)?;
        require(result.outputs == expected && result.states.is_empty(), "stateless stress mismatch")?;
    }
    drop(function);
    let function = load_function(runtime, root, stateful)?;
    let state_inputs = load_tensors(root, stateful.inputs)?;
    let mut states = load_tensors(root, stateful.initial_state)?;
    for iteration in 0..cycles {
        let result = function.run(state_inputs.clone(), states).wait().map_err(text)?;
        let expected = vec![(iteration + 1) as f32; 6];
        require(result.outputs.get("y").ok_or("missing stress output")?.to_vec::<f32>().map_err(text)? == expected,
                format!("stateful output mismatch at {iteration}"))?;
        require(result.states.get("accumulator").ok_or("missing stress state")?.to_vec::<f32>().map_err(text)? == expected,
                format!("stateful state mismatch at {iteration}"))?;
        states = result.states;
    }
    drop(function);
    for _ in 0..loads {
        let model = runtime.load_model(root.join(plain.model), plain.compute).wait().map_err(text)?;
        let function = model.load_function("main").wait().map_err(text)?;
        drop(model); // Function must retain native model ownership.
        compare(root, &function.run(plain_inputs.clone(), TensorMap::new()).wait().map_err(text)?.outputs, plain.steps[0].outputs)?;
        drop(function);
        runtime.flush().wait().map_err(text)?;
    }
    let function = load_function(runtime, root, stateful)?;
    for _ in 0..abandoned {
        drop(function.run(state_inputs.clone(), load_tensors(root, stateful.initial_state)?));
    }
    drop(function); // Pending requests must retain both function and model.
    for _ in 0..abandoned {
        drop(runtime.load_model(root.join(plain.model), plain.compute));
    }
    let model = runtime.load_model(root.join(plain.model), plain.compute).wait().map_err(text)?;
    for _ in 0..abandoned {
        drop(model.load_function("main"));
    }
    drop(model);
    runtime.flush().wait().map_err(text)?;
    // A fresh model remains usable after all abandoned work/releases drain.
    let function = load_function(runtime, root, plain)?;
    compare(root, &function.run(load_tensors(root, plain.inputs)?, TensorMap::new()).wait().map_err(text)?.outputs, plain.steps[0].outputs)?;
    drop(function);
    runtime.flush().wait().map_err(text)
}

fn execute() -> Result<(), String> {
    let args: Vec<_> = std::env::args().collect();
    let root = Path::new(args.get(1).ok_or("fixture path required")?);
    let mode = args.get(2).map(String::as_str).unwrap_or("parity");
    let runtime = Runtime::new().map_err(text)?;
    let mut failed = 0;
    if mode == "parity" {
        for case in CASES {
            let result = run_case(&runtime, root, case);
            emit("parity", case.name, case.backend, &result);
            failed += usize::from(result.is_err());
        }
        for backend in ["cpu", "gpu-preferred"] {
            for name in ["missing_asset", "missing_function", "missing_input", "unknown_input", "wrong_shape", "wrong_dtype", "missing_state", "wrong_state_shape"] {
                let result = negative(&runtime, root, backend, name);
                emit("negative", name, backend, &result);
                failed += usize::from(result.is_err());
            }
        }
    } else if mode == "stress" {
        let number = |index: usize, default: usize| args.get(index).map_or(Ok(default), |value| value.parse::<usize>().map_err(text));
        let cycles = number(3, 10_000)?;
        let loads = number(4, 100)?;
        let abandoned = number(5, 100)?;
        require(cycles > 0 && loads > 0 && abandoned > 0, "stress counts must be positive")?;
        for backend in ["cpu", "gpu-preferred"] {
            let result = stress(&runtime, root, backend, cycles, loads, abandoned);
            emit("stress", "lifecycle", backend, &result);
            failed += usize::from(result.is_err());
        }
        println!("{{\"event\":\"stress_counts\",\"stateless_per_backend\":{cycles},\"stateful_per_backend\":{cycles},\"load_drop_per_backend\":{loads},\"abandoned_each_kind_per_backend\":{abandoned}}}");
    } else {
        return Err(format!("unknown mode {mode}"));
    }
    runtime.flush().wait().map_err(text)?;
    println!("{{\"event\":\"complete\",\"mode\":{},\"failed\":{failed},\"passed\":{}}}", json(mode), failed == 0);
    require(failed == 0, format!("{failed} checks failed"))
}
fn main() {
    if let Err(error) = execute() {
        eprintln!("{error}");
        std::process::exit(1);
    }
}
