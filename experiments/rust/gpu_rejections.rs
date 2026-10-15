#![forbid(unsafe_code)]
//! No-payload GPU descriptor-boundary qualification. Both broadcast graphs are
//! GPU-rejection-only; CPU inference is restricted to the two x+x graphs. The
//! nonempty huge output is never explicitly allocated. Inputs have zero/four bytes.
use corsairs::{
    Compute, DType, Error, Function, MAX_GPU_INFERENCE_TENSOR_BYTES, MAX_TENSOR_BYTES,
    MetalBufferMap, MetalQueue, MetalValueMap, Runtime, Tensor, TensorHandleMap, TensorMap,
};
use std::io::Write;
use std::path::Path;

type Result<T = ()> = std::result::Result<T, Box<dyn std::error::Error>>;

struct Case {
    name: &'static str,
    input: &'static [usize],
    output: &'static [usize],
    gpu_reject: bool,
    cpu_run: bool,
}
const CASES: [Case; 4] = [
    Case {
        name: "empty-over-gpu-limit",
        input: &[0, 536870913],
        output: &[0, 536870913],
        gpu_reject: true,
        cpu_run: true,
    },
    Case {
        name: "empty-output-over-gpu-limit",
        input: &[0, 1],
        output: &[0, 536870913],
        gpu_reject: true,
        cpu_run: false,
    },
    Case {
        name: "nonempty-output-over-gpu-limit",
        input: &[1],
        output: &[536870913],
        gpu_reject: true,
        cpu_run: false,
    },
    // Recovery follows every rejection in the same runtime and Metal queue.
    Case {
        name: "empty-at-gpu-limit",
        input: &[0, 536870912],
        output: &[0, 536870912],
        gpu_reject: false,
        cpu_run: true,
    },
];

fn quoted(text: &str) -> String {
    let mut output = String::from("\"");
    for ch in text.chars() {
        match ch {
            '"' => output.push_str("\\\""),
            '\\' => output.push_str("\\\\"),
            '\n' => output.push_str("\\n"),
            '\r' => output.push_str("\\r"),
            '\t' => output.push_str("\\t"),
            c if c.is_control() => output.push_str(&format!("\\u{:04x}", c as u32)),
            c => output.push(c),
        }
    }
    output.push('"');
    output
}
fn event(case: &str, compute: &str, api: &str, kind: &str, detail: &str) {
    println!(
        "{{\"event\":\"check\",\"case\":{},\"compute\":{},\"api\":{},\"kind\":{},\"detail\":{},\"passed\":true}}",
        quoted(case),
        quoted(compute),
        quoted(api),
        quoted(kind),
        quoted(detail)
    );
    let _ = std::io::stdout().flush();
}
fn require(test: bool, message: impl Into<String>) -> Result {
    if test {
        Ok(())
    } else {
        Err(std::io::Error::other(message.into()).into())
    }
}
fn input(case: &Case) -> Result<Tensor> {
    let bytes = if case.input == [1] {
        1f32.to_le_bytes().to_vec()
    } else {
        Vec::new()
    };
    Ok(Tensor::from_bytes(DType::Float32, case.input, bytes)?)
}
fn tensor_is(tensor: &Tensor, shape: &[usize], bytes: &[u8]) -> Result {
    require(tensor.dtype() == DType::Float32, "dtype changed")?;
    require(
        tensor.shape() == shape,
        format!("shape changed: {:?} != {shape:?}", tensor.shape()),
    )?;
    require(tensor.as_bytes() == bytes, "payload changed")
}
fn descriptors(function: &Function, case: &Case, compute: &str) -> Result {
    let descriptor = function.descriptor();
    require(descriptor.states.is_empty(), "unexpected state descriptor")?;
    require(
        descriptor.inputs.len() == 1 && descriptor.outputs.len() == 1,
        "signature arity changed",
    )?;
    for (tensor, name, shape) in [
        (&descriptor.inputs[0], "x", case.input),
        (&descriptor.outputs[0], "y", case.output),
    ] {
        require(
            tensor.name == name
                && tensor.dtype == DType::Float32
                && tensor.shape == shape.iter().copied().map(Some).collect::<Vec<_>>(),
            format!("unexpected descriptor {tensor:?}"),
        )?;
    }
    event(
        case.name,
        compute,
        "descriptor",
        "metadata",
        "exact fixed float32 input/output shapes",
    );
    Ok(())
}
fn unsupported<T>(result: std::result::Result<T, Error>, case: &Case, api: &str) -> Result {
    match result {
        Err(Error::Unsupported(reason)) => {
            require(
                reason.contains("2 GiB") && reason.contains("inference boundary"),
                format!("unexpected Unsupported reason: {reason}"),
            )?;
            event(case.name, "gpu-preferred", api, "unsupported", &reason);
            Ok(())
        }
        Err(other) => {
            Err(format!("{} {api}: expected Unsupported, got {other:?}", case.name).into())
        }
        Ok(_) => Err(format!(
            "{} {api}: unexpectedly accepted over-limit GPU descriptor",
            case.name
        )
        .into()),
    }
}
fn run_case(
    runtime: &Runtime,
    root: &Path,
    queue: Option<&MetalQueue>,
    case: &Case,
    compute: Compute,
) -> Result {
    let compute_name = if compute == Compute::CpuOnly {
        "cpu"
    } else {
        "gpu-preferred"
    };
    require(
        compute != Compute::CpuOnly || case.cpu_run,
        "refusing CPU inference with a nonempty huge output",
    )?;
    let model = runtime
        .load_model(root.join(case.name).join("model.aimodel"), compute)
        .wait()?;
    let function = model.load_function("main").wait()?;
    descriptors(&function, case, compute_name)?;
    let input = input(case)?;
    let handle = runtime.upload(input.clone()).wait()?;
    tensor_is(&handle.download().wait()?, case.input, input.as_bytes())?;
    event(
        case.name,
        compute_name,
        "native-upload-download",
        "storage",
        "raw retained storage accepted independently of inference policy",
    );
    let reject = compute == Compute::GpuPreferred && case.gpu_reject;
    let owned = function
        .run(TensorMap::from([("x", input.clone())]), TensorMap::new())
        .wait();
    if reject {
        unsupported(owned, case, "owned")?;
    } else {
        let result = owned?;
        require(
            result.outputs.len() == 1 && result.states.is_empty(),
            "owned output arity/state changed",
        )?;
        tensor_is(
            result.outputs.get("y").ok_or("missing y")?,
            case.output,
            &[],
        )?;
        event(
            case.name,
            compute_name,
            "owned",
            "value",
            "empty bytes and metadata exact",
        );
    }
    let native = function
        .run_native(
            TensorHandleMap::from([("x", handle.clone())]),
            TensorHandleMap::new(),
        )
        .wait();
    if reject {
        unsupported(native, case, "native")?;
    } else {
        let result = native?;
        require(
            result.outputs.len() == 1 && result.states.is_empty(),
            "native output arity/state changed",
        )?;
        tensor_is(
            &result
                .outputs
                .get("y")
                .ok_or("missing y")?
                .download()
                .wait()?,
            case.output,
            &[],
        )?;
        event(
            case.name,
            compute_name,
            "native",
            "value",
            "empty bytes and metadata exact",
        );
    }
    if let Some(queue) = queue {
        let buffer = queue.upload(input.clone()).wait()?;
        tensor_is(&buffer.download().wait()?, case.input, input.as_bytes())?;
        event(
            case.name,
            compute_name,
            "metal-upload-download",
            "storage",
            "tiny/empty raw Metal storage accepted",
        );
        let auto = function
            .encode(
                queue,
                MetalValueMap::from([("x", buffer.clone())]),
                MetalBufferMap::new(),
                MetalBufferMap::new(),
            )
            .wait();
        if reject {
            unsupported(auto, case, "metal-auto")?;
        } else {
            let result = auto?;
            require(
                result.outputs.len() == 1 && result.states.is_empty(),
                "Metal output arity/state changed",
            )?;
            tensor_is(
                &result
                    .outputs
                    .get("y")
                    .ok_or("missing y")?
                    .download()
                    .wait()?,
                case.output,
                &[],
            )?;
            event(
                case.name,
                compute_name,
                "metal-auto",
                "value",
                "empty bytes and metadata exact",
            );
        }
        // A zero in the output shape guarantees no huge output allocation.
        if case.output.contains(&0) {
            let output = queue.buffer(DType::Float32, case.output).wait()?;
            tensor_is(&output.download().wait()?, case.output, &[])?;
            let bound = function
                .encode(
                    queue,
                    MetalValueMap::from([("x", buffer)]),
                    MetalBufferMap::new(),
                    MetalBufferMap::from([("y", output.clone())]),
                )
                .wait();
            if reject {
                unsupported(bound, case, "metal-bound")?;
            } else {
                let result = bound?;
                require(
                    result.outputs.len() == 1 && result.states.is_empty(),
                    "bound Metal output arity/state changed",
                )?;
                tensor_is(
                    &result
                        .outputs
                        .get("y")
                        .ok_or("missing y")?
                        .download()
                        .wait()?,
                    case.output,
                    &[],
                )?;
                tensor_is(&output.download().wait()?, case.output, &[])?;
                event(
                    case.name,
                    compute_name,
                    "metal-bound",
                    "value",
                    "explicit empty output bytes and metadata exact",
                );
            }
        }
    }
    // All resources owned by this case are dropped on return; the caller drains.
    Ok(())
}
fn run() -> Result {
    let root = std::env::args_os()
        .nth(1)
        .ok_or("usage: driver FIXTURE_DIRECTORY")?;
    let root = Path::new(&root);
    require(
        MAX_TENSOR_BYTES == 1usize << 32 && MAX_GPU_INFERENCE_TENSOR_BYTES == 1usize << 31,
        "unexpected public storage/inference limits",
    )?;
    for case in &CASES {
        let host = input(case)?;
        require(
            host.as_bytes().len() <= 4,
            "input unexpectedly allocated payload",
        )?;
        event(
            case.name,
            "host",
            "constructor",
            "storage",
            "host4GiB accepts logical empty or one-float input",
        );
    }
    let runtime = Runtime::new()?;
    for case in CASES.iter().filter(|case| case.cpu_run) {
        run_case(&runtime, root, None, case, Compute::CpuOnly)?;
        runtime.drain().wait()?;
        event(
            case.name,
            "cpu",
            "drop-drain",
            "lifecycle",
            "case resources dropped; runtime drain completed",
        );
    }
    {
        let queue = runtime.metal_queue().wait()?;
        for case in &CASES {
            run_case(&runtime, root, Some(&queue), case, Compute::GpuPreferred)?;
            queue.fence().wait()?;
            runtime.drain().wait()?;
            event(
                case.name,
                "gpu-preferred",
                "drop-drain",
                "lifecycle",
                "case resources dropped; queue fence and runtime drain completed",
            );
        }
    }
    runtime.drain().wait()?;
    println!(
        "{{\"event\":\"complete\",\"passed\":true,\"inference_checks\":19,\"expected_gpu_rejections\":11,\"positive_empty_results\":8,\"scope\":\"typed errors, exact metadata, recovery, explicit drop/drain; no live-allocation counter or leak-freedom measurement\"}}"
    );
    std::io::stdout().flush()?;
    Ok(())
}
fn main() {
    if let Err(error) = run() {
        eprintln!("{error}");
        println!(
            "{{\"event\":\"complete\",\"passed\":false,\"error\":{}}}",
            quoted(&error.to_string())
        );
        std::process::exit(1);
    }
}
